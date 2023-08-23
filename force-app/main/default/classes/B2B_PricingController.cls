/*******************************************************************************************************
* 
* @ Name            :   B2B_PricingController
* @ Purpose         :   Controller for flow B2B_Checkout
* @ Methods         :   1) startCartProcessAsync
*                       2) integrationStatusFailedWithCartValidationOutputError
* @ Author          :   Aseem Doddamani
* @ Usage           :   This must implement the sfdc_checkout.CartPriceCalculations interface
*                       in order to be processed by the checkout flow and used for your Price Calculations integration.
* @ Test Class Name :   B2B_PricingControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   18-05-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
global class B2B_PricingController implements sfdc_checkout.CartPriceCalculations {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        
        try {
            // Get all SKUs and their sale prices (customer-specific prices) from the cart items.
            Map<String, Decimal> map_SalesPricesFromSalesforce = new Map<String, Decimal>();
            
            for (CartItem objCartItem : [SELECT 
                                         Sku, 
                                         SalesPrice 
                                         FROM CartItem 
                                         WHERE CartId = :cartId 
                                         AND Type = 'Product']
                ) {
                    if (String.isBlank(objCartItem.Sku)) {
                        String strErrorMessage = 'The SKUs for all products in your cart must be defined.';
                        
                        return integrationStatusFailedWithCartValidationOutputError(
                            integStatus,
                            strErrorMessage,
                            jobInfo,
                            cartId
                        );
                    }
                    
                    map_SalesPricesFromSalesforce.put(objCartItem.Sku, objCartItem.SalesPrice);
                }
            
            // For each cart item SKU, check that the price from the external service
            // is the same as the sale price in the cart.
            // If that is not true, set the integration status to "Failed".
            for (String strSku : map_SalesPricesFromSalesforce.keySet()) {
                // If the prices in the external system are the same as the prices in Salesforce, set integration status as SUCCESS.
                integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
            }
        } catch(Exception e) {
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        
        return integStatus;
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
        // Level (required): One of the following - Info, Error or Warning
        // Message (optional): Message to be shown to the user
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
            Type = 'Pricing'
        );
        insert(objCartValidationError);
        
        return integrationStatus;
    }
}