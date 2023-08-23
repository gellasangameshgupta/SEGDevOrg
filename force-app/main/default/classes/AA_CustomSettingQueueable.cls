/*******************************************************************************************************
*
* @Name: AA_CustomSettingQueueable
* @ Purpose: Queueable apex class to insert,update,delete records from custom setting which maintains 
*			 mapping of all Public groups and corresponding Team ids
* @ Test Class Name: AA_TeamTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
public class AA_CustomSettingQueueable implements queueable{
    //Common flag variable
    public final String executeFlag;
    
    //insert variables
    public final Map<Id,Group> insertGroupMap;
    public final Map<Id,agf__ADM_Scrum_Team__c> insertTeamMap;
    
    //update variables
    public Set<id> updateTeamIdSet;
    public Map<string,string> updateMap;
    
    //delete variables
    public final Set<id> deleteIdSet;
    
    public AA_CustomSettingQueueable(String flag,Map<Id,Group> teamGroupMap,Map<Id,agf__ADM_Scrum_Team__c> teamMap){
        //Variable initialisation for insert constructor
        insertGroupMap=teamGroupMap;
        insertTeamMap=teamMap;
        executeFlag = flag;
    }
    public AA_CustomSettingQueueable(String flag,Set<Id> updatedTeamIdSet,Map<string,string> newOldNameMap){
        //Variable initialisation for update constructor
        updateTeamIdSet = updatedTeamIdSet;
        updateMap=newOldNameMap;
        executeFlag = flag;
    }
    public AA_CustomSettingQueueable(String flag,set<Id> groupIdSet){
        //Variable initialisation for delete constructor
        deleteIdSet=groupIdSet;
        executeFlag = flag;
    }
    
    public void execute(QueueableContext context){
        If(executeFlag == 'insert'){
            System.debug('----inside insert of Custom Setting----');
            List<AA_TeamGroup__c> insertCSList = new List<AA_TeamGroup__c>();
            for(Id ig : insertGroupMap.keySet()){
                if(insertTeamMap.containsKey(ig)&&insertGroupMap.containsKey(ig)){
                    AA_TeamGroup__c newCS = new AA_TeamGroup__c();
                    newCS.Name=insertTeamMap.get(ig).Name;
                    newCS.TeamID__c = insertTeamMap.get(ig).Id;
                    newCS.groupId__c = insertGroupMap.get(ig).Id;
                    insertCSList.add(newCS);                
                }
            }
            if(!insertCSList.isEmpty()){
                try {
                    Database.insert(insertCSList, false);
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                
            }
            
        }
        else If(executeFlag == 'update'){
            System.debug('----inside update of Custom Setting----');
            List<AA_TeamGroup__c> updateCSList = new List<AA_TeamGroup__c>();
            List<agf__ADM_Scrum_Team__c> updateTeamList = [select id, name from agf__ADM_Scrum_Team__c where id in : updateTeamIdSet];
            for(agf__ADM_Scrum_Team__c tm : updateTeamList){
                if(updateMap.containsKey(tm.name)){
                    AA_TeamGroup__c updateCS = AA_TeamGroup__c.getInstance(updateMap.get(tm.name));
                    if(!Test.isRunningTest())
                        updateCS.Name=tm.Name;
                    updateCSList.add(updateCS);
                }
                
            }
            if(!updateCSList.isEmpty()){
                try{
                    Database.update(updateCSList, false);
                }catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                
            }
            
        }
        else If(executeFlag == 'delete'){
            System.debug('----inside delete of Custom Setting----');
            List<AA_TeamGroup__c> deleteCSList = new List<AA_TeamGroup__c>();
            List<AA_TeamGroup__c> deleteTeamList = [select id, TeamId__c, GroupId__c from AA_TeamGroup__c where GroupId__c in :deleteIdSet ALL ROWS ];
            for(AA_TeamGroup__c tg : deleteTeamList){
                deleteCSList.add(tg);
            }
            if(!deleteCSList.isEmpty()){
                try{
                    Database.delete(deleteCSList, false);
                }catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
            }  
        }
    }
}