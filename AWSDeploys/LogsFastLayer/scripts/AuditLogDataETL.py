import sys
from datetime import datetime
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import SparkSession

from pyspark.sql.functions import expr,split,to_date,regexp_replace,col, lit, concat,udf, length, concat_ws, date_format,current_date
from pyspark.sql.types import BooleanType, StringType

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()

# Fetch the arguments
args = getResolvedOptions(sys.argv, ['bucket_name', 'file_name','log_destination','error_destination'])
bucket_name = args['bucket_name']
file_name = args['file_name']
log_destination = args['log_destination']
error_destination = args['error_destination']

# Define paths
s3_input_path = "s3://" + bucket_name +"/" +file_name
print(s3_input_path)

output_dir = log_destination
date_suffix = datetime.now().strftime("%Y%m%d%H%M")
name = file_name.split('/')[-1]
output_dir_err = error_destination + name  # + '_' + str(date_suffix)

# Initialize Spark session
spark = SparkSession.builder.appName("LogsFormatting").getOrCreate()

# Read Folder
df_input = spark.read.csv(s3_input_path, encoding='iso-8859-1', sep=';', header=False)

transformed_df = df_input.select(
    expr("substring(_c0, 1, 1) as tipo"),
    to_date(expr("substring(_c0, 2, 8)"), 'yyyyMMdd').alias('fecha'),
    expr("substring(_c0, 10, 8) as hora"),
    expr("trim(substring(_c0, 18, 10)) as usuario"),
    expr("trim(substring(_c0, 28, 10)) as pgm"),
    expr("substring(_c0, 38, length(_c0) - 37) as trama"),
    regexp_replace(expr("trim(split(substring(_c0, 38, length(_c0)), '\\\\|')[0])"), "D\\.N\\.I\\.\\s*", "").alias("documento_cliente"),
    regexp_replace(expr("trim(split(substring(_c0, 38, length(_c0)), '\\\\|')[0])"), "D\\.N\\.I\\.\\s*", "").alias("nro_dni2"),
    current_date().alias('fecprod')  # Add current date
).drop('_c0')

df_filtered = transformed_df.filter(transformed_df['documento_cliente'] != '')

def filter_dni_nulls(dataframe):
    df_error = dataframe.filter(dataframe['documento_cliente'] == '').drop('nro_dni2')
    df_single_column_error = df_error.select(concat_ws("", *df_error.columns).alias("concatenated"))
    return df_single_column_error

def keep_only_numeric(df, column):
    # Cast the specified column to bigint
    df = df.withColumn(column, col(column).cast('bigint'))
    # Filter out rows where the column is null after casting
    df1 = df.filter(col(column).isNotNull()).drop('nro_dni2')
    df_dni_errors = df.filter(col(column).isNull()).drop('nro_dni2')
    df_single_column_dni_error = df_dni_errors.select(concat_ws("", *df_dni_errors.columns).alias("concatenated"))
    return df1,df_single_column_dni_error

df_nulls_dni = filter_dni_nulls(transformed_df)
df_cleaned,df_dni_errors = keep_only_numeric(df_filtered, 'nro_dni2')

df_errors = df_dni_errors.union(df_nulls_dni)

df_errors = df_errors.repartition(1)
df_errors.write.mode('overwrite').option("header", "false").text(output_dir_err)


dataNew_repartitioned = df_cleaned.repartition(1)
dataNew_repartitioned.write.mode('append').partitionBy('fecha').parquet(output_dir)

# Stop the Spark session
spark.stop()