/*******************************************************************************************************
* 
* @ Name            :   B2B_RegistrationController
* @ Purpose         :   Controller for flow B2B_Registration
* @ Methods         :   1) saveContactDetails - Create contact record, related notes for contact to capture 
*							terms and conditions
*                       	params - List<Contact>
* @ Author          :   Aseem Doddamani
* @ Usage           :   1) To save the details user have entered via registration flow screen,
*                       To save/capture terms and condition accepted by user from registration screen
* @ Test Class Name :   B2B_RegistrationControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   18-05-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class B2B_RegistrationController {
    
    @InvocableMethod
    public static void saveContactDetails(List<Contact> list_Contacts) {
        if (!list_Contacts.isEmpty()) {
            try {
                List<Account> list_Accounts = [SELECT
                                               Id
                                               FROM Account
                                               WHERE Name = 'Default B2B Customer'
                                               AND RecordType.Name = 'B2B Customer'
                                              ];
                
                if (list_Accounts.isEmpty()) {
                    Account objAccount = new Account();
                    objAccount.Name = 'Default B2B Customer';
                    
                    List<RecordType> list_RecordTypes = [SELECT 
                                                         Id 
                                                         FROM RecordType 
                                                         WHERE Name = 'B2B Customer'
                                                        ];
                    if (!list_RecordTypes.isEmpty()) {
                        objAccount.RecordTypeId = list_RecordTypes[0].Id;
                    }
                    
                    IFv2_DmlController.GenericDMLOperation(objAccount, 'insert');
                    
                    list_Accounts = [SELECT
                                     Id
                                     FROM Account
                                     WHERE Name = 'Default B2B Customer'
                                     AND RecordType.Name = 'B2B Customer'
                                    ];
                }
                
                if (!list_Accounts.isEmpty()) {
                    for (Contact objContact : list_Contacts) {
                        objContact.AccountId = list_Accounts[0].Id;
                    }
                    // Calling generic method to insert SObject list records
                    IFv2_DmlController.GenericListDMLOperation(list_Contacts, 'insert');
                    
                    if (!String.isBlank(list_Contacts[0].Id)) {
                        // insert notes for created contact to record the terms and conditions
                        Note objNote = new Note();
                        objNote.ParentId = list_Contacts[0].Id;
                        objNote.Body = 'Time Stamp - ' + System.now();
                        objNote.Title = System.Label.CLB2B00013;
                        
                        // Calling generic method to insert SObject records
                        IFv2_DmlController.GenericDMLOperation(objNote, 'insert');
                        // creating workflow requests
                        createRequests(list_Contacts);
                    }
                }
            } catch(Exception ex) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
            }
        }
    }
    
    public static void createRequests(List<Contact> list_Contacts) {
        List<IFv2_Request__c> list_Requests = new List<IFv2_Request__c>();
        Map<String, Schema.SObjectField> map_fieldsByString = Schema.SObjectType.IFv2_Workflow__c.fields.getMap();
        
        String strQuery = 'SELECT ' + 
            String.join(new List<String>(map_fieldsByString.keySet()), ',') +
            ' FROM IFv2_Workflow__c WHERE Workflow__c = \'ShopMe\' LIMIT 1';
        
        List<IFv2_Workflow__c> list_Workflows = Database.query(strQuery);
        
        if (!list_Workflows.isEmpty()) {
            List<Group> list_Groups = [SELECT
                                       Id
                                       FROM Group
                                       WHERE Type = 'Queue'
                                       AND DeveloperName = 'B2B_AftermarketUsers'
                                      ];
            
            IFv2_Workflow__c objWorkflow = list_Workflows[0];
            
            for (Contact objContact : list_Contacts) {
                // list_Contacts will always contain 1 record, considering this we have DML and SOQL in for loop
                String strRequestId = IFv2_DmlController.insertRequestRecord(objWorkflow);
                
                List<IFv2_Country__mdt> list_Countries = [SELECT 
                                                          Id,
                                                          MasterLabel,
                                                          CountryCode__c
                                                          FROM 
                                                          IFv2_Country__mdt 
                                                          WHERE MasterLabel = :objContact.B2B_Country__c
                                                          AND Status__c = 'Active'
                                                          AND CountryCode__c != null
                                                          LIMIT 1
                                                         ];
                
                IFv2_Request__c objRequest = new IFv2_Request__c(Id = strRequestId);
                objRequest.CompanyName__c = objContact.B2B_CompanyName__c;
                objRequest.ContactName__c = objContact.FirstName + ' ' + objContact.LastName;
                objRequest.CustomerPhone__c = objContact.Phone;
                objRequest.B2B_MobilePhone__c = objContact.MobilePhone;
                objRequest.B2B_Email__c = objContact.Email;
                
                if (!list_Countries.isEmpty()) {
                    objRequest.B2B_VATRegistrationNoForEUCustomers__c = 
                        list_Countries[0].CountryCode__c + objContact.B2B_VATRegistrationNoForEUCustomers__c;
                } else {
                    objRequest.B2B_VATRegistrationNoForEUCustomers__c = objContact.B2B_VATRegistrationNoForEUCustomers__c;
                }
                
                if (!list_Groups.isEmpty()) {
                    objRequest.OwnerId = list_Groups[0].Id;
                }
                
                List<String> list_Addresses = new List<String>();
                List<String> list_OtherAddresses = new List<String>();
                
                // Mailing Address
                if (String.isNotBlank(objContact.MailingStreet)) {
                    list_Addresses.add(objContact.MailingStreet);
                }
                if (String.isNotBlank(objContact.MailingCity)) {
                    list_Addresses.add(objContact.MailingCity);
                }
                if (String.isNotBlank(objContact.MailingState)) {
                    list_Addresses.add(objContact.MailingState);
                }
                if (String.isNotBlank(objContact.MailingCountry)) {
                    list_Addresses.add(objContact.MailingCountry);
                }
                if (String.isNotBlank(objContact.MailingPostalCode)) {
                    list_Addresses.add(objContact.MailingPostalCode);
                }
                // Billing Address
                if (String.isNotBlank(objContact.OtherStreet)) {
                    list_OtherAddresses.add(objContact.OtherStreet);
                }
                if (String.isNotBlank(objContact.OtherCity)) {
                    list_OtherAddresses.add(objContact.OtherCity);
                }
                if (String.isNotBlank(objContact.OtherState)) {
                    list_OtherAddresses.add(objContact.OtherState);
                }
                if (String.isNotBlank(objContact.OtherCountry)) {
                    list_OtherAddresses.add(objContact.OtherCountry);
                }
                if (String.isNotBlank(objContact.OtherPostalCode)) {
                    list_OtherAddresses.add(objContact.OtherPostalCode);
                }
                
                objRequest.Customer_Address__c = String.join(list_OtherAddresses, ', ');
                objRequest.B2B_BillingAddress__c = String.join(list_Addresses, ', ');
                
                list_Requests.add(objRequest);
            }
        }
        
        // Calling generic method to update SObject list records
        IFv2_DmlController.GenericListDMLOperation(list_Requests, 'update');
        
        if (!list_Requests.isEmpty()) {
            String strFields = ', Name, Workflow__c, RequestExtension1__c, RequestExtension2__c, RequestExtension3__c, Account__c';
            List<IFv2_Request__c> list_UpdatedRequests = IFv2_UtilsController.getRequestRecord(list_Requests[0].Id, strFields);
            
            if (!list_UpdatedRequests.isEmpty()) {
                IFv2_HeaderController.submitForApproval(list_UpdatedRequests[0], null);
            }
        }
    }
}