/*******************************************************************************************************
* 
* @ Name            :   B2B_ResetPasswordController
* @ Purpose         :   Quick action to reset a User password
* @ Methods         :   resetPassword - Resets a User password
* @ Author          :   Monal Kumar
* @ Usage           :   For setup assitant on contact detail page
* @ Test Class Name :   B2B_ResetPasswordControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   07-07-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_ResetPasswordController {
    
    @AuraEnabled
    public static void resetPassword(String strContactId) {
        List<User> list_Users = [SELECT 
                                 Id,
                                 ContactId 
                                 FROM User 
                                 WHERE ContactId = :strContactId 
                                 AND IsActive = true 
                                 LIMIT 1
                                ];
        
        if (!list_Users.isEmpty()) {
            System.resetPassword(list_Users[0].Id, true);
        }
    }
}