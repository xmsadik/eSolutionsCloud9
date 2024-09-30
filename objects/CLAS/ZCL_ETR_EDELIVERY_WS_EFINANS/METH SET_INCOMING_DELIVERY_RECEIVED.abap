  METHOD set_incoming_delivery_received.
    DATA: lv_request_xml TYPE string.

    CONCATENATE
    '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.connector.uut.cs.com.tr/">'
      '<soapenv:Header>'
        '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">'
          '<wsse:UsernameToken>'
              '<wsse:Username>' ms_company_parameters-wsusr '</wsse:Username>'
              '<wsse:Password>' ms_company_parameters-wspwd '</wsse:Password>'
          '</wsse:UsernameToken>'
        '</wsse:Security>'
      '</soapenv:Header>'
       '<soapenv:Body>'
          '<ser:belgelerAlindi>'
             '<belgeTuru>IRSALIYE</belgeTuru>'
             '<ettn>' iv_document_uuid '</ettn>'
             '<vergiTcKimlikNo>' mv_company_taxid '</vergiTcKimlikNo>'
          '</ser:belgelerAlindi>'
       '</soapenv:Body>'
    '</soapenv:Envelope>'
    INTO lv_request_xml.
*    mv_request_url = '/efatura/ws/connectorService'.
    run_service( lv_request_xml ).
  ENDMETHOD.