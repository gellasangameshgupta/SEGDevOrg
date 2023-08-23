/*******************************************************************************************************
* 
* @ Name        : AQT_SyncProductApplicationBatch
* @ Purpose     : Call the apex class for insert products using product application and surpressing the soql limit
* @ Author      : Khushmeet Kaur
* @ Class Name  : AQT_SyncProductApplicationBatch
* @ Test Class  : AQT_SyncProductApplicationBatchTest
*
*   Date        |  Developer Name              |  Version      |  Changes
* ======================================================================================================
*   02-06-2022  |  khushmeet.kaur@absyz.com    |  1.0          |  Initial Version
*******************************************************************************************************/

public class AQT_SyncProductApplicationBatch implements Database.Batchable<sObject>{
    
    public string strQuery;
    
    public AQT_SyncProductApplicationBatch() {
        
        strQuery = 'SELECT Id, EAN__c, GroovesNumber__c, Product__c, Plant__c, ShopMeProduct__c, ' +
            'PreviousSEGIAMProductNumber__c, ProductType__c, LeadTimeWeeks__c, MOQ__c, Make__c, ' +
            'PulleyDimension__c, PulleyType__c, Rotation__c, SEGIAMProductNumber__c, TeethNumber__c, ' +
            'Weight__c, Voltage__c, OEMItemNumber__c ' +
            'FROM B2B_ProductApplication__c ' +
            'WHERE CreatedDate = LAST_N_DAYS:1 AND Product__c = null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<B2B_ProductApplication__c> scope) {
        B2B_ProductApplicationsToProduct.AQT_syncProductApplicationsToProduct(scope);
    }
    
    public void finish(Database.BatchableContext BC) {
        AsyncApexJob objAsyncApexJob = [SELECT 
                                        Id,
                                        Status,
                                        NumberOfErrors,
                                        JobItemsProcessed,
                                        TotalJobItems
                                        FROM AsyncApexJob
                                        WHERE Id = :BC.getJobId()];
        
        List<String> list_UserOrGroupIds = new List<String>();
        List<String> list_MailToAddresses = new List<String>();
        
        List<Group> list_Groups = [SELECT (SELECT UserOrGroupId FROM GroupMembers) 
                                   FROM Group 
                                   WHERE Name = 'IFv2_Admins'];
        
        if (!list_Groups.isEmpty()) {
            for (GroupMember objGroupMember : list_Groups[0].GroupMembers) {
                list_UserOrGroupIds.add(objGroupMember.UserOrGroupId);
            }
        }
        
        List<User> list_Users = [SELECT Email FROM User WHERE Id IN :list_UserOrGroupIds];
        for (User objUser : list_Users) {
            list_MailToAddresses.add(objUser.Email);
        } 
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage objMail = new Messaging.SingleEmailMessage();
        objMail.setToAddresses(list_MailToAddresses);
        objMail.setSubject('AQT_SyncProductApplicationBatch' + objAsyncApexJob.Status);
        objMail.setPlainTextBody
            ('The batch Apex job processed ' + objAsyncApexJob.TotalJobItems +
             ' batches with '+ objAsyncApexJob.NumberOfErrors + ' failures.');
             
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { objMail });
        }
    }
}