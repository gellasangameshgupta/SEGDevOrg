/**
* @description Used to fetch Account related data from Jagger
* @createdDate Dec 1, 2021
*/
public with sharing class CLM_AccountCalloutUtility extends CLM_CalloutUtility{

    private static final String USERNAME = System.Label.Jagger_Username;
    private static final String PASSWORD = System.Label.Jagger_Password;
    private static final String TOKEN = System.Label.Jagger_Token;
    private static final String UPSERT_FAILURE_EMAIL = System.Label.Jagger_SupplierUpsertFailureEmail;
    private static final String BASE_URL = 'https://app11.jaggaer.com/api/v1';
    public static final String GET_COMPANIES_API = '/contacts/companies';
    public static final String GET_TOTAL_COMPANIES_API = '/contacts/companies/total';
	@TestVisible
    public static Boolean doNotRun = false;

    /**
    * @description One time script to fetch all Accounts from Jagger API
    * @createdDate Dec 8, 2021
    */
    public static void bulkUpsert(){
        if(doNotRun){
            return;
        }
        CLM_AccountCalloutUtility obj = new CLM_AccountCalloutUtility();
        CLM_TotalCompanies totalObj = obj.getTotalCompanies();
        Integer callsCount = totalObj.total/totalObj.page;
        for(Integer i = 0;i<callsCount; i++){
            CLM_AccountUpsertQueue queueObj = new CLM_AccountUpsertQueue(i * totalObj.page);
            System.enqueueJob(queueObj);
        }
    }
    
    /**
    * @description Fetches all companies from Jagger API
    * @createdDate Dec 1, 2021
    * @param offset
    * @return CLM_CompaniesWrapper
    */
    public CLM_CompaniesWrapper getCompanies(Integer offset){
        String endPoint = BASE_URL + GET_COMPANIES_API;
        if(offset != null){
            endPoint += '?offset='+offset;
        }
        HttpResponse res = sendHTTPRequest('GET', endPoint, null, false, getAuthenticationHeaders());
        CLM_CompaniesWrapper wrapper;
        if(res != null && res.getStatusCode() == 200){
            wrapper = CLM_CompaniesWrapper.parse(res.getBody());
            //upsertAccounts(wrapper.getAccounts());
            CLM_AccountListToInsertOrUpdate accountListWrapper = wrapper.getAccounts();
            if(!accountListWrapper.getAccountsToInsert().isEmpty()){
                insertOrUpdateAccounts(accountListWrapper.getAccountsToInsert(), true);
            }
            if(!accountListWrapper.getAccountsToUpdate().isEmpty()){
                insertOrUpdateAccounts(accountListWrapper.getAccountsToUpdate(), false);
            }
        }
        return wrapper;
    }

    /**
    * @description Fetches count of total companies from Jagger API
    * @createdDate Dec 9, 2021
    * @return CLM_CompaniesWrapper
    */
    public CLM_TotalCompanies getTotalCompanies(){
        HttpResponse res = sendHTTPRequest('GET', BASE_URL + GET_TOTAL_COMPANIES_API, null, false, getAuthenticationHeaders());
        CLM_TotalCompanies totalObj;
        if(res != null && res.getStatusCode() == 200){
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            totalObj = new CLM_TotalCompanies((Integer)responseMap.get('total'), (Integer)responseMap.get('page'));
        }
        return totalObj;
    }

    /**
    * @description Forms generic authentication headers for Jagger API
    * @createdDate Dec 1, 2021
    * @return Map<String,String>
    */
    private static Map<String,String> getAuthenticationHeaders(){
        Map<String,String> headers = new Map<String,String>();
        headers.put('X-P4T-AUTH-USER', USERNAME);
        headers.put('X-P4T-AUTH-TOKEN', TOKEN);
        return headers;
    }

    /**
    * @description Fetches access token from Jagger for the specified user credentials
    * @createdDate Dec 1, 2021
    * @return String
    */
    public String getAccessToken(){
        String endPoint = BASE_URL + '/auth/tokens/acquire?loginname='+USERNAME+'&password='+PASSWORD;
        HttpResponse res = sendHTTPRequest('GET', endPoint, null, false, null);
        String token = null;
        if(res != null && res.getStatusCode() == 200){
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            token = (String)resMap.get('token');
        }
        return token;
    }

    /**
    * @description Insert/Update Accounts
    * @createdDate Jan 28, 2022
    * @param accountList, isInsert
    */
    public static void insertOrUpdateAccounts(List<Account> accountList, Boolean isInsert){
        System.debug('Account Size: '+accountList.size());
        Database.SaveResult[] saveResults;
        String insertOrUpdate = '';
        if(isInsert){
            saveResults = Database.insert(accountList, false);
            insertOrUpdate = 'Insert';
        }else{
            saveResults = Database.update(accountList, false);
            insertOrUpdate = 'Update';
        }
        String body = '<p>Account Size: '+accountList.size()+'</p>';
        Integer count = 0;
        for(Database.SaveResult saveResultsObj : saveResults) {
            if(saveResultsObj.isSuccess()){
                count++;
                continue;
            }
            List<Database.Error> errors = saveResultsObj.getErrors();
            for(Database.Error errorObj : errors) {
                System.debug('Error: '+errorObj.getMessage()+' -- '+errorObj.getFields());
                body+='<p>'+'Error: '+errorObj.getMessage()+' -- '+errorObj.getFields()+'</p>';
            }
        }
        body += '<p>Success Size: '+count+'</p>';
        sendMails('Failed/Success Accounts '+insertOrUpdate, body);
    }

    /**
    * @description Sends a mail for failed records
    * @createdDate Dec 8, 2021
    * @param subject, body
    */
    public static void sendMails(String subject, String body){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] emailAddresses = UPSERT_FAILURE_EMAIL.split(',');
        message.toAddresses = emailAddresses;
        message.subject = subject;
        message.htmlbody = body;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }

}