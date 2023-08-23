/*******************************************************************************************************
* 
* @ Name            :   B2B_UserSelector
* @ Purpose         :   Includes method to query user data
* @ Methods         :   1) getContactByuserId - Returns contact id for the user id
*                           params - strUserId
*						2) getContactStatus - Returns the status of the Contact
*                           params - strUserId
*                       Monal Kumar
* @ Usage           :   1) For enabling contact field update of current user
*						2) Identifies the status of the current user
* @ Test Class Name :   B2B_DeleteUserButtonControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   04-06-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public with sharing class B2B_UserSelector {
    
    public static String getContactIdByUserId(Id idUser) {
        List<User> list_Users = [SELECT
                                 ContactId
                                 FROM
                                 User
                                 WHERE
                                 Id =: idUser];
        
        if (!list_Users.isEmpty()) {
            return list_Users[0].ContactId;
        }
        
        return null;
    }
    
    public static String getContactStatus(Id idUser) {
        List<User> list_Users = [SELECT
                                 Contact.B2B_UserStatus__c
                                 FROM
                                 User
                                 WHERE
                                 Id =: idUser];
        
        if (!list_Users.isEmpty()) {
            return list_Users[0].Contact.B2B_UserStatus__c;
        }
        
        return null;
    }
}