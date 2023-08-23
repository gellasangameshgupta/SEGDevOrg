/*******************************************************************************************************
* 
* @ Name    :   IP_CustomLookUpControllerTest
* @ Purpose :   Test class for IP_CustomLookUpController
* @ Author  :   Debasmita Rawooth
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Debasmita Rawooth	        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_CustomLookUpControllerTest {
	@isTest
    public static void testCustomLookup(){
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
        
        //cs.IP_IDFNumber__c='IDF-00562';
        //insert cs;
        User p = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = p.Id;
        User u = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = u.Id;
        
        insert cs;
        
        List<User> lstUsers = [Select Id,Name,Email from User Limit 1];
        IP_CustomLookUpController.fetchLookUpValues('Test','User',lstUsers);
    }
}