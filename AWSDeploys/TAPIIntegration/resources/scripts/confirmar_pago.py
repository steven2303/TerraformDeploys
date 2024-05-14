from aplicacion_bdatos import bdatos
from integracion_tapi import tapi 
from aplicacion_general import general
from s3_logging import logs
import json
from urllib.parse import parse_qs

bd = bdatos()
g = general()
l = logs()
tapi_instance = tapi()

def lambda_handler(event, context):
    form_data = parse_qs(event['body'])
    query_params = {key: value[0] for key, value in form_data.items()}
    function_name = context.function_name
    log_filename = f'{function_name}_{context.aws_request_id}'
    log_path = 'LAMBDA'
    codigo_salida = 500
    tipo = '1'
    usuario = query_params.get('au_tipo_dispositivo')
    operation_id = query_params.get('operation_id')
    pgm = log_path
    trama = {'function_name': function_name}
    trama.update(query_params)

    try:
        payment_status = tapi_instance.get_payment_status(operation_id=operation_id)
        if 'error' in payment_status or 'Error' in payment_status:
            message = payment_status['error']['message']
            log_message = message
            data = ''
            codigo_salida = 500
        else:
            message = g.message_200[44]
            log_message = f'exitoso : {message}'
            codigo_salida = 200
            data = payment_status
    except Exception as e:
        data = ''
        log_message = f'error : {e}'
        log_path = 'LAMBDA_ERROR'
        if codigo_salida == 500:
            message = g.message_500
        else:
            message = log_message

    trama.update({'message': log_message})
    # l.guardar_registro_en_s3(log_path, log_filename, l.generar_formato_log(tipo=tipo, usuario=usuario, pgm=pgm, trama=trama))
    return g.estructurar_salida_json(codigo_salida, message, data)