/**
*
* @ Name: AA_RootCauseAnalysisTrigger
* @ Purpose: Trigger to share Root Cause records with Team member users
* @ Test Class Name: AA_ShareTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.08.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
trigger AA_RootCauseAnalysisTrigger on agf__RCA__c (after insert, after update){
    if(trigger.isAfter&&trigger.isInsert){
        List<agf__RCA__c> insertRootCauseAnalysisList = new LisT<agf__RCA__c>();
        for(agf__RCA__c rca : trigger.new){
            if(rca.agf__Scrum_Team__c!=null){
                insertRootCauseAnalysisList.add(rca);
            }
        }
        //Call method to share root cause analysis records with public group
        if(!insertRootCauseAnalysisList.isEmpty()){
        	AA_ShareTriggerUtils.shareRootCauseAnalysis(insertRootCauseAnalysisList);
        }
    }
    
    if(trigger.isAfter&&trigger.isUpdate){
        List<agf__RCA__c> updateRootCauseAnalysisList = new List<agf__RCA__c>();
        for(agf__RCA__c rca : trigger.new){
            if(trigger.oldMap.get(rca.id).agf__Scrum_Team__c!=rca.agf__Scrum_Team__c){
                updateRootCauseAnalysisList.add(rca);
            }
        }
        
        //Call method to share root cause analysis records with new team
        if(!updateRootCauseAnalysisList.isEmpty()){
            AA_ShareTriggerUtils.shareRootCauseAnalysis(updateRootCauseAnalysisList);
            //Call method to delete root cause analysis share records for old team
            AA_ShareTriggerUtils.deleteRootCauseAnalysisShare(trigger.old);
        
        }
    }
}