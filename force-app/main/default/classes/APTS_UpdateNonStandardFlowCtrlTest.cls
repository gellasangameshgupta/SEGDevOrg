/*************************************************************
@Name: APTS_UpdateNonStandardFlowCtrlTest
@Author:Apttus
@Description: Tests APTS_UpdateNonStandardFlowController

******************************************************************/
@isTest
private class APTS_UpdateNonStandardFlowCtrlTest{

    static testMethod void myUnitTest() {
        
        //Create a new Account
        Account testacc = new Account();
        testacc.Name = 'Test Account';
        
        insert testacc;
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;

        
        //Create new agreement
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        agreement.Apttus__Account__c = testacc.Id;
        
        insert agreement;
        
        Group legal = new Group(Name='Legal Queue', type='Queue');
        insert legal;
        
        //Start Test
        Test.startTest();
        
        //Initialize the page
        ApexPages.StandardController sc = new ApexPages.StandardController(agreement);
        APTS_UpdateNonStandardFlowController Ctrl = 
            new APTS_UpdateNonStandardFlowController(sc);
        
        //execute finalize method
        Ctrl.updateNonStandardFlow();
        
        //Stop Test
        Test.stopTest();
      
        
        
    }
    
    
}