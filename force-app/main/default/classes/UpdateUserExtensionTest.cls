/**
* Test Class to cover An apex page Extensioin that updates User.
* Created By: Chitranjan Chetkar
* Created On: 16/05/2018 
*/

@isTest
public class UpdateUserExtensionTest { 

    public static User newUser; // Variable for holding user details.
    public static User newUser2;
    public static String NT_User = 'ABC5KOR';
    
     @TestSetup 
      static void setup() {       
        newUser = new User(Alias = 'UTEST',
                         Email = 'UTEST@seg-automotive.com',
                        EmailEncodingKey = 'UTF-8',
                        LastName = 'Test User',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        ProfileId = [SELECT Id FROM Profile WHERE Name =: Label.Profile_SEG_User_Creation].Id,
                        NT_User__c = 'ABC5KOR',
                        TimeZoneSidKey = 'Europe/Berlin',
                        UserName = 'UserFortest@seg-automotive.com');
    }    
    
    static testMethod void newUserUpdateTest() {
        setup();
        insert newUser;
        
       // List<User> searchUserList =[Select Id, Name, Email, isActive, NT_User__c from User];
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.UpdateUser;
        Test.setCurrentPage(pageRef);
        
        newUser.Email = ''; // User Email updated
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        UpdateUserExtension newUserSc = new UpdateUserExtension(sc);
        List<User> userList = UpdateUserExtension.searchUser(NT_User);
        newUserSc.updateUser();
        newUserSc.OnChangeNT();
        newUserSc.searchTerm = NT_User;
        newUserSc.OnChangeNT();
       // newUserSc.updateUser();
        newUser.Email = 'UserFortestUpdate@seg-automotive.com'; // User Email updated
        //newUserSc.searchTerm = NT_User;
        newUserSc.updateUser();
        
       // system.assertEquals('Update Test User', newUser.LastName);
        
        // Stop the test.
        test.stopTest(); 
   }    

    static testMethod void BackTest() {
        setup();
        insert newUser;
        
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.UpdateUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        UpdateUserExtension newUserSc = new UpdateUserExtension(sc);
        newUserSc.back();
        
        // Stop the test.
        test.stopTest(); 
   }     
/*    static testMethod void newUserDMLExceptionTest() {
        setup();
        // Figure out to make dml user exception take place.
                
        // Start the test
        test.startTest();
        
        PageReference pageRef = Page.UpdateUser;
        Test.setCurrentPage(pageRef);
        
        //Create a new instance of standard controller
        ApexPages.StandardController sc = new ApexPages.StandardController(newUser);        
        UpdateUserExtension newUserSc = new UpdateUserExtension(sc);
        
        // Stop the test.
        test.stopTest(); 
   }    */
}