/*******************************************************************************************************
* 
* @ Name        : B2B_ResetPasswordControllerTest
* @ Purpose     : Test class for B2B_ResetPasswordController
* @ Author      : Pradeep Chary
* @ Class Name  : B2B_ResetPasswordController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   09-08-2021  |  pradeep.chary@absyz.com             |  1.0          |  Initial Version

*******************************************************************************************************/
@isTest
public class B2B_ResetPasswordControllerTest {
    
    @TestSetup
    static void createData() {
        Contact objcontact = new Contact();
        objcontact.LastName = 'TestLastName';
        insert objcontact;
    }
    
    @isTest
    public static void testResetPassword() {
        Test.startTest();
        Contact objContact = [SELECT 
                              Id
                              FROM Contact 
                              WHERE LastName = 'TestLastName'
                             ];
        
        B2B_ResetPasswordController.resetPassword(objContact.Id);         
        Test.stopTest();
    }   
}