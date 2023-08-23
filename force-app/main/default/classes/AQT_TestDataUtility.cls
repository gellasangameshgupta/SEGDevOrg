/*******************************************************************************************************
* 
* @ Name        :   AQT_TestDataUtility
* @ Purpose     :   Utility class for AQT module
* @ Author      :   Khushmeet Kaur
*
*   Date            |  Developer Name            |  Version      |  Changes
* ======================================================================================================
*   24-02-2022      |  Khushmeet.kaur@absyz.com  |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class AQT_TestDataUtility {
    public static Integer testDataSize = 1;
    
    @isTest
    public static Account getAccountObjectData() {
        Account objAccount = new Account(
            Name = 'TestAccount',
            ShippingStreet = 'TestShippingStreet',
            ShippingCity = 'TestShippingCity',
            ShippingState = 'TestShippingState',
            ShippingPostalCode = '123',
            ShippingCountry = 'TestShippingCountry',
            BillingStreet = 'TestBillingStreet',
            BillingCity = 'TestBillingCity',
            BillingState = 'TestBillingState',
            BillingPostalCode = '124',
            BillingCountry = 'TestBillingCountry'
        );
        insert objAccount;
        return objAccount;
    }
    
    @isTest
    public static AQT_Quote__c getQuoteObjectData() {
        
        AQT_Quote__c objQuote = new AQT_Quote__c();
        objQuote.NetAmount__c = 30;
        objQuote.Account__c = getAccountObjectData().Id;
        objQuote.TotalDiscount__c = 25;
        objQuote.TotalAmount__c = 150.90;
        objQuote.Version__c = 1;
        insert objQuote;
        return objQuote;
    }
    
    @isTest
    public static Product2 getProductObjectData() {
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'TestProduct';
        objProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('B2B Product').getRecordTypeId();
        objProduct.B2B_SEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_PreviousSEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_ProductType__c='STARTER';
        insert objProduct;
        return objProduct;
    }
    
     @isTest
    public static BuyerGroup getBuyerGroupData() {
        BuyerGroup objBuyerGroup = new BuyerGroup();
        objBuyerGroup.Name = 'TestBuyerGroup1';  
        insert objBuyerGroup;
        return objBuyerGroup;
    }
    
    @isTest
    public static BuyerGroupMember getBuyerGroupMemberData() {
        BuyerGroupMember objBuyerGroupMember = new BuyerGroupMember();
        obJBuyerGroupMember.BuyerGroupId = getBuyerGroupData().Id;
        obJBuyerGroupMember.BuyerId = getAccountObjectData().Id;
        insert objBuyerGroupMember;
        return objBuyerGroupMember;
    }
    
    @isTest
    public static Pricebook2 getBuyerGroupPricebook(){
        Pricebook2 objPriceBook = new Pricebook2();
        objPriceBook.Name = 'Buyer Price Book';
        objPriceBook.IsActive = true;
        insert objPriceBook;
        return objPriceBook;
    }
    
	@isTest
    public static Pricebook2 getStandardPriceBook(){
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        return standardPricebook;
    }    
    
    @isTest
    public static BuyerGroupPricebook getBuyerGroupPricebookRecord(){
        BuyerGroupPricebook objBuyerGroupPricebook = new BuyerGroupPricebook();
        objBuyerGroupPricebook.IsActive = true;
        objBuyerGroupPricebook.Pricebook2Id = getBuyerGroupPricebook().Id;
        objBuyerGroupPricebook.BuyerGroupId = getBuyerGroupData().Id;
        insert objBuyerGroupPricebook;
        return objBuyerGroupPricebook;
    }
    @isTest
    public static PricebookEntry getStandardPricebookRecord(){
        Id str_priceBookId = Test.getStandardPricebookId();
        PricebookEntry objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Pricebook2Id = getStandardPriceBook().Id;
        objPricebookEntry.Product2Id = getProductObjectData().Id;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        objPricebookEntry.UseStandardPrice = false;
        insert objPricebookEntry;
        return objPricebookEntry;
    }
    @isTest
    public static PricebookEntry getPricebookEntryRecord(){
        PricebookEntry objPricebookEntryBuyer = new PricebookEntry(
            Pricebook2Id = getStandardPriceBook().Id,
            Product2Id = getProductObjectData().Id,
            UnitPrice = 1,
            IsActive = true
        );
        insert objPricebookEntryBuyer;
        return objPricebookEntryBuyer;
    }
    
    
    @isTest
    public static AQT_QuoteLineItem__c getQuoteLineItemObjectData() {
        AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
        objQuoteLineItem.Quote__c = getQuoteObjectData().Id;
        objQuoteLineItem.Product__c = getProductObjectData().Id;
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
        insert objQuoteLineItem;
        return objQuoteLineItem;
    }
    
    @isTest
    public static Order getcreateOrderObjectData() {
        Order orderObj = new Order();
        orderObj.AccountId = '';
        orderObj.Status = 'Draft';
        insert orderObj;
        return orderObj;
    }
    
    @isTest
    public static IFv2_Request__c getRequestObjectData() {
        IFv2_Request__c requestObj = new IFv2_Request__c();
        requestObj.Account__c = '';
        requestObj.ArchivalStatus__c = 'Archived';
        insert requestObj;
        return requestObj;
    }
    
    @isTest
    public static Pricebook2 getPricebookObjectData() {
        Pricebook2 objPricebook2=new Pricebook2();
        objPricebook2.Id='';
        objPricebook2.Name='test';
        insert objPricebook2;
        return objPricebook2;
    }
    
    @isTest
    public static PricebookEntry getPricebookEntryData() {
        PricebookEntry priceBookEntryObj= new PricebookEntry();
        priceBookEntryObj.UnitPrice = 1;
        priceBookEntryObj.IsActive = true;
        priceBookEntryObj.UseStandardPrice = false;
        insert priceBookEntryObj;
        return priceBookEntryObj;
    }
    
   
    @isTest
    public static IFv2_Workflow__c getWorkflowData() {
        IFv2_Workflow__c objWorkflow = new IFv2_Workflow__c();
        objWorkflow.Name = 'Aftermarket Quotation Tool';
        objWorkflow.Workflow__c = 'Aftermarket Quotation Tool';
        objWorkflow.ApplicationKey__c = 'EUU';
        objWorkflow.ArchivingAfterDays__c = 180;
        objWorkflow.Category__c = 'All';
        objWorkflow.Active__c = true;
        insert objWorkflow;
        return objWorkflow;
    }
    
    public static list<IFv2_Request__c> getRequestData() {
        List<IFv2_Request__c> lstsObj = new list<IFv2_Request__c>();
        for (Integer i= 0; i < testDataSize; i++) {
            IFv2_Request__c obj = new IFv2_Request__c();
            obj.Status__c = 'Draft' ;
            lstsObj.add(obj);
        }   
        return lstsObj;
    }
}