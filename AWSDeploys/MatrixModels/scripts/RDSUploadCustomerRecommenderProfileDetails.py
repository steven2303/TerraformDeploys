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
args = ['BUCKET_NAME', 'PREFIX_RECOMMENDER', 'PREFIX_PROFILE', 'SECRET_NAME', 'TABLE_NAME']

# Get the arguments passed to the script
options = getResolvedOptions(sys.argv, args)

# Extract the individual arguments
BUCKET_NAME = options['BUCKET_NAME']
PREFIX_RECOMMENDER = options['PREFIX_RECOMMENDER']
PREFIX_PROFILE = options['PREFIX_PROFILE']
SECRET_NAME = options['SECRET_NAME']
TABLE_NAME = options['TABLE_NAME']

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def extract_date_from_key(key):
    date_pattern = re.compile(r'\d{4}-\d{2}-\d{2}')
    match = date_pattern.search(key)
    if match:
        return match.group()
    return None

def update_latest_partition(key, date, latest_date, latest_partition):
    if latest_date is None or date > latest_date:
        return date, key
    return latest_date, latest_partition

def get_latest_partition(s3_client, bucket_name, prefix):
    paginator = s3_client.get_paginator('list_objects_v2')
    result = paginator.paginate(Bucket=bucket_name, Prefix=prefix)
    latest_date = None
    latest_partition = None

    for page in result:
        if 'Contents' in page:
            for obj in page['Contents']:
                key = obj['Key']
                date = extract_date_from_key(key)
                if date:
                    latest_date, latest_partition = update_latest_partition(key, date, latest_date, latest_partition)

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

    latest_partition_recommender = get_latest_partition(s3_client, BUCKET_NAME, PREFIX_RECOMMENDER)
    latest_partition_profile = get_latest_partition(s3_client, BUCKET_NAME, PREFIX_PROFILE)

    logger.info(f"latest_partition_recommender: {latest_partition_recommender}")
    logger.info(f"latest_partition_profile: {latest_partition_profile}")

    df_recommender = pd.read_parquet(f"s3://{BUCKET_NAME}/{latest_partition_recommender}")
    df_profile = pd.read_parquet(f"s3://{BUCKET_NAME}/{latest_partition_profile}")

    df_recommender_profile = df_profile.merge(df_recommender[[
        'cod_persona', 'sku_1', 'sku_2', 'sku_3', 'sku_4', 'sku_5', 'sku_6','sku_7', 'sku_8', 'sku_9', 'sku_10', 
        'sku_11', 'sku_12', 'sku_13','sku_14', 'sku_15'
    ]], how='outer', on='cod_persona')
    #df_recommender_profile = df_recommender_profile[df_recommender_profile.sku_1.notnull()].copy()

    secret_dict = get_db_credentials(SECRET_NAME)
    engine = create_db_engine(secret_dict)

    truncate_table(engine)

    columns = ', '.join(df_recommender_profile.columns)
    values_placeholders = ', '.join(['%s'] * len(df_recommender_profile.columns))
    insert_query = f'INSERT INTO {TABLE_NAME} ({columns}) VALUES ({values_placeholders})'

    batch_size = 5000
    with ThreadPoolExecutor(max_workers=10) as executor:
        for i in range(0, len(df_recommender_profile), batch_size):
            batch = df_recommender_profile.iloc[i:i+batch_size]
            executor.submit(insert_batch, batch, engine, insert_query)

if __name__ == "__main__":
    main()