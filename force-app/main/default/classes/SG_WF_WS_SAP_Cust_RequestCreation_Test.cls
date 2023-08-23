@isTest
private class SG_WF_WS_SAP_Cust_RequestCreation_Test {
    
    @TestSetup
    static void testSetup(){
        /*commented for cleaning up of Insightflow 1.0 components
Workflow__c wf = new Workflow__c();
wf.Name = 'AP Monitor Workflow-1';
wf.Application_Key__c = 'APM1';
insert wf;
*/
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
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
            NT_User__c = 'SAP123'
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
            NT_User__c = 'SAP321'
        );
        insert u2;
        List<User> uList = [SELECT Id FROM User];
        System.assertEquals(true, uList.size()>0);
    }
    
    static testMethod void mandatoryFieldsTest(){
        SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper rw = new SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper();
        rw.Approver_name = 'TESTSAP123';
        
        Test.startTest();
        try{
            SG_WF_WS_SAP_Cust_RequestCreation.createApmRequest(rw);
        } catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Salesforce ID, Approver Name and Workflow number are required, please check if are filled properly') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
    static testMethod void reqCreationTest(){
        
        Scan__c scan = new Scan__c();
        insert scan;
        
        Attachment att = new Attachment();
        att.body = Blob.valueof('123');
        att.name = 'UnitTestAttachment';
        att.ParentId = scan.Id;
        insert att;
        
        Scan__c scanAfterInsert = [SELECT Id, Name FROM Scan__c WHERE Id=: scan.Id LIMIT 1];
        
        SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper rw = new SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper();
        rw.Approver_name = 'TESTSAP123';
        System.debug('MSWIST TEST: ' +scanAfterInsert.Name);
        rw.Salesforce_ID = scanAfterInsert.Name;
        rw.Workflow_number = '01';
        rw.Approver_Proxy_name = 'TESTSAP321';
        
        LIST<IFv2_Workflows__mdt> workflowList =[SELECT Name__c,ThirdPartyFormat__c,Status__c,DeactivateInInsightflow1__c
                                                 FROM IFv2_Workflows__mdt 
                                                 WHERE ThirdPartyFormat__c != NULL AND ThirdPartyFormat__c = : rw.Workflow_number];
        System.debug('IFv2_Workflows__mdt>>'+workflowList);
        SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject response = SG_WF_WS_SAP_Cust_RequestCreation.createApmRequest(rw);
        System.debug('reqCreationTest>>response>>'+response);
        
        System.assertEquals('ERROR', response.result);
        System.assert(String.isBlank(response.objectId));
    }  
    
    // Test method to create test data from SAP
    static testMethod void reqCreationTestTwo(){
        
        Scan__c scan = new Scan__c();
        insert scan;
        
        Attachment att = new Attachment();
        att.body = Blob.valueof('123');
        att.name = 'UnitTestAttachment';
        att.ParentId = scan.Id;
        insert att;
        
        Scan__c scanAfterInsert = [SELECT Id, Name FROM Scan__c WHERE Id=: scan.Id LIMIT 1];
        
        SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper rw = new SG_WF_WS_SAP_Cust_RequestCreation.RequestWrapper();
        rw.Approver_name = 'SAP321';
        System.debug('MSWIST TEST: ' +scanAfterInsert.Name);
        rw.Salesforce_ID = scanAfterInsert.Name;
        rw.Workflow_number = '01';
        rw.Approver_Proxy_name = 'SAP123';
        
        SG_WF_WS_SAP_Cust_RequestCreation.ResponseObject response = SG_WF_WS_SAP_Cust_RequestCreation.createApmRequest(rw);
        System.debug('test>>response>>'+response);
        //System.assertEquals('ERROR', response.result);
        //System.assert(String.isBlank(response.objectId));
    } 
}