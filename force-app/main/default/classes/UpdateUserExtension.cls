/**
* An apex page Extension that exposes the Update functionality of User.
* Created By: Chitranjan Chetkar
* Created On: 22/05/2018 
*/

public with sharing class UpdateUserExtension {
    
    // Instance fields
    private final User userExt; 
    public String searchTerm {get; set;}
    public String selectedUser {get; set;}
    PageReference page1;
    
    public UpdateUserExtension(ApexPages.StandardController controller) {	
        this.userExt= (User)controller.getrecord();
    }
    
    // JS Remoting action called when searching for a User name
    @RemoteAction
    public static List<User> searchUser(String searchTerm) {
        System.debug('User Name is: '+searchTerm );
        List<User> User= Database.query('Select Id, Name, Email, isActive, NT_User__c from User where NT_User__c like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return User;
    }
    
    // Method used to update email id.
    public Void updateUser() {
        Map<string,User> existingUserMap = new Map<string,User>();
        List<User> existingUsers = [select id,name,NT_User__c,Email from user where NT_User__c != '' or NT_User__c != null];
        userExt.NT_User__c = searchTerm;
        if(userExt.NT_User__c == '' || userExt.NT_User__c == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter NT User Id. e.g ABC123')); 
        }
        else {
            if(userExt.email == '' || userExt.email == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter valid email id. e.g abc@xyz.com')); 
            }
            else {         
                for(User userInstance : existingUsers) {
                    existingUserMap.put(userInstance.NT_User__c,userInstance);
                }
                system.debug('Map size'+existingUserMap.size());
                try { 
                    if(existingUserMap.containskey(userExt.NT_User__c)) {
                        User userUpdate = existingUserMap.get(userExt.NT_User__c);                    
                        ID UserRecID = userUpdate.Id;
                        if(userUpdate.Email == userExt.Email) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email address entered is currently being used. Please provide different email address. e.g abc@xyz.com.'));
                        }
                        else {
                            userUpdate = userExt;
                            userUpdate.id = UserRecID;
                            update userUpdate;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'User Updated Successfully.')); 
                        }
                    }
                    else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'NT UserID does not exist. Please enter existing NT User id.')); 
                    }
                }
                catch(exception ex) {
                    //throw exception
                    System.debug('An unexpected error has occurred: ' + ex.getMessage());
                }
            }	// else condition ends here for email check.
        }	// else condition ends here for NT Iserid check.
    }
    
    // Method is for checking NT user ID and Username on change
    public Void OnChangeNT() {
        System.debug('OnChangeNT called');
        userExt.NT_User__c = selectedUser;
        Map<string,User> existingUserMap = new Map<string,User>();
        // List<User> existingUsersList = [select id,name,isActive, Email,NT_User__c from user where NT_User__c != '' or NT_User__c != null];
        List<User> existingUsers = [select id,FirstName, LastName, Name,isActive, Email,NT_User__c from user where NT_User__c =: searchTerm LIMIT 1];
        // If condition to Bypass default system value..
        if(existingUsers.size() > 0 && existingUsers[0].FirstName != 'Automated' && existingUsers[0].LastName != 'Process')
        {
            userExt.FirstName  = existingUsers[0].FirstName;
            userExt.LastName  = existingUsers[0].LastName;
            userExt.isActive = existingUsers[0].isActive;
            userExt.Email = existingUsers[0].Email;
        }
        else {
            userExt.FirstName  = '';
            userExt.LastName  = '';
            userExt.isActive = false;
            userExt.Email = '';            
        }
    } 
    
    public PageReference back() {
        PageReference page1= Page.SEGUser; 
        page1.setRedirect(true);
        return page1;
    }    
}