import json, urllib.request as urequest
from urllib.error import HTTPError, URLError
from aplicacion_general import credenciales
class bonus:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        c = credenciales()
        dict_credenciales = c.obtener_datos_secret_manager()
        self.vuser = dict_credenciales.get('api_bonus_usuario')
        self.vpass = dict_credenciales.get('api_bonus_password')
        self.base = dict_credenciales.get('api_bonus_url')
        self.url_token = f"{self.base}auth/login"
        self.url_registrar_cliente = f"{self.base}bonus/customer-affiliation/register-customer"
        self.url_verificar_cliente = f"{self.base}bonus/customer-affiliation/exists-customer"
        self.url_obtener_stock = f"{self.base}bonus/customer-points/stock-product-exchange"
        self.url_obtener_puntos = f"{self.base}bonus/customer-points/get-points-balance"
        self.url_verificar_atributo = f"{self.base}bonus/customer-affiliation/exists-attribute"
        self.url_aceptar_contrato = f"{self.base}bonus/customer-affiliation/accept-contract"
        self.url_obtener_movimiento_puntos = f"{self.base}bonus/customer-points/lastest-moves-points"
        self.url_obtener_mecanica_puntos = f"{self.base}bonus/customer-points/get-points-purchase-mechanics"
        self.url_comprar_puntos = f"{self.base}bonus/customer-points/buy-points"
        self.url_transferir_puntos = f"{self.base}bonus/customer-points/points-transfer"
        self.url_canjear_puntos = f"{self.base}bonus/customer-points/prize-exchange"
        self.userid = self.params['userid'] if 'userid' in self.params else 'APPBONUS'
        self.operatingsystem = self.params['operatingsystem'] if 'operatingsystem' in self.params else 'WEB'
        self.physicalstoreid = self.params['physicalStoreId'] if 'physicalStoreId' in self.params else 20
        self.exchangepointcode = '0020'
        self.participantcode = self.params['participantCode'] if 'participantCode' in self.params else '0020'
        self.storecode = self.params['storeCode'] if 'storeCode' in self.params else '0020'
        self.personstatuscode = self.params['personStatusCode'] if 'personStatusCode' in self.params else '1'
        self.personstatusdesc = self.params['personStatusDesc'] if 'personStatusDesc' in self.params else ''
        self.vouchertype = self.params['voucherType'] if 'voucherType' in self.params else 3
        self.methodpayment = self.params['methodPayment'] if 'methodPayment' in self.params else 25
        self.token_transferir = self.params['token'] if 'token' in self.params else 0
        self.shippingtype = 1
        self.productpartner = ''
        self.code = 0
        self.token = 0

    def __generar_token(self)->str:
        body = {
        "username": self.vuser,
        "password": self.vpass
        }
        headers = {
            "Content-Type": "application/json"
        }
        result_request = urequest.Request(self.url_token,data = json.dumps(body).encode('utf-8'), headers = headers , method='POST')
        response = urequest.urlopen(result_request)
        return json.loads(response.read().decode('utf-8'))['jwtToken']
    
    def enviar_request(self,url,datos):
        headers = {
            "Authorization": f"Bearer {self.__generar_token()}",
            "Content-Type": "application/json"
        }
        result_request = urequest.Request(url,data = json.dumps(datos).encode('utf-8'), headers = headers , method='POST')
        response = urequest.urlopen(result_request)
        return json.loads(response.read().decode('utf-8'))
    def verificar_cliente(self,tipo,documento):
        datos = {
                "documentTypeCode": tipo,
                "documentTypeNumber": documento,
                "userId": self.userid,
                "operatingSystem": self.operatingsystem
            }
        try:
            result=self.enviar_request(self.url_verificar_cliente,datos)
            result.update({'estado':True})
            if int(result['errorCode'])>0:
                result = {'estado':False, 'mensaje': result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    
    def obtener_stock(self,dict_params):
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "physicalStoreId": self.physicalstoreid,
            "productList": dict_params.get('productos'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }
        try:
            result = result = self.enviar_request(self.url_obtener_stock,datos)
            result.update({'estado':True,'mensaje':''})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    
    def obtener_puntos(self,dict_params):
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }
        try:
            result = self.enviar_request(self.url_obtener_puntos,datos)
            result.update({'estado':True})
            if int(result['errorCode'])>0:
                result = {'estado':False, 'mensaje': result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    

    def registrar_cliente(self,dict_params):
        split_name = str(dict_params.get('given_name')).split(' ')
        if len(split_name)<2:
            split_name.append('-')
        split_fecha = str(dict_params.get('birthdate')).split('/')
        datos = {
                "person": {
                            "address": "" if not dict_params.get('custom:direccion') else dict_params.get('custom:direccion'),
                            "addressAltitude": "" if not dict_params.get('custom:altitud') else dict_params.get('custom:altitud'),
                            "addressExactitude": "" if not dict_params.get('custom:exactitud') else dict_params.get('custom:exactitud'),
                            "addressLatitude": "" if not dict_params.get('custom:latitude') else dict_params.get('custom:latitude'),
                            "addressLongitude": "" if not dict_params.get('custom:longitud') else dict_params.get('custom:longitud'),
                            "addressReference": "" if not dict_params.get('custom:referencia') else dict_params.get('custom:referencia'),
                            "postalCode": "0" if not dict_params.get('custom:cod_postal') else dict_params.get('custom:cod_postal'),
                            "associateCode": "" if not dict_params.get('custom:cod_asociado') else dict_params.get('custom:cod_asociado'),
                            "birthDate": "" if not dict_params.get('birthdate') else f'{split_fecha[2]}-{split_fecha[1]}-{split_fecha[0]}',
                            "cellPhoneNumber": "" if not dict_params.get('phone_number') else str(dict_params.get('phone_number'))[3:],
                            "civilStatus": "1" if not dict_params.get('custom:civil_estado') else dict_params.get('custom:civil_estado'),
                            "departmentCode": "" if not dict_params.get('custom:cod_departamento') else dict_params.get('custom:cod_departamento'),
                            "provinceCode": "" if not dict_params.get('custom:cod_provincia') else dict_params.get('custom:cod_provincia'),
                            "districtCode": "" if not dict_params.get('custom:cod_distrito') else dict_params.get('custom:cod_distrito'),
                            "documentNumber": "" if not dict_params.get('custom:nro_documento') else dict_params.get('custom:nro_documento'),
                            "documentTypeCode": "" if not dict_params.get('custom:id_tipo_documento') else dict_params.get('custom:id_tipo_documento'),
                            "email": "" if not dict_params.get('email') else dict_params.get('email'),
                            "firstName": split_name[0] if not str(dict_params.get('middle_name')).replace(' ','') else dict_params.get('given_name'),
                            "secondName": split_name[1] if not str(dict_params.get('middle_name')).replace(' ','') else dict_params.get('middle_name'),
                            "lastName": "" if not dict_params.get('custom:apellido_paterno') else dict_params.get('custom:apellido_paterno'),
                            "motherLastName": "" if not dict_params.get('custom:apellido_materno') else dict_params.get('custom:apellido_materno'),
                            "personCode": "",
                            "personNickName": split_name[0] if not str(dict_params.get('middle_name')).replace(' ','') else dict_params.get('given_name'),
                            "personStatusCode": self.personstatuscode,
                            "personStatusDesc": self.personstatusdesc,
                            "sex": "M" if not dict_params.get('gender') else dict_params.get('gender'),
                            "urlBackDocument": "url" if not dict_params.get('custom:urlBackDocument') else dict_params.get('custom:urlBackDocument'),
                            "urlFrontDocument": "url" if not dict_params.get('custom:urlFrontDocument') else dict_params.get('custom:urlFrontDocument')
                        },
                "participantCode": self.participantcode,
                "storeCode": self.storecode,
                "operatingSystem": self.operatingsystem,
                "userId": self.userid
            }
        try:
            result = self.enviar_request(self.url_registrar_cliente,datos)
            result.update({'estado':True})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
                      
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result 
    
    def aceptar_contrato(self,dict_params):
        datos = {
            "personCode": dict_params.get('personCode'),
            "documentCode": dict_params.get('custom:id_tipo_documento'),
            "documentNumber": dict_params.get('custom:nro_documento'),
            "termAndCondition": dict_params.get('custom:terminos'),
            "protectionClause": dict_params.get('custom:proteccionDatos'),
            "publicityAccept": "false",
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }
        try: 
            result = self.enviar_request(self.url_aceptar_contrato,datos)
            result.update({'estado':True})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
                      
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result  
    
    def obtener_movimiento_puntos(self,dict_params):
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }

        try:
            result = self.enviar_request(self.url_obtener_movimiento_puntos,datos)
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
            else :
                if int(result['numberTransactions'])==0:
                    result.update({'transactions':[{}]})
                result.update({'estado':True,'mensaje':''})
                      
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result    
    
    
    def obtener_mecanica_puntos(self,dict_params):
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "points": dict_params.get('puntos'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }

        try:
            result = self.enviar_request(self.url_obtener_mecanica_puntos,datos)
            result.update({'estado':True})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
                      
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result  


    def comprar_puntos(self,dict_params):
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "cardCode": dict_params.get('tarjeta'),
            "points": dict_params.get('puntos'),
            "coins": dict_params.get('soles'),
            "methodPayment": dict_params.get('metodo'),
            "voucherType": dict_params.get('documento_pago'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem,
            "operationNumber": dict_params.get('transaccion')
        }

        try:
            result = self.enviar_request(self.url_comprar_puntos,datos)
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
                      
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result  

    
    def verificar_atributo(self,dict_params):
        datos = {
                "searchType": dict_params.get('tipo_validacion'),
                "valueNume": dict_params.get('numero_validacion'),
                "valueString": dict_params.get('valor_validacion'),
                "userId": self.userid,
                "operatingSystem": self.operatingsystem
        }
        try:
            result = self.enviar_request(self.url_verificar_atributo,datos)
            result.update({'estado':True})
            if int(result['errorCode'])!=7 and dict_params.get('tipo_validacion') == 'T':
                result.update({'estado':False, 'mensaje':result['errorMessage']})
                if result['errorMessage'] == '':
                    result.update({'mensaje': 'telefono no existe'})
            if int(result['errorCode'])!=6 and dict_params.get('tipo_validacion') == 'C':
                result.update({'estado':False,'mensaje':result['errorMessage']})
                if result['errorMessage'] == '':
                    result.update({'mensaje': 'correo no existe'})
            if int(result['errorCode'])==0 and dict_params.get('tipo_validacion') == 'D' and result['personCode']=='':
                result.update({'estado':False,'mensaje':result['errorMessage']})
                if result['errorMessage'] == '':
                    result.update({'mensaje': 'documento no existe'})
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}        
        return result
        
    def transferir_puntos(self,dict_params):
        datos = {
            "sender": {
                "personCode": dict_params.get('codigo_persona'),
                "docuTypeCode": dict_params.get('tipo_documento'),
                "documentNumber": dict_params.get('documento')
            },
            "receiver": {
                "personCode": dict_params.get('codigo_persona_destino')
            },
            "points": dict_params.get('puntos'),
            "token": self.token_transferir,
            "userId": self.userid,
                "operatingSystem": self.operatingsystem
        }
        try:
            result = self.enviar_request(self.url_transferir_puntos,datos)
            result.update({'estado':True,'mensaje':''})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    
    def canjear_puntos(self, dict_params):
        """
        {
            "personCode":"0001374662",
            "docuTypeCode": 1,
            "documentNumber": "41231649",
            "cardCode": 7027661000309162457,
            "points": 150,
            "coins": 15.00,
            "shippingType": 1,
            "participatingCode": "0020",
            "exchangePointCode": "0020",
            "deliveryData": {
                
            },
            "shoppingCart": [
                {
                    "productCode": "2026643",
                    "productQuantity": 1,
                    "productPoints": 150,
                    "productCoins": 15.00,
                    "productPartner": "",
                    "certificates":[{
                        "code": 0
                    }]
                }
            ],
            "physicalStoreId": 20,
            "operationNumber": 600000005,
            "token": 0,
            "userId": "WEBBONUS",
            "operatingSystem": "WEB"
        }
        """
        datos = {
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "cardCode": dict_params.get('numero_tarjeta_bonus'),
            "points": dict_params.get('puntos'),
            "coins": dict_params.get('soles'),
            "shippingType": self.shippingtype,
            "participatingCode": self.participantcode,
            "exchangePointCode": self.exchangepointcode,
            "deliveryData": {},
            "shoppingCart": dict_params.get('carrito'),
            "physicalStoreId": self.physicalstoreid,
            "operationNumber": dict_params.get('numero_operacion'),
            "token": self.token,
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }
        try:
            result = self.enviar_request(self.url_canjear_puntos,datos)
            result.update({'estado':True,'mensaje':''})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    
    def informacion_tarjeta(self, dict_params):
        """
        {
            "personCode": "",
            "docuTypeCode": 0,
            "documentNumber": "",
            "userId": "APPBONUS",
            "operatingSystem": "WEB"
        }
        """
        datos = {
            
            "personCode": dict_params.get('codigo_persona'),
            "docuTypeCode": dict_params.get('tipo_documento'),
            "documentNumber": dict_params.get('documento'),
            "userId": self.userid,
            "operatingSystem": self.operatingsystem
        }
        try:
            result = self.enviar_request(self.url_canjear_puntos,datos)
            result.update({'estado':True,'mensaje':''})
            if int(result['errorCode'])>0:
                result={'estado':False,'mensaje':result['errorMessage']}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
