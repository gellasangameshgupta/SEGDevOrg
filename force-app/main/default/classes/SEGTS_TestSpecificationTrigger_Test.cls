@isTest
public class SEGTS_TestSpecificationTrigger_Test {
    static testmethod void testspeci(){
        Test_Specification__c tc=new Test_Specification__c();
        tc.Name='djj';
       insert tc;
        tc.Name ='dkk';
        update tc;
    }
}