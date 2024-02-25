import sys
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
from pyspark.sql import SparkSession
from pyspark.sql.functions import expr,split,to_date,regexp_replace,col, lit, concat,udf, length, concat_ws, date_format,current_date
from pyspark.sql.types import BooleanType, StringType
from datetime import datetime

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_INPUT_PATH', 'OUTPUT_DIR', 'OUTPUT_DIR_ERR'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()

# Define paths using arguments
s3_input_path = args['S3_INPUT_PATH']
output_dir = args['OUTPUT_DIR']
output_dir_err = args['OUTPUT_DIR_ERR']

date_suffix = datetime.now().strftime("%Y%m%d%H%M")
# Initialize Spark session
spark = SparkSession.builder.appName("ETLLogsFormatting").getOrCreate()

# Read Folder
full_df_input = spark.read.csv(s3_input_path, encoding='iso-8859-1', sep=';', header=False)

full_transformed_df  = full_df_input.select(
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

full_df_filtered  = full_transformed_df .filter(full_transformed_df ['documento_cliente'] != '')

def full_filter_dni_nulls(dataframe):
    df_error = dataframe.filter(dataframe['documento_cliente'] == '').drop('nro_dni2')
    df_single_column_error = df_error.select(concat_ws("", *df_error.columns).alias("concatenated"))
    return df_single_column_error

def full_keep_only_numeric(df, column):
    # Cast the specified column to bigint
    df = df.withColumn(column, col(column).cast('bigint'))
    # Filter out rows where the column is null after casting
    df1 = df.filter(col(column).isNotNull()).drop('nro_dni2')
    df_dni_errors = df.filter(col(column).isNull()).drop('nro_dni2')
    df_single_column_dni_error = df_dni_errors.select(concat_ws("", *df_dni_errors.columns).alias("concatenated"))
    return df1,df_single_column_dni_error

df_nulls_dni = full_filter_dni_nulls(full_transformed_df )
df_cleaned,df_dni_errors = full_keep_only_numeric(full_df_filtered , 'nro_dni2')

df_errors = df_dni_errors.union(df_nulls_dni)

df_errors = df_errors.repartition(1)
df_errors.write.mode('overwrite').option("header", "false").text(output_dir_err)

df_cleaned.write.mode('overwrite').partitionBy('fecha').parquet(output_dir)
# Stop the Spark session
spark.stop()