/*******************************************************************************************************
* 
* @ Name    :   IP_RequestforInformationController
* @ Purpose :   Controller for RequestforInformation Component
* @ Author  :   Ch V Lakshminarayana
* @ Test Class Name : IP_RequestforInformationControllerTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
public with sharing class IP_RequestforInformationController {

    
    @auraEnabled
    public static void updateRFI(String invDisclosureId, String Comments){
        if(String.isNotBlank(invDisclosureId)){
            Case cs = new Case(Id=invDisclosureId);
            //String encryptComments = String.isNotBlank(Comments)?InventionDisclosureController.encryptData(Comments):'';
            cs.IP_Comment_on_RFI__c = Comments;
            cs.IP_Status__c = 'Further Info Needed';
            cs.IP_Date_of_RFI__c = system.today();
            try {
                    database.update(cs,false);
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
            //database.update(cs,false);
        }
    }
    
    @auraEnabled
    public static String fetchRFI(String invDisclosureId){
        if(String.isNotBlank(invDisclosureId)){
            Case cs = [Select Id, IP_Comment_on_RFI__c from Case where Id=:invDisclosureId];
            //String decryptComments = String.isNotBlank(cs.Comment_on_RFI__c)?InventionDisclosureController.decryptData(cs.Comment_on_RFI__c):'';
            return cs.IP_Comment_on_RFI__c;
        }
        return null;
    }
    
    @auraEnabled
    public static void updatesearch(String invDisclosureId, String Comments, String searchid){
        if(String.isNotBlank(invDisclosureId)){
            Case cs = new Case(Id=invDisclosureId);
            cs.IP_Search_Comments__c = Comments;
            cs.IP_Law_Firm__c = searchid;
            cs.IP_Date_Search_Requested__c = system.today();
            cs.IP_Status__c = 'Legal Evaluation';
            try {
                    database.update(cs,false);
                } catch(Exception e) {
                    IFv2_ExceptionUtilitiesController.exceptionHandler(e);
                }
            //database.update(cs,false);
        }
    }
    
    @auraEnabled
    public static Case fetchsearch(String invDisclosureId){
        if(String.isNotBlank(invDisclosureId)){
            Case cs = [Select Id, IP_Search_Comments__c, IP_Law_Firm__c from Case where Id=:invDisclosureId];
            return cs;
        }
        return null;
    }
}