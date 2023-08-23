/*******************************************************************************************************
*
* @ Name: AA_TeamMemberTriggerUtils
* @ Purpose: Trigger Handler for Team Member Trigger 
* @ Test Class Name: AA_TeamTriggerTest
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
public class AA_TeamMemberTriggerUtils{
    @future
    public static void insertInGroup(List<id> teamMemberIdList){
        
        List<AA_TeamGroup__c> teamGroupList = new List<AA_TeamGroup__c>();
        Map<Id,Id> teamGroupMap = new Map<Id,Id>(); //map of teamId and goupId from custom setting
        List<agf__ADM_Scrum_Team_Member__c> teamMembersList = new List<agf__ADM_Scrum_Team_Member__c>();
        Set<Id> userIdSet = new Set<Id>(); //set of new team members' userId
        Map<Id,Id> userGroupmap = new Map<Id,Id>(); //Map of new userId and groupId--from custom setting
        Set<Id> teamIds = new Set<Id>(); // set of new team ids
        Map<Id,Id> teamUserMap = new Map<Id,Id>(); //map of teamId and userId of group member
        Map<Id,Id> userteamMap=new Map<Id,Id>(); //map of userId and teamId
        
        Map<Id,List<agf__ADM_Scrum_Team_Member__c>> teamMemberMap = new Map<Id,List<agf__ADM_Scrum_Team_Member__c>>(); //map of teamId and list of teamMembers
        
        //variables for calling AA_CustomSettingQueueable
        Map<Id,Group> teamIdGroupMap = new Map<Id,group>();
        Map<Id,agf__ADM_Scrum_Team__c> teamIdMap = new Map<Id,agf__ADM_Scrum_Team__c>();
        
        List<agf__ADM_Scrum_Team_Member__C> memberList = new List<agf__ADM_Scrum_Team_Member__c>();
        Map<Id,group> newTeamGroupMap = new Map<Id,Group>();
        List<Group> insertGroupList = new List<Group>();
        List<GroupMember> insertGroupMemberList1 = new List<GroupMember>();
        List<GroupMember> insertGroupMemberList2 = new List<GroupMember>();
        
        //Map<Id,Group> umap = new Map<Id,Group>(); //map of userId, group - used for creating new group and a groupmember
        
        Map<Id,agf__ADM_Scrum_Team__c> teamMap = new Map<Id,agf__ADM_Scrum_Team__c>([select Id, name from agf__ADM_Scrum_Team__c ]);
        
        //getting existing custom setting values and creating map of teamid and groupId
        teamGroupList = AA_TeamGroup__c.getAll().values();
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        //getting team member records in trigger.new
        teamMembersList = [select id, agf__Scrum_Team__c,agf__Scrum_Team_Name__c, agf__Member_Name__c from agf__ADM_Scrum_Team_Member__c where id IN :teamMemberIdList ];
        
        if(!teamMembersList.isEmpty()){
            for(agf__ADM_Scrum_Team_Member__c tm : teamMembersList){
                //if team member's team name is present in custom settings then add new team member to existing public group
                if(teamGroupMap.containsKey(tm.agf__Scrum_Team__c)){
                    userIdSet.add(tm.agf__Member_Name__c);
                    
                    // storing userId and groupid in a map to get groupId while creating new group member
                    userGroupmap.put(tm.agf__Member_Name__c,teamGroupMap.get(tm.agf__Scrum_Team__c));
                }else{
                    //else get the team member's teamids to create new custom setting with team id
                    teamids.add(tm.agf__Scrum_Team__c);
                    teamUserMap.put(tm.agf__Scrum_Team__c,tm.agf__Member_Name__c);
                    userteamMap.put(tm.agf__Member_Name__c,tm.agf__Scrum_Team__c);
                    
                    if(teamMemberMap != NULL && teamMemberMap.containsKey(tm.agf__Scrum_Team__c)) {
                        
                        List<agf__ADM_Scrum_Team_Member__c> newTeamMemberList = new List<agf__ADM_Scrum_Team_Member__c>();
                        newTeamMemberList = teamMemberMap.get(tm.agf__Scrum_Team__c);
                        If(tm.agf__Scrum_Team__c != null){
                            newTeamMemberList.add(tm);
                        }
                        teamMemberMap.put(tm.agf__Scrum_Team__c,newTeamMemberList);
                    } else {
                        teamMemberMap.put(tm.agf__Scrum_Team__c, new List<agf__ADM_Scrum_Team_Member__c> { tm });
                    }
                }   
            }
        }
        
        //create new group with team name and insert group members
        if(!teamids.isEmpty()){
            for(Id teamid : teamids){
                Group newGroup = new Group();
                newGroup.Name=teamMap.get(teamid).Name;
                newGroup.Type='Regular';
                insertGroupList.add(newGroup);
                teamIdGroupMap.put(teamid,newgroup); // for calling AA_CustomSettingQueueable
                teamIdMap.put(teamid, teamMap.get(teamid)); // for calling AA_CustomSettingQueueable
                memberList.addAll(teamMemberMap.get(teamid));
                //umap.put(userteamMap.get(teamUserMap.get(teamid)), newgroup); //map of userid,group
                newTeamGroupMap.put(teamid,newgroup);
            }
        }
        
        if(!insertGroupList.isEmpty()){
            try{
                Database.insert(insertGroupList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
        
        if(!memberList.isEmpty()){
            for(agf__ADM_Scrum_Team_Member__c teammem1 : memberList){
                groupmember gm = new groupmember();
                gm.GroupId=newTeamGroupMap.get(teammem1.agf__Scrum_Team__c).Id;
                gm.UserOrGroupId=teammem1.agf__Member_Name__c;
                insertGroupMemberList2.add(gm);
            }
        }
        
        if(!userIdSet.isEmpty()){
            for(Id iu : userIdSet){
                if(userGroupmap.containsKey(iu)){
                    GroupMember gm = new GroupMember();
                    gm.GroupId = userGroupmap.get(iu);
                    gm.UserOrGroupId = iu;
                    insertGroupMemberList1.add(gm); 
                }
            } 
        }
        
        if(!insertGroupMemberList1.isEmpty()){
            try{
                Database.insert(insertGroupMemberList1, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
        
        if(!insertGroupMemberList2.isEmpty()){
            try{
                Database.insert(insertGroupMemberList2, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
        
        if(!teamids.isEmpty()){
            AA_CustomSettingQueueable ics = new AA_CustomSettingQueueable('insert',teamIdGroupMap,teamIdMap);
            Id jobid=system.enqueueJob(ics);
        }
    }
    /*
    @future
    public static void deleteFromGroup(List<Id> teamMemberUserIdList)
    {
        List<GroupMember> groupMemberList = [select id,groupid from GroupMember where userOrgroupid in : teamMemberUserIdList];
        if(!groupMemberList.isEmpty()){
            try{
                Database.delete(groupMemberList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        }
    }
*/
    /* code for removing group member from group */
         @future
    public static void deleteFromGroupEdit(List<Id> teamMemberIdList,List<Id> deleteUserSet)
    {
        System.debug('Inside delete>>');
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Scrum_Team_Member__c> teamMembersList = new List<agf__ADM_Scrum_Team_Member__c>();
        Map<Id,Id> userGroupMmap = new Map<Id,Id>(); //map of userid, groupid
        List<GroupMember> getGroupMemberList = new List<GroupMember>(); 
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c teamg : teamGroupList){
                teamGroupMap.put(teamg.TeamId__c, teamg.groupId__c);
            }
        }
        System.debug('Inside delete teamGroupMap>>'+teamGroupMap);
        teamMembersList = [select id, agf__Scrum_Team__c, agf__Member_Name__c from agf__ADM_Scrum_Team_Member__c where id IN: teamMemberIdList ALL ROWS];
		System.debug('Inside delete teamGroupMap>>'+teamMembersList);        
        if(!teamMembersList.isEmpty()){
            for(agf__ADM_Scrum_Team_Member__c tm : teamMembersList){
                userGroupMmap.put(tm.agf__Member_Name__c,teamGroupMap.get(tm.agf__Scrum_Team__c));
                
            }
        }
         
        System.debug('Inside delete userGroupMmap>>'+userGroupMmap);    
        getGroupMemberList = [select id,groupid from GroupMember where userOrgroupid in : deleteUserSet and GroupId in : userGroupMmap.values() ALL ROWS];
        System.debug('Inside delete getGroupMemberList>>'+getGroupMemberList); 
        if(!getGroupMemberList.isEmpty()){
            for(GroupMember gm :getGroupMemberList) {
                if(userGroupMmap.values().contains(gm.GroupId)){
                    groupMemberList.add(gm);
                }
            }
        }
        System.debug('----Group Members to be deleted---'+groupMemberList);
        if(!groupMemberList.isEmpty()){
            try{
                Database.delete(groupMemberList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }   
        }
    }
    /*
    @future
    public static void deleteFromGroup(List<Id> teamMemberIdList)
    {
        List<GroupMember> groupMemberList = new List<GroupMember>();
        Map<Id,Id> teamGroupMap = new Map<Id,Id>();
        List<agf__ADM_Scrum_Team_Member__c> teamMembersList = new List<agf__ADM_Scrum_Team_Member__c>();
        Set<Id> userIdSet = new Set<Id>();
        Map<Id,Id> userGroupMmap = new Map<Id,Id>(); //map of userid, groupid
        List<GroupMember> getGroupMemberList = new List<GroupMember>();
        
        List<AA_TeamGroup__c> teamGroupList = AA_TeamGroup__c.getAll().values();
        
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c teamg : teamGroupList){
                teamGroupMap.put(teamg.TeamId__c, teamg.groupId__c);
            }
        }
        teamMembersList = [select id, agf__Scrum_Team__c, agf__Member_Name__c from agf__ADM_Scrum_Team_Member__c where id IN: teamMemberIdList ALL ROWS];       
        if(!teamMembersList.isEmpty()){
            for(agf__ADM_Scrum_Team_Member__c tm : teamMembersList){
                userIdSet.add(tm.agf__Member_Name__c);
                userGroupMmap.put(tm.agf__Member_Name__c,teamGroupMap.get(tm.agf__Scrum_Team__c));
                
            }
        }
            
        getGroupMemberList = [select id,groupid from GroupMember where userOrgroupid in : userIdSet and GroupId in : userGroupMmap.values() ALL ROWS];
        if(!getGroupMemberList.isEmpty()){
            for(GroupMember gm :getGroupMemberList) {
                if(userGroupMmap.values().contains(gm.GroupId)){
                    groupMemberList.add(gm);
                }
            }
        }
        System.debug('----Group Members to be deleted---'+groupMemberList);
        if(!groupMemberList.isEmpty()){
            try{
                Database.delete(groupMemberList, false);
            }catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }   
        }
    } */
}