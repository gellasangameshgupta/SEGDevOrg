/*******************************************************************************************************
* 
* @ Name    :   IP_CreateIPRightController
* @ Purpose :   Controller for IP_CreatePatentIPRight Component
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_CreateIPRightControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public without sharing class IP_CreateIPRightController {
    
    @auraEnabled
    public static Case insertIPRightandPatentFamily(String InventionId, case ipRight){
        
        Id stExam = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patent Family').getRecordTypeId();
        Case insertPatentFamily= new Case();
        Id ipRightRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IP Right').getRecordTypeId();
        Case insertipRight= new Case();
        if(ipRight != null && InventionId != null && InventionId != ''){
            Case invention= [select Id, IP_IDFNumber__c, Status, IP_Status__c, Subject, IP_Inventors__c, IP_Is_First_IP_Right_Created__c,IP_ProductClass__c,
                             IP_Product_Type__c, IP_Product_Subcategories__c,RecordTypeId, RecordType.name from Case Where Id =:InventionId];
            system.debug('InvenRec' + invention);
            
            if(invention != null){
                
                insertPatentFamily.IP_Patent_Family_ID__c = ipRight.IP_Patent_Family__c;
                insertPatentFamily.Subject = ipRight.IP_Patent_Family__c;
                insertPatentFamily.RecordTypeId = stExam;
                insertPatentFamily.IP_Family_Status__c = 'Not Filed';
                insertPatentFamily.IP_Product_Type__c = invention.IP_Product_Type__c;
                insertPatentFamily.IP_Product_Subcategories__c = invention.IP_Product_Subcategories__c;
                insert insertPatentFamily;
                
                insertipRight.IP_Country__c = ipRight.IP_Country__c;
                insertipRight.IP_Type_of_Right__c = ipRight.IP_Type_of_Right__c;
                insertipRight.ParentId = ipRight.ParentId;
                insertipRight.IP_Relationship_to_Parent__c = ipRight.IP_Relationship_to_Parent__c;
                insertipRight.IP_Provisional__c = ipRight.IP_Provisional__c;
                insertipRight.RecordtypeId = ipRightRecType;
                insertipRight.Subject = invention.Subject;
                insertipRight.IP_Product_Type__c = invention.IP_Product_Type__c;
                insertipRight.IP_Product_Subcategories__c = invention.IP_Product_Subcategories__c;
                insertipRight.IP_Status__c = invention.IP_Status__c;
                //  List<String> splitValues = invention.IDFNumber__c.trim().split('-');
                insertipRight.IP_Right_ID__c = ipRight.IP_Right_ID__c;
                insertipRight.IP_InventionName__c = invention.Id;
                insertipRight.IP_Right_Status__c = 'Not Filed';
                insertipRight.IP_All_Inventors__c = invention.IP_Inventors__c;
                insertipRight.IP_Patent_Family__c = insertPatentFamily.id;
                insertipRight.IP_ProductClass__c = ipRight.IP_ProductClass__c;
                //insertipRight.IP_ProductClass__c = '10HVPC;10GEPC';
                
                try {
                    insert insertipRight;
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
                //insert insertipRight;
                system.debug('insertipRight Family'+ insertipRight);
                if(insertipRight.Id != null || insertipRight.Id =='')
                {
                    invention.IP_Is_First_IP_Right_Created__c = true;
                    try {
                        update invention;
                    } catch(Exception e) {
                        IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                    }
                }
            }
        }
        
        return insertipRight;
        
    }
    
    @auraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        //  String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select Id, IP_Right_ID__c ';
        sQuery += ' from ' +ObjectName;
        sQuery += ' where IP_Right_ID__c LIKE \'%'+searchKeyWord+'%\' order by createdDate DESC limit 5';
        
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    
    @auraEnabled
    public static List<Case> updateIPRight(String InventionId, String IPRightId){
        List<Case> ipRightUpdate = new List<Case>();
        
        Id stExam = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IP Right').getRecordTypeId();
        if(InventionId != null && IPRightId != null && stExam != null){
            Case invention= [select Id, IP_IDFNumber__c,Status,IP_Status__c, Subject, IP_Inventors__c, IP_Product_Type__c, IP_Product_Subcategories__c from Case Where Id =:InventionId];
            Case ipRight=[select Id, IP_IDFNumber__c,Status,IP_Status__c, Subject, IP_Country__c, IP_Type_of_Right__c,IP_Right_ID__c,ParentId,IP_Patent_Family__c,
                          IP_Product_Type__c,IP_Product_Subcategories__c, IP_InventionName__c,IP_Right_Status__c,IP_All_Inventors__c
                          from Case Where Id =:IPRightId];
            if(invention != null && ipRight != null)
            {
                ipRight.RecordtypeId = stExam;
                ipRight.Subject = invention.Subject;
                ipRight.IP_Product_Type__c = invention.IP_Product_Type__c;
                ipRight.IP_Product_Subcategories__c = invention.IP_Product_Subcategories__c;
                ipRight.IP_Status__c = invention.IP_Status__c;
                List<String> splitValues = invention.IP_IDFNumber__c.trim().split('-');
                ipRight.IP_Right_ID__c = 'P'+splitValues[1]+'-'+ipRight.IP_Country__c;
                ipRight.IP_InventionName__c = invention.Id;
                ipRight.IP_Right_Status__c = 'Not Filed';
                ipRight.IP_All_Inventors__c = invention.IP_Inventors__c;
                ipRightUpdate.add(ipRight);
            }
        }
        if(ipRightUpdate.size() > 0)
            try {
                database.update(ipRightUpdate, false);
            } catch(Exception e) {
                IFv2_ExceptionUtilitiesController.exceptionHandler(e);
            }
        //database.update(ipRightUpdate, false);
        
        return ipRightUpdate;
    }
    
    @auraEnabled
    public static Case getInvention(String InventionId){
        Case invention= [select Id, IP_IDFNumber__c, Status,IP_Status__c, Subject, IP_Inventors__c, IP_Product_Type__c,
                         IP_Product_Subcategories__c from Case Where Id =:InventionId];
        
        return invention;
    }
    
    @AuraEnabled
    public static Map<String, String> getPicklistvalues(String objectName, String field_apiname,Boolean nullRequired){
        Map<String, String> options = new Map<String, String>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            options.put('--None--','--None--');
        }
        for (Schema.PicklistEntry pv : picklistValues) {
            options.put(pv.getValue(), pv.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        
        //Get the object type from object name. Here I've used custom object Book.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('Case');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field name. Here I've used custom field Genre__c of Book object.
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('IP_ProductClass__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        return plValues;
    }
}