/*******************************************************************************************************
* 
* @ Name            :   B2B_SyncProductApplicationBatchTest
* @ Purpose         :   Test Class for B2B_SyncProductApplicationBatch. 
* @ Author          :   Pradeep Chary
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    04-05-2023     |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*   
*******************************************************************************************************/
@isTest
public class B2B_SyncProductApplicationBatchTest {
    
    @TestSetup
    static void createData() {
        
        List<B2B_ProductWarehouse__c> list_ProductWarehouses = new List<B2B_ProductWarehouse__c>();
        B2B_ProductWarehouse__c objProductWarehouse = new B2B_ProductWarehouse__c();
        objProductWarehouse.Name = 'Hungary';
        objProductWarehouse.Warehouse__c = 'Hungary';
        list_ProductWarehouses.add(objProductWarehouse);
        insert list_ProductWarehouses;
        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2(
            Name = 'B2B Test Product 1',
            B2B_PreviousSEGIAMProductNumber__c = '464577',
            B2B_SEGIAMProductNumber__c = '4676678787',
            StockKeepingUnit = '4676678787',
            CurrencyIsoCode = 'EUR',
            B2B_Weight__c = 30,
            B2B_Plant__c = objProductWarehouse.Id,
            isActive = true,
            B2B_ShopMeProduct__c = true,
            ProductCode = '4676678787'
        );
        list_Products.add(objProduct);
        insert list_Products;
        
        List<B2B_ProductApplication__c> list_ProductApplications = new List<B2B_ProductApplication__c>();
        B2B_ProductApplication__c objProductApplication = new B2B_ProductApplication__c();
        objProductApplication.Name = 'Test Product';
        objProductApplication.EAN__c = '5446577';
        objProductApplication.Generation__c = 'PUNTO EVO (05/2010>04/2013)';
        objProductApplication.GroovesNumber__c = 6;
        objProductApplication.Make__c = 'AUDI';
        objProductApplication.Plant__c = 'Hungary';
        objProductApplication.PreviousSEGIAMProductNumber__c = '354679856';
        objProductApplication.PulleyDimension__c = 6;
        objProductApplication.PulleyType__c = 'Steel';
        objProductApplication.SEGIAMProductNumber__c = '4676678787';
        objProductApplication.OEMItemNumber__c = '46766787879';
        objProductApplication.TeethNumber__c = 6;
        objProductApplication.Weight__c = 121;
        objProductApplication.Product__c = objProduct.Id;
        list_ProductApplications.add(objProductApplication);
        insert list_ProductApplications;
    }
    
    @isTest
    static void testSyncProductApplicationsToProduct() {
        Test.startTest();
        String strQuery = 'SELECT Id, (SELECT Id, Make__c, OEMItemNumber__c FROM ProductApplications__r) FROM Product2 ' +
            'WHERE B2B_ShopMeProduct__c = true';
        
        Database.executeBatch(new B2B_SyncProductApplicationBatch(strQuery));
        
        Test.stopTest();
        List<Product2> list_Products = [SELECT 
                                        Id,
                                        B2B_OEMItemNumber__c
                                        FROM Product2 
                                        WHERE B2B_SEGIAMProductNumber__c = '4676678787'
                                       ];
        System.assertEquals(list_Products[0].B2B_OEMItemNumber__c, '46766787879');
    }
    
}