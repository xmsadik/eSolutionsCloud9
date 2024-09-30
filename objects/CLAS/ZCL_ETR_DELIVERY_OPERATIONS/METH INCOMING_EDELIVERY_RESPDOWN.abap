  METHOD incoming_edelivery_respdown.
    SELECT SINGLE docui, bukrs, archv, dlvii AS docii, dlvui AS duich, dlvno AS docno, envui, ruuid
      FROM zetr_t_icdlv
      WHERE docui = @iv_document_uid
      INTO @DATA(ls_document).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_etr_regulative_exception
        MESSAGE e005(zetr_common).
    ELSEIF ls_document-archv IS NOT INITIAL.
      SELECT SINGLE contn
        FROM zetr_t_arcd
        WHERE docui = @ls_document-docui
          AND conty = @iv_content_type
          AND docty = 'INCDLVRES'
        INTO @rv_document.
    ELSE.
      DATA(lo_edelivery_service) = zcl_etr_edelivery_ws=>factory( iv_company = ls_document-bukrs ).
      rv_document = lo_edelivery_service->incoming_delivery_respdown( is_document_numbers = CORRESPONDING #( ls_document )
                                                                      iv_content_type = iv_content_type ).
      CHECK iv_create_log = abap_true.
      zcl_etr_regulative_log=>create_single_log(
        EXPORTING
          iv_log_code    = zcl_etr_regulative_log=>mc_log_codes-download
          iv_document_id = ls_document-docui ).
    ENDIF.
  ENDMETHOD.