global class DCA_NotifyUsersOnRejectionBatch  implements Database.Batchable<sObject>, Database.Stateful,schedulable{
    global map<string,list<contact>>contactMap;
    global map<string,string>contactMapwithattachment;
    global map<string,string>contactNameMap;
    global string HEADERvALUE= 'SAP System, Role , Auth Type , Deciplinary manager';
    global string NEWLINE= '\n';
    global string header = HEADERvALUE+NEWLINE;
    global String PLAINTEXT;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('inside');
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;   
        string recordtype=' \''+ recordTypeId + '\'';
        string status=' \'Pending\'';
        string disp=' \''+ '' + '\'';
        string query='select email,name ,DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name, DCA_NameofSAPSystem__c,DCA_user__r.name, DCA_Role__c, DCA_AuthType__c, DCA_User__r.email,DCA_User__c from Contact'+
            ' where recordTypeId= \''+recordTypeId +'\''+
            ' and DCA_Status__c= \'Rejected\'' ;
        system.debug('query '+query);
        if(Test.isRunningTest())
            query=query+' limit 5';
        //GROUP BY DCA_DisciplinaryManager__c,DCA_DisciplinaryManager__r.email,DCA_DisciplinaryManager__r.Name limit 20000';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        
        string SEPERATOR= '"';
        string SEPERATORcOLUMN= '","';
        string ENDLINE= '"\n';
        if(contactMap==null)
            contactMap=new map<string,List<contact>>();
        if(contactNameMap==null)
            contactNameMap=new map<string,string>();
        if(contactMapwithattachment==null)
            contactMapwithattachment=new map<string,string>();
        try{system.debug('inside try');
            system.debug('scope '+scope);
            For(contact contact:scope)
            {system.debug('Contact '+contact);system.debug('contact.DCA_User__r.email '+contact.DCA_User__r.email);
             list<Contact> conList = new list<Contact>();
             if((contact.DCA_User__c!=null && contact.DCA_User__r.email !=null))
             {system.debug('conList '+conList);     
              if((contactMap.get(contact.DCA_User__r.email) == NULL))
              {
                  conList.add(contact);
              }
              else
              {
                  conList = contactMap.get(contact.DCA_User__r.email);system.debug('conList.size()'+conList.size());
                  conlist.add(contact);system.debug('conList.size()'+conList.size());  
              }
              contactMap.put(contact.DCA_User__r.email,conlist);
              contactNameMap.put(contact.DCA_User__r.email, contact.name);
              
             }
             else if((contact.DCA_User__c == null && contact.Email !=null))
             {system.debug('conList '+conList);     
              if((contactMap.get(contact.Email) == NULL))
              {
                  conList.add(contact);
              }
              else
              {
                  conList = contactMap.get(contact.Email);system.debug('conList.size()'+conList.size());
                  conlist.add(contact);system.debug('conList.size()'+conList.size());  
              }
              contactMap.put(contact.Email,conlist);
              contactNameMap.put(contact.Email, contact.name);
              
             }
            } 
            system.debug('contactMap '+contactMap);
            
            for (string key : contactMap.keySet()) {
                string atachmentdata = header;
                string finalattachmentdata = '';
                list<Contact> contactlistRejected = new list<Contact>();
                contactlistRejected = contactMap.get(key);system.debug('key '+key+' size '+contactlistRejected.size());
                for (Contact conObj :contactlistRejected )
                {
                    finalattachmentdata = SEPERATOR+conObj.DCA_NameofSAPSystem__c+SEPERATORcOLUMN+conObj.DCA_Role__c+SEPERATORcOLUMN+conObj.DCA_AuthType__c+SEPERATORcOLUMN+conObj.DCA_DisciplinaryManager__r.Name+ENDLINE;
                    atachmentdata = atachmentdata +finalattachmentdata;
                }
                contactMapwithattachment.put(key,atachmentdata);
                // The "key" variable is also available inside the loop
                // List<String> toAddresses = emailDiseaseMap.get(key);
                // ... emailing logic
            }
            
           }Catch(Exception e){System.debug('error>'+e.getMessage());}
        
    }
    
    /*
* Finish method 
*/
    global void finish(Database.BatchableContext BC) {
        System.debug('finish>>map>>'+contactMap);
        System.debug('finishattachment>>map>>'+contactMapwithattachment);
        try{
            List<Messaging.SingleEmailMessage > lstMails = new List<Messaging.SingleEmailMessage>();
            for (string key : contactMapwithattachment.keySet()) 
            {
                PLAINTEXT = '<html lang="en"><body>'+
                    'Dear '+ contactNameMap.get(key)+','+
                    '<br><br>'+
                    'During the currently ongoing Detective Controls Assignment your disciplinary manager decided to revoke some of your SAP access rights'+
                    '<br><br>'+
                    'In the attached Excel file you can see more details about the revoked SAP access rights. From your side there are no further activities necessary.'+
                    '<br><br>'+
                    'If you have any questions regarding the revoking, please contact your disciplinary manager.'+
                    '<br><br>'+
                    'Best Regards,'+
                    '<br>'+
                    'SEG Authorization Team'+
                    '<br>'+
                    '-----------------------------------------------------------------------------------'+
                    '<br>'+
                    'Please do not reply to this automatically generated e-mail.'+
                    '<b>'+
                    '</body></html>'; 
                
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                // System.debug('DEBUG::finalstr******' + finalstr);
                String[] toAddresses = new list<string>();
                toAddresses.add(key);toAddresses.add('external.arjun.anilkumar@seg-automotive.com');
                blob csvBlob = Blob.valueOf(contactMapwithattachment.get(key));
                csvAttc.setFileName('AccessrevokedList.csv');
                csvAttc.setBody(csvBlob);
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                email.setSubject('Access rights revoked');
                email.setToAddresses( toAddresses );
                email.setHtmlBody(PLAINTEXT);
                System.debug('DEBUG::csvAttc******' + csvAttc);
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                lstMails.add(email);
               // Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
               // system.debug('email '+r);
            }
          Messaging.sendEmail(lstMails);  
        }Catch(Exception e){System.debug('error>'+e.getMessage());}
    }
    global void execute(SchedulableContext SC) {
        database.executebatch(new DCA_NotifyUsersOnRejectionBatch());
    }
}