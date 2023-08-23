/**
* @Name: APTS_AgreementTriggerHandler
* @Author: APTTUS
* @CreateDate: 07/31/2019
* @Description: Triggerhandler for Agreement Trigger.
-----------------------------------------------------------------------------------------------
**/
public class APTS_AgreementTriggerHandler{
    public static void onAfterUpdate(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        APTS_integration_Allowed__c integrationallowed = APTS_integration_Allowed__c.getInstance('Integration_Allowed');
        Boolean allowcallouts = integrationallowed.APTS_Allow_Callout__c;
        APTS_AgreementTriggerHelper.activateFullySignedAgreement(newList,oldMap);
        if(allowcallouts){
            APTS_AgreementTriggerHelper.AgreementActive(newList,oldMap);
        }
    }
    public static void onAfterInsert(List<Apttus__APTS_Agreement__c> newList){APTS_AgreementTriggerHelper.AgreementDocFormatInsert(newList);
    }
    
    public static void onBeforeUpdate(List<Apttus__APTS_Agreement__c> newList, Map<Id,Apttus__APTS_Agreement__c> oldMap){
        APTS_AgreementTriggerHelper.AgreementDocFormatUpdate(newList);
        APTS_AgreementTriggerHelper.setApprovalStatus(newList);
    }
    
    //Agreement End Date - Set automatically to Start Date + 10 yrs
    public static void onBeforeInsert(List<Apttus__APTS_Agreement__c> newList){
        APTS_AgreementTriggerHelper.SetAgreementEndDate(newList);
        APTS_AgreementTriggerHelper.setApprovalStatus(newList);
    }
    
}