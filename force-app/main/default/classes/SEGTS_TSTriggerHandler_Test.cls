@isTest
public class SEGTS_TSTriggerHandler_Test {
    public static testMethod void testtrigger(){
        
        string aa='dk';
        Set<String> tsName = new Set<String>();
        tsName.add(aa);
        decimal bb=10;
        Set<Decimal> dsdd=new Set<Decimal>();
        dsdd.add(bb);
        List<Test_Specification__c> ls=new List<Test_Specification__c>();
        Test_Specification__c tc=new Test_Specification__c();
        tc.Order_No__c=12;
        tc.name='jdnm';
        for(decimal bg:dsdd){
        tc.Version_No__c=bg;
        }
        tc.HierechyLevel__c='Level 2';
        tc.PV_Number__c='shsk';
        ls.add(tc);
        
        Test_Specification__c tc1=new Test_Specification__c();
        tc1.Order_No__c=12;
         
        tc1.Name='djdj';
       
        for(decimal bg:dsdd){
        tc1.Version_No__c=bg;
        }
        tc.HierechyLevel__c='Level 2';
        tc.PV_Number__c='shsk';
        ls.add(tc1);
        
        insert ls;
        
        
        
        SEGTS_TSTriggerHandler td=new SEGTS_TSTriggerHandler();
        SEGTS_TSTriggerHandler.beforeInsert(ls);
        SEGTS_TSTriggerHandler.dataUpload(ls);
        SEGTS_TSTriggerHandler.buildSectionBlockRelationship(tc1,ls);
    }
    
    public static testMethod void testtrigger1(){
         string aa='dk';
        Set<String> tsName = new Set<String>();
        tsName.add(aa);
        decimal bb=10;
        Set<Decimal> dsdd=new Set<Decimal>();
        dsdd.add(bb);
        List<Test_Specification__c> ls=new List<Test_Specification__c>();
        Test_Specification__c tc=new Test_Specification__c();
        tc.Order_No__c=12;
        tc.name='jdnm';
        for(decimal bg:dsdd){
        tc.Version_No__c=bg;
        }
        tc.HierechyLevel__c='Level 3';
        tc.PV_Number__c='shsk';
        ls.add(tc);
        
        Test_Specification__c tc1=new Test_Specification__c();
        tc1.Order_No__c=12;
         
        tc1.Name='djdj';
       
        for(decimal bg:dsdd){
        tc1.Version_No__c=bg;
        }
        tc.HierechyLevel__c='Level 3';
        tc.PV_Number__c='shsk';
        ls.add(tc1);
        
         SEGTS_TSTriggerHandler.beforeInsert(ls);
        SEGTS_TSTriggerHandler.dataUpload(ls);
        SEGTS_TSTriggerHandler.buildSectionBlockRelationship(tc1,ls);
        
    }
}