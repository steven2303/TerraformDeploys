import json, urllib.request as urequest
import xml.etree.ElementTree as ET
import datetime
from urllib.error import HTTPError, URLError
from aplicacion_general import credenciales
class billetera:
    def __init__(self,**kwargs):
        c = credenciales()
        dict_credenciales = c.obtener_datos_secret_manager()
        self.params = {clave:valor for clave,valor in kwargs.items()}
        self.vuser = dict_credenciales.get('api_izipay_usuario')
        self.vpass = dict_credenciales.get('api_izipay_password')
        self.url = dict_credenciales.get('api_izipay_url')
        self.url_base_service = dict_credenciales.get('api_izipay_url_service')
        self.iservice_name = 'IService1'
        self.codemisor='941'
        self.codusuario='LY9999'
        self.numterminal='11010101'
        self.fecexp='0'
        self.moneda='604'
        self.reservado='0'
        self.comercio_consulta_saldo = '8106584'
        self.comercio_transferir_soles_salida = '9999999'
        self.comercio_transferir_soles_ingreso = '4019091'
        self.comercio_recarga_soles = '4060192'
    
    def estructurar_soap_xml(self,body,soap_action, format = 'xml'):
        str_soap = f"""
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="{self.url_base_service}">
        <soapenv:Header/>
        <soapenv:Body>
            <tem:{soap_action}>
                <tem:{format}>
                        {body}
                </tem:{format}>
            </tem:{soap_action}>
        </soapenv:Body>
        </soapenv:Envelope>
        """
        return str_soap
    
    def enviar_soap_request(self,url,datos,soap_action, format):
        headers = {
            'Content-Type': 'text/xml; charset=utf-8',
            'SOAPAction':f'{self.url_base_service}{self.iservice_name}/{soap_action}'
        }
        result_request = urequest.Request(url,data = self.estructurar_soap_xml(datos,soap_action, format).encode('utf-8'), headers = headers)
        response = urequest.urlopen(result_request)
        return response.read().decode('utf-8')
    
    def soap_xml_to_dict(self,element):
        if len(element) == 0:
            return element.text
        return {str(child.tag).replace(self.url_base_service,'').replace('{}','').replace('{http://schemas.xmlsoap.org/soap/envelope/}',''): self.soap_xml_to_dict(child) for child in element}
    
    def soap_request_to_dict(self,string_request,soap_action):
        result_soap = string_request.replace('&lt;','<').replace('&gt;&#xD;','>').replace('&gt;','>').replace('&#xD;','').replace('<?xml version="1.0" encoding="UTF-8"?>','')
        raiz = ET.fromstring(result_soap)
        data = self.soap_xml_to_dict(raiz)
        return data['Body'][f'{soap_action}Response'][f'{soap_action}Result']['Envelope']['Body']
    
    def consulta_saldos(self,dict_parametros):
        soap_action = 'Consulta_Saldos'
        fecha = datetime.datetime.now().strftime('%Y%m%d')
        hora = datetime.datetime.now().strftime('%H%M%S')
        datos = f"""
        <![CDATA[
        <{soap_action}>
            <CodEmisor>{self.codemisor}</CodEmisor>
            <CodUsuario>{self.codusuario}</CodUsuario>
            <NumTerminal>{self.numterminal}</NumTerminal>
            <NumReferencia>{dict_parametros.get('numreferencia')}</NumReferencia>
            <NumTarjetaMonedero>{dict_parametros.get('numtarjetamonedero')}</NumTarjetaMonedero>
            <FechaExpiracion>{self.fecexp}</FechaExpiracion>
            <Comercio>{self.comercio_consulta_saldo}</Comercio>
            <Moneda>{self.moneda}</Moneda>
            <FechaTxnTerminal>{fecha}</FechaTxnTerminal>
            <HoraTxnTerminal>{hora}</HoraTxnTerminal>
            <WSUsuario>{self.vuser}</WSUsuario>
            <WSClave>{self.vpass}</WSClave>
            <Reservado>{self.reservado}</Reservado>
        </{soap_action}>
        ]]>
        """
        try:
            result = self.enviar_soap_request(self.url,datos,soap_action,format = 'XML')
            data = self.soap_request_to_dict(result,soap_action)
            if data[soap_action]['CodRespuesta']!='0000':
                raise ValueError(data[soap_action]['DescRespuesta'])
            return data[soap_action]
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            raise ValueError(f"Error HTTP: {e.code} - {e.reason} : {cuerpo_error}")
        except URLError as e:
            cuerpo_error = e.read().decode()
            raise ValueError(f"Error de URL: {e.reason} : {cuerpo_error}")
        
    def consulta_movimientos(self,dict_parametros):
        soap_action = 'Consulta_Movimientos'
        fecha = datetime.datetime.now().strftime('%Y%m%d')
        hora = datetime.datetime.now().strftime('%H%M%S')
        datos = f"""
        <![CDATA[
        <{soap_action}>
            <CodEmisor>{self.codemisor}</CodEmisor>
            <CodUsuario>{self.codusuario}</CodUsuario>
            <NumTerminal>{self.numterminal}</NumTerminal>
            <NumReferencia>{dict_parametros.get('numreferencia')}</NumReferencia>
            <NumTarjetaMonedero>{dict_parametros.get('numtarjetamonedero')}</NumTarjetaMonedero>
            <FechaExpiracion>{self.fecexp}</FechaExpiracion>
            <Comercio>{self.comercio_consulta_saldo}</Comercio>
            <Moneda>{self.moneda}</Moneda>
            <FechaTxnTerminal>{fecha}</FechaTxnTerminal>
            <HoraTxnTerminal>{hora}</HoraTxnTerminal>
            <WSUsuario>{self.vuser}</WSUsuario>
            <WSClave>{self.vpass}</WSClave>
            <Reservado>{self.reservado}</Reservado>
        </{soap_action}>
        ]]>
        """
        try:
            result = self.enviar_soap_request(self.url,datos,soap_action,format = 'xml')
            data = self.soap_request_to_dict(result,soap_action)
            if data[soap_action]['CodRespuesta']!='0000':
                raise ValueError(data[soap_action]['DescRespuesta'])
            movimientos = []
            for i in range(1,int(data[soap_action]['MoviUltMovimientos'])+1):
                dict_movimiento = {
                    f'MovFechaTxn':data[soap_action][f'Mov{i}FechaTxn'],
                    f'MovDesTxn': data[soap_action][f'Mov{i}DesTxn'], 
                    f'MovMonOriginalTxn': data[soap_action][f'Mov{i}MonOriginalTxn'], 
                    f'MovMontoTxn': data[soap_action][f'Mov{i}MontoTxn'], 
                    f'MovSigMontoTxn': data[soap_action][f'Mov{i}SigMontoTxn'], 
                    f'MovTipoTarjeta': data[soap_action][f'Mov{i}TipoTarjeta'], 
                    f'MovFiller': data[soap_action][f'Mov{i}Filler']
                }
                movimientos.append(dict_movimiento)
            data_result = {
                'IdTransaccion':data[soap_action]['IdTransaccion'],
                'CodAutorizacion':data[soap_action]['CodAutorizacion'],
                'MoviUltMovimientos':data[soap_action]['MoviUltMovimientos'],
                'Movimientos':movimientos
            }
            return data_result
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            raise ValueError(f"Error HTTP: {e.code} - {e.reason} : {cuerpo_error}")
        except URLError as e:
            cuerpo_error = e.read().decode()
            raise ValueError(f"Error de URL: {e.reason} : {cuerpo_error}")
        
    def soles_ingreso(self,dict_parametros):
        soap_action = 'Cash_IN'
        fecha = datetime.datetime.now().strftime('%Y%m%d')
        hora = datetime.datetime.now().strftime('%H%M%S')
        datos = f"""
        <![CDATA[
            <{soap_action}>
            <CodEmisor>{self.codemisor}</CodEmisor>
            <CodUsuario>{self.codusuario}</CodUsuario>
            <NumTerminal>{self.numterminal}</NumTerminal>
            <NumReferencia>{dict_parametros.get('numreferencia')}</NumReferencia>
            <NumTarjetaMonedero>{dict_parametros.get('numtarjetamonedero')}</NumTarjetaMonedero>
            <Importe>{dict_parametros.get('importe')}</Importe>
            <FechaExpiracion>{self.fecexp}</FechaExpiracion>
            <Comercio>{dict_parametros.get('comercio')}</Comercio>
            <Moneda>{self.moneda}</Moneda>
            <FechaTxnTerminal>{fecha}</FechaTxnTerminal>
            <HoraTxnTerminal>{hora}</HoraTxnTerminal>
            <WSUsuario>{self.vuser}</WSUsuario>
            <WSClave>{self.vpass}</WSClave>
            <Reservado>{self.reservado}</Reservado>
        </{soap_action}>]]>
        """
        try:
            result_xml = self.enviar_soap_request(self.url,datos,soap_action,format = 'xml')
            result_dict = self.soap_request_to_dict(result_xml,soap_action)
            result = result_dict[soap_action]
            result.update({'estado':True,'mensaje':result['DescRespuesta']})
            if result['CodRespuesta']!='0000':
                result.update({'estado':False,'mensaje':result['DescRespuesta']})
            return result
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
    
    def soles_salida(self,dict_parametros):
        soap_action = 'Compras'
        fecha = datetime.datetime.now().strftime('%Y%m%d')
        hora = datetime.datetime.now().strftime('%H%M%S')
        datos = f"""
        <![CDATA[
            <{soap_action}>
            <CodEmisor>{self.codemisor}</CodEmisor>
            <CodUsuario>{self.codusuario}</CodUsuario>
            <NumTerminal>{self.numterminal}</NumTerminal>
            <NumReferencia>{dict_parametros.get('numreferencia')}</NumReferencia>
            <NumTarjetaMonedero>{dict_parametros.get('numtarjetamonedero')}</NumTarjetaMonedero>
            <Importe>{dict_parametros.get('importe')}</Importe>
            <FechaExpiracion>{self.fecexp}</FechaExpiracion>
            <Comercio>{dict_parametros.get('comercio')}</Comercio>
            <Moneda>{self.moneda}</Moneda>
            <FechaTxnTerminal>{fecha}</FechaTxnTerminal>
            <HoraTxnTerminal>{hora}</HoraTxnTerminal>
            <WSUsuario>{self.vuser}</WSUsuario>
            <WSClave>{self.vpass}</WSClave>
            <Reservado>{self.reservado}</Reservado>
        </{soap_action}>]]>
        """
        try:
            result_xml = self.enviar_soap_request(self.url,datos,soap_action,format = 'xml')
            result_dict = self.soap_request_to_dict(result_xml,soap_action)
            result = result_dict[soap_action]
            result.update({'estado':True,'mensaje':result['DescRespuesta']})
            if result['CodRespuesta']!='0000':
                result.update({'estado':False,'mensaje':result['DescRespuesta']})
            return result
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
        return result
        
    def informacion_tarjeta(self,dict_parametros):
        soap_action = 'Informacion_Tarjeta'
        fecha = datetime.datetime.now().strftime('%Y%m%d')
        hora = datetime.datetime.now().strftime('%H%M%S')
        datos = f"""
        <![CDATA[
            <{soap_action}>
            <CodEmisor>{self.codemisor}</CodEmisor>
            <CodUsuario>{self.codusuario}</CodUsuario>
            <NumTerminal>{self.numterminal}</NumTerminal>
            <NumReferencia>{dict_parametros.get('numreferencia')}</NumReferencia>
            <NumTarjeta>{dict_parametros.get('numtarjetamonedero')}</NumTarjeta>
            <FechaExpiracion>{self.fecexp}</FechaExpiracion>
            <Comercio>{self.comercio_transferir_soles_salida}</Comercio>
            <FechaTxnTerminal>{fecha}</FechaTxnTerminal>
            <HoraTxnTerminal>{hora}</HoraTxnTerminal>
            <WSUsuario>{self.vuser}</WSUsuario>
            <WSClave>{self.vpass}</WSClave>
            <Reservado>{self.reservado}</Reservado>
        </{soap_action}>]]>
        """
        try:
            result_xml = self.enviar_soap_request(self.url,datos,soap_action,format = 'XML')
            result_dict = self.soap_request_to_dict(result_xml,soap_action)
            result = result_dict[soap_action]
            if result['CodRespuesta']!='0000':
                result.update({'estado':False,'mensaje':result['DescRespuesta']})
                #raise ValueError(result_dict[soap_action]['DescRespuesta'])
        except HTTPError as e:
            cuerpo_error = e.read().decode()
            result = {'estado':False,'mensaje':f"{e.code} - {e.reason} : {cuerpo_error}"}
            #raise ValueError(f"Error HTTP: {e.code} - {e.reason} : {cuerpo_error}")
        except URLError as e:
            result = {'estado':False,'mensaje':str(e.reason)}
            #raise ValueError(f"Error de URL: {e.reason} : {cuerpo_error}")
        return result
