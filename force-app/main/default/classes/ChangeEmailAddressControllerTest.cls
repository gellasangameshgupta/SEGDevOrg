@isTest 
public class ChangeEmailAddressControllerTest{

    public static User userToCreate;
    
     @TestSetup 
      static void setup() {
       
        userToCreate = [select Id,Name,userName,Email from user where profile.Name = 'System Administrator' and isActive=true limit 1];
        
        update userToCreate;

    }
    
    static testMethod void noExistingEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.ChangeEmailAddressPage;
        Test.setCurrentPage(pageRef);
        
        ChangeEmailAddressController newEmail1 = new ChangeEmailAddressController();
        newEmail1.existingEmail = '';
        newEmail1.changeEmailIdOnSF();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest(); 
   }
   
   static testMethod void noNewEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.ChangeEmailAddressPage;
        Test.setCurrentPage(pageRef);
        
        ChangeEmailAddressController newEmail2 = new ChangeEmailAddressController();
        newEmail2.existingEmail = 'test@de.bosch.com';
        newEmail2.newEmail = '';
        newEmail2.changeEmailIdOnSF();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest(); 
   }
     
     static testMethod void noConfirmEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.ChangeEmailAddressPage;
        Test.setCurrentPage(pageRef);
        
        ChangeEmailAddressController newEmail3 = new ChangeEmailAddressController();
        newEmail3.existingEmail = 'test@de.bosch.com';
        newEmail3.newEmail = 'Test2@de.bosch.com';
        newEmail3.confirmEmail = '';
        newEmail3.changeEmailIdOnSF();
        
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest(); 
   }

    static testMethod void positiveWithAllValuesTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        User testUser = [select Id,Name,UserName,Email from User where Id = :userToCreate.Id];
        
        PageReference pageRef = Page.ChangeEmailAddressPage;
        Test.setCurrentPage(pageRef);
        
        ChangeEmailAddressController newEmail = new ChangeEmailAddressController();
        newEmail.existingEmail = userToCreate.Email;
        newEmail.newEmail = 'test@seg-automotive.com';
        newEmail.confirmEmail = 'test@seg-automotive.com';
        newEmail.changeEmailIdOnSF();
            
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();      

    }
    
    static testMethod void wrongEmailTest() {
    
        setup();
        
        // Start the test, this changes governor limit context to 
        // that of trigger rather than test. 
        test.startTest();
        
        PageReference pageRef = Page.ChangeEmailAddressPage;
        Test.setCurrentPage(pageRef);
        
        ChangeEmailAddressController newEmail = new ChangeEmailAddressController();
        newEmail.existingEmail = 'Test@de.bosch.com';
        newEmail.newEmail = 'test@seg-automotive.com';
        newEmail.confirmEmail = 'test@seg-automotive.com';
        newEmail.changeEmailIdOnSF();     

    }
}