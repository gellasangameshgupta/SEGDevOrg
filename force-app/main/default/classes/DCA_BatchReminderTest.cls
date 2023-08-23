@isTest(seeAllData=true)
public class DCA_BatchReminderTest {
    public static testmethod void DCA_BatchReminderTest() {
        test.startTest();
        User user1,user2;
        List<user> users=[select id,NT_User__c,Name from user where profile.name=:Label.CLIFv20008 and IsActive=true limit 2];
        if(users.size()>1)
        {
            user1=users.get(0);
            user2=users.get(1);
        }
        Contact contact=new Contact();
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
        contact.DCA_Status__c='Pending';
        contact.DCA_DisciplinaryManager__c=UserInfo.getUserId();
        contact.CreatedDate=Date.today();
        insert(Contact);
        
        Contact contact2=new Contact();
        contact2.FirstName='test name';
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
        contact2.DCA_Status__c='Pending';
        contact2.DCA_DisciplinaryManager__c=UserInfo.getUserId();
       // integer escDays=Integer.valueof(Label.DCA_EscalationDays);
        contact2.CreatedDate=Date.today();
        insert(contact2);
         /*       
        DateTime day=system.today();
        DCA_BatchPendingNotifyManager bc=new DCA_BatchPendingNotifyManager(day);
        Database.executeBatch(bc,1);
        */
        DCA_BatchReminder br=new DCA_BatchReminder();
        Database.executeBatch(br);
        
        test.stopTest();
     
    }
    
}