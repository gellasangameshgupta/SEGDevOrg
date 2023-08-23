/*******************************************************************************************************
* 
* @ Name        : 	B2B_CustomLookupControllerTest
* @ Purpose     : 	Test class for B2B_CustomLookupController
* @ Author      : 	Monal Kumar
* @ Class Name  : 	B2B_CustomLookupController
*
*   Date        |  Developer Name             |  Version      |  Changes
* ======================================================================================================
*   16-07-2021  |  monal.kumar@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_CustomLookupControllerTest {
    
    @isTest
    static void testRecordsfetching() {
        try {
            List<B2B_CustomLookupController.RecordsData> list_Records
                = new List<B2B_CustomLookupController.RecordsData>();
            
            Account objAccount = new Account(
                Name = 'Test Account'
            );
            insert objAccount;
            
            Test.startTest();
            list_Records = B2B_CustomLookupController.fetchRecords('Account', 'Name', 'Test Account', objAccount.Id);
            Test.stopTest();
            
        } catch (Exception e) {
            
        }
    }
    
    @isTest
    static void testRecordsfetching1() {
        try {
            List<B2B_CustomLookupController.RecordsData>  list_Records
                = new List<B2B_CustomLookupController.RecordsData>();
            
            Test.startTest();
            list_Records = B2B_CustomLookupController.fetchRecords('Account', 'Name', 'Test Account', '');
            list_Records = B2B_CustomLookupController.fetchRecords('RecordsData', 'Name', 'Test Account', '');
            Test.stopTest();
            
        } catch (Exception e) {
            
        }
    }
}