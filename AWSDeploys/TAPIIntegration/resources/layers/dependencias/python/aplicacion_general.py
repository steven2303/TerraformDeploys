import json, urllib.request as urequest
import boto3,random,hashlib,hmac
import re
from datetime import datetime, timedelta
from base64 import b64decode,b64encode
from decimal import Decimal
from datetime import date,datetime
from botocore.exceptions import ClientError
class general:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        self.service_name = 'secretsmanager'
        self.secret_name = "SecretBonus1"
        self.region_name = "us-east-2"
        self.region_sms = 'us-east-1'
        self.message_200 = {
            0: 'Nombres de productos obtenidos exitosamente.',
            1: 'Datos cargados exitosamente.',
            2: 'Cantidad de producto en el carrito actualizada exitosamente.',
            3: 'Producto agregado al carrito exitosamente.',
            4: 'Producto eliminado exitosamente.',
            5: 'Los productos se han limpiado del carrito.',
            6: 'Orden generada exitosamente',
            7: 'Transacción generada exitosamente',
            8: 'Consulta realizada exitosamente.',
            9: 'Productos favoritos obtenidos exitosamente.',
            10: 'Se guardó la configuración de las notificaciones exitosamente.',
            11: 'Correo actualizado exitosamente.',
            12: 'Datos personales actualizados exitosamente.',
            13: 'Se actualizó la dirección exitosamente.',
            14: 'Foto actualizado exitosamente.',
            15: 'Se actualizó los puntos exitosamente.',
            16: 'Telefono actualizado exitosamente.',
            17: 'Se actualizaron los terminos y condiciones exitosamente.',
            18: 'Puntos obtenidos exitosamente.',
            19: 'exitosamente.',
            20: 'Se eliminó la dirección exitosamente.',
            21: 'Cantidad de carrito recuperado exitosamente',
            22: 'Código de referido recuperado exitosamente.',
            23: 'Direcciones recuperadas exitosamente.',
            24: 'Movimiento de puntos obtenidos exitosamente.',
            25: 'Número celular y Email se obtuvieron de forma exitosa.',
            26: 'Se eliminó la tarjeta exitosamente.',
            27: 'Datos de tarjeta obtenidos exitosamente.',
            28: 'Se obtuvo el Número de celular exitoso.',
            29: 'Tipos de documentos recuperadas exitosamente.',
            30: 'Estado de favorito actualizado exitosamente.',
            31: 'Comprobante de compras registrado exitosamente.',
            32: 'Dirección registrada exitosamente.',
            33: 'Se registró el producto visto exitosamente.',
            34: 'Respuestas del quiz de preferencias registradas exitosamente.',
            37: 'Reclamo agregado exitosamente.',
            38: 'Sugerencia registrada exitosamente.',
            39: 'Se actualizó el alias de la tarjeta exitosamente.',
            40: 'Código generado con éxito.',
            41: "El documento no existe en el sistema y es válido.",
            42: "El documento no es válido.",
            43: "El documento ya existe en el sistema.",
            44: 'obtenidos exitosamente.',
            45: 'Solicitud registrada exitosamente.',
            46: 'Se realizó la consulta correctamente.',
            47: 'Se registró correctamente',
            48: 'Recarga en espera de confirmación'
        }
        self.message_500 = "Ha ocurrido un error en el servidor. Intente más tarde."
        self.message_400 = {
            0: 'La clave de 6 dígitos no está permitida. Por favor, introduce una clave válida.', 
            1: 'El producto no se agregó al carrito.', 
            2: 'El producto que intenta agregar ya existe en su carrito.', 
            3: 'El registro no existe.',
            4: 'No hay productos en el carrito.',
            6: 'Puntos insuficientes',
            7: 'Hay productos sin stock',
            8: 'No se logró generar la orden.',
            9: 'No existe el usuario.',
            10: 'No se logró generar la transacción.',
            11: 'No existe una orden activa.',
            12: 'El producto es incorrecto.',
            13: 'No existen productos',
            14: "Transaccion ya procesada",
            15: "Orden inactiva",
            16: "Cliente no existente",
            17: "Productos no existente",
            18: 'Dirección no existe.',
            19: 'No se pudo actualizar los puntos',
            20: 'No hay datos por actualizar.',
            21: 'usuario registrado',
            22: 'No se logró registrar el comprobante',
            23: 'No se logró registrar la dirección.',
            24: 'No se logró registrar el producto visto.',
            25: 'Categorias no existen',
            26: 'Preguntas no existen',
            27: 'No se logró agregar el reclamo.',
            28: 'No se logró registrar la sugerencia.',
            29: 'No se pudo actualizar el alias',
            30: "No se encontro el usuario",
            31: 'No se logró registrar.',
            32: 'datos inválidos',
            33: 'El parámetro no tiene un formato válido.',
            34: 'El parámetro no tiene un formato válido. Debe contener solo números y al menos 9 dígitos.',
            35: 'No se logró registrar la solicitud.',
            36: 'No se logró generar el código',
            37: 'No se logró registrar el cliente',
            38: 'Campo en blanco',
            39: 'No hay movimientos',
            40: 'La recarga no pudo ser procesada'
            }
        self.message_403 = 'No autorizado'
        self.message_404 = 'No existe el numero de orden'
        self.message_422 = "Montos no coincidentes"

    def obtener_fecha(self, format = '%d/%m/%Y'):
        str_fecha = datetime.now().strftime(format)
        return str_fecha    

    def json_string_to_obj(self,str_json):
        return json.loads(str_json)
    
    def generar_codigo_referencia(self):
        numero = int(random.random()*100000000000)
        llave = str(numero).rjust(11,'0')
        fecha = datetime.now()
        milisegundos = fecha.microsecond//1000
        llave+=str(milisegundos)[:3]
        llave+=fecha.strftime('%S')
        llave+=fecha.strftime('%M')
        llave+=fecha.strftime('%H')
        cadena = ''
        str_result = ''
        for i in list(range(1,20,2)):
            cadena=str(llave)[i:i+2]
            num = int(cadena) if cadena else 0
            if (num>47 and num <58) or (num>64 and num < 91):
                str_result+= chr(num)
            else:
                str_result+= str(llave)[i:i+1]
        return str_result

    def generar_authorization_izipay(self,transactionid,dict_data):
        endpoint = 'https://sandbox-api-pw.izipay.pe/security/v1/Token/Generate'
        headers = {
            'Content-Type': 'application/json',
            'transactionId': transactionid
        }
        data = json.dumps(dict_data).encode('utf-8')
        result_request = urequest.Request(endpoint,data=data, headers=headers,method='POST')
        response = urequest.urlopen(result_request)
        response_data = response.read().decode('utf-8')
        authorization = json.loads(response_data)['response']['token']
        return authorization
    
    def homologar_datos(self,obj):
        if isinstance(obj, Decimal):
            return float(obj)
        elif isinstance(obj, date):
            return obj.isoformat()
        raise TypeError

    """def obtener_datos_secret_manager(self,secret_name,region_name):
        #secrets_client = boto3.client(service_name=self.service_name,region_name=region_name)
        #secret_value = secrets_client.get_secret_value(SecretId=secret_name)
        #result = {
        #    'SecretString':json.loads(secret_value['SecretString'])
        #}
        #return result"""
    def calculate_secret_hash(self,client_id, client_secret, username):
        message = bytes(username + client_id, 'utf-8')
        key = bytes(client_secret, 'utf-8')
        digest = hmac.new(key, message, digestmod=hashlib.sha256).digest()
        return b64encode(digest).decode()
    
    def validar_cognito(self,dict_params):
        client = boto3.client('cognito-idp')
        c = credenciales()
        dict_secret_manager = c.obtener_datos_secret_manager()
        user_pool_id = dict_secret_manager.get('user_pool_id')
        username = f"{dict_params.get('custom:id_tipo_documento')}-{dict_params.get('custom:nro_documento')}"
        try:
            response = client.admin_get_user(
                UserPoolId=user_pool_id,
                Username=username
            )
            result = {'estado':True}
        except ClientError as e:
            result = {'estado':False}
            if e.response['Error']['Code'] == 'UserNotFoundException':
                mensaje = 'Usuario no encontrado'
            else:
                mensaje = str(e)
            result.update({'mensaje':mensaje})
        return result
    
    def enviar_sms(self,dict_params):
        client = boto3.client("sns",region_name=dict_params.get('region'))
        try:
            response = client.publish(
                PhoneNumber=dict_params.get('numero'),
                Message=dict_params.get('mensaje'),
                MessageAttributes={
                    'AWS.SNS.SMS.SenderID': {
                        'DataType': 'String',
                        'StringValue': dict_params.get('emisor')
                    },
                    'AWS.SNS.SMS.SMSType': {
                        'DataType': 'String',
                        'StringValue': 'Transactional'
                    }
                }
            )
            result = {'estado':True, 'mensaje':''}
        except Exception as e:
            result = {'estado':False , 'mensaje':str(e)}
        return result
    
    def registrar_cognito(self,dict_params):
        client = boto3.client('cognito-idp')
        c = credenciales()
        dict_secret_manager = c.obtener_datos_secret_manager()
        client_id = dict_secret_manager.get('client_id')
        client_secret = dict_secret_manager.get('client_secret')
        #user_pool_id = dict_secret_manager.get('user_pool_id')
        username = f"{dict_params.get('custom:id_tipo_documento')}-{dict_params.get('custom:nro_documento')}"
        password = dict_params.get('clave')
        secret_hash = self.calculate_secret_hash(client_id, client_secret, username)
        try:
            response = client.sign_up(
                ClientId=client_id,
                SecretHash=secret_hash,
                Username=username,
                Password=password,
                UserAttributes=[{"Name": key, "Value": value} for key,value in dict_params.items() if value and key!='clave']
                #SuppressSignUpConfirmation=True
            )
            #client.admin_confirm_sign_up(
            #    UserPoolId=user_pool_id,
            #    Username=username
            #)
            result = {'estado':True}
        except client.exceptions.UsernameExistsException:
            result = {'estado':False,'mensaje':'El usuario ya existe.'}
            #raise ValueError('El usuario ya existe.')
        except Exception as e:
            result = {'estado':False,'mensaje':str(e)}
            #raise ValueError(str(e))
        return result
    
    def get_decrypted_variable(self,encrypted_var):
        """Descifra una variable cifrada usando AWS KMS."""
        kms = boto3.client('kms')
        return kms.decrypt(
            CiphertextBlob=b64decode(encrypted_var),
            EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
        )['Plaintext'].decode('utf-8')
    
    def estructurar_diccionario_ordenado(self,data_inicial,data,list_comparar,list_grupo,list_nombre_grupo):
        if len(data) == 0:
            nuevo_valor = [{clave:valor for clave,valor in dict_valor.items() if clave in list_grupo[0]} for dict_valor in data_inicial]
            #valor_tuplas = {tuple(d.items()) for d in nuevo_valor}
            vistos = set()
            valor_tuplas = []
            for d in nuevo_valor:
                tupla = tuple(d.items())
                if tupla not in vistos:
                    valor_tuplas.append(tupla)
                    vistos.add(tupla)
            nuevo_valor = [dict(t) for t in valor_tuplas]
            data = nuevo_valor
            if len(list_grupo)==1:
                return data
            else:
                list_grupo = list_grupo[1:]
        list_grupo_tmp = [] + list_grupo
        list_comparar_tmp = [] + list_comparar
        for i,dic in enumerate(data):
            nuevo_valor = [{clave:valor for clave,valor in dict_valor.items() if clave in list_grupo_tmp[0]} for dict_valor in data_inicial if dict_valor[list_comparar_tmp[0]]==dic[list_comparar_tmp[0]]]
            if len(list_grupo_tmp)!=1:
                #valor_tuplas = {tuple(d.items()) for d in nuevo_valor}
                vistos = set()
                valor_tuplas = []
                for d in nuevo_valor:
                    tupla = tuple(d.items())
                    if tupla not in vistos:
                        valor_tuplas.append(tupla)
                        vistos.add(tupla)
                nuevo_valor = [dict(t) for t in valor_tuplas]
                self.estructurar_diccionario_ordenado(data_inicial,nuevo_valor,list_comparar_tmp[1:],list_grupo_tmp[1:],list_nombre_grupo[1:])
            data[i].update({list_nombre_grupo[0]:nuevo_valor})
        return data
    
    def estructurar_diccionario(self,data_inicial,data,list_comparar,list_grupo,list_nombre_grupo):
        if len(data) == 0:
            nuevo_valor = [{clave:valor for clave,valor in dict_valor.items() if clave in list_grupo[0]} for dict_valor in data_inicial]
            valor_tuplas = {tuple(d.items()) for d in nuevo_valor}
            nuevo_valor = [dict(t) for t in valor_tuplas]
            data = nuevo_valor
            if len(list_grupo)==1:
                return data
            else:
                list_grupo = list_grupo[1:]
        list_grupo_tmp = [] + list_grupo
        list_comparar_tmp = [] + list_comparar
        for i,dic in enumerate(data):
            nuevo_valor = [{clave:valor for clave,valor in dict_valor.items() if clave in list_grupo_tmp[0]} for dict_valor in data_inicial if dict_valor[list_comparar_tmp[0]]==dic[list_comparar_tmp[0]]]
            if len(list_grupo_tmp)!=1:
                valor_tuplas = {tuple(d.items()) for d in nuevo_valor}
                nuevo_valor = [dict(t) for t in valor_tuplas]
                self.estructurar_diccionario(data_inicial,nuevo_valor,list_comparar_tmp[1:],list_grupo_tmp[1:],list_nombre_grupo[1:])
            data[i].update({list_nombre_grupo[0]:nuevo_valor})
        return data
    
    def estructurar_json_success(self,data,status_code,message = ''):
        response_data = {
                'status': 'success',
                'message': message,
                'data': data
            }
        return {
                'statusCode': status_code,
                'headers': {
                            'Access-Control-Allow-Origin': '*',
                            "Access-Control-Allow-Credentials": 'true', 
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                'body': json.dumps(response_data, default=self.homologar_datos)
            }
            
    def estructurar_json_error(self,status_code,message = ''):
        return  {"status": "error",
                 'headers': {
                            'Access-Control-Allow-Origin': '*', 
                            "Access-Control-Allow-Credentials": 'true', 
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                "statusCode": status_code,
                "message": message,
                "data": ""}
    
    def estructurar_salida_json(self,codigo, mensaje = '', datos = ''):
        if codigo in [200]:
            salida = {
                        'statusCode': codigo,
                        'headers': {
                            'Access-Control-Allow-Origin': '*', 
                            'Access-Control-Allow-Credentials': 'true', 
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                        'body': json.dumps({
                                                'status': 'success',
                                                'message': mensaje,
                                                'data': datos
                                            }, default=self.homologar_datos)
                    }                                        
        if codigo >=400 and codigo <= 600:
            salida = {
                        "statusCode": codigo,
                        'headers': {
                                    'Access-Control-Allow-Origin': '*', 
                                    'Access-Control-Allow-Credentials': 'true', 
                                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                        'body': json.dumps({
                                                'status': 'error',
                                                'message': mensaje,
                                                'data': datos
                                            })
                    }
        return salida
    
    def generar_codigo_numerico(self, cantidad: int):
        multiplicador = 10**cantidad
        numero = int(random.random()*multiplicador)
        llave = str(numero).rjust(cantidad,'0')
        return llave
    
    def generar_sql_pivot(self,num_pivot,column_pivot):
        columns_stmt = ''
        str_array = [str(i) for i in range(1,int(num_pivot)+1)]
        str_column = column_pivot + f",{column_pivot}".join(str_array)
        columns_stmt += f',unnest(array[{str_array}]) as pivot'
        columns_stmt += f',unnest(array[{str_column}]) as {column_pivot}'
        return columns_stmt
    
class credenciales:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        self.service_name = 'secretsmanager'
        self.secret_name = "SecretBonus1"
        self.region_name = "us-east-2"

    def obtener_datos_secret_manager(self,secret_name = None,region_name = None):
        if not secret_name:
            secret_name = self.secret_name
        if not region_name:
            region_name = self.region_name
        secrets_client = boto3.client(service_name=self.service_name,region_name=region_name)
        secret_value = secrets_client.get_secret_value(SecretId=secret_name)
        return json.loads(secret_value['SecretString'])
    
class validador:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        self.service_name = 'secretsmanager'
        self.secret_name = "SecretBonus1"
        self.region_name = "us-east-2"

    def validar_en_blanco(self, valor, mensaje_error):
        if valor is None or valor.strip() == '':
            return {'valido': False, 'mensaje': mensaje_error}
        else:
            return {'valido': True, 'mensaje': ''}
    
    def validar_email(self, email):
        if email is None:
            return False
        re_email = re.compile(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$')
        return re_email.match(email) is not None

    
    def validar_telefono_peruano(self, telefono):
        if telefono is None:
            return False
        re_telefono = re.compile(r'^9\d{8}$')
        return re_telefono.match(telefono) is not None
    
    def validar_fecha(self, fecha):
        if not fecha:  
            print("La fecha no puede estar vacía")
            return False
        
        if not re.match(r'^\d{2}/\d{2}/\d{4}$', fecha):
            print("El formato de la fecha no es válido")
            return False

        partes_fecha = fecha.split('/')
        dia, mes, ano = int(partes_fecha[0]), int(partes_fecha[1]), int(partes_fecha[2])

        try:
            fecha_nacimiento = datetime(ano, mes, dia)
        except ValueError:
            print("La fecha es inválida")
            return False

        fecha_actual = datetime.now()

        edad = fecha_actual.year - fecha_nacimiento.year
        if (mes > fecha_actual.month) or (mes == fecha_actual.month and dia > fecha_actual.day):
            edad -= 1

        print(edad)
        if 18 <= edad <= 90:
            return True
        else:
            print("La fecha no cumple con la edad requerida")
            return False

        
    def validar_documento(self,tipo_doc, valor):
        if tipo_doc == 1:
            return self.validar_dni(valor)
        elif tipo_doc == 2:
            return self.validar_ci(valor)
        elif tipo_doc == 3:
            return self.validar_ce(valor)
        elif tipo_doc == 4:
            return self.validar_pasaporte(valor)
        elif tipo_doc == 5:
            return self.validar_ruc(valor)
        elif tipo_doc == 6:
            return self.validar_ptp(valor)
        return True

    def validar_dni(self,valor):
        return bool(re.match(r'^\d{8}$', valor))

    def validar_ce(self,valor):
        return bool(re.match(r'^[A-Za-z0-9]{9}$', valor))

    def validar_pasaporte(self,valor):
        return bool(re.match(r'^[A-Z0-9]{5,12}$', valor))

    def validar_ptp(self,valor):
        return bool(re.match(r'^\d{9}$', valor))
        
    def tiene_digitos_iguales(self,clave):
        return bool(re.search(r'(\d).*\1', clave))

    def generar_formatos_fecha(self,fecha_nacimiento):
        dia, mes, ano = map(int, fecha_nacimiento.split('/'))

        dia_str = str(dia).zfill(2)
        mes_str = str(mes).zfill(2)
        ano_str = str(ano)
        ano_inicio = ano_str[:2] 
        ano_fin = ano_str[2:]    

        return [
            dia_str + mes_str + ano_fin,    
            mes_str + dia_str + ano_fin,   
            ano_fin + mes_str + dia_str,    
            ano_fin + dia_str + mes_str,    
            mes_str + ano_fin + dia_str,    
            dia_str + ano_fin + mes_str,    
            dia_str + mes_str + ano_inicio, 
            mes_str + dia_str + ano_inicio, 
            ano_inicio + mes_str + dia_str, 
            ano_inicio + dia_str + mes_str, 
            mes_str + ano_inicio + dia_str, 
            dia_str + ano_inicio + mes_str, 
        ]

    def es_fecha_o_anio_nacimiento(self,clave, fecha_nacimiento):
        formatos_fecha = self.generar_formatos_fecha(fecha_nacimiento)
        print("esFechaOAnioNacimiento ", clave, fecha_nacimiento, formatos_fecha)
        return clave in formatos_fecha
    
    def es_capicua(self,clave):
        return clave == clave[::-1]

    def es_consecutivo(self,clave):
        ascendente = '01234567890'
        descendente = '09876543210'
        return clave in ascendente or clave in descendente

    def validar_clave_dni(self,clave, dni):
        dni_str = dni

        dni_descendente = dni_str[::-1]

        if clave in dni_str or clave in dni_descendente:
            return False
        return True

    def validar_clave_telefono(self,clave, telefono):
        telefono_str = telefono

        telefono_descendente = telefono_str[::-1]

        if clave in telefono_str or clave in telefono_descendente:
            return False
        return True
    
    def validar_clave(self,clave, datos_usuario, mensajes_validacion):
        if datos_usuario and 'fechaNacimiento' in datos_usuario:
            if self.es_fecha_o_anio_nacimiento(clave, datos_usuario['fechaNacimiento']):
                return {'estado': False, 'mensaje': mensajes_validacion['fechaNacimiento']}
        
        if self.es_capicua(clave):
            return {'estado': False, 'mensaje': mensajes_validacion['capicua']}
        
        print("datos_usuario", datos_usuario)
        
        if datos_usuario and 'dni' in datos_usuario:
            if not self.validar_clave_dni(clave, datos_usuario['dni']):
                return {'estado': False, 'mensaje': mensajes_validacion['dniInvalido']}
        
        if datos_usuario and 'numeroCelular' in datos_usuario:
            if not self.validar_clave_telefono(clave, datos_usuario['numeroCelular']):
                return {'estado': False, 'mensaje': mensajes_validacion['telefonoInvalido']}
        
        if self.es_consecutivo(clave):
            return {'estado': False, 'mensaje': mensajes_validacion['consecutivo']}
        
        if self.tiene_digitos_iguales(clave):
            return {'estado': False, 'mensaje': mensajes_validacion['digitosIguales']}
        
        return {'estado': True, 'mensaje': "La clave es válida."}
    
    def validar_entrada(texto):
        patrones_peligrosos = [
            {"patron": r"--", "mensaje": "Comentarios de SQL no permitidos"},
            {"patron": r";", "mensaje": "Punto y coma no permitido"},
            {"patron": r"'", "mensaje": "Comillas simples no permitidas"},
            {"patron": r'"', "mensaje": "Comillas dobles no permitidas"},
            {"patron": r"\\", "mensaje": "Caracteres de escape no permitidos"},
            {"patron": r"OR", "mensaje": "Operador lógico OR no permitido"},
            {"patron": r"AND", "mensaje": "Operador lógico AND no permitido"},
            {"patron": r"SELECT", "mensaje": "Instrucción SELECT no permitida"},
            {"patron": r"INSERT", "mensaje": "Instrucción INSERT no permitida"},
            {"patron": r"UPDATE", "mensaje": "Instrucción UPDATE no permitida"},
            {"patron": r"DELETE", "mensaje": "Instrucción DELETE no permitida"},
            {"patron": r"DROP", "mensaje": "Instrucción DROP no permitida"},
            {"patron": r"TRUNCATE", "mensaje": "Instrucción TRUNCATE no permitida"},
        ]

        for patron_peligroso in patrones_peligrosos:
            if re.search(patron_peligroso["patron"], texto, re.IGNORECASE):
                return {"valido": False, "mensaje": patron_peligroso["mensaje"]}
        
        return {"valido": True, "mensaje": ""}  

    def validar_codigo(codigo):
        regex = r'^[0-9A-Z]{10}$'
        return bool(re.match(regex, codigo))
