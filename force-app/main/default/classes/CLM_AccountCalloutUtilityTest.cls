/**
* @description Test class for CLM_AccountCalloutUtility
* @createdDate Dec 1, 2021
*/
@isTest
public class CLM_AccountCalloutUtilityTest {
    
    @testSetup
    static void testData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
        Account accObj = new Account(
            RecordTypeId = recordTypeId,
            External_Id__c = '97404508',
            Name = 'HunanLRNeoEcoTechnologies',
            IFv2_Country__c = 'India',
            BillingCity = 'Hyd',
            BillingCountry = 'India',
            IFv2_SupplierClassification__c = 'General'
        );
        insert accObj;
    }
    
    @isTest
    static void getAccessTokenTest(){
        Test.setMock(HttpCalloutMock.class, new CLM_AccountCalloutMock());
        Test.startTest();
        String token = new CLM_AccountCalloutUtility().getAccessToken();
        Test.stopTest();
        System.assertEquals('1234', token, 'Failed to get token');
    }
    
    @isTest
    static void bulkUpsertTest(){
        Test.setMock(HttpCalloutMock.class, new CLM_AccountCalloutMock());
        Test.startTest();
        CLM_AccountCalloutUtility.bulkUpsert();
        Test.stopTest();
    }
    
    @isTest
    static void schedulerTest(){
        Test.setMock(HttpCalloutMock.class, new CLM_AccountCalloutMock());
        CLM_AccountCalloutUtility.doNotRun = true;
        CLM_AccountUpdateScheduler sh1 = new CLM_AccountUpdateScheduler();
        String sch = '0 0 23 * * ?';
        Test.startTest();
        System.schedule('Account Update Scheduler', sch, sh1);
        Test.stopTest();
    }
    
}