public without sharing class B2B_OrderSummaryForAfterMarketUser {
    
        @AuraEnabled
        public static List<String> getStatus() {
            List<String> list_Options = new List<String>();
            Schema.DescribeFieldResult objDescribeFieldResult = OrderSummary.Status.getDescribe();
            List<Schema.PicklistEntry> list_PicklistValues = objDescribeFieldResult.getPicklistValues();
            for( Schema.PicklistEntry objPickListEntry : list_PicklistValues)
            {
                list_Options.add(objPickListEntry.getValue());
            }     
            return list_Options;
        }

        @AuraEnabled
        public static void updateStatus(String strSelectedStatus, String strRecordId) {
            
            OrderSummary objOrderSummary = [SELECT
                                            Id,
                                            Status
                                            FROM OrderSummary
                                            WHERE Id =: strRecordId];

            objOrderSummary.Status = strSelectedStatus;
            update objOrderSummary;
        }
}