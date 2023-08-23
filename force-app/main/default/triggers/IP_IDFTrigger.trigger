/*******************************************************************************************************
* 
* @ Name    :   IP_IDFTrigger
* @ Purpose :   Trigger on Case object for IPFolio application. 
                Provides access to IP Manager and PRC Member based on the mapping.
* @ Author  :   madhuravani.b@absyz.com
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  madhuravani.b@absyz.com      |  1.0          |  Initial Version
*********************************************************************************************************************/
trigger IP_IDFTrigger on Case (after Insert, after Update) {
    
    if(Trigger.isAfter){
        if(trigger.isInsert){
            if(!IP_CheckRecursion.firstcall) {
                IP_CheckRecursion.firstcall = true;
                IP_IDFTriggerHelper.createsharingrecords(trigger.new, null);
                IP_IDFTriggerHelper.updateFamilyStatus(trigger.new);
            }
        }
        if(trigger.isUpdate ){
            if(!IP_CheckRecursion.firstcall1) {
                IP_CheckRecursion.firstcall1 = true;
                IP_IDFTriggerHelper.createsharingrecords(trigger.new, trigger.oldmap);
                IP_IDFTriggerHelper.updateFamilyStatus(trigger.new);
            }
        } 
    }
}