/*******************************************************************************************************
*
*
* @ Purpose: Test Class for all the AA_TeamTrigger and AA_TeamTriggerUtils
*
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*******************************************************************************************************/
@isTest(seeAllData=true)
public class AA_TeamTriggerTest 
{
    public static testMethod void testTeamTrigger(){
        Test.startTest(); 
        
        //User user1 = TestData.createMultipleUsers('test1',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user1;
        
        //User user2 = TestData.createMultipleUsers('test2',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user2;
        
        List<User> userlist = [Select Id from user Limit 2];
         
        
        
        agf__ADM_Scrum_Team__c scrumTeam1 = TestData.createScrumTeam('Team1');
        System.debug('----Check----'+scrumTeam1);
        insert scrumTeam1;
        
        
        List<agf__ADM_Scrum_Team__c> teamList = [select id, name from agf__ADM_Scrum_Team__c Limit 1];
        teamList[0].Name = 'Updated Team Name';
        
        Group subGrp  = new Group();
        subGrp.name = 'Test Group2';
        subGrp.Type = 'Regular'; 
        Insert subGrp; 
 
        AA_TeamGroup__c cs = new AA_TeamGroup__c();
        cs.Name='test';
        cs.TeamId__c=scrumTeam1.id;
        insert cs;
        update teamList;
        
        List<agf__ADM_Scrum_Team__c> updatedList = [select id, name from agf__ADM_Scrum_Team__c where Name = 'Updated Team Name' Limit 1];
        System.assert(updatedList.size()==1);
        
        agf__ADM_Scrum_Team_Member__c scrumTeamMember1 = TestData.createScrumTeamMember(scrumTeam1.Id,userlist[0].Id);
        insert scrumTeamMember1;
        
        delete scrumTeamMember1;
        delete scrumTeam1;
        
        List<agf__ADM_Scrum_Team__c> finalList = [select id, name from agf__ADM_Scrum_Team__c where Id =: scrumTeam1.Id Limit 1];
        System.assert(finalList.size()==0);
        
        Test.stopTest();
    }
    
    public static testMethod void testTeamDelete(){
        Test.startTest(); 
        
        //User user1 = TestData.createMultipleUsers('test1',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user1;
        
        //User user2 = TestData.createMultipleUsers('test2',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user2;
        
        List<User> userlist = [Select Id from user Limit 2];
        
        agf__ADM_Scrum_Team__c scrumTeam1 = TestData.createScrumTeam('Team1');
        System.debug('----Check----'+scrumTeam1);
        insert scrumTeam1;
        
        agf__ADM_Scrum_Team_Member__c scrumTeamMember1 = TestData.createScrumTeamMember(scrumTeam1.Id,userlist[0].Id);
        insert scrumTeamMember1;
        
        List<agf__ADM_Scrum_Team__c> teamList = [select id, name from agf__ADM_Scrum_Team__c where Name = 'Team1' Limit 1];
        System.assert(teamList.size()==1);
        
        Set<Id> deleteGroupSet = new Set<Id>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam1.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        
        deleteGroupSet.add(newGroup.Id);
        
        AA_CustomSettingQueueable deleteCS = new AA_CustomSettingQueueable('delete',deleteGroupSet);
        Id jobId =  System.EnqueueJob(deleteCS);
        
        Test.stopTest();
    }
    
    public static testMethod void testTeamMemberTrigger1(){
        Test.startTest(); 
        
        //User user1 = TestData.createMultipleUsers('test1',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user1;
        //User user2 = TestData.createMultipleUsers('test2',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user2;
        
        List<User> userlist = [Select Id from user Limit 2];
        
        agf__ADM_Scrum_Team__c scrumTeam2 = TestData.createScrumTeam('Team2');
        System.debug('----Check----'+scrumTeam2);
        insert scrumTeam2;
        
        List<agf__ADM_Scrum_Team_Member__c> scrumTeamMemberList = new List<agf__ADM_Scrum_Team_Member__c>();
        List<Id> teamIdList = new List<Id>();
            
        agf__ADM_Scrum_Team_Member__c scrumTeamMember1 = TestData.createScrumTeamMember(scrumTeam2.Id,userlist[0].Id);
        scrumTeamMemberList.add(scrumTeamMember1);
        teamIdList.add(scrumTeamMember1.Id);
        agf__ADM_Scrum_Team_Member__c scrumTeamMember2 = TestData.createScrumTeamMember(scrumTeam2.Id,userlist[1].Id);
        scrumTeamMemberList.add(scrumTeamMember2);
        teamIdList.add(scrumTeamMember2.Id);
        insert scrumTeamMemberList;
        
        List<agf__ADM_Scrum_Team_Member__c> teamMemberList = [select id, name from agf__ADM_Scrum_Team_Member__c where agf__Scrum_Team__c =:scrumTeam2.Id];
        System.assert(teamMemberList.size()==2);
        
        Test.stopTest();
    }
    
    public static testMethod void testTeamMemberTrigger2(){
        Test.startTest(); 
        
        //User user1 = TestData.createMultipleUsers('test1',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user1;
        //User user2 = TestData.createMultipleUsers('test2',[SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        //insert user2;
        
        List<User> userlist = [Select Id from user Limit 2];
        
        List<agf__ADM_Scrum_Team_Member__c> scrumTeamMemberlist = [Select Id,Name,agf__Member_Name__c,agf__Scrum_Team__c from agf__ADM_Scrum_Team_Member__c limit 1];
        
        scrumTeamMemberlist[0].agf__Member_Name__c=userlist[0].Id;
        update scrumTeamMemberlist;
        
        List<agf__ADM_Scrum_Team_Member__c> updatedTeamMemberList = [select id, name from agf__ADM_Scrum_Team_Member__c where agf__Member_Name__c=:userlist[0].Id];
        System.assert(updatedTeamMemberList.size()==1);
        
        Test.stopTest();
    }
    
    public static testMethod void testTeamMemberTrigger3(){
        Test.startTest(); 
        
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Test Team');
        insert scrumTeam;
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';

        AA_TeamGroup__c newCS = new AA_TeamGroup__c();
        newCS.Name=scrumTeam.Name;
        newCS.TeamID__c = scrumTeam.Id;
        newCS.groupId__c = newGroup.Id;
        
        insert newCS;
        
        List<AA_TeamGroup__c> teamGroupList = new List<AA_TeamGroup__c>();
        Map<Id,Id> teamGroupMap = new Map<Id,Id>(); //map of teamId and goupId from custom setting
        teamGroupList = AA_TeamGroup__c.getAll().values();
        
        teamGroupList = AA_TeamGroup__c.getAll().values();
        if(!teamGroupList.isEmpty()){
            for(AA_TeamGroup__c tg : teamGroupList){
                teamGroupMap.put(tg.TeamId__c, tg.groupId__c);
            }
        }
        
        System.assert(teamGroupMap.get(scrumTeam.Id)==newGroup.Id);
        
        Test.stopTest();
    }
}