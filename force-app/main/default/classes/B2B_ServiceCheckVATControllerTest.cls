/*******************************************************************************************************
* 
* @ Name        : 	B2B_ServiceCheckVATControllerTest
* @ Purpose     : 	Test class for B2B_ServiceCheckVATController
* @ Author      : 	Aseem Doddamani
* @ Class Name  : 	B2B_ServiceCheckVATController
*
*   Date        |  Developer Name                       |  Version      |  Changes
* ======================================================================================================
*   22-10-2021  |  aseem.doddamani@absyz.com            |  1.0          |  Initial Version
*
*******************************************************************************************************/
@isTest
public class B2B_ServiceCheckVATControllerTest implements WebServiceMock {
    
    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> map_ResponseByResult,
        String strEndpoint,
        String strSoapAction,
        String strRequestName,
        String strResponseNS,
        String strResponseName,
        String strResponseType
    ) {
        B2B_ServiceCheckVatTypes.checkVatResponse_element objCheckVatResponse = 
            new B2B_ServiceCheckVatTypes.checkVatResponse_element();
        objCheckVatResponse.valid = true;
        map_ResponseByResult.put('response_x', objCheckVatResponse); 
    }
    
    @isTest
    public static void testCheckVATValidity() {
        Test.startTest();
        
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new B2B_ServiceCheckVATControllerTest());
        
        List<B2B_ServiceCheckVATController.VATResult> list_VatResults = 
            new List<B2B_ServiceCheckVATController.VATResult>();
        
        List<B2B_ServiceCheckVATController.VATRequest> list_requestVATParams = 
            new List<B2B_ServiceCheckVATController.VATRequest>();
        
        B2B_ServiceCheckVATController.VATRequest objVATRequest = new B2B_ServiceCheckVATController.VATRequest();
        objVATRequest.strCountryCode = 'Portugal';
        objVATRequest.strVATNumber = '505051931';
        
        list_requestVATParams.add(objVATRequest);
        
        // Call the method that invokes a callout
        list_VatResults = B2B_ServiceCheckVATController.checkVATValidity(list_requestVATParams);
        
        // Verify that a fake result is returned
        System.assertEquals(true, list_VatResults[0].blnIsValid);
        
        Test.stopTest();
    }
}