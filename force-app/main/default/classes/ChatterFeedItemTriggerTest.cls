/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest(SeeAllData=true)
private class ChatterFeedItemTriggerTest {
    
    static testMethod void feedItemTest() {
        
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'testseg123@seg-automotive.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        insert u;
        
        //Id recTypeId = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='IFv2_Request__c' ].get(0).Id;
        
        Test.startTest();
        System.runAs(u) {
            
            IFv2_Request__c req = new IFv2_Request__c();
            req.Status__c = 'Draft';
            // req.recordTypeId = recTypeId;
            insert req;
            
            FeedItem fi = new FeedItem (
                ParentId = req.id,
                Body = 'Hello'
            );
            
            insert fi; 
            FeedItem fi2 = [SELECT Id FROM FeedItem WHERE ParentId = :req.Id];
            System.assertEquals(true, fi2 != null); 
        }
        Test.stopTest();
        /*commented for cleaning up of Insightflow 1.0 components 
Test.startTest();
System.runAs(u) {

Request_EMEA__c req = new Request_EMEA__c();
req.Status__c = 'Draft';
req.recordTypeId = recTypeId;
insert req;

FeedItem fi = new FeedItem (
ParentId = req.id,
Body = 'Hello'
);

insert fi; 
FeedItem fi2 = [SELECT Id FROM FeedItem WHERE ParentId = :req.Id];
System.assertEquals(true, fi2 != null); 
}
Test.stopTest();

*/
    }
}