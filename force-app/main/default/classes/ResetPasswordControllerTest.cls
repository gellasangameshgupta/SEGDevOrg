@isTest 
public class ResetPasswordControllerTest{
    
    public static User userToCreate;
    
     @TestSetup 
      static void setup() {
       
        userToCreate = [select Id,Name,userName from user where profile.Name = 'System Administrator' and isActive=true limit 1];
        
        update userToCreate;

    }
    
    static testMethod void noEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.PasswordResetPage;
        Test.setCurrentPage(pageRef);
        
        ResetPasswordController newPassword = new ResetPasswordController();
        newPassword.emailString = '';
        newPassword.resetPassword();
            
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();      

    }
    
    static testMethod void wrongEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.PasswordResetPage;
        Test.setCurrentPage(pageRef);
        
        ResetPasswordController newPassword = new ResetPasswordController();
        newPassword.emailString = 'testemail@gmail.com';
        newPassword.resetPassword();
            
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();      

    }
    
    static testMethod void correctEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
		Profile p =[SELECT ID FROM Profile Where Name='SG Standard User'];

		User user1 = new user();
		user1.alias = 'alSGSEG';
		user1.LastName = 'lastName11';
		user1.Username = 'testSGSEG@seg-automotive.com';
		user1.Email = 'testSGSEG@seg-automotive.com';
		user1.TimeZoneSidKey = 'Europe/Berlin';
		user1.LocaleSidKey = 'en_US';
		user1.EmailEncodingKey = 'UTF-8';
		user1.LanguageLocaleKey = 'en_US';
		user1.ProfileId = p.Id;
        user1.NT_User__C = 'TEST001';
		insert user1;
        
        User emailChangedUser = [select Id,Name,Email from User where Id = :user1.Id];
        
        PageReference pageRef = Page.PasswordResetPage;
        Test.setCurrentPage(pageRef);
        
        ResetPasswordController newPassword = new ResetPasswordController();
        newPassword.emailString = emailChangedUser.Email;
        newPassword.resetPassword();
            
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();    

    }
}