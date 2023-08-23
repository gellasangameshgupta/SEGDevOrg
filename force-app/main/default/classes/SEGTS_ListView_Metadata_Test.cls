/************************************************************************************************
    Class Name      :SEGTS_ListView_Metadata_Test
    Purpose         :Code coverage for the controller -SEGTS_ListView_MetaData_CTRL
    Created By      :RBEI
    Created Date    :Dec 2018
*************************************************************************************************/
@isTest(seeAllData=true)
public class SEGTS_ListView_Metadata_Test {
    public static testMethod void SEGTS_ListView_Metadata_Test(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Test.setMock(HttpCalloutMock.class, new ListView_Test_Mockup());
        List<Test_Specification__c> testSpecList = new List<Test_Specification__c>();
        Test_Specification__c test = new Test_Specification__c();
        test.Name = 'Test';
        test.Change_Nr__c = '123456';
        test.Test_Specification__c = 'TestSpec';
        test.FLC__c = true;
        test.i__c = 00009;
        test.Char_Curve_1__c = '12345';
        test.SAP_Doc__c = 'PRV';
        test.Starter__c = 'Invalid';
        testSpecList.add(test);       
        list<Test_Specification__c> ler =new list<Test_Specification__c>();
         ApexPages.StandardSetController standard = new  ApexPages.StandardSetController(ler);
         SEGTS_ListView_MetaData_CTRL listview = new SEGTS_ListView_MetaData_CTRL(standard);
         listview.Today = Date.today();
         //listview.listTestSpec= testSpecList;
        }
}