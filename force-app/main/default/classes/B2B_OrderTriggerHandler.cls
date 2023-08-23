/*******************************************************************************************************
* 
* @ Name            :   B2B_OrderTriggerHandler
* @ Purpose         :   For Order Summary Calculation
* @ Author          :   Prathiksha Suvarna
* @ Test Class Name :   B2B_OrderTriggerHandler
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   21-12-2022      |  prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_OrderTriggerHandler {
    
      
    public static void createShopMeOrders(Map<Id, Order> map_OrderById) {
        
        /* Used to Activate or deactivate this method*/
    	Boolean donotExecuteTrigger = IFv2_UtilsController.getTriggerLogic(
        	'B2B_OrderTriggerHandler',
        	'createShopMeOrders'
    	);
        
        /* checking if donotExecuteTrigger variable is true or false */
        if (!donotExecuteTrigger) {
            Map<Id, List<OrderItem>> map_RegularOrderItemsByOrderId = new Map<Id, List<OrderItem>>();
            Map<Id, List<OrderItem>> map_PickMeOrderItemsByOrderId = new Map<Id, List<OrderItem>>();
            Map<Id, List<OrderSummary>> map_OrderSummaryByOrderId = new Map<Id, List<OrderSummary>>();
            Map<Id, B2B_ShopMeOrder__c> map_ShopMeRegularOrderByOrderId = new Map<Id, B2B_ShopMeOrder__c>();
            Map<Id, B2B_ShopMeOrder__c> map_ShopMePickMeOrderByOrderId = new Map<Id, B2B_ShopMeOrder__c>();
            Map<Id, List<OrderItemSummary>> map_OrderItemSummaryByOrderId = new Map<Id, List<OrderItemSummary>>();
            Set<Id> set_OrderItemIds = new Set<Id>();    
            Map<Id, OrderItemSummary> map_OrderItemSummaryByOrderItemId = new Map<Id, OrderItemSummary>();
            Map<Id, OrderSummary> map_OrderSummaryIdByOrderId = new Map<Id, OrderSummary>();
            Set<Id> set_RegularOrderIds = new Set<Id>();
            
            for (OrderSummary objOrderSummary : [SELECT 
                                                 Id,
                                                 OriginalOrderId
                                                 FROM OrderSummary
                                                 WHERE 	OriginalOrderId IN :map_OrderById.keySet()]
            	) {
                map_OrderSummaryIdByOrderId.put(objOrderSummary.OriginalOrderId, objOrderSummary);    
            }
            
            for (OrderItem objOrderItem : [SELECT 
                                           Id,
                                           OrderId,
                                           Product2Id,
                                           Quantity,
                                           ListPrice,
                                           UnitPrice,
                                           TotalLineAmount,
                                           TotalPrice,
                                           Product2.B2B_QuantityRemaining__c,
                                           Product2.Name 
                                           FROM OrderItem 
                                           WHERE OrderId IN :map_OrderById.keySet()]
                ) {
                    set_OrderItemIds.add(objOrderItem.Id);
                    if (objOrderItem.Quantity > objOrderItem.Product2.B2B_QuantityRemaining__c) {
                        system.debug('inside out of stock');
                        if (map_RegularOrderItemsByOrderId.containsKey(objOrderItem.OrderId)) {
                            map_RegularOrderItemsByOrderId.get(objOrderItem.OrderId).add(objOrderItem);
                        } else {
                            map_RegularOrderItemsByOrderId.put(objOrderItem.OrderId, new List<OrderItem>{objOrderItem});
                        }
                    } else {
                        system.debug('inside in stock');
                        if (map_PickMeOrderItemsByOrderId.containsKey(objOrderItem.OrderId)) {
                            map_PickMeOrderItemsByOrderId.get(objOrderItem.OrderId).add(objOrderItem);
                        } else {
                            map_PickMeOrderItemsByOrderId.put(objOrderItem.OrderId, new List<OrderItem>{objOrderItem});
                        }
                        
                    }
                }
            system.debug('map_RegularOrderItemsByOrderId :: ' + map_RegularOrderItemsByOrderId);
            system.debug('map_PickMeOrderItemsByOrderId :: ' + map_PickMeOrderItemsByOrderId);
            system.debug('Set of OrderItems :: '+ set_OrderItemIds);
            for (OrderItemSummary objOrderItemSummary : [SELECT 
                                                         Id,
                                                         OrderSummaryId,
                                                         Product2Id,
                                                         OrderSummary.OriginalOrderId,
                                                         OriginalOrderItemId,
                                                         ShopMeOrder__c
                                                         FROM OrderItemSummary
                                                         WHERE OriginalOrderItemId IN :set_OrderItemIds]
                ) {
                    map_OrderItemSummaryByOrderItemId.put(objOrderItemSummary.OriginalOrderItemId, objOrderItemSummary);
                    //map_OrderSummaryIdByOrderId.put(objOrderItemSummary.OrderSummary.OriginalOrderId, objOrderItemSummary.OrderSummaryId);
                }
            
            for (Order objOrder : map_OrderById.values()) {
                system.debug('objOrder :: ' + objOrder);
                if (map_RegularOrderItemsByOrderId.containsKey(objOrder.Id)) {
                	B2B_ShopMeOrder__c objRegularShopMeOrder = new B2B_ShopMeOrder__c();
                	objRegularShopMeOrder.Account__c = objOrder.AccountId;
                	objRegularShopMeOrder.CurrencyIsoCode = objOrder.CurrencyIsoCode;
                	//objRegularShopMeOrder.OrderSummary__c = map_OrderSummaryIdByOrderId.get(objOrder.Id).Id;	
                    objRegularShopMeOrder.OrderType__c = 'Regular';
                	map_ShopMeRegularOrderByOrderId.put(objOrder.Id, objRegularShopMeOrder);
                }
                
                if(map_PickMeOrderItemsByOrderId.containsKey(objOrder.Id)) {
                	B2B_ShopMeOrder__c objPickMeShopMeOrder = new B2B_ShopMeOrder__c();
                	objPickMeShopMeOrder.Account__c = objOrder.AccountId;
                	objPickMeShopMeOrder.CurrencyIsoCode = objOrder.CurrencyIsoCode;
                	//objPickMeShopMeOrder.OrderSummary__c = map_OrderSummaryIdByOrderId.get(objOrder.Id).Id;
                    objPickMeShopMeOrder.OrderType__c = 'Pick Me';
                    map_ShopMePickMeOrderByOrderId.put(objOrder.Id, objPickMeShopMeOrder);
                }
            }
            System.debug('map_ShopMeRegularOrderByOrderId :: ' + map_ShopMeRegularOrderByOrderId);
            insert map_ShopMeRegularOrderByOrderId.values();
            System.debug('map_ShopMePickMeOrderByOrderId :: ' + map_ShopMePickMeOrderByOrderId);
            insert map_ShopMePickMeOrderByOrderId.values();
            
            for (Order objOrder : map_OrderById.values()) {
                if(map_RegularOrderItemsByOrderId.containsKey(objOrder.Id)) {
                    for (OrderItem objOrderItem : map_RegularOrderItemsByOrderId.get(objOrder.Id)) {
                        if (map_OrderItemSummaryByOrderItemId.containsKey(objOrderItem.Id)) {
                        	map_OrderItemSummaryByOrderItemId.get(objOrderItem.Id).ShopMeOrder__c = map_ShopMeRegularOrderByOrderId.get(objOrder.Id).Id;
                        }
                    }
                }
                
              	if(map_PickMeOrderItemsByOrderId.containsKey(objOrder.Id)) {
                    for (OrderItem objOrderItem : map_PickMeOrderItemsByOrderId.get(objOrder.Id)) {
                        if (map_OrderItemSummaryByOrderItemId.containsKey(objOrderItem.Id)) {
                        	map_OrderItemSummaryByOrderItemId.get(objOrderItem.Id).ShopMeOrder__c = map_ShopMePickMeOrderByOrderId.get(objOrder.Id).Id;
                        }
                    }
                }
            }
            
            //update map_OrderItemSummaryByOrderItemId.values();  
		}
    }
}