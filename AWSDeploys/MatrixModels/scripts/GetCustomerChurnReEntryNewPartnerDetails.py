import boto3
import json
import pg8000
import decimal
import os

# Inicializa la conexión fuera del manejador de la función para reutilizarla entre invocaciones
conn = None

def get_db_connection():
    global conn
    secret_id = os.environ.get('secrets_manager_secret_name')

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
            return {
                "headers": {"Content-Type": "application/json"},
                'body': json.dumps({"status": False, "message": str(e), "data": {}})
            }

    return conn

def lambda_handler(event, context):
    try:
        conn = get_db_connection()
        params = event.get('queryStringParameters', {})
        cod_persona = params.get('cod_persona', None)
        socio = params.get('socio', None)
        query = f"SELECT * FROM modelos_matrix.desercion_reingreso_nuevosocio WHERE cod_persona = '{cod_persona}' AND socio = '{socio}'"

        with conn.cursor() as cursor:
            cursor.execute(query)
            columns = [desc[0] for desc in cursor.description]
            row = cursor.fetchone()
            if row:
                data = dict(zip(columns, row))
                status = True
                message = "OK"
            else:
                data = {}
                status = False
                message = "No existen datos para ese cliente."

        return {
            "headers": {"Content-Type": "application/json"},
            'body': json.dumps({"status": status, "message": message, "data": data}, default=lambda x: str(x) if isinstance(x, decimal.Decimal) else x)
        }
    except Exception as e:
        return {
            "headers": {"Content-Type": "application/json"},
            'body': json.dumps({"status": False, "message": str(e), "data": {}})
        }