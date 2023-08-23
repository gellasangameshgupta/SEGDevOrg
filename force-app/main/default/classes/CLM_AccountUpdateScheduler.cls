/**
* @description Used to schedule update of Salesforce Accounts from Jagger on a daily basis
* @createdDate Jan 26, 2022
*/
public without sharing class CLM_AccountUpdateScheduler implements Schedulable{
    public void execute(SchedulableContext SC) {
        CLM_AccountCalloutUtility.bulkUpsert();
    }
}