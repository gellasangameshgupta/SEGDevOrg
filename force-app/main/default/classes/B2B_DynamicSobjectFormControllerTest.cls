/*******************************************************************************************************
* 
* @ Name            :   B2B_DynamicSobjectFormControllerTest
* @ Purpose         :   Test Class for B2B_DynamicSobjectFormController. 
* @ Author          :   Pradeep Chary
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    01-05-2023     |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*   
*******************************************************************************************************/
@isTest
public class B2B_DynamicSobjectFormControllerTest {

    @TestSetup
    static void createData() {
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.AccountNumber = '1234';
        insert objAccount;
    }

    @isTest
    public static void testGetFieldsetFields() {
        Test.startTest();
        List<B2B_DynamicSobjectFormController.FieldInfo> list_FieldInfos = B2B_DynamicSobjectFormController.getFieldsetFields('Account', 'IFv2_Travels');
        System.assertEquals(true, list_FieldInfos.size() > 0, 'Returns list of fields');
        Test.stopTest();
    }

    @isTest
    public static void testGetRecord() {
        Test.startTest();
        List<Account> list_Accounts = [SELECT Id, Name FROM Account LIMIT 1];
        List<String> fieldNames = new List<String>();
        fieldNames.add('Name');
        fieldNames.add('AccountNumber');
        Map<String, Object> recordValues = B2B_DynamicSobjectFormController.getRecord(list_Accounts[0].Id, fieldNames);
        System.assertEquals(true, recordValues.size() > 0, 'Returns list of records');
        Test.stopTest();
    }

    @isTest
    public static void testSaveRecord() {
        Test.startTest();
        List<Account> list_Accounts = [SELECT Id, Name FROM Account LIMIT 1];
        list_Accounts[0].Phone = '909090';
        B2B_DynamicSobjectFormController.saveRecord(list_Accounts[0]);
        list_Accounts = [SELECT Id, Phone FROM Account LIMIT 1];
        System.assertEquals('909090', list_Accounts[0].Phone, 'Record should be updated');
        Test.stopTest();
    }
}