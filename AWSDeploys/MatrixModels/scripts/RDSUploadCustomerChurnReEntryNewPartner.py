import boto3
import re
import pandas as pd
import pg8000
import json
from concurrent.futures import ThreadPoolExecutor
import logging
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool
import sys
from awsglue.utils import getResolvedOptions

# Define the argument names that you expect to receive from the Glue job
args = ['BUCKET_NAME', 'PREFIX_CHURN', 'PREFIX_NEW_PARTNER','PREFIX_RE_ENTRY', 'SECRET_NAME', 'TABLE_NAME']

# Get the arguments passed to the script
options = getResolvedOptions(sys.argv, args)

# Extract the individual arguments
BUCKET_NAME = options['BUCKET_NAME']
PREFIX_CHURN = options['PREFIX_CHURN']
PREFIX_NEW_PARTNER = options['PREFIX_NEW_PARTNER']
PREFIX_RE_ENTRY = options['PREFIX_RE_ENTRY']
SECRET_NAME = options['SECRET_NAME']
TABLE_NAME = options['TABLE_NAME']

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_latest_partition(s3_client, bucket_name, prefix):
    paginator = s3_client.get_paginator('list_objects_v2')
    result = paginator.paginate(Bucket=bucket_name, Prefix=prefix)
    latest_date = None
    latest_partition = None
    date_pattern = re.compile(r'\d{4}-\d{2}-\d{2}')

    for page in result:
        if 'Contents' in page:
            for obj in page['Contents']:
                key = obj['Key']
                match = date_pattern.search(key)
                if match:
                    date = match.group()
                    if latest_date is None or date > latest_date:
                        latest_date = date
                        latest_partition = key

    return latest_partition

def get_db_credentials(secret_name):
    client = boto3.client(service_name='secretsmanager')
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)

def create_db_engine(secret_dict, pool_size=10):
    connection_string = f"postgresql+pg8000://{secret_dict['DBUser']}:{secret_dict['DBPassword']}@{secret_dict['DBHost']}/{secret_dict['DBName']}"
    engine = create_engine(connection_string, poolclass=QueuePool, pool_size=pool_size)
    return engine

def insert_batch(batch, engine, insert_query):
    with engine.connect() as conn:
        try:
            conn.execute(insert_query, [tuple(x) for x in batch.values])
        except Exception as e:
            logger.error(f"Error inserting batch: {e}")

def truncate_table(engine):
    with engine.connect() as conn:
        try:
            conn.execute(f"TRUNCATE TABLE {TABLE_NAME}")
            logger.info("Table truncated successfully")
        except Exception as e:
            logger.error(f"Error truncating table: {e}")


def main():
    s3_client = boto3.client('s3')

    latest_partition_churn = get_latest_partition(s3_client, BUCKET_NAME, PREFIX_CHURN)
    latest_partition_new_partner = get_latest_partition(s3_client, BUCKET_NAME, PREFIX_NEW_PARTNER)
    latest_partition_re_entry = get_latest_partition(s3_client, BUCKET_NAME, PREFIX_RE_ENTRY)

    logger.info(f"latest_partition_recommender: {latest_partition_churn}")
    logger.info(f"latest_partition_profile: {latest_partition_new_partner}")
    logger.info(f"latest_partition_profile: {latest_partition_re_entry}")

    df_churn = pd.read_parquet(f"s3://{BUCKET_NAME}/{latest_partition_churn}")
    df_new_partner = pd.read_parquet(f"s3://{BUCKET_NAME}/{latest_partition_new_partner}")
    df_re_entry = pd.read_parquet(f"s3://{BUCKET_NAME}/{latest_partition_re_entry}")

    df_merge = df_new_partner[['mes_nuevo_socio','cod_cliente','socio','prob_nuevo_socio','flag_nuevo_socio','categoria_nuevo_socio','tiempo_bonus']].merge(df_re_entry,how = 'outer',
                            on = ['cod_cliente','socio'])
    df_merge = df_merge.merge(df_churn,how = 'outer',on = ['cod_cliente','socio'])
    df_merge = df_merge[['cod_cliente', 'socio','mes_nuevo_socio','prob_nuevo_socio','flag_nuevo_socio', 'categoria_nuevo_socio','tiempo_bonus','mes_reingreso', 'prob_reingreso', 
                         'flag_reingreso', 'meses_inactivos','categoria_reingreso','mes_desercion', 'prob_desercion','flag_desercion', 
                         'categoria_desercion']].rename(columns = {'cod_cliente':'cod_persona'})
    df_merge[['prob_nuevo_socio','prob_reingreso','prob_desercion']] = round(df_merge[['prob_nuevo_socio','prob_reingreso','prob_desercion']],3)
    secret_dict = get_db_credentials(SECRET_NAME)
    engine = create_db_engine(secret_dict)

    truncate_table(engine)

    columns = ', '.join(df_merge.columns)
    values_placeholders = ', '.join(['%s'] * len(df_merge.columns))
    insert_query = f'INSERT INTO {TABLE_NAME} ({columns}) VALUES ({values_placeholders})'

    batch_size = 5000
    with ThreadPoolExecutor(max_workers=10) as executor:
        for i in range(0, len(df_merge), batch_size):
            batch = df_merge.iloc[i:i+batch_size]
            executor.submit(insert_batch, batch, engine, insert_query)

if __name__ == "__main__":
    main()

    