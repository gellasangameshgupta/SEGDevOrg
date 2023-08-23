/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderTrigger
* @ Purpose         :   For Order and OrderItem Creation
* @ Author          :   Prathiksha Suvarna
* @ Test Class Name :   
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   26-12-2022      |  Prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
trigger B2B_OrderTrigger on Order(Before Update) {
    
    // if (Trigger.isBefore) {
    //     if (Trigger.isUpdate) {
    //         B2B_OrderTriggerHandler.createShopMeOrders(Trigger.newMap);
    //     }
    // }
}