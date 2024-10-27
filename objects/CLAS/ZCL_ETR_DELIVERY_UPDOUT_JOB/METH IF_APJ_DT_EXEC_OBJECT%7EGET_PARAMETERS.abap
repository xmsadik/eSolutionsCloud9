  METHOD if_apj_dt_exec_object~get_parameters.
    et_parameter_def = VALUE #( ( selname = 'P_BUKRS'
                                  kind = if_apj_dt_exec_object=>parameter
*                                  component_type = 'BUKRS'
                                  datatype = 'C'
                                  length = 4
                                  param_text = 'Company'
                                  changeable_ind = abap_true )
                                ( selname = 'P_BEGDA'
                                  kind = if_apj_dt_exec_object=>parameter
*                                  component_type = 'DATUM'
                                  datatype = 'D'
                                  length = 8
                                  param_text = 'Date Begin'
                                  changeable_ind = abap_true )
                                ( selname = 'P_ENDDA'
                                  kind = if_apj_dt_exec_object=>parameter
*                                  component_type = 'DATUM'
                                  datatype = 'D'
                                  length = 8
                                  param_text = 'Date End'
                                  changeable_ind = abap_true ) ).

    DATA(lv_yesterday) = CONV datum( cl_abap_context_info=>get_system_date( ) - 10 ).
    DATA(lv_today) = CONV datum( cl_abap_context_info=>get_system_date( ) ).
    et_parameter_val = VALUE #( ( selname = 'P_BEGDA'
                                  kind = if_apj_dt_exec_object=>parameter
                                  sign = 'I'
                                  option = 'EQ'
                                  low = |{ lv_yesterday+6(2) }.{ lv_yesterday+4(2) }.{ lv_yesterday(4) }| )
                                ( selname = 'P_ENDDA'
                                  kind = if_apj_dt_exec_object=>parameter
                                  sign = 'I'
                                  option = 'EQ'
                                  low = |{ lv_today+6(2) }.{ lv_today+4(2) }.{ lv_today(4) }| ) ).
  ENDMETHOD.