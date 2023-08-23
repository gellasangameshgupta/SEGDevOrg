@isTest
public class AA_TeamBatchScheduleTest {
    public static testMethod void testTeamBatch(){
        Test.startTest(); 
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
        
        agf__ADM_Product_Tag__c productTag = TestData.createproductTagRecord(scrumTeam2.Id,'Test Tag');
        insert productTag;
        
        Database.executeBatch(new AA_TeamBatch());
                
        Test.stopTest();
    }
    //Method to call schedule class
    Public static TestMethod void BatchschedlueMethod() {
        
        //Creating cron Logic
        String cronValue = '0 0 0 28 2 ? *';
        
        test.startTest();     
        AA_TeamBatchScheduler teamBatchScheduler = new AA_TeamBatchScheduler(); 
        String jobId = System.schedule('AA_TeamBatchScheduler',cronValue,teamBatchScheduler);
        CronTrigger crontrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                                   FROM CronTrigger 
                                   WHERE id = :jobId];
        system.assertEquals(0, crontrigger.TimesTriggered);
        test.stopTest();
    }
}