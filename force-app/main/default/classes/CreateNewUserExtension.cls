/**
* An apex page Extensioin that exposes the Save functionality of User.
* Created By: Chitranjan Chetkar
* Created On: 16/05/2018 
*/

public without sharing class CreateNewUserExtension {
         
    private final User user;
    PageReference page1;
    
    public CreateNewUserExtension(ApexPages.StandardController controller) {    
        this.user= (User)controller.getrecord();
        user.UserPreferencesShowFaxToGuestUsers = true;
        user.UserPreferencesShowWorkPhoneToExternalUsers = true;
        user.UserPreferencesShowTitleToExternalUsers = true;
        user.UserPreferencesShowStreetAddressToExternalUsers = true;
        user.UserPreferencesShowPostalCodeToExternalUsers = true;
        user.UserPreferencesShowManagerToExternalUsers = true;
        user.UserPreferencesShowMobilePhoneToExternalUsers = true;   
        user.sysUserCreationApp__c = true;
        User.IsActive = true;
    }
    
    public List<selectOption> getLicense()    {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
       // options.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
          for (UserLicense users :[SELECT Id,Name FROM UserLicense where name =:Label.License_Salesforce_Platform])  
          {    
                options.add(new selectOption(users.Id, users.Name)); //for all records found - add them to the picklist options
          }
        return options; //return the picklist options
    }
    
   public List<selectOption> getProfile() {
                List<selectOption> options1 = new List<selectOption>(); //new list for holding all of the picklist options
                       // options1.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
                //   for (User users : [SELECT Id,UserType FROM User]) { //query for User records with System Admin profile
                //for (Profile users1 :[SELECT Id,Name FROM Profile  where UserLicenseId=:user.UserType])  {    
                for (Profile users1 :[SELECT Id,Name FROM Profile  where name =: Label.Profile_SG_Standard_User])  {    
              options1.add(new selectOption(users1.Id, users1.Name)); //for all records found - add them to the picklist options
                        }      
        return options1; //return the picklist options 
    }  
    
   public List<selectOption> getRole() {
                List<selectOption> options2 = new List<selectOption>(); //new list for holding all of the picklist options
                       // options1.add(new selectOption('', '- None -')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
                //   for (User users : [SELECT Id,UserType FROM User]) { //query for User records with System Admin profile
                //for (Profile users1 :[SELECT Id,Name FROM Profile  where UserLicenseId=:user.UserType])  {    
                for (UserRole users1 :[SELECT Id,Name FROM UserRole  where Name =: Label.Role_Dummy])  {    
              options2.add(new selectOption(users1.Id, users1.Name)); //for all records found - add them to the picklist options
                        }      
        return options2; //return the picklist options 
    }     
    
    public PageReference Cancel(){
        PageReference page1= Page.SEGUser; 
        page1.setRedirect(true);
        return page1;        
    }
    
}