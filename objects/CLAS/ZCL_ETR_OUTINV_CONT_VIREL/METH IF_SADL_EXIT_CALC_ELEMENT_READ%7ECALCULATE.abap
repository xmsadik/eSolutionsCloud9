  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA: lt_output TYPE STANDARD TABLE OF zetr_ddl_p_outgoing_invcont.
    lt_output = CORRESPONDING #( it_original_data ).
    LOOP AT lt_output ASSIGNING FIELD-SYMBOL(<ls_output>).
      <ls_output>-ContentUrl = 'https://' && zcl_etr_regulative_common=>get_ui_url( ) &&
                               '/sap/opu/odata/sap/ZETR_DDL_B_OUTG_INVOICES/Contents(DocumentUUID=guid''' && <ls_output>-DocumentUUID &&
                               ''',ContentType=''' && <ls_output>-ContentType &&
                               ''',DocumentType=''' && <ls_output>-DocumentType && ''')/$value'.
    ENDLOOP.
    IF lines( lt_output ) = 1.
      READ TABLE lt_output
        ASSIGNING <ls_output>
        INDEX 1.
      IF sy-subrc = 0.
        SELECT SINGLE contn
          FROM zetr_t_arcd
          WHERE docui = @<ls_output>-DocumentUUID
            AND conty = @<ls_output>-ContentType
          INTO @<ls_output>-Content.
        IF <ls_output>-Content IS INITIAL.
          TRY.
              DATA(lo_invoice_operations) = zcl_etr_invoice_operations=>factory( <ls_output>-companycode ).
              <ls_output>-Content = lo_invoice_operations->outgoing_invoice_download( iv_document_uid = <ls_output>-DocumentUUID
                                                                                      iv_content_type = <ls_output>-ContentType ).
            CATCH zcx_etr_regulative_exception INTO DATA(lx_etr_regulative_exception).
              <ls_output>-Content = cl_abap_conv_codepage=>create_out( )->convert(
                                                                                   replace( val = '<!DOCTYPE html><html><body><h1>Hata Olustu / Error Occured</h1><p>' &&
                                                                                                   lx_etr_regulative_exception->get_text( ) &&
                                                                                                   '</p></body></html>'
                                                                                            sub = |\n|
                                                                                            with = ``
                                                                                            occ = 0  ) ).
          ENDTRY.
        ENDIF.
      ENDIF.
    ENDIF.
    ct_calculated_data = CORRESPONDING #( lt_output ).
  ENDMETHOD.