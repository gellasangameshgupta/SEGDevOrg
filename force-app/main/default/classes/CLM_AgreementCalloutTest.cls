@isTest
public class CLM_AgreementCalloutTest {
    
    public class CLM_AgreementCalloutMock implements HttpCalloutMock{
        public boolean isSuccess;
        
        public CLM_AgreementCalloutMock(Boolean success){
            this.isSuccess = success;
        }
        
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            if(isSuccess){
                res.setStatus('SUCCESS');
                res.setStatusCode(200);
                res.setBody('{"message":"","items":["1:created"]}');
                res.setHeader('Content-Type', 'application/json');
            }
            else{
                res.setStatus('ERROR');
                res.setStatusCode(500);
                res.setBody('{"message":"Internal Server Error","items":[]}');
                res.setHeader('Content-Type', 'application/json');
            }
            return res;
        }
    }
    
    @testSetup
    public static void setupData(){
        
        APTS_integration_Allowed__c intAllow = new APTS_integration_Allowed__c();
        intAllow.Name = 'Integration_Allowed';
        intAllow.APTS_Allow_Callout__c = true;
        insert intAllow;
              
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Supplier').getRecordTypeId();
        Account accObj = new Account(
            RecordTypeId = recordTypeId,
            External_Id__c = '97404508',
            Name = 'HunanLRNeoEcoTechnologies',
            IFv2_Country__c = 'India',
            BillingCity = 'Hyd',
            BillingCountry = 'India',
            IFv2_SupplierClassification__c = 'General'
        );
        insert accObj;
        
        Id CorporateAgreementRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('APTS_Corporate_Agreement').getRecordTypeId();
        
        Apttus__APTS_Agreement__c agree = new Apttus__APTS_Agreement__c();
        agree.RecordTypeId = CorporateAgreementRecordTypeId;
        agree.Apttus__Status_Category__c = 'In Effect';
        agree.Apttus__Status__c = 'Activated';
        agree.Apttus__Account__c = accObj.Id;
        agree.Apttus__Contract_Start_Date__c = System.today();
        agree.OwnerId = UserInfo.getUserId();
        agree.APTS_BufferStockInWorkingDays__c = 10;
        insert agree;
        
        system.debug([SELECT Id,Name,Owner.Name FROM Apttus__APTS_Agreement__c WHERE Id = :agree.Id]);
        
        
    }
    @isTest
    public static void testBatchSuccess(){
        test.setMock(HttpCalloutMock.class, new CLM_AgreementCalloutTest.CLM_AgreementCalloutMock(true));
        Test.startTest();
        System.schedule('JAGGAER Sync', '0 0 23 * * ?' , new CLM_AgreementCalloutBatch());
        Test.stopTest();
     }
    
     @isTest
    public static void testBatchFailure(){
        test.setMock(HttpCalloutMock.class, new CLM_AgreementCalloutTest.CLM_AgreementCalloutMock(false));
        Test.startTest();
        System.schedule('JAGGAER Sync', '0 0 23 * * ?' , new CLM_AgreementCalloutBatch());
        Test.stopTest();
    }
    
}