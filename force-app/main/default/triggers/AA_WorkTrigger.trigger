/**
*
* @ Name: AA_WorkTrigger
* @ Purpose: Trigger to share Work records with Team member users
* @ Test Class Name: AA_AllTriggersTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_WorkTrigger on agf__ADM_Work__c (after insert, after update){
    if(trigger.isAfter&&trigger.isInsert){
        List<agf__ADM_Work__c> insertWorkList = new LisT<agf__ADM_Work__C>();
        for(agf__ADM_Work__c wrk : trigger.new){
            if(wrk.agf__Scrum_Team__c!=null){
                insertWorkList.add(wrk);
            }
        }
        //Call method to share work records with public group
        if(!insertWorkList.isEmpty()){
        	AA_ShareTriggerUtils.shareWork(insertWorkList);
        }
    }
    
    if(trigger.isAfter&&trigger.isUpdate){
        List<agf__ADM_Work__c> updateWorkList = new List<agf__ADM_Work__C>();
        for(agf__ADM_Work__c wrk : trigger.new){
            if(trigger.oldMap.get(wrk.id).agf__Scrum_Team__c!=wrk.agf__Scrum_Team__c){
                updateWorkList.add(wrk);
            }
        }
        
        
        //Call method to share work records with new team
        if(!updateWorkList.isEmpty()){
            AA_ShareTriggerUtils.shareWork(updateWorkList);
            //Call method to delete work share records for old team
            AA_ShareTriggerUtils.deleteWorkShare(trigger.old);
        }
    }
}