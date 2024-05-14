import boto3
import datetime
from aplicacion_general import credenciales

class logs:
    def __init__(self,**kwargs):
        c = credenciales()
        dict_secret_manager = c.obtener_datos_secret_manager()
        self.bucket_name = dict_secret_manager.get('bucket_name')
        pass
    def generar_formato_log(self,**kwargs):
        try:
            adicional = []
            str_adicional = ''
            tipo=''
            fecha=''
            hora=''
            usuario=''
            pgm=''
            trama=''
            for nombre,valor in kwargs.items():
                if not valor:
                    continue
                if nombre.lower() == 'tipo':
                    tipo = valor.ljust(1,' ')
                    continue
                if nombre.lower() == 'usuario':
                    usuario = valor.ljust(10,' ')
                    continue
                if nombre.lower() == 'pgm':
                    pgm = valor.ljust(10,' ')
                    continue
                if nombre.lower() == 'trama':
                    trama = '|'.join(str(subvalor) for subvalor in valor.values()).ljust(1500,' ')
                    continue
                adicional.append(valor.ljust(10,' '))
            fecha = datetime.datetime.now().strftime('%Y%m%d')
            hora = datetime.datetime.now().strftime('%H:%M:%S')
            if not adicional:
                str_adicional = ''.join(adicional)
            str_formato = f'{tipo}{fecha}{hora}{usuario}{pgm}{trama}{str_adicional}'
        except Exception as e:
            str_formato = str(e)
        return str_formato
            
    def guardar_registro_en_s3(self, s3_path, custom_filename, contenido = ''):
        s3_client = boto3.client('s3')
        if s3_path[:-1] != '/':
            s3_path+='/'
        dir_log = s3_path + datetime.datetime.now().strftime('%Y-%m-%d')+'/'
        file_name = f"{dir_log}{datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S_%f')}_{custom_filename}.log"
        s3_client.put_object(Bucket=self.bucket_name, Key=file_name, Body=contenido)
