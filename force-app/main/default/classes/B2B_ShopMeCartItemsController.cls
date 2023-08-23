/*******************************************************************************************************
* 
* @ Name            :   B2B_ShopMeCartItemsController
* @ Purpose         :   For displaying Cart Items
* @ Author          :   Prathiksha Suvarna
* @ Test Class Name :   B2B_ShopMeCartItemsControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   21-03-2023      |  prathiksha.suvarna@absyz.com |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class B2B_ShopMeCartItemsController {
    
     /**
    * @ Name     :  ResponseWrapper
    * @ Purpose  :  Wrapper class to send response to the lwc.
    * @ Author   :  Prathiksha Suvarna
    **/   
    public class ResponseWrapper {
        @AuraEnabled public String strErrorMessage; 
        @AuraEnabled public Boolean blnIsSuccess;
        
        //List of CartItem objects
        @AuraEnabled public List<CartItem> list_AllCartItems = new List<CartItem>();
        
        //This is used to store Managed Content Version Collection
        @AuraEnabled public ConnectApi.ManagedContentVersionCollection contentVersionCollection;
        
        //Map of ImageURL by ManageContentId
        @AuraEnabled public Map<String, String> map_ImageURLByManageContentId;
        
        //Map of ElectronicMediaId By CartItemId
        @AuraEnabled public Map<Id, Id> map_ElectronicMediaIdByCartItemId;
    }
    
    /**
    * @ author       :  Prathiksha Suvarna
    * @ description  :  This method queries and returns the ResponseWrapper Object which mainly consists of
    *                   all the Available CartItems for Cart Record.
    * @ params       :  'recordId' - Cart object recordId.
    * @ return       :  'ResponseWrapper' - Wrapper Class
    **/
    @AuraEnabled
    public static ResponseWrapper getCartItems(Id recordId) {
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        
        //This is used to retrive org wide default record for custom setting of B2B_ShopMeConfigurations__c
        B2B_ShopMeConfigurations__c objShopMeConfiguration = B2B_ShopMeConfigurations__c.getOrgDefaults();
        
        try {
            List<CartItem> list_CartItems = [SELECT
                                             Id,
                                             Name,
                                             SalesPrice,
                                             Quantity,
                                             TotalAmount,
                                             TotalPriceTaxAmount,
                                             product2Id,
                                             Product2.B2B_PlantName__c,
                                             Product2.B2B_ProductType__c,
                                             Product2.Name 
                                             FROM CartItem
                                             WHERE CartId = :recordId
                                             AND Product2.Name != :objShopMeConfiguration.ProductName__c];
            
            objResponseWrapper.blnIsSuccess = true;
            objResponseWrapper.list_AllCartItems = list_CartItems;
            
            //Map of ElectronicMediaId By CartItemId
            Map<Id, Id> map_ElectronicMediaIdByCartItemId = new Map<Id, Id>();
            
            List<Id> list_ProductIds = new List<Id>();
            for (CartItem objCartItem : list_CartItems) {
                list_ProductIds.add(objCartItem.Product2Id);
            }
            
            List<Network> list_Networks = [SELECT 
                                           Id, 
                                           Name 
                                           FROM Network
                                           WHERE Name = :objShopMeConfiguration.NetworkName__c];
            
            String strNetworkId;
            if (!list_Networks.isEmpty()) {
            	strNetworkId = list_Networks[0].Id.to15();
            }
            
            List<ProductMedia> list_ProductMedias = [SELECT
                                                    ElectronicMediaId, 
                                                    ProductId
                                                    FROM ProductMedia
                                                    WHERE ProductId = :list_ProductIds];
            
            //Map of ElectronicId By ProductId
            Map<Id, Id> map_ElectronicIdByProductId = new Map<Id, Id>();           
            List<String> list_ContentIds = new List<String>();
            
            for (ProductMedia objProductMedia : list_ProductMedias) {
                list_ContentIds.add(objProductMedia.ElectronicMediaId);
                map_ElectronicIdByProductId.put(objProductMedia.ProductId, objProductMedia.ElectronicMediaId);
            }
            
            for (CartItem objCartItem : list_CartItems) {
                map_ElectronicMediaIdByCartItemId.put(
                    objCartItem.Id,
                    map_ElectronicIdByProductId.get(objCartItem.Product2Id)
                );
            }
            objResponseWrapper.map_ElectronicMediaIdByCartItemId = map_ElectronicMediaIdByCartItemId;
            
            //This method is invoked to retrive Managed Content Version Collection
            ConnectApi.ManagedContentVersionCollection contentList = ConnectApi.ManagedContent.getManagedContentByIds(
                strNetworkId, 
                list_ContentIds, 
                0, 
                100, 
                'en_US', 
                'cms_image'
            );
            objResponseWrapper.contentVersionCollection = contentList;
            
            //List of Managed Content Media Source Node Value
            List<ConnectApi.ManagedContentMediaSourceNodeValue> mediaSourceNodes = new List<ConnectApi.ManagedContentMediaSourceNodeValue>();
            //Map of MediaId by Image Url
            Map<String, String> mappingOfMediaIdAndUrl = new Map<String, String>();
            
            for (ConnectApi.ManagedContentVersion versionItems : contentList.items) {
                mediaSourceNodes.add((ConnectApi.ManagedContentMediaSourceNodeValue) versionItems.contentNodes.get('source'));
                for (ConnectApi.ManagedContentMediaSourceNodeValue nodeValue : mediaSourceNodes) {
                    // Assign values to a map of Managed Content Id by Image Url 
                    mappingOfMediaIdAndUrl.put(versionItems.managedcontentid, System.Url.getOrgDomainUrl().toExternalForm() + nodeValue.url);
                }
            }
            
            objResponseWrapper.map_ImageURLByManageContentId = mappingOfMediaIdAndUrl;
        } catch (Exception objException) {
            objResponseWrapper.blnIsSuccess = false;
            objResponseWrapper.strErrorMessage = objException.getMessage();
        }
        return objResponseWrapper;
    }
}