/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderButtonController
* @ Purpose         :   Controller for LWC b2b_orderControlButton
* @ Methods         :   1) B2B_OrderButtonController - Updates Order Summary fields
terms and conditions
*                       params - String, String, String
* @ Author          :   Aseem Doddamani
* @ Usage           :   1) To update the details user cancel/returns order,
*                       from the B2B Portal Order Detail screen
* @ Test Class Name :   B2B_OrderItemTriggerHandlerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   05-08-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*   12-12-2022      |  pradeep.chary@absyz.com        |  2.0          |  Added method updateOrderSummaryDetails
*
*******************************************************************************************************/
public without sharing class B2B_OrderButtonController {
    
    @AuraEnabled
    public static void updateOrderSummaryFields(
        String strOrderSummaryID, 
        String strStatusValue, 
        String strReason
    ) {
        try {
            if(strOrderSummaryID != null) {
                OrderSummary objOrderSummary = [SELECT
                                                Id,
                                                Status,
                                                B2B_OrderActionReason__c
                                                FROM
                                                OrderSummary
                                                WHERE Id = :strOrderSummaryID
                                                LIMIT 1];
                
                objOrderSummary.Status = strStatusValue;
                objOrderSummary.B2B_OrderActionReason__c = strReason;
                
                update objOrderSummary;
            }
        } catch(Exception ex) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
        }
    }
    
    @InvocableMethod
    public static void updateOrderSummaryDetails(List<OrderSummary> list_OrderSummaries) {
        if (!list_OrderSummaries.isEmpty()) {
            try {
                update list_OrderSummaries;
            } catch(Exception ex) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(ex);
            }
        }
    }
}