/**
*
* @ Name: AA_BuildTrigger
* @ Purpose: Trigger to share Build records with Team member users
* @ Test Class Name: AA_ShareTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.08.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_BuildTrigger on agf__ADM_Build__c (after insert, after update){
    if(trigger.isAfter&&trigger.isInsert){
        List<agf__ADM_Build__c> insertBuildList = new LisT<agf__ADM_Build__c>();
        System.debug('entering trigger');
        for(agf__ADM_Build__c bld : trigger.new){
            System.debug('team>>'+bld.Scrum_Team__c);
            if(bld.Scrum_Team__c!=null){
                insertBuildList.add(bld);
            }
        }
        //Call method to share build records with public group
        if(!insertBuildList.isEmpty()){
            System.debug('not empty');
        	AA_ShareTriggerUtils.shareBuild(insertBuildList);
        }
    }
    
    if(trigger.isAfter&&trigger.isUpdate){
        List<agf__ADM_Build__c> updateBuildList = new List<agf__ADM_Build__c>();
        for(agf__ADM_Build__c bld : trigger.new){
            if(trigger.oldMap.get(bld.id).Scrum_Team__c!=bld.Scrum_Team__c){
                updateBuildList.add(bld);
            }
        }
      
        
        //Call method to share build records with new team
        if(!updateBuildList.isEmpty()){
            AA_ShareTriggerUtils.shareBuild(updateBuildList);
            //Call method to delete build share records for old team
            AA_ShareTriggerUtils.deleteBuildShare(trigger.old);
        }
    }
}