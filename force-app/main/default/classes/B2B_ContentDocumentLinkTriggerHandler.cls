/*******************************************************************************************************
* 
* @ Name            :   B2B_ContentDocumentLinkTriggerHandler
* @ Purpose         :   This class contains all the handler methods for ContentDocumentLinkTrigger
* @ Author          :   Pradeep Chary
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   05-26-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_ContentDocumentLinkTriggerHandler {
    
    /**
     * Author       : Pradeep Chary
     * Date         : 05-26-2021
     * Params       : List<ContentDocumentLink> list_ContentdocumentLinks - List of ContentDocumentLinks whose Linked Entity is Order
     * Description  : This method updates the Visibilty of the Content document link if the LinkedEntity is Order
    **/
    public static Boolean blnIsRecurssive = false;
    
    public static void insertContentDocumentOnOrderSummary(List<ContentDocumentLink> list_ContentdocumentLinks) {
        /* Used to Activate or deactivate this method */
        Boolean blnDonotExecuteTrigger = IFv2_UtilsController.getTriggerLogic(
            'B2B_ContentDocumentLinkTriggerHandler',
            'insertContentDocumentOnOrderSummary'
        );
        
        /* checking if blnDonotExecuteTrigger variable is true or false */
        if (!blnDonotExecuteTrigger) {
            Map<Id, Id> map_OrderIdByContentDocumentId = new Map<Id, Id>();
            Map<Id, Id> map_OrderIdByOrderSummaryId = new Map<Id, Id>();
            List<ContentDocumentLink> list_ContentDocumentLinksToInsert = new List<ContentDocumentLink>();
            List<String> list_OrderSummaryIds = new List<String>();
            
            for (ContentDocumentLink objContentDocumentLink : list_ContentdocumentLinks) {
                map_OrderIdByContentDocumentId.put(
                    objContentDocumentLink.LinkedEntityId,
                    objContentDocumentLink.ContentDocumentId
                );
            }
            
            if (!map_OrderIdByContentDocumentId.isEmpty()) {
                List<OrderSummary> list_OrderSummaries = [SELECT
                                                          Id,
                                                          OriginalOrderId
                                                          FROM 
                                                          OrderSummary
                                                          WHERE OriginalOrderId = :map_OrderIdByContentDocumentId.keySet()
                                                         ];
                
                for (OrderSummary objOrderSummary : list_OrderSummaries) {
                    map_OrderIdByOrderSummaryId.put(objOrderSummary.OriginalOrderId, objOrderSummary.Id);
                }
                
                for (Id strOrderId : map_OrderIdByContentDocumentId.keySet()) {
                    if (map_OrderIdByOrderSummaryId.containsKey(strOrderId)) {
                        ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                        objContentDocumentLink.ContentDocumentId = map_OrderIdByContentDocumentId.get(strOrderId);
                        objContentDocumentLink.LinkedEntityId = map_OrderIdByOrderSummaryId.get(strOrderId);
                        objContentDocumentLink.ShareType = 'V';
                        objContentDocumentLink.Visibility = 'AllUsers';
                        list_ContentDocumentLinksToInsert.add(objContentDocumentLink);
                        list_OrderSummaryIds.add(objContentDocumentLink.LinkedEntityId);
                    }
                }
                
                B2B_ContentDocumentLinkTriggerHandler.blnIsRecurssive = true;
                
                if (!list_ContentDocumentLinksToInsert.isEmpty()) {
                    IFv2_DmlController.GenericListDMLOperation(list_ContentDocumentLinksToInsert, 'insert');
                }
                
                if (!list_OrderSummaryIds.isEmpty()) {
                    sendInvoiceCompleteNotification(list_OrderSummaryIds);
                }
            }
        }
    }
    
    public static void sendInvoiceCompleteNotification(List<String> list_OrderSummaryIds) {
        /* Used to Activate or deactivate this method */
        Boolean blnDonotExecuteTrigger = IFv2_UtilsController.getTriggerLogic(
            'B2B_ContentDocumentLinkTriggerHandler',
            'sendInvoiceCompleteNotification'
        );
        
        /* checking if blnDonotExecuteTrigger variable is true or false */
        if (!blnDonotExecuteTrigger) {
            List<EmailTemplate> list_EmailTemplates = [SELECT 
                                                       Id,
                                                       Subject,
                                                       Description,
                                                       HtmlValue,
                                                       DeveloperName,
                                                       Body
                                                       FROM EmailTemplate 
                                                       WHERE DeveloperName = :System.Label.CLB2B00054
                                                      ];
            
            Map<String, String> map_OrderOwnerEmailByEmail = new Map<String, String>();
            Map<String, String> map_OrderOwnerEmailByContactId = new Map<String, String>();
            List<OrderSummary> list_OrderSummaries = [SELECT
                                                      Id,
                                                      B2B_OrderOwnerEmail__c,
                                                      B2B_OrderOwner__c
                                                      FROM OrderSummary
                                                      WHERE Id IN :list_OrderSummaryIds
                                                     ];
            
            if (!list_OrderSummaries.isEmpty()) {
                for (OrderSummary objOrderSummary : list_OrderSummaries) {
                    if (String.isNotEmpty(objOrderSummary.B2B_OrderOwnerEmail__c)) {
                        map_OrderOwnerEmailByEmail.put(
                            objOrderSummary.B2B_OrderOwnerEmail__c,
                            objOrderSummary.B2B_OrderOwnerEmail__c
                        );
                    }
                }
                
                List<Contact> list_Contacts = [SELECT 
                                               Id,
                                               Email
                                               FROM CONTACT
                                               WHERE Email IN :map_OrderOwnerEmailByEmail.keySet()
                                              ];
                
                for (Contact objContact : list_Contacts) {
                    map_OrderOwnerEmailByContactId.put(
                        objContact.Email,
                        objContact.Id
                    );
                }
                
                if (!list_EmailTemplates.isEmpty()) {
                    List<Messaging.SingleEmailMessage> list_Messages = new List<Messaging.SingleEmailMessage>();
                    
                    // Query from Organization-Wide Email Address       
                    List<OrgWideEmailAddress> list_OrgWideEmailAddresses = [SELECT
                                                                            Id
                                                                            FROM 
                                                                            OrgWideEmailAddress 
                                                                            WHERE DisplayName = 'SEG ShopMe'
                                                                            LIMIT 1
                                                                           ];
                    
                    for (OrderSummary objOrderSummary : list_OrderSummaries) {
                        Messaging.SingleEmailMessage objMessage = new Messaging.SingleEmailMessage();
                        if (!map_OrderOwnerEmailByContactId.isEmpty() && map_OrderOwnerEmailByContactId.containsKey(objOrderSummary.B2B_OrderOwnerEmail__c)) {
                            // This is important for the merge fields in template to work
                            objMessage.setTargetObjectId(map_OrderOwnerEmailByContactId.get(objOrderSummary.B2B_OrderOwnerEmail__c));
                        } else if (Test.isRunningTest()) {
                            List<Contact> list_TestContacts = [SELECT Id FROM CONTACT where Email <> NULL LIMIT 1];
                            if (!list_TestContacts.isEmpty()) {
                                objMessage.setTargetObjectId(list_TestContacts[0].Id);
                            }
                        }
                        
                        if (!list_OrgWideEmailAddresses.isEmpty()) {
                            objMessage.setOrgWideEmailAddressId(list_OrgWideEmailAddresses[0].Id);
                        }
                        objMessage.setUseSignature(false); 
                        objMessage.setBccSender(false);  
                        objMessage.setSaveAsActivity(false);
                        objMessage.setTemplateId(list_EmailTemplates[0].Id); 
                        
                        // This is important for the merge fields in template to work
                        objMessage.setWhatId(objOrderSummary.Id);
                        if(string.isNotBlank(objOrderSummary.B2B_OrderOwnerEmail__c))
                        {
                            objMessage.toAddresses = new String[] { objOrderSummary.B2B_OrderOwnerEmail__c };

                        }
                        else if (Test.isRunningTest()) {
                            List<Contact> list_TestContacts = [SELECT Id,Email FROM CONTACT LIMIT 1];
                            if (!list_TestContacts.isEmpty()) {
                                objMessage.toAddresses = new String[] { list_TestContacts[0].Email};
                            }
                        }
                        list_Messages.add(objMessage);
                    }
                    
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(list_Messages);
                }
            }
        }
    }
}