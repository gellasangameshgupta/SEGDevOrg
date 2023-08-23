@isTest
public class SEGTS_TestSpecOnDeleteTrigger_Test {
    public static testMethod void SEGTS_TestSpecOnDeleteTrigger_Test(){
	 List<Test_Specification__c> ListTest = new List<Test_Specification__c>();
        Test_Specification__c testSpec = new Test_Specification__c();
        testSpec.Name = 'Test';
        testSpec.Change_Nr__c = '123456';
        testSpec.Test_Specification__c = 'TestSpec';
        testSpec.FLC__c = true;
        testSpec.i__c = 00009;
        testSpec.Status__c = 'Draft';
        testSpec.Char_Curve_1__c = '12345';
        testSpec.SAP_Doc__c = 'PRV';
        testSpec.Starter__c = 'Invalid';
        insert testSpec;
    	ListTest.add(testSpec);
        
        Test_Specification__c testSpec1 = new Test_Specification__c();
        testSpec1.Name = 'Test1';
        testSpec1.Change_Nr__c = '123456';
        testSpec1.Test_Specification__c = 'TestSpec';
        testSpec1.Parent_Test_Specification__c = testSpec.Id;
        testSpec1.FLC__c = true;
        testSpec1.i__c = 00009;
        testSpec1.Status__c = 'Draft';
        testSpec1.Char_Curve_1__c = '12345';
        testSpec1.SAP_Doc__c = 'PRV';
        testSpec1.Starter__c = 'Invalid';
        insert testSpec1;
    	ListTest.add(testSpec1);
        test.startTest();
        List<Test_Specification__c> ListTest1 = new List<Test_Specification__c>();
        ListTest1 = [Select id ,Name,Change_Nr__c,Test_Specification__c,Parent_Test_Specification__c,FLC__c,i__c,Status__c,Char_Curve_1__c
                    ,SAP_Doc__c,Starter__c from Test_Specification__c where id =: testSpec.id];
        	delete ListTest1;
        test.stopTest();
        
       
        //delete testSpec;
        ApexPages.currentPage().getParameters().put('id', testSpec.id);//Pass Id to page
        //SEGTS_TestSpecificationDeleteTrigger TestCreateNew = new SEGTS_TestSpecificationDeleteTrigger();
    }
    
}