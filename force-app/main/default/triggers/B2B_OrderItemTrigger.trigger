/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderItemTrigger
* @ Purpose         :   For Ordered Quantity Calculation on Product
* @ Author          :   Monal Kumar
* @ Test Class Name :   
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   17-06-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
trigger B2B_OrderItemTrigger on OrderItem(after insert, after update) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            B2B_OrderItemTriggerHandler.updateOrderedQuantityOnProduct(Trigger.new);
        }
    }
}