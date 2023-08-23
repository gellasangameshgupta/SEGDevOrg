/*******************************************************************************************************
* 
* @ Name            :   B2B_AccountSharingController
* @ Purpose         :   Controller for flow B2B_Registration
* @ Methods         :   1) setAccountSharing - Create Account sharing rule for particular contact user
*                       params - String
*                       2) checkAccountShare - Check wheter Account sharing is enabled
*                       params - String, string
*                       3) returnUserId - return user ID associated with Contact
*                       params - Id
*                       4) setBuyerPermisisonSet - Set Permission Set of B2B_Buyer to the User
*                       params - String
*                       5) checkBuyerPermissionSetEnabled - Check wheter Permission Set of B2B_Buyer is set
*                       params - Id
* @ Author          :   Aseem Doddamani
* @ Usage           :   1) To create Account sharing rule to Readt/Edit record associated with the respective contact
*                   :   2) Identifies the status of the account setup
*                   :   3) Return User ID associated with Contact
*                   :   4) ISet Permission Set of B2B_Buyer to the User
*                   :   5) Check wheter Permission Set of B2B_Buyer is set
* @ Test Class Name :   B2B_AccountSharingControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   02-07-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_AccountSharingController {
    
    @AuraEnabled
    public static void setAccountSharing(String strContactId) {
        try {
            List<User> list_Users = B2B_AccountSharingController.returnUserId(strContactId);
            List<Contact> list_Contacts = B2B_ContactSelector.getContactIdById(strContactId);
            
            if (!list_Contacts.isEmpty() && !list_Users.isEmpty()) {
                Contact objContact = list_Contacts[0];
                String strUserId = list_Users[0].Id;
                if (objContact.AccountId != null) {
                    AccountShare objAccount = new AccountShare();
                    objAccount.AccountId = objContact.AccountId;
                    objAccount.UserOrGroupId = strUserId;
                    objAccount.AccountAccessLevel = 'Edit';
                    objAccount.ContactAccessLevel = 'Edit';
                    objAccount.CaseAccessLevel = 'Edit';
                    objAccount.OpportunityAccessLevel = 'Edit';
                    
                    // Calling generic method to insert SObject records
                    IFv2_DmlController.GenericDMLOperation(objAccount, 'insert');
                    
                    //set Buyer Permission Set
                    B2B_AccountSharingController.setBuyerPermisisonSet(strContactId);
                }
            }
        } catch(Exception ex) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
        }
    }
    
    public static List<AccountShare> checkAccountShare(String strAccountId, String strUserId) {
        return [SELECT
                Id,
                AccountAccessLevel,
                ContactAccessLevel,
                UserOrGroupId
                FROM
                AccountShare 
                WHERE
                AccountId = :strAccountId
                AND UserOrGroupId = :strUserId
                AND AccountAccessLevel != null 
                AND ContactAccessLevel != null
               ];
    }
    
    public static List<User> returnUserId(Id strContactId) {
        return [SELECT 
                Id
                FROM
                USER 
                WHERE ContactId = :strContactId];
    }
    
    @future
    public static void setBuyerPermisisonSet(String strContactId) {
        try {
            List<PermissionSet> list_PermissionSets = [SELECT 
                                                       Id
                                                       FROM PermissionSet 
                                                       WHERE Name = 'B2B_Buyer'];
            if (!list_PermissionSets.isEmpty()) {
                List<User> list_Users = B2B_AccountSharingController.returnUserId(strContactId);
                
                if (!list_Users.isEmpty()) {
                    PermissionSetAssignment objPermissionSetAssignment = new PermissionSetAssignment (
                        PermissionSetId = list_PermissionSets[0].Id,
                        AssigneeId = list_Users[0].Id
                    );
                    
                    // Calling generic method to insert SObject records
                    IFv2_DmlController.GenericDMLOperation(objPermissionSetAssignment, 'insert');
                }
            }
        } catch(Exception ex) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
        }
    }
    
    public static List<PermissionSetAssignment> checkBuyerPermissionSetEnabled(String strUserId) {
        return [SELECT
                Id,
                AssigneeId
                FROM
                PermissionSetAssignment 
                WHERE
                AssigneeId = :strUserId
                AND
                PermissionSet.Name = 'B2B_Buyer'];
    }
}