/*******************************************************************************************************
* 
* @ Name            :   B2B_FieldSetSelector
* @ Purpose         :   Includes method to query data using field set
* @ Methods         :   1) getFields - Returns List of FieldSetMember
*                           params - strObjectApiName, strFieldSetName
*                       2) getCriteriaFieldValueByObjectAPINameFieldAPINameAndRecordId
*                           params - RecordId, sObjectName, FieldAPIName
*                           Returns specific field's value as string to pass as criteria in query filter
* @ Author          :   Monal Kumar
* @ Usage           :   1) For displaying product application list on the product detail page
* @ Test Class Name :   B2B_FieldSetSelectorTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   15-05-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/

public with sharing class B2B_FieldSetSelector {
    
    public static List<Schema.FieldSetMember> getFields(
        String strObjectApiName,
        String strFieldSetName
    ) {
        if (!String.isEmpty(strObjectApiName) && !String.isEmpty(strFieldSetName)) {
            //get fields from FieldSet
            SObject objInstance = 
                (SObject)(Type.forName('Schema.' + strObjectApiName).newInstance());
            
            List<Schema.FieldSetMember> list_FieldSetMembers = 
                objInstance
                .getSObjectType()
                .getDescribe()
                .FieldSets
                .getMap()
                .get(strFieldSetName)
                .getFields();
            
            return list_FieldSetMembers;
        }
        
        return null;
    }
    
    public static String getCriteriaFieldValueByObjectAPINameFieldAPINameAndRecordId(
        String strRecordId, 
        String strObjectApiName, 
        String strFieldApiName
    ) {
        //prepare SOQL query based on fieldAPIs	
        String strQuery = 'SELECT ';
        
        if (String.isNotBlank(strRecordId) 
            && String.isNotBlank(strObjectApiName) 
            && String.isNotBlank(strFieldApiName)) {
                
                strQuery += strFieldApiName + ' FROM ';
                strQuery += strObjectApiName;
                strQuery += ' WHERE Id=\'' + strRecordId + '\'';
                
                //Execute query
                List<SObject> list_Records = Database.query(strQuery);
                system.debug('strQuery '+strQuery);
                if (!list_Records.isEmpty()) {
                    return (String) list_Records[0].get(strFieldApiName);
                }
            }
        
        return null;
    }
    
    public static List<SObject> getRecordsByFieldSetAndCriteria(
        String strObjectApiName, 
        List<Schema.FieldSetMember> list_FieldSetMembers,
        String strCriteriaField, 
        String strCriteriaFieldValue, 
        String strLimitRow, String makefilter
    ) {
        //prepare SOQL query based on fieldApis	
        String strQuery = 'SELECT ';
        
        if (list_FieldSetMembers != null && strObjectApiName != null) {
            
            for (Schema.FieldSetMember objFieldSetMember : list_FieldSetMembers) {
                strQuery += objFieldSetMember.getFieldPath() + ', ';
            }
            strQuery += 'Id FROM ' + strObjectApiName ;
            
            //Just in case criteria field not specified then it will return all records
            if (String.isNotEmpty(strCriteriaField) && String.isNotEmpty(strCriteriaFieldValue)) {
                strQuery += ' WHERE ' + strCriteriaField + '=\'' + strCriteriaFieldValue + '\'';
            }
            
            if (String.isNotEmpty(strLimitRow)) {
                if(makefilter != '')
                {
                    strQuery = strQuery+ makefilter;
                }
                strQuery += ' LIMIT ' + strLimitRow;
            }
            system.debug('strQuery12121 ='+strQuery);
            //execute query
            List<SObject> list_Records = Database.query(strQuery);
            return list_Records;   
        }
        
        return null;
    }
}