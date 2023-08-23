/*******************************************************************************************
    Class Name      :SEGTS_CreateTestDetailsCtrl_Test
    Purpose         :Code coverage for the controller -SEGTS_CreateTestDetailsCtrl
    Created By      :RBEI
    Created Date    :Feb 2019
*******************************************************************************************/
@isTest
public class SEGTS_CreateTestDetailsCtrl_Test {
    public static testMethod void SEGTS_CreateTestDetailsCtrl_Test(){
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
        testSpec.HierechyLevel__c = 'Level 0';
        testSpec.Char_Curve_1__c = '12345';
        testSpec.SAP_Doc__c = 'PRV';
        testSpec.Starter__c = 'Invalid';
        insert testSpec;
        
        Test_Specification__c testSpec1 = new Test_Specification__c();
        testSpec1.Name = 'Test1';
        testSpec1.Change_Nr__c = '123456';
        testSpec1.Test_Specification__c = testSpec.id;
        testSpec1.Test_Section_Header__c = 'TestSection';
        testSpec1.Parent_Test_Specification__c = testSpec.id;
        testSpec1.HierechyLevel__c = 'Level 1';
        testSpec1.Designation__c = 'Expected Result ';
        insert testSpec1;
        
        Test_Specification__c testSpec2 = new Test_Specification__c();
        testSpec2.Name = 'Test2';
        testSpec2.Change_Nr__c = '123456';
        testSpec2.Test_Specification__c = testSpec1.id;
        testSpec2.Parent_Test_Specification__c =testSpec1.id;
        testSpec2.Test_Block_Header__c  = 'TestBlock';
        testSpec2.Designation__c = testSpec1.Designation__c;
        testSpec2.HierechyLevel__c = 'Level 2';
      	insert testSpec2;
        System.debug('testSpec2:::::::'+testSpec2);
        Test_Specification__c testSpec3 = new Test_Specification__c();
        //testSpec3.Name = 'Test3';
        testSpec3.Test_Specification__c = 'TestSpec';
        testSpec3.Parent_Test_Specification__c = testSpec2.id;
       	testSpec3.Remark__c = 'Remarks';
        testSpec3.Size__c = '23';
        testSpec3.Value_Toleran__c = '4';
        testSpec3.Name = testSpec2.Designation__c;
        testSpec3.Designation__c = 'Expected Result ';
        testSpec3.Interface__c = 'Auslaufzeit';
      	insert testSpec3;
        
       	ListTest.add(testSpec);
        ListTest.add(testSpec1);
        ListTest.add(testSpec2);
        ListTest.add(testSpec3);
        
       	Test_Specification__c testSpecNew =  [Select id,Name from Test_Specification__c where id =: testSpec.id];
        System.assertEquals(testSpecNew.Name, 'Test');
        SEGTS_CreateTestDetailsCtrl se = new SEGTS_CreateTestDetailsCtrl();
       
        String myJSON = '{"request":[{"testSectionHeader":"Headline","sortOrder":"1","level2":[{"testBlockHeader":"Block","sortOrder":"1","level3":[{"designation":"Test Condition","size":"P","condition":"=>","volume":"234","unit":"°C","remark":"rt","interfacec":"Kenntemp"}]}]}]}';
        SEGTS_CreateTestDetailsCtrl.SaveTestDeatils(myJSON , testSpec.id);

        se.getDesignationOptionList();
        se.getSizeOptionList();
        se.getConditionOptionList();
        se.getUnitOptionList();
        se.getInterfaceOptionList();
    
	}
}