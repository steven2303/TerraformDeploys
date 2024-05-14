from aplicacion_general import credenciales
import pg8000
class bdatos:
    def __init__(self,**kwargs):
        c = credenciales()
        datos_db = c.obtener_datos_secret_manager()
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
        vhost = self.dbhost
        vuser = self.dbuser
        vpasswd = self.dbpass
        vdb = self.bdname
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
    
    def select(self,tabla, condicion = None, cols = None, str_with = None, str_order = None, limit = 0, offset = 0, pivot = False,column_pivot = 'value_pivot', num_pivot = 0):
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
        if pivot:
            str_array = [str(i) for i in range(1,int(num_pivot)+1)]
            str_column = column_pivot + f",{column_pivot}".join(str_array)
            columns_stmt += f',unnest(array[{str_array}]) as pivot'
            columns_stmt += f',unnest(array[{str_column}]) as {column_pivot}'
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