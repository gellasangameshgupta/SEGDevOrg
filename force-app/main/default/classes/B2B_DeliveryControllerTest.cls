/*******************************************************************************************************
* 
* @ Name        :   B2B_DeliveryControllerTest
* @ Purpose     :   Test class for B2B_DeliveryController
* @ Author      :   Aseem Doddamani
* @ Class Name  :   B2B_DeliveryController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   22-06-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_DeliveryControllerTest {
    
    @TestSetup
    static void createData() {
        
        //Pricebook2
        Pricebook2 objPriceBook = new Pricebook2(
            Name = 'B2B PriceBook',
            IsActive = TRUE
        );
        insert objPriceBook;
        
        List<B2B_ProductWarehouse__c> list_ProductWarehouses = new List<B2B_ProductWarehouse__c>();
        B2B_ProductWarehouse__c objProductWarehouse = new B2B_ProductWarehouse__c();
        objProductWarehouse.Name = 'Hungary';
        objProductWarehouse.Warehouse__c = 'Hungary';
        
        list_ProductWarehouses.add(objProductWarehouse);
        insert list_ProductWarehouses;
        
        //Product2
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2(
            Name = 'B2B Test Product 1',
            B2B_PreviousSEGIAMProductNumber__c = '464577',
            B2B_SEGIAMProductNumber__c = '2222',
            StockKeepingUnit = 'ChargeSKU',
            CurrencyIsoCode = 'EUR',
            B2B_Weight__c = 30,
            B2B_Plant__c = objProductWarehouse.Id,
            isActive = true,
            ProductCode = 'Test'
        );
        list_Products.add(objProduct);
        insert list_Products;
        
        //Account
        Account objAccount = new Account(
            Name = 'B2B Test Account'
        );
        insert objAccount;
        
        //WebStore
        WebStore objWebStore = new WebStore(
            Name = 'B2B Store',
            PricingStrategy = 'LowestPrice',
            StrikethroughPricebook = objPriceBook,
            CurrencyIsoCode = 'EUR'
            
        );
        insert objWebStore;
        
        //WebCart
        WebCart objWebCart = new WebCart(
            Name = 'B2B Cart',
            AccountId = objAccount.Id,
            WebStoreId = objWebStore.Id,
            PoNumber = '',
            Status = 'Active',
            Type = 'Cart',
            CurrencyIsoCode = 'EUR'
        );
        insert objWebCart;
        
        //CartDeliveryGroup
        CartDeliveryGroup objCartDeliveryGroup = new CartDeliveryGroup();
        objCartDeliveryGroup.CartId = objWebCart.Id;
        objCartDeliveryGroup.DeliverToState = 'Test';
        objCartDeliveryGroup.DeliverToCountry = 'Belgium';
        objCartDeliveryGroup.CurrencyIsoCode = 'EUR';
        objCartDeliveryGroup.Name = 'Default Delivery';
        insert objCartDeliveryGroup;
        
        //CartItem
        List<CartItem> list_CartItems = new List<CartItem>();
        
        CartItem objCartItem = new CartItem();
        objCartItem.Sku = '666753';
        objCartItem.CartDeliveryGroupId = objCartDeliveryGroup.Id;
        objCartItem.CartId = objWebCart.Id;
        objCartItem.Product2Id = objProduct.Id;
        objCartItem.Name = 'TestProduct';
        objCartItem.TotalPrice = 50;
        objCartItem.Type = 'Charge';
        list_CartItems.add(objCartItem);
        insert list_CartItems;
    }
    
    @isTest
    public static void testStartCartProcessAsync() {
        Test.startTest();
        
        sfdc_checkout.IntegrationInfo jobInfo ;
        
        List<WebCart> list_WebCarts = [SELECT Id FROM WebCart WHERE Name = 'B2B Cart'];
        
        B2B_DeliveryController objB2B_DeliveryController = new B2B_DeliveryController();
        sfdc_checkout.IntegrationStatus integrationResult = 
            objB2B_DeliveryController.startCartProcessAsync(jobInfo, list_WebCarts[0].Id);
        
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResult.status);
        
        List<CartDeliveryGroup> list_CartDeliveryGroups = 
            [SELECT Id FROM CartDeliveryGroup WHERE CartId = :list_WebCarts[0].Id LIMIT 1];
        
        CartItem objCartItemSKU = new CartItem(
            CartId = list_WebCarts[0].Id,
            Quantity = 1.0,
            Type = 'Product',
            Name = 'TestProductNoSku',
            CartDeliveryGroupId = list_CartDeliveryGroups.get(0).Id
        );
        insert objCartItemSKU;
        
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        
        sfdc_checkout.IntegrationStatus integrationResults =
            objB2B_DeliveryController.startCartProcessAsync(integInfo, list_WebCarts[0].Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.SUCCESS, integrationResults.status);
        
        List<CartValidationOutput> list_CartValidationOutputs =
            [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        
        integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        
        delete objCartItemSKU;
        Test.stopTest();
    }
    
    @isTest
    public static void testStartCartProcessAsyncNegative() {
        Test.startTest();
        
        sfdc_checkout.IntegrationInfo jobInfo ;
        
        List<WebCart> list_WebCarts = [SELECT Id FROM WebCart WHERE Name = 'B2B Cart'];
        
        B2B_DeliveryController objB2B_DeliveryController = new B2B_DeliveryController();
        objB2B_DeliveryController.blnTriggerException = true;
        sfdc_checkout.IntegrationStatus integrationResult = 
            objB2B_DeliveryController.startCartProcessAsync(jobInfo, list_WebCarts[0].Id);
        
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        
        List<CartDeliveryGroup> list_CartDeliveryGroups = 
            [SELECT Id FROM CartDeliveryGroup WHERE CartId = :list_WebCarts[0].Id LIMIT 1];
        
        CartItem objCartItemSKU = new CartItem(
            CartId = list_WebCarts[0].Id,
            Quantity = 1.0,
            Type = 'Product',
            Name = 'TestProductNoSku',
            CartDeliveryGroupId = list_CartDeliveryGroups.get(0).Id
        );
        insert objCartItemSKU;
        
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        
        sfdc_checkout.IntegrationStatus integrationResults =
            objB2B_DeliveryController.startCartProcessAsync(integInfo, list_WebCarts[0].Id);
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResults.status);
        
        List<CartValidationOutput> list_CartValidationOutputs =
            [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        
        integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        
        delete objCartItemSKU;
        objB2B_DeliveryController.blnTriggerException = false;
        Test.stopTest();
    }
}