import json, urllib.request as urequest
from urllib.error import HTTPError, URLError
from aplicacion_general import credenciales
class keynua:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        c = credenciales()
        dict_credenciales = c.obtener_datos_secret_manager()
        self.base = dict_credenciales.get('api_keynua_url')
        self.token = dict_credenciales.get('api_keynua_token')
        self.authorization = dict_credenciales.get('api_keynua_authorization')
        self.url_verificar_cliente = f"{self.base}identity-verification/v1"
    
    def enviar_request(self,url,datos):
        headers = {
            "x-api-key":self.token,
            "authorization":self.authorization,
            "Content-Type": "application/json"
        }
        result_request = urequest.Request(url,data = json.dumps(datos).encode('utf-8'), headers = headers , method='PUT')
        response = urequest.urlopen(result_request)
        return json.loads(response.read().decode('utf-8'))
    def verificar_cliente(self,numero_documento,telefono,nombre_completo,titulo,tipo,tipo_documento,estado_notificacion,validar_documento):
        datos = {
                    "documentNumber": numero_documento,
                    "userPhone": telefono,
                    "userFullName": nombre_completo,
                    "title": titulo,
                    "type": tipo,
                    "documentType": tipo_documento,
                    "disableInitialNotification": estado_notificacion,
                    "validateDocument": validar_documento
                }
        try:
            if tipo_documento == 'passport':
                datos.update({"documentScanVersion":2})
            result = self.enviar_request(self.url_verificar_cliente,datos)
            result.update({'estado':True, 'mensaje':''})
            #if result.get('code') == 'InvalidParameter':
            #    result = {'estado':False, 'mensaje':'dato no soportaddo'}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
