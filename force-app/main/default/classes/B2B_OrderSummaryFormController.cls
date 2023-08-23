public without sharing class B2B_OrderSummaryFormController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldNames(String objectName, String fieldSetName) {
        List<String> fieldNames = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objDef = schemaMap.get(objectName);
        if (objDef != null) {
            Schema.DescribeSObjectResult objResult = objDef.getDescribe();
            if (objResult != null && objResult.fieldSets.getMap().containsKey(fieldSetName)) {
                for (Schema.FieldSetMember fsm : objResult.fieldSets.getMap().get(fieldSetName).getFields()) {
                    fieldNames.add(fsm.getFieldPath());
                }
            }
        }
        return fieldNames;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecord(Id recordId, List<String> fieldNames) {
        Map<String, Object> recordValues = new Map<String, Object>();
        Id myId = Id.valueOf(recordId);
        Schema.SObjectType sobjectType = myId.getSObjectType();
        String sobjectName = String.valueOf(sobjectType.getDescribe().getName());
        SObject record = Database.query('SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + sobjectName + ' WHERE Id = :recordId LIMIT 1');
        if (record != null) {
            for (String fieldName : fieldNames) {
                recordValues.put(fieldName, record.get(fieldName));
            }
        }
        return recordValues;
    }

    @AuraEnabled
    public static void saveRecord(SObject record) {
        try {
            upsert record;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}