trigger CLM_AgreementTrigger on Apttus__APTS_Agreement__c (After insert, after update , before update, before insert) {
    
    if (Trigger.isUpdate && Trigger.isAfter) {
        CLM_AgreementTriggerHelper.HelperPlantDetails(Trigger.new, Trigger.oldMap); 
    }
    
    if(Trigger.isInsert && Trigger.isAfter){
        CLM_AgreementTriggerHelper.HelperPlantDetails(Trigger.new, null);
    }
    
}