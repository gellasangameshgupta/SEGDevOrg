/***********************************************************************************
    Class Name      :SEGTS_ctrl_TestDeatilsViewLc_Test
    Purpose         :Code coverage for the controller - SEGTS_ctrl_TestDeatilsViewLc
    Created By      :RBEI
    Created Date    :FEB 2019
***********************************************************************************/
@isTest
public class SEGTS_ctrl_TestDeatilsViewLc_Test {
	public static testMethod void SEGTS_CreateTestDetailsCtrl_Test(){
	List<Test_Specification__c> ListTest = new List<Test_Specification__c>();
        Test_Specification__c testSpec = new Test_Specification__c();
        testSpec.Name = 'Test';
        testSpec.Change_Nr__c = '123456';
        testSpec.Test_Specification__c = 'TestSpec12';
        testSpec.FLC__c = true;
        testSpec.i__c = 00009;
        testSpec.Interface__c = 'Auslaufzeit';
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
        List<SEGTS_ctrl_TestDeatilsViewLc.WrapperBlock> nw = new List<SEGTS_ctrl_TestDeatilsViewLc.WrapperBlock>();
        SEGTS_ctrl_TestDeatilsViewLc.WrapperBlock swe = new SEGTS_ctrl_TestDeatilsViewLc.WrapperBlock();
        swe.blkname = 'TEstBlock';
        swe.l2Id = testSpec.id;
        
        swe.blkorderno = 123;
        swe.resultListInner = ListTest;
        nw.add(swe);
		Test_Specification__c testSpecNew =  [Select id,Name from Test_Specification__c where id =: testSpec.id];
        System.assertEquals(testSpecNew.Name, 'Test'); 
        List<SEGTS_ctrl_TestDeatilsViewLc.WrapperSection> LIstSEW = new List<SEGTS_ctrl_TestDeatilsViewLc.WrapperSection>();
        SEGTS_ctrl_TestDeatilsViewLc.WrapperSection setTest = new SEGTS_ctrl_TestDeatilsViewLc.WrapperSection();
        setTest.secname = 'TEstSection';
        setTest.secorderno = 96417;
        setTest.l1Id = TestSpec1.id;
        LIstSEW.add(setTest);
           SEGTS_ctrl_TestDeatilsViewLc se = new SEGTS_ctrl_TestDeatilsViewLc();
           SEGTS_ctrl_TestDeatilsViewLc.getData(testSpec.id);
        
    }
}