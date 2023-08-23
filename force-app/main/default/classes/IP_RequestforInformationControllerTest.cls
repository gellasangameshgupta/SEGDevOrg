/*******************************************************************************************************
* 
* @ Name    :   IP_RequestforInformationControllerTest
* @ Purpose :   TestClass for IP_RequestforInformationController
* @ Author  :   Ch V Lakshminarayana
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_RequestforInformationControllerTest {
    
    @isTest
    public static void testRequest(){
        
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
        cs.IP_Status__c='Draft';
        cs.Status = 'Draft';
        cs.IP_Product_Subcategories__c='Armature';
        cs.IP_am_employed_at_SEG_Automotive_Germany__c=true;
        cs.IP_Invention_Part_of_Entrusted_Research__c='Yes';
        //insert cs;
        User p = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = p.Id;
        User u = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = u.Id;
        insert cs;
        
        IP_RequestforInformationController.updateRFI(cs.Id,'Test Comments');
        case chkupdateRFI=[select IP_Comment_on_RFI__c,IP_Status__c from case where id=:cs.Id];
        system.assertEquals('Test Comments',chkupdateRFI.IP_Comment_on_RFI__c);
        IP_RequestforInformationController.fetchRFI(cs.Id);
        
        
        User q = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'Law Firm' limit 1];
        IP_RequestforInformationController.updatesearch(cs.Id,'search Comments',q.Id);
        case chkupdatesearch=[select IP_Search_Comments__c,IP_Law_Firm__c,IP_Status__c from case where id=:cs.Id];
        system.assertEquals('search Comments', chkupdatesearch.IP_Search_Comments__c);
        case chkCase=IP_RequestforInformationController.fetchsearch(cs.Id);
        system.assertEquals(q.Id, chkCase.IP_Law_Firm__c);
    }
}