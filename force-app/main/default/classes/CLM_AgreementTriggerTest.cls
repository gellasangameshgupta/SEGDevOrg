@isTest
public class CLM_AgreementTriggerTest {
    
    @testSetup
    public static void setUpData(){
        /*CLM_Plant__mdt pl = new CLM_Plant__mdt();
        pl.Label = 'SGCN Changchun';
        pl.Plant_Name__c = 'SGCN Plant Changchun';
        pl.Plant_Code__c = 'E09T / 47D1';
        Pl.Address__c = '130012 Changchun China';   
        plntList.add(pl);*/
        APTS_integration_Allowed__c obj = new APTS_integration_Allowed__c(Name = 'Integration_Allowed', APTS_Allow_Callout__c = true);
        insert obj;
        
        Account supp = new Account();
        supp.name = 'Test Supplier';
        Insert supp;
        
        Account seg = new Account();
        seg.Name = 'SEG Automotive';
        Insert seg;
        
    }
    
    
    @isTest
    public static void HelperPlantDetailsTest(){
        list<CLM_Plant__mdt> plntList = [SELECT Id,Label,Plant_Name__c,Plant_Code__c,Address__c FROM CLM_Plant__mdt LIMIT 1];
        
        list<Apttus__APTS_Agreement__c> agList = new list<Apttus__APTS_Agreement__c>();
        Account supp = [SELECT Id FROM Account WHERE Name = 'Test Supplier' LIMIT 1];
        Account seg = [SELECT Id FROM Account WHERE Name = 'SEG Automotive' LIMIT 1];
        Apttus__APTS_Agreement__c agg = new Apttus__APTS_Agreement__c();
        agg.APTS_Internal_Legal_Entity__c = seg.Id;
        agg.Apttus__Account__c = supp.Id;
        agg.Plant__c= plntList[0].Label;
        agList.add(agg);
        
        Test.startTest();
        insert agList;
        Test.stopTest();
        List<Account> acct = [SELECT Id,CLM_PlantName__c, CLM_PlantCode__c FROM Account where CLM_Agreement__c=:agg.Id];
        system.assertEquals(plntList[0].Plant_Name__c, acct[0].CLM_PlantName__c);
        
    }
}