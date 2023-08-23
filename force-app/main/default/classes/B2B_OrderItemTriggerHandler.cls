/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderItemTriggerHandler
* @ Purpose         :   For Ordered Quantity Calculation on Product
* @ Author          :   Monal Kumar
* @ Test Class Name :   B2B_OrderItemTriggerHandlerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   17-06-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_OrderItemTriggerHandler {
    
    public static void updateOrderedQuantityOnProduct(List<OrderItem> list_OrderItems) {
        
        /* Used to Activate or deactivate this method*/
        Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic(
            'B2B_OrderItemTriggerHandler',
            'updateOrderedQuantityOnProduct'
        );
        
        /* checking if donotExecuteTrigger variable is true or false */
        if (!donotExecuteTrigger) {
            List<Product2> list_Products = new List<Product2>();
            Set<Id> set_ProductIds = new Set<Id>();
            
            for (OrderItem objOrderItem : list_OrderItems) {
                if (objOrderItem.Product2Id != null) {
                    set_ProductIds.add(objOrderItem.Product2Id);
                }
            }
            
            /* Getting the aggregated results from OrderItem */
            AggregateResult[] list_GroupedResults = [SELECT 
                                                     sum(Quantity) intQuantity,
                                                     Product2Id 
                                                     FROM 
                                                     OrderItem  
                                                     WHERE 
                                                     Product2Id IN :set_ProductIds 
                                                     AND 
                                                     Product2.IsActive = true
                                                     GROUP BY Product2Id];
            
            /* To check if groupedResults LIST is not empty */
            if (!list_GroupedResults.isEmpty()) {
                for (AggregateResult objOrderItem : list_GroupedResults) {
                    if ((String) objOrderItem.get('Product2Id') != null) { 
                        if ((Decimal) objOrderItem.get('intQuantity') != null) {
                            list_Products.add(
                                new Product2(
                                    Id = (String) objOrderItem.get('Product2Id'),
                                    B2B_QuantityOrdered__c = (Decimal) objOrderItem.get('intQuantity')
                                )
                            );
                        }
                    }
                } 
            }
            
            /* updating the request records */
            if (!list_Products.isEmpty()) {
                IFv2_DmlController.GenericListDMLOperation(list_Products, 'update');
            }
        }
    }
}