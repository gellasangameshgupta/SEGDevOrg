@isTest(seeAllData=true)
public class DetectiveControlsAutomationApexTest {
    public static testmethod void DetectiveControlsAutomationAllTest() {
        test.startTest();
        User user1,user2;
        List<user> users=[select id,NT_User__c,Name from user where profile.name=:Label.CLIFv20008 and IsActive=true limit 2];
        if(users.size()>1)
        {
            user1=users.get(0);
            user2=users.get(1);
        }
        Id recordTypeId = [SELECT Id,Name,SobjectType FROM RecordType where Name =:Label.DCA_recordType limit 1].id;
        Contact contact=new Contact();
        contact.RecordTypeId=recordTypeId;
        contact.FirstName='test name';
        contact.DCA_NameofSAPSystem__c='SAP test';
        contact.DCA_AuthType__c='Auth test';
        contact.DCA_Authorization__c='Authorization test';
        contact.DCA_AuthorizationDescription__c='test';
        contact.DCA_Function__c='function';
        contact.DCA_BusinessCase__c='case test';
        contact.DCA_User__c=user1.id;
        contact.LastName=user1.Name;
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
        contact2.DCA_User__c=user1.id;
        contact2.LastName=user1.Name;
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
        contact3.DCA_User__c=user1.id;
        contact3.LastName=user1.Name;
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
        contact3.DCA_Status__c='Rejected';
        contact3.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(contact3);
        
        
        Contact contact4=new Contact();
        contact4.FirstName='test name';
        contact4.RecordTypeId=recordTypeId;
        contact4.DCA_User__c=user1.id;
        contact4.LastName=user1.Name;
        contact4.DCA_ValidFrom__c=System.today();
        contact4.DCA_ValidTo__c=System.today()+1;
        contact4.DCA_Company__c='SEG';
        contact4.DCA_Status__c='Pending';
        contact4.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        insert(contact4);
        
        contact4.DCA_ApprovalComment__c='test';
        update(contact4);      
        DetectiveControlsAutomationApex.fetchCount();
        //   DetectiveControlsAutomationApex.fetchDetailsNext(1,null,null,null);
        DetectiveControlsAutomationApex.fetchDetailsNext(1,contact.id,'Id','asc ');
        DetectiveControlsAutomationApex.SearchData('','','',null,null);
        DetectiveControlsAutomationApex.SearchSubmittedData('','','',null,null);
        DetectiveControlsAutomationApex.fetchSubmittedDetailsNext(1,contact.id,'Id','asc ');
        DetectiveControlsAutomationApex.fetchRecordForUpdateComp(contact2.id);
        DetectiveControlsAutomationApex.getPicklistvalues('DCA_Status__c');
        
        DetectiveControlsAutomationApex.SlotWrapper slotwrap=new DetectiveControlsAutomationApex.SlotWrapper();
        slotwrap.id=contact2.Id;
        slotwrap.DCA_Status='Processed';
        slotwrap.DCA_ApprovalComment='Processed';
        DetectiveControlsAutomationApex.SlotWrapper slotwrapSub=new DetectiveControlsAutomationApex.SlotWrapper();
        slotwrapSub.id=contact2.Id;
        slotwrapSub.DCA_Status='Processed';
        slotwrapSub.DCA_ApprovalComment='Processed';
        List<DetectiveControlsAutomationApex.SlotWrapper>submitlist=new List<DetectiveControlsAutomationApex.SlotWrapper>();
        submitlist.add(slotwrapSub);
        slotwrap.userList=submitlist;
        DetectiveControlsAutomationApex.submitRecord(JSON.serialize(slotwrap));
        
        DetectiveControlsAutomationApex.SlotWrapper slotwrap2=new DetectiveControlsAutomationApex.SlotWrapper();
        slotwrap2.id=contact3.Id;
        slotwrap2.DCA_Status='Processed';
        slotwrap2.DCA_ApprovalComment='Processed';
        DetectiveControlsAutomationApex.submitRecordForUpdateComp(JSON.serialize(slotwrap2));
        
        contact4.DCA_Status__c='Rejected';
        contact4.DCA_ApprovalComment__c='Reject test';
        update contact4;
        
        
        contact4.DCA_Status__c='Rejected';
        contact4.DCA_ApprovalComment__c='test';
        update contact4;
        
        contact4.DCA_Status__c='Approved';
        contact4.DCA_ApprovalComment__c='test';
        update contact4;
        
        contact4.FirstName='test first';
        update contact4;
        
        contact4.DCA_ProcessingComment__c='test process';
        update contact4;
        
        test.stopTest();
    }
    
}