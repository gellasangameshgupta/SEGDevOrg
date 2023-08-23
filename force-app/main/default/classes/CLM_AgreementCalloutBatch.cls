/**
* @description Used to push Agreement related data to Jagger
* @createdDate Jul 26, 2022
*/
public class CLM_AgreementCalloutBatch implements Database.Batchable<SObject>,Database.AllowsCallouts, System.Schedulable {
    public Database.QueryLocator start(database.BatchableContext bc){
        
        String query = Label.CLM_AgreementCalloutBatch_Query;
        System.debug('query:'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc,List<Apttus__APTS_Agreement__c>agreementList){
        CLM_AgreementCalloutUtility callout = new CLM_AgreementCalloutUtility();
        callout.putAgreements(agreementList);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    public void execute(System.SchedulableContext sc) {
        Database.executeBatch(new CLM_AgreementCalloutBatch());
    }

}