/*
** Test Class for ReassignInactiveUsersWorkflows.
** Created By: Hanu Sanampudi
** Created On: 24/04/2019 
*/

@IsTest
public class ReassignInactiveUsersWorkflowsTest {
    
    public static User testUser ;
    public static IFv2_Request__c requestRecord;
    public static IFv2_AdminOnly__c adminRecord;

    @IsTest
    public static void reassignWorkflowsTest() {
        
        prepareTestData();

        System.runAs(testUser) {

           Id recordTypeIdAdmin = Schema.SObjectType.IFv2_AdminOnly__c.getRecordTypeInfosByName().get('OutOfOfficeLogs').getRecordTypeId();
           Id userRecId = [Select Id from user where isActive=true and profile.name='System Administrator' limit 1].Id;

            //insert IFv2_AdminOnly__c records
            adminRecord = new IFv2_AdminOnly__c();
            adminRecord.User__c = userRecId;
            adminRecord.WorkflowName__c = 'eSignature';
            adminRecord.RecordtypeId = recordTypeIdAdmin;
            adminRecord.OwnerId= testUser.Id;

            insert adminRecord;
            System.assertNotEquals(adminRecord,null);
            system.debug('adminRecord******'+ adminRecord);
            system.debug('adminRecord****Owner**'+ adminRecord.OwnerId);
        }

        Test.startTest();

            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(requestRecord.Id); 
            req1.setSubmitterId(UserInfo.getUserId()); 
            req1.setProcessDefinitionNameOrId('IFv2_eSignature');
            req1.setSkipEntryCriteria(false);
            Approval.ProcessResult result = Approval.process(req1);

        System.runAs(new User(Id=UserInfo.getUserId())) {

            testUser.isActive = false;
            update testUser;
            System.assertNotEquals(testUser,null);
        }
        List<user> usersList = new List<user>();
        usersList.add(testUser);
        ReassignInactiveUsersWorkflows.checkAndRemovePublicGroupsPermissionSets(usersList);
        Test.stopTest();

        //iterate the list of users check pending process instance work items
        list<ProcessInstanceWorkitem> pendingInstanceRecordsList= [ SELECT OriginalActor.Name, ActorId, ElapsedTimeInDays,ProcessInstance.TargetObjectId 
                                                                        FROM ProcessInstanceWorkitem 
                                                                        where ActorId =: testUser.Id];  
        
        System.assertEquals(pendingInstanceRecordsList.isEmpty(),true);

    }
	
    @IsTest
    public static void updateSpecialfrightRecords() {
        
        prepareTestData();
        Test.startTest();


        System.runAs(new User(Id=UserInfo.getUserId())) {

            testUser.isActive = false;
            update testUser;
            System.assertNotEquals(testUser,null);
        }
        Id userRecId = [Select Id from user where isActive=true and profile.name='System Administrator' limit 1].Id;
        testUser.DelegatedApproverId = userRecId;
        update testUser;
        Test.stopTest();
        //System.assertEquals(pendingInstanceRecordsList.isEmpty(),true);
    }	

    //insert test data
    public static void prepareTestData() {

        System.runAs(new User(Id=UserInfo.getUserId())) {

            Profile profileobj =[SELECT ID FROM Profile Where Name='System Administrator'];

            UserRole ur = new UserRole(Name = 'Dummy');
            insert ur;

            //insert Test user
            testUser = new user();
            testUser.alias = 'adele';
            testUser.LastName = 'lastDele';
            testUser.Username = 'test123dele@seg-automotive.com';
            testUser.Email = 'test1234dele@seg-automotive.com';
            testUser.TimeZoneSidKey = 'Europe/Berlin';
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'UTF-8';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.ProfileId = profileobj.Id;
            testUser.ManagerId = UserInfo.getUserId();
            testUser.UserRoleId  = ur.Id;

            insert testUser;
            System.assertNotEquals(testUser,null);
            system.debug('testUser'+ testUser);

            //insert test request record
            requestRecord = new IFv2_Request__c();
            requestRecord.Workflow__c = 'eSignature';
            requestRecord.Status__c= 'submitted';
            requestRecord.Approver1__c = testUser.Id;

            insert requestRecord;
            System.assertNotEquals(requestRecord,null);
            system.debug('requestRecord'+ requestRecord);

        }
    }
}