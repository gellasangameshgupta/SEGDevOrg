/***************************************************************************************************************************
* 
* @ Name            :   SEG_B2BBuyerControllerTest
* @ Purpose         :   Test class for SEG_B2BBuyerController
* @ Author          :   Mridul Nathani
*
*   Date            |  Developer Name               |  Version      |  Changes
* ==========================================================================================================================
*   18-01-2023      | mridul.nathani@absyz.com      |  1.0          |  Initial Version
*
***************************************************************************************************************************/
@isTest
public class SEG_B2BBuyerControllerTest {

    @isTest 
    private static void SEG_B2BBuyerControllerMethodsTest() {

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
            SEG_B2BBuyerController.permisson();
            Boolean blnIsAssigned = SEG_B2BBuyerController.isPermissonAlreadyAssigned();
        }

        Test.stopTest();
    }
}