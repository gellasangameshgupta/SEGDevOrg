/*******************************************************************************************************
* 
* @ Name        : B2B_ProductApplicationsToProductTest
* @ Purpose     : Test class for B2B_ProductApplicationsToProduct
* @ Author      : Aseem Doddamani
* @ Class Name  : B2B_ProductApplicationsToProduct
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   18-07-2021  |  aseem.doddamani@absyz.com   |  1.0          |  Initial Version
*   31-05-2022  |  Khushmeet.kaur@absyz.com    |  2.0          |  Added new method AQT_syncProductApplicationsToProduct

*******************************************************************************************************/
@isTest
public class B2B_ProductApplicationsToProductTest {
    
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
        B2B_ProductApplicationsToProduct.syncProductApplicationsToProduct();
        
        List<B2B_ProductApplication__c> list_ProductApplications =  [SELECT
                                                                     Id,
                                                                     EAN__c,
                                                                     Generation__c,
                                                                     GroovesNumber__c,
                                                                     Make__c,
                                                                     Plant__c,
                                                                     PreviousSEGIAMProductNumber__c,
                                                                     ProductType__c,
                                                                     PulleyDimension__c,
                                                                     PulleyType__c,
                                                                     Rotation__c,
                                                                     SEGIAMProductNumber__c,
                                                                     TeethNumber__c,
                                                                     Weight__c,
                                                                     Voltage__c,
                                                                     OEMItemNumber__c,
                                                                     LeadTimeWeeks__c,
                                                                     MOQ__c,
                                                                     ShopMeProduct__c
                                                                     FROM B2B_ProductApplication__c
                                                                    ];
        
        B2B_ProductApplicationsToProduct.AQT_syncProductApplicationsToProduct(list_ProductApplications);
        
        List<Product2> list_Products = [SELECT 
                                        Id 
                                        FROM Product2 
                                        WHERE B2B_SEGIAMProductNumber__c = '4676678787'
                                       ];
        
        System.assertEquals(!list_Products.isEmpty(), true);
        Test.stopTest();
    }
}