  METHOD if_apj_rt_exec_object~execute.
    LOOP AT it_parameters INTO DATA(ls_parameter).
      CASE ls_parameter-selname.
        WHEN 'P_BUKRS'.
          IF ls_parameter-low IS INITIAL.
            SELECT bukrs, title
              FROM zetr_t_cmpin
              WHERE bukrs EQ @ls_parameter-low
              INTO TABLE @DATA(lt_companies).
          ELSE.
            SELECT bukrs, title
              FROM zetr_t_cmpin
              INTO TABLE @lt_companies.
          ENDIF.
        WHEN 'P_BEGDA'.
          DATA(lv_begda) = CONV datum( ls_parameter-low ).
        WHEN 'P_ENDDA'.
          DATA(lv_endda) = CONV datum( ls_parameter-low ).
      ENDCASE.
    ENDLOOP.
    IF lv_begda IS INITIAL.
      lv_begda = cl_abap_context_info=>get_system_date( ) - 1.
    ENDIF.
    IF lv_endda IS INITIAL.
      lv_endda = lv_begda.
    ENDIF.
    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'ZETR_ALO_REGULATIVE'
                                                                                      subobject = 'DELIVERY_UPDOUT_JOB' ) ).
        DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                           id = 'ZETR_COMMON'
                                                           number = '213' ).
        lo_log->add_item( lo_message ).
        LOOP AT lt_companies INTO DATA(ls_company).
          SELECT FROM zetr_t_ogdlv
            FIELDS docui, dlvno
            WHERE bukrs = @ls_company-bukrs
              AND stacd NOT IN ('','2')
              AND snddt BETWEEN @lv_begda AND @lv_endda
            INTO TABLE @DATA(lt_documents).
          CHECK sy-subrc = 0.

          TRY.
              DATA(lo_delivery_operations) = zcl_etr_delivery_operations=>factory( ls_company-bukrs ).
              LOOP AT lt_documents INTO DATA(ls_document).
                DATA(ls_status) = lo_delivery_operations->outgoing_delivery_status( iv_document_uid = ls_document-docui ).
                lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_status
                                                             id = 'ZETR_COMMON'
                                                             number = '000'
                                                             variable_1 = CONV #( ls_document-dlvno )
                                                             variable_2 = '->'
                                                             variable_3 = CONV #( ls_status-stacd )
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
              TRY.
                  lo_log->add_item( lx_exception ).
                CATCH cx_bali_runtime.
              ENDTRY.
          ENDTRY.
        ENDLOOP.
      CATCH cx_root INTO DATA(lx_root).
        lx_exception = cl_bali_exception_setter=>create( severity = if_bali_constants=>c_severity_error
                                                         exception = lx_root ).
        TRY.
            lo_log->add_item( lx_exception ).
          CATCH cx_bali_runtime.
        ENDTRY.
    ENDTRY.

    TRY.
        cl_bali_log_db=>get_instance( )->save_log( log = lo_log assign_to_current_appl_job = abap_true ).
      CATCH cx_bali_runtime.
    ENDTRY.
  ENDMETHOD.