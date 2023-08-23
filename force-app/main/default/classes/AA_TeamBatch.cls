/*******************************************************************************************************
* 
* @ Name    		: AA_TeamBatch
* @ Purpose 		: Batch Class for giving Team members access to Team and product tag records
* @ Author  		: Debasmita Rawooth
* @ Test Class Name : 
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.05.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/

global class AA_TeamBatch implements Database.batchable<Sobject>
{
    public String query;
    global database.QueryLocator start(Database.BatchableContext bc) {
        query = 'SELECT Id, Name '+
            'FROM agf__ADM_Scrum_Team__c ';
        system.debug(query);        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, LIST<agf__ADM_Scrum_Team__c> teamRecords) {
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<Id> teamIdList = new List<Id>();
        List<Id> grpIdList = new List<Id>();
        List<Id> teamShareIdList = new List<Id>();
        List<Id> tagShareIdList = new List<Id>();
        List<Id> teamUpdateList = new List<Id>();
        List<agf__ADM_Product_Tag__c> tagUpdateList = new List<agf__ADM_Product_Tag__c>();
        List<agf__ADM_Scrum_Team__Share> teamShareUpdateList = new List<agf__ADM_Scrum_Team__Share>();
        List<agf__ADM_Product_Tag__Share> tagShareUpdateList = new List<agf__ADM_Product_Tag__Share>();
        for(AA_TeamGroup__c tg : teamGroupList){
            teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            teamIdList.add(tg.TeamId__c);
            grpIdList.add(tg.groupId__c);
        }
        System.debug('1--teamGroupMap'+teamGroupMap);
        List<agf__ADM_Scrum_Team__Share> teamShareList = [Select id,ParentId,UserOrGroupId,AccessLevel from agf__ADM_Scrum_Team__Share where ParentId IN: teamIdList AND UserOrGroupId IN: grpIdList];
        System.debug('2--teamShareList'+teamShareList);
        if(!teamShareList.isEmpty()){
            for(agf__ADM_Scrum_Team__Share ts : teamShareList){
                teamShareIdList.add(ts.ParentId);
            }
        }
        if(!teamIdList.isEmpty()){
            for(Id t : teamIdList){
                if(!teamShareIdList.contains(t)){
                    teamUpdateList.add(t);
                }
            }
        }
        System.debug('3--teamUpdateList'+teamUpdateList);
        if(!teamUpdateList.isEmpty()){
            for(Id teamId : teamUpdateList){
                agf__ADM_Scrum_Team__Share teamShare = new agf__ADM_Scrum_Team__Share();
                teamShare.ParentId = teamId;
                teamShare.UserOrGroupId = teamGroupMap.get(teamId);
                teamShare.AccessLevel = 'Edit';
                teamShare.RowCause = Schema.agf__ADM_Scrum_Team__Share.RowCause.AASharing__c;
                teamShareUpdateList.add(teamShare);
            }
        }
        System.debug('4--teamShareUpdateList'+teamShareUpdateList);
        List<agf__ADM_Product_Tag__c> tagList= [Select Id,name,agf__Team__c from agf__ADM_Product_Tag__c where agf__Team__c IN: teamUpdateList];
        System.debug('5--tagList'+tagList);
        List<Id> tagIdList = new List<Id>();
        if(!tagList.isEmpty()){
            for(agf__ADM_Product_Tag__c tag : tagList){
                tagIdList.add(tag.Id);
            }
        }
        List<agf__ADM_Product_Tag__share> tagShareList = [Select id,ParentId,UserOrGroupId,AccessLevel from agf__ADM_Product_Tag__share where ParentId IN: tagIdList AND UserOrGroupId IN: grpIdList];
        System.debug('6--tagShareList'+tagShareList);
        if(!tagShareList.isEmpty()){
            for(agf__ADM_Product_Tag__share ts : tagShareList){
                tagShareIdList.add(ts.ParentId);
            }
        }
        if(!tagList.isEmpty()){
            for(agf__ADM_Product_Tag__c t : tagList){
                if(!tagShareIdList.contains(t.Id)){
                    tagUpdateList.add(t);
                }
            }
        }
        System.debug('7--tagUpdateList'+tagUpdateList);
        if(!tagUpdateList.isEmpty()){
            for(agf__ADM_Product_Tag__c tag : tagUpdateList){
                agf__ADM_Product_Tag__Share tagShare = new agf__ADM_Product_Tag__Share();
                tagShare.ParentId = tag.Id;
                tagShare.UserOrGroupId = teamGroupMap.get(tag.agf__Team__c);
                tagShare.AccessLevel = 'Edit';
                tagShare.RowCause = Schema.agf__ADM_Product_Tag__Share.RowCause.AASharing__c;
                tagShareUpdateList.add(tagShare);
            }
        }
        System.debug('8--tagShareUpdateList'+tagShareUpdateList);
        if(!teamShareUpdateList.isEmpty()){
            insert teamShareUpdateList;
        }
        if(!tagShareUpdateList.isEmpty()){
            insert tagShareUpdateList;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}