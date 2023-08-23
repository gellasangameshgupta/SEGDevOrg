/**
* @description Http Mock class to generate HttpResponse for CLM_AccountCalloutUtility
* @createdDate Dec 1, 2021
*/
@isTest
public class CLM_AccountCalloutMock implements HttpCalloutMock{

    /**
     * @description Generates fake response for CLM_AccountCalloutUtility test class
     * @param req
     * @return HttResponse
     */
    public HTTPResponse respond(HTTPRequest req) {      
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String responseBody = '';
        String endPoint = req.getEndpoint();
        res.setStatusCode(200);
        if(endPoint.contains('tokens')){
            responseBody = '{"token":"1234"}';
        } else if(endPoint.contains(CLM_AccountCalloutUtility.GET_TOTAL_COMPANIES_API)){
            responseBody = '{"total":1,"page":1}';
        } else if(endPoint.contains(CLM_AccountCalloutUtility.GET_COMPANIES_API)){
            responseBody = '{"items":[{"id":"260333630","isMember":true,"name":"HunanLRNeo-EcoTechnologies","city":"Changsha","country":"CHINA","partnerNumber":"97404508"}]}';
        }
        res.setBody(responseBody);
        return res;
    }
    
}