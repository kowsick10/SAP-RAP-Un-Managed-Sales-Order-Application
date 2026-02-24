CLASS lhc_SalesOrderHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    TYPES: BEGIN OF ty_excel_row,
             col_a TYPE string,
             col_b TYPE string,
             col_c TYPE string,
             col_d TYPE string,
             col_e TYPE string,
             col_f TYPE string,
             col_g TYPE string,
           END OF ty_excel_row.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE SalesOrderHdr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SalesOrderHdr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SalesOrderHdr.

    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrderHdr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK SalesOrderHdr.

    METHODS rba_Salesitem FOR READ
      IMPORTING keys_rba FOR READ SalesOrderHdr\_Salesitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_Salesitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE SalesOrderHdr\_Salesitem.

    METHODS uploadExcelData FOR MODIFY
      IMPORTING keys FOR ACTION SalesOrderHdr~uploadExcelData RESULT result.

    METHODS downloadTemplate FOR MODIFY
      IMPORTING keys FOR ACTION SalesOrderHdr~downloadTemplate RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR SalesOrderHdr RESULT result.

ENDCLASS.

CLASS lhc_SalesOrderHdr IMPLEMENTATION.

  METHOD get_instance_authorizations. ENDMETHOD.
  METHOD get_global_authorizations. ENDMETHOD.
  METHOD lock. ENDMETHOD.

  METHOD create.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entities).
      DATA(ls_sales_hdr) = CORRESPONDING zcit_header( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_hdr-salesdocument IS NOT INITIAL.
        SELECT SINGLE FROM zcit_header FIELDS salesdocument
          WHERE salesdocument = @ls_sales_hdr-salesdocument
          INTO @DATA(lv_exists).

        IF sy-subrc NE 0.
          lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
                                  IMPORTING ex_created   = DATA(lv_created) ).
          IF lv_created EQ abap_true.
            APPEND VALUE #( %cid = ls_entities-%cid
                            salesdocument = ls_sales_hdr-salesdocument ) TO mapped-salesorderhdr.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).
    LOOP AT entities INTO DATA(ls_entities).
      lo_util->get_hdr_value( IMPORTING ex_sales_hdr = DATA(ls_sales_hdr) ).

      IF ls_sales_hdr-salesdocument <> ls_entities-SalesDocument.
        SELECT SINGLE FROM zcit_header FIELDS * WHERE salesdocument = @ls_entities-SalesDocument
          INTO @ls_sales_hdr.
      ENDIF.

      IF ls_entities-%control-OrderReason = if_abap_behv=>mk-on.
        ls_sales_hdr-orderreason = ls_entities-OrderReason.
      ENDIF.

      lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr ).
    ENDLOOP.
  ENDMETHOD.

  METHOD uploadExcelData.
    DATA: lt_excel_rows TYPE STANDARD TABLE OF ty_excel_row.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).

    READ ENTITIES OF zcit_sales_i IN LOCAL MODE
      ENTITY SalesOrderHdr ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    DATA(ls_header) = lt_headers[ 1 ].

    TRY.
        DATA(lo_xlsx) = xco_cp_xlsx=>document->for_file_content( ls_header-Attachment )->read_access( ).
        DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).

        DATA(lo_selection) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
          )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
          )->to_column(   xco_cp_xlsx=>coordinate->for_alphabetic_value( 'G' )
          )->from_row(    xco_cp_xlsx=>coordinate->for_numeric_value( 2 )
          )->get_pattern( ).

        lo_worksheet->select( lo_selection )->row_stream( )->operation->write_to( REF #( lt_excel_rows ) )->execute( ).

        DATA lv_item_pos TYPE int2 VALUE 10.
        LOOP AT lt_excel_rows INTO DATA(ls_row) WHERE col_c IS NOT INITIAL.
          DATA(ls_new_item) = VALUE zcit_itm(
            salesdocument   = ls_header-SalesDocument
            salesitemnumber = lv_item_pos
            material        = ls_row-col_c
            plant           = ls_row-col_d
            quantity        = ls_row-col_e
          ).
          lo_util->set_itm_value( EXPORTING im_sales_itm = ls_new_item ).
          lv_item_pos += 10.
        ENDLOOP.

        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-success
                                                      text     = 'Excel processed successfully.' )
                      ) TO reported-salesorderhdr.

      CATCH cx_root.
        APPEND VALUE #( %tky = ls_header-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = 'Excel processing failed.' )
                      ) TO reported-salesorderhdr.
    ENDTRY.
  ENDMETHOD.

  METHOD downloadTemplate.
    DATA(lo_xlsx) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_worksheet) = lo_xlsx->get_workbook( )->worksheet->at_position( 1 ).
    DATA(lt_headers) = VALUE string_table( ( `SalesDoc` ) ( `Item` ) ( `Material` ) ( `Plant` ) ( `Qty` ) ( `Price` ) ( `Currency` ) ).

    " --- ERROR FIXED HERE: Added io_column and io_row labels ---
    DATA(lo_cursor) = lo_worksheet->cursor(
        io_column = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
        io_row    = xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
    ).
    " -----------------------------------------------------------

    LOOP AT lt_headers INTO DATA(lv_header).
      lo_cursor->get_cell( )->value->write_from( lv_header ).
      lo_cursor->move_right( ).
    ENDLOOP.

    DATA(lv_file) = lo_xlsx->get_file_content( ).

    MODIFY ENTITIES OF zcit_sales_i IN LOCAL MODE
      ENTITY SalesOrderHdr
      UPDATE FIELDS ( Attachment MimeType Filename )
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky
                                      Attachment = lv_file
                                      MimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
                                      Filename = 'Template.xlsx' ) ).

    READ ENTITIES OF zcit_sales_i IN LOCAL MODE
      ENTITY SalesOrderHdr ALL FIELDS WITH CORRESPONDING #( keys ) RESULT DATA(lt_res).
    result = VALUE #( FOR h IN lt_res ( %tky = h-%tky %param = h ) ).
  ENDMETHOD.

  METHOD get_instance_features.
    result = VALUE #( FOR key IN keys
                      ( %tky = key-%tky
                        %action-uploadExcelData = if_abap_behv=>fc-o-enabled
                        %action-downloadTemplate = if_abap_behv=>fc-o-enabled ) ).
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_hdr_t_deletion( EXPORTING im_sales_doc = VALUE #( salesdocument = ls_key-salesdocument ) ).
      lo_util->set_hdr_deletion_flag( EXPORTING im_so_delete = abap_true ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE FROM zcit_header FIELDS * WHERE salesdocument = @ls_key-salesdocument
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0. APPEND CORRESPONDING #( ls_hdr ) TO result. ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD rba_Salesitem.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT FROM zcit_itm FIELDS * WHERE salesdocument = @ls_key-salesdocument
        INTO TABLE @DATA(lt_items).
      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        APPEND VALUE #( source-salesdocument = ls_key-salesdocument
                        target-salesdocument = ls_item-salesdocument
                        target-salesitemnumber = ls_item-salesitemnumber ) TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Salesitem.
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).
    LOOP AT entities_cba INTO DATA(ls_entities_cba).
      LOOP AT ls_entities_cba-%target INTO DATA(ls_item_create).
        DATA(ls_sales_itm) = CORRESPONDING zcit_itm( ls_item_create MAPPING FROM ENTITY ).
        ls_sales_itm-salesdocument = ls_entities_cba-SalesDocument.
        lo_util->set_itm_value( EXPORTING im_sales_itm = ls_sales_itm ).
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
