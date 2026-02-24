CLASS lsc_zcit_sales_i DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_zcit_sales_i IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    " 1. Retrieve data from Buffer
    DATA(lo_util) = zcl_cit_util_22cs083=>get_instance( ).

    lo_util->get_hdr_value( IMPORTING ex_sales_hdr = DATA(ls_sales_hdr) ).
    lo_util->get_itm_value( IMPORTING ex_sales_itm = DATA(ls_sales_itm) ).

    lo_util->get_hdr_t_deletion( IMPORTING ex_sales_docs = DATA(lt_sales_hdr_del) ).
    lo_util->get_itm_t_deletion( IMPORTING ex_sales_info = DATA(lt_sales_itm_del) ).
    lo_util->get_deletion_flags( IMPORTING ex_so_hdr_del = DATA(lv_so_hdr_del) ).

    " 2. Save/Update Header
    IF ls_sales_hdr IS NOT INITIAL.
      MODIFY zcit_header FROM @ls_sales_hdr.
    ENDIF.

    " 3. Save/Update Item
    " Note: If your utility class buffers multiple items (for Excel upload),
    " ensure get_itm_value returns the full table or loop appropriately.
    " Based on the standard guide, this modifies the item table from the buffer structure.
    IF ls_sales_itm IS NOT INITIAL.
      MODIFY zcit_itm FROM @ls_sales_itm.
    ENDIF.

    " 4. Handle Deletions
    IF lv_so_hdr_del = abap_true.
      " Delete full header and associated items
      LOOP AT lt_sales_hdr_del INTO DATA(ls_del_hdr).
        DELETE FROM zcit_header WHERE salesdocument = @ls_del_hdr-salesdocument.
        DELETE FROM zcit_itm WHERE salesdocument = @ls_del_hdr-salesdocument.
      ENDLOOP.
    ELSE.
      " Delete individual items
      LOOP AT lt_sales_itm_del INTO DATA(ls_del_itm).
        DELETE FROM zcit_itm WHERE salesdocument = @ls_del_itm-salesdocument
                               AND salesitemnumber = @ls_del_itm-salesitemnumber.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    zcl_cit_util_22cs083=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
