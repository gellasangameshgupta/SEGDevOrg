/**
* @Name: APTS_AgreementClauseTriggerHelperTest
* @Author: APTTUS
* @CreateDate: 01/31/2020
* @Description: Test Class for APTS_AgreementClauseTriggerHelper.
-----------------------------------------------------------------------------------------------
**/
@isTest
private class APTS_AgreementClauseTriggerHelperTest {
    @testSetup static void setupTestData() {

        //Create Test User
        User testUser = new User();
        testUser.FirstName = 'Test User 101';
        testUser.LastName = 'Test User 101';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        testUser.Alias = 'TU101';
        testUser.email = 'testUser101@apttus.com';
        testUser.Username = 'testUser101@apttus.com';
        testUser.TimeZoneSidKey = 'America/Los_Angeles';
        testUser.LocaleSidKey = 'en_us';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_us';
        insert testUser;

        //Create Account
        Account testAccount = new Account();
        //testAccount.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Global HQ Account').getRecordTypeId();
        testAccount.Name ='Test Account 101';
        /*
        testAccount.Type ='Prospect';
        testAccount.APTS_Account_Legal_Entity_Name__c = 'Test Account 101 LCC';
        testAccount.APTS_Legal_Entity_Address_Street__c = '1400 Fashion Island Blvd #100';
        testAccount.APTS_Legal_Entity_Address_City__c = 'San Mateo';
        testAccount.APTS_Legal_Entity_Address_State__c = 'CA';
        testAccount.APTS_Legal_Entity_Address_Country__c = 'United States';
        testAccount.APTS_Account_Legal_Address_Zip__c = '94404';        
        testAccount.APTS_Legal_Entity_Region__c = 'Americas';        
        testAccount.BillingStreet = '1400 Fashion Island Blvd #100';
        testAccount.BillingCity = 'San Mateo';
        testAccount.BillingState = 'CA';
        testAccount.BillingCountry = 'USA';
        testAccount.BillingPostalCode = '94404';
        */
        testAccount.OwnerID = testUser.Id;
        insert testAccount;
        
        //Create Account - Internal Legal Entity
        Account testAccount1 = new Account();
        //testAccount1.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Global HQ Account').getRecordTypeId();
        testAccount1.Name ='Test Account 102';
        /*
        testAccount1.Type ='Partner / Reselle';
        testAccount1.APTS_Account_Legal_Entity_Name__c = 'Test Account 101 LCC';
        testAccount1.APTS_Legal_Entity_Address_Street__c = '1400 Fashion Island Blvd #100';
        testAccount1.APTS_Legal_Entity_Address_City__c = 'San Mateo';
        testAccount1.APTS_Legal_Entity_Address_State__c = 'CA';
        testAccount1.APTS_Legal_Entity_Address_Country__c = 'United States';
        testAccount1.APTS_Account_Legal_Address_Zip__c = '94404';        
        testAccount1.APTS_Legal_Entity_Region__c = 'Americas';        
        testAccount1.BillingStreet = '1400 Fashion Island Blvd #100';
        testAccount1.BillingCity = 'San Mateo';
        testAccount1.BillingState = 'CA';
        testAccount1.BillingCountry = 'USA';
        testAccount1.BillingPostalCode = '94404';
        testAccount1.APTS_Internal_Legal_Entity__c = true;
        */
        testAccount1.OwnerID = testUser.Id;
        
        
        insert testAccount1;
        
       // Initialize - Integration_Allowed
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj; 
        
       //Create Agreement
       // List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreement1 = new Apttus__APTS_Agreement__c();
        testAgreement1.Name = 'Test Agreement 1';
        testAgreement1.RecordTypeId = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c').getDescribe().getRecordTypeInfosByName().get('NDA').getRecordTypeId();
        testAgreement1.Apttus__Account__c = testAccount.Id;
        testAgreement1.APTS_Internal_Legal_Entity__c = testAccount1.Id;
        testAgreement1.Apttus__Status_Category__c = 'In Authoring';
        testAgreement1.Apttus__Status__c = 'Author Contract';
        testAgreement1.APTS_Type_of_Paper__c = 'Third Party Paper';
        //testAgreement1.Apttus__Perpetual__c = true;
        testAgreement1.OwnerId = testUser.Id;
        testAgreement1.APTS_Governing_Law__c = 'New York';
        testAgreement1.APTS_Term_Years__c = 5;
        testAgreement1.Apttus__Contract_Start_Date__c = Date.today();
        insert testAgreement1;
        
        //Create Agreement Clause
        List<Apttus__Agreement_Clause__c> agreementClauseList = new List<Apttus__Agreement_Clause__c>();
        Apttus__Agreement_Clause__c agreementClause1 = new Apttus__Agreement_Clause__c();
        agreementClause1.Apttus__Agreement__c = testAgreement1.Id;
        agreementClause1.Apttus__Action__c = 'Modified';
        agreementClause1.Apttus__Category__c = 'Term and Termination';
        agreementClause1.Apttus__Clause__c = 'Term';
        agreementClause1.Apttus__Text__c = 'Original Clause Modified';
        agreementClause1.Apttus__PrevText__c = 'Original Clause';
        agreementClause1.Apttus__DiffText2__c = 'Modified';
        //agreementClause1.APTS_Approval_Status__c = 'Approval Required';
        agreementClause1.Approval_Status__c = 'Approval Required';
        agreementClause1.Apttus__Active__c = true;
        agreementClauseList.add(agreementClause1);
        insert agreementClauseList;
 

               
    }
    
     @isTest static void UpdateApprovalRequiredTest(){
        Test.startTest();
        List<Account> accountList = new List<Account>([Select ID, Name, OwnerID FROM Account WHERE Name = 'Test Account 101' LIMIT 1]);                             

        List<Apttus__APTS_Agreement__c> agrList = new List<Apttus__APTS_Agreement__c>([SELECT ID, Name FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c =: accountList[0].Id]);
        
        List<Apttus__Agreement_Clause__c> agrClauseList = new List<Apttus__Agreement_Clause__c>([SELECT ID,Apttus__Agreement__c, Apttus__Action__c,Apttus__Category__c, Apttus__Clause__c FROM Apttus__Agreement_Clause__c WHERE Apttus__Agreement__c =: agrList[0].Id]);
        
        
         
        APTS_AgreementClauseTriggerHelper.UpdateApprovalRequired(agrClauseList);
        
        System.assert(agrClauseList.size() > 0, 'Test Case passed');
        Test.stopTest();
    }
    
}