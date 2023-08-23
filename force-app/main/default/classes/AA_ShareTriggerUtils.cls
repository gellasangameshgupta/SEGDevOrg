/**
*
* @ Name: AA_ShareTriggerUtils
* @ Purpose: Trigger Handler for AA_WorkTrigger, AA_ EpicTrigger, AA_SprintTrigger, AA_ProductTagTrigger,AA_BuildTrigger,AA_RootCauseAnalysisTrigger
* @ Test Class Name: AA_ShareTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
public class AA_ShareTriggerUtils{
    public static void shareWork(List<agf__ADM_Work__c> worklist){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Work__share> workShareList = new List<agf__ADM_Work__share>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        
        if(!worklist.isEmpty()){
            for(agf__ADM_Work__c wrk : worklist){
                
                if(teamGroupMap.containsKey(wrk.agf__Scrum_Team__c)){
                    agf__ADM_Work__share workShare = new agf__ADM_Work__share();
                    workShare.ParentId = wrk.Id;
                    workShare.UserOrGroupId = teamGroupMap.get(wrk.agf__Scrum_Team__c);
                    workShare.AccessLevel = 'Edit';
                    workShare.RowCause= Schema.agf__ADM_Work__Share.RowCause.AASharing__c;
                    workShareList.add(workShare);
                }
            }
        }
        
        if(!workShareList.isEmpty()){
            try{
                Database.insert(workShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
        public static void shareRootCauseAnalysis(List<agf__RCA__c> rootcauseanalysislist){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__RCA__share> rootcauseanalysisShareList = new List<agf__RCA__share>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        
        if(!rootcauseanalysislist.isEmpty()){
            for(agf__RCA__c rca : rootcauseanalysislist){
                
                if(teamGroupMap.containsKey(rca.agf__Scrum_Team__c)){
                    agf__RCA__share rootcauseanalysisShare = new agf__RCA__share();
                    rootcauseanalysisShare.ParentId = rca.Id;
                    rootcauseanalysisShare.UserOrGroupId = teamGroupMap.get(rca.agf__Scrum_Team__c);
                    rootcauseanalysisShare.AccessLevel = 'Edit';
                    rootcauseanalysisShare.RowCause = Schema.agf__RCA__Share.RowCause.AASharing__c;
                    rootcauseanalysisShareList.add(rootcauseanalysisShare);
                }
            }
        }
        
        if(!rootcauseanalysisShareList.isEmpty()){
            try{
                Database.insert(rootcauseanalysisShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
        public static void shareBuild(List<agf__ADM_Build__c> buildlist){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Build__share> BuildShareList = new List<agf__ADM_Build__share>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        
        if(!buildlist.isEmpty()){
            for(agf__ADM_Build__c bld : buildlist){
                
                if(teamGroupMap.containsKey(bld.Scrum_Team__c)){
                    agf__ADM_Build__share buildShare = new agf__ADM_Build__share();
                    buildShare.ParentId = bld.Id;
                    buildShare.UserOrGroupId = teamGroupMap.get(bld.Scrum_Team__c);
                    buildShare.AccessLevel = 'Edit';
                    buildShare.RowCause = Schema.agf__ADM_Build__Share.RowCause.AASharing__c;
                    BuildShareList.add(buildShare);
                }
            }
        }
        
        if(!BuildShareList.isEmpty()){
            try{
                Database.insert(BuildShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    public static void shareEpic(List<agf__ADM_Epic__c> epicList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Epic__share> epicShareList = new list<agf__ADM_Epic__share>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }  
        }
        
        if(!epicList.isEmpty()){
            for(agf__ADM_Epic__c epic : epicList){
                if(teamGroupMap.containsKey(epic.agf__Team__c)){
                    agf__ADM_Epic__Share epicShare = new agf__ADM_Epic__Share();
                    epicShare.ParentId = epic.Id;
                    epicShare.accesslevel = 'Edit';
                    epicShare.UserOrGroupId=teamGroupMap.get(epic.agf__Team__c);
                    epicShareList.add(epicShare);
                }
            }
        }
        if(!epicShareList.isEmpty()){
            try{
                Database.insert(epicShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    } 
    public static void shareSprint(List<agf__ADM_Sprint__c> sprintList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Sprint__Share> sprintShareList = new List<agf__ADM_Sprint__share>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!sprintList.isEmpty()){
            for(agf__ADM_Sprint__c spr : sprintList){
                if(teamGroupMap.containsKey(spr.agf__Scrum_Team__c)){
                    agf__ADM_Sprint__share sprintShare = new agf__ADM_Sprint__share();
                    sprintShare.ParentId = spr.Id;
                    sprintShare.accesslevel = 'Edit';
                    sprintShare.UserOrGroupId = teamGroupMap.get(spr.agf__Scrum_Team__c);
                    sprintShareList.add(sprintShare);
                }
            } 
        }
        if(!sprintShareList.isEmpty()){
            try{
                Database.insert(sprintShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    @future
    public static void shareProductTag(list<Id> productTagIdList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_Product_Tag__share> productTagShareList = new List<agf__ADM_Product_Tag__share>();
        List<agf__ADM_Product_Tag__c> productTagList = new List<agf__ADM_Product_Tag__c>();
        
        productTagList = [Select Id,Name,agf__Team__c from agf__ADM_Product_Tag__c where Id IN :productTagIdList];
        
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c teamg : teamGroupList){
                teamGroupMap.put(teamg.TeamId__c, teamg.groupId__c);
            }
        }
        
        System.debug('teamGroupMap::' + teamGroupMap);
        if(!productTagList.isEmpty()){
            for(agf__ADM_Product_Tag__c pt : productTagList){
                List<Group> groupList = [Select Name from Group Where Name = :pt.agf__Team__c];
                System.debug('public group::' + groupList);
                if(teamGroupMap.containsKey(pt.agf__Team__c)){
                    agf__ADM_Product_Tag__share productTagShare = new agf__ADM_Product_Tag__share();
                    productTagShare.ParentId = pt.id;
                    productTagShare.accesslevel = 'Edit';
                    productTagShare.userOrGroupId = teamGroupMap.get(pt.agf__Team__c);
                    productTagShareList.add(productTagShare);
                }
                
            }
        }
        System.debug('Final List::' + productTagShareList);
        if(!productTagShareList.isEmpty()){
            try{
                System.debug('Before Insert::' + productTagShareList);
                Database.insert(productTagShareList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    public static void deleteWorkShare(List<agf__ADM_Work__c> oldWorkList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<id> oldIdSet = new Set<id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_Work__share> deleteWorkList = new List<agf__ADM_Work__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!oldWorkList.isEmpty()){
            for(agf__ADM_Work__c wrk : oldWorkList){
                if(teamGroupMap.containsKey(wrk.agf__Scrum_Team__c))
                    oldIdSet.add(teamGroupMap.get(wrk.agf__Scrum_Team__c));
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteWorkList = [select id from agf__ADM_Work__share where rowcause='manual' AND userOrGroupId in :oldIdSet ];
        }
        
        if(!deleteWorkList.isEmpty()){
            try{
                Database.delete(deleteWorkList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
        public static void deleteRootCauseAnalysisShare(List<agf__RCA__c> oldRootCauseAnalysisList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<id> oldIdSet = new Set<id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__RCA__share> deleteRootCauseAnalysisList = new List<agf__RCA__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!oldRootCauseAnalysisList.isEmpty()){
            for(agf__RCA__c rca : oldRootCauseAnalysisList){
                if(teamGroupMap.containsKey(rca.agf__Scrum_Team__c))
                    oldIdSet.add(teamGroupMap.get(rca.agf__Scrum_Team__c));
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteRootCauseAnalysisList = [select id from agf__RCA__share where rowcause='manual' AND userOrGroupId in :oldIdSet ];
        }
        
        if(!deleteRootCauseAnalysisList.isEmpty()){
            try{
                Database.delete(deleteRootCauseAnalysisList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
        public static void deleteBuildShare(List<agf__ADM_Build__c> oldBuildList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<id> oldIdSet = new Set<id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_Build__share> deleteBuildList = new List<agf__ADM_Build__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!oldBuildList.isEmpty()){
            for(agf__ADM_Build__c bld : oldBuildList){
                if(teamGroupMap.containsKey(bld.Scrum_Team__c))
                    oldIdSet.add(teamGroupMap.get(bld.Scrum_Team__c));
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteBuildList = [select id from agf__ADM_Build__share where rowcause='manual' AND userOrGroupId in :oldIdSet ];
        }
        
        if(!deleteBuildList.isEmpty()){
            try{
                Database.delete(deleteBuildList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    public static void deleteEpicShare(List<agf__ADM_epic__c> oldEpicList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<Id> oldIdSet = new Set<Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_epic__share> deleteEpicList = new List<agf__ADM_epic__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!oldEpicList.isEmpty()){
            for(agf__ADM_epic__c spr : oldEpicList){
                if(teamGroupMap.containsKey(spr.agf__Team__c))
                    oldIdSet.add(teamGroupMap.get(spr.agf__Team__c));
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteEpicList = [select id from agf__ADM_epic__share where rowcause='manual' AND userOrGroupId in :oldIdSet];
        }
        
        if(!deleteEpicList.isEmpty()){
            try{
                Database.delete(deleteEpicList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    public static void deleteSprintShare(List<agf__ADM_sprint__c> oldSprintList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<Id> oldIdSet = new Set<Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_sprint__share> deleteSprintList = new List<agf__ADM_sprint__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            } 
        }
        if(!oldSprintList.isEmpty()){
            for(agf__ADM_sprint__c spr : oldSprintList){
                if(teamGroupMap.containsKey(spr.agf__Scrum_Team__c))
                    oldIdSet.add(teamGroupMap.get(spr.agf__Scrum_Team__c));
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteSprintList = [select id from agf__ADM_sprint__share where rowcause='manual' AND userOrGroupId in :OldIdSet];
        }
        
        if(!deleteSprintList.isEmpty()){
            try{
                Database.delete(deleteSprintList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
    public static void deleteProductTagShare(List<agf__ADM_Product_Tag__c> oldProductTagList){
        
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        Set<Id> oldIdSet = new Set<Id>();
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        List<agf__ADM_Product_Tag__share> deleteProductTagList = new List<agf__ADM_Product_Tag__share>();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        if(!oldProductTagList.isEmpty()){
            for(agf__ADM_Product_Tag__c pt : oldProductTagList){
                if(teamGroupMap.containsKey(pt.agf__Team__c)){
                    oldIdSet.add(teamGroupMap.get(pt.agf__Team__c));
                }
            }
        }
        
        if(!oldIdSet.isEmpty()){
            deleteProductTagList = [select id from agf__ADM_Product_Tag__share where rowcause='manual' AND userOrGroupId in : OldIdSet];
        }
        
        if(!deleteProductTagList.isEmpty()){
            try{
                Database.delete(deleteProductTagList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
}