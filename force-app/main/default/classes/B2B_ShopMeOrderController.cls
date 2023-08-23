/*******************************************************************************************************
* 
* @ Name            :   B2B_ShopMeOrderController
* @ Purpose         :   For creation of ShopMe Orders
* @ Author          :   Prathiksha Suvarna
* @ Test Class Name :   B2B_ShopMeOrderControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   06-01-2023      |  prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
public class B2B_ShopMeOrderController {

    @AuraEnabled(cacheable=false)
    public static OrderSummary createShopMeOrders(String idOrderSummaryId) {
              
            List<B2B_ShopMeOrder__c> list_ShopMeOrders = new List<B2B_ShopMeOrder__c>();
            List<OrderItemSummary> List_RegularOrderItemSummaries = new List<OrderItemSummary>();
            List<OrderItemSummary> List_PickMeOrderItemSummaries = new List<OrderItemSummary>();
            Decimal decRegulaOrderTotal = 0;
            Decimal decPickMeOrderTotal = 0;
            Decimal decRegularOrderTax = 0;
            Decimal decPickMeOrderTax = 0;

            OrderSummary ObjOrderSummary = [SELECT 
                                            OrderNumber,
                                            (
                                                 SELECT
                                                 Id,
                                                 Name,
                                                 OrderType__c
                                                 FROM ShopMe_Orders__r
                                            )
                                            FROM OrderSummary 
                                            WHERE Id =: idOrderSummaryId];

            for (OrderItemSummary ObjOrderItemSummary : [SELECT
                                                         Id,
                                                         OrderSummaryId,
                                                         OrderSummary.AccountId,
                                                         OrderSummary.CurrencyIsoCode,
                                                         OriginalOrderItemId,
                                                         Product2Id,
                                                         TotalAmtWithTax,
                                                         TotalTaxAmount,
                                                         ShopMeOrder__c,
                                                         Type,
                                                         Product2.B2B_QuantityRemaining__c,
                                                         QuantityOrdered,
                                                         Status
                                                         FROM OrderItemSummary
                                                         WHERE OrderSummaryId =: idOrderSummaryId]
            ) {
                    if (ObjOrderItemSummary.Type != 'Delivery Charge') {
                        if((ObjOrderItemSummary.ShopMeOrder__c == null )) {
                            if (ObjOrderItemSummary.QuantityOrdered > ObjOrderItemSummary.Product2.B2B_QuantityRemaining__c) {
                                decRegulaOrderTotal += ObjOrderItemSummary.TotalAmtWithTax;
                                decRegularOrderTax += ObjOrderItemSummary.TotalTaxAmount;
                                List_RegularOrderItemSummaries.add(ObjOrderItemSummary);
                            } else {
                                decPickMeOrderTotal += ObjOrderItemSummary.TotalAmtWithTax;
                                decPickMeOrderTax += ObjOrderItemSummary.TotalTaxAmount;
                                List_PickMeOrderItemSummaries.add(ObjOrderItemSummary);
                            }
                    }
                }
              }  
            
                if (!List_RegularOrderItemSummaries.isEmpty()) {
                	B2B_ShopMeOrder__c objRegularShopMeOrder = new B2B_ShopMeOrder__c();
                	objRegularShopMeOrder.Account__c = List_RegularOrderItemSummaries[0].OrderSummary.AccountId;
                	objRegularShopMeOrder.CurrencyIsoCode = List_RegularOrderItemSummaries[0].OrderSummary.CurrencyIsoCode;
                    objRegularShopMeOrder.OrderType__c = 'Regular';
                    objRegularShopMeOrder.Status__c = 'Created';
                    objRegularShopMeOrder.Total__c = decRegulaOrderTotal;
                    objRegularShopMeOrder.Tax__c = decRegularOrderTax;
                    objRegularShopMeOrder.OrderSummary__c = idOrderSummaryId;    
                	list_ShopMeOrders.add(objRegularShopMeOrder);
                }
                
                if(!List_PickMeOrderItemSummaries.isEmpty()) {
                	B2B_ShopMeOrder__c objPickMeShopMeOrder = new B2B_ShopMeOrder__c();
                	objPickMeShopMeOrder.Account__c = List_PickMeOrderItemSummaries[0].OrderSummary.AccountId;
                	objPickMeShopMeOrder.CurrencyIsoCode = List_PickMeOrderItemSummaries[0].OrderSummary.CurrencyIsoCode;
                    objPickMeShopMeOrder.OrderType__c = 'Pick Me';
                    objPickMeShopMeOrder.Status__c = 'Created';
                    objPickMeShopMeOrder.Total__c = decPickMeOrderTotal;
                    objPickMeShopMeOrder.Tax__c = decPickMeOrderTax;
                    objPickMeShopMeOrder.OrderSummary__c = idOrderSummaryId;
                    list_ShopMeOrders.add(objPickMeShopMeOrder);
                }      

            if (!list_ShopMeOrders.isEmpty()) {
                insert list_ShopMeOrders;

                for (B2B_ShopMeOrder__c objShopMeOrder : list_ShopMeOrders) {
                    if(objShopMeOrder.OrderType__c == 'Regular') {
                        for (OrderItemSummary objOrderItemSummary : List_RegularOrderItemSummaries) {
                            objOrderItemSummary.ShopMeOrder__c = objShopMeOrder.Id;
                        }
                    }
                    
                    if(objShopMeOrder.OrderType__c == 'Pick Me') {
                        for (OrderItemSummary objOrderItemSummary : List_PickMeOrderItemSummaries) {
                            objOrderItemSummary.ShopMeOrder__c = objShopMeOrder.Id;
                        }
                    }
                }

                List_RegularOrderItemSummaries.addAll(List_PickMeOrderItemSummaries);
                update List_RegularOrderItemSummaries;
            }
            return ObjOrderSummary;           
		}
    }