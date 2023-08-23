/**
*
*
* @ Purpose: This Trigger fires if a new attachment is inserted and invokes an update on Scan Trigger
*
* @ Author: Raphael Rugova
*
*
*       Date        |   Developer Name                  |   Version     |   Changes
* ===========================================================================================================
*   04.08.2017      |   raphael.rugova@t-systems.com    | 1.0           |   Initial Version
*   08.12.2017      |   aaron.klinge@t-systems.com      | 1.1           |   Added p28 logic 
*   12.12.2017      |   aaron.klinge@t-systems.com      | 1.2           |   Fixed error in update trigger 
*	19.03.2019		|	pradeep.chary@absyz.com			| 2.0			|	InsightFlow 2.0 - update SCAN records for upload of attachment
*/
trigger SG_WF_ATTACHMENT_XML_TRIGGER on Attachment (after insert, after update) {
    
    if (Trigger.isAfter) {
        
        Map<Id,List<String>> attachmentParentIdTitleMap = new Map<Id,List<String>>(); //map of parent id and document title
        //insert part
        if (Trigger.isInsert) {
            
            /*Schema.DescribeSObjectResult resultForObjectp28Log = P28_Log__c.sObjectType.getDescribe();
String p28LogPrefix = resultForObjectp28Log.getKeyPrefix();*/
            String p28LogPrefix = '';
            
            List<Id> attachParentIds = new List<Id>();
            
            for (Attachment a: Trigger.new) {
                if(String.valueOf(a.ParentId).left(3) == p28LogPrefix) {
                    //CSVParser cp = new CSVParser();
                    //cp.parseInboundCSV(a);
                } else {
                    attachParentIds.add(a.ParentId);
                    /* Used to Activate or deactivate this method */
                    /* InsightFlow 2.0 - Iteration 3 SCAN records logic START */
                    Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic('SG_WF_ATTACHMENT_XML_TRIGGER','attachmentHandler');
                    if(!donotExecuteTrigger){
                        
                        if(a.ContentType == 'application/xml' || a.ContentType == 'text/xml') {
                            attachmentParentIdTitleMap.put(a.ParentId,a.Name.substringBefore('.').split('_',3));
                        }
                        /* InsightFlow 2.0 - Iteration 3 SCAN records logic END */
                    }
                    
                }
            }
            
            //get scan objects
            /* List<Scan__c> scanList = new List<Scan__c>();
if(attachParentIds.size() > 0 ) {
scanList = [SELECT Id, Name FROM Scan__c WHERE Id in : attachParentIds];
}

if (scanList.size() > 0) {
update scanList;
}*/
            
            /* InsightFlow 2.0 - Iteration 3 SCAN records logic START*/
            IFv2_TriggerHandler.attachmentHandler(attachParentIds,attachmentParentIdTitleMap);
            
            /* InsightFlow 2.0 - Iteration 3 SCAN records logic END*/
        }
        
        
        //update part
        if (Trigger.isUpdate) {
            
            /*Schema.DescribeSObjectResult resultForObjectp28Log = P28_Log__c.sObjectType.getDescribe();
String p28LogPrefix = resultForObjectp28Log.getKeyPrefix();*/
            String p28LogPrefix = '';
            
            List<Id> attachParentIds = new List<Id>();
            
            for (Attachment a: Trigger.new) {
                if(String.valueOf(a.ParentId).left(3) != p28LogPrefix) {
                    attachParentIds.add(a.ParentId);
                    
                    /* InsightFlow 2.0 - Iteration 3 SCAN records logic START */
                    Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic('SG_WF_ATTACHMENT_XML_TRIGGER','attachmentHandler');
                    if(!donotExecuteTrigger){
                        if(a.ContentType == 'application/xml' || a.ContentType == 'text/xml') {
                            attachmentParentIdTitleMap.put(a.ParentId,a.Name.substringBefore('.').split('_',3));
                        }
                    }
                    /* InsightFlow 2.0 - Iteration 3 SCAN records logic END */
                } 
            }
            
            //get scan objects
            /*List<Scan__c> scanList = new List<Scan__c>();
if(attachParentIds.size() > 0 ) {
scanlist = scanList = [SELECT Id, Name FROM Scan__c WHERE Id in : attachParentIds];
}
if (scanList.size() > 0) {
update scanList;
}*/
            
            /* InsightFlow 2.0 - Iteration 3 SCAN records logic START*/
            IFv2_TriggerHandler.attachmentHandler(attachParentIds,attachmentParentIdTitleMap);
            
            /* InsightFlow 2.0 - Iteration 3 SCAN records logic END*/
            
        }
    }
}