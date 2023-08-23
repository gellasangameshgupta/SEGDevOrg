/*
* @ Name        : DCA_BatchReminder
* @ Purpose     : Batch class for sending Reminder Email to Disciplinary Managers
* @ Test Class  : DCA_BatchPendingNotifyManagerHandlerTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 28-08-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version

*******************************************************************************************************/
global class DCA_BatchReminder implements Database.Batchable<sObject>, Database.Stateful{
    map<string,contact>contactMap;
    global DCA_BatchReminder()
    {
        if(contactMap==null)
        contactMap=new map<string,contact>();
    }
/*    global List<Contact>  start(Database.BatchableContext BC) {
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
        integer escDays=Integer.valueof(Label.DCA_EscalationDays);
        integer escNext=escDays-1;
        List<Contact>ContactList;
        if(Test.isRunningTest())
            ContactList=new List<Contact>([select id,DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact where recordTypeId=:recordTypeId and DCA_Status__c='Pending' and DCA_DisciplinaryManager__c!=''  and createddate>=:Date.Today() and createddate<:Date.Today().addDays(1) limit 5]);
        else
            ContactList=new List<Contact>([select id,DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact where recordTypeId=:recordTypeId and DCA_Status__c='Pending' and DCA_DisciplinaryManager__c!='']);
        System.debug('reminder batch>ContactList>'+ContactList);
     //   List<Contact>ContactList=new List<Contact>([select id,DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact where recordTypeId=:recordTypeId and DCA_Status__c='Pending' and createddate>=:Date.Today().addDays(-escDays) and createddate<:Date.Today().addDays(-escNext) and DCA_DisciplinaryManager__c!='']);
        return ContactList;		
    } */
    
	 global Database.QueryLocator start(Database.BatchableContext BC){
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;   
        datetime startDate =Date.Today();
        datetime endDate=startDate.addDays(1);
        string recordtype=' \''+ recordTypeId + '\'';
        string status=' \'Pending\'';
        string disp=' \''+ '' + '\'';
        string query='select DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact'+
            ' where recordTypeId= \''+recordTypeId +'\''+
            ' and DCA_Status__c= \'Pending\'';
        if(Test.isRunningTest())
            query=query+' and createddate>=:startDate'+' and createddate<:endDate' + ' limit 5';
      return Database.getQueryLocator(query);
   }
        
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        try{
            For(contact contact:scope)
            {
                if(contact.DCA_DisciplinaryManager__c!=null && contact.DCA_DisciplinaryManager__r.email!=null)
                    contactMap.put(contact.DCA_DisciplinaryManager__r.email,contact);
            }
        }Catch(Exception e){System.debug('error>'+e.getMessage());}
        
    }
    
    /*
* Finish method 
*/
    global void finish(Database.BatchableContext BC) {
        try{
            DCA_BatchPendingNotifyManagerHandler.SendReminderEmail(contactMap);
        }Catch(Exception e){System.debug('error>'+e.getMessage());}       
        
    }
}