/***************************************************************************************************************
* 
* @ Name            :   B2B_BuyerPermissionControllerTest
* @ Purpose         :   Test class for B2B_BuyerPermissionController
* @ Author          :   Mridul Nathani
*
*   Date            |  Developer Name               |  Version      |  Changes
* ==============================================================================================================
*   18-01-2023      | mridul.nathani@absyz.com      |  1.0          |  Initial Version
*   26-01-2023      | prathiksha.suvarna@absyz.com  |  1.1          |  Updated Version
****************************************************************************************************************/
@isTest
public class B2B_BuyerPermissionControllerTest {
    
    @isTest 
    private static void B2B_BuyerPermissionControllerTest() {
        
        Account objAccount = new Account(
            Name = 'Community'
        );
        insert objAccount;
        
        Contact objContact = new Contact(
            FirstName = 'Joe',
            LastName = 'Smith',
            AccountId = objAccount.Id
        );
        insert objContact;
        
        Profile objProfile = [SELECT 
                              Id 
                              FROM Profile 
                              WHERE Name = 'Customer Community Plus Login User'];
        
        User objUser = new User(
            Alias = 'commUser',
            ContactId = objContact.Id,
            Email ='communityuser@testorg.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            ProfileId = objProfile.Id,
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            UserName='testpermissionsetuser@testorg.com'
        );
        insert objUser;
        
        Test.startTest();
        
        System.runAs(objUser) {
            B2B_BuyerPermissionController.permisson();
            Boolean blnIsAssigned = B2B_BuyerPermissionController.isPermissonAlreadyAssigned();
        }
        
        Test.stopTest();
    }
}