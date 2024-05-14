import pg8000
import os
import boto3
import json, urllib.request as urequest
from base64 import b64decode
from decimal import Decimal
from datetime import date

class general:
    def __init__(self,**kwargs):
        #declaración de variables para general
        self.params = {clave:valor for clave,valor in kwargs.items()}

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

    def obtener_datos_secret_manager(self,secret_name,region_name):
        service_name = 'secretsmanager'
        secrets_client = boto3.client(service_name=service_name,region_name=region_name)
        secret_value = secrets_client.get_secret_value(SecretId=secret_name)
        return secret_value

    def get_decrypted_variable(self,encrypted_var):
        """Descifra una variable cifrada usando AWS KMS."""
        kms = boto3.client('kms')
        return kms.decrypt(
            CiphertextBlob=b64decode(encrypted_var),
            EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
        )['Plaintext'].decode('utf-8')
    
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
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                'body': json.dumps(response_data, default=self.homologar_datos)
            }
            
    def estructurar_json_error(self,status_code,message = ''):
        return  {"status": "error",
                 'headers': {
                            'Access-Control-Allow-Origin': '*', 
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
                            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                        'body': json.dumps({
                                                'status': 'success',
                                                'message': mensaje,
                                                'data': datos
                                            }, default=self.homologar_datos)
                    }
        if codigo in [400,500]:
            salida = {
                        "statusCode": codigo,
                        'headers': {
                                    'Access-Control-Allow-Origin': '*', 
                                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                                },
                        'body': json.dumps({
                                                'status': 'error',
                                                'message': mensaje,
                                                'data': ""
                                            })
                    }
        return salida


class bdatos:
    def __init__(self,**kwargs):
        g = general()
        self.secret_name = "SecretBonus1"
        self.region_name = "us-east-2"
        datos_secret_manaer = g.obtener_datos_secret_manager(self.secret_name,self.region_name)
        datos_db = json.loads(datos_secret_manaer['SecretString'])
        self.bdname = datos_db['DBName']
        self.dbhost = datos_db['DBHost']
        self.dbpass = datos_db['DBPass']
        self.dbport = 5432
        self.dbuser = datos_db['DBUser']
        self.dbschem = datos_db['DBSchm']
    
    def obtener_esquema(self):
        return self.dbschem
    
    def connect_to_postgresql(self):
        """Obtiene y retorna una conexión a la base de datos."""
        # Descifra las variables de entorno
        g = general()
        vhost = self.dbhost
        vuser = self.dbuser#g.get_decrypted_variable(os.environ['DB_USER'])
        vpasswd = self.dbpass#g.get_decrypted_variable(os.environ['DB_PASS'])
        vdb = self.bdname#g.get_decrypted_variable(os.environ['DB_NAME'])
        vport = self.dbport
        db_params = {
            'database': vdb,
            'user': vuser,
            'password': vpasswd,
            'host': vhost,
            'port': vport  
        }
        return pg8000.connect(**db_params)
    
    def insert_from_select(self, tabla: str,str_select, str_columns = None, str_return = None):
        return_stmt = ''
        columns_stmt = ''
        if str_return:
            return_stmt = f'RETURNING {str_return}'
        if str_columns:
            columns_stmt = f'({str_columns})'
        sql_insert_query = f"INSERT INTO {tabla} {columns_stmt} {str_select} {return_stmt}"
        conn = self.connect_to_postgresql()
        cur = conn.cursor()
        result = cur.execute(sql_insert_query)
        rows = [{'estado':True}]
        if str_return:
            result = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            rows = [dict(zip(columns, row)) for row in result]
        conn.commit()
        cur.close()
        conn.close()
        return rows

    def insert(self, tabla: str, datos, str_return = None):
        return_stmt = ''
        if str_return:
            return_stmt = f'RETURNING {str_return}'
        conn = self.connect_to_postgresql()
        cur = conn.cursor()
        columnas = ', '.join(datos[0].keys())
        valores = ', '.join(['%s'] * len(datos[0]))
        sql_insert_query = f"INSERT INTO {tabla} ({columnas}) VALUES ({valores}) {return_stmt}"
        t_valores = [tuple(d.values()) for d in datos]
        result = cur.executemany(sql_insert_query, t_valores)
        rows = [{'estado':True}]
        if str_return:
            result = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            rows = [dict(zip(columns, row)) for row in result]
        conn.commit()
        cur.close()
        conn.close()
        return rows
    
    def delete(self,tabla, str_where, str_return = None):
        return_stmt = ''
        if str_return:
            return_stmt = f'RETURNING {str_return}'
        sql_delete_query = f'DELETE FROM {tabla} where {str_where} {return_stmt}'
        conn = self.connect_to_postgresql()
        cur = conn.cursor()
        result = cur.execute(sql_delete_query)
        rows = [{'estado':True}]
        if str_return:
            result = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            rows = [dict(zip(columns, row)) for row in result]
        conn.commit()
        cur.close()
        conn.close()
        return rows
    
    def update(self, tabla, dict_set,str_where, str_return = None):
        return_stmt = ''
        if str_return:
            return_stmt = f'RETURNING {str_return}'
        conn = self.connect_to_postgresql()
        cur = conn.cursor()
        str_set = '"'+'"=%s, "'.join(dict_set[0].keys())+'"=%s'
        sql_update_query = f'UPDATE {tabla} set {str_set} where {str_where} {return_stmt}'
        t_valores = [tuple(d.values()) for d in dict_set]
        result = cur.executemany(sql_update_query, t_valores)
        rows = [{'estado':True}]
        if str_return:
            result = cur.fetchall()
            columns = [desc[0] for desc in cur.description]
            rows = [dict(zip(columns, row)) for row in result]
        conn.commit()
        cur.close()
        conn.close()
        return rows
    
    def select(self,tabla, condicion = None, cols = None, str_with = None, str_order = None, limit = 0, offset = 0):
        columns_stmt = '*'
        where_stmt = ''
        with_stmt = ''
        limit_stmt = ''
        order_stmt = ''
        if cols:
            columns_stmt = cols
        if condicion:
            where_stmt = 'where ' + condicion
        if str_order:
            order_stmt = 'order by ' + str_order
        if str_with:
            with_stmt = 'with ' + str_with
        if limit > 0:
            limit_stmt = f'limit {limit}'
        offset_stmt =  f'offset {offset}'
        query_stmt = f'{with_stmt}select {columns_stmt} from {tabla} {where_stmt} {order_stmt} {limit_stmt} {offset_stmt}'
        con = self.connect_to_postgresql()
        cursor = con.cursor()
        cursor.execute(query_stmt)
        columns = [desc[0] for desc in cursor.description]
        result = cursor.fetchall()
        rows = [dict(zip(columns, row)) for row in result]
        cursor.close()
        con.close()
        return rows
