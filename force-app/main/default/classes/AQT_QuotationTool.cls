/*******************************************************************************************************
*
* @ Name            :   AQT_QuotationTool
* @ Purpose         :   Controller for process upload excel file,search product,create quote and request record
* @ Author          :   Khushmeet Kaur
* @ Test Class Name :   AQT_QuotationToolTest
*
*   Date            |  Developer Name            |  Version      |  Changes
* ======================================================================================================
*   24-02-2022      |  Khushmeet.kaur@absyz.com  |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class AQT_QuotationTool {
    
    //This method is to fetch the custom setting for the setup of the quotation tool
    @AuraEnabled(cacheable = true)
    public static AQT_AftermarketQuotationToolSetup__c getCustomSettings() {
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool =
            AQT_AftermarketQuotationToolSetup__c.getInstance();
        return objAfterMarketQuotationTool;
    }
    
    /* * * * * * * * * * * Wrapper Classes - Start To deserialize the excel upload* * * * * * * * * */
    public class processExcelUploadFileWrapper {
        @AuraEnabled public String Partnumber {get;set;}
        @AuraEnabled public Integer Quantity {get;set;}
        @AuraEnabled public Decimal TargetPrice {get; set;} 
    }
    
    /* * * * * * * * * * * Wrapper END - Start To deserialize the excel upload* * * * * * * * * */
    @AuraEnabled
    public static List<processExcelUploadFileWrapper> processExcelUploadFile(String processFileData) {
        try {
            List<processExcelUploadFileWrapper> list_processExcelFileWrapper =
                (List<processExcelUploadFileWrapper> )
                JSON.deserialize(processFileData, List<processExcelUploadFileWrapper> .class);
            return list_processExcelFileWrapper;
        } catch (Exception e) {
            throw new JSONException(e.getMessage());
        }
    }
    
    //This method is to search the product and return the result to LWC controller
    @AuraEnabled
    public static searchProductWrapper searchProducts(
        String strAccountId,
        String strContactId,
        String strRequestedData,
        String strProductId
    ) {
        try {
            //Get the custom setting data
            AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = getCustomSettings();
            Decimal decimalEbitPercentage = objAfterMarketQuotationTool.EBITPercentage__c / 100;
            String strStandardPricebookId = objAfterMarketQuotationTool.StandardPricebookId__c;
            String strPPCPriceBookId = objAfterMarketQuotationTool.PPCPricebookId__c;
            
            //Create a set of requested part numbers, part numbers will always be unique.
           // Set<String> set_RequestedPartNumbers = new Set<String>();
          
            Set<String> set_RequestedPartNumberWithWildCharacters = new Set<String>();
            
            //List of processExcelUploadFile data
            List<processExcelUploadFileWrapper> list_ProcessExcelUploadFileWrapper = new List<processExcelUploadFileWrapper>();
            //Get the requested partNumber
            if (String.isNotBlank(strRequestedData)) {
                list_ProcessExcelUploadFileWrapper = processExcelUploadFile(strRequestedData);
                for (processExcelUploadFileWrapper objProcessExcelFile : list_ProcessExcelUploadFileWrapper) {
                    //set_RequestedPartNumbers.add(objProcessExcelFile.PartNumber);
                    set_RequestedPartNumberWithWildCharacters.add('%' + objProcessExcelFile.PartNumber + '%');
                }
            }
            
            //Send the data as the searchProductWrapper when products are searched from lookup field.
            if (String.isNotBlank(strProductId)) {
                for (Product2 objProduct : AQT_QuotationToolSelector.getProductDetails(strProductId)) {
                    set_RequestedPartNumberWithWildCharacters.add(objProduct.B2B_SEGIAMProductNumber__c);
                    //Create process excel upload wrapper and add it to the  wrapper list
                    processExcelUploadFileWrapper objProcessExcelFile = new processExcelUploadFileWrapper();
                    objProcessExcelFile.PartNumber = objProduct.B2B_SEGIAMProductNumber__c;
                    objProcessExcelFile.Quantity = 1;
                    objProcessExcelFile.TargetPrice = 0;
                    list_ProcessExcelUploadFileWrapper.add(objProcessExcelFile);
                }
            }
            
            //Get the pricebook from the account buyer group
            String strBuyerGroupPricebookId;
            if (String.isNotBlank(strAccountId)) {
                String strBuyerGroupMemeberId;
                for (BuyerGroupMember objBuyerGroupMember : AQT_QuotationToolSelector.getBuyerGroupMember(strAccountId)) {
                    strBuyerGroupMemeberId = objBuyerGroupMember.BuyerGroupId;
                }
                if (String.isNotBlank(strBuyerGroupMemeberId)) {
                    for (BuyerGroupPricebook objBuyerGroupPricebookRecord : AQT_QuotationToolSelector.getBuyerGroupPricebook(strBuyerGroupMemeberId)) {
                        strBuyerGroupPricebookId = objBuyerGroupPricebookRecord.Pricebook2Id;
                    }
                }
            }
            
            //Get the pricebook entry for the selected part numbers and related buyer group pricebook
            Map<String, PriceBookEntry> map_PricebookEntryBySelectedPartNumber = new Map<String, PriceBookEntry>();
            List<String> list_OEMNumbers = new List<String>();
            
            for (PriceBookEntry objPriceBookEntry : AQT_QuotationToolSelector.getPricebookEntryRecord(
                set_RequestedPartNumberWithWildCharacters, 
                strBuyerGroupPricebookId)
                ) {
                    //Store SEGIAMNumber with priceboook entry
                    map_PricebookEntryBySelectedPartNumber.put(objPriceBookEntry.Product2.B2B_SEGIAMProductNumber__c, objPriceBookEntry);
                    //Store Previous SEGIAMNumber with priceboook entry
                    if(String.isNotBlank(objPriceBookEntry.Product2.B2B_PreviousSEGIAMProductNumber__c)){
                    	map_PricebookEntryBySelectedPartNumber.put(objPriceBookEntry.Product2.B2B_PreviousSEGIAMProductNumber__c, objPriceBookEntry);
                    }
                    if (String.isNotBlank(objPriceBookEntry.Product2.B2B_OEMItemNumber__c)) {
                        //Store Previous OEMNumber with priceboook entry
                        list_OEMNumbers = objPriceBookEntry.Product2.B2B_OEMItemNumber__c.split(',');
                        if (!list_OEMNumbers.isEmpty()) {
                            for (String strOEMNumber : list_OEMNumbers) {
                                map_PricebookEntryBySelectedPartNumber.put(strOEMNumber.replaceAll( '\\s+', ''), objPriceBookEntry);
                            }
                        } else {
                            map_PricebookEntryBySelectedPartNumber.put(objPriceBookEntry.Product2.B2B_OEMItemNumber__c, objPriceBookEntry);
                        }
                    }
                    system.debug('map_PricebookEntryBySelectedPartNumber12'+map_PricebookEntryBySelectedPartNumber);
                }
            
            system.debug('map_PricebookEntryBySelectedPartNumber'+map_PricebookEntryBySelectedPartNumber);
            
            //Get standard pricebook unit price for selected products
            Map<String, Decimal> map_standardPriceBySelectedPartNumber = new Map<String, Decimal>();
            for (PriceBookEntry objPriceBoookEntry : AQT_QuotationToolSelector.getPricebookEntryRecord(
                set_RequestedPartNumberWithWildCharacters, 
                strStandardPricebookId)){
                map_standardPriceBySelectedPartNumber.put(objPriceBoookEntry.Product2.B2B_SEGIAMProductNumber__c, objPriceBoookEntry.UnitPrice);
            }
            
            //Get the ppc price for the selected products
            Map<String, Decimal> map_ppcPriceBySelectedPartNumber = new Map<String, Decimal>();
            for (PriceBookEntry objPriceBoookEntry : AQT_QuotationToolSelector.getPricebookEntryRecord(
                set_RequestedPartNumberWithWildCharacters, 
                strPPCPriceBookId)) {
                    map_ppcPriceBySelectedPartNumber.put(objPriceBoookEntry.Product2.B2B_SEGIAMProductNumber__c, objPriceBoookEntry.UnitPrice);
                }
            
            //Get the previous records for the quotelineitem related to selected account and partnumber
            Map<String, Decimal> map_previousOfferedPriceByPartNumber = new Map<String, Decimal>();
            for (OrderItemSummary objOrderItemSummary : AQT_QuotationToolSelector.getPreviousRecordUnitPrice(strAccountId,set_RequestedPartNumberWithWildCharacters)) {
                map_previousOfferedPriceByPartNumber.put(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c, objOrderItemSummary.UnitPrice);
            }
            
            Set<String>set_accountId = new Set<String>();
            for (OrderItemSummary objOrderItemSummary : 
                 AQT_QuotationToolSelector.getPreviousSoldUnitPrice(
                     set_RequestedPartNumberWithWildCharacters,
                     strAccountId)){
                         set_accountId.add(String.valueOf(objOrderItemSummary.OrderSummary.AccountId));
                     }
            
            
            map<String,String> map_BuyerGroupByAccountId = new map<String,String>();
            for (BuyerGroupMember objBuyerGroupMember : 
                 AQT_QuotationToolSelector.getBuyerGroupMemberRecord(set_accountId)){
                     map_BuyerGroupByAccountId.put(objBuyerGroupMember.BuyerGroup.Name,
                                                   objBuyerGroupMember.BuyerId
                                                  );
                 }
            
            
            map<String,List<previousOfferedPrice>> map_previousOfferedPricesByPartNumber = new map<String, List<previousOfferedPrice>>();
            map<String,map<String,Decimal>>map_previousOfferedPriceByAccountIdByPartNumber = new map<String,map<String,Decimal>>();
            
            for (OrderItemSummary objOrderItemSummary : 
                 AQT_QuotationToolSelector.getPreviousSoldUnitPrices(
                     set_RequestedPartNumberWithWildCharacters,
                     map_BuyerGroupByAccountId.values())) {
                         
                         if(!map_previousOfferedPriceByAccountIdByPartNumber.containsKey(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c)) {
                             map_previousOfferedPriceByAccountIdByPartNumber.put(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c,new map<String,Decimal>());
                             map_previousOfferedPricesByPartNumber.put(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c,new list<previousOfferedPrice>());
                         } 
                         if(!map_previousOfferedPriceByAccountIdByPartNumber.get(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c).containsKey(objOrderItemSummary.OrderSummary.AccountId)){
                             map_previousOfferedPriceByAccountIdByPartNumber.get(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c).put(objOrderItemSummary.OrderSummary.AccountId,objOrderItemSummary.UnitPrice);
                             previousOfferedPrice objpreviousOfferedPrice = new previousOfferedPrice();
                         	 objpreviousOfferedPrice.AccountName = objOrderItemSummary.OrderSummary.Account.Name;
                         	 objpreviousOfferedPrice.UnitPrice = objOrderItemSummary.UnitPrice;
                             map_previousOfferedPricesByPartNumber.get(objOrderItemSummary.Product2.B2B_SEGIAMProductNumber__c).add(objpreviousOfferedPrice);
                         }
                     }          
            
            List<productFoundData> list_productFoundWrapper = new List<productFoundData>();
            List<productNotFoundData> list_productNotFoundWrapper = new List<productNotFoundData>();
            
            for (processExcelUploadFileWrapper objProcessUploadFile : list_ProcessExcelUploadFileWrapper) {
                //If product has the pricebook entry with the buyer pricebook id,add it to product found list
                if (map_PricebookEntryBySelectedPartNumber.containsKey(objProcessUploadFile.PartNumber)) {
                    Decimal decimalEbit = 0;
                    productFoundData objProductFoundWrapper = new productFoundData();
                    objProductFoundWrapper.PartNumber = objProcessUploadFile.PartNumber;
                    
                    objProductFoundWrapper.Quantity = objProcessUploadFile.Quantity;
                    objProductFoundWrapper.TargetPrice = objProcessUploadFile.TargetPrice;
                    //On the first search,the quantity will be same applied on the quantity final
                    objProductFoundWrapper.SEGIAMNumber = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber)
                        .Product2.B2B_SEGIAMProductNumber__c;
                    
                    if (map_standardPriceBySelectedPartNumber.containsKey(objProductFoundWrapper.SEGIAMNumber)) {
                        objProductFoundWrapper.StandardListPrice = map_standardPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber);
                        objProductFoundWrapper.EndPrice = map_standardPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber);
                        objProductFoundWrapper.NetAmount = objProductFoundWrapper.Quantity * objProductFoundWrapper.StandardListPrice;
                        
                        //Calculate EBIT%
                        if (map_ppcPriceBySelectedPartNumber.containsKey(objProductFoundWrapper.SEGIAMNumber)) {
                            decimalEbit = ((map_standardPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber) -
                                            map_ppcPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber) 
                                            * (1 + decimalEbitPercentage)) /
                                           map_standardPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber)) * 100;
                            
                            objProductFoundWrapper.PPCPrice = map_ppcPriceBySelectedPartNumber.get(objProductFoundWrapper.SEGIAMNumber);
                            objProductFoundWrapper.SG_A = decimalEbitPercentage;
                        }
                    }
                    
                    objProductFoundWrapper.UnitPrice = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).UnitPrice;
                    objProductFoundWrapper.QuantityFinal = objProcessUploadFile.Quantity;
                    objProductFoundWrapper.Discount = 0;
                    objProductFoundWrapper.EBIT = decimalEbit.setScale(2);
                    objProductFoundWrapper.ProductType = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.B2B_ProductType__c;
                    objProductFoundWrapper.Name = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.Name;
                    objProductFoundWrapper.ProductionLocation = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.B2B_Plant__r.Name;
                    
                    if (map_previousOfferedPriceByPartNumber.containsKey(objProductFoundWrapper.SEGIAMNumber)) {
                        objProductFoundWrapper.SEGAlreadyOfferedPrice = map_previousOfferedPriceByPartNumber.get(objProductFoundWrapper.SEGIAMNumber);
                    }
                    
                    objProductFoundWrapper.QuantityRemaining = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.B2B_QuantityRemaining__c;
                    objProductFoundWrapper.approvalRequired = false;
                    objProductFoundWrapper.LeadTime = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.B2B_LeadTimeWeeks__c;
                    objProductFoundWrapper.MOQ = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2.B2B_MOQ__c;
                    objProductFoundWrapper.ProductId = map_PricebookEntryBySelectedPartNumber.get(objProcessUploadFile.PartNumber).Product2Id;
                    objProductFoundWrapper.AccountId = strAccountId;
                    objProductFoundWrapper.ContactId = strContactId;
                    
                    if (map_previousOfferedPricesByPartNumber.containsKey(objProductFoundWrapper.SEGIAMNumber)) {
                        objProductFoundWrapper.previousOfferedPrice = map_previousOfferedPricesByPartNumber.get(objProductFoundWrapper.SEGIAMNumber);
                    }
                    
                    list_productFoundWrapper.add(objProductFoundWrapper);
                }
                
                /* Create product not found wrapper for the products which are not available with the buyerGroupPricebokId */
                if (!map_PricebookEntryBySelectedPartNumber.containsKey(objProcessUploadFile.PartNumber)) {
                    productNotFoundData objProductNotFoundWrapper = new productNotFoundData();
                    objProductNotFoundWrapper.PartNumber = objProcessUploadFile.PartNumber;
                    objProductNotFoundWrapper.Quantity = objProcessUploadFile.Quantity;
                    objProductNotFoundWrapper.TargetPrice = objProcessUploadFile.TargetPrice;
                    objProductNotFoundWrapper.Comment = '';
                    list_productNotFoundWrapper.add(objProductNotFoundWrapper);
                }
            }
            searchProductWrapper searchProductWrapper = new searchProductWrapper();
            searchProductWrapper.productFoundData = list_productFoundWrapper;
            searchProductWrapper.productNotFoundData = list_productNotFoundWrapper;
            return searchProductWrapper;
            
        } catch (Exception e) {
            throw new JSONException(e.getMessage());
        }
    }
    
    public class searchProductWrapper {
        @AuraEnabled public List<productFoundData> productFoundData;
        @AuraEnabled public List<productNotFoundData> productNotFoundData;
    }
    
    //Wrapper to store product found data
    public class productFoundData {
        @AuraEnabled public String PartNumber;
        @AuraEnabled public Integer Quantity;
        @AuraEnabled public Decimal TargetPrice;
        @AuraEnabled public String SEGIAMNumber;
        @AuraEnabled public Decimal StandardListPrice;
        @AuraEnabled public Decimal UnitPrice;
        @AuraEnabled public Decimal QuantityFinal;
        @AuraEnabled public Decimal EndPrice;
        @AuraEnabled public Decimal Discount;
        @AuraEnabled public Decimal NetAmount;
        @AuraEnabled public Decimal EBIT;
        @AuraEnabled public String ProductType;
        @AuraEnabled public String Name;
        @AuraEnabled public String ProductionLocation;
        @AuraEnabled public Decimal SEGAlreadyOfferedPrice;
        @AuraEnabled public Decimal QuantityRemaining;
        @AuraEnabled public Boolean approvalRequired;
        @AuraEnabled public String QuoteId;
        @AuraEnabled public String AccountId;
        @AuraEnabled public String ContactId;
        @AuraEnabled public String ProductId;
        @AuraEnabled public String Id;
        @AuraEnabled public Decimal PPCPrice;
        @AuraEnabled public Decimal SG_A;
        @AuraEnabled public Decimal LeadTime;
        @AuraEnabled public Decimal MOQ;
        @AuraEnabled public List<previousOfferedPrice> previousOfferedPrice;
        
        public productFoundData() {
            this.StandardListPrice = 0;
            this.EndPrice = 0;
            this.NetAmount = 0;
        }
    }
    
    public class previousOfferedPrice {
        @AuraEnabled public String AccountName;
        @AuraEnabled public Decimal UnitPrice;
    }
    
    //Wrapper to store product not found data
    public class productNotFoundData {
        @AuraEnabled public String PartNumber;
        @AuraEnabled public Integer Quantity;
        @AuraEnabled public Decimal TargetPrice;
        @AuraEnabled public String Comment;
    }
    
    public class QuoteDetail {
        @AuraEnabled public Boolean blnCreateRequestRecord;
        @AuraEnabled public Decimal decTotalAmount;
        @AuraEnabled public Decimal decNetAmount;
        @AuraEnabled public Decimal decTotalDiscount;
        @AuraEnabled public String strAccountId;
        @AuraEnabled public String strContactId;
        @AuraEnabled public String strContentVersionId;
        @AuraEnabled public String strProductFoundDataWrapper;
        @AuraEnabled public String strProductNotFoundWrapper;
        @AuraEnabled public Boolean blnSaveAsDraft;
        
        public QuoteDetail() {
            blnCreateRequestRecord = false;
        }
    }
    
    //This function is to create the quote and quotelineitem record and create request record,submit for approval if required
    @AuraEnabled
    public static returnCreatedRecords createQuoteRecord(String strQuoteDetail) {
        try {
            QuoteDetail objQuoteDetail = (QuoteDetail) System.JSON.deserialize(strQuoteDetail, QuoteDetail.class);
            
            //Create quote record
            AQT_Quote__c objQuote = new AQT_Quote__c();
            objQuote.Account__c = objQuoteDetail.strAccountId;
            objQuote.Contact__c = objQuoteDetail.strContactId;
            objQuote.TotalAmount__c = objQuoteDetail.decTotalAmount;
            objQuote.TotalDiscount__c = (objQuoteDetail.decTotalDiscount * 100).setScale(2);
            objQuote.NetAmount__c = objQuoteDetail.decNetAmount;
            objQuote.Version__c = 1;
            if (objQuoteDetail.blnSaveAsDraft == false) {
                objQuote.Status__c = 'Submittedw/oApproval';
            }
            
            IFv2_DmlController.GenericDMLOperation(objQuote, 'insert');
            
            //Store product not found details under notes.
            if (String.isNotBlank(objQuoteDetail.strProductNotFoundWrapper)) {
                List<productNotFoundData> list_ProductNotFoundWrapper = 
                    (List<productNotFoundData>) System.JSON.deserialize(objQuoteDetail.strProductNotFoundWrapper, List<productNotFoundData> .class);
                //Create note with the comments 
                Note objNote = new Note();
                objNote.ParentId = objQuote.Id;
                objNote.Body = '';
                for (productNotFoundData objProductNotFoundData : list_ProductNotFoundWrapper) {
                    objNote.Body += objProductNotFoundData.PartNumber + ' - ' + objProductNotFoundData.Comment + '\n';
                    objNote.Title = System.label.CLAQT00005;
                }
                IFv2_DmlController.GenericDMLOperation(objNote, 'insert');
            }
            
            //Deserialize the product found wrapper and create quote line item records.
            List<productFoundData> list_ProductFoundDataWrapper = 
                (List<productFoundData>) System.JSON.deserialize(objQuoteDetail.strProductFoundDataWrapper, List<productFoundData>.class);
            List<AQT_QuoteLineItem__c> list_QuoteLineItems = new List<AQT_QuoteLineItem__c>();
            
            //Create list of quotelineitem record to be inserted
            for (productFoundData objProductFoundWrapper : list_ProductFoundDataWrapper) {
                AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
                objQuoteLineItem.Product__c = objProductFoundWrapper.ProductId;
                objQuoteLineItem.UnitPrice__c = objProductFoundWrapper.UnitPrice;
                objQuoteLineItem.Quantity__c = objProductFoundWrapper.QuantityFinal;
                objQuoteLineItem.QuantityRequested__c = objProductFoundWrapper.Quantity;
                objQuoteLineItem.Discount__c = objProductFoundWrapper.Discount;
                objQuoteLineItem.CustomerTargetPrice__c = objProductFoundWrapper.TargetPrice;
                objQuoteLineItem.Partnumber__c = objProductFoundWrapper.PartNumber;
                objQuoteLineItem.StandardListPrice__c = objProductFoundWrapper.StandardListPrice;
                objQuoteLineItem.EndPrice__c = (objProductFoundWrapper.EndPrice).setScale(2);
                objQuoteLineItem.ListPrice__c = 
                    (objProductFoundWrapper.UnitPrice * 
                     objProductFoundWrapper.QuantityFinal).setScale(2);
                objQuoteLineItem.TotalAmount__c = (objProductFoundWrapper.EndPrice * objProductFoundWrapper.QuantityFinal).setScale(2);
                objQuoteLineItem.EBIT__c = objProductFoundWrapper.EBIT;
                objQuoteLineItem.Quote__c = objQuote.Id;
                objQuoteLineItem.LeadTime__c = objProductFoundWrapper.LeadTime;
                objQuoteLineItem.MOQ__c = objProductFoundWrapper.MOQ;
                list_QuoteLineItems.add(objQuoteLineItem);
            }
            
            if (String.isNotBlank(objQuoteDetail.strContentVersionId)) {
                
                Id objContentDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :objQuoteDetail.strContentVersionId].ContentDocumentId;
                ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                objContentDocumentLink.ContentDocumentId = objContentDocument;
                objContentDocumentLink.LinkedEntityId = objQuote.Id;
                objContentDocumentLink.Visibility = 'Allusers';
                objContentDocumentLink.ShareType = 'V';
                insert objContentDocumentLink;
            }
            
            if (!list_QuoteLineItems.isEmpty()) {
                IFv2_DmlController.GenericListDMLOperation(list_QuoteLineItems, 'insert');
            }
            
            returnCreatedRecords wrapperRecords = new returnCreatedRecords();
            
            List<Account> list_Accounts = AQT_QuotationToolSelector.getAccountDetails(objQuoteDetail.strAccountId);
            if (!list_Accounts.isEmpty()) {
                wrapperRecords.objAccountDetails = list_Accounts[0];
            }
            
            List<AQT_Quote__c> list_QuoteRecords = AQT_QuotationToolSelector.getQuoteDetails(objQuote.Id);
            IFv2_Request__c objRequest = new IFv2_Request__c();
            
            if (objQuoteDetail.blnCreateRequestRecord == true) {
                objRequest = createRequests(list_QuoteRecords, objQuoteDetail.strAccountId, objQuoteDetail.strContactId);
                wrapperRecords.objRequestDetails = objRequest;
            }            
            if (!list_QuoteRecords.isEmpty()) {
                wrapperRecords.objQuoteDetails = list_QuoteRecords[0];
            }
            return wrapperRecords;
            
        } catch (Exception e) {
            throw new JSONException(e.getMessage());
        }
    }
    
    public class returnCreatedRecords {
        @AuraEnabled public AQT_Quote__c objQuoteDetails;
        @AuraEnabled public IFv2_Request__c objRequestDetails;
        @AuraEnabled public Account objAccountDetails;
    }
    
    @AuraEnabled
    public static List<productFoundData> fetchQuoteLineItemRecords(String strQuoteId) {
        
        AQT_AftermarketQuotationToolSetup__c objAfterMarketQuotationTool = getCustomSettings();
        Decimal decimalEbitPercentage = objAfterMarketQuotationTool.EBITPercentage__c/100;
        String strPPCPriceBookId = objAfterMarketQuotationTool.PPCPricebookId__c;
        Set<String> set_selectedPartNumbers = new Set<String>();
        Map<String, Decimal> map_ppcPriceBySelectedPartNumber = new Map<String, Decimal>();
        
        Boolean blnQuoteSubmittedForApproval = false;
        for (AQT_QuoteLineItem__c objQuoteLineItem : AQT_QuotationToolSelector.getQuoteLineItemRecords(strQuoteId)) {
            if (objQuoteLineItem.Quote__r.Status__c != 'Draft' && objQuoteLineItem.Quote__r.Status__c != 'Submittedw/oApproval') {
                blnQuoteSubmittedForApproval = true;
                break;
            } else {
                set_selectedPartNumbers.add(objQuoteLineItem.SEGIAMProductNumber__c);
            }
        }
        
        //Get the PPC price for each product
        for (PricebookEntry objPricebookEntry : AQT_QuotationToolSelector.getPricebookEntryRecord(set_selectedPartNumbers,strPPCPriceBookId)) {
            map_ppcPriceBySelectedPartNumber.put(objPricebookEntry.Product2.B2B_SEGIAMProductNumber__c, objPricebookEntry.UnitPrice);
        }
        
        List<productFoundData> list_productFoundWrapper = new List<productFoundData>();
        if (blnQuoteSubmittedForApproval == false) {
            
            for (AQT_QuoteLineItem__c objQuoteLineItem : AQT_QuotationToolSelector.getQuoteLineItemRecords(strQuoteId)) {
                productFoundData objProductFoundDataWrapper = new productFoundData();
                objProductFoundDataWrapper.Id = objQuoteLineItem.Id;
                objProductFoundDataWrapper.QuoteId = objQuoteLineItem.Quote__c;
                objProductFoundDataWrapper.PartNumber = objQuoteLineItem.Partnumber__c;
                objProductFoundDataWrapper.Quantity = Integer.valueOf(objQuoteLineItem.QuantityRequested__c);
                objProductFoundDataWrapper.QuoteId = objQuoteLineItem.Quote__c;
                objProductFoundDataWrapper.AccountId = objQuoteLineItem.Quote__r.Account__c;
                objProductFoundDataWrapper.ContactId = objQuoteLineItem.Quote__r.Contact__c;
                objProductFoundDataWrapper.TargetPrice = objQuoteLineItem.CustomerTargetPrice__c;
                objProductFoundDataWrapper.QuantityFinal = objQuoteLineItem.Quantity__c;
                objProductFoundDataWrapper.ProductId = objQuoteLineItem.Product__c;
                objProductFoundDataWrapper.SEGIAMNumber = objQuoteLineItem.SEGIAMProductNumber__c;
                objProductFoundDataWrapper.UnitPrice = objQuoteLineItem.UnitPrice__c;
                objProductFoundDataWrapper.ProductType = objQuoteLineItem.ProductType__c;
                objProductFoundDataWrapper.Name = objQuoteLineItem.Product__r.Name;
                objProductFoundDataWrapper.ProductionLocation = objQuoteLineItem.ProductionLocation__c;
                objProductFoundDataWrapper.EBIT = objQuoteLineItem.EBIT__c;
                objProductFoundDataWrapper.LeadTime = objQuoteLineItem.LeadTime__c;
                objProductFoundDataWrapper.MOQ = objQuoteLineItem.MOQ__c;
                objProductFoundDataWrapper.StandardListPrice = objQuoteLineItem.StandardListPrice__c;
                objProductFoundDataWrapper.Discount = objQuoteLineItem.Discount__c;
                objProductFoundDataWrapper.QuantityRemaining = objQuoteLineItem.Product__r.B2B_QuantityRemaining__c;
                objProductFoundDataWrapper.EndPrice = objQuoteLineItem.EndPrice__c;
                objProductFoundDataWrapper.NetAmount = objQuoteLineItem.TotalAmount__c;
                objProductFoundDataWrapper.approvalRequired = false;
                
                if (map_ppcPriceBySelectedPartNumber.containsKey(objQuoteLineItem.SEGIAMProductNumber__c)) {
                    objProductFoundDataWrapper.PPCPrice = map_ppcPriceBySelectedPartNumber.get(objQuoteLineItem.SEGIAMProductNumber__c);
                }
                
                objProductFoundDataWrapper.SG_A = decimalEbitPercentage;
                list_productFoundWrapper.add(objProductFoundDataWrapper);
            }
        }
        return list_productFoundWrapper;
    }
    
    //Create request record and submit it for approval
    public static IFv2_Request__c createRequests(
        List<AQT_Quote__c> list_quoteRecord,
        String strAccountId,
        String strContactId
    ) {
        
        //Map of current userId by user details
        Map<Id, User> map_UserByUserId = new Map<Id, User>();
        for (User objUser : AQT_QuotationToolSelector.getUserDetail(Userinfo.getUserId())) {
            map_UserByUserId.put(objUser.Id, objUser);
        }
        
        //Map of account details by accountId
        Map<Id, Account> map_AccountById = new Map<Id, Account>();
        for (Account objAccount : AQT_QuotationToolSelector.getAccountDetails(strAccountId)) {
            map_AccountById.put(objAccount.Id, objAccount);
        }
        Map<Id, String> map_AcountIdByContactName = new Map<Id, String>();
        for (Contact objContact : AQT_QuotationToolSelector.getContactDetails(strContactId)) {
            map_AcountIdByContactName.put(objContact.AccountId, objContact.Name);
        }
        
        //Map of buyer group name by account id
        Map<Id, String> map_AcountIdByBuyerGroupName = new Map<Id, String>();
        for (BuyerGroupMember objBuyerGroup : AQT_QuotationToolSelector.getBuyerGroupMember(strAccountId)) {
            map_AcountIdByBuyerGroupName.put(objBuyerGroup.BuyerId, objBuyerGroup.BuyerGroup.Name);
        }
        Map<String, Schema.SObjectField> map_fieldsByString = Schema.SObjectType.IFv2_Workflow__c.fields.getMap();
        
        String strQuery = 'SELECT ' +
            String.join(new List<String>(map_fieldsByString.keySet()), ',') +
            ' FROM IFv2_Workflow__c WHERE Workflow__c = \'Aftermarket Quotation Tool\' LIMIT 1';
        
        List<IFv2_Request__c> list_Requests = new List<IFv2_Request__c>();
        List<IFv2_Workflow__c> list_Workflows = Database.query(strQuery);
        if (!list_Workflows.isEmpty()) {
            // list_Quotes will always contain 1 record, considering this we have DML and SOQL in for loop
            IFv2_Workflow__c objWorkflow = list_Workflows[0];
            String strRequestId = IFv2_DmlController.insertRequestRecord(objWorkflow);
            for (AQT_Quote__c objQuote : list_quoteRecord) {
                IFv2_Request__c objRequest = new IFv2_Request__c(Id = strRequestId);
                objRequest.RequestorName__c = map_UserByUserId.get(Userinfo.getUserId()).Name;
                objRequest.Department__c = map_UserByUserId.get(Userinfo.getUserId()).Department;
                if (map_AccountById.containsKey(objQuote.Account__c)) {
                    objRequest.CompanyName__c = map_AccountById.get(objQuote.Account__c).Name;
                    objRequest.ContactName__c = map_AcountIdByContactName.get(objQuote.Account__c);
                    objRequest.AQT_CustomerGroup__c = map_AcountIdByBuyerGroupName.get(objQuote.Account__c);
                    objRequest.Customer_Address__c = map_AccountById.get(objQuote.Account__c).BillingStreet +
                        ' ' +
                        map_AccountById.get(objQuote.Account__c).BillingCity +
                        ' ' +
                        map_AccountById.get(objQuote.Account__c).BillingState +
                        ' ' +
                        map_AccountById.get(objQuote.Account__c).BillingPostalCode +
                        ' ' +
                        map_AccountById.get(objQuote.Account__c).BillingCountry;
                }
                objRequest.AQT_QuotationNumber__c = objQuote.Id;
                objRequest.AQT_Discount__c = objQuote.TotalDiscount__c;
                objRequest.AQT_TotalAmount__c = objQuote.TotalAmount__c;
                objRequest.AQT_NetAmount__c = objQuote.NetAmount__c;
                list_Requests.add(objRequest);
            }
        }
        
        List<IFv2_Request__c> list_UpdatedRequests = new List<IFv2_Request__c>();
        // Calling generic method to update SObject list records
        IFv2_DmlController.GenericListDMLOperation(list_Requests, 'update');
        if (!list_Requests.isEmpty()) {
            String strFields = ', Name, Workflow__c, RequestExtension1__c, RequestExtension2__c, RequestExtension3__c, Account__c';
            list_UpdatedRequests = IFv2_UtilsController.getRequestRecord(list_Requests[0].Id, strFields);
            if (!list_UpdatedRequests.isEmpty()) {
                IFv2_HeaderController.submitForApproval(list_UpdatedRequests[0], null);
            }
        }
        
        if (!list_UpdatedRequests.isEmpty()) {
            return list_UpdatedRequests[0];
        }
        
        return new IFv2_Request__c();
    }
    
    //Update,insert the quotelineitem and quote record
    @AuraEnabled
    public static returnCreatedRecords updateQuoteLineItemRecords(
        String list_quoteLineItemRecord,
        Decimal decTotalAmount,
        Decimal decTotalDiscount,
        Boolean blnCreateRequestRecord
    ) {
        try {
            List<productFoundData> list_ProductFoundDataWrapper = (List<productFoundData>) JSON.deserialize(list_quoteLineItemRecord, List<productFoundData>.class);
            
            String strQuoteId;
            String strAccountId;
            String strContactId;
            
            List<AQT_QuoteLineItem__c> list_updateQuoteLineItemRecords = new List<AQT_QuoteLineItem__c>();
            for (productFoundData objProductFoundWrapper : list_ProductFoundDataWrapper) {
                AQT_QuoteLineItem__c objQuoteLineItem = new AQT_QuoteLineItem__c();
                objQuoteLineItem.Discount__c = objProductFoundWrapper.Discount;
                objQuoteLineItem.Quantity__c = objProductFoundWrapper.QuantityFinal;
                objQuoteLineItem.EBIT__c = objProductFoundWrapper.EBIT;
                objQuoteLineItem.Id = objProductFoundWrapper.Id;
                objQuoteLineItem.EndPrice__c = (objProductFoundWrapper.EndPrice).setScale(2);
                objQuoteLineItem.TotalAmount__c = (objProductFoundWrapper.EndPrice * objProductFoundWrapper.QuantityFinal).setScale(2);
                objQuoteLineItem.ListPrice__c = (objProductFoundWrapper.QuantityFinal * objProductFoundWrapper.UnitPrice).setScale(2);
                if (objProductFoundWrapper.Id == null) {
                    objQuoteLineItem.Quote__c = objProductFoundWrapper.QuoteId;
                    objQuoteLineItem.Product__c = objProductFoundWrapper.ProductId;
                    objQuoteLineItem.ListPrice__c = objProductFoundWrapper.QuantityFinal * objProductFoundWrapper.UnitPrice;
                    objQuoteLineItem.UnitPrice__c = objProductFoundWrapper.UnitPrice;
                    objQuoteLineItem.QuantityRequested__c = objProductFoundWrapper.Quantity;
                    objQuoteLineItem.CustomerTargetPrice__c = objProductFoundWrapper.TargetPrice;
                    objQuoteLineItem.Partnumber__c = objProductFoundWrapper.PartNumber;
                    objQuoteLineItem.TotalAmount__c = objProductFoundWrapper.EndPrice * objProductFoundWrapper.QuantityFinal;
                    objQuoteLineItem.StandardListPrice__c = objProductFoundWrapper.StandardListPrice;
                    objQuoteLineItem.EndPrice__c = objProductFoundWrapper.EndPrice;
                }
                strQuoteId = objProductFoundWrapper.QuoteId;
                list_updateQuoteLineItemRecords.add(objQuoteLineItem);
            }
            List<AQT_Quote__c> list_updateQuoteRecords = new List<AQT_Quote__c>();
            for (AQT_Quote__c objQuote : AQT_QuotationToolSelector.getQuoteDetails(strQuoteId)) {
                objQuote.TotalAmount__c = decTotalAmount;
                objQuote.TotalDiscount__c = (decTotalDiscount * 100).setScale(2);
                objQuote.NetAmount__c = decTotalAmount - (decTotalAmount * decTotalDiscount);
                list_updateQuoteRecords.add(objQuote);
            }
            
            if (!list_updateQuoteLineItemRecords.isEmpty()) {
                IFv2_DmlController.GenericListDMLOperation(list_updateQuoteLineItemRecords, 'upsert');
            }
            if (!list_updateQuoteRecords.isEmpty()) {
                IFv2_DmlController.GenericListDMLOperation(list_updateQuoteRecords, 'update');
            }
            IFv2_Request__c objRequest = new IFv2_Request__c();
            Account objAccount;
            if (!list_updateQuoteRecords.isEmpty()) {
                objAccount = AQT_QuotationToolSelector.getAccountDetails(list_updateQuoteRecords[0].Account__c)[0];
                
                if (blnCreateRequestRecord == true) {
                    objRequest = createRequests(list_updateQuoteRecords, list_updateQuoteRecords[0].Account__c, list_updateQuoteRecords[0].Contact__c);
                }
            }
            
            returnCreatedRecords wrapperRecords = new returnCreatedRecords();
            if (!list_updateQuoteRecords.isEmpty()) {
                wrapperRecords.objQuoteDetails = list_updateQuoteRecords[0];
            }
            
            wrapperRecords.objRequestDetails = objRequest;
            wrapperRecords.objAccountDetails = objAccount;
            return wrapperRecords;
            
        } catch (Exception e) {
            throw new JSONException(e.getMessage());
        }
    }
    
    //Delete the quoteLineItem record
    @AuraEnabled
    public static void deleteQuoteLineItem(List<SObject> list_SObjects) {
        try {
            if (!list_SObjects.isEmpty()) {
                delete list_SObjects;
            }
        } catch (Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
    }
    
    //Submit the quote for approval
    @AuraEnabled
    public static Boolean submitForApproval(String QuoteId) {
        try {
            Boolean blnSuccess = false;
            List<AQT_Quote__c> list_Quotes = [SELECT
                                              Id,
                                              Name,
                                              TotalAmount__c,
                                              TotalDiscount__c,
                                              Account__c,
                                              NetAmount__c,
                                              Contact__c
                                              FROM AQT_Quote__c
                                              WHERE Id = :QuoteId 
                                              AND Status__c = 'Draft'
                                             ];
            if (!list_Quotes.isEmpty()) {
                String strContactId = list_Quotes[0].Contact__c;
                String strAccountId = list_Quotes[0].Account__c;
                
                IFv2_Request__c objRequest = createRequests(list_Quotes, strAccountId, strContactId);
                
                if (objRequest != null) {
                    blnSuccess = true;
                }
            }
            return blnSuccess;
        } catch (Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean quotePDFCacheStore(
        String strProductFoundData,
        Decimal decTotalPrice,
        Decimal decTotalDiscount,
        String strAccountName,
        String strContactName
    ) {
        Cache.SessionPartition partition = Cache.Session.getPartition('local.QuotePDF');
        partition.put('strProductFoundData', strProductFoundData);
        partition.put('decTotalPrice', decTotalPrice);
        partition.put('decTotalDiscount', decTotalDiscount);
        partition.put('strAccountName', strAccountName);
        if (!String.isBlank(strContactName)) {
            partition.put('strContactName', strContactName);
        }
        return true;
    }
}