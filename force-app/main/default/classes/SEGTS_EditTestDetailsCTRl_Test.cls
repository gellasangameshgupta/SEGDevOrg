/*********************************************************************************
    Class Name      :SEGTS_EditTestDetailsCTRl_Test
    Purpose         :Code coverage for the controller - SEGTS_EditTestDetailsCTRl
    Created By      :RBEI
    Created Date    :FEB 2019
*********************************************************************************/
@isTest
public class SEGTS_EditTestDetailsCTRl_Test {
    public static testMethod void SEGTS_EditTestDetailsCTRl_Test(){
    List<Test_Specification__c> ListTest = new List<Test_Specification__c>();
        Test_Specification__c testSpec = new Test_Specification__c();
        testSpec.Name = 'Test';
        testSpec.Change_Nr__c = '123456';
        testSpec.Test_Specification__c = 'TestSpec12';
        testSpec.FLC__c = true;
        testSpec.i__c = 00009;
        testSpec.Interface__c = 'Auslaufzeit';
        testSpec.Interface__c = ' ';
        testSpec.Designation__c ='Test Condition';
        testSpec.HierechyLevel__c = 'Level 1';
        testSpec.Char_Curve_1__c = '12345';
        testSpec.SAP_Doc__c = 'PRV';
        testSpec.Starter__c = 'Invalid';
        insert testSpec;
        
        Test_Specification__c testSpec1 = new Test_Specification__c();
        testSpec1.Name = 'Test1';
        testSpec1.Change_Nr__c = '123456';
        testSpec1.Test_Specification__c = testSpec.Test_Specification__c;
        testSpec1.Test_Block_Header__c = testSpec.id;
        testSpec1.Test_Section_Header__c = testSpec.id;
        testSpec1.Name = testSpec.id;
        testSpec1.Parent_Test_Specification__c = testSpec.id;
        testSpec1.HierechyLevel__c = 'Level 2';
        testSpec1.Designation__c = 'Expected Result ';
        testSpec1.FLC__c = true;
        testSpec1.i__c = 00009;
        testSpec1.Char_Curve_1__c = '12345';
        testSpec1.Interface__c = 'Feld12A';
        testSpec1.Test_Specification__c = 'test';
        testSpec1.SAP_Doc__c = 'PRV';
        testSpec1.Starter__c = 'Invalid';
        insert testSpec1;
        
        Test_Specification__c testSpec2 = new Test_Specification__c();
        testSpec2.Name = 'Test1';
        testSpec2.Change_Nr__c = '123456';
        testSpec2.Test_Specification__c = testSpec.Test_Specification__c;
        testSpec2.Test_Block_Header__c = testSpec.id;
        testSpec2.Test_Section_Header__c = testSpec.id;
        testSpec2.Name = testSpec.id;
        testSpec2.Parent_Test_Specification__c = testSpec1.id;
        testSpec2.HierechyLevel__c = 'Level 2';
        testSpec2.Designation__c = 'Expected Result ';
        
        insert testSpec2;
       
       
        ListTest.add(testSpec);
        ListTest.add(testSpec1);
        ListTest.add(testSpec2);
        List<SEGTS_EditTestDetailsCtrl.WrapperSection> nw = new List<SEGTS_EditTestDetailsCtrl.WrapperSection>();
        SEGTS_EditTestDetailsCtrl.WrapperSection swe = new SEGTS_EditTestDetailsCtrl.WrapperSection();
        swe.l1Id = testSpec.id;
        nw.add(swe);
        Test_Specification__c testSpecNew =  [Select id,Name from Test_Specification__c where id =: testSpec.id];
        System.assertEquals(testSpecNew.Name, 'Test'); 
        List<SEGTS_EditTestDetailsCtrl.WrapperSection> LIstSEW = new List<SEGTS_EditTestDetailsCtrl.WrapperSection>();
        /*SEGTS_EditTestDetailsCtrl.WrapperSection setTest = new SEGTS_EditTestDetailsCtrl.WrapperSection();
        setTest.secname = 'TEstSection';
        setTest.secorderno = 96417;
        setTest.l1Id = TestSpec1.id;*/
        //LIstSEW.add(setTest);
           SEGTS_EditTestDetailsCtrl se = new SEGTS_EditTestDetailsCtrl();
        String myJSON = '{"request":[{"testSectionHeader":"Headline","sortOrder":"1","level2":[{"testBlockHeader":"Block","sortOrder":"1","level3":[{"designation":"Test Condition","size":"P","condition":"=>","volume":"234","unit":"°C","remark":"rt","interfacec":"Kenntemp"}]}]}]}';
        SEGTS_EditTestDetailsCtrl.SaveTestDeatils(myJSON , testSpec.id);
        se.getDesignationOptionList();
        se.getSizeOptionList();
        se.getConditionOptionList();
        se.getUnitOptionList();
        se.getInterfaceOptionList();
        
    }
}