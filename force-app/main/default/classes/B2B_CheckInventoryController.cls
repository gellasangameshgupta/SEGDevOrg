/*******************************************************************************************************
* 
* @ Name            :   B2B_CheckInventoryController
* @ Purpose         :   Controller for flow B2B_Checkout
* @ Methods         :   1) startCartProcessAsync
*                       2) integrationStatusFailedWithCartValidationOutputError
* @ Author          :   Aseem Doddamani
* @ Usage           :   This must implement the sfdc_checkout.CartInventoryValidation interface
*                       in order to be processed by the checkout flow and used for your Check Inventory integration.
* @ Test Class Name :   B2B_CheckInventoryControllerTest
*
*   Date            |  Developer Name                 |  Version      |  Changes
* ======================================================================================================
*   18-05-2021      |  aseem.doddamani@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/
global class B2B_CheckInventoryController implements sfdc_checkout.CartInventoryValidation {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        
        try {
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> map_QuantitiesFromSalesforce = new Map<String, Decimal>();
            
            for (CartItem objCartItem : [SELECT 
                                         Sku, 
                                         Quantity 
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
                    
                    map_QuantitiesFromSalesforce.put(objCartItem.Sku, objCartItem.Quantity);
                }
            
            // Stop checkout if there are no items in the cart
            if (map_QuantitiesFromSalesforce.isEmpty()) {
                String strErrorMessage = 'Looks like your cart is empty.';
                
                return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    strErrorMessage,
                    jobInfo,
                    cartId
                );
            }
            
            // We do not have any external system, all the checks are from Salesforce
            // So set the integration status to "Success" by default.
            for (String strSku : map_QuantitiesFromSalesforce.keySet()) {
                // If the product exists and the available quantity is enough, set status as SUCCESS
                integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
            }
            
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            
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
        // To propagate the error to the user, we need to add a new CartValidationOutput record.
        // The following fields must be populated:
        // BackgroundOperationId: Foreign Key to the BackgroundOperation
        // CartId: Foreign key to the WebCart that this validation line is for
        // Level (required): One of the following - Info, Error, or Warning
        // Message (optional): Message displyed to the user
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
            Type = 'Inventory'
        );
        insert(objCartValidationError);
        
        return integrationStatus;
    }
}