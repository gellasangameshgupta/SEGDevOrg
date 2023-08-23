/**
* @Name: APTS_AgreementClauseTriggerHandler
* @Author: APTTUS
* @CreateDate: 01/31/2020
* @Description: Triggerhandler for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/
public class APTS_AgreementClauseTriggerHandler {
    
    public static void onAfterInsert(List<Apttus__Agreement_Clause__c> newList){
        system.debug('APTS_AgreementClauseTriggerHandler - After Inset Event fired');
        APTS_AgreementClauseTriggerHelper.UpdateApprovalRequired(newList);                                                                              
    }

}