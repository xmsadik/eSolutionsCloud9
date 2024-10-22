  METHOD if_oo_adt_classrun~main.
    DATA lt_uuid TYPE RANGE OF sysuuid_c22.

    SELECT documentuuid, documentnumber
      FROM zetr_ddl_i_outgoing_invoices AS z
      INNER JOIN i_journalentry AS j
      ON  j~CompanyCode = z~CompanyCode
      AND j~AccountingDocument = z~DocumentNumber
      AND j~FiscalYear = z~FiscalYear
      WHERE z~StatusCode IN ('','2')
        AND j~AccountingDocumentType = 'KZ'
      INTO TABLE @lt_uuid.
    CHECK sy-subrc = 0.
    DELETE FROM zetr_t_oginv WHERE docui IN @lt_uuid.
    DELETE FROM zetr_t_arcd WHERE docui IN @lt_uuid.
    DELETE FROM zetr_t_logs WHERE docui IN @lt_uuid.
    COMMIT WORK AND WAIT.
  ENDMETHOD.