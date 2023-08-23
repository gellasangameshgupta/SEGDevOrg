/*******************************************************************************************************
* 
* @ Name        :   AQT_CreateOrderSummaryBatchTest
* @ Purpose     :   Test Class for AQT_CreateOrderBatch
* @ Author      :   Khushmeet Kaur
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   01-08-2022  |  Khushmeet.kaur@absyz.com    |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest(SeeAllData = true)
public class AQT_CreateOrderSummaryBatchTest {
   
    @isTest
    public static void createOrderFromQuoteTest() {
        Test.startTest();
        List<OrderItem> list_UpdatedOrderItems = new List<OrderItem>();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2();
        objProduct.Name = 'Test Product';
        objProduct.Description = 'Test Product Entry 1';
        objProduct.ProductCode = 'ABC';
        objProduct.B2B_SEGIAMProductNumber__c = '56789';
        objProduct.IsActive = true;
        list_Products.add(objProduct);
        insert list_Products;
        
        Id idPricebookId = Test.getStandardPricebookId();
        
        // Insert PricebookEntry
        PricebookEntry objPricebookEntry = new PricebookEntry();
        objPricebookEntry.Pricebook2Id = idPricebookId;
        objPricebookEntry.Product2Id = objProduct.Id;
        objPricebookEntry.UnitPrice = 1;
        objPricebookEntry.IsActive = true;
        objPricebookEntry.UseStandardPrice = false;
        insert objPricebookEntry;
        
        List<AQT_Quote__c> list_Quotes = new List<AQT_Quote__c>();
        AQT_Quote__c objQuote = new AQT_Quote__c();
        objQuote.NetAmount__c = 30;
        objQuote.Account__c = objAccount.Id;
        objQuote.TotalDiscount__c = 25;
        objQuote.TotalAmount__c = 150.90;
        objQuote.Version__c = 1;
        list_Quotes.add(objQuote);
        insert list_Quotes;
        
        
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
        
        Order objOrder = new Order(
            AccountId = objAccount.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert objOrder;
        
         OrderDeliveryMethod objOrderDeliveryMethod = new OrderDeliveryMethod(
            Name = 'Test'
        );
        
        insert objOrderDeliveryMethod;
        
        OrderDeliveryGroup objOrderDeliveryGroup = new OrderDeliveryGroup(
            DeliverToName = 'Test',
            OrderId = objOrder.Id,
            OrderDeliveryMethodId = objOrderDeliveryMethod.Id
        );
        insert objOrderDeliveryGroup;
        
        OrderItem objOrderProduct = new OrderItem(
            Product2Id = objProduct.Id,
            OrderId = objOrder.Id,
            UnitPrice = 15,
            Quantity = 21,
            ListPrice = 10,
            TotalLineAmount = 10,
            OrderDeliveryGroupId = objOrderDeliveryGroup.Id
        );
        insert objOrderProduct;
        
        objOrder.Status = 'Activated';
        update objOrder;
        
        database.executeBatch(new AQT_CreateOrderSummaryBatch());
        
        Test.stopTest();
    }
    
    @isTest
    public static void schedulableMethodTest(){
        Test.startTest();
        
        String strSchedulableTime = '0 0 12 * * ?';
        AQT_CreateOrderSummaryBatch aqtCreateOrderBatchSchedulable = new AQT_CreateOrderSummaryBatch();
        system.schedule('aqtCreateOrderBatchSchedulable', strSchedulableTime, aqtCreateOrderBatchSchedulable);
        
        Test.stopTest();
    }
}