/*******************************************************************************************************
* 
* @ Name            :   B2B_ShopMeOrderControllerTest
* @ Purpose         :   Test class for B2B_ShopMeOrderController
* @ Author          :   Prathiksha Suvarna
* @ Class Name 		:   B2B_ShopMeOrderController
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   18-01-2023      |  prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest(seeAllData=true)
public class B2B_ShopMeOrderControllerTest {
    
    @isTest
    public static void testRegularShopMeOrders() {
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
            B2B_SEGIAMProductNumber__c = '1234',
            B2B_QuantityAvailable__c = 20,
            B2B_QuantityOrdered__c = 10
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
        
        OrderItemSummary objOrderItemSummary = new OrderItemSummary();
        objOrderItemSummary.Type = 'Delivery Charge';
        objOrderItemSummary.QuantityOrdered = 20;
        objOrderItemSummary.Product2Id = objProduct.Id;
        objOrderItemSummary.OrderSummaryId = objOrderSummaryId.OrderSummaryId;
        
        B2B_ShopMeOrder__c objShopMeOrder = new B2B_ShopMeOrder__c();
        objShopMeOrder.OrderType__c = 'Regular';
        objShopMeOrder.OrderSummary__c = objOrderSummaryId.OrderSummaryId;
        insert objShopMeOrder;  
        
        B2B_ShopMeOrderController.createShopMeOrders(objOrderSummaryId.OrderSummaryId);        
        Test.stopTest();
    }
    
    @isTest
    public static void testPickMeShopMeOrders() {
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
            B2B_SEGIAMProductNumber__c = '1234',
            B2B_QuantityAvailable__c = 40,
            B2B_QuantityOrdered__c = 10
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
        
        OrderItemSummary objOrderItemSummary = new OrderItemSummary();
        objOrderItemSummary.Type = 'Delivery Charge';
        objOrderItemSummary.QuantityOrdered = 1;
        objOrderItemSummary.Product2Id = objProduct.Id;
        objOrderItemSummary.OrderSummaryId = objOrderSummaryId.OrderSummaryId;
        
        B2B_ShopMeOrder__c objShopMeOrder = new B2B_ShopMeOrder__c();
        objShopMeOrder.OrderType__c = 'Pick Me';
        objShopMeOrder.OrderSummary__c = objOrderSummaryId.OrderSummaryId;
        insert objShopMeOrder;  
        
        B2B_ShopMeOrderController.createShopMeOrders(objOrderSummaryId.OrderSummaryId); 
        Test.stopTest();
    }
}