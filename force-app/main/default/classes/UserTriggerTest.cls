/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class UserTriggerTest {
    @isTest
    static  void myUnitTest() {
        
        
        /*commented for cleaning up of Insightflow 1.0 components
Id recTypeId = [select Id, SobjectType, DeveloperName from RecordType where SobjectType='Request_NALA__c' and DeveloperName = 'Investment_Approval'].get(0).Id;
*/
        List<Id> userIdList = new List<Id>();
        list<user> users = new list<user>();
        Test.startTest();
        
        /*commented for cleaning up of Insightflow 1.0 components
Workflow__c wf = new Workflow__c();
wf.Name = 'Investment Approval';
insert wf;


Request_NALA__c req = new Request_NALA__c();
req.Status__c = 'Draft';
req.recordTypeId = recTypeId;
req.WF_Workflow_Name__c = wf.Id;
insert req;
*/
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test123@seg-automotive.com';
        u.Email = 'test1234@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        insert u;
        users.add(u);
        User u2 = new User();
        u2.alias = 'alias2';
        u2.LastName = 'lastName2';
        u2.Username = 'test2@seg-automotive.com';
        u2.Email = 'test2@seg-automotive.com';
        u2.TimeZoneSidKey = 'Europe/Berlin';
        u2.LocaleSidKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LanguageLocaleKey = 'en_US';
        u2.ProfileId = p.Id;
        insert u2;
        
        
        
        List<User> chMeList = new List<User>();
        
        try{
            chMeList = [select 
                        Id, 
                        FirstName, 
                        LastName 
                        from 
                        User 
                        where 
                        FirstName = 'Change' 
                        and 
                        LastName = 'Me'];	
        } catch(Exception e) {
            //nothing to do here	
        }
        
        Id changeMeUserId;
        
        if(chMeList.size() == 0) {
            User u1 = new user();
            u1.alias = 'alias1';
            u1.LastName = 'Me';
            u1.FirstName = 'Change';
            u1.Username = 'test1123@seg-automotive.com';
            u1.Email = 'test1123@seg-automotive.com';
            u1.TimeZoneSidKey = 'Europe/Berlin';
            u1.LocaleSidKey = 'en_US';
            u1.EmailEncodingKey = 'UTF-8';
            u1.LanguageLocaleKey = 'en_US';
            u1.ProfileId = p.Id;
            insert u1;
            users.add(u1);
            changeMeUserId = u1.Id;
        } else {
            User changeMeUser = chMeList.get(0);
            changeMeUserId = changeMeUser.Id;
        }
        
        system.assertEquals(1, chMeList.size());
        /*commented for cleaning up of Insightflow 1.0 components
req.Verify_Check__c = true;
req.Status__c = 'Verify';
req.Predefined_Approver_01__c = u.Id;
req.Predefined_Approver_02__c = changeMeUserId;
req.Predefined_Approver_03__c = changeMeUserId;
req.Predefined_Approver_04__c = changeMeUserId;
req.Predefined_Approver_05__c = changeMeUserId;
req.Predefined_Approver_06__c = changeMeUserId;
req.Predefined_Approver_07__c = changeMeUserId;
req.Approver_10__c = changeMeUserId;
req.Select_a_flow_option__c = 'Investments until 100 TBRL';
req.Responsible_Branch_Line__c = 'gggg';
req.Responsible_department__c = 'kkkkk';
req.Responsible_Name__c = 'hhhhh';
req.Responsible_Date__c = Date.today();
req.Investment_Description__c = 'ppppp';
req.Investment_Position__c = 'lllllllllllll';
req.Investment_Value__c = 10;
req.Currency_Picklist__c = 'Dólar ($)';


try{
update req;
} catch(Exception ex){
//ok here -> not all predefined approvers defined
}

Request_NALA__c reqDB = [select Id, Status__c from Request_NALA__c where Id =: req.Id].get(0);
system.assertEquals(reqDB.Status__c, 'Draft');


req.Verify_Check__c = true;
req.Status__c = 'Verify';
req.Predefined_Approver_01__c = u.Id;
req.Predefined_Approver_02__c = u.Id;
req.Predefined_Approver_03__c = u.Id;
req.Predefined_Approver_04__c = u.Id;
req.Predefined_Approver_05__c = u.Id;
req.Predefined_Approver_06__c = u.Id;
req.Predefined_Approver_07__c = u.Id;
req.Approver_10__c = u.Id;


update req;
processInstanceWorkItem piw=[  SELECT Id,processinstanceId,ProcessInstance.TargetObject.Id
FROM ProcessInstanceWorkitem
WHERE ProcessInstance.TargetObjectId = :req.id
AND ProcessInstance.Status = 'Pending'
LIMIT 1];
Approval.ProcessSubmitRequest AccountRequest = new Approval.ProcessSubmitRequest();
AccountRequest.setObjectId(req.Id); */
        /* Approval.ProcessResult AccountRequestResult = Approval.Process(AccountRequest);
ProcessInstanceWorkitem pworkItem = new ProcessInstanceWorkitem();
pworkItem.ActorId = userinfo.getuserId();
pworkItem.OriginalActorId = userinfo.getuserId();
pworkItem.ProcessInstanceId = AccountRequestResult.instanceid;
insert pworkItem;*/
        /*commented for cleaning up of Insightflow 1.0 components

list<processInstanceWorkItem> piwList = new list<processInstanceWorkItem>();
piwlist.add(piw);
reqDB = [select Id, Status__c from Request_NALA__c where Id =: req.Id].get(0);
system.assertEquals(reqDB.Status__c, 'Submitted');

u.Delegate_Investment_Approval__c = u2.Email; 
*/
        u.Out_Of_Office__c = true;
        update u;
        
        u.Out_Of_Office__c = false;
        update u; 
        
        system.debug('called before update---');
        
        userIdList.add(u2.Id);
        /*commented for cleaning up of Insightflow 1.0 components
Id batchid=  Database.executeBatch(new BatchUserAssignToDelegated());
SG_WF_UserTriggerHelper.sendEmailByInactiveDelegate(userIdList);

SG_WF_UserTriggerHelper.sendEmailByChangedEmailDelegate(userIdList);   
UpdateProcessInstancetoDelegatedUser.UpdatePiw2(users,batchid);
commented for destruction package
SG_WF_usertriggerhelper.getWorkflowNamesForPiw(piwList);
string reqPRefix=String.valueOf(req.Id).left(3);
sg_wf_usertriggerhelper.createReassignmentLog(piw, userinfo.getuserId(), reqPRefix, '', '', '');

sg_Wf_usertriggerhelper.deleteReassignmentLogsForDeletedUsers(userIdList);
sg_wf_userTriggerhelper.sendEmailByInactiveDelegate(userIdList);
sg_wf_userTriggerhelper.assignRequestsBack(userIdList);
*/
        
        Test.stopTest();
        
    }
    
    @testSetup static void setup() {  
        // Create common test accounts      
        
        //     List<Account> testAccts = new List<Account>();       
        
        Profile p =[SELECT ID FROM Profile Where Name='System Administrator'];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test123@seg-automotive23.com';
        u.Email = 'test1234@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = p.Id;
        insert u;
        
        User u1 = new user();
        u1.alias = 'alias';
        u1.LastName = 'lastName';
        u1.Username = 'test123@seg-automotive34.com';
        u1.Email = 'test1234@seg-automotive12.com';
        u1.TimeZoneSidKey = 'Europe/Berlin';
        u1.LocaleSidKey = 'en_US';
        u1.EmailEncodingKey = 'UTF-8';
        u1.LanguageLocaleKey = 'en_US';
        u1.ProfileId = p.Id;
        insert u1;
        
        System.debug('Entering test set up');
        
        
        
    }  
    
    /*  static testMethod void myUnitTest1(){
list<user> u =[select id,Delegate_Investment_Approval__c,Email,Out_Of_Office__c from user ];
test.startTest();
u[0].Delegate_Investment_Approval__c=u[1].Email;
u[0].Out_Of_Office__c=true;
update u[0];
test.stoptest();	        
}
*/     
    /* method for giving record access to delegated approver when delegated approver is changed */
    public static testMethod void DelegatedApproverRecordAccess()
    {
        User user1=[select id,DelegatedApproverId from user where email='test1234@seg-automotive.com' limit 1];
        User user2=[select id from user where email='test1234@seg-automotive12.com' limit 1];
        IFv2_Request__c generalRequest = new IFv2_Request__c();
        generalRequest.Workflow__c = 'General Approval Form';
        generalRequest.Serial__c=true;
        generalRequest.Approver1__c =  user1.Id;
        insert generalRequest;
        IFv2_HeaderController.submitForApproval(generalRequest,Null);
        user1.DelegatedApproverId=user2.id;
        update(user1);

    }
    
}