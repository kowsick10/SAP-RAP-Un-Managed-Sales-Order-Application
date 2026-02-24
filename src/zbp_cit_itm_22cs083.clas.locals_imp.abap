CLASS lhc_salesorderitm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SalesOrderItm.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SalesOrderItm.

    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrderItm RESULT result.

    METHODS rba_Salesheader FOR READ
      IMPORTING keys_rba FOR READ SalesOrderItm\_salesHeader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_salesorderitm IMPLEMENTATION.

  METHOD update.
    DATA: ls_sales_itm TYPE zcit_itm.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_itm = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_itm-salesdocument IS NOT INITIAL.
         lo_util->set_itm_value( EXPORTING im_sales_itm = ls_sales_itm
                                 IMPORTING ex_created   = DATA(lv_created) ).

         IF lv_created = abap_true.
           APPEND VALUE #( salesdocument = ls_sales_itm-salesdocument
                           salesitemnumber = ls_sales_itm-salesitemnumber ) TO mapped-salesorderitm.
         ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
     DATA: ls_sales_itm_key TYPE zcl_cit_util_22cs083=>ty_sales_item.
     DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).

     LOOP AT keys INTO DATA(ls_key).
       ls_sales_itm_key-salesdocument = ls_key-SalesDocument.
       ls_sales_itm_key-salesitemnumber = ls_key-SalesItemnumber.

       lo_util->set_itm_t_deletion( im_sales_itm_info = ls_sales_itm_key ).

       " FIXED: Removed %cid_ref usage
       APPEND VALUE #(
                       salesdocument   = ls_key-salesdocument
                       salesitemnumber = ls_key-salesitemnumber
                       %msg = new_message( id       = 'ZCIT_MSG'
                                           number   = 001
                                           v1       = 'Item Deleted'
                                           severity = if_abap_behv_message=>severity-success )
                     ) TO reported-salesorderitm.
     ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_itm FIELDS *
        WHERE salesdocument = @ls_key-SalesDocument
          AND salesitemnumber = @ls_key-SalesItemnumber
        INTO @DATA(ls_itm).
      IF sy-subrc = 0.
        APPEND CORRESPONDING #( ls_itm ) TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Salesheader.
  ENDMETHOD.

ENDCLASS.
