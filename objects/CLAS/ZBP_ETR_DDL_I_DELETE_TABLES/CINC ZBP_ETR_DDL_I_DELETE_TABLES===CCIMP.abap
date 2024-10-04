CLASS lhc_DeleteEntries DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR DeleteEntries RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ DeleteEntries RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK DeleteEntries.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR DeleteEntries RESULT result.

    METHODS deleteDocuments FOR MODIFY
      IMPORTING keys FOR ACTION DeleteEntries~deleteDocuments RESULT result.

ENDCLASS.

CLASS lhc_DeleteEntries IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD deleteDocuments.
    READ ENTITIES OF zetr_ddl_i_delete_tables IN LOCAL MODE
    ENTITY DeleteEntries
    ALL FIELDS WITH
    CORRESPONDING #( keys )
    RESULT DATA(Documents).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZETR_DDL_I_DELETE_TABLES DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZETR_DDL_I_DELETE_TABLES IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    CHECK sy-subrc = 0.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.