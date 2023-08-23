/*******************************************************************************************************
* 
* @ Name        :   AQT_QuotationToolTest
* @ Purpose     :   Test Class for AQT_QuotationTool
* @ Author      :   Sravani Makkena
* @ Class Name  :   AQT_QuotationTool
*
*   Date        |  Developer Name                   |  Version      |  Changes
* ======================================================================================================
*   19-04-2022  |  sravani.makkena@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

@isTest
public class AQT_QuotationToolTest {
    
    @TestSetup
    static void createData() {
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
        
        List<AQT_Quote__c> objListQuote = new List<AQT_Quote__c>();
        AQT_Quote__c objQuote = new AQT_Quote__c();
        objQuote.NetAmount__c = 30;
        objQuote.Account__c = objAccount.Id;
        objQuote.Contact__c = objContact.Id;
        objQuote.TotalDiscount__c = 25;
        objQuote.TotalAmount__c = 150.90;
        objQuote.Version__c = 1;
        objListQuote.add(objQuote);
        insert objListQuote;
        
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.Title = 'Test Document';
        objContentVersion.PathOnClient = 'TestDocument.pdf';
        objContentVersion.VersionData = Blob.valueOf('Test Content');
        objContentVersion.IsMajorVersion = true;
        insert objContentVersion;
        
        //Get Content Documents
        List<ContentDocument> docList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink objContentDocumentLink = New ContentDocumentLink();
        objContentDocumentLink.LinkedEntityId = objQuote.Id;
        objContentDocumentLink.ContentDocumentId = docList[0].Id;
        objContentDocumentLink.Visibility='Allusers';
        
        objContentDocumentLink.shareType = 'V';
        insert objContentDocumentLink;
        
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = new AQT_AftermarketQuotationToolSetup__c();
        objAfterMarketQuotationTool.QuoteDiscountThreshold__c = 20;
        objAfterMarketQuotationTool.EBITPercentage__c = 14.4;
        insert objAfterMarketQuotationTool;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'TestProduct';
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('B2B Product').getRecordTypeId();
        objProduct.B2B_SEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_PreviousSEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_ProductType__c='STARTER';
        insert objProduct;
        
        BuyerGroup objBuyerGroup = new BuyerGroup();
        objBuyerGroup.Name = 'TestBuyerGroup1';  
        insert objBuyerGroup;
        
        BuyerGroupMember objBuyerGroupMember = new BuyerGroupMember();
        obJBuyerGroupMember.BuyerGroupId = objBuyerGroup.Id;
        obJBuyerGroupMember.BuyerId = objAccount.Id;
        insert obJBuyerGroupMember;
        
        Pricebook2 objPriceBook = new Pricebook2();
        objPriceBook.Name = 'Buyer Price Book';
        objPriceBook.IsActive = true;
        insert objPriceBook;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;    
        
        BuyerGroupPricebook objBuyerGroupPricebook = new BuyerGroupPricebook();
        objBuyerGroupPricebook.IsActive = true;
        objBuyerGroupPricebook.Pricebook2Id = objPriceBook.Id;
        objBuyerGroupPricebook.BuyerGroupId = objBuyerGroup.Id;
        insert objBuyerGroupPricebook;
        
        Id str_priceBookId = Test.getStandardPricebookId();
        PricebookEntry objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Pricebook2Id = standardPricebook.Id;
        objPricebookEntry.Product2Id = objProduct.Id;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        objPricebookEntry.UseStandardPrice = false;
        insert objPricebookEntry;
        
        PricebookEntry objPricebookEntryBuyer = new PricebookEntry(
            Pricebook2Id = objPriceBook.Id,
            Product2Id = objProduct.Id,
            UnitPrice = 1,
            IsActive = true
        );
        insert objPricebookEntryBuyer;
        
        IFv2_Workflow__c objWorkflow = new IFv2_Workflow__c();
        objWorkflow.Name = 'Aftermarket Quotation Tool';
        objWorkflow.Workflow__c = 'Aftermarket Quotation Tool';
        objWorkflow.ApplicationKey__c = 'EUU';
        objWorkflow.ArchivingAfterDays__c = 180;
        objWorkflow.Category__c = 'All';
        objWorkflow.Active__c = true;
        insert objWorkflow;
        
        list<IFv2_Request__c> list_Request = new list<IFv2_Request__c>();
        IFv2_Request__c objRequest = new IFv2_Request__c();
        objRequest.RequestorName__c = 'sravani';
        objRequest.AQT_Discount__c = 20;
        list_Request.add(objRequest);
        insert list_Request;
        
        List<AQT_QuoteLineItem__c> objListQuoteLineItems = new List<AQT_QuoteLineItem__c>();
        AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
        objQuoteLineItem.Quote__c = objQuote.Id;
        objQuoteLineItem.Product__c = objProduct.Id;
        objQuoteLineItem.TotalAmount__c = 350.00;
        objQuoteLineItem.UnitPrice__c = 14.4;
        objQuoteLineItem.Quantity__c = 1;
        objQuoteLineItem.Discount__c = 0;
        objQuoteLineItem.CustomerTargetPrice__c = 2.00;
        objQuoteLineItem.StandardListPrice__c = 55.00;
        objQuoteLineItem.EndPrice__c = 60.00;
        objQuoteLineItem.TotalAmount__c = 14.4;
        objQuoteLineItem.EBIT__c = 3.00;
        objQuoteLineItem.LeadTime__c = 2.00;
        objQuoteLineItem.MOQ__c = 2.00;
        objQuoteLineItem.QuantityRequested__c = 2.00;
        objQuoteLineItem.Partnumber__c = 'F000BL06U8';
        objListQuoteLineItems.add(objQuoteLineItem);
        insert objListQuoteLineItems;
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User objUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'TestUser', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = objProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'AftermarketTestUser@absyz.com'
        );
        insert objUser;
    }
    
    @isTest
    static void testgetCustomSettings() {
        Test.startTest();
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = AQT_QuotationTool.getCustomSettings();
        Test.stopTest();
        System.assertEquals(20, objAfterMarketQuotationTool.QuoteDiscountThreshold__c);
    }
    
    @isTest
    static void testProcessExcelUploadFile() {
        Test.startTest();
        AQT_QuotationTool.processExcelUploadFileWrapper processExcelFilesWrapper=new AQT_QuotationTool.processExcelUploadFileWrapper();
        processExcelFilesWrapper.Partnumber='F000BL06U8';
        processExcelFilesWrapper.Quantity=20;
        processExcelFilesWrapper.TargetPrice=25;
        List<AQT_QuotationTool.processExcelUploadFileWrapper> list_processExcelUploadFileWrapper = AQT_QuotationTool.processExcelUploadFile('[{"Partnumber":"F000BL06U8","TargetPrice":20,"Quantity":25}]');
        Test.stopTest();
        System.assertEquals(list_processExcelUploadFileWrapper[0].Partnumber,'F000BL06U8');
    }
    
    @isTest
    public static void testSearchProducts() {
        AQT_QuotationTool.productNotFoundData wrapper_productNotFoundData = new AQT_QuotationTool.productNotFoundData();
        wrapper_productNotFoundData.PartNumber = 'F000BL0698';
        wrapper_productNotFoundData.Quantity = 2;
        wrapper_productNotFoundData.TargetPrice = 35;
        wrapper_productNotFoundData.Comment = 'Data';
        
        AQT_QuotationTool.productFoundData wrapper_productFoundData = new AQT_QuotationTool.productFoundData();
        wrapper_productFoundData.PartNumber = 'F000BL06U8';
        wrapper_productFoundData.Quantity = 1;
        wrapper_productFoundData.TargetPrice = 35;
        wrapper_productFoundData.SEGIAMNumber = 'F000BL06U8';
        wrapper_productFoundData.StandardListPrice = 101;
        wrapper_productFoundData.UnitPrice = 101;
        wrapper_productFoundData.QuantityFinal = 1;
        wrapper_productFoundData.EndPrice = 200;
        wrapper_productFoundData.Discount = 0;
        wrapper_productFoundData.NetAmount = 1011;
        wrapper_productFoundData.EBIT = 1.3;
        wrapper_productFoundData.ProductType = '';
        wrapper_productFoundData.Name = '';
        wrapper_productFoundData.ProductionLocation = 'Germany';
        wrapper_productFoundData.SEGAlreadyOfferedPrice = 101;
        wrapper_productFoundData.QuantityRemaining = 10;
        wrapper_productFoundData.approvalRequired = false;
        wrapper_productFoundData.ProductId = '';
        wrapper_productFoundData.Id = '';
        wrapper_productFoundData.LeadTime = 120;
        wrapper_productFoundData.MOQ = 10;        
        
        Test.startTest();
        
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact objContact = [SELECT Id,Name FROM Contact WHERE AccountId =: objAccount.Id];
        Product2 objProduct= [SELECT Id, Name from Product2 WHERE Name = 'TestProduct'];
        AQT_Quote__c objQuote = [SELECT Id, Account__c, TotalDiscount__c, TotalAmount__c, NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        
        wrapper_productFoundData.QuoteId = objQuote.Id;
        wrapper_productFoundData.AccountId = objAccount.Id;
        wrapper_productFoundData.ContactId = objAccount.Id;
        
        List<AQT_QuoteLineItem__c> list_QuoteLineItem = [SELECT Id, Quote__c, UnitPrice__c, TotalAmount__c FROM AQT_QuoteLineItem__c WHERE Quote__c = :objQuote.id];
        AQT_QuotationTool.searchProducts(objAccount.Id, objContact.Id, '[{"PartNumber":"F000BL06U8","Quantity":2,"TargetPrice":35,"AccountId":"'+objAccount.Id+'","ProductId":"'+objProduct.Id+'","StandardListPrice":"200.00","SEGIAMNumber":"F000BL06U8","UnitPrice":10.00,"SEGAlreadyOfferedPrice":25.00,"QuantityFinal":10,"Discount":5.00,"EndPrice":100.00,"EBIT":25.00,"ProductType":"","Name":"F000BL06U8","ProductionLocation":"xyz","LeadTime":"","MOQ":"","RecommendedPrice":50.00,"approvalRequired":true}]', objProduct.Id);
        AQT_QuotationTool.searchProducts(objAccount.Id, objContact.Id, '[{"PartNumber":"F000BL0698","Quantity":2,"TargetPrice":35,"AccountId":"'+objAccount.Id+'","ProductId":"'+objProduct.Id+'","StandardListPrice":"200.00","SEGIAMNumber":"F000BL06U8","UnitPrice":10.00,"SEGAlreadyOfferedPrice":25.00,"QuantityFinal":10,"Discount":5.00,"EndPrice":30.00,"EBIT":25.00,"ProductType":"","Name":"F000BL06U8","ProductionLocation":"xyz","LeadTime":"","MOQ":"","RecommendedPrice":50.00,"approvalRequired":true}]', objProduct.Id);
        
        Test.stopTest();
        System.assertEquals(wrapper_productNotFoundData.PartNumber, 'F000BL0698');
    }
    
    @isTest
    public static void testCreateQuoteRecord() {
        AQT_QuotationTool.productNotFoundData objProductNotFoundData = new AQT_QuotationTool.productNotFoundData();
        objProductNotFoundData.PartNumber = 'F000BL0698';
        objProductNotFoundData.Quantity = 2;
        objProductNotFoundData.TargetPrice = 35.00;
        objProductNotFoundData.Comment = 'Data';
        List<AQT_QuotationTool.productNotFoundData> list_ProductNotFoundData = new List<AQT_QuotationTool.productNotFoundData>();
        list_ProductNotFoundData.add(objProductNotFoundData);
        
        AQT_QuotationTool.productFoundData objProductFoundData = new AQT_QuotationTool.productFoundData();
        objProductFoundData.PartNumber = 'F000BL06U8';
        objProductFoundData.Quantity = 1;
        objProductFoundData.TargetPrice = 35.00;
        objProductFoundData.SEGIAMNumber = 'F000BL06U8';
        objProductFoundData.StandardListPrice = 101.00;
        objProductFoundData.UnitPrice = 101.00;
        objProductFoundData.QuantityFinal = 1.00;
        objProductFoundData.EndPrice = 200.00;
        objProductFoundData.Discount = 0;
        objProductFoundData.NetAmount = 1011.00;
        objProductFoundData.EBIT = 1.3;
        objProductFoundData.ProductType = 'STARTER';
        objProductFoundData.Name = 'F000BL06U8';
        objProductFoundData.ProductionLocation = 'Germany';
        objProductFoundData.SEGAlreadyOfferedPrice = 101.00;
        objProductFoundData.QuantityRemaining = 10.00;
        objProductFoundData.approvalRequired = false;
        objProductFoundData.LeadTime = 120.00;
        objProductFoundData.MOQ = 10.00;
        List<AQT_QuotationTool.productFoundData> list_ProductFoundData = new List<AQT_QuotationTool.productFoundData>();
        list_ProductFoundData.add(objProductFoundData);
        
        AQT_QuotationTool.QuoteDetail objQuoteDetail = new AQT_QuotationTool.QuoteDetail();
        objQuoteDetail.strProductFoundDataWrapper = JSON.serialize(list_ProductFoundData);
        objQuoteDetail.strProductNotFoundWrapper = JSON.serialize(list_ProductNotFoundData);
        objQuoteDetail.blnCreateRequestRecord = true;
        objQuoteDetail.decTotalAmount = 1011.00;
        objQuoteDetail.decTotalDiscount = 0.00;
        objQuoteDetail.decNetAmount = 1011.00;
        
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact objContact = [SELECT Id FROM Contact WHERE AccountId = :objAccount.Id];
        objQuoteDetail.strAccountId = objAccount.Id;
        objQuoteDetail.strContactId = objContact.Id;
        
        AQT_QuotationTool.returnCreatedRecords quoteRecord = AQT_QuotationTool.createQuoteRecord(JSON.serialize(objQuoteDetail));
        Test.stopTest();
        //   System.assertEquals(objRequest.RequestorName__c,'sravani');
    }
    
    @isTest
    public static void testcreateRequests() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact objContact = [SELECT Id, Name FROM Contact WHERE AccountId =: objAccount.Id];
        
        IFv2_Workflow__c objWorkflow = [SELECT Id, Name FROM IFv2_Workflow__c WHERE Name = 'Aftermarket Quotation Tool'];
        list<IFv2_Request__c> list_Request = new list<IFv2_Request__c>();
        IFv2_Request__c objRequest = [SELECT Id, RequestorName__c FROM IFv2_Request__c WHERE RequestorName__c = 'sravani'];
        List<AQT_Quote__c> objListQuote = [SELECT Id, Account__c, TotalDiscount__c, TotalAmount__c, NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        AQT_QuotationTool.createRequests(objListQuote,objAccount.Id, objContact.Id);
        Test.stopTest();
        list< IFv2_Request__c> list_objRequestAfterInsert = [SELECT Id, RequestorName__c FROM IFv2_Request__c];
        System.assert(list_objRequestAfterInsert.size() > 1);
    }
    
    @isTest
    public static void testfetchQuoteLineItemRecords() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        AQT_Quote__c objQuote= [SELECT Id, Account__c, TotalDiscount__c, TotalAmount__c, NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        List<AQT_QuotationTool.productFoundData> list_productFoundDataWrapper = AQT_QuotationTool.fetchQuoteLineItemRecords(objQuote.Id);
        Test.stopTest();
        system.assertEquals(list_productFoundDataWrapper[0].PartNumber, 'F000BL06U8');
    }
    
    @isTest
    public static void testdeleteQuoteLineItem() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        AQT_Quote__c objQuote= [SELECT Id, Account__c, TotalDiscount__c, TotalAmount__c, NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        List<AQT_QuoteLineItem__c> objListQuoteLineItem = [SELECT Id, Quote__c, TotalAmount__c FROM AQT_QuoteLineItem__c WHERE Quote__c = :objQuote.Id];
        AQT_QuotationTool.deleteQuoteLineItem(objListQuoteLineItem);
        Test.stopTest();
        List<AQT_QuoteLineItem__c> objListQuoteLineItemAfterDelete = [SELECT Id, Quote__c, TotalAmount__c FROM AQT_QuoteLineItem__c WHERE Quote__c = :objQuote.Id];
        System.assertEquals(0, objListQuoteLineItemAfterDelete.size());
    }
    
    @isTest
    public static void testsubmitForApproval() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        AQT_Quote__c objQuote= [SELECT Id,Account__c,TotalDiscount__c,TotalAmount__c,NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        Boolean result=AQT_QuotationTool.submitForApproval(objQuote.Id);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    
    @isTest
    public static void testupdateQuoteLineItemRecords() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact objContact = [SELECT Id FROM Contact WHERE AccountId =: objAccount.Id];
        Product2 objProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'TestProduct'];
        AQT_Quote__c objQuote = [SELECT Id,Account__c,TotalDiscount__c,TotalAmount__c,NetAmount__c FROM AQT_Quote__c WHERE Account__c =: objAccount.Id];
        list<AQT_Quote__c> list_objQuote= [SELECT Id,Account__c,TotalDiscount__c,TotalAmount__c,NetAmount__c FROM AQT_Quote__c];
        list<AQT_QuoteLineItem__c> list_objQuoteLineItem = [SELECT Id,Quote__c,TotalAmount__c FROM AQT_QuoteLineItem__c WHERE Quote__c = :objQuote.id];
        AQT_QuotationTool.returnCreatedRecords quoteRecord = AQT_QuotationTool.updateQuoteLineItemRecords('[{"PartNumber":"F000BL06U8","Quantity":2,"TargetPrice":35.00,"SEGIAMNumber":"F000BL06U8","StandardListPrice":250.00,"UnitPrice":10.00,"QuantityFinal":10.00,"EndPrice":10.00,"Discount":5.00,"NetAmount":30.00,"EBIT":25.00,"ProductType":"","Name":"F000BL06U8","ProductionLocation":"xyz","SEGAlreadyOfferedPrice":20.00,"QuantityRemaining":20.00,"approvalRequired":true,"QuoteId":"'+objQuote.Id+'","AccountId":"'+objAccount.Id+'","ContactId":"'+objContact.Id+'","ProductId":"'+objProduct.Id+'","LeadTime":2.00,"MOQ":2.00,"Id":"'+list_objQuoteLineItem[0].Id+'"}]',1000,10,FALSE);
        AQT_QuotationTool.returnCreatedRecords quoteRecordData = AQT_QuotationTool.updateQuoteLineItemRecords('[{"PartNumber":"F000BL06U8","Quantity":2,"TargetPrice":35.00,"SEGIAMNumber":"F000BL06U8","StandardListPrice":250.00,"UnitPrice":10.00,"QuantityFinal":10.00,"EndPrice":10.00,"Discount":5.00,"NetAmount":30.00,"EBIT":25.00,"ProductType":"","Name":"F000BL06U8","ProductionLocation":"xyz","SEGAlreadyOfferedPrice":20.00,"QuantityRemaining":20.00,"approvalRequired":true,"QuoteId":"'+objQuote.Id+'","AccountId":"'+objAccount.Id+'","ContactId":"'+objContact.Id+'","ProductId":"'+objProduct.Id+'","LeadTime":2.00,"MOQ":2.00,"Id":"'+list_objQuoteLineItem[0].Id+'"}]',1000,10,FALSE);
        Test.stopTest();
        //  System.assertEquals(true, result);
    }
    
    @isTest
    public static void testQuotePDFCacheStore() {
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Contact objContact = [SELECT Id FROM Contact WHERE AccountId =: objAccount.Id];
        
        AQT_QuotationTool.productFoundData objProductFoundData = new AQT_QuotationTool.productFoundData();
        objProductFoundData.PartNumber = 'F000BL06U8';
        objProductFoundData.Quantity = 1;
        objProductFoundData.TargetPrice = 35;
        objProductFoundData.SEGIAMNumber = 'F000BL06U8';
        objProductFoundData.StandardListPrice = 101;
        objProductFoundData.UnitPrice = 101;
        objProductFoundData.QuantityFinal = 1;
        objProductFoundData.EndPrice = 200;
        objProductFoundData.Discount = 0;
        objProductFoundData.NetAmount = 1011;
        objProductFoundData.EBIT = 1.3;
        objProductFoundData.ProductType = '';
        objProductFoundData.Name = '';
        objProductFoundData.ProductionLocation = 'Germany';
        objProductFoundData.SEGAlreadyOfferedPrice = 101;
        objProductFoundData.QuantityRemaining = 10;
        objProductFoundData.approvalRequired = false;
        objProductFoundData.ProductId = '';
        objProductFoundData.Id = '';
        objProductFoundData.LeadTime = 120;
        objProductFoundData.MOQ = 10; 
        
        Boolean blnResult = 
            AQT_QuotationTool.quotePDFCacheStore
            ('[{"PartNumber":"F000BL06U8","Quantity":2,"TargetPrice":35.00,"SEGIAMNumber":"F000BL06U8","StandardListPrice":250.00,"UnitPrice":10.00,"QuantityFinal":10.00,"EndPrice":10.00,"Discount":5.00,"NetAmount":30.00,"EBIT":25.00,"ProductType":"","Name":"F000BL06U8","ProductionLocation":"xyz","SEGAlreadyOfferedPrice":20.00,"QuantityRemaining":20.00,"approvalRequired":true',
             200,
             200,
             objAccount.Id,
             objContact.Id);
        System.assertEquals(true, blnResult);
    }
}