/**
* @description Used to push Agreement related data to Jagger
* @createdDate Jul 26, 2022
*/
public with sharing class CLM_AgreementCalloutUtility extends CLM_CalloutUtility{
    
    private static final String USERNAME = System.Label.Jagger_Username;
    private static final String PASSWORD = System.Label.Jagger_Password;
    private static final String TOKEN = System.Label.Jagger_Token;
    private static final String UPSERT_FAILURE_EMAIL = System.Label.Jagger_SupplierUpsertFailureEmail;
    private static final String BASE_URL = 'https://app11.jaggaer.com/api/v1';
    public static final String PUT_AGREEMENTS_API = '/tables/seg_clm';
    
    //   @TestVisible
    //  public static Boolean doNotRun = false;
    
    public void putAgreements(List<Apttus__APTS_Agreement__c> objList){
        String endPoint = BASE_URL + PUT_AGREEMENTS_API;
        System.debug('Endpoint:'+endPoint);
        
        String body = createRequestBody(objList);
        system.debug('body'+body);
        HttpResponse res = sendHTTPRequest('POST', endPoint, body, false, getAuthenticationHeaders());
        if(res != null && res.getStatusCode() == 200){
            System.debug('Success');
            System.debug('response:'+res.getBody());
            Map<String,Object> resBody = new Map<String,Object>();
            resBody = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            if(((List<Object>)resBody.get('items')).size()>0){
                for(Apttus__APTS_Agreement__c agr : objList){
                    agr.SyncedWithJaggaer__c = true;
                }
                update objList;}
        }
        else{
            String emailBody = 'Error Count:'+objList.size();
            sendMails('Failed Agreements', emailBody); 
        }
    }    
    
    
    private static Map<String,String> getAuthenticationHeaders(){
        Map<String,String> headers = new Map<String,String>();
        headers.put('X-P4T-AUTH-USER', USERNAME);
        headers.put('X-P4T-AUTH-TOKEN', TOKEN);
        headers.put('Content-Type', 'application/json');
        return headers;
    }
    
    
    public static void sendMails(String subject, String body){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] emailAddresses = UPSERT_FAILURE_EMAIL.split(',');
        message.toAddresses = emailAddresses;
        message.subject = subject;
        message.htmlbody = body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
    
    public static String createRequestBody(List<Apttus__APTS_Agreement__c> agreementList){
        String body;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('items');
        gen.writeStartArray();
        for(Apttus__APTS_Agreement__c agreement:agreementList){
            gen.writeStartObject();
            if(agreement.RecordType.Name != null && agreement.RecordType.Name != 'Legacy Agreement'){
                gen.writeStringField('contract_type',agreement.RecordType.Name);
            }
            else if(agreement.RecordType.Name == 'Legacy Agreement' && agreement.Agreement_Types__c != null){
                gen.writeStringField('contract_type', agreement.Agreement_Types__c);
            }
            else{
                gen.writeNullField('contract_type');
            }
            if(agreement.Name != null){
                gen.writeStringField('contract_name',agreement.Name);
            }
            else{
                gen.writeNullField('contract_name');
            }
            if(agreement.Apttus__Status__c != null){
                gen.writeStringField('contract_status',agreement.Apttus__Status__c);
            }
            else{
                gen.writeNullField('contract_status');
            }
            if(agreement.Apttus__Contract_Start_Date__c != null){
                gen.writeDateField('contract_valid_from',agreement.Apttus__Contract_Start_Date__c);
            }
            else{
                gen.writeNullField('contract_valid_from');
            }
            if(agreement.Apttus__Contract_End_Date__c != null){
                gen.writeDateField('contract_valid_to',agreement.Apttus__Contract_End_Date__c);
            }
            else{
                gen.writeNullField('contract_valid_to');
            }
            gen.writeStringField('contract_owner',agreement.Owner.Name!= null?agreement.Owner.Name:'');
            if(agreement.Id != null){
                gen.writeStringField('contract_link',URL.getSalesforceBaseUrl().toExternalForm() + '/' + agreement.Id);
            }
            else{
                gen.writeNullField('contract_link');
            }
            if(agreement.Apttus__FF_Agreement_Number__c != null){
                gen.writeStringField('_contract_link_name',agreement.Apttus__FF_Agreement_Number__c);
            }
            else{
                gen.writeNullField('_contract_link_name');
            }
            if(agreement.Apttus__FF_Agreement_Number__c != null){
                gen.writeStringField('conga_agreement_id',agreement.Apttus__FF_Agreement_Number__c);
            }
            else{
                gen.writeNullField('conga_agreement_id');
            }
            gen.writeStringField('_$crm_company_id',agreement.Apttus__Account__r.CLM_JAGGAER_Id__c!=null?agreement.Apttus__Account__r.CLM_JAGGAER_Id__c:'');
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        gen.close();
        body = gen.getAsString();
        return body;
    }
    
}