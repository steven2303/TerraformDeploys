import json
import requests
from requests_aws4auth import AWS4Auth
from urllib.parse import urlencode
import boto3
from datetime import datetime, timedelta
import pytz

# Variable global para almacenar credenciales cacheadas
cached_credentials = None

def get_sts_credentials():
    global cached_credentials
    # Asegúrate de que ahora esté en la misma zona horaria que las credenciales de AWS STS
    now_with_tz = datetime.now(pytz.UTC)
    if not cached_credentials or now_with_tz >= cached_credentials['Expiration']:
        sts_client = boto3.client('sts')
        assumed_role_object = sts_client.assume_role(
            RoleArn="arn:aws:iam::577585731673:role/cross-account-654654330879-api-access-role",
            RoleSessionName="AssumeRoleSession1"
        )
        # AWS ya devuelve la hora de expiración en UTC
        expiration_datetime = assumed_role_object['Credentials']['Expiration']
        # Restamos 5 minutos para asegurar un margen antes de la expiración real
        cached_credentials = assumed_role_object['Credentials']
        cached_credentials['Expiration'] = expiration_datetime - timedelta(minutes=5)
    return cached_credentials

def invoke_api_with_aws_auth(service, region, url, params):
    credentials = get_sts_credentials()
    awsauth = AWS4Auth(credentials['AccessKeyId'], credentials['SecretAccessKey'], region, service, session_token=credentials['SessionToken'])
    
    query_string = urlencode(params)
    url_with_params = f"{url}?{query_string}"
    
    response = requests.get(url_with_params, auth=awsauth)
    return response

def lambda_handler(event, context):
    service = 'execute-api'
    region = 'us-west-2'
    url = 'https://kawn9npp34.execute-api.us-west-2.amazonaws.com/dev/products-recommender-and-profile'
    params = {'cod_persona': '354396'}
    
    response = invoke_api_with_aws_auth(service, region, url, params)
    
    if response.status_code == 200:
        return {
            'statusCode': 200,
            'body': json.dumps('API invoked successfully!')
        }
    else:
        return {
            'statusCode': response.status_code,
            'body': json.dumps('Failed to invoke API')
        }

