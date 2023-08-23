/*******************************************************************************************************
* 
* @ Name        : 	B2B_TaxControllerTest
* @ Purpose     : 	Test class for B2B_TaxController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_TaxController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   22-06-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_TaxControllerTest {
    
    @TestSetup
    static void createData() {
        
        Pricebook2 objPriceBook = new Pricebook2(
            Name = 'B2B PriceBook',
            IsActive = TRUE
        );
        insert objPriceBook;
        
        List<B2B_ProductWarehouse__c> list_ProductWarehouses = new List<B2B_ProductWarehouse__c>();
        B2B_ProductWarehouse__c objProductWarehouse = new B2B_ProductWarehouse__c();
        objProductWarehouse.Name = 'Spain';
        objProductWarehouse.Warehouse__c = 'Spain';
        list_ProductWarehouses.add(objProductWarehouse);
        insert list_ProductWarehouses;
        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2(
            Name = 'B2B Test Product 2',
            B2B_PreviousSEGIAMProductNumber__c = '4645777',
            B2B_SEGIAMProductNumber__c = '22222',
            StockKeepingUnit = 'ChargeSKU - 2222',
            CurrencyIsoCode = 'EUR',
            B2B_Weight__c = 30,
            B2B_Plant__c = objProductWarehouse.Id,
            isActive = true,
            ProductCode = 'Test'
        );
        list_Products.add(objProduct);
        
        Product2 objProduct2 = new Product2(
            Name = 'B2B Test Product 22',
            B2B_PreviousSEGIAMProductNumber__c = '464577722',
            B2B_SEGIAMProductNumber__c = '2222222',
            StockKeepingUnit = 'ChargeSKU',
            CurrencyIsoCode = 'EUR',
            B2B_Weight__c = 30,
            B2B_Plant__c = objProductWarehouse.Id,
            isActive = true,
            ProductCode = 'Test'
        );
        list_Products.add(objProduct2);
        insert list_Products;
        
        Account objAccount = new Account(
            Name = 'B2B Test Account'
        );
        insert objAccount;
        
        WebStore objWebStore = new WebStore(
            Name = 'B2B Store',
            PricingStrategy = 'LowestPrice',
            StrikethroughPricebook = objPriceBook,
            CurrencyIsoCode = 'EUR'
        );
        insert objWebStore;
        
        WebCart objWebCart = new WebCart(
            AccountId = objAccount.Id,
            Name = 'B2B Cart',
            WebStoreId = objWebStore.Id,
            PoNumber = '',
            Status = 'Active',
            Type = 'Cart',
            CurrencyIsoCode = 'EUR'
        );
        insert objWebCart;
        
        CartDeliveryGroup objCartDeliveryGroup = new CartDeliveryGroup(
            CartId = objWebCart.Id,
            DeliverToState = 'Test',
            DeliverToCountry = 'Spain',
            CurrencyIsoCode = 'EUR',
            Name = 'Default Delivery'
        );
        insert objCartDeliveryGroup;
        
        List<CartItem> list_CartItems = new List<CartItem>();
        CartItem objCartItem = new CartItem();
        objCartItem.Sku = objProduct.StockKeepingUnit;
        objCartItem.Name = 'TestProduct';
        objCartItem.CartDeliveryGroupId = objCartDeliveryGroup.Id;
        objCartItem.Product2Id = objProduct.Id;
        objCartItem.CartId = objWebCart.Id;
        objCartItem.Type = 'Product';
        objCartItem.TotalPrice = 400;
        list_CartItems.add(objCartItem);
        
        CartItem objCartItem2 = new CartItem();
        objCartItem2.Sku = objProduct2.StockKeepingUnit;
        objCartItem2.Name = 'TestProduct2';
        objCartItem2.CartDeliveryGroupId = objCartDeliveryGroup.Id;
        objCartItem2.Product2Id = objProduct2.Id;
        objCartItem2.CartId = objWebCart.Id;
        objCartItem2.Type = 'Charge';
        objCartItem2.TotalPrice = 400;
        list_CartItems.add(objCartItem2);
        insert list_CartItems;
    }
    
    @isTest
    public static void testStartCartProcessAsync() {
        Test.startTest();
        
        sfdc_checkout.IntegrationInfo jobInfo;
        
        List<WebCart> list_WebCarts = [SELECT Id FROM WebCart WHERE Name = 'B2B Cart'];
        
        B2B_TaxController classB2BTaxController = new B2B_TaxController();
        sfdc_checkout.IntegrationStatus integrationResult =
            classB2BTaxController.startCartProcessAsync(jobInfo, list_WebCarts[0].Id);
        
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
            classB2BTaxController.startCartProcessAsync(integInfo, list_WebCarts[0].Id);
        
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResults.status);
        
        List<CartValidationOutput> list_CartValidationOutputs =
            [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, list_CartValidationOutputs.size());
        System.assertEquals('The SKUs for all products in your cart must be defined.',
                            list_CartValidationOutputs.get(0).Message);
        
        integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        
        delete objCartItemSKU;
        
        Test.stopTest();
    }
}