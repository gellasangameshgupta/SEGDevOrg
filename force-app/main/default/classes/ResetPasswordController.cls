/**
* An apex page controller that exposes the reset password functionality
*/

public with sharing class ResetPasswordController {
    
    public String emailString{get; set;} 
    
    public String lowerCaseEmail;
          
    public resetPasswordController() {}
    
    List<User> usersList = new List<User>();
    
    public PageReference resetPassword() {
    
        
        if(String.isNotBlank(emailString)) {
        
            lowerCaseEmail = emailString.toLowerCase();
            
        } else {
        
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the E-Mail Address of the User, whose password needs to be reset. '));
             return null;
        }       

        List<User> usersList = [select Id,Email from User where Email=:lowerCaseEmail ];
        
        if(!usersList.isEmpty()) {
        
            for(User usr: usersList){
            
                System.ResetPasswordResult result = System.resetPassword(usr.Id,true);
                system.debug('DEBUG:: result*************' + result);
            }
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Please inform the User that their password has been reset and they would be shortly receiving an E-Mail with instructions to reset their Insight Account password.'));
            return null;
            
        } else {
        
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'User with the entered E-Mail address does not exist.'));
            return null;
        }
        return null;
   }

public PageReference Back()
    {
            PageReference page1= Page.SEGUser; 
            page1.setRedirect(true);
        return page1;
    }    
   
 }