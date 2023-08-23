/**
* @Name: APTS_AgreementTriggerTst
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Test Class for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/

@isTest
private class APTS_AgreementTriggerTst {
    
    @isTest static void autoActivateAgreementTest() {
        Account acc = new Account();
        acc.Name = 'testAccountforTestClass';
        
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name ='testOpptyforTestClass';
        opp.CloseDate = system.today()+4;
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.Id;
        
        insert opp;
        
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
        
        list<Apttus__APTS_Agreement__c> agList = new list<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agg = new Apttus__APTS_Agreement__c();
        // agg.name = 'testAgreementforTestclass';
        agg.APTS_Internal_Legal_Entity__c = acc.Id;
        agg.APTS_Type_of_Signature__c ='Esignature';
        agg.Apttus__Contract_Start_Date__c = system.today();
        agg.Apttus__Account__c = acc.Id;
        agg.Apttus__Status__c = 'Ready for Signatures';
        agg.APTS_BufferStockInWorkingDays__c = 10;
        agg.Name = 'NDA';
        agg.Apttus_Approval__Approval_Status__c = 'Approved';
        agg.APTS_WarrantyPeriod__c = 20;           
        agList.add(agg);
        
        Apttus__APTS_Agreement__c agg1 = new Apttus__APTS_Agreement__c();
        // agg.name = 'testAgreementforTestclass';
        agg1.APTS_Internal_Legal_Entity__c = acc.Id;
        agg1.APTS_Type_of_Signature__c ='Esignature';
        agg1.Apttus__Contract_Start_Date__c = system.today();
        agg1.Apttus__Account__c = acc.Id;
        agg1.Apttus__Status__c = 'Ready for Signatures';
        agg1.Name = 'Corporate Agreement';
        agg1.APTS_BufferStockInWorkingDays__c = 10;
        agg1.Apttus_Approval__Approval_Status__c = 'Not Submitted';
       agg1.APTS_Final_Checked_In__c = False;
        agList.add(agg1);
        insert agList;
      //  agg.Apttus__Status__c = 'Activated';
      //  update agg;
       APTS_AgreementTriggerHelper.AgreementDocFormatInsert(agList);
        Apttus__MergeEvent__c app = new Apttus__MergeEvent__c();
        //app.Apttus__MergeEvent__c = 'Testmerge';
        app.Apttus__Action__c = 'Check In';
        app.Apttus__DocumentInfo__c = 'Final';
        insert app;      
        
        Apttus__MergeEvent__c app1 = new Apttus__MergeEvent__c();
        //app.Apttus__MergeEvent__c = 'Testmerge';
        app1.Apttus__Action__c = 'Check In';
        app1.Apttus__DocumentInfo__c = 'Final';
        app1.Apttus__AgreementId__c =agg.Id;
        insert app1;      
        
        ContentVersion att = new ContentVersion();
        att.VersionData= blob.valueOf('abcd');
        att.PathOnClient = 'signedDoc.PDF';
        att.ReasonForChange = 'Final Signed';
        insert att;
        
        ContentVersion cv = [select id,ContentDocumentId from contentVersion where id =: att.Id];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = agg1.Id;
        cdl.ShareType ='V';
        insert cdl;
        
        system.debug([SELECT Id,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE ID = :agg1.ID]);
        Test.StartTest();
        agg.Apttus__Status__c = 'Fully Signed';
        update agg;
        
        agg1.Apttus__Status__c = 'Fully Signed';
        update agg1;
        Test.stopTest();
    }
    
}