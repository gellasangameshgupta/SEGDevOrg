/**
*
*
* @ Purpose: Test Class for all the AA object triggers involved in this change 
* @ Author: Debasmita Rawooth
*
*
*       Date        |   Developer Name                  				 |   Version     |   Changes
* ===========================================================================================================
*   20.03.2019      |   external.debasmita.rawooth@seg-automotive.com    | 1.0           |   Initial Version
*
*/
@isTest
public class AA_ShareTriggerTest {

    @isTest
    public static void testEpic(){    
        Test.startTest(); 
        
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        
        List<agf__ADM_Scrum_Team__c> teamList = [Select Id,Name from agf__ADM_Scrum_Team__c where Name=:scrumTeam.Name Limit 1];
        System.assert(teamList.size()==1);
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
        
        agf__ADM_Epic__c epic = TestData.createEpicRecord(scrumTeam.Id, 'TestEpic');
        insert epic;
        
        agf__ADM_Scrum_Team__c scrumTeam2 = TestData.createScrumTeam('Team2');
        insert scrumTeam2;
        
        epic.agf__Team__c=scrumTeam2.Id;
        update epic;
        
        //List<agf__ADM_Epic__Share> epicShareList = [Select Id from agf__ADM_Epic__Share where ParentId = :epic.Id];
        //System.assert(epicShareList.size()==1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void testSprint(){ 
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
        
        agf__ADM_Sprint__c sprint = TestData.createSprintRecord(scrumTeam.Id,'2018.03a-ITA3.CW48.3December');
        insert sprint;
        
        agf__ADM_Scrum_Team__c scrumTeam2 = TestData.createScrumTeam('Team2');
        insert scrumTeam2;
        
        sprint.agf__Scrum_Team__c = scrumTeam2.Id;
        update sprint;
        
        List<agf__ADM_Sprint__share> sprintShareList = [Select Id from agf__ADM_Sprint__share where parentId=:sprint.Id];
        System.assert(sprintShareList.size()==1);
    }
    @isTest
    public static void testProductTag(){    
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
        
        agf__ADM_Product_Tag__c productTag = TestData.createproductTagRecord(scrumTeam.Id,'Test Tag');
        insert productTag;
        
        agf__ADM_Scrum_Team__c scrumTeam2 = TestData.createScrumTeam('Team2');
        insert scrumTeam2;
        
        productTag.agf__Team__c = scrumTeam2.Id;
        update productTag;
        
        List<agf__ADM_Product_Tag__share> productTagSharelist = [Select Id from agf__ADM_Product_Tag__share where ParentId = :productTag.Id];
        //System.assert(productTagSharelist.size()==1);
        
    }
    
    @isTest
    public static void testWork(){ 
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
        
        agf__ADM_Work__c work = TestData.createWorkRecord(scrumTeam.Id,'Test Work');
        insert work;
        
        agf__ADM_Scrum_Team__c scrumTeam1 = TestData.createScrumTeam('Team2');
        insert scrumTeam1;
        
        work.agf__Scrum_Team__c=scrumTeam1.Id;
        update work;
        
        //List<agf__ADM_Work__share> workShareList = [Select Id from agf__ADM_Work__share where ParentId = :work.Id ];
        //system.assertEquals(workShareList.Size(), 1);
    }
    @isTest
    public static void testBuild(){ 
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
        
        agf__ADM_Build__c build = TestData.createBuildRecord(scrumTeam.Id,'Test Build');
        insert build;
        
        agf__ADM_Scrum_Team__c scrumTeam1 = TestData.createScrumTeam('Team2');
        insert scrumTeam1;
        
        build.Scrum_Team__c=scrumTeam1.Id;
        update build;
        
        //List<agf__ADM_Work__share> workShareList = [Select Id from agf__ADM_Work__share where ParentId = :work.Id ];
        //system.assertEquals(workShareList.Size(), 1);
    }
     @isTest
    public static void testRootCauseAnalysis(){ 
       
        Test.startTest();
        agf__ADM_Scrum_Team__c scrumTeam = TestData.createScrumTeam('Team1');
        insert scrumTeam;
        Test.stopTest();
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       //User u=TestData.createUser(p.Id);
       //insert u;
       
        //User user1 = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator']);
        //insert user1;
        
        List<String> groupList = new List<String>();
        
        Group newGroup = new Group();
        newGroup.Name=scrumTeam.Name;
        newGroup.Type='Regular';
        
        insert newGroup;
        groupList.add(newGroup.Id);
        
        AA_TeamGroup__c teamGroup1 = TestData.createTeamGroupRecord(newGroup.id,scrumTeam.Id,scrumTeam.Name);
        insert teamGroup1;
        
        List<AA_TeamGroup__c> teamGroupList = [Select Name from AA_TeamGroup__c where TeamId__c=:scrumTeam.Id ];
        System.assertEquals(teamGroupList.size(), 1);
            
        
        agf__RCA__c root = TestData.createRootCauseAnalysisRecord(UserInfo.getUserId(),scrumTeam.Id,'Test Build');
        insert root;
        
        agf__ADM_Scrum_Team__c scrumTeam1 = TestData.createScrumTeam('Team2');
        insert scrumTeam1;
        
        root.agf__Scrum_Team__c=scrumTeam1.Id;
        update root;
        
        //List<agf__ADM_Work__share> workShareList = [Select Id from agf__ADM_Work__share where ParentId = :work.Id ];
        //system.assertEquals(workShareList.Size(), 1);
    }
}