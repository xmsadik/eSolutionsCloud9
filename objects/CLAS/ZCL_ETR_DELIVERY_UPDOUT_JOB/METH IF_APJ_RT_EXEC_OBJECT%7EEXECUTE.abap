  METHOD if_apj_rt_exec_object~execute.
    TYPES: BEGIN OF ty_document,
             docui TYPE zetr_t_ogdlv-docui,
             dlvno TYPE zetr_t_ogdlv-dlvno,
             bukrs TYPE zetr_t_ogdlv-bukrs,
           END OF ty_document,
           BEGIN OF ty_company,
             bukrs TYPE zetr_t_ogdlv-bukrs,
           END OF ty_company.
    DATA: lt_documents   TYPE SORTED TABLE OF ty_document WITH UNIQUE KEY docui
                                                          WITH NON-UNIQUE SORTED KEY by_bukrs COMPONENTS bukrs,
          lt_companies   TYPE STANDARD TABLE OF ty_company,
          lt_datum_range TYPE RANGE OF datum,
          lt_bukrs_range TYPE RANGE OF bukrs.

    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'S_BUKRS'.
          APPEND INITIAL LINE TO lt_bukrs_range ASSIGNING FIELD-SYMBOL(<ls_bukrs>).
          <ls_bukrs> = CORRESPONDING #( ls_parameter ).
        WHEN 'S_DATUM'.
          APPEND INITIAL LINE TO lt_datum_range ASSIGNING FIELD-SYMBOL(<ls_datum>).
          <ls_datum> = CORRESPONDING #( ls_parameter ).
      ENDCASE.
    ENDLOOP.

    IF lt_datum_range IS INITIAL.
      APPEND INITIAL LINE TO lt_datum_range ASSIGNING <ls_datum>.
      <ls_datum>-sign = 'I'.
      <ls_datum>-option = 'EQ'.
      <ls_datum>-low = cl_abap_context_info=>get_system_date( ) - 10.
      <ls_datum>-high = cl_abap_context_info=>get_system_date( ).
    ENDIF.

    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'ZETR_ALO_REGULATIVE'
                                                                                       subobject = 'INVOICE_UPDOUT_JOB' ) ).
        SELECT FROM zetr_t_ogdlv
          FIELDS docui, dlvno, bukrs
          WHERE bukrs IN @lt_bukrs_range
            AND stacd NOT IN ('','2')
            AND snddt IN @lt_datum_range
          INTO TABLE @lt_documents.
        IF sy-subrc = 0.
          lt_companies = CORRESPONDING #( lt_documents ).
          SORT lt_companies.
          DELETE ADJACENT DUPLICATES FROM lt_companies.
        ELSE.
          DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                             id = 'ZETR_COMMON'
                                                             number = '005' ).
          lo_log->add_item( lo_message ).
        ENDIF.

        LOOP AT lt_companies INTO DATA(ls_company).
          TRY.
              DATA(lo_delivery_operations) = zcl_etr_delivery_operations=>factory( ls_company-bukrs ).
              LOOP AT lt_documents INTO DATA(ls_document) USING KEY by_bukrs WHERE bukrs = ls_company-bukrs.
                DATA(ls_status) = lo_delivery_operations->outgoing_delivery_status( iv_document_uid = ls_document-docui ).
                lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_status
                                                             id = 'ZETR_COMMON'
                                                             number = '000'
                                                             variable_1 = CONV #( ls_document-dlvno )
                                                             variable_2 = '->'
                                                             variable_3 = CONV #( ls_status-radsc )
                                                             variable_4 = CONV #( ls_status-staex ) ).
                lo_log->add_item( lo_message ).
              ENDLOOP.
            CATCH zcx_etr_regulative_exception INTO DATA(lx_regulative_exception).
              lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                           id = 'ZETR_COMMON'
                                                           number = '004'
                                                           variable_1 = CONV #( ls_document-dlvno ) ).
              lo_log->add_item( lo_message ).
              DATA(lx_exception) = cl_bali_exception_setter=>create( severity = if_bali_constants=>c_severity_error
                                                                     exception = lx_regulative_exception ).
              lo_log->add_item( lx_exception ).
          ENDTRY.
        ENDLOOP.

        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime.
    ENDTRY.
  ENDMETHOD.