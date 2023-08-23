/*******************************************************************************************************
* 
* @ Name    :   IP_CreateChildIPRightControllerTest
* @ Purpose :   TestClass for IP_CreateChildIPRightController
* @ Author  :   Ch V Lakshminarayana
*
*   Date            |  Developer Name               |  Version      |  Changes
* ===================================================================================================================
*   06-04-2021      |  Ch V Lakshminarayana	        |  1.0          |  Initial Version
*********************************************************************************************************************/
@isTest
public class IP_CreateChildIPRightControllerTest {
    
    @isTest
    public static  void createChildIpRightTest(){
        User user1 = new User(Alias = 'standt', 
                              Email = 'UserFortest@test.com', 
                              EmailEncodingKey = 'UTF-8', 
                              LastName = 'Testing', 
                              LanguageLocaleKey = 'en_US', 
                              LocaleSidKey = 'en_US', 
                              TimeZoneSidKey = 'Europe/Berlin',
                              UserName = 'UserFortestxyz@test.com',
                              ProfileId = [SELECT Id FROM Profile WHERE name = 'SG Standard User' limit 1 ].Id);
        insert user1;
        
        User law = [SELECT Id, name FROM User WHERE IP_InsightIP_Role__c = 'Law Firm' limit 1];
        
        case vs= new case();
        vs.Subject='test ip rght';
        vs.IP_Country__c='	KE';
        vs.IP_Type_of_Right__c='Patent';
        vs.IP_Right_ID__c='P00661-KE';
        //vs.ParentId=ps.Id;
        //vs.IP_Patent_Family__c=pf.Id;
        //vs.IP_InventionName__c=cs.Id;
        vs.IP_Right_Status__c='	Not Filed';
        vs.IP_All_Inventors__c='test Inventor(100%)';
        vs.IP_Relationship_to_Parent__c='From Provisional';
        vs.IP_Law_Firm_Reference__c='test method';
        vs.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        vs.Status=  'Approved for Filing';
        vs.IP_Status__c = 'Approved for Filing';
        vs.IP_Law_Firm__c= law.Id;
        vs.IP_Law_Firm_Text__c='Law Firm';
        vs.IP_Product_Type__c='PC Starter';
        vs.IP_Product_Subcategories__c='Armature';
        Id ipRightRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IP Right').getRecordTypeId();
        vs.RecordTypeId= ipRightRecType;
        
        insert vs;
        
        List<Case> childCaseList= new List<Case>();
        
        Case child = new Case();
        child.Subject='test ip rght';
        child.IP_Country__c='	KE';
        child.IP_Type_of_Right__c='Patent';
        child.IP_Right_ID__c='P00661-DE';
        //vs.ParentId=ps.Id;
        //vs.IP_Patent_Family__c=pf.Id;
        //vs.IP_InventionName__c=cs.Id;
        child.IP_Right_Status__c='	Not Filed';
        child.IP_All_Inventors__c='test Inventor(100%)';
        child.IP_Relationship_to_Parent__c='From Provisional';
        child.IP_Law_Firm_Reference__c='test method';
        child.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        child.Status=  'Approved for Filing';
        child.IP_Status__c = 'Approved for Filing';
        child.IP_Law_Firm__c= law.Id;
        child.IP_Law_Firm_Text__c='Law Firm';
        child.IP_Product_Type__c='PC Starter';
        child.IP_Product_Subcategories__c='Armature';
        child.RecordTypeId= ipRightRecType;
        
        childCaseList.add(child);
        
        Case family = new Case();
        family.Subject='test ip rght';
        family.IP_Country__c='	KE';
        family.IP_Type_of_Right__c='Patent';
        family.IP_Right_ID__c='P00661-DE';
        //vs.ParentId=ps.Id;
        //vs.IP_Patent_Family__c=pf.Id;
        //vs.IP_InventionName__c=cs.Id;
        family.IP_Right_Status__c='	Not Filed';
        family.IP_All_Inventors__c='test Inventor(100%)';
        family.IP_Relationship_to_Parent__c='From Provisional';
        family.IP_Law_Firm_Reference__c='test method';
        family.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        family.Status=  'Approved for Filing';
        family.IP_Status__c = 'Approved for Filing';
        family.IP_Law_Firm__c= law.Id;
        family.IP_Law_Firm_Text__c='Law Firm';
        family.IP_Product_Type__c='PC Starter';
        family.IP_Product_Subcategories__c='Armature';
        Id familyRightRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Patent Family').getRecordTypeId();
        family.RecordTypeId= familyRightRecType;
        
        insert family;
        
        Case ipRight = new Case();
        ipRight.Subject='test ip rght';
        ipRight.IP_Country__c='	KE';
        ipRight.IP_Type_of_Right__c='Patent';
        ipRight.IP_Right_ID__c='P00661-DE';
        //vs.ParentId=ps.Id;
        ipRight.IP_Patent_Family__c=family.Id;
        //vs.IP_InventionName__c=cs.Id;
        ipRight.IP_Right_Status__c='	Not Filed';
        ipRight.IP_All_Inventors__c='test Inventor(100%)';
        ipRight.IP_Relationship_to_Parent__c='From Provisional';
        ipRight.IP_Law_Firm_Reference__c='test method';
        ipRight.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        ipRight.Status=  'Approved for Filing';
        ipRight.IP_Status__c = 'Approved for Filing';
        ipRight.IP_Law_Firm__c= law.Id;
        ipRight.IP_Law_Firm_Text__c='Law Firm';
        ipRight.IP_Product_Type__c='PC Starter';
        ipRight.IP_Product_Subcategories__c='Armature';
        ipRight.RecordTypeId = ipRightRecType;
        
        insert ipRight;
        
        Case ipRight2 = new Case();
        ipRight2.Subject='test ip rght2';
        ipRight2.IP_Country__c='	KE';
        ipRight2.IP_Type_of_Right__c='Patent';
        ipRight2.IP_Right_ID__c='P00662-CN';
        ipRight2.ParentId=ipRight.Id;
        ipRight2.IP_Patent_Family__c=family.Id;
        //vs.IP_InventionName__c=cs.Id;
        ipRight2.IP_Right_Status__c='	Not Filed';
        ipRight2.IP_All_Inventors__c='test Inventor(100%)';
        ipRight2.IP_Relationship_to_Parent__c='From Provisional';
        ipRight2.IP_Law_Firm_Reference__c='test method';
        ipRight2.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        ipRight2.Status=  'Approved for Filing';
        ipRight2.IP_Status__c = 'Approved for Filing';
        ipRight2.IP_Law_Firm__c= law.Id;
        ipRight2.IP_Law_Firm_Text__c='Law Firm';
        ipRight2.IP_Product_Type__c='PC Starter';
        ipRight2.IP_Product_Subcategories__c='Armature';
        ipRight2.RecordTypeId = ipRightRecType;
        
        insert ipRight2;
        
        Case ipRight3 = new Case();
        ipRight3.Subject='test ip rght2';
        ipRight3.IP_Country__c='	KE';
        ipRight3.IP_Type_of_Right__c='Patent';
        ipRight3.IP_Right_ID__c='P00662-CN';
        ipRight3.ParentId=ipRight2.Id;
        ipRight3.IP_Patent_Family__c=family.Id;
        ipRight3.IP_Right_Status__c='	Not Filed';
        ipRight3.IP_All_Inventors__c='test Inventor(100%)';
        ipRight3.IP_Relationship_to_Parent__c='From Provisional';
        ipRight3.IP_Law_Firm_Reference__c='test method';
        ipRight3.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        ipRight3.Status=  'Approved for Filing';
        ipRight3.IP_Status__c = 'Approved for Filing';
        ipRight3.IP_Law_Firm__c= law.Id;
        ipRight3.IP_Law_Firm_Text__c='Law Firm';
        ipRight3.IP_Product_Type__c='PC Starter';
        ipRight3.IP_Product_Subcategories__c='Armature';
        ipRight3.RecordTypeId = ipRightRecType;
        
        insert ipRight3;
        
        Case ipRight4 = new Case();
        ipRight4.Subject='test ip rght2';
        ipRight4.IP_Country__c='	KE';
        ipRight4.IP_Type_of_Right__c='Patent';
        ipRight4.IP_Right_ID__c='P00662-CN';
        ipRight4.ParentId=ipRight3.Id;
        ipRight4.IP_Patent_Family__c=family.Id;
        ipRight4.IP_Right_Status__c='	Not Filed';
        ipRight4.IP_All_Inventors__c='test Inventor(100%)';
        ipRight4.IP_Relationship_to_Parent__c='From Provisional';
        ipRight4.IP_Law_Firm_Reference__c='test method';
        ipRight4.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        ipRight4.Status=  'Approved for Filing';
        ipRight4.IP_Status__c = 'Approved for Filing';
        ipRight4.IP_Law_Firm__c= law.Id;
        ipRight4.IP_Law_Firm_Text__c='Law Firm';
        ipRight4.IP_Product_Type__c='PC Starter';
        ipRight4.IP_Product_Subcategories__c='Armature';
        ipRight4.RecordTypeId = ipRightRecType;
        
        insert ipRight4;
        
        Case ipRight5 = new Case();
        ipRight5.Subject='test ip rght2';
        ipRight5.IP_Country__c='	KE';
        ipRight5.IP_Type_of_Right__c='Patent';
        ipRight5.IP_Right_ID__c='P00662-CN';
        ipRight5.ParentId=ipRight4.Id;
        ipRight5.IP_Patent_Family__c=family.Id;
        ipRight5.IP_Right_Status__c='	Not Filed';
        ipRight5.IP_All_Inventors__c='test Inventor(100%)';
        ipRight5.IP_Relationship_to_Parent__c='From Provisional';
        ipRight5.IP_Law_Firm_Reference__c='test method';
        ipRight5.IP_ProductClass__c='10GEAM(Highline Generator Segment AM)';
        ipRight5.Status=  'Approved for Filing';
        ipRight5.IP_Status__c = 'Approved for Filing';
        ipRight5.IP_Law_Firm__c= law.Id;
        ipRight5.IP_Law_Firm_Text__c='Law Firm';
        ipRight5.IP_Product_Type__c='PC Starter';
        ipRight5.IP_Product_Subcategories__c='Armature';
        ipRight5.RecordTypeId = ipRightRecType;
        
        insert ipRight5;
        
        List<String> strList = new List<String>();
        strList.add('Fm0N9E000000Cezc');
        
        test.startTest();
        IP_CreateChildIPRightController.getIPRight(vs.Id);
        IP_CreateChildIPRightController.getPicklistvalues('Case','IP_Country__c',null);
        IP_CreateChildIPRightController.getAppendValue('Divisional');
        IP_CreateChildIPRightController.fetchLookUpValues('IN','IP_Country__mdt',strList,vs.Id);
        IP_CreateChildIPRightController.fetchLookUpValues('Test','User',null,vs.Id);
        IP_CreateChildIPRightController.getFamilyTree(family.Id);
        IP_CreateChildIPRightController.getFamilyTree(ipRight.Id);
        IP_CreateChildIPRightController.getInsertChildIPRight(vs.Id,childCaseList);
        test.stopTest();
    }
}