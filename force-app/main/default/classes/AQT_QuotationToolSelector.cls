/*******************************************************************************************************
*
* @ Name            :   AQT_QuotationToolSelector
* @ Purpose         :   Selector class for AQT Quote and Quote line items
* @ Author          :   Khushmeet Kaur
* @ Test Class Name :   AQT_QuotationToolSelectorTest
*
*   Date            |  Developer Name            |  Version      |  Changes
* ======================================================================================================
*   24-02-2022      |  Khushmeet.kaur@absyz.com  |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class AQT_QuotationToolSelector {
    public static List<PriceBookEntry> getPricebookEntryRecord(
        Set<String> set_PartNumberWithWildCharacters,
        String strPricebookId
    ) {
        return [
            SELECT
            Id,
            Name,
            Product2Id,
            Pricebook2Id,
            Product2.B2B_Plant__r.Name,
            Product2.Name,
            Product2.B2B_QuantityRemaining__c,
            Product2.B2B_SEGIAMProductNumber__c,
            Product2.B2B_PreviousSEGIAMProductNumber__c,
            Product2.B2B_OEMItemNumber__c,
            Product2.B2B_ProductType__c,
            Product2.B2B_LeadTimeWeeks__c,
            Product2.B2B_MOQ__c,
            UnitPrice
            FROM PricebookEntry
            WHERE
            PriceBook2Id = :strPricebookId
            AND IsActive = TRUE
            AND (Product2.B2B_SEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_PreviousSEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_OEMItemNumber__c LIKE :set_PartNumberWithWildCharacters)
        ];
    }
    
    public static List<BuyerGroupMember> getBuyerGroupMember(
        String strAccountId
    ) {
        return [
            SELECT Id, BuyerGroupId, BuyerId, BuyerGroup.Name
            FROM BuyerGroupMember
            WHERE BuyerId = :strAccountId
        ];
    }
    
    //Optimise
    public static List<BuyerGroupMember> getBuyerGroupMemberRecord(
        Set<String> set_accountId
    ) {
        return [
            SELECT Id, BuyerGroupId, BuyerId, BuyerGroup.Name
            FROM BuyerGroupMember
            WHERE BuyerId = :set_accountId
        ];
    }
    
    public static List<BuyerGroupPricebook> getBuyerGroupPricebook(
        String strBuyerGroupId
    ) {
        return [
            SELECT Id, Name, Pricebook2Id, BuyerGroupId
            FROM BuyerGroupPricebook
            WHERE BuyerGroupId = :strBuyerGroupId AND IsActive = TRUE
            ORDER BY Priority ASC
            LIMIT 1
        ];
    }
    
    public static List<Account> getAccountDetails(String strAccountId) {
        return [
            SELECT
            Id,
            Name,
            Contact_Persons__c,
            BillingStreet,
            AQT_Validity__c,
            AQT_PaymentTerm__c,
            AQT_Intercom2010__c,
            BillingCity,
            BillingState,
            BillingPostalCode,
            BillingCountry
            FROM Account
            WHERE Id = :strAccountId
        ];
    }
    
    public static List<Contact> getContactDetails(String strContactId) {
        return [SELECT Id, Name, AccountId FROM Contact WHERE Id = :strContactId];
    }
    
    public static List<Contact> getContactDetailsFromAccount(
        String strAccountId
    ) {
        return [
            SELECT Id, Name, AccountId
            FROM Contact
            WHERE AccountId = :strAccountId
            LIMIT 1
        ];
    }
    
    public static List<Product2> getProductDetails(String strProductId) {
        return [
            SELECT Id, Name, B2B_SEGIAMProductNumber__c
            FROM Product2
            WHERE Id = :strProductId
        ];
    }
    
    @AuraEnabled
    public static List<AQT_Quote__c> getQuoteDetails(String strQuoteId) {
        return [
            SELECT
            Id,
            Name,
            TotalAmount__c,
            TotalDiscount__c,
            Account__r.Name,
            Reference__c,
            NetAmount__c,
            Contact__c,
            Contact__r.Name
            FROM AQT_Quote__c
            WHERE Id = :strQuoteId
        ];
    }
    
    public static List<User> getUserDetail(String strUserId) {
        return [SELECT Id, Name, Department FROM User WHERE Id = :strUserId];
    }
    
    public static List<AQT_QuoteLineItem__c> getQuoteLineItemRecords(
        String strQuoteId
    ) {
        return [
            SELECT
            Id,
            Name,
            Partnumber__c,
            Product__r.Name,
            TotalAmount__c,
            Quote__r.Name,
            Quote__r.Account__c,
            Quote__r.Account__r.Name,
            SEGIAMProductNumber__c,
            Quote__r.Status__c,
            Quote__r.Reference__c,
            ProductType__c,
            Product__r.B2B_QuantityRemaining__c,
            Product__r.B2B_LeadTimeWeeks__c,
            Product__r.B2B_MOQ__c,
            Product__c,
            StandardListPrice__c,
            CustomerTargetPrice__c,
            Quote__r.Contact__c,
            Discount__c,
            EndPrice__c,
            Product__r.B2B_SEGIAMProductNumber__c,
            ListPrice__c,
            ProductionLocation__c,
            Quantity__c,
            Quote__r.TotalDiscount__c,
            Quote__r.TotalAmount__c,
            Quote__r.NetAmount__c,
            Quote__c,
            LeadTime__c,
            MOQ__c,
            QuantityRequested__c,
            UnitPrice__c,
            Ebit__c
            FROM AQT_QuoteLineItem__c
            WHERE Quote__c = :strQuoteId
        ];
    }
    
    public static List<OrderItemSummary> getPreviousRecordUnitPrice(
        String strAccountId,
        Set<String> set_PartNumberWithWildCharacters
    ) {
        return [
            SELECT Id, Product2.B2B_SEGIAMProductNumber__c, UnitPrice
            FROM OrderItemSummary
            WHERE
            Ordersummary.AccountId = :strAccountId
            AND (Product2.B2B_SEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_PreviousSEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_OEMItemNumber__c LIKE :set_PartNumberWithWildCharacters)
            ORDER BY CREATEDDATE DESC
        ];
    }
    
    //Get quote record with draft status
    @AuraEnabled
    public static List<AQT_Quote__c> getQuoteRecord() {
        return [
            SELECT
            Id,
            Name,
            Account__c,
            Account__r.Name,
            Contact__c,
            Contact__r.Name,
            NetAmount__c,
            TotalDiscount__c
            FROM AQT_Quote__c
            WHERE Status__c = 'Draft' AND CreatedById = :Userinfo.getUserId()
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
    
    //Get the prices for all the accounts related to part numbers
    public static List<OrderItemSummary> getPreviousSoldUnitPrice(
        Set<String> set_PartNumberWithWildCharacters,
        String strAccountId
    ) {
        return [
            SELECT
            Id,
            Product2.B2B_SEGIAMProductNumber__c,
            Ordersummary.AccountId,
            Ordersummary.Account.Name,
            UnitPrice
            FROM OrderItemSummary
            WHERE
            Ordersummary.AccountId != :strAccountId
            AND (Product2.B2B_SEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_PreviousSEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_OEMItemNumber__c LIKE :set_PartNumberWithWildCharacters)
            ORDER BY CREATEDDATE DESC
        ];
    }
    
    public static List<OrderItemSummary> getPreviousSoldUnitPrices(
        Set<String> set_PartNumberWithWildCharacters,
        List<String> set_accountId
    ) {
        return [
            SELECT
            Id,
            Product2.B2B_SEGIAMProductNumber__c,
            Ordersummary.AccountId,
            Ordersummary.Account.Name,
            UnitPrice
            FROM OrderItemSummary
            WHERE
            Ordersummary.AccountId = :set_accountId
            AND (Product2.B2B_SEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_PreviousSEGIAMProductNumber__c LIKE :set_PartNumberWithWildCharacters
                 OR Product2.B2B_OEMItemNumber__c LIKE :set_PartNumberWithWildCharacters)
            ORDER BY CREATEDDATE DESC
        ];
    }
}