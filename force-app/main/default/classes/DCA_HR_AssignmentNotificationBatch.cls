/*
* @ Name        : DCA_HR_AssignmentNotificationBatch
* @ Purpose     : Batch class for sending initial Email notification to deciplinary managers.
* @ Test Class  : DCA_BatchPendingNotifyManagerHandlerTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 20-10-2021    | external.arjun.anilkumar@seg-automotive.com  | 1.0       | Initial Version

*******************************************************************************************************/
global class DCA_HR_AssignmentNotificationBatch  implements Database.Batchable<sObject>, Database.Stateful{
    
    global String jobName;
    public DCA_HR_AssignmentNotificationBatch(String specifyJobName) {
        jobName = specifyJobName;
    }
    global map<string,contact>contactMap = new map<string,contact>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name = 'DCA HR Apps' limit 1].id;   
        system.debug('jobName '+jobName);
        string recordtype=' \''+ recordTypeId + '\'';
        string status=' \'Pending\'';
        string disp=' \''+ '' + '\'';
        string query='select DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact'+
            ' where recordTypeId= \''+recordTypeId +'\''+
            ' and DCA_Status__c= \'\'';
        system.debug('query '+query);
        if(Test.isRunningTest())
            query=query+' limit 5';
        //GROUP BY DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name limit 20000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        try{
            For(contact contact:scope)
            {system.debug('contact.DCA_DisciplinaryManager__c '+contact.DCA_DisciplinaryManager__c);
             system.debug('contact.DCA_DisciplinaryManager__r.email '+contact.DCA_DisciplinaryManager__r.email);
             if(contact.DCA_DisciplinaryManager__c!=null && contact.DCA_DisciplinaryManager__r.email!=null)
             {
                 system.debug('inside if');
                 contactMap.put(contact.DCA_DisciplinaryManager__r.email,contact);
             }
            }
            System.debug('inside map>'+contactMap);
        }
        Catch(Exception e)
        {System.debug('error>'+e.getMessage());}
        
    }
    
    /*
* Finish method 
*/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish>>map>>'+contactMap);
        try{
            System.debug('inside handler');
            //  map<string,contact>contactMap=new map<string,contact>();
            system.debug('jobName '+jobName);
            System.debug('inside map>'+contactMap);    
            String emailTemplateInsert='DCA_HR_After_Insert';
            String emailTemplateRemainder='DCA_ReminderEmail';
            EmailTemplate EmailTemplateRecord = new EmailTemplate();
            if(emailTemplateInsert!=Null && jobName == 'Insert')
                EmailTemplateRecord = [SELECT Id,Name,Subject,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplateInsert limit 1];
            else if(emailTemplateRemainder != NULL && jobName == 'Remainder')
                EmailTemplateRecord = [SELECT Id,Name,Subject,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplateRemainder limit 1];
            
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
            for(String id:contactMap.keyset()){
                system.debug('record '+contactMap.get(id));
                system.debug('id '+id);
                Contact record=contactMap.get(id);
                if(record.DCA_DisciplinaryManager__r!=null && record.DCA_DisciplinaryManager__r.email!=null){
                    List<string> emailAddresses=new List<string>();
                    emailAddresses.add(record.DCA_DisciplinaryManager__r.email);
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.toAddresses = emailAddresses;
                    // message.optOutPolicy = 'FILTER';
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
            {system.debug('inside size 0');
              Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
             system.debug('results '+results);
            }
            
        }Catch(Exception e){System.debug('error>'+e.getMessage());}
    }
}