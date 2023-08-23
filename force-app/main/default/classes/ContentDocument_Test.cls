@isTest
public class ContentDocument_Test{
    
    
    static testMethod void testTriggerRequest() {
        
        Test.StartTest();
        list<IFv2_Request__c> lstRequest = IFv2_testDataUtility.createRequest();  //inserting Request  
        lstRequest[0].Status__c = 'Draft' ;
        lstRequest[0].Workflow__c = 'IFE Process Workflow'; 
        insert lstRequest;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = lstRequest[0].id );
        
        insert contDoc;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete documents;
        
        Test.StopTest();
    }
    static testMethod void testTriggerRequestfordesignverification() {
        
        Test.StartTest();
         Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test@testingfsagdgdsbggfbsajkdf.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        u.Department = '123';
        insert u;
        list<IFv2_Request__c> lstRequest = IFv2_testDataUtility.createRequest();  //inserting Request  
        lstRequest[0].Status__c = 'Draft' ;
        lstRequest[0].Workflow__c = 'Design Verification Process Approval'; 
        lstRequest[0].Approver1__c = u.id;
        lstRequest[0].Approver9__c = u.id;
        lstRequest[0].Approver2__c = u.id;
        lstRequest[0].Approver3__c = u.id;
        lstRequest[0].Approver4__c = u.id;
        lstRequest[0].Approver5__c = u.id;
        lstRequest[0].Approver6__c = u.id;
        lstRequest[0].Approver7__c = u.id;
        lstRequest[0].Approver8__c = u.id;
        lstRequest[0].Approver10__c = u.id;
        lstRequest[0].Approver11__c = u.id;
        lstRequest[0].Approver12__c = u.id;
        lstRequest[0].Approver13__c = u.id;
        lstRequest[0].Approver14__c = u.id;

        insert lstRequest;
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(lstRequest[0].Id);
        req1.setComments('Restarting approval process because the attachments were modified');
        
        //Submit the approval request for the change
        Approval.ProcessResult result = Approval.Process(req1);
        System.assert(result.isSuccess());system.debug('Approval.isLocked(reqObj.id) '+Approval.isLocked(lstRequest[0].id));
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = lstRequest[0].id );
        
        insert contDoc;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete documents;
        
        Test.StopTest();
    }
    /*public static testMethod void requestDeleteTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        Workflow__c wf = new Workflow__c(Name='AP Monitor Workflow-1', Application_Key__c='APM1');
        insert wf;
        
        User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test',
            NT_User__c = 'TESTSAP123'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'standt2', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test2',
            NT_User__c = 'TESTSAP321'
        );
        insert u2;
        
        Scan__c scan = new Scan__c();
        insert scan;
        
        
        WF_Request__c req = new WF_Request__c(
            Approver_name__c = 'TESTSAP123',
            Approver_Proxy_name__c = 'TESTSAP321',
            Workflow_number__c = '01',
            WF_Workflow_Name__c = [SELECT Id, Name FROM Workflow__c WHERE Name = 'AP Monitor Workflow-1' LIMIT 1].Id,
            Salesforce_ID__c = [SELECT Name FROM Scan__c WHERE Id =: scan.Id LIMIT 1].Name,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'X34_AP_Monitor_workflow_1'].Id,
            WF29_Approver__c = u.Id,
            Approver_2__c = u2.Id,
            Status__C = 'Submitted'
        );
        insert req;
        
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        ContentDocument myFeed = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id In (SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVer.id)];
        // Create News record
        News_Announcements__c news = TestData.createNews(user.Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        
        ContentDocumentLink contentlink=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                  ShareType= 'I',
                                                                  Visibility = 'AllUsers',
                                                                  LinkedEntityId = news.id );
        insert  contentlink;
        
        
        
        ContentDocumentLink contentlink1=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                   ShareType= 'I',
                                                                   Visibility = 'AllUsers',
                                                                   LinkedEntityId = req.id );
        insert  contentlink1;
        
        
        
        Test.startTest();
        try{
            delete myFeed;    
        }catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be deleted only for Draft Requests') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }     
        Test.stopTest(); 
    }
    public static testMethod void requestEMEADeleteTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        Workflow__c wf = new Workflow__c(Name='AP Monitor Workflow-1', Application_Key__c='APM1');
        insert wf;
        
        User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test',
            NT_User__c = 'TESTSAP123'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'standt2', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test2',
            NT_User__c = 'TESTSAP321'
        );
        insert u2;
        
        Scan__c scan = new Scan__c();
        insert scan;
        Id recTypeId1 = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='Request_EMEA__c' and DeveloperName = 'Role_Change_Request'].get(0).Id;
        
        
        
        Request_EMEA__c reqEMEA = new Request_EMEA__c();
        reqEMEA.Status__c = 'Draft';
        reqEMEA.recordTypeId = recTypeId1;
        
        reqEMEA.Verify_Check__c = true;
        reqEMEA.Status__c = 'Verify';
        reqEMEA.Plant__c = 'Change Me';
        reqEMEA.Project_Number__c = '123456';
        reqEMEA.Project_Title__c = 'testTitle';
        reqEMEA.Type_of_Investment__c = 'MAE (without EWAK)';
        reqEMEA.System__c = '011';
        reqEMEA.Role_type__c = 'Single Role';
        reqEMEA.Request_type__c = 'Create new role';
        reqEMEA.Reason_to_apply_for_authorisation__c = 'cause why not';
        reqEMEA.Authorisation_role_updates__c = 'textText';
        reqEMEA.Predefined_Approver_1__c = u.Id;
        reqEMEA.Predefined_Approver_2__c = u.Id;
        reqEMEA.Predefined_Approver_3__c = u.Id;
        reqEMEA.Predefined_Approver_4__c = u.Id;
        reqEMEA.Predefined_Approver_5__c = u.Id;
        reqEMEA.Predefined_Approver_6__c = u.Id;
        reqEMEA.Predefined_Approver_7__c = u.Id;
        reqEMEA.Predefined_Approver_8__c = u.Id;
        reqEMEA.Predefined_Approver_9__c = u.Id;
        reqEMEA.Predefined_Approver_10__c = u.Id;
        reqEMEA.Predefined_Approver_11__c = u.Id;
        reqEMEA.Predefined_Approver_12__c = u.Id;
        reqEMEA.Predefined_Approver_13__c = u.Id;
        reqEMEA.Predefined_Approver_14__c = u.Id;
        reqEMEA.Predefined_Approver_15__c = u.Id;
        reqEMEA.Predefined_Approver_16__c = u.Id;
        reqEMEA.Predefined_Approver_17__c = u.Id;
        reqEMEA.Predefined_Approver_18__c = u.Id;
        reqEMEA.Predefined_Approver_19__c = u.Id;
        reqEMEA.Predefined_Approver_20__c = u.Id;
        reqEMEA.Predefined_Approver_21__c = u.Id;      
        insert reqEMEA;
        
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        ContentDocument myFeed = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id In (SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVer.id)];
        // Create News record
        News_Announcements__c news = TestData.createNews(user.Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        ContentDocumentLink contentlink=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                  ShareType= 'I',
                                                                  Visibility = 'AllUsers',
                                                                  LinkedEntityId = news.id );
        insert  contentlink;
        
        ContentDocumentLink contentlink1=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                   ShareType= 'I',
                                                                   Visibility = 'AllUsers',
                                                                   LinkedEntityId = reqEMEA.id );
        insert  contentlink1;
        
        
        
        try{
            delete myFeed;    
        }catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be deleted only for  Draft Request EMEA') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }
    }
    public static testMethod void requestAPACDeleteTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        Workflow__c wf = new Workflow__c(Name='AP Monitor Workflow-1', Application_Key__c='APM1');
        insert wf;
        
        User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test',
            NT_User__c = 'TESTSAP123'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'standt2', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test2',
            NT_User__c = 'TESTSAP321'
        );
        insert u2;
        
        Scan__c scan = new Scan__c();
        insert scan;
        Id recTypeIdLeaveOvertime = [select 
                                     Id, 
                                     DeveloperName, 
                                     SobjectType 
                                     from 
                                     RecordType 
                                     where 
                                     DeveloperName = 'China_Leave_and_Overtime_Application'
                                     and
                                     SobjectType = 'Request_APAC__c'].get(0).Id;
        Request_APAC__c rq = new Request_APAC__c(Employee_Name__c= u.Id);
        rq.RecordTypeId = recTypeIdLeaveOvertime;
        rq.Predefined_Approver_01__c = u.Id;
        rq.Predefined_Approver_02__c = u2.Id;
        rq.Status__c = 'Approved';        
        insert rq;
        
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        ContentDocument myFeed = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id In (SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVer.id)];
        // Create News record
        News_Announcements__c news = TestData.createNews(user.Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        ContentDocumentLink contentlink=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                  ShareType= 'I',
                                                                  Visibility = 'AllUsers',
                                                                  LinkedEntityId = news.id );
        insert  contentlink;
        
        ContentDocumentLink contentlink1=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                   ShareType= 'I',
                                                                   Visibility = 'AllUsers',
                                                                   LinkedEntityId = rq.id );
        insert  contentlink1;
        
        
        
        Test.startTest();
        try{
            delete myFeed;    
        }catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be deleted only for  Draft Request APAC') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);     
        }
        
        Test.stopTest(); 
    }
    public static testMethod void requestNALADeleteTest(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        Workflow__c wf = new Workflow__c(Name='AP Monitor Workflow-1', Application_Key__c='APM1');
        insert wf;
        
        User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test',
            NT_User__c = 'TESTSAP123'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'standt2', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test2',
            NT_User__c = 'TESTSAP321'
        );
        insert u2;
        
        Scan__c scan = new Scan__c();
        insert scan;
        
        Id recTypeId = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='Request_NALA__c' and DeveloperName = 'NA_Journal_Entry_Application'].get(0).Id;
        Request_NALA__c reqNALA = new Request_NALA__c();
        reqNALA.Status__c = 'Draft';
        reqNALA.recordTypeId = recTypeId;
        reqNALA.Predefined_Approver_01__c = u.Id;
        insert reqNALA;      
        reqNALA.Verify_Check__c = true;
        reqNALA.Status__c = 'Verify';
        reqNALA.Predefined_Approver_02__c = u.Id;
        reqNALA.Predefined_Approver_03__c = u.Id;
        reqNALA.Predefined_Approver_04__c = u.Id;
        reqNALA.Predefined_Approver_05__c = u.Id;
        reqNALA.Predefined_Approver_06__c = u.Id;
        reqNALA.Cost_Center_included__c = 'Yes';
        reqNALA.Description__c = 'testDescription';
        reqNALA.Initiated_Approval_Process__c = DateTime.now();
        reqNALA.Total_Amount__c = 100;
        update reqNALA;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        ContentDocument myFeed = [SELECT LatestPublishedVersionId FROM ContentDocument WHERE Id In (SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVer.id)];
        // Create News record
        News_Announcements__c news = TestData.createNews(user.Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        ContentDocumentLink contentlink=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                  ShareType= 'I',
                                                                  Visibility = 'AllUsers',
                                                                  LinkedEntityId = news.id );
        insert  contentlink;
        
        ContentDocumentLink contentlink1=  new ContentDocumentLink(ContentDocumentId = myFeed.id,
                                                                   ShareType= 'I',
                                                                   Visibility = 'AllUsers',
                                                                   LinkedEntityId = reqNALA.id );
        insert  contentlink1;
        
        
        
        Test.startTest();
        
        try{
            delete myFeed;    
        }catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be deleted only for  Draft Request NALA') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }        
        
        
        Test.stopTest(); 
    }
    public static testMethod void requestUpdateTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1]; 
        Workflow__c wf = new Workflow__c(Name='AP Monitor Workflow-1', Application_Key__c='APM1');
        insert wf;
        
        User user = TestData.createUser([SELECT Id FROM Profile WHERE Name = 'System Administrator'][0].Id);
        insert user;
        
        // Create News record
        News_Announcements__c news = TestData.createNews(user.Id, 
                                                         'Global_News', 
                                                         'Event');
        insert news;
        
        // Create ContentVersion
        ContentVersion contentVer = new ContentVersion( Title = 'news news',ContentURL='http://www.google.com' );
        insert contentVer;
        
        contentVer = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :contentVer.Id];
        
        // Create ContentDocumentLink   
        ContentDocumentLink contDoc =  new ContentDocumentLink(ContentDocumentId = contentVer.ContentDocumentId,
                                                               ShareType= 'I',
                                                               Visibility = 'AllUsers',
                                                               LinkedEntityId = news.id );
        
        
        news = [Select Id, ImageAttachmentId__c From News_Announcements__c where Id =: news.Id][0];
        
        User u = new User(
            Alias = 'standt', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test',
            NT_User__c = 'TESTSAP123'
        );
        insert u;
        
        User u2 = new User(
            Alias = 'standt2', 
            Email='standarduser@seg-automotive.com', 
            EmailEncodingKey='UTF-8', 
            LastName='Testing2', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='standarduser@t-systems.com.test2',
            NT_User__c = 'TESTSAP321'
        );
        insert u2;
        
        Scan__c scan = new Scan__c();
        insert scan;
        Id recTypeId = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='Request_NALA__c' and DeveloperName = 'NA_Journal_Entry_Application'].get(0).Id;
        
        
        Request_NALA__c reqNALA = new Request_NALA__c();
        reqNALA.Status__c = 'Draft';
        reqNALA.recordTypeId = recTypeId;
        reqNALA.Predefined_Approver_01__c = u.Id;
        insert reqNALA;      
        reqNALA.Verify_Check__c = true;
        reqNALA.Status__c = 'Verify';
        reqNALA.Predefined_Approver_02__c = u.Id;
        reqNALA.Predefined_Approver_03__c = u.Id;
        reqNALA.Predefined_Approver_04__c = u.Id;
        reqNALA.Predefined_Approver_05__c = u.Id;
        reqNALA.Predefined_Approver_06__c = u.Id;
        reqNALA.Cost_Center_included__c = 'Yes';
        reqNALA.Description__c = 'testDescription';
        reqNALA.Initiated_Approval_Process__c = DateTime.now();
        reqNALA.Total_Amount__c = 100;
        update reqNALA;
        
        Id recTypeId1 = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='Request_EMEA__c' and DeveloperName = 'Role_Change_Request'].get(0).Id;
        
        
        
        Request_EMEA__c reqEMEA = new Request_EMEA__c();
        reqEMEA.Status__c = 'Draft';
        reqEMEA.recordTypeId = recTypeId1;
        insert reqEMEA;
        reqEMEA.Verify_Check__c = true;
        reqEMEA.Status__c = 'Verify';
        reqEMEA.Plant__c = 'Change Me';
        reqEMEA.Project_Number__c = '123456';
        reqEMEA.Project_Title__c = 'testTitle';
        reqEMEA.Type_of_Investment__c = 'MAE (without EWAK)';
        reqEMEA.System__c = '011';
        reqEMEA.Role_type__c = 'Single Role';
        reqEMEA.Request_type__c = 'Create new role';
        reqEMEA.Reason_to_apply_for_authorisation__c = 'cause why not';
        reqEMEA.Authorisation_role_updates__c = 'textText';
        reqEMEA.Predefined_Approver_1__c = u.Id;
        reqEMEA.Predefined_Approver_2__c = u.Id;
        reqEMEA.Predefined_Approver_3__c = u.Id;
        reqEMEA.Predefined_Approver_4__c = u.Id;
        reqEMEA.Predefined_Approver_5__c = u.Id;
        reqEMEA.Predefined_Approver_6__c = u.Id;
        reqEMEA.Predefined_Approver_7__c = u.Id;
        reqEMEA.Predefined_Approver_8__c = u.Id;
        reqEMEA.Predefined_Approver_9__c = u.Id;
        reqEMEA.Predefined_Approver_10__c = u.Id;
        reqEMEA.Predefined_Approver_11__c = u.Id;
        reqEMEA.Predefined_Approver_12__c = u.Id;
        reqEMEA.Predefined_Approver_13__c = u.Id;
        reqEMEA.Predefined_Approver_14__c = u.Id;
        reqEMEA.Predefined_Approver_15__c = u.Id;
        reqEMEA.Predefined_Approver_16__c = u.Id;
        reqEMEA.Predefined_Approver_17__c = u.Id;
        reqEMEA.Predefined_Approver_18__c = u.Id;
        reqEMEA.Predefined_Approver_19__c = u.Id;
        reqEMEA.Predefined_Approver_20__c = u.Id;
        reqEMEA.Predefined_Approver_21__c = u.Id;      
        update reqEMEA;
        
        Id recTypeIdLeaveOvertime = [select 
                                     Id, 
                                     DeveloperName, 
                                     SobjectType 
                                     from 
                                     RecordType 
                                     where 
                                     DeveloperName = 'China_Leave_and_Overtime_Application'
                                     and
                                     SobjectType = 'Request_APAC__c'].get(0).Id;
        
        
        Request_APAC__c rq = new Request_APAC__c(Employee_Name__c= u.Id);
        rq.RecordTypeId = recTypeIdLeaveOvertime;
        rq.Predefined_Approver_01__c = u.Id;
        rq.Predefined_Approver_02__c = u2.Id;
        
        insert rq;
        rq.Status__c = 'Approved';        
        update rq;
        
        
        
        WF_Request__c req = new WF_Request__c(
            Approver_name__c = 'TESTSAP123',
            Approver_Proxy_name__c = 'TESTSAP321',
            Workflow_number__c = '01',
            WF_Workflow_Name__c = [SELECT Id, Name FROM Workflow__c WHERE Name = 'AP Monitor Workflow-1' LIMIT 1].Id,
            Salesforce_ID__c = [SELECT Name FROM Scan__c WHERE Id =: scan.Id LIMIT 1].Name,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'X34_AP_Monitor_workflow_1'].Id,
            WF29_Approver__c = u.Id,
            Approver_2__c = u2.Id,
            Status__C = 'Submitted'
        );
        insert req;
        
        
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData =beforeblob;          
        insert cv;         
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=req.id;
        contentlink.sharetype = 'V';        
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        
        ContentDocumentLink contentlink2=new ContentDocumentLink();
        contentlink2.LinkedEntityId=reqNALA.id;
        contentlink2.sharetype = 'V';        
        contentlink2.ContentDocumentId=testcontent.ContentDocumentId;
        
        ContentDocumentLink contentlink3=new ContentDocumentLink();
        contentlink3.LinkedEntityId=reqEMEA.id;
        contentlink3.sharetype = 'V';        
        contentlink3.ContentDocumentId=testcontent.ContentDocumentId;
        
        ContentDocumentLink contentlink4=new ContentDocumentLink();
        contentlink4.LinkedEntityId=rq.id;
        contentlink4.sharetype = 'V';        
        contentlink4.ContentDocumentId=testcontent.ContentDocumentId;        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        Test.startTest();
        insert contDoc;
        ContentDocumentContoller con = new ContentDocumentContoller();
        con.restrictContentDocumentDeletion(documents);
        try{
            insert contentlink;        
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be updated only for Draft Requests') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            insert contentlink2;        
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be updated only for  Draft Request NALA') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            insert contentlink3;        
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be updated only for  Draft Request EMEA') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        try{
            insert contentlink4;        
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Attachment can be updated only for  Draft Request APAC') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }*/
    
    
}