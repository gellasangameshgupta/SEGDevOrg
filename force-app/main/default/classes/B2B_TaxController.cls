/*******************************************************************************************************
* 
* @ Name            :   B2B_TaxController
* @ Purpose         :   Controller for flow B2B_Checkout
* @ Methods         :   1) startCartProcessAsync
*                           params - sfdc_checkout.IntegrationInfo, Id
*                       2) getTaxRatesAndAmountsFromExternalService
*                           params - Map<String, Decimal>, String, String
*                       3) integrationStatusFailedWithCartValidationOutputError
*                           params - sfdc_checkout.IntegrationStatus, String, sfdc_checkout.IntegrationInfo, Id
* @ Author          :   Aseem Doddamani
* @ Usage           :   This must implement the sfdc_checkout.CartTaxCalculations interface
*                       in order to be processed by the checkout flow and used for your Taxes integration.
* @ Test Class Name :   B2B_TaxControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   18-05-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/

global class B2B_TaxController implements sfdc_checkout.CartTaxCalculations {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // We need to get the ID of the delivery group in order to get the DeliverTo info.
            List<CartItem> list_CartItems = [SELECT
                                             CartDeliveryGroupId
                                             FROM CartItem
                                             WHERE CartId = :cartId];
            
            if (!list_CartItems.isEmpty()) {
                Id cartDeliveryGroupId = list_CartItems[0].CartDeliveryGroupId;
                
                //get Cart Delivery Group details
                List<CartDeliveryGroup> list_CartDeliveryGroups = [SELECT
                                                                   DeliverToState,
                                                                   DeliverToCountry
                                                                   FROM CartDeliveryGroup
                                                                   WHERE Id = :cartDeliveryGroupId];
                
                if (!list_CartDeliveryGroups.isEmpty()) {
                    CartDeliveryGroup objDeliveryGroup = list_CartDeliveryGroups[0];
                    
                    // Get all SKUs, the cart item IDs, and the total prices from the cart items.
                    Map<String, Id> map_CartItemIdsBySKU = new Map<String, Id>();
                    Map<String, Decimal> map_CartItemTotalPriceBySKU = new Map<String, Decimal>();
                    
                    for (CartItem objCartItem : [SELECT Sku, TotalPrice, Type FROM CartItem WHERE CartId = :cartId]) {
                        String strCartItemSKU = '';
                        if (objCartItem.Type == 'Product') {
                            if (String.isBlank(objCartItem.Sku)) {
                                String errorMessage = 'The SKUs for all products in your cart must be defined.';
                                return integrationStatusFailedWithCartValidationOutputError(
                                    integStatus,
                                    errorMessage,
                                    jobInfo,
                                    cartId
                                );
                            }
                            
                            strCartItemSKU = objCartItem.Sku;
                        } else if (objCartItem.Type == 'Charge') {
                            // This is an example for a Cart Item of type shipping charge.
                            // For simplicity purposes, we just assign some SKU to this charge so that the taxation returns some value.
                            strCartItemSKU = 'ChargeSKU';
                        }
                        
                        map_CartItemIdsBySKU.put(strCartItemSKU, objCartItem.Id);
                        map_CartItemTotalPriceBySKU.put(strCartItemSKU, objCartItem.TotalPrice);
                    }
                    
                    // Get the tax rates and tax amounts from an external service
                    // Other parameters will be passed here, like ship_from, bill_to, more details about the ship_to, etc.
                    Map<String, TaxDataFromExternalService> map_RateAndAmountFromExternalServicePerSku =
                        getTaxRatesAndAmountsFromExternalService(
                            map_CartItemTotalPriceBySKU,
                            cartId,
                            objDeliveryGroup.DeliverToCountry
                        );
                    // If there are taxes from a previously cancelled checkout, delete them.
                    List<Id> list_CartItemIds = map_CartItemIdsBySKU.values();
                    delete [SELECT Id FROM CartTax WHERE CartItemId IN :list_CartItemIds];
                    
                    // For each cart item, insert a new tax line in the CartTax entity.
                    // The total tax is automatically rolled up to TotalLineTaxAmount in the corresponding CartItem line.
                    CartTax[] list_cartTaxestoInsert = new CartTax[]{};
                        for (String strSKU : map_RateAndAmountFromExternalServicePerSku.keySet()) {
                            
                            if (map_CartItemIdsBySKU.containsKey(strSKU)) {
                                TaxDataFromExternalService rateAndAmountFromExternalService = map_RateAndAmountFromExternalServicePerSku.get(strSKU);
                                
                                // If the sku was found in the external system, add a new CartTax line for that sku
                                // The following fields from CartTax can be filled in:
                                // Amount (required): Calculated tax amount.
                                // CartItemId (required): ID of the cart item.
                                // Description (optional): Description of CartTax.
                                // Name (required): Name of the tax.
                                // TaxCalculationDate (required): Calculation date for this tax line.
                                // TaxRate (optional): The percentage value of the tax. Null if the tax is a flat amount.
                                // TaxType (required): The type of tax, e.g. Actual or Estimated.
                                CartTax objCartTax = new CartTax(
                                    Amount = rateAndAmountFromExternalService.getAmount(),
                                    CartItemId = map_CartItemIdsBySKU.get(strSKU),
                                    Name = rateAndAmountFromExternalService.getTaxName(),
                                    TaxCalculationDate = Date.today(),
                                    TaxRate = rateAndAmountFromExternalService.getRate(),
                                    TaxType = 'Actual'
                                );
                                list_cartTaxestoInsert.add(objCartTax);
                            } else {
                                return integrationStatusFailedWithCartValidationOutputError(
                                    integStatus,
                                    'The product with sku ' + strSKU + ' could not be found',
                                    jobInfo,
                                    cartId
                                );
                            }
                        }
                    
                    insert(list_cartTaxestoInsert);
                    integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                }
            }
        } catch(Exception e) {
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage() + ' at line ' + e.getLineNumber(),
                jobInfo,
                cartId
            );
        }
        
        return integStatus;
    }
    
    private Map<String, TaxDataFromExternalService> getTaxRatesAndAmountsFromExternalService (
        Map<String, Decimal> map_CartItemTotalAmountBySKU, 
        String strCartId, 
        String strCountry
    ) {
        Map<String, TaxDataFromExternalService> map_TaxDataFromExternalServiceBySKU = 
            new Map<String, TaxDataFromExternalService>();
        Map<String, String> map_TotalPriceByCountry = new Map<String, String>();
        Decimal decDeliveryCost = 0;
        Decimal decDeliveryTaxCost = 0;
        
        if (String.isEmpty(strCountry)) {
            strCountry = 'Germany';
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
                    
                    if (String.isNotEmpty(strCountry) && strCountry == 'Germany') {
                        if (!map_TotalPriceByCountry.containsKey(strCountry)) {
                            map_TotalPriceByCountry.put(strCountry, '0');
                        }
                        
                        String strParameter = map_TotalPriceByCountry.get(strCountry);
                        List<String> list_Parameters = strParameter.split(':');
                        
                        Decimal decTotalPriceByCountry = Decimal.valueOf(list_Parameters[0]);
                        decTotalPriceByCountry += (objCartItem.TotalPrice);
                        
                        map_TotalPriceByCountry.put(
                            strCountry,
                            String.valueOf(decTotalPriceByCountry) + ':' + objCartItem.Sku
                        );
                    } else {
                        if (!map_TotalPriceByCountry.containsKey(objCartItem.Product2.B2B_Plant__r.Warehouse__c)) {
                            map_TotalPriceByCountry.put(objCartItem.Product2.B2B_Plant__r.Warehouse__c, '0');
                        }
                        
                        String strParameter = map_TotalPriceByCountry.get(objCartItem.Product2.B2B_Plant__r.Warehouse__c);
                        List<String> list_Parameters = strParameter.split(':');
                        
                        Decimal decTotalPriceByCountry = Decimal.valueOf(list_Parameters[0]);
                        decTotalPriceByCountry += (objCartItem.TotalPrice);
                        
                        map_TotalPriceByCountry.put(
                            objCartItem.Product2.B2B_Plant__r.Warehouse__c,
                            String.valueOf(decTotalPriceByCountry) + ':' + objCartItem.Sku
                        );
                    }
                }
                
                if (objCartItem.Type == 'Charge') {
                    decDeliveryCost = objCartItem.TotalPrice;
                }
            }
        
        // Get the values for Price, Country and other details from custom metadata
        Map<String, Decimal> map_TaxEstimateByCountry = new Map<String, Decimal>();
        List<B2B_TaxEstimate__mdt> list_TaxEstimates = [SELECT 
                                                        Id,
                                                        Country__c,
                                                        Currency__c,
                                                        Tax__c
                                                        FROM B2B_TaxEstimate__mdt
                                                        WHERE Active__c = true
                                                        AND Country__c IN :map_TotalPriceByCountry.keySet()
                                                       ];
        
        if (!list_TaxEstimates.isEmpty()) {
            
            for (B2B_TaxEstimate__mdt objTaxEstimate : list_TaxEstimates) {
                map_TaxEstimateByCountry.put(
                    objTaxEstimate.Country__c,
                    objTaxEstimate.Tax__c
                );
                
                if (objTaxEstimate.Country__c == strCountry) {
                    decDeliveryTaxCost = decDeliveryCost * (objTaxEstimate.Tax__c / 100);
                    
                    map_TaxDataFromExternalServiceBySKU.put('ChargeSKU', new TaxDataFromExternalService(
                        0.00,
                        decDeliveryTaxCost,
                        strCountry
                    ));
                }
            }
            
            for (String strKey : map_TotalPriceByCountry.keySet()) {
                
                String strKeyValues = map_TotalPriceByCountry.get(strKey);
                List<String> list_StrKeyValues = strKeyValues.split(':');
                Decimal decTaxPrice = 0.00;
                
                if (strKey == strCountry && map_TaxEstimateByCountry.containsKey(strKey)) {
                    decTaxPrice = Decimal.valueOf(list_StrKeyValues[0]) * (map_TaxEstimateByCountry.get(strKey) / 100);
                }
                
                map_TaxDataFromExternalServiceBySKU.put(list_StrKeyValues[1], new TaxDataFromExternalService(
                    0.00,
                    decTaxPrice,
                    strCountry
                ));
            }
            
            if (decDeliveryTaxCost == 0) {
                map_TaxDataFromExternalServiceBySKU.put('ChargeSKU', new TaxDataFromExternalService(
                    0.00,
                    0.00,
                    strCountry
                ));
            }
        } else {
            for (String strSKU : map_CartItemTotalAmountBySKU.keySet()) {
                map_TaxDataFromExternalServiceBySKU.put(strSKU, new TaxDataFromExternalService(
                    0.00,
                    0.00,
                    strCountry
                ));
            }
        }
        
        return map_TaxDataFromExternalServiceBySKU;
    }
    
    // Structure to store the tax data retrieved from external service
    // This simplifies our ability to access it when storing it in Salesforce's CartTax entity
    Class TaxDataFromExternalService {
        private Decimal rate;
        private Decimal amount;
        private String taxName;
        
        public TaxDataFromExternalService () {
            rate = 0.0;
            amount = 0.0;
            taxName = '';
        }
        
        public TaxDataFromExternalService (Decimal someRate, Decimal someAmount, String someTaxName) {
            rate = someRate;
            amount = someAmount;
            taxName = someTaxName;
        }
        
        public Decimal getRate() {
            return rate;
        }
        
        public Decimal getAmount() {
            return amount;
        }
        
        public String getTaxName() {
            return taxName;
        }
    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, 
        String strErrorMessage, 
        sfdc_checkout.IntegrationInfo jobInfo, 
        Id cartId
    ) {
        integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
        // For the error to be propagated to the user, we need to add a new CartValidationOutput record.
        // The following fields must be populated:
        // BackgroundOperationId: Foreign Key to the BackgroundOperation
        // CartId: Foreign key to the WebCart that this validation line is for
        // Level (required): One of the following - Info, Error, or Warning
        // Message (optional): Message displayed to the user (maximum 255 characters)
        // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
        // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
        // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
        CartValidationOutput objCartValidationError = new CartValidationOutput(
            BackgroundOperationId = jobInfo.jobId,
            CartId = cartId,
            Level = 'Error',
            Message = strErrorMessage.left(255),
            Name = (String)cartId + ':' + jobInfo.jobId,
            RelatedEntityId = cartId,
            Type = 'Taxes'
        );
        
        insert(objCartValidationError);
        return integrationStatus;
    }
}