import json,urllib.error , urllib.request as urequest
import xml.etree.ElementTree as ET
from aplicacion_general import credenciales
class equifax:
    def __init__(self,**kwargs):
        self.params = {clave:valor for clave,valor in kwargs.items()}
        c = credenciales()
        dict_credenciales = c.obtener_datos_secret_manager()
        self.vuser = dict_credenciales.get('api_equifax_usuario')
        self.vpass = dict_credenciales.get('api_equifax_password')
        self.url = dict_credenciales.get('api_equifax_url')
        self.url_endpoint = dict_credenciales.get('api_equifax_url_endpoint')
        self.url_document = dict_credenciales.get('api_equifax_url_document')
        self.url_base_service = dict_credenciales.get('api_equifax_service')
        self.iservice_name = 'Endpoint'
        self.dict_duplicado = {}
    
    def estructurar_soap_xml(self,body,soap_action,soap_sub_action):
        str_soap = f"""
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:end="{self.url_endpoint}" xmlns:doc="{self.url_document}" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
                <soapenv:Header>
                <wsse:Security soapenv:mustUnderstand="1">
                    <wsse:UsernameToken wsu:Id="UsernameToken-1">
                        <wsse:Username>{self.vuser}</wsse:Username>
                        <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">{self.vpass}</wsse:Password>
                    </wsse:UsernameToken>
                </wsse:Security>
        </soapenv:Header>
        <soapenv:Body>
            <end:{soap_action}>
                <doc:{soap_sub_action}>
                    {body}
                </doc:{soap_sub_action}>
            </end:{soap_action}>
        </soapenv:Body>
        </soapenv:Envelope>
        """
        return str_soap
    
    def enviar_soap_request(self,url,datos,soap_action,soap_sub_action):
        headers = {
            'Content-Type': 'text/xml; charset=utf-8'
        }
        try:
            result_request = urequest.Request(url,data = self.estructurar_soap_xml(datos,soap_action,soap_sub_action).encode('utf-8'), headers = headers)
            response = urequest.urlopen(result_request)
            resultado = response.read().decode('utf-8')
        except Exception as e:
            resultado = """
            <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
            <soap:Body>
                <soap:Fault>
                    <faultcode>soap:EI3000</faultcode>
                </soap:Fault>
            </soap:Body>
            </soap:Envelope>
            """
        return resultado
    
    def validar_duplicado(self,text_base,text_validar):
        if text_base.lower() == text_validar.lower():
            if not text_validar.lower() in self.dict_duplicado:
                self.dict_duplicado.update({text_validar.lower():1})
            else:
                self.dict_duplicado.update({text_validar.lower():self.dict_duplicado[text_validar.lower()]+1})
            text_base = text_base+'_'+str(self.dict_duplicado[text_validar.lower()])
        return text_base

    def soap_xml_to_dict(self,element):
        if len(element) == 0:
            return element.text
        return {self.validar_duplicado(str(child.tag).replace(self.url_base_service,'').replace(self.url_endpoint,'').replace(self.url_document,'').replace('{}','').replace('{http://schemas.xmlsoap.org/soap/envelope/}',''),'modulo'): self.soap_xml_to_dict(child) for child in element}
    
    def soap_request_to_dict(self,string_request,soap_action):
        result_soap = string_request.replace('&lt;','<').replace('&gt;&#xD;','>').replace('&gt;','>').replace('&#xD;','').replace('<?xml version="1.0" encoding="UTF-8"?>','')
        raiz = ET.fromstring(result_soap)
        data = self.soap_xml_to_dict(raiz)
        return data['Body']
    def obtener_datos_personales(self,tipo_per,tipo_doc,numero_doc):
        soap_action = 'GetReporteOnline'
        soap_sub_action = 'DatosConsulta'
        datos = f"""
        <TipoPersona>{tipo_per}</TipoPersona>
        <TipoDocumento>{tipo_doc}</TipoDocumento>
        <NumeroDocumento>{numero_doc}</NumeroDocumento>
        <CodigoReporte>380</CodigoReporte>
        """
        result_soap = self.soap_request_to_dict(self.enviar_soap_request(self.url,datos,soap_action,soap_sub_action),soap_action)
        if 'Fault' in result_soap:
            result = {'result':False}
        else:
            result = {'result':True,'data':result_soap[f'{soap_action}Response']['ReporteCrediticio']['Modulos']['Modulo_1']['Data']['DirectorioPersona']}
        return result