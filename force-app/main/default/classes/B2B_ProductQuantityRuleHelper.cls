/***********************************************************************************************************
* 
* @ Name            :   B2B_ProductQuantityRuleHelper
* @ Purpose         :   To handle product quantity rules creation based on product quantity availability
* @ Methods         :   
* @ Test Class Name :   B2B_ProductQuantityRuleHelperTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* =========================================================================================================
*   28-11-2022      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
***********************************************************************************************************/
public class B2B_ProductQuantityRuleHelper {
    
    public static void generateQuantityRules(Map<Id, Product2> map_ProductById, Map<Id, Product2> map_OldProductById) {
        Set<String> set_ProductIds = new Set<String>();
        Set<Decimal> set_ProductMOQs = new Set<Decimal>();
        List<Product2> list_Products = new List<Product2>();
        
        for (Product2 objProduct : map_ProductById.values()) {
            Product2 objOldProduct = map_OldProductById.get(objProduct.Id);
            if ((objProduct.B2B_QuantityOrdered__c != objOldProduct.B2B_QuantityOrdered__c ||
                 objProduct.B2B_QuantityAvailable__c != objOldProduct.B2B_QuantityAvailable__c) &&
                objProduct.B2B_MOQ__c != null) {
                    list_Products.add(objProduct);
                    set_ProductIds.add(objProduct.Id);
                    set_ProductMOQs.add(objProduct.B2B_MOQ__c);
                }
        }
        
        if (list_Products.isEmpty()) {
            return;
        }
        
        List<ProductQuantityRule> list_ProductQuantityRules = new List<ProductQuantityRule>();
        List<ProductQuantityRule> list_DeleteProductQuantityRules = new List<ProductQuantityRule>();
        List<PurchaseQuantityRule> list_PurchaseQuantityRules = new List<PurchaseQuantityRule>();
        Map<String, ProductQuantityRule> map_ProductQuantityRuleByProductId = new Map<String, ProductQuantityRule>();
        Map<Decimal, String> map_PurchaseQuantityRuleIdByMinimumQuantity = new Map<Decimal, String>();
        Map<String, Decimal> map_MinimumQuantityByProductId = new Map<String, Decimal>();
        
        List<ProductQuantityRule> list_ExistingProductQuantityRules = [SELECT 
                                                                       Id, 
                                                                       ProductId 
                                                                       FROM ProductQuantityRule 
                                                                       WHERE ProductId IN :set_ProductIds];
        if (!list_ExistingProductQuantityRules.isEmpty()) {
            for (ProductQuantityRule objProductQuantityRule : list_ExistingProductQuantityRules) {
                map_ProductQuantityRuleByProductId.put(objProductQuantityRule.ProductId, objProductQuantityRule);
            }
        }
        
        List<PurchaseQuantityRule> list_ExistingPurchaseQuantityRules = [SELECT 
                                                                         Id, 
                                                                         Minimum 
                                                                         FROM PurchaseQuantityRule 
                                                                         WHERE Minimum IN :set_ProductMOQs];
        if (!list_ExistingPurchaseQuantityRules.isEmpty()) {
            for (PurchaseQuantityRule objPurchaseQuantityRule : list_ExistingPurchaseQuantityRules) {
                map_PurchaseQuantityRuleIdByMinimumQuantity.put(Double.valueof(objPurchaseQuantityRule.Minimum), objPurchaseQuantityRule.Id);
            }
        }
        
        for (Product2 objProduct : list_Products) {
            if (objProduct.B2B_QuantityRemaining__c == 0 && 
                !map_ProductQuantityRuleByProductId.containsKey(objProduct.Id)
               ) {
                   Double objProductMOQ = Double.valueOf(objProduct.B2B_MOQ__c);
                   if (map_PurchaseQuantityRuleIdByMinimumQuantity.containsKey(objProductMOQ)) {
                       ProductQuantityRule objProductQuantityRule = new ProductQuantityRule();
                       objProductQuantityRule.ProductId = objProduct.Id;
                       objProductQuantityRule.PurchaseQuantityRuleId = 
                           map_PurchaseQuantityRuleIdByMinimumQuantity.get(objProductMOQ);
                       
                       list_ProductQuantityRules.add(objProductQuantityRule);
                   } else {
                       map_MinimumQuantityByProductId.put(objProduct.Id, objProduct.B2B_MOQ__c);
                   }
               } else if (objProduct.B2B_QuantityRemaining__c != 0 && 
                          map_ProductQuantityRuleByProductId.containsKey(objProduct.Id)
                         ) {
                             list_DeleteProductQuantityRules.add(map_ProductQuantityRuleByProductId.get(objProduct.Id));
                         }
        }
        
        if (!map_MinimumQuantityByProductId.isEmpty()) {
            Set<Decimal> set_MOQs = new Set<Decimal>();
            set_MOQs.addAll(map_MinimumQuantityByProductId.values());
            
            for (Decimal decMOQ : set_MOQs) {
                PurchaseQuantityRule objPurchaseQuantityRule = new PurchaseQuantityRule();
                objPurchaseQuantityRule.Minimum = decMOQ;
                objPurchaseQuantityRule.Increment = 1;
                objPurchaseQuantityRule.Name = 'Min ' + decMOQ + ' - Increment ' + 1;
                list_PurchaseQuantityRules.add(objPurchaseQuantityRule);
            }
            
            if (!list_PurchaseQuantityRules.isEmpty()) {
                insert list_PurchaseQuantityRules;
            }
            
            List<PurchaseQuantityRule> list_NewPurchaseQuantityRules = [SELECT 
                                                                        Id, 
                                                                        Minimum 
                                                                        FROM PurchaseQuantityRule 
                                                                        WHERE Minimum IN :set_MOQs];
            if (!list_NewPurchaseQuantityRules.isEmpty()) {
                for (PurchaseQuantityRule objPurchaseQuantityRule : list_NewPurchaseQuantityRules) {
                    map_PurchaseQuantityRuleIdByMinimumQuantity.put(Double.valueof(objPurchaseQuantityRule.Minimum), objPurchaseQuantityRule.Id);
                }
            }
            
            for (String strProductId : map_MinimumQuantityByProductId.keySet()) {
                Product2 objProduct = map_ProductById.get(strProductId);
                Double objProductMOQ1 = Double.valueOf(objProduct.B2B_MOQ__c);
                
                if (map_PurchaseQuantityRuleIdByMinimumQuantity.containsKey(objProductMOQ1)) {
                    ProductQuantityRule objProductQuantityRule = new ProductQuantityRule();
                    objProductQuantityRule.ProductId = strProductId;
                    objProductQuantityRule.PurchaseQuantityRuleId = 
                        map_PurchaseQuantityRuleIdByMinimumQuantity.get(objProductMOQ1);
                    
                    list_ProductQuantityRules.add(objProductQuantityRule);
                }
            }
        }
        
        if (!list_ProductQuantityRules.isEmpty()) {
            insert list_ProductQuantityRules;
        }
        
        if (!list_DeleteProductQuantityRules.isEmpty()) {
            delete list_DeleteProductQuantityRules;
        }
    }
}