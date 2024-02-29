import boto3
import json
import pg8000
import decimal
import os

# Inicializa la conexión fuera del manejador de la función para reutilizarla entre invocaciones
conn = None

def get_db_connection():
    global conn
    secret_id = os.environ.get('SECRET_ID')

    if conn is None:
        try:
            # Intenta crear una nueva conexión
            secrets_client = boto3.client('secretsmanager')
            secret = secrets_client.get_secret_value(SecretId=secret_id)['SecretString']
            secret_dict = json.loads(secret)
            
            conn_params = {
                "database": secret_dict['DBName'],
                "user": secret_dict['DBUser'],
                "password": secret_dict['DBPassword'],
                "host": secret_dict['DBHost'],
                "port": 5432
            }
            
            conn = pg8000.connect(**conn_params)
        except pg8000.InterfaceError:
            # Maneja errores de conexión
            print("Error al conectar a la base de datos")

    return conn

def lambda_handler(event, context):
    conn = get_db_connection()
    cod_persona = event.get('queryStringParameters', {}).get('cod_persona', None)
    query = f"SELECT * FROM modelos_matrix.recomendador_producto_perfil WHERE cod_persona = '{cod_persona}'"

    with conn.cursor() as cursor:
        cursor.execute(query)
        columns = [desc[0] for desc in cursor.description]
        row = cursor.fetchone()
        if row:
            result = dict(zip(columns, row))
        else:
            result = {}

    return {
        'statusCode': 200,
        "headers": {"Content-Type": "application/json"},
        'body': json.dumps(result, default=lambda x: str(x) if isinstance(x, decimal.Decimal) else x)
    }