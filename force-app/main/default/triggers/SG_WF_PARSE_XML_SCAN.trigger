/**
*
*
* @ Purpose: This Trigger fires if it detects attachments, parses the attached xml file an sends it to SAP
*
* @ Author: Raphael Rugova
*
*
*    Date               |   Developer Name                  |   Version     |   Changes
* ===========================================================================================================
*   (1.0) 04.08.2017    |   raphael.rugova@t-systems.com    | 1.0           |   Initial Version
*   (1.1) 11.08.2017    |   raphael.rugova@t-systems.com    | 1.1           |   Added after update handling, invoked from new attachments
*   (1.2) 05.02.2018    |   peter.bosch@t-systems.com       | 1.2           |   load sequence changed by Reisswolf   
*   (1.3) 23.02.2018    |   aaron.klinge@t-systems.com      | 1.3           |   prevented null pointer in archiving batch
*   (2.0) 08.04.2019    |   pradeep.chary@absyz.com         | 2.0           |   InsighFlow 2.0 code change
*/


trigger SG_WF_PARSE_XML_SCAN on Scan__c (after insert, before update, after update, before delete) {
    
    LIST<Scan__c> scanLIST = new LIST<Scan__c>();
    LIST<Attachment> attachLIST = new LIST<Attachment>();
    
    /* Switch for callout handler class */	
    Boolean switchScanLogic = IFv2_UtilsController.getTriggerLogic('SG_WF_PARSE_XML_SCAN','httpSapCall');
    Boolean deactivateTrigger = IFv2_UtilsController.getTriggerLogic('SG_WF_PARSE_XML_SCAN','completeTrigger');
    
    if(!deactivateTrigger || Test.isRunningTest()) {
        if(Trigger.isBefore && trigger.isUpdate){
            for (Scan__c scan: Trigger.new) 
                if(scan.ArchivingStatus__c=='Archived')
                scan.isArchived__c ='y';
        }
        
        if (Trigger.isAfter) {
            if (Trigger.isUpdate) {
                for (Scan__c scan: Trigger.new) {
                    if(scan.isArchived__c != null ) {
                        if(!String.valueOf(scan.isArchived__c).equalsIgnoreCase('y')
                           && scan.IFv2_SAPStatus__c == 'Draft') {
                               if(String.isBlank(scan.SAP_Response__c)){
                                   scanLIST.add(scan); 
                               }
                           }
                    }
                }
                
                if(!scanLIST.isEmpty()) {
                    attachLIST = [SELECT Id, ParentId 
                                  FROM Attachment 
                                  WHERE ContentType ='application/pdf' AND ParentId IN :scanLIST];
                }
                
                if (!attachLIST.isEmpty()) {
                    for (Scan__c scan: scanLIST) {
                        /* InsightFlow 2.0 - Code update for SAP callout */
                        if(!switchScanLogic || Test.isRunningTest()) {
                            IFv2_SAPCalloutHandler.httpSapCall(scan.Id, scan.Name);    	//InsighFlow 2.0 callout class
                        }
                        /*commented for cleaning up of Insightflow 1.0 components
else {
SG_WF_SAP_COM_STRUC_HANDLER.httpSapCall(scan.Id, scan.Name);	//InsighFlow 1.0 callout class
}   */
                    }
                } else {
                    system.debug('DEBUG::There are no PDF attachements attached to this Scan record.');
                }  
            }
            
            if (Trigger.isInsert) {
                LIST<Id> scanIdLIST = new LIST<Id>();
                for (Scan__c s: Trigger.new) {
                    scanIdLIST.add(s.Id);
                }
                LIST<Attachment> attachLIST = new LIST<Attachment>();
                if(!scanIdLIST.isEmpty()) {
                    attachLIST = [SELECT Id, ParentId FROM Attachment WHERE ContentType ='application/pdf' and ParentId in :scanIdLIST];
                }
                
                if (!attachLIST.isEmpty() ) {
                    for (Scan__c scan: Trigger.new) { 
                        /* InsightFlow 2.0 - Code update for SAP callout */
                        if(!switchScanLogic || Test.isRunningTest()) {
                            IFv2_SAPCalloutHandler.httpSapCall(scan.Id, scan.Name);    	//InsighFlow 2.0 callout class
                        } 
                        /*commented for cleaning up of Insightflow 1.0 components
else {
SG_WF_SAP_COM_STRUC_HANDLER.httpSapCall(scan.Id, scan.Name);	//InsighFlow 1.0 callout class
}  */
                    }
                } else {
                    system.debug('DEBUG::There are no PDF attachements attached to this Scan record.');
                }
            }
        }
        if(Trigger.isBefore && Trigger.isDelete){
            IFv2_Triggerhandler.deleteScanRelatedRecords(Trigger.oldMap);
        } 
    }
    
    /*  if (Trigger.isInsert) {
List<Id> scanIdList = new List<Id>();
for (Scan__c s: Trigger.new) {
scanIdList.add(s.Id);
}
List<Attachment> attachList = [SELECT Id, ParentId FROM Attachment WHERE ParentId in :scanIdList];

if (attachList.size() > 0) {
for (Scan__c s: Trigger.new){ 
SG_WF_SAP_COM_STRUC_HANDLER.httpSapCall(s.Id, s.Name);
}
}
}*/
}