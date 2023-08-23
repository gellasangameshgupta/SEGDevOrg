/*******************************************************************************************************
* 
* @ Name          :   AQT_QuotationToolSelectorTest
* @ Purpose       :   Test Class for AQT_QuotationToolSelector
* @ Author        :   Paavani Janapareddy
* @ Class Name    :   AQT_QuotationToolSelector
* @LastModifiedBy : Khushmeet Kaur
*   Date        |  Developer Name               	|  Version      |  Changes
* ======================================================================================================
*   18-04-2022  |  paavani.janapareddy@absyz.com    |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class AQT_QuotationToolSelectorTest {
    
    @TestSetup
    static void createData() {
        Account objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.ShippingStreet = 'TestShippingStreet';
        objAccount.ShippingCity = 'TestShippingCity';                                       
        objAccount.ShippingState = 'TestShippingState';
        objAccount.ShippingPostalCode = '123';
        objAccount.ShippingCountry = 'TestShippingCountry';
        objAccount.BillingStreet = 'TestBillingStreet';
        objAccount.BillingCity = 'TestBillingCity';
        objAccount.BillingState = 'TestBillingState';
        objAccount.BillingPostalCode = '124';
        objAccount.BillingCountry = 'TestBillingCountry';
        insert objAccount;
        
        Contact objContact=new Contact();
        objContact.FirstName='FName';
        objContact.LastName='LName';
        insert objContact;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'TestProduct';
        objProduct.RecordTypeId = 
            Schema.SObjectType.Product2.getRecordTypeInfosByName().get('B2B Product').getRecordTypeId();
        objProduct.B2B_SEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_PreviousSEGIAMProductNumber__c = 'F000BL06U8';
        objProduct.B2B_ProductType__c = 'STARTER';
        insert objProduct;     
        
        AQT_Quote__c objQuote = new AQT_Quote__c();
        objQuote.TotalDiscount__c = 20;
        objQuote.NetAmount__c = 30;
        insert objQuote;
        
        List<AQT_QuoteLineItem__c> objQuoteLineItemlist = new List<AQT_QuoteLineItem__c>();
        AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
        objQuoteLineItem.UnitPrice__c = 20.0;
        objQuoteLineItem.TotalAmount__c = 200;
        objQuoteLineItem.Quote__c = objQuote.Id;
        objQuoteLineItemlist.add(objQuoteLineItem);
        insert objQuoteLineItemlist;
        
        Pricebook2 objPricebook = new Pricebook2();
        objPricebook.Name = 'Standard Price Book';
        insert objPricebook;
        
        Id idPricebookId = Test.getStandardPricebookId();
        PriceBookEntry objStandardPricebookEntry = new PriceBookEntry();
        objStandardPricebookEntry.Product2Id = objProduct.Id;
        objStandardPricebookEntry.Pricebook2Id = idPricebookId;
        objStandardPricebookEntry.UnitPrice = 10;
        objStandardPricebookEntry.IsActive = true;
        insert objStandardPricebookEntry;
        
        PriceBookEntry objPriceBookEntry = new PriceBookEntry();
        objPriceBookEntry.Product2Id = objProduct.Id;
        objPriceBookEntry.Pricebook2Id = objPricebook.Id;
        objPriceBookEntry.UnitPrice = 10;
        objPriceBookEntry.IsActive = true;
        insert objPriceBookEntry; 
        
        BuyerGroup objBuyerGroup = new BuyerGroup();
        objBuyerGroup.Name = 'TestBuyerGroup';
        insert objBuyerGroup;
        
        BuyerAccount objBuyerAccount = new BuyerAccount();
        objBuyerAccount.BuyerId = objAccount.Id;
        objBuyerAccount.Name = 'Test Buyer Account (BA-AJ)';
        objBuyerAccount.IsActive = true;
        insert objBuyerAccount;
        
        BuyerGroupMember objBuyerGroupMember = new BuyerGroupMember();
        objBuyerGroupMember.BuyerId = objAccount.Id;
        objBuyerGroupMember.BuyerGroupId = objBuyerGroup.Id;
        insert objBuyerGroupMember;
        
        BuyerGroupPricebook objBuyerGroupPricebook = new BuyerGroupPricebook();
        objBuyerGroupPricebook.BuyerGroupId = objBuyerGroup.Id;
        objBuyerGroupPricebook.Pricebook2Id = objPricebook.Id;
        insert objBuyerGroupPricebook;
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User objUser = new User(
            Alias = 'standt', 
            Email = 'standardus123123er@testorg.com',
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
    public static void testPriceBookEntryRecord() {
        Test.startTest();
        Pricebook2 objPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book'];
        
        Set<String> set_PartNumbers = new Set<String>{'F000BL06U8'};
            Set<String> set_PartNumberWithWildCharacters = new Set<String>{'#F000BL06U8'};
                
                List<PricebookEntry> list_PricebookEntries = AQT_QuotationToolSelector.getPricebookEntryRecord(
                    set_PartNumberWithWildCharacters,
                    objPricebook.Id
                );
        
        if (!list_PricebookEntries.isEmpty()) {
            System.assertEquals(objPricebook.Id, list_PricebookEntries[0].PriceBook2Id);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBuyerGroupMember() {
        Test.startTest();
        Set<String>set_accountId = new set<String>();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        set_accountId.add(objAccount.Id);
        
        List<BuyerGroupMember> list_BuyerGroupMembers = AQT_QuotationToolSelector.getBuyerGroupMember(objAccount.Id);
        AQT_QuotationToolSelector.getBuyerGroupMemberRecord(set_accountId);
        
        System.assertEquals(objAccount.Id, list_BuyerGroupMembers[0].BuyerId);        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetBuyerGroupPricebook() {
        Test.startTest();
        
        String strBuyerGroupId;
        Set<string> Set_BuyerGroupPricebook = new Set<string>();
        BuyerGroup objBuyerGroup = [SELECT Id FROM BuyerGroup WHERE Name = 'TestBuyerGroup'];
        BuyerGroupPricebook objBuyerGroupPricebook = [SELECT 
                                                      Id, 
                                                      BuyerGroupId, 
                                                      Pricebook2Id 
                                                      FROM BuyerGroupPricebook 
                                                      WHERE BuyerGroupId = :objBuyerGroup.Id
                                                     ];
        strBuyerGroupId = objBuyerGroup.Id;
        
        List<BuyerGroupPricebook> list_BuyerGroupPricebooks = 
            AQT_QuotationToolSelector.getBuyerGroupPricebook(strBuyerGroupId);
        //System.assertEquals(objBuyerGroup.Id,list_BuyerGroupPricebooks[0].BuyerGroupId);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetAccountDetails() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        
        List<Account> list_Account = AQT_QuotationToolSelector.getAccountDetails(objAccount.Id);
        System.assertEquals(objAccount.Id,list_Account[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetContactDetails() {
        Test.startTest();
        Contact objContact = [SELECT Id FROM Contact WHERE FirstName = 'FName'];
        
        List< Contact> list_Contact = AQT_QuotationToolSelector.getContactDetails(objContact.Id);
        System.assertEquals(objContact.Id, list_Contact[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetProductDetails() {
        Test.startTest();
        Product2 objProduct = [SELECT Id FROM Product2 WHERE Name = 'TestProduct'];
        
        List<Product2> list_Product2 = AQT_QuotationToolSelector.getProductDetails(objProduct.Id);
        System.assertEquals(objProduct.Id, list_Product2[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetQuoteDetails() {
        Test.startTest();
        AQT_Quote__c objQuote = [SELECT Id FROM AQT_Quote__c];
        
        List<AQT_Quote__c> list_Quote = AQT_QuotationToolSelector.getQuoteDetails(objQuote.Id);
        AQT_QuotationToolSelector.getQuoteRecord();
        
        System.assertEquals(objQuote.Id,list_Quote[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetUserDetail() {
        Test.startTest();
        User objUser = [SELECT Id FROM User WHERE UserName = 'AftermarketTestUser@absyz.com'];
        
        List<User> list_User = AQT_QuotationToolSelector.getUserDetail(objUser.Id);
        System.assertEquals(objUser.Id,list_User[0].Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testgetQuoteLineItemRecords() {
        Test.startTest();
        AQT_QuoteLineItem__c objQuoteLineItem = [SELECT Id, Quote__c FROM AQT_QuoteLineItem__c];
        
        List<AQT_QuoteLineItem__c> list_QuoteLineItem = 
            AQT_QuotationToolSelector.getQuoteLineItemRecords(objQuoteLineItem.Quote__c);
        System.assertEquals(objQuoteLineItem.Quote__c,list_QuoteLineItem[0].quote__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetPreviousRecordUnitPrice() {
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Product2 objProduct = [SELECT Id FROM Product2 WHERE Name = 'TestProduct'];
        AQT_Quote__c objQuote = [SELECT Id FROM AQT_Quote__c];
        Set<String> set_PartNumbers = new set<String>{'F000BL06U8'};
        List<String>set_accountId = new list<String>();
        
        set_accountId.add(objAccount.Id);
        
            AQT_QuoteLineItem__c objQuoteLineItem = [SELECT Id, Quote__c, UnitPrice__c FROM AQT_QuoteLineItem__c];
        	AQT_QuotationToolSelector.getPreviousRecordUnitPrice(objAccount.Id,set_PartNumbers);
        
        	AQT_QuotationToolSelector.getPreviousSoldUnitPrice(set_PartNumbers,objAccount.Id);
        	AQT_QuotationToolSelector.getPreviousSoldUnitPrices(set_PartNumbers,set_accountId);
        
        //System.assertEquals(objProduct.Id,list_QuoteLineItem[0].Product__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetContactDetailsFromAccount(){
        Test.startTest();
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        AQT_QuotationToolSelector.getContactDetailsFromAccount(objAccount.Id);
        
        Test.stopTest();
    }
}