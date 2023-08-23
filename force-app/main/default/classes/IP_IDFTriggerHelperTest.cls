/*******************************************************************************************************
* 
* @ Name    :   IP_IDFTriggerHelperTest
* @ Purpose :   TestClass for IP_IDFTriggerHelper
* @ Author  :   Ashutosh Kumar
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ashutosh Kumar		        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_IDFTriggerHelperTest {
    
	@isTest
    public static void testCaseInsert(){
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.IP_Product_Type__c = 'PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c = 'Yes';
        cs.IP_Who_Initiated_the_Subject__c = 'Test';
        cs.IP_Reason_for_Working_on_That_Subject__c = 'Test';
        cs.IP_Is_there_Contribution_of_the_Company__c ='Yes';
        cs.IP_Special_Points_to_be_Considered__c = 'Yes';
        cs.IP_Explanation_of_Special_Points__c = 'Test';
        cs.IP_Inventors__c = 'raviteja.vaddi@gmail.com(100%)';
        cs.IP_Fill_Form_or_Upload_IDF__c = 'I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c = '';
        cs.IP_Problem_Solved__c = '';
        cs.IP_Invention_Description__c = '';
        cs.IP_Proveof_Invention_onCompetitorProduct__c = '';
        cs.IP_Use_of_Invention_by_Us__c = '';
        cs.IP_Status__c = 'Draft';
        cs.Status = 'Draft';
        cs.IP_Product_Subcategories__c = 'Armature';
        cs.IP_am_employed_at_SEG_Automotive_Germany__c = true;
        cs.IP_Invention_Part_of_Entrusted_Research__c = 'Yes';
        
        User ipMgr = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = ipMgr.Id;
        
        User prcMember = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = prcMember.Id;
        
        insert cs;
    }
    
    @isTest
    public static void testCaseUpdate(){
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.IP_Product_Type__c = 'PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c = 'Yes';
        cs.IP_Who_Initiated_the_Subject__c = 'Test';
        cs.IP_Reason_for_Working_on_That_Subject__c = 'Test';
        cs.IP_Is_there_Contribution_of_the_Company__c ='Yes';
        cs.IP_Special_Points_to_be_Considered__c = 'Yes';
        cs.IP_Explanation_of_Special_Points__c = 'Test';
        cs.IP_Inventors__c = 'raviteja.vaddi@gmail.com(100%)';
        cs.IP_Fill_Form_or_Upload_IDF__c = 'I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c = '';
        cs.IP_Problem_Solved__c = '';
        cs.IP_Invention_Description__c = '';
        cs.IP_Proveof_Invention_onCompetitorProduct__c = '';
        cs.IP_Use_of_Invention_by_Us__c = '';
        cs.IP_Status__c = 'Draft';
        cs.Status = 'Draft';
        cs.IP_Product_Subcategories__c = 'Armature';
        cs.IP_am_employed_at_SEG_Automotive_Germany__c = true;
        cs.IP_Invention_Part_of_Entrusted_Research__c = 'Yes';
        
        List<User> listIPUsers = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager'];
        List<User> listPRCUsers = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member'];
        
        cs.IP_Manager__c = listIPUsers[2].Id;
        
        User prcMember = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = listPRCUsers[0].Id;
        
        insert cs;
        
        cs.IP_Manager__c = listIPUsers[3].Id;
        cs.IP_PRC_Member__c = listPRCUsers[1].Id;
        update cs;
    }
    
    @isTest
    public static void testSendEmail(){
        List<Case> listCases = new List<Case>();
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.IP_Product_Type__c = 'PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c = 'Yes';
        cs.IP_Who_Initiated_the_Subject__c = 'Test';
        cs.IP_Reason_for_Working_on_That_Subject__c = 'Test';
        cs.IP_Is_there_Contribution_of_the_Company__c ='Yes';
        cs.IP_Special_Points_to_be_Considered__c = 'Yes';
        cs.IP_Explanation_of_Special_Points__c = 'Test';
        cs.IP_Inventors__c = 'raviteja.vaddi@gmail.com(100%)';
        cs.IP_Fill_Form_or_Upload_IDF__c = 'I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c = '';
        cs.IP_Problem_Solved__c = '';
        cs.IP_Invention_Description__c = '';
        cs.IP_Proveof_Invention_onCompetitorProduct__c = '';
        cs.IP_Use_of_Invention_by_Us__c = '';
        cs.IP_Status__c = 'Search';
        cs.Status = 'Draft';
        cs.IP_Product_Subcategories__c = 'Armature';
        cs.IP_am_employed_at_SEG_Automotive_Germany__c = true;
        cs.IP_Invention_Part_of_Entrusted_Research__c = 'Yes';
        cs.IP_Is_Law_Firm_Feedback_Updated__c = false;
        
        User ipMgr = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = ipMgr.Id;
        
        User prcMember = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = prcMember.Id;
        
        insert cs;
        listCases.add(cs);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Header_Picture1';
        cv.PathOnClient = '/Header_Picture1.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        // cv.FileType= 'PNG';
        Insert cv;
        
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
         
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cs.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        cs.IP_Is_Law_Firm_Feedback_Updated__c = true;
        cs.IP_Comments_to_OC__c = 'Testing';
        
        update cs;
        
        //IP_IDFTriggerHelper.sendEmailtoIPManager(listCases);
    }
    
    @isTest
    public static void testUpdateFamilyStatus(){
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
        
        case getIpRight = IP_CreateIPRightController.insertIPRightandPatentFamily(cs.Id , cs);
    }
}