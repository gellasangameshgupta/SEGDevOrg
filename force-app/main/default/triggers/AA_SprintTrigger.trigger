/**
*
* @ Name: AA_SprintTrigger
* @ Purpose: Trigger to share Sprint records with Team member users
* @ Test Class Name: AA_AllTriggersTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_SprintTrigger on agf__ADM_Sprint__c (after insert,after update){
    if(trigger.isAfter&&trigger.isInsert){
        List<agf__ADM_Sprint__c> insertSprintList = new List<agf__ADM_Sprint__c>();
        for(agf__ADM_Sprint__c spr : trigger.new){
            if(spr.agf__Scrum_Team__c!=null){
                insertSprintList.add(spr);
            }
        }
        //Call method to share sprint records with public group
        if(!insertSprintList.isEmpty()){
            AA_ShareTriggerUtils.shareSprint(insertSprintList);
        }
    }
    
    if(trigger.isAfter&&trigger.isUpdate){
        List<agf__ADM_Sprint__c> updateSprintList = new List<agf__ADM_Sprint__c>();
        for(agf__ADM_Sprint__c spr : trigger.new){
            if(trigger.oldMap.get(spr.Id).agf__Scrum_Team__c!=spr.agf__Scrum_Team__c){
                updateSprintList.add(spr);
            }
        }
       
        //Call method to share sprint records with new team
        if(!updateSprintList.isEmpty()){
            AA_ShareTriggerUtils.shareSprint(updateSprintList);
            //Call method to delete sprint share records for old team
            AA_ShareTriggerUtils.deleteSprintShare(trigger.old);
            
        }
    }
}