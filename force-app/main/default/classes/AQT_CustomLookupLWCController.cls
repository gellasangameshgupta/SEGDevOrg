/*******************************************************************************************************
* 
* @ Name            :   AQT_CustomLookupLWCController
* @ Purpose         :   Custom lookup field
* @ Methods         :   1) getCustomSettings -- Fetch the custom setting to get the setup
* @ Author          :   Khushmeet Kaur
* @ Usage           :   1) Get the result from the based on the search input
* @ Test Class Name :   AQT_CustomLookupLWCControllerTest
*
*   Date            |  Developer Name            |  Version      |  Changes
* ======================================================================================================
*   24-02-2022      |  Khushmeet.kaur@absyz.com  |  1.0          |  Initial Version
*
*******************************************************************************************************/
public without sharing class AQT_CustomLookupLWCController {
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> search(String strSearchTerm, String strObjectName, String strFilter) {
        String strQuery = null;
        
        if (strFilter != null && strFilter != '') {
            strQuery = 'SELECT Id, Name FROM ' + strObjectName + ' WHERE Name LIKE \'%' + strSearchTerm + '%\' AND ' + strFilter + ' LIMIT 5';
        } else {
            if (strSearchTerm == null || strSearchTerm == '') {
                strQuery = 'SELECT Id, Name FROM ' + strObjectName + ' WHERE LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT 5';
            } else {
                strQuery = 'SELECT Id, Name FROM ' + strObjectName + ' WHERE Name LIKE \'%' + strSearchTerm + '%\' LIMIT 5';
            }
        }

        List<SObject> list_Results = Database.query(strQuery);
        return list_Results;
    }
}