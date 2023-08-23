@isTest
public with sharing class AgreementNew_ltngCmpController_Test {
    
    @IsTest
    static void testFetchFieldSet(){
        
        Test.startTest();
        List<AgreementNew_ltngCmpController.Field> fieldList = AgreementNew_ltngCmpController.fetchFieldSet('Apttus__AgreementNewFieldSet');
        Test.stopTest();

        System.assert(!fieldList.isEmpty(),'No Fields in fieldset Apttus__AgreementNewFieldSet');
        
    }

    @isTest
    static void testFieldDefaultConstructor(){
        
        Test.startTest();
        AgreementNew_ltngCmpController.Field field = new AgreementNew_ltngCmpController.Field();
        Test.stopTest();

        System.assert(String.isBlank(field.name));
        
    }

    @IsTest
    static void testDelete(){

        APTS_integration_Allowed__c integrationallowed = new APTS_integration_Allowed__c();
        integrationallowed.Name = 'Integration_Allowed';
        integrationallowed.APTS_Allow_Callout__c = false;
        insert integrationallowed;

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Name = 'Test';
        agreement.Apttus__Activated_Date__c = system.today();
        agreement.Apttus__Account__c = acc.Id;
        agreement.APTS_Internal_Legal_Entity__c = acc.Id;
        insert agreement;
        Test.startTest();
        
        AgreementNew_ltngCmpController.deleteRecord(agreement.Id);

        Test.stopTest();

        list<Apttus__APTS_Agreement__c> agreementList = [SELECT Id,Name FROM Apttus__APTS_Agreement__c WHERE Id = :agreement.Id];
        System.assert(agreementList.isEmpty(),'Agreement not deleted');
        
    }
}