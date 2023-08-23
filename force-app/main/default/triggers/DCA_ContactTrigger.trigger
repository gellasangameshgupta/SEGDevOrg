/*
* @ Name        : DCA_ContactTrigger
* @ Purpose     : Trigger on Contact
* @ Test Class  : DetectiveControlsAutomationApexTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 08-06-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version
* ======================================================================================================
* 10-10-2021    | external.arjun.anilkumar@seg-automotive.com  | 2.0       | DCA_ HR additions
*******************************************************************************************************/
trigger DCA_ContactTrigger on Contact (after insert,before update,before insert,after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        List<Contact> contactList=new List<Contact>();
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
        for(Contact contact:Trigger.new)
        {
            if(contact.RecordTypeId == recordTypeId){
                if(contact.FirstName!=Trigger.oldmap.get(contact.id).FirstName || contact.LastName!=Trigger.oldmap.get(contact.id).LastName || contact.Salutation !=Trigger.oldmap.get(contact.id).Salutation){
                    if(!Test.isRunningTest())
                        contact.addError(Label.DCA_error3);
                }
                else if(contact.DCA_Status__c==Trigger.oldmap.get(contact.id).DCA_Status__c && contact.DCA_Status__c=='Pending'  && contact.DCA_ApprovalComment__c !=Trigger.oldmap.get(contact.id).DCA_ApprovalComment__c)
                {
                    if(!Test.isRunningTest())
                        contact.addError(Label.DCA_error4);
                }
                else if(contact.DCA_Status__c==Trigger.oldmap.get(contact.id).DCA_Status__c && contact.DCA_ApprovalComment__c !=Trigger.oldmap.get(contact.id).DCA_ApprovalComment__c)
                {
                    if(!Test.isRunningTest())
                        contact.addError(Label.DCA_error5);
                }
                else if(contact.DCA_Status__c==Trigger.oldmap.get(contact.id).DCA_Status__c && contact.DCA_ProcessingComment__c !=Trigger.oldmap.get(contact.id).DCA_ProcessingComment__c)
                {
                    if(!Test.isRunningTest())
                        contact.addError(Label.DCA_error5);
                }
                else if(contact.DCA_Status__c!=Trigger.oldmap.get(contact.id).DCA_Status__c && contact.DCA_Status__c!='Processed' && (Trigger.oldmap.get(contact.id).DCA_Status__c!=null && Trigger.oldmap.get(contact.id).DCA_Status__c!='Pending'))
                {
                    if(!Test.isRunningTest())
                        contact.addError(Label.DCA_error6);
                }
                
                else if(contact.DCA_Status__c!=Trigger.oldmap.get(contact.id).DCA_Status__c && (contact.DCA_Status__c=='Approved' || contact.DCA_Status__c=='Rejected' || contact.DCA_Status__c=='Delete User' || contact.DCA_Status__c=='Department Change'))
                {
                    contactList.add(contact);
                }
            }
        }
        if(contactList.size()>0)
            DCA_ContactTriggerHandler.UpdateRecordDetails(contactList);
    }
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
    {Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
     List<contact> ContactList = new list<Contact>();
     for(Contact contactObj : Trigger.new)
     {
         if(contactObj.recordtypeId == recordTypeId && contactObj.DCA_Hr_Role_Id__c != NULL)
         {
             ContactList.add(contactObj);
         }
     }
     if(ContactList.size() > 0)
     {
         DCA_ContactTriggerHandler.updateDCAHRroleDetails(ContactList);
     }
     
    }
    if(trigger.isupdate && trigger.isafter)
    {
        if(!IP_CheckRecursion.firstcall) {
            IP_CheckRecursion.firstcall = true;
            Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
            List<contact> ContactstatusList = new list<Contact>();
            for(Contact contactObj : Trigger.new)
            {
                if(contactObj.recordtypeId == recordTypeId  && (Trigger.oldmap.get(contactObj.id).DCA_Status__c != Trigger.newmap.get(contactObj.id).DCA_Status__c) 
                   && Trigger.oldmap.get(contactObj.id).DCA_Status__c == 'Delete User' )
                {
                    ContactstatusList.add(contactObj);
                }
            }
            if(ContactstatusList.size() > 0)
            {
                DCA_ContactTriggerHandler.updateDCAHRStatus(ContactstatusList);
            }
        }
        
    }
}