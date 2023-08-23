/*******************************************************************************************************
*
* @ Name: AA_TeamMemberTrigger
* @ Purpose: Trigger on Team Member to create public group and add/delete users to/from it which will 
*			 be used in all other sharing
* @ Test Class Name: AA_TeamMemberTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |    Version    |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    |		1.0      |   Initial Version
*
*******************************************************************************************************/
trigger AA_TeamMemberTrigger on agf__ADM_Scrum_Team_Member__c (after insert,after delete,after update,before update){
    
    if(trigger.isAfter&&trigger.isInsert){
        List<Id> insertMemberIdList = new List<Id>();
        List<Id> teamIdList = new List<Id>();
        for(agf__ADM_Scrum_Team_Member__c tm : trigger.new){
            insertMemberIdList.add(tm.id);
        }
        for(agf__ADM_Scrum_Team_Member__c i : trigger.new){
            teamIdList.add(i.agf__Scrum_Team__c);
        }
        //Call method to insert new teammember to existing public group 
        //or create new public group for new team and create corresponding custom setting mapping record
        if(!insertMemberIdList.isEmpty()){
            AA_TeamMemberTriggerUtils.insertInGroup(insertMemberIdList);
        }
    }
       
    if(trigger.isAfter&&trigger.isDelete){
        List<Id> deleteMemberIdList = new List<Id>();
        List<Id> deleteUserSet = new List<Id>();
        for(agf__ADM_Scrum_Team_Member__c tm : trigger.old){
             deleteUserSet.add(trigger.oldMap.get(tm.Id).agf__Member_Name__c);
             deleteMemberIdList.add(trigger.oldMap.get(tm.Id).Id);  
        }
        
        if(!deleteMemberIdList.isEmpty()){
            AA_TeamMemberTriggerUtils.deleteFromGroupEdit(deleteMemberIdList,deleteUserSet); 
        }
    }
    if(trigger.isAfter&&trigger.isUpdate){
        List<Id> updatedMemberIdList = new List<Id>();
        List<Id> deleteMemberIdList = new List<Id>();
        List<Id> deleteUserSet = new List<Id>(); 
        Id GroupId;
        for(agf__ADM_Scrum_Team_Member__c teamMem : trigger.new){
            //Getting old team member details from triger.old when team member is replaced
            if(trigger.oldMap.get(teamMem.Id).agf__Member_Name__c!=teamMem.agf__Member_Name__c){
                System.debug('old>>'+trigger.oldMap.get(teamMem.Id).agf__Member_Name__c+'>>'+teamMem.agf__Member_Name__c);
                updatedMemberIdList.add(teamMem.Id);
                GroupId=teamMem.Id;
                deleteUserSet.add(trigger.oldMap.get(teamMem.Id).agf__Member_Name__c);
                deleteMemberIdList.add(trigger.oldMap.get(teamMem.Id).Id);  
            }
        }
        
        
        //Call method to insert new team member in public group
        if(!updatedMemberIdList.isEmpty()){
            AA_TeamMemberTriggerUtils.insertInGroup(updatedMemberIdList);
            
        }
        //Call method to delete old team member from public group
        if(!deleteMemberIdList.isEmpty()){
            AA_TeamMemberTriggerUtils.deleteFromGroupEdit(deleteMemberIdList,deleteUserSet); 
        }
        
        
    }
}