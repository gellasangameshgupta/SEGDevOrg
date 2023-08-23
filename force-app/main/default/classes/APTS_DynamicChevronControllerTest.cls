/*************************************************************
@Name: APTS_DynamicChevronControllerTest
@Author: Chris Grimmett
@CreateDate: 6/13/2016
@Description: Tests APTS_DynamicChevronController

******************************************************************
@ModifiedBy: 
@ModifiedDate: 
@ChangeDescription: 

******************************************************************/
@isTest
public class APTS_DynamicChevronControllerTest {
    @testSetup static void setupTest()
    {
        Account testAcc = new Account();
        testAcc.Name = 'Faust Alchemical Supplies';
        insert testAcc;
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
        
        Apttus__APTS_Agreement__c newAg = new Apttus__APTS_Agreement__c();
        newAg.Name = 'Binding Contract';
        newAg.Apttus__Account__c = testAcc.Id;
        newAg.Apttus__Contract_End_Date__c = Date.Today().AddYears(24);
        newAg.Apttus__Status_Category__c ='Request';
        newAg.Apttus__Status__c = 'Request';
        insert newAg;
    }
    
    static testmethod void testStages()
    {
        Apttus__APTS_Agreement__c a = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c LIMIT 1][0];
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        APTS_DynamicChevronController ex = new APTS_DynamicChevronController(sc);
    }
}