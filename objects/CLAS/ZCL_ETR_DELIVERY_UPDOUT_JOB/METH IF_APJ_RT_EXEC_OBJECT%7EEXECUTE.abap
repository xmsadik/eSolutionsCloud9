  METHOD if_apj_rt_exec_object~execute.
    READ TABLE it_parameters INTO DATA(ls_parameter) INDEX 1.
    CHECK sy-subrc = 0.
    TRY.
        DATA(lo_log) = cl_bali_log=>create_with_header( cl_bali_header_setter=>create( object = 'ZETR_ALO_REGULATIVE'
                                                                                      subobject = 'INVOICE_USERS_JOB' ) ).
        DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                           id = 'ZETR_COMMON'
                                                           number = '213' ).
        lo_log->add_item( lo_message ).
        DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( iv_company = CONV #( ls_parameter-low ) ).
        DATA(lt_data) = lo_invoice_operations->update_einvoice_users( iv_db_write = abap_true ).
        SORT lt_data BY taxid.
        DATA(lv_saved_records) = lines( lt_data ).
        lo_message = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_status
                                                     id = 'ZETR_COMMON'
                                                     number = '082'
                                                     variable_1 = CONV #( lv_saved_records ) ).
        lo_log->add_item( lo_message ).
      CATCH cx_root INTO DATA(lx_root).
        DATA(lx_exception) = cl_bali_exception_setter=>create( severity = if_bali_constants=>c_severity_error
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