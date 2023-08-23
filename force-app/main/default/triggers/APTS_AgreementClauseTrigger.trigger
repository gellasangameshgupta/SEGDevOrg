/**
* @Name: APTS_AgreementClauseTrigger
* @Author: APTTUS
* @CreateDate: 01/31/2020
* @Description: Trigger on AgreementClause object
-----------------------------------------------------------------------------------------------
**/
trigger APTS_AgreementClauseTrigger on Apttus__Agreement_Clause__c (after Insert) {   
    
    if(Trigger.isInsert && Trigger.isAfter){
        system.debug('After Inset Event fired');
        APTS_AgreementClauseTriggerHandler.onAfterInsert(Trigger.new);
    }
}