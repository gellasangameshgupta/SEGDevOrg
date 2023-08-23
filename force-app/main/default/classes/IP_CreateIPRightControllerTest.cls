/*******************************************************************************************************
* 
* @ Name    :   IP_CreateIPRightControllerTest
* @ Purpose :   Test class for IP_CreateIPRightController
* @ Author  :   Ch V Lakshminarayana
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_CreateIPRightControllerTest {
    @isTest
    public static void createIpRight(){
        list<case> listofCases=new list<case>();
        case cs=new case();
        cs.Subject='Test';
        cs.IP_Product_Type__c='PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c='Yes';
        cs.IP_Who_Initiated_the_Subject__c='Test';
        cs.IP_Reason_for_Working_on_That_Subject__c='Test';
        cs.IP_Is_there_Contribution_of_the_Company__c	='Yes';
        cs.IP_Special_Points_to_be_Considered__c='Yes';
        cs.IP_Explanation_of_Special_Points__c='Test';
        cs.IP_Inventors__c='raviteja.vaddi@gmail.com(100%)';
        cs.IP_Fill_Form_or_Upload_IDF__c='I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c='';
        cs.IP_Problem_Solved__c='';
        cs.IP_Invention_Description__c='';
        cs.IP_Proveof_Invention_onCompetitorProduct__c='';
        cs.IP_Use_of_Invention_by_Us__c='';
        cs.IP_Status__c='Approved for Filing';
        cs.Status = 'Approved for Filing';
        cs.IP_Product_Subcategories__c='Armature';
        cs.IP_am_employed_at_SEG_Automotive_Germany__c=true;
        cs.IP_Invention_Part_of_Entrusted_Research__c='Yes';
        cs.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        Id idfRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Invention Disclosure').getRecordTypeId();
        cs.RecordTypeId = idfRecType;
        
        User p = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = p.Id;
        User u = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = u.Id;
        
        insert cs;
        
        test.startTest();
        case getIpRight = IP_CreateIPRightController.insertIPRightandPatentFamily(cs.Id , cs);
        List<Case> ipRightUpdateReturn= IP_CreateIPRightController.updateIPRight(cs.Id, getIpRight.Id);
        case returnInvention =IP_CreateIPRightController.getInvention(cs.Id);
        //string objName= 'case';
        List < sObject > listReturn=IP_CreateIPRightController.fetchLookUpValues(getIpRight.Id,'Case');
        Boolean value = False;
        Map<String, String> returnOptions=IP_CreateIPRightController.getPicklistvalues('Case', 'IP_ProductClass__c',value );
        List<String> plValuesReturn=IP_CreateIPRightController.getPiklistValues();
        test.stopTest();
    }
}