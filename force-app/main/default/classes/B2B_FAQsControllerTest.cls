/*******************************************************************************************************
* 
* @ Name            :   B2B_FAQsControllerTest
* @ Purpose         :   Test class for B2B_FAQsController
* @ Author          :   Pradeep Chary
* @ Class Name 		:   B2B_FAQsController
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   09-06-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_FAQsControllerTest {
    
    @TestSetup
    static void createData() {
        B2B_FAQ__c objFAQ = new B2B_FAQ__c(
            Subject__c = 'Test',
            Category__c = 'Test',
            Active__c = true,
            IsGuestVisible__c = true
        );
        
        insert objFAQ;
        
    }
    
    @isTest
    static void testGetAllFAQRecords() {
        Test.startTest();
        
        Map<String, List<B2B_FAQsController.FAQWrapper>> map_FAQByCategory = 
            B2B_FAQsController.getAllFAQRecords();
        
        System.assertEquals(!map_FAQByCategory.isEmpty(), true);
        
        Test.stopTest();
    }
}