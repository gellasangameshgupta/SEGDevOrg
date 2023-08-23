/***************************************************************************
    
    Class Name      :CreateNewVersion_Test
    Purpose         :Code coverage for the controller -UpdateStatusValue
    Created By      :RBEI
    Created Date    :Dec 2018

*****************************************************************************/
@isTest
public class UpdateStatusValue_Test {
    public static testMethod void UpdateStatusValue_Test(){
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
       UpdateStatusValue.updateStatusVal(testSpec.id);
        UpdateStatusValue.testSpec(testSpec.id);
    }
}