/*******************************************************************************************************
* 
* @ Name            :   B2B_GenericDataTableByFieldSetController
* @ Purpose         :   To fecilitate serever side logic for b2b_genericDataTableByFieldSet
* @ Methods         :   getTableData - Returns sObject label to show on the component header
                            params - strRecordId, strObjectApiName, strFieldSetName, strCriteriaField
                                strParentObjectAPIName, strParentCriteriaField, strLimitRow
*                           Returns specific wrapper object
* @ Author          :   Monal Kumar
* @ Usage           :   For displaying product application list on the product detail page
* @ Test Class Name :   B2B_FieldSetSelectorTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   15-05-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public with sharing class B2B_GenericDataTableByFieldSetController {
    
    @AuraEnabled
    public static TableData getTableData(
        String strRecordId,
        String strObjectApiName, 
        String strFieldSetName,
        String strCriteriaField,
        String strParentObjectAPIName,
        String strParentCriteriaField, 
        String strLimitRow
    ) {
        try {
            List<SObject> list_Make = Database.query('Select B2B_Make__c FROM Product2 where Id = \''+strRecordId+ '\'');
            string makefilter = '';
            if (!list_Make.isEmpty()) {
                makefilter = (String) list_Make[0].get('B2B_Make__c');
            }
            TableData objTabledata = new TableData();
            Map<String, String> map_columnsAndRecordsByKey = new Map<String, String> ();
            if (makefilter != '') {
              makefilter = 'AND Make__c = \''+makefilter+ '\'';
            }
            String strParentCriteriaFieldValue = 
                B2B_FieldSetSelector.getCriteriaFieldValueByObjectAPINameFieldAPINameAndRecordId(
                    strRecordId,
                    strParentObjectAPIName, 
                    strParentCriteriaField
                );
system.debug('strParentCriteriaFieldValue ='+strParentCriteriaFieldValue);            
            if (!String.isEmpty (strObjectApiName) && !String.isEmpty(strfieldSetName)) {
                List<Schema.FieldSetMember> list_FieldSetMembers = 
                    B2B_FieldSetSelector.getFields(
                        strObjectApiName,
                        strfieldSetName
                    );
                
                List<SObject> list_Records = 
                    B2B_FieldSetSelector.getRecordsByFieldSetAndCriteria(
                        strObjectApiName,
                        list_FieldSetMembers,
                        strCriteriaField,
                        strParentCriteriaFieldValue,
                        strLimitRow,makefilter
                    );
                
                String strSObjectLabel = 
                    ((SObject)(Type.forName('Schema.' + strObjectApiName)
                               .newInstance())).getSObjectType()
                    .getDescribe()
                    .getLabel();
                
                //prepare a map which will hold fieldList and recordList and return it
                objTabledata.strFieldList = JSON.serialize(list_FieldSetMembers);
                objTabledata.strRecordList = JSON.serialize(list_Records);
                objTabledata.strSobjectLabel = JSON.serialize(strSObjectLabel);
                
                return objTabledata;
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }
        
        return null;
    }
    
    public class TableData {
        @AuraEnabled public String strFieldList;
        @AuraEnabled public String strRecordList;
        @AuraEnabled public String strSobjectLabel;
    }
}