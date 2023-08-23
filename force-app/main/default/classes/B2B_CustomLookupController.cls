/*******************************************************************************************************
* 
* @ Name            :   B2B_CustomLookupController
* @ Purpose         :   Generic lookup controller
* @ Methods         :   fetchRecords - Returns searched record
* @ Author          :   Monal Kumar
* @ Usage           :   For setup assitant on contact detail page
* @ Test Class Name :   B2B_CustomLookupControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   07-07-2021      |  monal.kumar@absyz.com        |  1.0          |  Initial Version
*
*******************************************************************************************************/
public with sharing class B2B_CustomLookupController {
    
    @AuraEnabled
    public static List<RecordsData> fetchRecords(
        String strObjectName,
        String strFilterField,
        String strSearchString, 
        String strValue
    ) {
        try {
            List<RecordsData> list_Records = new List<RecordsData>();
            String strQuery = 'SELECT Id, ' + strFilterField + ' FROM '+ strObjectName;
            if(String.isNotBlank(strValue)) {
                strQuery += ' WHERE Id = \''+ strValue + '\' LIMIT 49999';
            } else {
                strQuery += ' WHERE '+ strFilterField +
                    ' LIKE ' + '\'%' + String.escapeSingleQuotes(strSearchString.trim()) + '%\' LIMIT 49999';
            }
            for(SObject objSobject : Database.query(strQuery)) {
                list_Records.add(new RecordsData((String) objSobject.get(strFilterField), (String) objSobject.get('Id')));
            }
            
            return list_Records;
        } catch (Exception objError) {
            if ( String.isNotBlank(objError.getMessage()) && objError.getMessage().contains('error:')) {
                throw new AuraHandledException(objError.getMessage()?.split('error:')[1]?.split(':')[0] + '.');
            } else {
                throw new AuraHandledException(objError.getMessage());
            }
        }
    }
    
    public class RecordsData {
        @AuraEnabled public String strLabel;
        @AuraEnabled public String strValue;
        
        public RecordsData(String strLabel, String strValue) {
            this.strLabel = strLabel;
            this.strValue = strValue;
        }
    }
}