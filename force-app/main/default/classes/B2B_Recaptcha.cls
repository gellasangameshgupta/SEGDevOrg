/*******************************************************************************************************
* 
* @ Name            :   B2B_Recaptcha
* @ Purpose         :   Controller for b2b_googleRecaptcha
* @ Methods         :   confirmRecaptcha - Make a REST Api call to Google Recaptcha and confirms back
*                           params - objRecord, strRecaptchaResponse
* @ Author          :   Pradeep Chary
* @ Usage           :   Verifies and confirms the Registering User is a valid user
* @ Test Class Name :   B2B_RecaptchaTest
*
*   Date            |  Developer Name               |  Version      |  Changes
* ======================================================================================================
*   05-23-2021      |  pradeep.chary@absyz.com      |  1.0          |  Initial Version
*
*******************************************************************************************************/

public with sharing class B2B_Recaptcha {
    private static String strRecaptchaSecretKey = System.Label.CLB2B00015;
    
    @AuraEnabled
    public static Boolean confirmRecaptcha(SObject objRecord, String strRecaptchaResponse) {
        try {
            //https://developers.google.com/recaptcha/docs/verify
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.google.com/recaptcha/api/siteverify');
            request.setMethod('POST');
            request.setBody('secret=' + strRecaptchaSecretKey + '&response=' + strRecaptchaResponse);
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug(response.getBody());
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                if (result.containsKey('success') && result.get('success') == true) {
                    if (result.containsKey('score')) {
                        //score logic is only needed/returned for v3 (0.0 - 1.0)
                        //https://developers.google.com/recaptcha/docs/v3
                        //TODO: verify action name for the request
                        String action = (String) result.get('action');
                        
                        //TODO: get threshold configuration for each action
                        Decimal threshold = .4;
                        Decimal score = (Decimal) result.get('score');

                        if (score > threshold) {
                            //TODO: perform action on record
                            return true; // 'Success - v3'
                        }
                    } else {
                        //TODO: perform action on record
                        return true; // 'Success - v2'
                    }
                } else {
                    return false; // 'Invalid Verification'
                }
            }
        } catch(Exception e) {
            IFv2_ExceptionUtilitiesController.exceptionHandler(e);
        }

        //consider letting this through
        return false; //'Invalid Verification Request'
    }
}