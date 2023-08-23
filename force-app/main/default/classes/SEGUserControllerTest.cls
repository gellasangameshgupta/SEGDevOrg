/**
* Test Class to cover An apex page Controller that refers VF page for holding three user actions: Create User, User Update and Reset Password.
* Created By: Chitranjan Chetkar
* Created On: 16/05/2018 
*/

@isTest
public class SEGUserControllerTest {    
  
    static testMethod void createNewUserTest() {
        
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.SEGUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller      
        SEGUserController newUserSc = new SEGUserController();
        newUserSc.createNewUser();
        newUserSc.updateUser();
        newUserSc.resetPassword();
        
        // Stop the test.
        test.stopTest(); 
   }  
}