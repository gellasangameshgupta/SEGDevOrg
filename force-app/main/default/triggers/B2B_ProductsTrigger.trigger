/*******************************************************************************************************
* @ Name        : 	B2B_ProductsTrigger 
* @ Purpose     : 	Trigger for object Product2
* @ Author      : 	Keerthana
*
*   Date        |  Developer Name             		  |  Version      |  Changes
* ======================================================================================================
*   29-11-2022  |  keerthana.kadampally@absyz.com   |  1.0          |  Initial Version
*
*******************************************************************************************************/
trigger B2B_ProductsTrigger on Product2(after update) {

    /* Used to Activate or deactivate this method*/
    Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic(
        'B2B_ProductQuantityRuleAsyncHelper',
        'B2B_ProductQuantityRuleAsyncHelper'
    );
    
    /* checking if donotExecuteTrigger variable is true or false */
    if (!donotExecuteTrigger && Trigger.isAfter && Trigger.isUpdate) {
        System.enqueueJob(new B2B_ProductQuantityRuleAsyncHelper(Trigger.newMap, Trigger.oldMap));
    }
}