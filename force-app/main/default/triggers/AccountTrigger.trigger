/*******************************************************************************************************
* 
* @ Name 	: AccountTrigger
* @ Purpose : This trigger fires when an Account record is inserted, updated or deleted
* @ Author	: Prasad Vivek
*
*   Date            |  Developer Name                |  Version     |  Changes
* ======================================================================================================
*
*
*******************************************************************************************************/

trigger AccountTrigger on Account (before insert, before update, after insert,after update,after delete) {
    
    AccountHandler accntHandler = new AccountHandler();
    if(trigger.isBefore) {
        if(trigger.isInsert) {
            accntHandler.OnBeforeInsert(trigger.new);
        } else if( trigger.isUpdate) {
            accntHandler.OnBeforeUpdate(trigger.newMap, trigger.oldMap);    
        }   
    }
    
    IFv2_TriggerHandler objTriggerHandler = new IFv2_TriggerHandler();
    // Added by Madhura for Rollup summary
    if (Trigger.isAfter) {
        if(Trigger.isInsert || Trigger.isUpdate) {
            objTriggerHandler.RollupSummaryDetails(trigger.new);
        } else if(Trigger.isDelete) {
            objTriggerHandler.RollupSummaryDetails(Trigger.old);
        }
    } 
}