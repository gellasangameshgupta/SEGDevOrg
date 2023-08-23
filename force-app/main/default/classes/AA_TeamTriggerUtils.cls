/*******************************************************************************************************
*
* @Name: AA_TeamTriggerUtils
* @ Purpose : Trigger Handler for Team Trigger 
* @ Test Class Name : AA_TeamTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
public class AA_TeamTriggerUtils{
    @future
    public static void deletePublicGroup(Set<id> teamIdSet){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<Id> deleteGroupSet = new Set<Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_Scrum_Team__c> teamList = new List<agf__ADM_Scrum_Team__c>();
        
        //form a map of teamid and groupid
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        
        //get all group ids that are supposed to be deleted
        if(!teamIdSet.isEmpty()){
            teamList = [select id, name from agf__ADM_Scrum_Team__c where id in :teamIdSet all rows];
        }
        if(!teamList.isEmpty()){
            for(agf__ADM_Scrum_Team__c team : teamList){
                if(teamGroupMap.containskey(team.id)){
                    deleteGroupSet.add(teamGroupMap.get(team.id)) ;
                }
            }
        }
        
        List<Group> deleteGroupsList = [select id, name from group where id in :deleteGroupSet ];
        //delete group and enqueue deletion of custom setting
        if(!deleteGroupsList.isEmpty()){
            System.debug('----List of Groups to be deleted----'+deleteGroupsList);
            try{
                Database.delete(deleteGroupsList, false);   
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
            AA_CustomSettingQueueable deleteCS = new AA_CustomSettingQueueable('delete',deleteGroupSet);
            Id jobId =  System.EnqueueJob(deleteCS);
        }
    }
    
    @future
    public static void updateGroupName(Set<Id> teamIdSet,Map<String,String> teamNameMap)
    {
        System.debug('-----updateGroupName----'+teamIdSet);
        List<agf__ADM_Scrum_Team__c> teamList = [select id, name from agf__ADM_Scrum_Team__c where id in : teamIdSet all rows];
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<Group> updateGroupsList = new List<Group>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        for(AA_TeamGroup__c tg : teamGroupList){
            
            teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
        }
        System.debug('-----Check teamList----'+teamList);
        for(agf__ADM_Scrum_Team__c team : teamList){
            Group gr = new Group(Id=teamGroupMap.get(team.Id));
            gr.Name=team.Name;
            updateGroupsList.add(gr);
        }
        //update group and enqueue updation of custom setting
        if(!updateGroupsList.isEmpty()){
            System.debug('----List of groups to be updated----'+updateGroupsList);
            try{
                Database.update(updateGroupsList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
            AA_CustomSettingQueueable updateCS = new AA_CustomSettingQueueable('update',teamIdSet,teamNameMap);
            Id jobId = System.EnqueueJob(updateCS);
        }
    }
}