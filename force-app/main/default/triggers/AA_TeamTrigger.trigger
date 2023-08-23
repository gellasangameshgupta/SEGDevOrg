/*******************************************************************************************************
*
* @ Name: AA_TeamTrigger
* @ Purpose : Trigger on Team to delete or update public group when Team is deleted or Team Name is updated
* @ Test Class Name : AA_TeamTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
trigger AA_TeamTrigger on agf__ADM_Scrum_Team__c (after insert,after delete,after update){
    /*if(trigger.isInsert && trigger.isAfter){
        List<agf__ADM_Scrum_Team__c> insertTeamList = new List<agf__ADM_Scrum_Team__c>();
        for(agf__ADM_Scrum_Team__c team : trigger.new){
            if(team.id!=null){
                insertTeamList.add(team);
            }
        }
        //Call method to share epic records with public group
        if(!insertTeamList.isEmpty()){
            AA_ShareTriggerUtils.shareTeam(insertTeamList);
        }
    }*/
    if(trigger.isAfter&&trigger.isDelete){
        Set<Id> deleteTeamSet = new Set<Id>();
        for(agf__ADM_Scrum_Team__c team: trigger.old){
            deleteTeamSet.add(team.id);
        }
        //Call method to delete public group if team gets deleted
        if(!deleteTeamSet.isEmpty()){
            AA_TeamTriggerUtils.deletePublicGroup(deleteTeamSet);
        }
    }
    
    if(trigger.isAfter&&trigger.isUpdate){
        Set<Id> updateTeamSet = new Set<Id>();
        Map<string,string> teamNameMap = new Map<string,string>();
        
        for(agf__ADM_Scrum_Team__c tm : trigger.new){
            if(trigger.OldMap.get(tm.id).Name!=tm.Name){
                updateTeamSet.add(tm.Id);
                teamNameMap.put(tm.Name,trigger.oldMap.get(tm.id).Name);
            }
        }
        //Call method to update public group name if team name gets updated
        System.debug('----Check params----'+'updateTeamSet: '+updateTeamSet+'teamNameMap:'+teamNameMap);
        if(!updateTeamSet.isEmpty()){
            AA_TeamTriggerUtils.updateGroupName(updateTeamSet,teamNameMap);
        }
        
        
    }
}