/***************************************************************************
    Class Name      :SEGTS_Release_Generate_Test
    Purpose         :Code coverage for the controller -Release_Generate_CTRL
    Created By      :RBEI
    Created Date    :Dec 2018
*****************************************************************************/
@isTest(SeeAllData=true)
public class SEGTS_Release_Generate_Test {
	 public static testMethod void SEGTS_Release_Generate_Test(){
        List<Test_Specification__c> ls=new List<Test_Specification__c>();
        Test_Specification__c tc=new Test_Specification__c();
        tc.Order_No__c=12;
        tc.Name='bosche Paraent';
        //ls.add(tc);
        insert tc;
        Test_Specification__c tc1=new Test_Specification__c();
        tc1.Order_No__c=12;
        tc1.Name='bosche Section';
        tc1.Parent_Test_Specification__c = tc.Id;
        //ls.add(tc1);
        
        insert tc1;
        
        Test_Specification__c tc2=new Test_Specification__c();
        tc2.Order_No__c=12;
        tc2.Name='bosche Block';
        tc2.Parent_Test_Specification__c = tc1.Id;
        //ls.add(tc1);
        
        insert tc2;
        Test_Specification__c tc3=new Test_Specification__c();
        tc3.Order_No__c=12;
        tc3.Name='bosche Result';
        tc3.Parent_Test_Specification__c = tc2.Id;
        //ls.add(tc1);
        
        insert tc3;

        ls.add(tc1);
        ls.add(tc);
       // Instantiate VisualForce Page
        List<SEGTS_Release_Generate_CTRL.WrapperSection> ws=new List<SEGTS_Release_Generate_CTRL.WrapperSection>();
        PageReference pgRef = Page.SEGTS_Release_Generate_PDF; //Create Page Reference - 'Release_Generate_PDF' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('ID',tc1.id);
        ApexPages.StandardController sc=new ApexPages.StandardController(tc1);
        SEGTS_Release_Generate_CTRL releaseGenerate = new SEGTS_Release_Generate_CTRL(sc);
    }
}