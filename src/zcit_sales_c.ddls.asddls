//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Header Consumption View'
//@Metadata.ignorePropagatedAnnotations: true
//define root view entity ZCIT_SALES_C as select from ZCIT_SALES_I
//composition of target_data_source_name as _association_name
//{
//    key SalesDocument,
//    SalesDocumentType,
//    OrderReason,
//    SalesOrganization,
//    DistributionChannel,
//    Division,
//    SalesOffice,
//    SalesGroup,
//    NetPrice,
//    Currency,
//    LocalCreatedBy,
//    LocalCreatedAt,
//    LocalLastChangedBy,
//    LocalLastChangedAt,
//    /* Associations */
//    _salesitem,
//    _association_name // Make association public
//}
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Header Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_SALES_C
  provider contract transactional_query
  as projection on ZCIT_SALES_I
{
  key SalesDocument,
      SalesDocumentType,
      OrderReason,
      SalesOrganization,
      DistributionChannel,
      Division,
      @Search.defaultSearchElement: true
      SalesOffice,
      SalesGroup,
      @Semantics.amount.currencyCode: 'Currency'
      NetPrice,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      Currency,

      /* --- REQUIRED FOR FILE UPLOAD --- */
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'Filename',
        contentDispositionPreference: #ATTACHMENT
      }
      Attachment,

      @Semantics.mimeType: true
      MimeType,

      Filename,
      /* -------------------------------- */

      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      
      /* Associations */
      _salesitem : redirected to composition child ZCIT_SALES_OC
}
