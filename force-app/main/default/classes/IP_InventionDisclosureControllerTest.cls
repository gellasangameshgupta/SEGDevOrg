/*******************************************************************************************************
* 
* @ Name    :   IP_InventionDisclosureControllerTest
* @ Purpose :   Test Class for IP_InventionDisclosureController
* @ Author  :   Ch V Lakshminarayana
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest(SeeAllData=true)
public class IP_InventionDisclosureControllerTest {
    
    @isTest
    public static void testInvention(){
        //Creating Case
        case cs=new case();
        cs.Subject='P00-001';
        cs.IP_Product_Type__c='PC Starter';
        cs.IP_Invention_Created_as_Part_of_Work__c='Yes';
        cs.IP_Who_Initiated_the_Subject__c='Test';
        cs.IP_Reason_for_Working_on_That_Subject__c='Test';
        cs.IP_Is_there_Contribution_of_the_Company__c  ='Yes';
        cs.IP_Special_Points_to_be_Considered__c='Yes';
        cs.IP_Explanation_of_Special_Points__c='Test';
        
        cs.IP_Fill_Form_or_Upload_IDF__c='I have summarized my invention in a document and would like to upload it below';
        cs.IP_Prior_Art__c='';
        cs.IP_Problem_Solved__c='';
        cs.IP_Invention_Description__c='';
        cs.IP_Use_of_Invention_by_Us__c='';
        cs.Status=  'Submitted for Review';
        cs.IP_Status__c = 'Submitted for Review';
        cs.IP_Product_Subcategories__c='Armature';
        cs.IP_Invention_Part_of_Entrusted_Research__c='Yes';
        
        User user1 = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'IP Manager' limit 1];
        cs.IP_Manager__c = user1.Id;
        
        User user2 = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'PRC Member' limit 1];
        cs.IP_PRC_Member__c = user2.Id;
        
        user  invuser = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'Inventor' limit 1];
        cs.IP_Inventors__c=invuser.Id;
        cs.IP_Inventors_Technical__c=invuser.Id+':100';
        
        Id recordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Invention Disclosure').getRecordTypeId();
        cs.RecordtypeId= recordTypeId ;
        
        List<string> newList =new List<string>();
        string userId=invuser.Id;
        newList.add(userId);
        
        string res=IP_InventionDisclosureController.createInventionDisclosure(cs, JSON.serialize(newList));
        
        case insertedCs=[select Status from case where id=:res];
        system.assertEquals(cs.Status, insertedCs.Status);
        
        cs.Subject='Test Update';
        test.startTest();
        string id=IP_InventionDisclosureController.updateInventionDisclosure(cs, JSON.serialize(newList));
        case updatedCs=[select Subject from case where id=:id];
        system.assertEquals(cs.Subject, updatedCs.Subject);
        
        case getCase=IP_InventionDisclosureController.getInventionDisclosure(id);
        system.assertEquals(cs.IP_Invention_Created_as_Part_of_Work__c, getCase.IP_Invention_Created_as_Part_of_Work__c);
        
        list<case> cases=IP_InventionDisclosureController.fetchInventionDisclosures();
        IP_InventionDisclosureController.getProductTypeOptions();
        IP_InventionDisclosureController.fetchLookUpValues( );
        IP_InventionDisclosureController.getAttachmentCount(id);
        IP_InventionDisclosureController.fetchInventors(id);
        test.stopTest();
    }
}