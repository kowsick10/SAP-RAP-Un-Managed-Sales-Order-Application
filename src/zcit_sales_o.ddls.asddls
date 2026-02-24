//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Child Interface View for Item'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZCIT_SALES_O as select from ZCIT_ITM
//{
//    key salesdocument as Salesdocument,
//    key salesitemnumber as Salesitemnumber,
//    material as Material,
//    plant as Plant,
//    quantity as Quantity,
//    quantityunits as Quantityunits,
//    local_created_by as LocalCreatedBy,
//    local_created_at as LocalCreatedAt,
//    local_last_changed_by as LocalLastChangedBy,
//    local_last_changed_at as LocalLastChangedAt,
//    last_changed_at as LastChangedAt
//}


@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Child Interface View for the Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZCIT_SALES_O
  as select from zcit_itm
  association to parent ZCIT_SALES_I as _salesHeader 
    on $projection.SalesDocument = _salesHeader.SalesDocument
{
  key salesdocument         as SalesDocument,
  key salesitemnumber       as SalesItemnumber,
      material              as Material,
      plant                 as Plant,
      @Semantics.quantity.unitOfMeasure: 'Quantityunits'
      quantity              as Quantity,
      quantityunits         as Quantityunits,
      @Semantics.amount.currencyCode: 'Currency'
      netprice as NetPrice,
      currency as Currency,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      /* Associations */
       _salesHeader
}
