/***************************************************************************
    Class Name      :SEGTS_Print_TestSpec_Back_Test
    Purpose         :Code coverage for the controller -SEGTS_Print_TestSpec_Back_CTRL
    Created By      :RBEI
    Created Date    :Dec 2018
*****************************************************************************/
@isTest
public class SEGTS_Print_TestSpec_Back_Test {
	public static testMethod void SEGTS_Print_TestSpec_Bacl_Test(){
        Test_Specification__c testSpec = new Test_Specification__c();
        testSpec.Name = 'Test';
        testSpec.Change_Nr__c = '123456';
        testSpec.Test_Specification__c = 'TestSpec';
        testSpec.FLC__c = true;
        testSpec.i__c = 00009;
        testSpec.Char_Curve_1__c = '12345';
        testSpec.SAP_Doc__c = 'PRV';
        testSpec.Starter__c = 'Invalid';
        insert testSpec;
        
       // Instantiate VisualForce Page
        PageReference pgRef = Page.SEGTS_Print_TestSpec_Page; //Create Page Reference - 'Test_Back_Page' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id', testSpec.id);//Pass Id to page
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testSpec);
        SEGTS_Print_TestSpec_Back_CTRL TestBack = new SEGTS_Print_TestSpec_Back_CTRL(sc);
        TestBack.Back();
    }
}