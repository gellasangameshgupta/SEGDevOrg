/*******************************************************************************************************
* 
* @ Name        : 	B2B_AccountSharingControllerTest
* @ Purpose     : 	Test class for B2B_AccountSharingController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_AccountSharingController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   02-07-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_AccountSharingControllerTest {
    
    @TestSetup
    static void createData() {
        
        String strUniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile objProfile = [SELECT 
                              Id 
                              FROM Profile 
                              WHERE Name = 'Customer Community Plus Login User'
                             ];
        
        String strContactRecordTypeId = 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId();
        
        Account objAccount = new Account(
            Name = 'B2B Test Account'
        );
        insert objAccount;
        
        Contact objContact = new Contact(
            LastName = 'LName',
            RecordTypeId = strContactRecordTypeId,
            AccountId = objAccount.Id
        );
        insert objContact;
        
        User objUser = new User(
            Alias = 'standt', 
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = objProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = strUniqueUserName,
            ContactId = objContact.Id
        );
        insert objUser;
        
        AccountShare objAccountShare = new AccountShare(
            AccountId = objAccount.Id,
            UserOrGroupId = objUser.Id,
            AccountAccessLevel = 'Edit',
            ContactAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );
        insert objAccountShare;
    }
    
    @isTest
    public static void testSetAccountSharing() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id,
                              AccountId
                              FROM Contact 
                              WHERE Name = 'LName'
                             ];
        
        B2B_AccountSharingController.setAccountSharing(objContact.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCheckAccountSharing() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id,
                              AccountId,
                              OwnerId
                              FROM Contact 
                              WHERE Name = 'LName'
                             ];
        
        User objUser = [SELECT 
                        Id
                        FROM User 
                        WHERE LastName = 'Testing'
                       ];
        
        List<AccountShare> list_AccountShare = 
            B2B_AccountSharingController.checkAccountShare(objContact.AccountId,objUser.Id);
        System.assert(!list_AccountShare.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void testPermissionSetEnable() {
        Test.startTest();
        
        PermissionSet objPermissionSet = [SELECT
                                          Id
                                          FROM
                                          PermissionSet
                                          WHERE
                                          Name = 'B2B_Buyer'
                                         ];
        
        User objUser = [SELECT 
                        Id,
                        ContactId
                        FROM User 
                        WHERE Contact.Name = 'LName'
                       ];
        
        PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment(
            PermissionSetId = objPermissionSet.Id,
            AssigneeId = objUser.Id);
        
        insert objPermissionSetAssignment;
        
        List<PermissionSetAssignment> list_PermissionSetAssignments = 
            B2B_AccountSharingController.checkBuyerPermissionSetEnabled(objUser.Id);
        System.assert(!list_PermissionSetAssignments.isEmpty());
        Test.stopTest();
    }
}