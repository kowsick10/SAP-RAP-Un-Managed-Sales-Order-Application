//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'Root Interface View for Header'
//@Metadata.ignorePropagatedAnnotations: true
//define root view entity ZCIT_SALES_I as select from ZCIT_HEADER
//composition of target_data_source_name as _association_name
//{
//    key salesdocument as Salesdocument,
//    salesdocumenttype as Salesdocumenttype,
//    orderreason as Orderreason,
//    salesorganization as Salesorganization,
//    distributionchannel as Distributionchannel,
//    division as Division,
//    salesoffice as Salesoffice,
//    salesgroup as Salesgroup,
//    netprice as Netprice,
//    currency as Currency,
//    local_created_by as LocalCreatedBy,
//    local_created_at as LocalCreatedAt,
//    local_last_changed_by as LocalLastChangedBy,
//    local_last_changed_at as LocalLastChangedAt,
//    last_changed_at as LastChangedAt,
//    _association_name // Make association public
//}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Interface View for the Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_SALES_I 
  as select from zcit_header as salesHeader
  composition [0..*] of ZCIT_SALES_O as _salesitem
{
  key salesdocument       as SalesDocument,
      salesdocumenttype   as SalesDocumentType,
      orderreason         as OrderReason,
      salesorganization   as SalesOrganization,
      distributionchannel as DistributionChannel,
      division            as Division,
      salesoffice         as SalesOffice,
      salesgroup          as SalesGroup,
      
      @Semantics.amount.currencyCode: 'Currency'
      netprice            as NetPrice,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Currency', element: 'Currency' } }]
      currency            as Currency,

      /* --- NEW FIELDS FOR FILE UPLOAD --- */
      @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'Filename',
        contentDispositionPreference: #ATTACHMENT
      }
      attachment          as Attachment,

      @Semantics.mimeType: true
      mimetype            as MimeType,

      filename            as Filename,
      /* ---------------------------------- */

      @Semantics.user.createdBy: true
      local_created_by    as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at    as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _salesitem
}
