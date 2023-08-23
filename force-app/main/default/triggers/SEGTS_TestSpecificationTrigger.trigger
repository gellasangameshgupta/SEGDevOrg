/****************************************************************************
    Trigger Name    :SEGTS_TestSpecificationTrigger
    Purpose         :To delete Test Spec with child
    Created By      :RBEI
    Created Date    :Jan 2019
*****************************************************************************/
trigger SEGTS_TestSpecificationTrigger on Test_Specification__c (before insert,before update) {
    String enableTrigger = System.Label.Segts_TS_Trigger_Enable;
    System.debug('enableTrigger:::::::::::'+enableTrigger);
    
    String duplicateCheck = System.Label.Segts_Dup_Validation;
    System.debug('duplicateCheck:::::::::::'+duplicateCheck);
    if(Trigger.isBefore && Trigger.isInsert) {
        if('TRUE'.equalsIgnoreCase(duplicateCheck)) {
            SEGTS_TSTriggerHandler.beforeInsert(Trigger.New);
        }
        if('TRUE'.equalsIgnoreCase(enableTrigger)) {
            System.debug('data upload');
            SEGTS_TSTriggerHandler.dataUpload(Trigger.New);
        }
    } 
    if(Trigger.isBefore && Trigger.isUpdate) {
        String enableTrigger = System.Label.Segts_TS_Trigger_Enable;
        System.debug('enableTrigger:::::::::::'+enableTrigger);
        if('TRUE'.equalsIgnoreCase(enableTrigger)) {
            System.debug('data upload');
            SEGTS_TSTriggerHandler.dataUpload(Trigger.New);
        }
    }
        
}