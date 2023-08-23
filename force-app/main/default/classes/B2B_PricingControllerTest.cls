/*******************************************************************************************************
* 
* @ Name        : 	B2B_PricingControllerTest
* @ Purpose     : 	Test class for B2B_PricingController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_PricingController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   23-06-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_PricingControllerTest {
    
    @TestSetup
    static void createData() {
        
        Pricebook2 objPriceBook = new Pricebook2(
            Name = 'B2B PriceBook',
            IsActive = TRUE
        );
        
        insert objPriceBook;
        
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
            DeliverToState = 'Andhra',
            DeliverToCountry = 'Austria',
            CurrencyIsoCode = 'EUR',
            Name = 'Default Delivery'
        );
        
        insert objCartDeliveryGroup;
        
        CartItem objCartItem = new CartItem(
            CartDeliveryGroupId = objCartDeliveryGroup.Id,
            CartId = objWebCart.Id,
            Name = 'TestProduct',
            Type = 'Product',
            Sku = '4455466',
            SalesPrice = 46577
        );
        
        insert objCartItem;
    }
    
    @isTest
    public static void testStartCartProcessAsync() {
        Test.startTest();
        
        sfdc_checkout.IntegrationInfo jobInfo;
        List<WebCart> list_WebCarts = [SELECT Id FROM WebCart WHERE Name = 'B2B Cart'];
        
        B2B_PricingController classB2BPricingController = new B2B_PricingController();
        sfdc_checkout.IntegrationStatus integrationResult =
            classB2BPricingController.startCartProcessAsync(jobInfo, list_WebCarts[0].Id);
        
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
            classB2BPricingController.startCartProcessAsync(integInfo, list_WebCarts[0].Id);
        
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResults.status);
        
        List<CartValidationOutput> list_CartValidationOutputs =
            [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        
        System.assertEquals(1, list_CartValidationOutputs.size());
        System.assertEquals('The SKUs for all products in your cart must be defined.',
                            list_CartValidationOutputs.get(0).Message);
        
        Test.stopTest();
    }
}