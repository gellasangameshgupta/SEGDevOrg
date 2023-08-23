/**
*
* @ Name: AA_EpicTrigger
* @ Purpose: Trigger to share Epic records with Team member users
* @ Test Class Name: AA_AllTriggersTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_EpicTrigger on agf__ADM_Epic__c (after insert,after update){
    if(trigger.isInsert && trigger.isAfter){
        List<agf__ADM_Epic__c> insertEpicList = new List<agf__ADM_Epic__c>();
        for(agf__ADM_Epic__c epic : trigger.new){
            if(epic.agf__Team__c!=null){
                insertEpicList.add(epic);
            }
        }
        //Call method to share epic records with public group
        if(!insertEpicList.isEmpty()){
            AA_ShareTriggerUtils.shareEpic(insertEpicList);
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate){
        List<agf__ADM_epic__c> updateEpicList = new List<agf__ADM_epic__c>();
        for(agf__ADM_epic__c epic : trigger.new){
            if(trigger.oldMap.get(epic.Id).agf__Team__c!=epic.agf__Team__c){
                updateEpicList.add(epic);
            }
        }
        
            
        //Call method to share epic records with new team
        if(!updateEpicList.isEmpty()){
            AA_ShareTriggerUtils.shareEpic(updateEpicList);
            //Call method to delete epic share records for old team
            AA_ShareTriggerUtils.deleteEpicShare(trigger.old);
        }
    }
}