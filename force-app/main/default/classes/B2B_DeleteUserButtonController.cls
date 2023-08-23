/*******************************************************************************************************
* 
* @ Name            :   B2B_DeleteUserButtonController
* @ Purpose         :   To fecilitate serever side logic for b2b_deleteUserButton
* @ Methods         :   updateDeleteStatusAtContact - update contact's status and cancellation reason
*                           params - strRecordId, strReason
* @ Author          :   Monal Kumar
* @ Usage           :   For supporting contact deletion button on user profile
* @ Test Class Name :   B2B_DeleteUserButtonControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   04-06-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public with sharing class B2B_DeleteUserButtonController {
    
    @AuraEnabled
    public static void updateDeleteStatusAtContact(String strUserId, String strReason) {
        try {
            Id idUser = Id.valueOf(strUserId);
            String strContactId = B2B_UserSelector.getContactIdByUserId(idUser);
            
            if (String.isNotBlank(strContactId)) {
                IFv2_DmlController.GenericDMLOperation(
                    new Contact(
                        Id = strContactId,
                        B2B_UserStatus__c = 'Delete User', 
                        B2B_ReasonForDeletion__c = strReason
                    ),
                    'update');
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getContactStatusByUserId(String strUserId) {
        try {
            Id idUser = Id.valueOf(strUserId);
            return B2B_UserSelector.getContactStatus(idUser);
            
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            return null;
        }
    }
}