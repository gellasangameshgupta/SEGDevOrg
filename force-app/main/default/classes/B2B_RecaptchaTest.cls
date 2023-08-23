/*******************************************************************************************************
* 
* @ Name        : B2B_RecaptchaTest
* @ Purpose     : Test class for B2B_Recaptcha
* @ Author      : Pradeep Chary
* @ Class Name  : B2B_Recaptcha
*
*   Date        |  Developer Name                     |  Version      |  Changes
* ======================================================================================================
*   05-23-2021  |  pradeep.chary@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_RecaptchaTest implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse objResponse = new HttpResponse();
        
        String strSetBody = '{"success": true, "score": 0.5, "action": "POST"}';
        objResponse.setBody(strSetBody);
        objResponse.setStatusCode(200);
        return objResponse;
    }
    
    @isTest
    static void testConfirmRecaptcha() {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new B2B_RecaptchaTest());
        Boolean blnStatus = B2B_Recaptcha.confirmRecaptcha(null, 'true');
        
        Test.stopTest();
        
        System.assertEquals(blnStatus, true);
    }
}