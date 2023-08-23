/*******************************************************************************************************
* 
* @ Name            :   B2B_ProductApplicationsToProduct
* @ Purpose         :   Controller for Product Data Migration
* @ Methods         :   
* @ Test Class Name :   B2B_ProductApplicationsToProductTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   18-07-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*   31-05-2022      |  Khushmeet.kaur@absyz.com       |  2.0          |  Added new method AQT_syncProductApplicationsToProduct
*
*******************************************************************************************************/

public class B2B_ProductApplicationsToProduct {
    
    public static void syncProductApplicationsToProduct() {
        Map<String, Product2> map_ProductByStockKeepingUnit = new Map<String, Product2>();
        Map<String, List<B2B_ProductApplication__c>> map_ProductApplicationsByStockKeepingUnit = 
            new Map<String, List<B2B_ProductApplication__c>>();
        Map<String, String> map_ProductWarehouseIdsByName = new Map<String, String>();
        List<Product2> list_NewProducts = new List<Product2>();
        Set<String> set_Plants = new Set<String>();
        Set<String> set_PicklistEntries = new Set<String>();
        
        try {
            List<RecordType> list_RecordTypes = [SELECT
                                                 Id
                                                 FROM
                                                 RecordType
                                                 WHERE Name = 'B2B Product'
                                                 LIMIT 1
                                                ];
            
            SObjectField objSObjectField = SObjectType.Product2.fields.B2B_Generation__c.getSObjectField();
            List<PicklistEntry> list_PicklistEntries = objSObjectField.getDescribe().getPicklistValues();
            for (PicklistEntry objPicklistEntry : list_PicklistEntries) {
                set_PicklistEntries.add(objPicklistEntry.getValue());
            }
            
            List<Product2> list_Products = [SELECT
                                            Id,
                                            StockKeepingUnit
                                            FROM Product2
                                            WHERE StockKeepingUnit <> null
                                            AND IsActive = true
                                           ];
            
            for (Product2 objProduct : list_Products) {
                map_ProductByStockKeepingUnit.put(objProduct.StockKeepingUnit, objProduct);
            }
            
            List<B2B_ProductApplication__c> list_ProductApplications = [SELECT
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
                                                                        OEMItemNumber__c
                                                                        FROM B2B_ProductApplication__c
                                                                        WHERE CreatedDate = LAST_N_DAYS:1
                                                                        LIMIT 49000
                                                                       ];
            
            for (B2B_ProductApplication__c objProductApplication : list_ProductApplications) {
                String strStockKeepingUnit = objProductApplication.Make__c + ' - ' + objProductApplication.SEGIAMProductNumber__c;
                set_Plants.add(objProductApplication.Plant__c);
                
                if (!map_ProductByStockKeepingUnit.containsKey(strStockKeepingUnit)) {
                    if (!map_ProductApplicationsByStockKeepingUnit.containsKey(strStockKeepingUnit)) {
                        map_ProductApplicationsByStockKeepingUnit.put(strStockKeepingUnit, new List<B2B_ProductApplication__c>());
                    }
                    
                    List<B2B_ProductApplication__c> list_ProductApplicationsToMap = 
                        map_ProductApplicationsByStockKeepingUnit.get(strStockKeepingUnit);
                    
                    list_ProductApplicationsToMap.add(objProductApplication);
                    map_ProductApplicationsByStockKeepingUnit.put(strStockKeepingUnit, list_ProductApplicationsToMap);
                }
            }
            
            List<B2B_ProductWarehouse__c> list_ProductWarehouses = [SELECT
                                                                    Id,
                                                                    Warehouse__c
                                                                    FROM B2B_ProductWarehouse__c
                                                                    WHERE Warehouse__c IN :set_Plants
                                                                   ];
            
            for (B2B_ProductWarehouse__c objProductWarehouse : list_ProductWarehouses) {
                map_ProductWarehouseIdsByName.put(objProductWarehouse.Warehouse__c, objProductWarehouse.Id);
            }
            
            for (String strStockKeepingUnit : map_ProductApplicationsByStockKeepingUnit.keySet()) {
                List<B2B_ProductApplication__c> list_ProductApplicationsToMap = 
                    map_ProductApplicationsByStockKeepingUnit.get(strStockKeepingUnit);
                
                if (!list_ProductApplicationsToMap.isEmpty()) {
                    Product2 objProduct = new Product2();
                    objProduct.B2B_EAN__c = list_ProductApplicationsToMap[0].EAN__c;
                    objProduct.B2B_GroovesNumber__c = Integer.valueOf(list_ProductApplicationsToMap[0].GroovesNumber__c);
                    objProduct.B2B_Make__c = list_ProductApplicationsToMap[0].Make__c;
                    objProduct.B2B_Plant__c = map_ProductWarehouseIdsByName.get(list_ProductApplicationsToMap[0].Plant__c);
                    objProduct.B2B_PreviousSEGIAMProductNumber__c = 
                        list_ProductApplicationsToMap[0].PreviousSEGIAMProductNumber__c;
                    objProduct.B2B_ProductType__c = list_ProductApplicationsToMap[0].ProductType__c;
                    objProduct.B2B_PulleyType__c = String.valueOf(list_ProductApplicationsToMap[0].PulleyType__c);
                    objProduct.B2B_PulleyDimension__c = Integer.valueOf(list_ProductApplicationsToMap[0].PulleyDimension__c);
                    objProduct.B2B_SEGIAMProductNumber__c = list_ProductApplicationsToMap[0].SEGIAMProductNumber__c;
                    objProduct.B2B_Weight__c = Integer.valueOf(list_ProductApplicationsToMap[0].Weight__c);
                    objProduct.IsActive = true;
                    objProduct.Name = list_ProductApplicationsToMap[0].SEGIAMProductNumber__c;
                    objProduct.ProductCode = strStockKeepingUnit;
                    objProduct.StockKeepingUnit = strStockKeepingUnit;
                    objProduct.B2B_TeethNumber__c = Integer.valueOf(list_ProductApplicationsToMap[0].TeethNumber__c);
                    objProduct.B2B_Rotation__c = String.valueOf(list_ProductApplicationsToMap[0].Rotation__c);
                    objProduct.B2B_Voltage__c = Integer.valueOf(list_ProductApplicationsToMap[0].Voltage__c);
                    
                    
                    if (!list_RecordTypes.isEmpty()) {
                        objProduct.RecordTypeId = list_RecordTypes[0].Id;
                    }
                    
                    Set<String> set_Generations = new Set<String>();
                    Set<String> set_OemItemNumbers = new Set<String>();
                    for (B2B_ProductApplication__c objProductApplication : list_ProductApplicationsToMap) {
                        String strGeneration = String.valueOf(objProductApplication.Generation__c);
                        if (String.isNotBlank(strGeneration) && set_PicklistEntries.contains(strGeneration)) {
                            set_Generations.add(strGeneration);
                        }
                        set_OemItemNumbers.add(String.valueOf(objProductApplication.OEMItemNumber__c));
                    }
                    
                    if (!set_Generations.isEmpty()) {
                        //    objProduct.B2B_Generation__c = format(set_Generations);
                    }
                    
                    if (!set_OemItemNumbers.isEmpty()) {
                        List<String> list_OemItemNumbers = new List<String>();
                        list_OemItemNumbers.addAll(set_OemItemNumbers);
                        objProduct.B2B_OEMItemNumber__c = String.join(list_OemItemNumbers, ', ');
                    }
                    list_NewProducts.add(objProduct);
                }
            }
            
            if (!list_NewProducts.isEmpty()) {
                // Calling generic method to insert SObject list records
                IFv2_DmlController.GenericListDMLOperation(list_NewProducts, 'insert');
            }
        } catch (Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
    }
    
    public static void AQT_syncProductApplicationsToProduct(List<B2B_ProductApplication__c> list_ProductApplications) {
        Map<String, Product2> map_ProductByStockKeepingUnit = new Map<String, Product2>();
        Map<String, List<B2B_ProductApplication__c>> map_ProductApplicationsByStockKeepingUnit = 
            new Map<String, List<B2B_ProductApplication__c>>();
        Map<String, String> map_ProductWarehouseIdsByName = new Map<String, String>();
        List<Product2> list_NewProducts = new List<Product2>();
        Set<String> set_Plants = new Set<String>();
        Set<String> set_PicklistEntries = new Set<String>();
        Map<String, Product2> map_ProductBySEGIAMNumber = new Map<String, Product2>();
        List<B2B_ProductApplication__c> list_ProductApplicationUpdate = new List<B2B_ProductApplication__c>();
        
        try {
            SObjectField objSObjectField = SObjectType.Product2.fields.B2B_MakeMultiple__c.getSObjectField();
            List<PicklistEntry> list_PicklistEntries = objSObjectField.getDescribe().getPicklistValues();
            for (PicklistEntry objPicklistEntry : list_PicklistEntries) {
                set_PicklistEntries.add(objPicklistEntry.getValue());
            }
            
            List<RecordType> list_RecordTypes = [SELECT
                                                 Id
                                                 FROM
                                                 RecordType
                                                 WHERE Name = 'B2B Product'
                                                 LIMIT 1
                                                ];
            
            List<Product2> list_Products = [SELECT
                                            Id,
                                            StockKeepingUnit
                                            FROM Product2
                                            WHERE StockKeepingUnit <> null
                                            AND IsActive = true
                                           ];
            
            for (Product2 objProduct : list_Products) {
                map_ProductByStockKeepingUnit.put(objProduct.StockKeepingUnit, objProduct);
            }
            
            for (B2B_ProductApplication__c objProductApplication : list_ProductApplications) {
                String strStockKeepingUnit = objProductApplication.SEGIAMProductNumber__c;
                set_Plants.add(objProductApplication.Plant__c);
                
                if (!map_ProductApplicationsByStockKeepingUnit.containsKey(strStockKeepingUnit)) {
                    map_ProductApplicationsByStockKeepingUnit.put(strStockKeepingUnit, new List<B2B_ProductApplication__c>());
                }
                
                List<B2B_ProductApplication__c> list_ProductApplicationsToMap = 
                    map_ProductApplicationsByStockKeepingUnit.get(strStockKeepingUnit);
                
                list_ProductApplicationsToMap.add(objProductApplication);
                map_ProductApplicationsByStockKeepingUnit.put(strStockKeepingUnit, list_ProductApplicationsToMap);
            }
            
            List<B2B_ProductWarehouse__c> list_ProductWarehouses = [SELECT
                                                                    Id,
                                                                    Warehouse__c
                                                                    FROM B2B_ProductWarehouse__c
                                                                    WHERE Warehouse__c IN :set_Plants
                                                                   ];
            
            for (B2B_ProductWarehouse__c objProductWarehouse : list_ProductWarehouses) {
                map_ProductWarehouseIdsByName.put(objProductWarehouse.Warehouse__c, objProductWarehouse.Id);
            }
            
            for (String strStockKeepingUnit : map_ProductApplicationsByStockKeepingUnit.keySet()) {
                List<B2B_ProductApplication__c> list_ProductApplicationsToMap = 
                    map_ProductApplicationsByStockKeepingUnit.get(strStockKeepingUnit);
                
                if (!list_ProductApplicationsToMap.isEmpty()) {
                    Product2 objProduct = new Product2();
                    if (map_ProductByStockKeepingUnit.containsKey(strStockKeepingUnit)) {
                        objProduct.Id = map_ProductByStockKeepingUnit.get(strStockKeepingUnit).Id;
                    }
                    objProduct.B2B_EAN__c = list_ProductApplicationsToMap[0].EAN__c;
                    objProduct.B2B_GroovesNumber__c = Integer.valueOf(list_ProductApplicationsToMap[0].GroovesNumber__c);
                    objProduct.B2B_Plant__c = map_ProductWarehouseIdsByName.get(list_ProductApplicationsToMap[0].Plant__c);
                    objProduct.B2B_PreviousSEGIAMProductNumber__c = 
                        list_ProductApplicationsToMap[0].PreviousSEGIAMProductNumber__c;
                    objProduct.B2B_ProductType__c = list_ProductApplicationsToMap[0].ProductType__c;
                    objProduct.B2B_PulleyType__c = String.valueOf(list_ProductApplicationsToMap[0].PulleyType__c);
                    objProduct.B2B_PulleyDimension__c = Integer.valueOf(list_ProductApplicationsToMap[0].PulleyDimension__c);
                    objProduct.B2B_SEGIAMProductNumber__c = list_ProductApplicationsToMap[0].SEGIAMProductNumber__c;
                    objProduct.B2B_Weight__c = Integer.valueOf(list_ProductApplicationsToMap[0].Weight__c);
                    objProduct.IsActive = true;
                    objProduct.Name = list_ProductApplicationsToMap[0].SEGIAMProductNumber__c;
                    objProduct.ProductCode = strStockKeepingUnit;
                    objProduct.StockKeepingUnit = strStockKeepingUnit;
                    objProduct.B2B_TeethNumber__c = Integer.valueOf(list_ProductApplicationsToMap[0].TeethNumber__c);
                    objProduct.B2B_Rotation__c = String.valueOf(list_ProductApplicationsToMap[0].Rotation__c);
                    objProduct.B2B_Voltage__c = Integer.valueOf(list_ProductApplicationsToMap[0].Voltage__c);
                    objProduct.B2B_LeadTimeWeeks__c = list_ProductApplicationsToMap[0].LeadTimeWeeks__c;
                    objProduct.B2B_MOQ__c = list_ProductApplicationsToMap[0].MOQ__c;
                    objProduct.B2B_ShopMeProduct__c = list_ProductApplicationsToMap[0].ShopMeProduct__c;
                    
                    if (!list_RecordTypes.isEmpty()) {
                        objProduct.RecordTypeId = list_RecordTypes[0].Id;
                    }
                    
                    Set<String> set_OemItemNumbers = new Set<String>();
                    Set<String> set_Makes = new Set<String>();
                    for (B2B_ProductApplication__c objProductApplication : list_ProductApplicationsToMap) {
                        String strMake = String.valueOf(objProductApplication.Make__c);
                        if (String.isNotBlank(strMake) && set_PicklistEntries.contains(strMake)) {
                            set_Makes.add(strMake);
                        }
                        
                        set_OemItemNumbers.add(String.valueOf(objProductApplication.OEMItemNumber__c));
                    }
                    
                    if (!set_Makes.isEmpty()) {
                        objProduct.B2B_MakeMultiple__c = format(set_Makes);
                    }
                    
                    if (!set_OemItemNumbers.isEmpty()) {
                        List<String> list_OemItemNumbers = new List<String>();
                        list_OemItemNumbers.addAll(set_OemItemNumbers);
                        objProduct.B2B_OEMItemNumber__c = String.join(list_OemItemNumbers, ', ');
                    }
                    
                    list_NewProducts.add(objProduct);
                }
            }
            
            if (!list_NewProducts.isEmpty()) {
                // Calling generic method to insert SObject list records
                IFv2_DmlController.GenericListDMLOperation(list_NewProducts, 'upsert');
            }
            
            List<Product2> list_UpdatedProducts = [SELECT
                                                   Id,
                                                   StockKeepingUnit
                                                   FROM Product2
                                                   WHERE StockKeepingUnit <> null
                                                   AND IsActive = true
                                                  ];
            
            for (Product2 objProduct : list_UpdatedProducts) {
                map_ProductBySEGIAMNumber.put(objProduct.StockKeepingUnit, objProduct);
            }
            
            //Update the product application with product id
            for (B2B_ProductApplication__c objProductApplication : list_ProductApplications) {
                if (map_ProductBySEGIAMNumber.containsKey(objProductApplication.SEGIAMProductNumber__c)) {
                    objProductApplication.Product__c = map_ProductBySEGIAMNumber.get(objProductApplication.SEGIAMProductNumber__c).Id;
                    list_ProductApplicationUpdate.add(objProductApplication);
                }
            }
            
            if (!list_ProductApplicationUpdate.isEmpty()) {
                // Calling generic method to insert SObject list records
                IFv2_DmlController.GenericListDMLOperation(list_ProductApplicationUpdate, 'update');
            }
        } catch (Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
    }
    
    public static String format(Set<String> set_Values) {
        if (set_Values == null) {
            return null;
        }
        
        List<String> list_Values = new List<String>(set_Values);
        list_Values.sort();
        return String.join(list_Values, ';');
    }
}