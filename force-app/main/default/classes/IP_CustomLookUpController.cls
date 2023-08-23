/*******************************************************************************************************
* 
* @ Name    :   IP_CustomLookUpController
* @ Purpose :   Controller for IP_CustomLookUp Component
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_CustomLookUpControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public without sharing class IP_CustomLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList ) {
        
        String searchKey = '%' + searchKeyWord + '%';
        List <sObject> returnList = new List <sObject>();
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        string psName = Label.IP_InventorPS;
        //string groupName=Label.IP_LawFirmMembers;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records   
        String sQuery =  'select id, Name,Email from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems'+' And isActive=true'+' order by createdDate DESC limit 5';
        
        List <sObject> lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
}