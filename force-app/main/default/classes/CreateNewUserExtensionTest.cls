/**
* Test Class to cover An apex page Extensioin that exposes the Save functionality of User.
* Created By: Chitranjan Chetkar
* Created On: 16/05/2018 
*/

@isTest
public class CreateNewUserExtensionTest { 

    public static User newUser; // Variable for holding user details.
    
     @istest
      static void setup() {   
        // UserLicense uLicense = new UserLicense([SELECT Id,Name FROM UserLicense where name =:Label.License_Salesforce_Platform]); 
        newUser = new User(Alias = 'UTEST',
                         Email = 'UTEST@seg-automotive.com',
                        EmailEncodingKey = 'UTF-8',
                        FirstName = 'Test',
                        LastName = 'User',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        sysUserCreationApp__c= True,
                        ProfileId = [SELECT Id FROM Profile WHERE Name =: Label.Profile_SG_Standard_User].Id,
                        NT_User__c = 'ABC5KOR',
                        TimeZoneSidKey = 'Europe/Berlin',
                        UserName = 'UserFortest@seg-automotive.com');

    }    
        
    static testMethod void newUserTest() {
        setup();        
        insert newUser;
     
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.CreateNewUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        CreateNewUserExtension newUserSc = new CreateNewUserExtension(sc);
        newUserSc.getLicense();
        newUserSc.getProfile();
        newUserSc.getRole();
        system.assertEquals('User', newUser.LastName);
        
        // Stop the test.
        test.stopTest(); 
   }
    
    static testMethod void CancelTest() {
        setup();
        insert newUser;
        
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.CreateNewUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        CreateNewUserExtension newUserSc = new CreateNewUserExtension(sc);
        newUserSc.Cancel();
        
        // Stop the test.
        test.stopTest(); 
   }    
    
    static testMethod void newUserDMLExceptionTest() {
        setup();
        // Figure out to make dml user exception take place.
                
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.CreateNewUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        CreateNewUserExtension newUserSc = new CreateNewUserExtension(sc);
        newUserSc.getLicense();
        newUserSc.getProfile();
        
        // Stop the test.
        test.stopTest(); 
   }    
}