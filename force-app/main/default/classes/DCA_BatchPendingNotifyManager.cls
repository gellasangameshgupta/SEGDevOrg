/*
* @ Name        : DCA_BatchPendingNotifyManager
* @ Purpose     : Batch class for sending Email notification on insertion.
* @ Test Class  : DCA_BatchPendingNotifyManagerHandlerTest
*
* Date          | Developer Name                      | Version   | Changes
* ======================================================================================================
* 28-08-2020    | external.debasmita.rawooth@absyz.com       | 1.0       | Initial Version

*******************************************************************************************************/
global class DCA_BatchPendingNotifyManager  implements Database.Batchable<sObject>, Database.Stateful{
      private DateTime notifyDate;
	global map<string,contact>contactMap;
    global DCA_BatchPendingNotifyManager(DateTime nDate) {
        notifyDate = nDate;
        if(contactMap==null)
        contactMap=new map<string,contact>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;   
        datetime startDate =notifyDate;
        datetime endDate=notifyDate.addDays(1);
        string recordtype=' \''+ recordTypeId + '\'';
        string status=' \'Pending\'';
        string disp=' \''+ '' + '\'';
        string query='select DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name from Contact'+
            ' where recordTypeId= \''+recordTypeId +'\''+
            ' and DCA_Status__c= \'Pending\''+
            ' and createddate>=:startDate'+
            ' and createddate<:endDate' ;
        if(Test.isRunningTest())
            query=query+' limit 5';
            //GROUP BY DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name limit 20000';
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
        System.debug('finish>>map>>'+contactMap);
        try{
            DCA_BatchPendingNotifyManagerHandler.NotifyEmailOnInsertionN(contactMap);
        }Catch(Exception e){System.debug('error>'+e.getMessage());}
    }
}