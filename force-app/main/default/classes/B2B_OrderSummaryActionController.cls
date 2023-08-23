/* Test Class - B2B_OrderSummaryActionControllerTest.cls */
public without sharing class B2B_OrderSummaryActionController {
    public class CustomException extends Exception {}

    public class ResponseWrapper {
        @AuraEnabled public String strErrorMessage;
        @AuraEnabled public Boolean blnIsSuccess;
        @AuraEnabled public List<OrderSummary> list_orderSummaries;
        @AuraEnabled public List<B2B_OrderExcelConfig__c> list_orderExcelConfigs;
        @AuraEnabled public Map<String, IFv2_Country__mdt> map_CountryConfigs;

        public ResponseWrapper () {
            this.blnIsSuccess = true;
            this.strErrorMessage = '';
            this.list_orderSummaries = new List<OrderSummary>();
            this.list_orderExcelConfigs = new List<B2B_OrderExcelConfig__c>();
            this.map_CountryConfigs = new Map<String, IFv2_Country__mdt>();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getDownloadActionDetails (Id idOrderSummary) { 
        ResponseWrapper objResponseWrapper = new ResponseWrapper();
        Map<String, IFv2_Country__mdt> map_CountryConfigs = new Map<String, IFv2_Country__mdt>();
        List<OrderSummary> list_OrderSummaries = new List<OrderSummary>();

        String strQuery = 'SELECT ';
        String strSubQuery = ', (SELECT ';

        Set<String> set_ParentFields = new Set<String>();
        List<String> list_ParentFields = new List<String>();
        Set<String> set_ChildFields = new Set<String>();
        List<String> list_ChildFields = new List<String>();
        set_ParentFields.add('OrderNumber');
        set_ParentFields.add('CurrencyIsoCode');

        try{
            List<B2B_OrderExcelConfig__c> list_excelConfigs = [SELECT 
                                                               Name, 
                                                               FieldName__c, 
                                                               SortOrder__c, 
                                                               DefaultValue__c, 
                                                               Type__c,
                                                               MetaDataField__c,
                                                               ColumnType__c,
                                                               ShowCurrencyCode__c
                                                               FROM B2B_OrderExcelConfig__c 
                                                               ORDER BY SortOrder__c];

            for (B2B_OrderExcelConfig__c objExcelConfig : list_excelConfigs) {
                if (String.isNotBlank(objExcelConfig.Type__c) && objExcelConfig.Type__c.toLowerCase().trim() == 'parent') {
                    if (String.isNotBlank(objExcelConfig.FieldName__c))
                        set_ParentFields.add(objExcelConfig.FieldName__c);
                } else if (String.isNotBlank(objExcelConfig.Type__c) && objExcelConfig.Type__c.toLowerCase().trim() == 'child') {
                    if (String.isNotBlank(objExcelConfig.FieldName__c))
                        set_ChildFields.add(objExcelConfig.FieldName__c);
                }
            }

            list_ParentFields.addAll(set_ParentFields);
            list_ChildFields.addAll(set_ChildFields);
            strQuery += String.join(list_ParentFields, ',')
                        + strSubQuery 
                        + String.join(list_ChildFields, ',')
                        + ' FROM OrderItemSummaries)'
                        + ' FROM OrderSummary'
                        + ' WHERE Id = \'' 
                        + String.escapeSingleQuotes(idOrderSummary)
                        + '\''
                        + ' ORDER BY CreatedDate';

            list_OrderSummaries = (List<OrderSummary>) Database.query(strQuery);

            //Fetch All Records from 'IFv2_Country__mdt' Metadata and formed a map by countrycode as key.
            for (IFv2_Country__mdt objCountryConfig : IFv2_Country__mdt.getAll().values()) {
                if (String.isNotBlank(objCountryConfig.DeveloperName)) {
                    map_CountryConfigs.put(objCountryConfig.DeveloperName.toLowerCase().trim(), objCountryConfig);
                }
            }

            // Create the response wrapper object to return data
            objResponseWrapper.list_orderExcelConfigs = list_excelConfigs;
            objResponseWrapper.list_orderSummaries = list_OrderSummaries;
            objResponseWrapper.map_CountryConfigs = map_CountryConfigs;
        } catch (Exception objException) {
            objResponseWrapper.blnIsSuccess = false;
            objResponseWrapper.strErrorMessage = objException.getMessage() +' on Line No: '+ objException.getLineNumber();
        }

        return objResponseWrapper;
    }
}