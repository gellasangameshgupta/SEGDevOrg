/*******************************************************************************************************
* 
* @ Name            :   B2B_DynamicSobjectFormController
* @ Purpose         :   Controller for b2b_dynamicSobjectForm. 
* @ Author          :   Pradeep Chary
* @ Test Class Name :   B2B_DynamicSobjectFormControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*    01-05-2023     |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*   
*******************************************************************************************************/
public without sharing class B2B_DynamicSobjectFormController {
    
    @AuraEnabled(cacheable=true)
    public static List<FieldInfo> getFieldsetFields(String objectName, String fieldsetName) {
        List<FieldInfo> fieldInfos = new List<FieldInfo>();
        Schema.FieldSet fieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap().get(fieldsetName);
        for (Schema.FieldSetMember field : fieldSet.getFields()) {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get(field.getFieldPath()).getDescribe();
            FieldInfo fieldInfo = new FieldInfo();
            fieldInfo.strApiName = field.getFieldPath();
            fieldInfo.strLabel = fieldResult.getLabel();
            fieldInfo.strDataType = String.valueOf(fieldResult.getType());
            if (fieldResult.getType() == DisplayType.Picklist) {
                List<String> picklistValues = new List<String>();
                for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
                    picklistValues.add(picklistEntry.getValue());
                }
                fieldInfo.list_PicklistValues = picklistValues;
            }
            fieldInfos.add(fieldInfo);
        }
        return fieldInfos;
    }
    
    public class FieldInfo {
        @AuraEnabled public String strApiName;
        @AuraEnabled public String strLabel;
        @AuraEnabled public String strDataType;
        @AuraEnabled public List<String> list_PicklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRecord(String recordId, List<String> fieldNames) {
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