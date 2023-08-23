/*******************************************************************************************************
* 
* @ Name        : AQT_SyncProductApplicationBatchTest
* @ Purpose     : Test class for AQT_SyncProductApplicationBatch
* @ Author      : Khushmeet Kaur
* @ Class Name  : AQT_SyncProductApplicationBatch
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   02-06-2022  |  khushmeet.kaur@absyz.com    |  1.0          |  Initial Version

*******************************************************************************************************/
@isTest
public class AQT_SyncProductApplicationBatchTest {
    
    @TestSetup
    static void createData() {
        
        List<B2B_ProductWarehouse__c> list_ProductWarehouses = new List<B2B_ProductWarehouse__c>();
        B2B_ProductWarehouse__c objProductWarehouse = new B2B_ProductWarehouse__c();
        objProductWarehouse.Name = 'Hungary';
        objProductWarehouse.Warehouse__c = 'Hungary';
        list_ProductWarehouses.add(objProductWarehouse);
        insert list_ProductWarehouses;
        
        List<B2B_ProductApplication__c> list_ProductApplications = new List<B2B_ProductApplication__c>();
        B2B_ProductApplication__c objProductApplication = new B2B_ProductApplication__c();
        objProductApplication.Name = 'Product';
        objProductApplication.EAN__c = '5446577';
        objProductApplication.Generation__c = 'PUNTO EVO (05/2010>04/2013)';
        objProductApplication.GroovesNumber__c = 6;
        objProductApplication.Make__c = 'AUDI';
        objProductApplication.Plant__c = 'Hungary';
        objProductApplication.PreviousSEGIAMProductNumber__c = '354679856';
        objProductApplication.PulleyDimension__c = 6;
        objProductApplication.PulleyType__c = 'Steel';
        objProductApplication.SEGIAMProductNumber__c = '4676678787';
        objProductApplication.OEMItemNumber__c = '4676678787';
        objProductApplication.TeethNumber__c = 6;
        objProductApplication.Weight__c = 121;
        list_ProductApplications.add(objProductApplication);
        insert list_ProductApplications;
        
        List<Product2> list_Products = new List<Product2>();
        Product2 objProduct = new Product2(
            Name = 'B2B Test Product 1',
            B2B_PreviousSEGIAMProductNumber__c = '464577',
            B2B_SEGIAMProductNumber__c = '2222',
            StockKeepingUnit = '464577-2222',
            CurrencyIsoCode = 'EUR',
            B2B_Weight__c = 30,
            B2B_Plant__c = objProductWarehouse.Id,
            isActive = true,
            ProductCode = 'Test'
        );
        list_Products.add(objProduct);
        insert list_Products;
    }
    
    @isTest
    static void testSyncProductApplicationsToProduct() {
        Test.startTest();
        
        Database.executeBatch(new AQT_SyncProductApplicationBatch());
        
        Test.stopTest();
        List<Product2> list_Products = [SELECT 
                                        Id 
                                        FROM Product2 
                                        WHERE B2B_SEGIAMProductNumber__c = '4676678787'
                                       ];
        System.assertEquals(!list_Products.isEmpty(), true);
    }
}