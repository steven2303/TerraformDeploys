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
    pgm = log_path
    trama = {'function_name': function_name}
    trama.update(query_params)

    try:
        # Validación de parámetros requeridos para el pago
        company_code = query_params.get('company_code')
        product_id = query_params.get('product_id')
        amount = query_params.get('amount')
        identifier_name = query_params.get('identifier_name')
        identifier_value = query_params.get('identifier_value')
        payment_method = query_params.get('payment_method')

        if not all([company_code, product_id, amount, identifier_name, identifier_value, payment_method]):
            raise ValueError("Todos los parámetros requeridos deben ser proporcionados")

        # Lógica para procesar el pago
        payment_result = tapi_instance.process_payment(
            company_code=company_code,
            product_id=product_id,
            amount=amount,
            identifier_name=identifier_name,
            identifier_value=identifier_value,
            payment_method=payment_method
        )

        message = g.message_200[44]  # Mensaje de éxito
        log_message = f'exitoso : {message}'
        codigo_salida = 200
        data = payment_result
    except Exception as e:
        data = ''
        log_message = f'error : {e}'
        log_path = 'LAMBDA_ERROR'
        message = g.message_500 if codigo_salida == 500 else log_message

    trama.update({'message': log_message})
    # l.guardar_registro_en_s3(log_path, log_filename, l.generar_formato_log(tipo=tipo, usuario=usuario, pgm=pgm, trama=trama))
    return g.estructurar_salida_json(codigo_salida, message, data)