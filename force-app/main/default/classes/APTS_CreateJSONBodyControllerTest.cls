@isTest
public class APTS_CreateJSONBodyControllerTest {
    static testmethod void setupTest()
    {
        APTS_integration_Allowed__c integrationallowed = new APTS_integration_Allowed__c();
        integrationallowed.Name = 'Integration_Allowed';
        integrationallowed.APTS_Allow_Callout__c = true;
        insert  integrationallowed;
        
        
        Account testAcc = new Account();
        testAcc.Name = 'test';
        insert testAcc;
        
        Apttus__APTS_Agreement__c newAg = new Apttus__APTS_Agreement__c();
        newAg.Name = 'test';
        newAg.Apttus__Account__c = testAcc.Id;
        newAg.Apttus__Status_Category__c ='Request';
        newAg.Apttus__Status__c = 'Request';
        insert newAg;
        
        
        APTS_CreateJSONBodyController sc = new APTS_CreateJSONBodyController();
        sc.createJSONBody(newAg.Id);
    }
}