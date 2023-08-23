/**
* An apex page controller that used for navigating to differnt pages( Create User, User Update and Reset Password ).
* Created By: Chitranjan Chetkar
* Created On: 22/05/2018 
*/

public with sharing class SEGUserController {

	PageReference page1;
    
    public PageReference createNewUser() {
		PageReference page1= Page.createNewUser;
        page1.setRedirect(true);
    return page1;
	}
    
    public PageReference updateUser() {
        PageReference page1= Page.updateUser; 
        page1.setRedirect(true);
    return page1;
	}       
    
    public PageReference resetPassword() {
        PageReference page1= Page.PasswordResetPage; 
        page1.setRedirect(true);
    return page1;
	}    
}