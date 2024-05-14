import json, urllib.request as urequest, urllib.parse as uparse
from urllib.error import HTTPError, URLError

class capa:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        self.url_recomendador = 'https://usje2dwpo3.execute-api.us-west-2.amazonaws.com/dev/datos_recomendador_perfil'

    def enviar_request(self,url,datos, method = 'GET'):
        datos_codificados = uparse.urlencode(datos)
        url = f"{url}?{datos_codificados}"
        result_request = urequest.Request(url , method=method)
        response = urequest.urlopen(result_request)
        decode_response = response.read().decode('utf-8')
        if decode_response == '':
            decode_response = '{}'
        return json.loads(decode_response)
    
    def obtener_productos_recomendados(self,dict_params):
        datos = {
            'cod_persona':dict_params.get('id_cliente_bonus')
        }
        try:
            result_request = self.enviar_request(self.url_recomendador,datos)
            if result_request.get('status'):
                result = result_request.get('data')
                result.update({'estado':True, 'mensaje':'ok'})
            else:
                result = {'estado':False,'mensaje':result_request.get('message')}
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result