@isTest
public class DCA_HR_ControllerTest {
    public static testmethod void DCA_HR_ControllerTest1() {
        test.startTest();
        User user1,user2;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new user();
        u.alias = 'alias';
        u.LastName = 'lastName';
        u.Username = 'test@testingfsagdgdsbggfbsajkdf.com';
        u.Email = 'test@seg-automotive.com';
        u.TimeZoneSidKey = 'Europe/Berlin';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = profileId.Id;
        u.Department = '123';
        insert u;
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name ='DCA HR Apps' limit 1].id;
        Contact contact=new Contact();
        contact.RecordTypeId=recordTypeId;
        contact.FirstName='test name';
        contact.DCA_NameofSAPSystem__c='SFSF EC';
        contact.DCA_AuthType__c='Auth test';
        contact.DCA_Authorization__c='Authorization test';
        contact.DCA_AuthorizationDescription__c='test';
        contact.DCA_Function__c='function';
        contact.DCA_BusinessCase__c='case test';
        contact.DCA_User__c=u.id;
        contact.LastName=u.LastName;
        contact.DCA_Risk__c='risk';
        contact.DCA_Role__c='role';
        contact.DCA_RoleDescription__c='dis';
        contact.DCA_LockedBy__c='locked';
        contact.DCA_ValidFrom__c=System.today();
        contact.DCA_ValidTo__c=System.today()+1;
        contact.DCA_Department__c='Department';
        contact.DCA_DepartmentActive__c='Dep';
        contact.DCA_Location__c='Goa';
        contact.DCA_Company__c='SEG';
        contact.DCA_Status__c='Processed';
        contact.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(Contact);
        
        Contact contact2=new Contact();
        contact2.FirstName='test name';
        contact2.RecordTypeId=recordTypeId;
        contact2.DCA_NameofSAPSystem__c='SAP test';
        contact2.DCA_AuthType__c='Auth test';
        contact2.DCA_Authorization__c='Authorization test';
        contact2.DCA_AuthorizationDescription__c='test';
        contact2.DCA_Function__c='function';
        contact2.DCA_BusinessCase__c='case test';
        contact2.DCA_User__c=u.id;
        contact2.LastName=u.LastName;
        contact2.DCA_Risk__c='risk';
        contact2.DCA_Role__c='role';
        contact2.DCA_RoleDescription__c='dis';
        contact2.DCA_LockedBy__c='locked';
        contact2.DCA_ValidFrom__c=System.today();
        contact2.DCA_ValidTo__c=System.today()+1;
        contact2.DCA_Department__c='Department';
        contact2.DCA_DepartmentActive__c='Dep';
        contact2.DCA_Location__c='Goa';
        contact2.DCA_Company__c='SEG';
        contact2.DCA_Status__c='Rejected';
        contact2.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(contact2);
        
        Contact contact3=new Contact();
        contact3.FirstName='test name';
        contact3.RecordTypeId=recordTypeId;
        contact3.DCA_NameofSAPSystem__c='SAP test';
        contact3.DCA_AuthType__c='Auth test';
        contact3.DCA_Authorization__c='Authorization test';
        contact3.DCA_AuthorizationDescription__c='test';
        contact3.DCA_Function__c='function';
        contact3.DCA_BusinessCase__c='case test';
        contact3.DCA_User__c=u.id;
        contact3.LastName=u.LastName;
        contact3.DCA_Risk__c='risk';
        contact3.DCA_Role__c='role';
        contact3.DCA_RoleDescription__c='dis';
        contact3.DCA_LockedBy__c='locked';
        contact3.DCA_ValidFrom__c=System.today();
        contact3.DCA_ValidTo__c=System.today()+1;
        contact3.DCA_Department__c='Department';
        contact3.DCA_DepartmentActive__c='Dep';
        contact3.DCA_Location__c='Goa';
        contact3.DCA_Company__c='SEG';
        contact3.DCA_Status__c='';
        contact3.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(contact3);
        
        
        Contact contact4=new Contact();
        contact4.FirstName='test name';
        contact4.RecordTypeId=recordTypeId;
        contact4.DCA_User__c=u.id;
        contact4.LastName=u.LastName;
        contact4.DCA_ValidFrom__c=System.today();
        contact4.DCA_ValidTo__c=System.today()+1;
        contact4.DCA_Company__c='SEG';
        contact4.DCA_Status__c='Delete User';
        contact4.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(contact4);
        
        contact4.DCA_ApprovalComment__c='test';
        //update(contact4);      
        DCA_HR_Controller.returncontact();
        //   DetectiveControlsAutomationApex.fetchDetailsNext(1,null,null,null);
        DCA_HR_Controller.returncontactGeneral('SFSF EC');
        DCA_HR_Controller.SearchData('','','',null,null,'SFSF EC');
        //DCA_HR_Controller.SearchSubmittedData('','','',null,null.'SFSF EC');
        DCA_HR_Controller.submitRecord('','SFSF EC');
       // DCA_HR_Controller.fetchRecordForUpdateComp(contact2.id);
        DCA_HR_Controller.getPicklistvalues('DCA_Status__c');
        
        DCA_HR_Controller.SlotWrapper slotwrap=new DCA_HR_Controller.SlotWrapper();
        slotwrap.id=contact2.Id;
        slotwrap.DCA_Status='Processed';
        slotwrap.DCA_ApprovalComment='Processed';
        DCA_HR_Controller.SlotWrapper slotwrapSub=new DCA_HR_Controller.SlotWrapper();
        slotwrapSub.id=contact2.Id;
        slotwrapSub.DCA_Status='Processed';
        slotwrapSub.DCA_ApprovalComment='Processed';
        List<DCA_HR_Controller.SlotWrapper>submitlist=new List<DCA_HR_Controller.SlotWrapper>();
        submitlist.add(slotwrapSub);
        slotwrap.userList=submitlist;
      //  DCA_HR_Controller.submitRecord(JSON.serialize(slotwrap));
        
        DCA_HR_Controller.SlotWrapper slotwrap2=new DCA_HR_Controller.SlotWrapper();
        slotwrap2.id=contact3.Id;
        slotwrap2.DCA_Status='Processed';
        slotwrap2.DCA_ApprovalComment='Processed';
        //DCA_HR_Controller.submitRecordForUpdateComp(JSON.serialize(slotwrap2));
        
        contact4.DCA_Status__c='Rejected';
        contact4.DCA_ApprovalComment__c='Reject test';
       // update contact4;
        
        
        contact4.DCA_Status__c='Rejected';
        contact4.DCA_ApprovalComment__c='test';
       // update contact4;
        
        contact4.DCA_Status__c='Approved';
        contact4.DCA_ApprovalComment__c='test';
       // update contact4;
        
        contact4.FirstName='test first';
       // update contact4;
        
        contact4.DCA_ProcessingComment__c='test process';
       // update contact4;
        
        DCA_HR_Roles__c roleObj = new DCA_HR_Roles__c();
        roleObj.Role_Id__c = 'testId';
        roleObj.Role_Description__c = 'Test desc';
        roleObj.Risk_Assessment_Type__c = 'Test Risk';
        insert roleObj;
        contact4.DCA_Hr_Role_Id__c = roleObj.Role_Id__c;
        contact4.DCA_Status__c = 'Delete User';
        contact4.email = 'test@g.com';
       // update contact4;
        contact4.DCA_Status__c = 'Approved';
        update contact4;
        DCA_HR_AssignmentNotificationBatch obj = new DCA_HR_AssignmentNotificationBatch('Insert');
        DataBase.executeBatch(obj); 
        test.stopTest();
    }
    
}