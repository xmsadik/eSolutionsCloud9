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
        WHEN 'P_INVUI'.
          DATA(lv_invui) = CONV sysuuid_c36( ls_parameter-low ).
        WHEN 'P_IMREC'.
          DATA(lv_imrec) = CONV abap_boolean( ls_parameter-low ).
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
                                                                                      subobject = 'INVOICE_GETINC_JOB' ) ).
        DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                           id = 'ZETR_COMMON'
                                                           number = '213' ).
        lo_log->add_item( lo_message ).
        LOOP AT lt_companies INTO DATA(ls_company).
          TRY.
              DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( ls_company-bukrs ).
              DATA(lt_invoice_list) = lo_invoice_operations->get_incoming_invoices( iv_date_from = lv_begda
                                                                                    iv_date_to   = lv_endda
                                                                                    iv_import_received = lv_imrec
                                                                                    iv_invoice_uuid = lv_invui ).
              DATA(lv_saved_records) = lines( lt_invoice_list ).
              lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_status
                                                           id = 'ZETR_COMMON'
                                                           number = '000'
                                                           variable_1 = CONV #( ls_company-bukrs )
                                                           variable_2 = CONV #( ls_company-title )
                                                           variable_3 = '->'
                                                           variable_4 = CONV #( lv_saved_records ) ).
              lo_log->add_item( lo_message ).
            CATCH zcx_etr_regulative_exception INTO DATA(lx_regulative_exception).
              DATA(lx_exception) = cl_bali_exception_setter=>create( severity = if_bali_constants=>c_severity_error
                                                                     exception = lx_regulative_exception ).
              TRY.
                  lo_log->add_item( lx_exception ).
                CATCH cx_bali_runtime.
              ENDTRY.
          ENDTRY.
          CLEAR: lt_invoice_list, lo_invoice_operations.
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