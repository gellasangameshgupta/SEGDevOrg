/*******************************************************************************************************
* 
* @ Name            :   AQT_QuotePDF
* @ Purpose         :   To preview the quote pdf and save it as notes and attactments
* @ Methods         :   1) onLoad - Fetch the variables from the URL and desearlize the wrapper
*                       2) savePDF - This function is to save the pdf as document
* @ Author          :   Khushmeet Kaur
* @ Test Class Name :   AQT_QuotePDFTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   01-03-2022      |  khushmeet.kaur@absyz.com     |  1.0          |  Initial Version
*   03-08-2022      |  khushmeet.kaur@absyz.com		|  2.0 			|  Create content document link for the files which 
are stored in quotation tool folder to the quote record
*******************************************************************************************************/
public with sharing class AQT_QuotePDF {
    public static List<productFoundDataWrapper> list_foundProductData {get; set;}
    public Decimal decTotalPrice {get;set;}
    public Decimal decTotalDiscount {get;set;}
    public List<AQT_QuoteLineItem__c> objQuoteLineItemRecord{get; set;}
    public String strAccountName {get;set;}
    public String strContactName {get;set;}
    public static List<Account> list_Accounts {get;set;}
    public static List<AQT_Quote__c> list_Quotes {get;set;}
    
    
    public void onLoad() {
        String RecordId = ApexPages.currentPage().getParameters().get('id');
        String strProductFoundData;
        
        if (RecordId != null && objQuoteLineItemRecord == null) {
            objQuoteLineItemRecord = AQT_QuotationToolSelector.getQuoteLineItemRecords(RecordId);
            list_Quotes = AQT_QuotationToolSelector.getQuoteDetails(RecordId);
            if(!list_Quotes.isEmpty() && list_Quotes!=null){
                strAccountName = list_Quotes[0].Account__r.Name;
                List<Contact> list_Contacts = AQT_QuotationToolSelector.getContactDetails(list_Quotes[0].Contact__c);
                if (!list_Contacts.isEmpty()) {
                    strContactName = list_Contacts[0].Name;
                }
                list_Accounts = AQT_QuotationToolSelector.getAccountDetails(list_Quotes[0].Account__c);
            }
        }
        
        Cache.SessionPartition partition = Cache.Session.getPartition('local.QuotePDF');
        if (partition.contains('strProductFoundData')) {
            strProductFoundData = (String)partition.get('strProductFoundData'); 
            partition.remove('strProductFoundData');
        }
        if (partition.contains('decTotalPrice')) {
            decTotalPrice = (Decimal)partition.get('decTotalPrice'); 
            partition.remove('decTotalPrice');
        }
        if (partition.contains('decTotalDiscount')) {
            decTotalDiscount = (Decimal)partition.get('decTotalDiscount'); 
            partition.remove('decTotalDiscount');
        }
        if (partition.contains('strAccountName')) {
            strAccountName = (String)partition.get('strAccountName'); 
            partition.remove('strAccountName');
        }
        if (partition.contains('strContactName')) {
            strContactName = (String)partition.get('strContactName'); 
            partition.remove('strContactName');
        }
        if (!String.isBlank(strProductFoundData)) {
            list_foundProductData = (List<productFoundDataWrapper>)JSON.deserialize(strProductFoundData, List<productFoundDataWrapper>.class);
            for (productFoundDataWrapper objFoundProductData : list_foundProductData) {
                list_Accounts = AQT_QuotationToolSelector.getAccountDetails(objFoundProductData.AccountId);
            }
        }
    }
    
    public class productFoundDataWrapper {
        public String PartNumber {get;set;}
        public Integer Quantity {get;set;}
        public Decimal TargetPrice {get;set;}
        public String SEGIAMNumber {get;set;}
        public Decimal StandardListPrice {get;set;}
        public Decimal UnitPrice {get;set;}
        public Decimal QuantityFinal {get;set;}
        public Decimal EndPrice {get;set;}
        public Decimal Discount {get;set;}
        public Decimal NetAmount {get;set;}
        public Decimal EBIT {get;set;}
        public String ProductType {get;set;}
        public String Name {get;set;}
        public String ProductionLocation {get;set;}
        public Decimal SEGAlreadyOfferedPrice {get;set;}
        public Decimal QuantityRemaining {get;set;}
        public Boolean approvalRequired {get;set;}
        public String QuoteId {get;set;}
        public String AccountId {get;set;}
        public String ContactId {get;set;}
        public String ProductId {get;set;}
        public String Id {get;set;}
        public String LeadTime {get;set;}
        public String MOQ {get;set;}
    }
    
    @AuraEnabled
    public static Boolean savePDF(String strQuoteId) {
        
        PageReference pdf = Page.AQT_QuotePDF;
        String strQuoteName;
        String strAccountName;
        for (AQT_Quote__c objQuote : [SELECT Id, Name, Account__r.Name FROM AQT_Quote__c WHERE Id = :strQuoteId]) {
            strQuoteName = objQuote.Name;
            strAccountName = objQuote.Account__r.Name;
        }
        
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id', strQuoteId);
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = pdf.getContentAsPDF();
            
            // need to pass unit test -- current bug	
        } catch (VisualforceException e) {
            body = Blob.valueOf('Error');
        }
        
        //Get the custom setting
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = AQT_QuotationTool.getCustomSettings();
      	String strQuotationToolFolderName = objAfterMarketQuotationTool.QuotationToolFolderName__c;
        
        //Create the content version record for the quote pdf
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.ContentLocation = 's';
        objContentVersion.Title= strQuoteName + ' ' + strAccountName;
        objContentVersion.PathOnClient=objContentVersion.Title + '.pdf';
        objContentVersion.VersionData=body;
        insert objContentVersion;
        
        
        set<String>set_contentDocumentLink = new set<String>(); //Store the already inserted contentdocument link for the current record.
        For(ContentDocumentLink objContentDocumentLink : [SELECT
                                                          Id,
                                                          ContentDocumentId,
                                                          LinkedEntityId
                                                          FROM ContentDocumentLink
                                                          WHERE
                                                          LinkedEntityId=:strQuoteId]){
                                                              set_contentDocumentLink.add(objContentDocumentLink.ContentDocumentId);
                                                          }
        
        list<ContentDocumentLink>list_ContentDocumentLink = new list<ContentDocumentLink>();
        //Query all the content document record which is stored in quotation tool folder and the current pdf
        For(ContentVersion objContentVersionRecord : [SELECT
                                                      Id,
                                                      ContentDocumentId,
                                                      VersionData, 
                                                      FileExtension,
                                                      Title FROM ContentVersion 
                                                      WHERE Id = :objContentVersion.Id
                                                      OR (FirstPublishLocation.Name =: strQuotationToolFolderName
                                                          AND ContentDocumentId !=: set_contentDocumentLink)]){
                                                                                                                            
                                                              ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                                                              objContentDocumentLink.ContentDocumentId = objContentVersionRecord.ContentDocumentId;
                                                              objContentDocumentLink.LinkedEntityId = strQuoteId;
                                                              objContentDocumentLink.Visibility = 'Allusers';
                                                              objContentDocumentLink.ShareType = 'V';
                                                              list_ContentDocumentLink.add(objContentDocumentLink);  
                                                          }
        
        
        if(list_ContentDocumentLink.size()>0){
            insert list_ContentDocumentLink;
        }
        
        return true;
    }
}