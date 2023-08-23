/**
* @Name: APTS_AgreementTrigger
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Trigger on Agreement object.
-----------------------------------------------------------------------------------------------
**/
trigger APTS_AgreementTrigger on Apttus__APTS_Agreement__c (before Insert, before Update, after update) {   
    
    if (Trigger.isUpdate && Trigger.isAfter) {
        APTS_AgreementTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap); 
        
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        APTS_AgreementTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
       APTS_AgreementTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger.isInsert && Trigger.isBefore){
       APTS_AgreementTriggerHandler.onBeforeInsert(Trigger.new);
    }
    
    if(Trigger.isInsert && Trigger.isBefore)
    {
        APTS_AgreementTriggerHelper.SetAgreementEndDate(Trigger.new);        
    }
    
}