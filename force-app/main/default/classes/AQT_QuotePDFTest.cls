/*******************************************************************************************************
* 
* @ Name        :   AQT_QuotePDFTest
* @ Purpose     :   Test Class for AQT_QuotePDF
* @ Author      :   Paavani Janapareddy
* @ Class Name  :   AQT_QuotePDF
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   08-04-2022  |  paavani.janapareddy@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class AQT_QuotePDFTest {
    
    @TestSetup
    static void createData() {
        
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = new AQT_AftermarketQuotationToolSetup__c();
       	objAfterMarketQuotationTool.QuotationToolFolderName__c = 'Quotation Tool Files';
        insert objAfterMarketQuotationTool;
        
        Product2 objProduct = aqt_testDataUtility.getProductObjectData();
        
        Account objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Plant__c = 'HiP';
        insert objAccount;
        
        B2B_ContactSetupAssistantController.enableBuyerAccount(objAccount.Id, 'TestName');
        
        Contact objContact = new Contact();
        objContact.FirstName = 'FName';
        objContact.LastName = 'LName';
        objContact.AccountId = objAccount.Id;
        insert objContact;
        
        AQT_Quote__c objQuote = new AQT_Quote__c();
        objQuote.TotalDiscount__c = 20;
        objQuote.NetAmount__c = 30;
        objQuote.Account__c = objAccount.Id;
        objQuote.Contact__c = objContact.Id;
        insert objQuote;
        
        AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
        objQuoteLineItem.TotalAmount__c = 200;
        objQuoteLineItem.Quote__c = objQuote.Id;
        insert objQuoteLineItem;
        
        AQT_QuotePDF.productFoundDataWrapper objProductFoundDataWrapper = new AQT_QuotePDF.productFoundDataWrapper();
        objProductFoundDataWrapper.Quantity = 2; 
        objProductFoundDataWrapper.Discount = 20.00;
        objProductFoundDataWrapper.ProductType = 'ALTERNATOR';
        objProductFoundDataWrapper.TargetPrice = 200;
        objProductFoundDataWrapper.PartNumber = '';
        objProductFoundDataWrapper.Name = '';					
        objProductFoundDataWrapper.ProductionLocation = '';
        objProductFoundDataWrapper.LeadTime = '';
        objProductFoundDataWrapper.MOQ = '';
        objProductFoundDataWrapper.approvalRequired = true;
        objProductFoundDataWrapper.SEGIAMNumber = '';
        objProductFoundDataWrapper.UnitPrice = 20.00;
        objProductFoundDataWrapper.EndPrice = 10;
        objProductFoundDataWrapper.EBIT = 20;
        objProductFoundDataWrapper.QuantityFinal = 2;
        objProductFoundDataWrapper.ProductId = '';
        objProductFoundDataWrapper.AccountId = '';
        objProductFoundDataWrapper.SEGAlreadyOfferedPrice = 20;
        objProductFoundDataWrapper.StandardListPrice  = 200;
        objProductFoundDataWrapper.NetAmount = 200;
        objProductFoundDataWrapper.QuantityRemaining = 100;
        objProductFoundDataWrapper.QuoteId = '';
        objProductFoundDataWrapper.ContactId = '';
        objProductFoundDataWrapper.Id = '';
        
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.Title = 'Test Document';
        objContentVersion.PathOnClient = 'TestDocument.pdf';
        objContentVersion.VersionData = Blob.valueOf('Test Content');
        objContentVersion.IsMajorVersion = true;
        insert objContentVersion;
        
        //Get Content Documents
        List<ContentDocument> list_ContentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink objContentDocumentLink = New ContentDocumentLink();
        objContentDocumentLink.LinkedEntityId = objQuote.Id;
        objContentDocumentLink.ContentDocumentId = list_ContentDocuments[0].Id;
        objContentDocumentLink.Visibility = 'Allusers';
        objContentDocumentLink.shareType = 'V';
        insert objContentDocumentLink;
        
        
        ContentVersion objContentVersionRecord = new ContentVersion();
        objContentVersionRecord.Title = 'Test Document';
        objContentVersionRecord.PathOnClient = 'TestDocument.pdf';
        objContentVersionRecord.VersionData = Blob.valueOf('Test Content');
        objContentVersionRecord.IsMajorVersion = true;
        insert objContentVersionRecord;
    }
    
    @isTest
    public static void testonLoad() {
        Test.startTest();
        AQT_Quote__c objQuote = [SELECT Id FROM AQT_Quote__c];
        AQT_QuoteLineItem__c objQuoteLineItem = [SELECT Id FROM AQT_QuoteLineItem__c];

        Test.setCurrentPage(Page.aqt_quotePDF);
        AQT_QuotePDF objQuotePDF = new AQT_QuotePDF();
        
        ApexPages.currentPage().getParameters().put('id', objQuote.Id);
        objQuotePDF.onLoad();
        Test.stopTest();
    }
    
    @isTest
    public static void testsavePDF() {
        Test.startTest();
        AQT_Quote__c objQuote = [SELECT Id FROM AQT_Quote__c];
        Boolean result = AQT_QuotePDF.savePDF(objQuote.Id);
        Test.stopTest();
        System.assertEquals(true, result);
    }
}