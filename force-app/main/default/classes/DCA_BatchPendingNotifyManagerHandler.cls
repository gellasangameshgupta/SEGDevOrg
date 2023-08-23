/*
* @ Name        : DCA_BatchPendingNotifyManagerHandler
* @ Purpose     : Handler class for DCA_BatchPendingNotifyManager and DCA_BatchReminder.
* @ Test Class  : DCA_BatchPendingNotifyManagerHandlerTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 28-08-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version

*******************************************************************************************************/

public class DCA_BatchPendingNotifyManagerHandler {
    public static void NotifyEmailOnInsertionN(map<string,contact>contactMap)
    {
        System.debug('inside handler');
      //  map<string,contact>contactMap=new map<string,contact>();
       
        System.debug('inside map>'+contactMap);    
        String emailTemplate='DCA_NotifyAfterInsertTemplate';
        EmailTemplate EmailTemplateRecord = new EmailTemplate();
        if(emailTemplate!=Null)
            EmailTemplateRecord = [SELECT Id,Name,Subject,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplate limit 1];
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        for(String id:contactMap.keyset()){
            Contact record=contactMap.get(id);
            if(record.DCA_DisciplinaryManager__r!=null && record.DCA_DisciplinaryManager__r.email!=null){
                List<string> emailAddresses=new List<string>();
                emailAddresses.add(record.DCA_DisciplinaryManager__r.email);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = emailAddresses;
                    message.optOutPolicy = 'FILTER';
                if(EmailTemplateRecord!=null)
                    message.setTemplateId(EmailTemplateRecord.id);
                message.setWhatId(record.Id);
                message.setSaveAsActivity(false); 
                //Id userId=UserInfo.getUserId();
                message.setTargetObjectId(record.Id);
                message.setTreatTargetObjectAsRecipient(false);
                messages.add(message);
                System.debug('message>'+message);
            }
        }
        System.debug('finish>msgs>'+messages);
        if(messages.size()>0)
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        
        
    }
   
  
    public static void SendReminderEmail(map<string,contact>contactMap)
    {
       /* map<string,contact>contactMap=new map<string,contact>();
        For(contact contact:contactList)
        {
            if(contact.DCA_DisciplinaryManager__c!=null && contact.DCA_DisciplinaryManager__r.email!=null)
            contactMap.put(contact.DCA_DisciplinaryManager__r.email,contact);
        }*/
        System.debug('reminder>map>'+contactMap);
        String emailTemplate='DCA_ReminderEmail';
        EmailTemplate EmailTemplateRecord = new EmailTemplate();
        if(emailTemplate!=Null)
            EmailTemplateRecord = [SELECT Id,Name,Subject,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplate limit 1];
        
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        for(String id:contactMap.keyset()){
            Contact record=contactMap.get(id);
            if(record.DCA_DisciplinaryManager__r!=null && record.DCA_DisciplinaryManager__r.email!=null){
                List<string> emailAddresses=new List<string>();
                emailAddresses.add(record.DCA_DisciplinaryManager__r.email);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new List<string>{record.DCA_DisciplinaryManager__r.email};
                    message.optOutPolicy = 'FILTER';
                if(EmailTemplateRecord!=null)
                    message.setTemplateId(EmailTemplateRecord.id);
                message.setWhatId(record.Id);
                message.setSaveAsActivity(false); 
                message.setTargetObjectId(record.Id);
                message.setTreatTargetObjectAsRecipient(false);
                messages.add(message);
                
            }
        }
        System.debug('finish>msgs reminder>'+messages);
        if(messages.size()>0)
        {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    
}