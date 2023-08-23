/*******************************************************************************************************
* 
* @ Name            :   B2B_ShopMeCartItemsControllerTest
* @ Purpose         :   Test class for B2B_ShopMeCartItemsController
* @ Author          :   Prathiksha Suvarna
* @ Class Name 		:   B2B_ShopMeCartItemsController
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   06-04-2023      |  prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest(SeeAllData=true)
public class B2B_ShopMeCartItemsControllerTest {  
    
    @isTest
    public static void testgetCartItems() {
        Test.startTest();
        
        Account objAccount = new Account(
            Name = 'Test Account'
        );        
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
        
        WebStore objStore = new WebStore(
            Name = 'Test Store',
            SupportedLanguages = 'de',
            DefaultLanguage = 'de',
            PricingStrategy = 'LowestPrice',
            SupportedCurrencies = 'EUR',
            CurrencyIsoCode = 'EUR'           
        );
        insert objStore;
        
        WebCart objCart = new WebCart(
            Name = 'Cart',
            WebStoreId = objStore.Id,
            AccountId = objAccount.Id,
            PoNumber = 'PO1',
            Status = 'Active',
            Type = 'Cart',
            CurrencyIsoCode = 'EUR'
        );
        insert objCart;        
        
        CartDeliveryGroup objCartDeliveryGroup = new CartDeliveryGroup(
            Name = 'Default Delivery',
            CartId = objCart.Id
        );
        insert objCartDeliveryGroup;
        
        CartItem objCartItem = new CartItem(
            Name = '0125810000',
            SalesPrice = 160,
            Quantity = 1,
            product2Id = objProduct.Id ,
            CartId = objCart.Id,
            CartDeliveryGroupId =objCartDeliveryGroup.Id           
        );
        insert objCartItem;
        
        ElectronicMediaGroup objElectronicMediaGroup = new ElectronicMediaGroup(
            Name = 'Product Detail',
            DeveloperName = 'productDetail',
            UsageType = 'Standard' 
        );
        insert objElectronicMediaGroup;
        
        //This is used to retrive org wide default record for custom setting of B2B_ShopMeConfigurations__c
        B2B_ShopMeConfigurations__c objShopMeConfiguration = B2B_ShopMeConfigurations__c.getOrgDefaults();
        
/*        ProductMedia objProductMedia = new ProductMedia(
            ProductId = objProduct.Id,
            ElectronicMediaGroupId = objElectronicMediaGroup.Id,
            ElectronicMediaId = objShopMeConfiguration.ElectronicMediaId__c
        );
        insert objProductMedia;*/
        // Create test product media
        ProductMedia testProductMedia = new ProductMedia();
        testProductMedia.ProductId = objProduct.Id;
    //    testProductMedia.MediaType = 'Image';
     //   testProductMedia.Url = 'https://example.com/test-image.jpg';
        
        // Set ElectronicMediaGroupId and ElectronicMediaId fields
        testProductMedia.ElectronicMediaGroupId = objElectronicMediaGroup.Id;
        testProductMedia.ElectronicMediaId = 'EM001';
        
        // Insert product media record
        insert testProductMedia;
        
        B2B_ShopMeCartItemsController.ResponseWrapper response = B2B_ShopMeCartItemsController.getCartItems(objCart.Id);
        
        Test.stopTest();
    }
}