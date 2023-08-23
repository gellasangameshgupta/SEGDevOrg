/*******************************************************************************************************
* 
* @ Name        : B2B_SyncProductApplicationBatch
* @ Purpose     : Call the apex class for insert products using product application and surpressing the soql limit
* @ Author      : Pradeep Chary
* @ Class Name  : B2B_SyncProductApplicationBatch
* @ Test Class  : B2B_SyncProductApplicationBatchTest
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   04-05-2023  |  pradeep.chary@absyz.com     |  1.0          |  Initial Version
*******************************************************************************************************/
/**
    Sample Query
        String strQuery = 'SELECT Id, (SELECT Id, Make__c, OEMItemNumber__c FROM ProductApplications__r) FROM Product2' +
                    'WHERE B2B_ShopMeProduct__c = true';
**/

public class B2B_SyncProductApplicationBatch implements Database.Batchable<sObject>{
    
    public String strQuery;
    
    public B2B_SyncProductApplicationBatch(String stQuery) {
        strQuery = stQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Product2> scope) {
        Set<String> set_PicklistEntries = new Set<String>();
        List<Product2> list_Products = new List<Product2>();
        
        SObjectField objSObjectField = SObjectType.Product2.fields.B2B_MakeMultiple__c.getSObjectField();
        List<PicklistEntry> list_PicklistEntries = objSObjectField.getDescribe().getPicklistValues();
        for (PicklistEntry objPicklistEntry : list_PicklistEntries) {
            set_PicklistEntries.add(objPicklistEntry.getValue());
        }
        
        for (Product2 objProduct : scope) {
            Set<String> set_OemItemNumbers = new Set<String>();
            Set<String> set_Makes = new Set<String>();
            for (B2B_ProductApplication__c objProductApplication : objProduct.ProductApplications__r) {
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
            
            list_Products.add(objProduct);
        }
        
        if (!list_Products.isEmpty()) {
            // Calling generic method to insert SObject list records
            IFv2_DmlController.GenericListDMLOperation(list_Products, 'update');
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {}
    
    public static String format(Set<String> set_Values) {
        if (set_Values == null) {
            return null;
        }
        
        List<String> list_Values = new List<String>(set_Values);
        list_Values.sort();
        return String.join(list_Values, ';');
    }
}