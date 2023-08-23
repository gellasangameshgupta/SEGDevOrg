/*******************************************************************************************************
* 
* @ Name        :   B2B_FieldSetSelectorTest
* @ Purpose     :   Test Class for B2B_FieldSetSelector and B2B_GenericDataTableByFieldSetController
* @ Author      :   Monal Kumar
* @ Class Name  :   B2B_FieldSetSelector
*
*   Date        |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   21-05-2021  |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_FieldSetSelectorTest {
    
    @TestSetup
    static void makeData() {
        List<B2B_ProductApplication__c> list_ProductApplications = new List<B2B_ProductApplication__c>();
        Product2 objProduct = new Product2();
        objProduct.B2B_SEGIAMProductNumber__c = '56789';
        objProduct.Name = 'AUDI - 136';
        insert objProduct;
        
        B2B_ProductApplication__c objProductApplicationBMW = new B2B_ProductApplication__c();
        objProductApplicationBMW.Name = 'BMW-123';
        list_ProductApplications.add(objProductApplicationBMW);
        
        B2B_ProductApplication__c objProductApplicationAUDI = new B2B_ProductApplication__c();
        objProductApplicationAUDI.Name = 'AUDI - 136';
        objProductApplicationAUDI.SEGIAMProductNumber__c = '56789';
        objProductApplicationAUDI.Product__c = objProduct.Id;
        list_ProductApplications.add(objProductApplicationAUDI);
        
        insert list_ProductApplications;
    }
    
    static testMethod void testGetFields() {
        Test.startTest();
        List<Schema.FieldSetMember> list_FieldSetMembers = B2B_FieldSetSelector.getFields(
            'B2B_ProductApplication__c',
            'B2B_ProductDetailPageRelatedList'
        );
        
        Test.stopTest();
        System.assertEquals(!list_FieldSetMembers.isEmpty(), true);
    }
    
    static testMethod void testGetCriteriaFieldValueByObjectAPINameFieldAPINameAndRecordId() {
        Test.startTest();
        String strResponse;
        List<B2B_ProductApplication__c> list_ProductApplications = [SELECT Id FROM B2B_ProductApplication__c WHERE Name = 'AUDI - 136'];
        
        if (!list_ProductApplications.isEmpty()) {
            strResponse = B2B_FieldSetSelector.getCriteriaFieldValueByObjectAPINameFieldAPINameAndRecordId(
                list_ProductApplications[0].Id,
                'B2B_ProductApplication__c',
                'Name'
            );
        }
        Test.stopTest();
        
        System.assertEquals(String.isNotEmpty(strResponse), true);
    }
    
    static testMethod void testGetRecordsByFieldSetAndCriteria() {
        List<Schema.FieldSetMember> list_FieldSetMembers = 
            SObjectType.B2B_ProductApplication__c.FieldSets.B2B_ProductDetailPageRelatedList.getFields();
        
        Test.startTest();
        List<SObject> list_Objects = B2B_FieldSetSelector.getRecordsByFieldSetAndCriteria(
            'B2B_ProductApplication__c',
            list_FieldSetMembers,
            'SEGIAMProductNumber__c',
            '56789','',
            '5'
        );
        Test.stopTest();   
        
        System.assertEquals(!list_Objects.isEmpty(), true);
    }
    
    static testMethod void testGetTableData() {
        Test.startTest();
        B2B_GenericDataTableByFieldSetController.TableData objResponse = new B2B_GenericDataTableByFieldSetController.TableData();
        List<B2B_ProductApplication__c> list_ProductApplications = [SELECT Id FROM B2B_ProductApplication__c WHERE Name = 'AUDI - 136'];
        
        if (!list_ProductApplications.isEmpty()) {
            objResponse = B2B_GenericDataTableByFieldSetController.getTableData(
                list_ProductApplications[0].Id,
                'B2B_ProductApplication__c',
                'B2B_ProductDetailPageRelatedList',
                'SEGIAMProductNumber__c',
                'Product2',
                'B2B_SEGIAMProductNumber__c',
                '5'
            );
        }
        Test.stopTest();
        
        System.assertEquals(objResponse != null, true);
    }
}