/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderItemTriggerHandlerTest
* @ Purpose         :   Test class for B2B_OrderItemTriggerHandler and B2B_OrderButtonController
* @ Author          :   Monal Kumar
* @ Class Name 		:   B2B_OrderItemTriggerHandler,B2B_OrderButtonController
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   21-06-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*   12-12-2022      |  pradeep.chary@absyz.com      |  2.0          |  Added test method updateOrderSummaryDetails
*
*******************************************************************************************************/
@isTest(seeAllData=true)
public class B2B_OrderItemTriggerHandlerTest {
    
    @isTest
    public static void testUpdateOrderedQuantityOnProduct() {
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
        
        Order objOrder = new Order();
        objOrder.Name = 'Test Order ';
        objOrder.Status = 'Draft';
        objOrder.AccountId = objAccount.Id;
        objOrder.EffectiveDate = System.today();
        objOrder.EndDate = System.today() + 4;
        objOrder.Pricebook2Id = idPricebookId;
        insert objOrder;
        
        List<OrderItem> list_OrderItems = new List<OrderItem>();
        OrderItem objOrderItem = new OrderItem();
        objOrderItem.OrderId = objOrder.Id;
        objOrderItem.Quantity = 25;
        objOrderItem.UnitPrice = 240;
        objOrderItem.Product2Id = list_Products[0].Id;
        objOrderItem.PricebookEntryId = objPricebookEntry.Id;
        list_OrderItems.add(objOrderItem);
        insert list_OrderItems;
        
        List<Product2> list_UpdatedProducts = [SELECT 
                                               Id, 
                                               B2B_QuantityOrdered__c 
                                               FROM Product2 
                                               WHERE Name = 'Test Product' 
                                               LIMIT 1];
        
        if (!list_UpdatedProducts.isEmpty()) {
            System.assertEquals(list_UpdatedProducts[0].B2B_QuantityOrdered__c, 25);
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testupdateOrderSummaryFields() {
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Order objOrder = new Order(
            AccountId = objAccount.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert objOrder;
        
        Product2 objProduct = new Product2(
            Name = 'Test Product',
            B2B_SEGIAMProductNumber__c = '1234'
        );
        insert objProduct;
        
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
        
        ConnectApi.OrderSummaryInputRepresentation objOrderSummary = new ConnectApi.OrderSummaryInputRepresentation();
        objOrderSummary.OrderId = objOrder.Id;
        objOrderSummary.Status = 'Created';
        ConnectApi.OrderSummaryOutputRepresentation objOrderSummaryId = ConnectApi.OrderSummaryCreation.createOrderSummary(objOrderSummary);
        
        B2B_OrderButtonController.updateOrderSummaryFields(
            String.valueOf(objOrderSummaryId.OrderSummaryId), 
            'Return Request', 
            'Wrong product'
        );
        
        List<OrderSummary> list_OrderSummaries = [SELECT 
                                                  Id, 
                                                  Status 
                                                  FROM OrderSummary 
                                                  WHERE Id = :objOrderSummaryId.OrderSummaryId];
        
        if (!list_OrderSummaries.isEmpty()) {
            System.assertEquals(list_OrderSummaries[0].Status, 'Return Request');
        }
        
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateOrderSummaryDetails() {
        Test.startTest();
        
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        insert objAccount;
        
        Order objOrder = new Order(
            AccountId = objAccount.Id,
            EffectiveDate = System.today(),
            Status = 'Draft'
        );
        insert objOrder;
        
        Product2 objProduct = new Product2(
            Name = 'Test Product',
            B2B_SEGIAMProductNumber__c = '1234'
        );
        insert objProduct;
        
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
        
        ConnectApi.OrderSummaryInputRepresentation objOrderSummary = new ConnectApi.OrderSummaryInputRepresentation();
        objOrderSummary.OrderId = objOrder.Id;
        objOrderSummary.Status = 'Created';
        ConnectApi.OrderSummaryOutputRepresentation objOrderSummaryId = ConnectApi.OrderSummaryCreation.createOrderSummary(objOrderSummary);
        
        OrderSummary objOrderSummaryUpdated = new OrderSummary();
        objOrderSummaryUpdated.Id = objOrderSummaryId.OrderSummaryId;
        objOrderSummaryUpdated.PoNumber = '1234567890';
        objOrderSummaryUpdated.B2B_CarrierInformation__c = 'Address Details: Test';
        
        List<OrderSummary> list_OrderSummaries = new List<OrderSummary>();
        list_OrderSummaries.add(objOrderSummaryUpdated);
        
        B2B_OrderButtonController.updateOrderSummaryDetails(list_OrderSummaries);
        
        list_OrderSummaries = [SELECT 
                               Id, 
                               PoNumber 
                               FROM OrderSummary 
                               WHERE Id = :objOrderSummaryId.OrderSummaryId];
        
        if (!list_OrderSummaries.isEmpty()) {
            System.assertEquals(list_OrderSummaries[0].PoNumber, '1234567890');
        }
        
        Test.stopTest();
    }
}