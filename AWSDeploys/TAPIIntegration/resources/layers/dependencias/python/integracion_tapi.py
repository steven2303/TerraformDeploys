import json,urllib.error , urllib.request as urequest
# import xml.etree.ElementTree as ET
from aplicacion_general import credenciales
import requests
class tapi:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        c = credenciales()
        dict_credenciales = c.obtener_datos_secret_manager()
        self.api_tapi_usuario = dict_credenciales.get('api_tapi_usuario')
        self.api_tapi_password = dict_credenciales.get('api_tapi_password')
        self.api_tapi_login_url = dict_credenciales.get('api_tapi_login_url')
        self.api_tapi_companies_url = dict_credenciales.get('api_tapi_companies_url')
        self.api_tapi_recharges_url = dict_credenciales.get('api_tapi_recharges_url')
        self.api_key_tapi_login = dict_credenciales.get('api_key_tapi_login')
        self.api_key_tapi_companies = dict_credenciales.get('api_key_tapi_companies')
        self.api_key_tapi_recharges = dict_credenciales.get('api_key_tapi_recharges')
        self.iservice_name = 'Endpoint'
        self.dict_duplicado = {}
        self.token_expiration = 0

    def login(self):
        data = {
            'clientUsername': self.api_tapi_usuario,
            'password': self.api_tapi_password
        }
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': self.api_key_tapi_login
        }
        request = urequest.Request(self.api_tapi_login_url , data=json.dumps(data).encode(), headers=headers)
        try:
            response = urequest.urlopen(request)
            response_data = json.loads(response.read())
            return response_data
        except urllib.error.HTTPError as e:
            return {'error': e.reason}

    def get_companie_detail(self, company_code):
        login_response = self.login()
        if 'error' in login_response:
            return login_response
        auth_token = login_response.get('accessToken')  
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': self.api_key_tapi_companies,
            'x-authorization-token': auth_token  # Incluir el token de autorización en el header
        }
        
        url_with_company_code = f"{self.api_tapi_companies_url}{company_code}"
        request = urequest.Request(url_with_company_code, headers=headers)
        try:
            response = urequest.urlopen(request)
            response_data = json.loads(response.read())
            return response_data
        except urllib.error.HTTPError as e:
            error_response = json.loads(e.read())
            return {'error': error_response}
        
    def payment(self, external_payment_id, external_client_id, product_id, company_code, identifier_name, identifier_value, amount, payment_method='DEBIT'):
        # Lógica para confirmar el pago
        login_response = self.login()
        if 'error' in login_response:
            return login_response
        data = {
            'companyCode': company_code,
            'productId': product_id,
            'externalPaymentId': external_payment_id,
            'externalClientId': external_client_id,
            'identifierName': identifier_name,
            'identifierValue': identifier_value,
            'amount': amount,
            'paymentMethod': payment_method
        }
        auth_token = login_response.get('accessToken')
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': self.api_key_tapi_recharges,
            'x-authorization-token': auth_token  # Incluir el token de autorización en el header
        }

        url_recharge = f"{self.api_tapi_recharges_url}/payment"
        request = urequest.Request(url_recharge, data=json.dumps(data).encode(), headers=headers)
        try:
            response = urequest.urlopen(request)
            response_data = json.loads(response.read())
            return {'status_code': response.getcode(), 'response_data': response_data}
        except urllib.error.HTTPError as e:
            error_response = json.loads(e.read())
            return {'status_code': e.code, 'error': error_response}
        
    def get_payment_status(self, operation_id):
        login_response = self.login()
        if 'error' in login_response:
            return login_response
        auth_token = login_response.get('accessToken')
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': self.api_key_tapi_recharges,
            'x-authorization-token': auth_token,
        }
        url_with_operation_id = f"{self.api_tapi_recharges_url}/operation/{operation_id}"
        try:
            response = requests.get(url_with_operation_id, headers=headers)
            if response.status_code != 200:
                error_details = response.json()
                return {'error': {'message': error_details.get('message', 'Unknown error'), 'code': error_details.get('code', 'UnknownCode')}}
            return response.json()
        except requests.HTTPError as e:
            error_response = e.response.json() 
            return {'error': {'message': error_response.get('message', 'Unknown error'), 'code': error_response.get('code', 'UnknownCode')}}
        

    def confirm_payment(self, external_payment_id, external_client_id, operation_id, status, company_code,company_name, amount,
                        amount_type, hash):
        # Lógica para confirmar el pago
        login_response = self.login()
        if 'error' in login_response:
            return login_response
        data = {
            'externalPaymentId': external_payment_id,
            'externalClientId': external_client_id,
            'operationId': operation_id,
            'status':status,
            'companyCode': company_code,
            'companyName': company_name,
            'amount': amount,
            'amountType': amount_type,
            'hash': hash
        }
        auth_token = login_response.get('accessToken')
        headers = {
            'Content-Type': 'application/json',
            'x-api-key': self.api_key_tapi_recharges,
            'x-authorization-token': auth_token  # Incluir el token de autorización en el header
        }

        url_recharge = f"{self.api_tapi_recharges_url}/payment"
        request = urequest.Request(url_recharge, data=json.dumps(data).encode(), headers=headers)
        try:
            response = urequest.urlopen(request)
            response_data = json.loads(response.read())
            return {'status_code': response.getcode(), 'response_data': response_data}
        except urllib.error.HTTPError as e:
            error_response = json.loads(e.read())
            return {'status_code': e.code, 'error': error_response}