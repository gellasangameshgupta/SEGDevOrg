/*******************************************************************************************************
* 
* @ Name        :   B2B_ProductQuantityRuleHelperTest 
* @ Purpose     :   Test class for B2B_ProductQuantityRuleHelper
* @ Author      :   Keerthana
* @ Class Name  :   B2B_ProductQuantityRuleHelper
*
*   Date        |  Developer Name                   |  Version      |  Changes
* ======================================================================================================
*   29-11-2022  |  keerthana.kadampally@absyz.com   |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_ProductQuantityRuleHelperTest {
    
    @TestSetup
    static void createData() {        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2(
            B2B_QuantityAvailable__c = 30,
            B2B_QuantityOrdered__c = 10,
            B2B_MOQ__c = 7,
            Name = 'B2B Test Product',
            B2B_SEGIAMProductNumber__c = 'B2B ProductNumber'
        );
        list_Products.add(objProduct);
        
        Product2 objProduct1 = new Product2(
            B2B_QuantityAvailable__c = 30,
            B2B_QuantityOrdered__c = 10,
            B2B_MOQ__c = 8,
            Name = 'B2B Test Product1',
            B2B_SEGIAMProductNumber__c = 'B2B ProductNumber1'
        );
        list_Products.add(objProduct1);
        
        insert list_Products;
        
        PurchaseQuantityRule objPurchaseQuantityRule = new PurchaseQuantityRule(
            Increment = 1,
            Minimum = 7,
            Name = 'Test PurchaseQuantityRule'
        );
        insert objPurchaseQuantityRule;
    }
    
    @isTest
    public static void testGenerateQuantityRules() {
        Test.startTest();
        
        Product2 objProduct = [SELECT 
                               Id,
                               Name,
                               B2B_QuantityAvailable__c,
                               B2B_QuantityOrdered__c,
                               B2B_MOQ__c
                               FROM Product2 
                               WHERE Name = 'B2B Test Product'
                               LIMIT 1];
        
        objProduct.B2B_QuantityOrdered__c = 30;
        update objProduct;
        
        Test.stopTest();
        
        PurchaseQuantityRule objPurchaseQuantityRule = [SELECT 
                                                        Id,
                                                        Minimum 
                                                        FROM PurchaseQuantityRule 
                                                        LIMIT 1];
        
        List<ProductQuantityRule> list_ProductQuantityRule = [SELECT Id
                                                              FROM ProductQuantityRule 
                                                              WHERE ProductId = :objProduct.Id 
                                                              AND PurchaseQuantityRuleId = :objPurchaseQuantityRule.Id
                                                              LIMIT 1];
        
        System.assertEquals(list_ProductQuantityRule.size(), 1);
        System.assertEquals(objPurchaseQuantityRule.Minimum, objProduct.B2B_MOQ__c);
    }
    
    @isTest
    public static void testInsertPurchaseQuantityRule() {
        Test.startTest();
        
        Product2 objProduct = [SELECT 
                               Id,
                               Name,
                               B2B_QuantityAvailable__c,
                               B2B_QuantityOrdered__c,
                               B2B_MOQ__c
                               FROM Product2 
                               WHERE Name = 'B2B Test Product1'
                               LIMIT 1];
        
        objProduct.B2B_QuantityOrdered__c = 30;
        update objProduct;
        
        Test.stopTest();
        
        List<ProductQuantityRule> list_ProductQuantityRule = [SELECT Id
                                                              FROM ProductQuantityRule
                                                              LIMIT 1];
        System.assertEquals(list_ProductQuantityRule.size(), 1);
    }
}