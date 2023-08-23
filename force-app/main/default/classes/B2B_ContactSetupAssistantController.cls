/*******************************************************************************************************
* 
* @ Name            :   B2B_ContactSetupAssistantController
* @ Purpose         :   To fecilitate server side logic for b2b_contactSetupAssistant
* @ Methods         :   1) getStepInformation - Returns each step flag to show on the component
*                             params - strRecordId
*                             Returns specific wrapper object
*                   :   2) enableBuyerAccount - Enable the contact as Buyer account
*                             params - String, String
*                   :   3) addBuyerGroup - Add record as a memeber of buyer group
*                             params - String, String
*                   :   4) getBuyerGroup - returns the list of buyer group linked to the record
*                             params - String
* @ Author          :   Monal Kumar
* @ Usage           :   For setup assitant on contact detail page
* @ Test Class Name :   B2B_ContactSetupAssistantControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   07-07-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public without sharing class B2B_ContactSetupAssistantController {
    
    @AuraEnabled
    public static SetupData getStepInformation(String strRecordId, String strAccountId) {
        SetupData objSetupData = new SetupData();
        
        try {
            List<Contact> list_Contacts = B2B_ContactSelector.getContactIdById(strRecordId);
            
            if (!list_Contacts.isEmpty()) {
                Contact objContact = list_Contacts[0];
                objSetupData.blnCustomerUserEnabled = (objContact.Users != null && 
                                                       !objContact.Users.isEmpty() ?
                                                       true : 
                                                       false
                                                      );
                
                objSetupData.objContactMailingAddress = objContact.MailingAddress;
                objSetupData.objContactOtherAddress = objContact.OtherAddress;
                
                if (String.isNotBlank(strAccountId)) {
                    List<Account> list_Accounts = B2B_AccountSelector.getAccountById(strAccountId);
                    
                    if (!list_Accounts.isEmpty()) {
                        Account objAccount = list_Accounts[0];
                        objSetupData.blnAccountAvailable = true;
                        objSetupData.strAccountId = objAccount.Id;
                        objSetupData.strAccountName = objAccount.Name;
                        
                        objSetupData.blnBuyerAccountEnabled = (objAccount.BuyerAccounts != null &&
                                                               !objAccount.BuyerAccounts.isEmpty() ?
                                                               true : 
                                                               false
                                                              );
                        
                        List<BuyerGroupMember> list_BuyerGroupMembers = 
                            B2B_BuyerGroupMemberSelector.getBuyerGroupMembersByBuyerId(objAccount.Id);
                        objSetupData.blnBuyerGroupAvailable = (!list_BuyerGroupMembers.isEmpty() ?
                                                               true :
                                                               false
                                                              );
                        
                        if (objAccount.ContactPointAddresses != null && 
                            !objAccount.ContactPointAddresses.isEmpty()) {
                                Boolean hasShipping = false;
                                Boolean hasBilling = false;
                                for (ContactPointAddress objContactPointAddress : objAccount.ContactPointAddresses) {
                                    if (objContactPointAddress.AddressType == 'Billing') {
                                        hasBilling = true;
                                    } else if (objContactPointAddress.AddressType == 'Shipping') {
                                        hasShipping = true;
                                    }
                                }
                                
                                objSetupData.blnContactPointAddressesAvailable = (hasBilling && hasShipping ? true : false);
                            }
                        
                        if (!objSetupData.blnCustomerUserEnabled) {
                            objSetupData.blnAccountSharingRuleEnabled = false;
                            objSetupData.blnBuyerPermissionEnabled = false;
                        } else {
                            List<AccountShare> list_AccountShare = B2B_AccountSharingController.checkAccountShare(
                                strAccountId,
                                objContact.Users[0].Id
                            );
                            objSetupData.blnAccountSharingRuleEnabled = (!list_AccountShare.isEmpty() ?
                                                                         true :
                                                                         false
                                                                        );
                            List<PermissionSetAssignment> list_PermissionSetAssignments = 
                                B2B_AccountSharingController.checkBuyerPermissionSetEnabled(objContact.Users[0].Id);
                            objSetupData.blnBuyerPermissionEnabled = (!list_PermissionSetAssignments.isEmpty() ?
                                                                      true :
                                                                      false
                                                                     );
                        }
                    }
                }
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return objSetupData;
    }
    
    @AuraEnabled
    public static void enableBuyerAccount(String strAccountId, String strAccountName) {
        try {
            if (String.isNotBlank(strAccountId)) {
                BuyerAccount objBuyerAccount = new BuyerAccount(
                    BuyerId = strAccountId,
                    Name = strAccountName,
                    IsActive = true
                );
                
                insert objBuyerAccount;
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
    }
    
    @AuraEnabled
    public static List<TableData> addBuyerGroup(String strAccountId, String strBuyerGroupId) {
        try {
            if (String.isNotBlank(strAccountId) && String.isNotBlank(strBuyerGroupId)) {
                insert new BuyerGroupMember(
                    BuyerId = strAccountId,
                    BuyerGroupId = strBuyerGroupId
                );
                
                return getBuyerGroup(strAccountId);
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return new List<TableData>();
    }
    
    @AuraEnabled
    public static List<TableData> getBuyerGroup(String strAccountId) {
        List<TableData> list_TableData = new List<TableData>();
        
        try {
            if (String.isNotBlank(strAccountId)) {
                List<BuyerGroupMember> list_BuyerGroupMembers = [SELECT
                                                                 Id,
                                                                 BuyerGroup.Name,
                                                                 Buyer.Name
                                                                 FROM BuyerGroupMember
                                                                 WHERE BuyerId = :strAccountId
                                                                ];
                
                for (BuyerGroupMember objBuyerGroupMember : list_BuyerGroupMembers) {
                    TableData objTableData = new TableData();
                    objTableData.strRecordId = objBuyerGroupMember.Id;
                    objTableData.strGroupName = objBuyerGroupMember.BuyerGroup.Name;
                    objTableData.strBuyerName = objBuyerGroupMember.Buyer.Name;
                    list_TableData.add(objTableData);
                }
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return list_TableData;
    }
    
    @AuraEnabled
    public static List<ContactPointAddress> getContactPointAddresses(String strAccountId, String strAddressType) {
        
        List<ContactPointAddress> list_ContactPointAddresses = new List<ContactPointAddress>();
        
        try {
            if (String.isNotBlank(strAccountId)) {
                list_ContactPointAddresses = [SELECT
                                              Id,
                                              Street, 
                                              State, 
                                              City, 
                                              Country, 
                                              PostalCode 
                                              FROM 
                                              ContactPointAddress 
                                              WHERE ParentId = : strAccountId
                                              AND
                                              AddressType = : strAddressType
                                             ];
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return list_ContactPointAddresses;
    }
    
    public class SetupData {
        @AuraEnabled public Boolean blnAccountAvailable = false; // Account availability step's status
        @AuraEnabled public Boolean blnBuyerAccountEnabled = false; // Whether buyer account is enabled
        @AuraEnabled public Boolean blnBuyerGroupAvailable = false; // Buyer group's availability status
        @AuraEnabled public Boolean blnCustomerUserEnabled = false; // Whether customer user is enabled
        @AuraEnabled public Boolean blnContactPointAddressesAvailable = false; // Whether Contact Point Address is available
        @AuraEnabled public String strAccountId; // AccountId for enabling buyer Account
        @AuraEnabled public String strAccountName; // Account Name for enabling buyer Account
        @AuraEnabled public Object objContactMailingAddress; // Contact's Mailing address to copy on contact point address
        @AuraEnabled public Object objContactOtherAddress; // Contact's Other Address to copy on contact point address
        @AuraEnabled public Boolean blnAccountSharingRuleEnabled = false; // Whether Account Sharing is enabled
        @AuraEnabled public Boolean blnBuyerPermissionEnabled = false; // Whether Buyer Permission Set is enabled
    }
    
    public class TableData {
        @AuraEnabled public String strRecordId;
        @AuraEnabled public String strGroupName;
        @AuraEnabled public String strBuyerName;
    }
}