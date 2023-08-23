/*******************************************************************************************************
* 
* @ Name        : B2B_DeleteUserButtonControllerTest
* @ Purpose     : Test class for B2B_DeleteUserButtonController
* @ Author      : Monal Kumar
* @ Class Name  : B2B_DeleteUserButtonController
*
*   Date        |  Developer Name       		|  Version      |  Changes
* ======================================================================================================
*   10-06-2021  |  monal.kumar@absyz.com        |  1.0          |  Initial Version

*******************************************************************************************************/

@isTest
public class B2B_DeleteUserButtonControllerTest {
    
    @TestSetup
    static void createData() {
        UserRole objPortalRole = [SELECT Id 
                                  FROM UserRole 
                                  WHERE PortalType = 'None' 
                                  LIMIT 1];
        
        Profile objProfile = [SELECT Id 
                              FROM Profile 
                              WHERE Name = 'System Administrator'];
        
        User objAdminUser = new User(
            UserRoleId = objPortalRole.Id,
            ProfileId = objProfile.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email = 'bruce.wayne@wayneenterprises.com',
            EmailEncodingKey = 'UTF-8',
            Firstname = 'Bruce',
            Lastname = 'Wayne',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Chicago'
        );
        Database.insert(objAdminUser);
        
        System.runAs(objAdminUser) {
            Account objAccount = new Account(
                Name = 'TestAccount',
                OwnerId = objAdminUser.Id
            );
            Database.insert(objAccount);
            
            String strContactRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId();
            
            //Create contact
            Contact objContact = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = objAccount.Id,
                Email = System.now().millisecond() + 'test@test.com',
                recordTypeId = strContactRecordTypeId
            );
            Database.insert(objContact);
            
            //Create user
            Profile objPortalProfile = [SELECT Id 
                                        FROM Profile 
                                        WHERE Name = 'Customer Community Plus Login User' 
                                        LIMIT 1];
            
            User objPortalUser = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = objContact.Id,
                ProfileId = objPortalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(objPortalUser);
        }
    }
    
    @isTest
    public static void testUpdateDeleteStatusAtContact() {
        User objUser = [SELECT Id 
                        FROM User 
                        WHERE Email = 'test12345@test.com'
                        LIMIT 1];
        
        System.runAs(objUser) {
            B2B_DeleteUserButtonController.updateDeleteStatusAtContact(objUser.Id, 'Testing');
        }
    }
    
    @isTest
    public static void testGetContactStatusByUserId() {
        User objUser = [SELECT Id 
                        FROM User 
                        WHERE Email = 'test12345@test.com'
                        LIMIT 1];
        
        System.runAs(objUser) {
            String strStatus = 
                B2B_DeleteUserButtonController.getContactStatusByUserId(objUser.Id);
            
            System.assertEquals(strStatus, 'Pending');
        }
    }
    
    @isTest
    public static void testUpdateDeleteStatusAtContactNegative() {
        try {
            B2B_DeleteUserButtonController.updateDeleteStatusAtContact('###test', 'Testing');
        } catch (Exception e) {
            
        }
    }
    
    @isTest
    public static void testGetContactStatusByUserIdNegative() {
        try {
            B2B_DeleteUserButtonController.getContactStatusByUserId('###test');
        } catch(Exception e) {
            
        }
    }
}