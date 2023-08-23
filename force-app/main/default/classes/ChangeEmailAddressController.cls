/**
* An apex page controller that exposes the Change Email functionality
*/

public without sharing class ChangeEmailAddressController {
    
    public String existingEmail{get; set;} 
    
    public String newEmail{get; set;}
    
    public String confirmEmail{get; set;}
    
    public String lowerExistingEmail{get; set;}
    
    public String lowerNewEmail{get; set;}
    
    public String lowerConfirmEmail{get; set;}
          
    public ChangeEmailAddressController() {}
    
    public List<User> usersList = new List<User>();
       
    public List<User> updateUserList {get;set;}
    
    public PageReference changeEmailIdOnSF() {
        
        if(String.isBlank(existingEmail)) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the Existing E-Mail Address of the User, whose Email needs to be changed.'));
            return null;
        } 
        
        if(String.isBlank(newEmail)) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the New E-Mail Address of the User.'));
            return null;
        }
        
        if(String.isBlank(confirmEmail)) {
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please confirm the New E-Mail Address of the User.'));
            return null;
        }
        
        
        if(String.isNotBlank(existingEmail) && String.isNotBlank(newEmail) && String.isNotBlank(confirmEmail)) {
        
            lowerExistingEmail = existingEmail.toLowerCase();
            
            lowerNewEmail = newEmail.toLowerCase();
            
            lowerConfirmEmail = confirmEmail.toLowerCase();   
        } 
        
        system.debug('DEBUG:: lowerExistingEmail *************' + lowerExistingEmail);
        system.debug('DEBUG:: lowerNewEmail *************' + lowerNewEmail);
        system.debug('DEBUG:: lowerConfirmEmail*************' + lowerConfirmEmail);
      
      if(String.isNotBlank(lowerNewEmail) && String.isNotBlank(lowerExistingEmail) &&  lowerNewEmail.equalsIgnoreCase(lowerExistingEmail)) {
            
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The Existing Email Address and New Email Address are Same. Please check and Retry!'));
            return null;
      }
        
      if(String.isNotBlank(lowerNewEmail) && String.isNotBlank(lowerConfirmEmail) &&  !lowerNewEmail.equalsIgnoreCase(lowerConfirmEmail)) {
            
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The New Email Address and Confirm Email Address are not Same. Please check and Retry!'));
            return null;
      }
        

        List<User> usersList = new List<User>();
        updateUserList = new List<User>();
        
        
        if(String.isNotBlank(lowerNewEmail)) {
            usersList  = [select Id,Email,UserName from User where Email=:lowerExistingEmail  limit 1];
        }
        
        if(!usersList.isEmpty() && String.isNotBlank(lowerNewEmail) && String.isNotBlank(lowerConfirmEmail) && String.isNotBlank(lowerExistingEmail )) {
        
            for(User usr: usersList){
                
                system.debug('DEBUG:: lowerNewEmail*************' + lowerNewEmail);
                usr.Email = lowerNewEmail;
                usr.UserName = lowerNewEmail;
                updateUserList.add(usr);
            }          
        } else {
                if(String.isNotBlank(lowerNewEmail) && String.isNotBlank(lowerConfirmEmail) && String.isNotBlank(lowerExistingEmail )) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'User with the entered E-Mail address does not exist.'));
                    return null;
                }    
        }
        

        try {
            
            if(!updateUserList.isEmpty()){
                
                update updateUserList;
                
                System.debug('DEBUG:: updated users Email ID ' + updateUserList[0].Email);
                System.debug('DEBUG:: updated users User Name ' + updateUserList[0].userName);
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The requested Email Successfully updated in Salesforce.Thank you!'));
                return null;
            }

           
        } catch(Exception me) {
           System.debug('Message: ' + me.getMessage());    
           System.debug('Cause: ' + me.getCause());    
           System.debug('Line number: ' + me.getLineNumber());    
           System.debug('Stack trace: ' + me.getStackTraceString()); 
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,me.getMessage()));
        }

            return null;
    }
 }