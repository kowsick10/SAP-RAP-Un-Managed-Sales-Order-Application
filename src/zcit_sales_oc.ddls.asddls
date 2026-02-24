//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Item consumption View'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZCIT_SALES_OC as select from ZCIT_SALES_O
//{
//    key SalesDocument,
//    key SalesItemnumber,
//    Material,
//    Plant,
//    Quantity,
//    Quantityunits,
//    LocalCreatedBy,
//    LocalCreatedAt,
//    LocalLastChangedBy,
//    LocalLastChangedAt,
//    /* Associations */
//    _salesHeader
//}


@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Order Item Consumption View'
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZCIT_SALES_OC 
  as projection on ZCIT_SALES_O
{
  key SalesDocument,
  key SalesItemnumber,
      @Search.defaultSearchElement: true
      Material,
      Plant,
      @Semantics.quantity.unitOfMeasure: 'Quantityunits'
      Quantity,
      Quantityunits,
    @Semantics.amount.currencyCode: 'Currency'   
      NetPrice,
      Currency,
      
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      
      /* Associations */
      // This links back to the Header Consumption View
      _salesHeader : redirected to parent ZCIT_SALES_C
}
