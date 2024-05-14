from aplicacion_bdatos import bdatos
from integracion_tapi import tapi 
from aplicacion_general import general
from s3_logging import logs
import json
from urllib.parse import parse_qs

# Instancias de las clases
bd = bdatos()
g = general()
l = logs()
tapi_instance = tapi()

def lambda_handler(event, context):
    # Procesa los datos del evento
    form_data = parse_qs(event['body'])
    query_params = {key: value[0] for key, value in form_data.items()}
    function_name = context.function_name
    log_filename = f'{function_name}_{context.aws_request_id}'
    log_path = 'LAMBDA'
    codigo_salida = 500
    tipo = '1'
    usuario = query_params.get('au_tipo_dispositivo')
    external_payment_id = context.aws_request_id #query_params.get('external_payment_id')
    external_client_id = query_params.get('external_client_id')
    product_id = query_params.get('product_id')
    company_code = query_params.get('company_code')
    identifier_name = query_params.get('identifier_name')
    identifier_value = query_params.get('identifier_value')
    amount = float(query_params.get('amount'))
    pgm = log_path
    trama = {'function_name': function_name}
    trama.update(query_params)

    try:
        # Realiza el pago con los parámetros proporcionados
        payment_details = tapi_instance.payment(external_payment_id, external_client_id, product_id,company_code,
                                             identifier_name, identifier_value,amount)
        if 'error' in payment_details:
            message = g.message_400[40]#payment_details['error']#['message']
            log_message = message
            data = payment_details['error']
            codigo_salida = payment_details['status_code'] #500
        else:
            message = g.message_200[44]
            log_message = f'exitoso : {message}'
            codigo_salida = 200
            data = payment_details
            if payment_details['status_code'] == 202:
                codigo_salida = 202
                message = g.message_200[48]
                log_message = f'peding : {message}'
                

    except Exception as e:
        # Manejo de errores
        data = ''
        log_message = f'error : {e}'
        log_path = 'LAMBDA_ERROR'
        if codigo_salida == 500:
            message = g.message_500
        else:
            message = log_message

    # Actualiza la trama del log y guarda el registro
    trama.update({'message': log_message})
    # l.guardar_registro_en_s3(log_path, log_filename, l.generar_formato_log(tipo=tipo, usuario=usuario, pgm=pgm, trama=trama))

    # Devuelve la respuesta estructurada
    return g.estructurar_salida_json(codigo_salida, message, data)