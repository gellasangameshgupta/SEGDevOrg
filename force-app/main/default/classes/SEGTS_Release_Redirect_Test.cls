/***************************************************************************
    Class Name      :SEGTS_Release_Redirect_Test
    Purpose         :Code coverage for the controller -Release_Generate_CTRL
    Created By      :RBEI
    Created Date    :Dec 2018
*****************************************************************************/
@isTest(SeeAllData=true)
public class SEGTS_Release_Redirect_Test {
    public static testMethod void Release_Generate_Test(){
        Test_Specification__c testSpec = new Test_Specification__c();
        testSpec.Name = 'Test';
        testSpec.Change_Nr__c = '123456';
        testSpec.Test_Specification__c = 'TestSpec';
        testSpec.FLC__c = true;
        testSpec.i__c = 00009;
        testSpec.Char_Curve_1__c = '12345';
        testSpec.SAP_Doc__c = 'PRV';
        insert testSpec;
        
       // Instantiate VisualForce Page
        
        PageReference pgRef = Page.SEGTS_Release_Redirect_Page; //Create Page Reference - 'Release_Generate_PDF' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id', testSpec.id);//Pass Id to page
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(testSpec);
        SEGTS_Release_Redirect_CTRL releaseGenerate = new SEGTS_Release_Redirect_CTRL(sc);
        releaseGenerate.OK();
    }
}