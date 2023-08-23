/*******************************************************************************************************
* 
* @ Name            :   B2B_DeliveryController
* @ Purpose         :   Controller for flow B2B_Checkout
* @ Methods         :   1) startCartProcessAsync
*                       	params - sfdc_checkout.IntegrationInfo, Id
*                       2) getShippingOptionsAndRatesFromExternalService
*                       	params - String, String
*                       3) populateCartDeliveryGroupMethodWithShippingOptions
*                       	params - ShippingOptionsAndRatesFromExternalService, Id, Id, Id
*                       4) integrationStatusFailedWithCartValidationOutputError
*                       	params - sfdc_checkout.IntegrationStatus, String, sfdc_checkout.IntegrationInfo, Id
*                       5) getOrderDeliveryMethods
*                       	params - List<ShippingOptionsAndRatesFromExternalService>
* @ Author          :   Aseem Doddamani
* @ Usage           :   This must implement the sfdc_checkout.CartShippingCharges interface
*                       in order to be processed by the checkout flow for the "Shipping" integration
* @ Test Class Name :   B2B_DeliveryControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   20-06-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
global class B2B_DeliveryController implements sfdc_checkout.CartShippingCharges {
    
    global Boolean blnTriggerException = false;
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        
        try {
            // We need to get the ID of the cart delivery group in order to create the order delivery groups.
            List<CartItem> list_CartItems = [SELECT 
                                             CartDeliveryGroupId 
                                             FROM CartItem 
                                             WHERE CartId = :cartId];
            
            if (!list_CartItems.isEmpty()) {
                Id cartDeliveryGroupId = list_CartItems[0].CartDeliveryGroupId;
                
                // Get cart delivery group details
                List<CartDeliveryGroup> list_CartDeliveryGroups = [SELECT 
                                                                   DeliverToState, 
                                                                   DeliverToCountry 
                                                                   FROM CartDeliveryGroup 
                                                                   WHERE Id = :cartDeliveryGroupId];
                
                if (!list_CartDeliveryGroups.isEmpty()) {
                    CartDeliveryGroup objDeliveryGroup = list_CartDeliveryGroups[0];
                    
                    // Get the shipping options from custom metadata.
                    // We're getting information Country, Warehouse, Per KG Price. 
                    ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService = 
                        getShippingOptionsAndRatesFromExternalService(objDeliveryGroup.DeliverToCountry, cartId);
                    
                    // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
                    delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];
                    
                    // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
                    List<Id> list_OrderDeliveryMethodIds = getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);
                    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
                    Integer intI = 0;
                    for (Id orderDeliveryMethodId : list_OrderDeliveryMethodIds) {
                        populateCartDeliveryGroupMethodWithShippingOptions(
                            shippingOptionsAndRatesFromExternalService[intI],
                            cartDeliveryGroupId,
                            orderDeliveryMethodId,
                            cartId
                        );
                        
                        intI += 1;
                    }
                    
                    // If everything works well, the charge is added to the cart and our integration has been successfully completed.
                    integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                }
            }
            
            if (blnTriggerException) {
                return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    'An exception has occurred',
                    jobInfo,
                    cartId
                );
            }
        } catch (DmlException de) {
            // Catch any exceptions thrown when trying to insert the shipping charge to the CartItems
            Integer intNumErrors = de.getNumDml();
            String strErrorMessage = 'There were ' + intNumErrors + ' errors when trying to insert the charge in the CartItem: ';
            for (Integer intErrorIdx = 0; intErrorIdx < intNumErrors; intErrorIdx++) {
                strErrorMessage += 'Field Names = ' + de.getDmlFieldNames(intErrorIdx);
                strErrorMessage += 'Message = ' + de.getDmlMessage(intErrorIdx);
                strErrorMessage += ' , ';
            }
            
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                strErrorMessage,
                jobInfo,
                cartId
            );
            
        } catch(Exception e) {
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        
        return integStatus;
    }
    
    private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService(
        String strDeliverToCountry, 
        String strCartId
    ) {
        ShippingOptionsAndRatesFromExternalService[] list_ShippingOptions = 
            new List<ShippingOptionsAndRatesFromExternalService>();
        Map<String, Decimal> map_TotalPriceByCountry = new Map<String, Decimal>();
        
        if (String.isEmpty(strDeliverToCountry)) {
            strDeliverToCountry = 'Germany';
        }
        
        for (CartItem objCartItem : [SELECT
                                     Sku,
                                     TotalPrice,
                                     Type,
                                     Quantity,
                                     Product2.B2B_Plant__r.Warehouse__c
                                     FROM CartItem
                                     WHERE CartId = :strCartId]
            ) {
                if (objCartItem.Product2.B2B_Plant__r.Warehouse__c != null) {
                    if (!map_TotalPriceByCountry.containsKey(objCartItem.Product2.B2B_Plant__r.Warehouse__c)) {
                        map_TotalPriceByCountry.put(objCartItem.Product2.B2B_Plant__r.Warehouse__c, 0);
                    }
                    
                    Decimal decTotalPriceByCountry = map_TotalPriceByCountry.get(objCartItem.Product2.B2B_Plant__r.Warehouse__c);
                    decTotalPriceByCountry += (objCartItem.TotalPrice);
                    
                    map_TotalPriceByCountry.put(objCartItem.Product2.B2B_Plant__r.Warehouse__c, decTotalPriceByCountry);
                }
            }
        
        Map<String, Decimal> map_DeliveryPriceByWarehouseLocation = new Map<String, Decimal>();
        List<B2B_DeliveryEstimate__mdt> list_DeliveryEstimates = [SELECT 
                                                                  Id,
                                                                  Currency__c,
                                                                  Country__c,
                                                                  WarehouseLocation__c,
                                                                  DeliveryCost__c
                                                                  FROM B2B_DeliveryEstimate__mdt
                                                                  WHERE Active__c = true
                                                                  AND Country__c = :strDeliverToCountry
                                                                  AND WarehouseLocation__c IN :map_TotalPriceByCountry.keySet()];
        
        if (!list_DeliveryEstimates.isEmpty() || Test.isRunningTest()) {
            for (B2B_DeliveryEstimate__mdt objDeliveryEstimate : list_DeliveryEstimates) {
                map_DeliveryPriceByWarehouseLocation.put(
                    objDeliveryEstimate.WarehouseLocation__c,
                    objDeliveryEstimate.DeliveryCost__c
                );
            }
            
            Decimal decShipmentPricing = 0;
            
            for (String strKey : map_TotalPriceByCountry.keySet()) {
                Decimal decPriceByCountry = 0;
                
                if (map_DeliveryPriceByWarehouseLocation.containsKey(strKey)) {
                    // calculate the delivery charge
                    decPriceByCountry = (map_TotalPriceByCountry.get(strKey) / 100) * map_DeliveryPriceByWarehouseLocation.get(strKey);
                    decShipmentPricing += decPriceByCountry;
                }
            }
            
            list_ShippingOptions.add(new ShippingOptionsAndRatesFromExternalService(
                strDeliverToCountry,
                '',
                decShipmentPricing,
                decShipmentPricing,
                strDeliverToCountry
            ));
        } else {
            // TO-DO : logic for other EU Countries
            list_ShippingOptions.add(new ShippingOptionsAndRatesFromExternalService(
                strDeliverToCountry,
                '',
                0.00,
                0.00,
                strDeliverToCountry
            ));
        }
        
        return list_ShippingOptions;
    }
    
    // Structure to store the shipping options retrieved from custom metadata.
    Class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;
        
        public ShippingOptionsAndRatesFromExternalService() {
            name = '';
            provider = '';
            rate = 0.0;
            serviceName = '';
            otherCost = 0.0;
        }
        
        public ShippingOptionsAndRatesFromExternalService(
            String someName, 
            String someProvider, 
            Decimal someRate, 
            Decimal someOtherCost, 
            String someServiceName
        ) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
        }
        
        public String getProvider() {
            return provider;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getOtherCost() {
            return otherCost;
        }
        
        public String getServiceName() {
            return serviceName;
        }
        
        public String getName() {
            return name;
        }
    }
    
    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private void populateCartDeliveryGroupMethodWithShippingOptions(
        ShippingOptionsAndRatesFromExternalService shippingOption,
        Id cartDeliveryGroupId,
        Id deliveryMethodId,
        Id webCartId
    ) {
        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
        // CartDeliveryGroupId: Id of the delivery group of this shipping option
        // DeliveryMethodId: Id of the delivery method for this shipping option
        // ExternalProvider: Unique identifier of shipping provider
        // Name: Name of the CartDeliveryGroupMethod record
        // ShippingFee: The cost of shipping for the delivery group
        // WebCartId: Id if the cart that the delivery group belongs to
        CartDeliveryGroupMethod objCartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOption.getProvider(),
            Name = shippingOption.getName(),
            ShippingFee = shippingOption.getRate(),
            WebCartId = webCartId
        );
        
        insert(objCartDeliveryGroupMethod);
    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, 
        String strErrorMessage, 
        sfdc_checkout.IntegrationInfo jobInfo, 
        Id cartId
    ) {
        integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        // In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
        // The following fields must be populated:
        // BackgroundOperationId: Foreign Key to the BackgroundOperation
        // CartId: Foreign key to the WebCart that this validation line is for
        // Level (required): One of the following - Info, Error, or Warning
        // Message (optional): Message displayed to the user
        // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
        // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
        // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
        CartValidationOutput objCartValidationError = new CartValidationOutput(
            BackgroundOperationId = jobInfo?.jobId,
            CartId = cartId,
            Level = 'Error',
            Message = strErrorMessage.left(255),
            Name = (String)cartId + ':' + jobInfo?.jobId,
            RelatedEntityId = cartId,
            Type = 'Shipping'
        );
        
        insert(objCartValidationError);
        return integrationStatus;
    }
    
    private List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> list_ShippingOptions) {
        String strDefaultDeliveryMethodName = 'SEG Delivery Services';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();
        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> list_OrderDeliveryMethodIds = new List<Id>();
        Integer intI = 1;
        for (ShippingOptionsAndRatesFromExternalService objShippingOption : list_ShippingOptions) {
            String strShippingOptionNumber = String.valueOf(intI);
            String strName = strDefaultDeliveryMethodName + ' - ' + strShippingOptionNumber;
            List<OrderDeliveryMethod> list_OrderDeliveryMethods = [SELECT 
                                                                   Id, 
                                                                   ProductId, 
                                                                   Carrier, 
                                                                   ClassOfService 
                                                                   FROM OrderDeliveryMethod 
                                                                   WHERE Name = :strName];
            
            // This is the case in which an Order Delivery method does not exist.
            if (list_OrderDeliveryMethods.isEmpty()) {
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = strName,
                    Carrier = objShippingOption.serviceName,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = objShippingOption.provider
                );
                
                insert(defaultOrderDeliveryMethod);
                list_OrderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
                
            } else {
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod objExistingOrderDeliveryMethod = list_OrderDeliveryMethods[0];
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (objExistingOrderDeliveryMethod.ProductId == null || 
                    objExistingOrderDeliveryMethod.Carrier == null || 
                    objExistingOrderDeliveryMethod.ClassOfService == null) {
                        
                        objExistingOrderDeliveryMethod.ProductId = product2IdForThisDeliveryMethod;
                        objExistingOrderDeliveryMethod.Carrier = objShippingOption.serviceName;
                        objExistingOrderDeliveryMethod.ClassOfService = objShippingOption.provider;
                        update(objExistingOrderDeliveryMethod);
                    }
                list_OrderDeliveryMethodIds.add(objExistingOrderDeliveryMethod.Id);
            }
            
            intI += 1;
        }
        
        return list_OrderDeliveryMethodIds;
    }
    
    private Id getDefaultShippingChargeProduct2Id() {
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String strShippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> list_ShippingChargeProducts = [SELECT Id 
                                                      FROM Product2 
                                                      WHERE Name = :strShippingChargeProduct2Name];
        if (list_ShippingChargeProducts.isEmpty()) {
            Product2 objShippingChargeProduct = new Product2(
                isActive = true,
                Name = strShippingChargeProduct2Name,
                B2B_SEGIAMProductNumber__c = 'ShippingCharges'
            );
            insert(objShippingChargeProduct);
            
            return objShippingChargeProduct.Id;
        } else {
            return list_ShippingChargeProducts[0].Id;
        }
    }
}