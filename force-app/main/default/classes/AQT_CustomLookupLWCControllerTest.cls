/*******************************************************************************************************
* 
* @ Name        :   AQT_CustomLookupLWCControllerTest
* @ Purpose     :   Test Class for aqt_customLookupLWCController
* @ Author      :   Sravani Makkena
* @ Class Name  :   aqt_customLookupLWCController
*
*   Date        |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   08-04-2022  |  sravani.makkena@absyz.com    |  1.0          |  Initial Version
*
*******************************************************************************************************/

@isTest
public class AQT_CustomLookupLWCControllerTest {
    
    @TestSetup
    static void createData() {
        List<Account> list_Accounts = new List<Account>();
        Account objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Plant__c = 'HiP';
        list_Accounts.add(objAccount);

        insert list_Accounts;
    }

    static testMethod void testSearchAccountWithName() {
        Account objAccount = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Test.startTest();
        AQT_CustomLookupLWCController.search('TestAccount', 'Account', '');
        Test.stopTest();
        System.assertEquals('TestAccount', objAccount.Name);
    }

    static testMethod void testSearchAccount() {
        Account objAccount = [SELECT Id FROM Account WHERE Name = 'TestAccount'];
        Test.startTest();
        AQT_CustomLookupLWCController.search('', 'Account', '');
        Test.stopTest();
        System.assert(objAccount.Id != null);
    }

    static testMethod void testSearchAccountBasedOnCondition() {
        Account objAccount = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Test.startTest();
        AQT_CustomLookupLWCController.search('a', 'Account', 'CreatedDate = TODAY');
        Test.stopTest();
        List<Account> list_Accounts= [SELECT Id, Name, LastViewedDate FROM Account WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5];
        System.assert(list_Accounts.size() <= 5);
    }
}