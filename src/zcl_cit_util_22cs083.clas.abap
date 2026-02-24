CLASS zcl_cit_util_22cs083 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    " Types for Header and Item
    TYPES: BEGIN OF ty_sales_hdr,
             salesdocument TYPE zsorder,
           END OF ty_sales_hdr.

    TYPES: BEGIN OF ty_sales_item,
             salesdocument   TYPE zsorder,
             salesitemnumber TYPE int2,
           END OF ty_sales_item.

    " Table Types
    TYPES: tt_sales_header TYPE STANDARD TABLE OF ty_sales_hdr WITH DEFAULT KEY.
    TYPES: tt_sales_items  TYPE STANDARD TABLE OF ty_sales_item WITH DEFAULT KEY.

    " Singleton Instance Access
    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcl_cit_util_22cs083.

    " Buffer Methods for Header
    METHODS set_hdr_value
      IMPORTING im_sales_hdr TYPE zcit_header
      EXPORTING ex_created   TYPE abap_boolean.

    METHODS get_hdr_value
      EXPORTING ex_sales_hdr TYPE zcit_header.

    " Buffer Methods for Item
    METHODS set_itm_value
      IMPORTING im_sales_itm TYPE zcit_itm
      EXPORTING ex_created   TYPE abap_boolean.

    METHODS get_itm_value
      EXPORTING ex_sales_itm TYPE zcit_itm.

    " Buffer Methods for Deletion
    METHODS set_hdr_deletion_flag
      IMPORTING im_so_delete TYPE abap_boolean.

    METHODS get_deletion_flags
      EXPORTING ex_so_hdr_del TYPE abap_boolean.

    METHODS set_hdr_t_deletion
      IMPORTING im_sales_doc TYPE ty_sales_hdr.

    METHODS get_hdr_t_deletion
      EXPORTING ex_sales_docs TYPE tt_sales_header.

    METHODS set_itm_t_deletion
      IMPORTING im_sales_itm_info TYPE ty_sales_item.

    METHODS get_itm_t_deletion
      EXPORTING ex_sales_info TYPE tt_sales_items.

    METHODS cleanup_buffer.

    " --- NEW: Email Method Definition ---
    " We use STRING here because it is a permitted type in ABAP Cloud
    METHODS send_email
      IMPORTING
        iv_sales_doc   TYPE zsorder
        iv_email       TYPE string
      RETURNING
        VALUE(rv_sent) TYPE abap_boolean.
    METHODS save_data.
    METHODS clear_data.
    " ------------------------------------

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA: go_instance TYPE REF TO zcl_cit_util_22cs083.

    " Buffer Variables
    DATA: ms_sales_hdr    TYPE zcit_header,
          ms_sales_itm    TYPE zcit_itm,
          mv_so_hdr_del   TYPE abap_boolean,
          mt_sales_header TYPE tt_sales_header,
          mt_sales_items  TYPE tt_sales_items.
ENDCLASS.



CLASS ZCL_CIT_UTIL_22CS083 IMPLEMENTATION.


  METHOD get_instance.
    IF go_instance IS NOT BOUND.
      go_instance = NEW #( ).
    ENDIF.
    ro_instance = go_instance.
  ENDMETHOD.


  METHOD set_hdr_value.
    IF ms_sales_hdr-salesdocument IS INITIAL.
      ms_sales_hdr = im_sales_hdr.
      ex_created = abap_true.
    ELSE.
      ex_created = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD get_hdr_value.
    ex_sales_hdr = ms_sales_hdr.
  ENDMETHOD.


  METHOD set_itm_value.
    ms_sales_itm = im_sales_itm.
    ex_created = abap_true.
  ENDMETHOD.


  METHOD get_itm_value.
    ex_sales_itm = ms_sales_itm.
  ENDMETHOD.


  METHOD set_hdr_deletion_flag.
    mv_so_hdr_del = im_so_delete.
  ENDMETHOD.


  METHOD get_deletion_flags.
    ex_so_hdr_del = mv_so_hdr_del.
  ENDMETHOD.


  METHOD set_hdr_t_deletion.
    APPEND im_sales_doc TO mt_sales_header.
  ENDMETHOD.


  METHOD get_hdr_t_deletion.
    ex_sales_docs = mt_sales_header.
  ENDMETHOD.


  METHOD set_itm_t_deletion.
    APPEND im_sales_itm_info TO mt_sales_items.
  ENDMETHOD.


  METHOD get_itm_t_deletion.
    ex_sales_info = mt_sales_items.
  ENDMETHOD.


  METHOD cleanup_buffer.
    CLEAR: ms_sales_hdr, ms_sales_itm, mv_so_hdr_del, mt_sales_header, mt_sales_items.
  ENDMETHOD.


  METHOD send_email.
    TRY.
        " 1. Create Mail Instance
        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

        " 2. Add Recipient
        " FIX: Use CONV #( ) to convert STRING to the required internal type automatically.
        " This avoids using the forbidden Data Element name explicitly.
        lo_mail->add_recipient( iv_address = CONV #( iv_email ) ).

        " 3. Set Subject
        lo_mail->set_subject( |Notification: Sales Order { iv_sales_doc } Saved| ).

        " 4. Set Content (Body)
        DATA(lv_content) = |Dear User,\n\n| &&
                           |Sales Order { iv_sales_doc } has been successfully created/updated in the system.\n\n| &&
                           |Best Regards,\nSales Team|.

        lo_mail->set_main( cl_bcs_mail_textpart=>create_instance(
            iv_content      = lv_content
            iv_content_type = 'text/plain'
        ) ).

        " 5. Send Email
        lo_mail->send( ).

        rv_sent = abap_true.

      CATCH cx_bcs_mail INTO DATA(lx_mail).
        " Error handling
        rv_sent = abap_false.
    ENDTRY.
  ENDMETHOD.

  METHOD save_data.

  ENDMETHOD.


  METHOD clear_data.

  ENDMETHOD.

ENDCLASS.
