/**
* @description Used to make callouts synchronously or asynchronously
* @createdDate Dec 1, 2021
*/
public virtual class CLM_CalloutUtility {
    
    /** @description Forms the HTTP request and sends it based on details passed as params
    * @createdDate Dec 1, 2021
    * @param httpMethod, endPoint, body, isBlobBody, requestHeaders
    * @return HTTPResponse
    */
    protected HTTPResponse sendHTTPRequest(String httpMethod, String endPoint, String body, Boolean isBlobBody, Map<String, String> requestHeaders){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        if(requestHeaders != null){
            for(String header : requestHeaders.keySet()){
                req.setHeader(header, requestHeaders.get(header));
            } 
        }
        req.setEndpoint(endPoint);
        if(!String.isBlank(body)){
            if(isBlobBody){
                req.setBodyAsBlob(EncodingUtil.base64Decode(body));
            }else{
                req.setBody((String)body);
            }
        }
        HTTPResponse response = null;
        try{
            response = h.send(req);
        }catch(Exception e){
            System.debug('Callout Error: '+e.getMessage());
        }
        return response;
    }

}