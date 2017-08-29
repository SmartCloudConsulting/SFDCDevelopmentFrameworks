/**********************************************************************
Name:  GeWS_WebService_A
Copyright © 2016
======================================================
======================================================
Purpose:  Generic class for executing web-service callouts

FUTURE IMPROVEMENTS
 - HTTP METHODS should be ENUMS not Strings even Constants
 - Exception Handling should be added

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Smart Cloud Framework    06/08/2017       
***********************************************************************/  
public abstract with sharing class GeWS_WebService_A {
    
    public Map<String, GeWS_WebService_Integration_Settings__c> integrationSettings;
    public enum GeWS_HTTPMethod { POST,GET,PATCH,PUT }


    public GeWS_WebService_A.CallOutResults callOutResult;
    public Map<String, String> parameters;
    public Map<String, String> urlReplacements;
    public String endpoint;

    /******************* Declaration of variables *********************/

    public String lastEndpointCalled;

    protected Integer timeout;       
    protected String authorizationHeader;
    protected String userAgent;

    /******************* Constructor             *********************/    
    public GeWS_WebService_A() {
        integrationSettings = GeWS_WebService_Integration_Settings__c.getAll(); 
        defaultVariables();
    }

    /*******************************************************************
    * @description Defaults the variables                        
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private Void defaultVariables(){
        lastEndpointCalled = null;
        timeout = 0;
        authorizationHeader = null;
        userAgent = null;       
    }

    /*******************************************************************
    * @description Initalises the prams for the web service calls                      
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private void initaliseForWebServiceCall(){
        //Setup Required Parameters
        endpoint = '';
        parameters = new Map<String, String>();
        urlReplacements = new Map<String, String>();
        callOutResult = new GeWS_WebService_A.CallOutResults();
    }

    /*******************************************************************
    * @description Initalises the prams for the web service calls
    * @param  String wsType - the Integreation Cred Site              
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public void initaliseForWebServiceCall(String wsType){
        initaliseForWebServiceCall();
        endpoint = integrationSettings.get(wsType).GeWS_Endpoint__c;     
    }
     
    /*******************************************************************
    * @description Utility method for building an endpoint to be called by a web-service
    * @param  String url - The URL of the endpoint to be called
    * @param  Map<String, String> urlReplacements - Any URL Replacements 
    * @param  Map<String, String> parameters - Parameters to add to the URL
    *         Param Identifier > Param Value
    * @return String endpoint for the web-service call
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected virtual String populateEndPoint(String url
                                            , Map<String, String> urlReplacements
                                            , Map<String, String> parameters) {
        String finalEndPoint = url;
        
        // Determine if endpoint already has a trailing slash - if not, add one
        if (!finalEndPoint.endsWith('/')) {
            finalEndPoint += '/';
        }
        //replace any required URI Replacements
        //eg www.example.com/{UID}/test  to be www.example.com/123423423423/test
        if(urlReplacements!= null){
            for(String aKey : urlReplacements.keySet()){
                finalEndPoint = finalEndPoint.replace(aKey, urlReplacements.get(aKey));
            }
        }
        //These are the parameters at the end of the URI 
        //eg www.example.com?Take=value&Skip=value
        if(parameters != null){
            finalEndPoint = addParameters(finalEndPoint,parameters);
        }
        
        return finalEndPoint;
    }

    /*******************************************************************
    * @description Addss parameters the URL
    * @param  String endPoint - The URL of the endpoint to be called
    * @param  Map<String, String> parameters - Parameters to add to the URL
    *         Param Identifier > Param Value
    * @return String endpoint for the web-service call
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public String addParameters(String endPoint, Map<String, String> parameters){

        // If the URL has a trailing slash, remove it before adding the parameters
        if (endPoint.endsWith('/')) {
            endPoint = endPoint.substring(0, endPoint.length() -1);
        }

        // Add parameters to the end of the URL
        if (parameters != null) {
            endPoint += '?';
            for (String arg : parameters.keySet()) {
                if (endPoint.endsWith('?')) {
                    endPoint += arg + '=' + parameters.get(arg);
                } else {
                    endPoint += '&' + arg + '=' + parameters.get(arg);
                }       
            }
        } 
        // If the URL has a trailing question mark, remove it
        if (endPoint.endsWith('?')) {
            endPoint = endPoint.substring(0, endPoint.length() -1);
        }  
        return endPoint;
    }
    
    /*******************************************************************
    * @description Builds a HTTP Request and makes a callout. 
    *              The response is mapped back into a Custom Object
    * @param  String method - The method that should be used for the Web Service       
    * @param  String endPoint - The URL of the endpoint to be called
    * @param  String wS_IntegrationSettingName - name of the integration setting
    * @param  String String contentType - content type of the body of the message
    * @param  Map<String, Object> requestBody - Request body
    * @param  Boolean retryIfBusy - if TRUE then retry if a response code 429
    * @return CallOutResults
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (   String method
                                                        , String endpoint
                                                        , String wS_IntegrationSettingName
                                                        , String contentType
                                                        , Map<String, Object> requestBody
                                                        , Boolean retryIfBusy){
        return callOutToWebService(   method
                                    , endpoint
                                    , wS_IntegrationSettingName
                                    , contentType
                                    , String.valueOf(JSON.serialize(requestBody))
                                    , retryIfBusy);
    }

    /*******************************************************************
    * @description Builds a HTTP Request and makes a callout. 
    *              The response is mapped back into a Custom Object
    * @param  String method - The method that should be used for the Web Service       
    * @param  String endPoint - The URL of the endpoint to be called
    * @param  String wS_IntegrationSettingName - name of the integration setting
    * @param  String String contentType - content type of the body of the message
    * @param  Boolean retryIfBusy - if TRUE then retry if a response code 429
    * @return CallOutResults
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , Boolean retryIfBusy
                                                    ){
        return callOutToWebService(method
                                , endpoint
                                , wS_IntegrationSettingName
                                , contentType
                                , ''
                                , retryIfBusy);
    }

    /*******************************************************************
    * @description Builds a HTTP Request and makes a callout. 
    *              The response is mapped back into a Custom Object
    * @param  String method - The method that should be used for the Web Service       
    * @param  String endPoint - The URL of the endpoint to be called
    * @param  String wS_IntegrationSettingName - name of the integration setting
    * @param  String String contentType - content type of the body of the message
    * @param  String requestBody - Request body
    * @param  Boolean retryIfBusy - if TRUE then retry if a response code 429
    * @return CallOutResults
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public virtual CallOutResults callOutToWebService (String method
                                                    , String endpoint
                                                    , String wS_IntegrationSettingName
                                                    , String contentType
                                                    , String requestBody
                                                    , Boolean retryIfBusy
                                                    ){

        // Create a new instance of the results object
        CallOutResults results = new CallOutResults();
        
        // Attempt the callout
        results = makeWSCall(method
                            , endpoint
                            , wS_IntegrationSettingName
                            , contentType
                            , requestBody
                            , retryIfBusy);
        return results;
    }

    /*******************************************************************
    * @description Prepares the request for the web-service callout and 
    *              performs it (retries if service is busy and is specified)
    * @param  String method - The method that should be used for the Web Service       
    * @param  String endPoint - The URL of the endpoint to be called
    * @param  String wS_IntegrationSettingName - name of the integration setting
    * @param  String String contentType - content type of the body of the message
    * @param  String bodyOfMessage - Request body
    * @param  Boolean retryIfBusy - if TRUE then retry if a response code 429
    * @return CallOutResults
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    protected virtual CallOutResults makeWSCall(  String method
                                                , String endpoint
                                                , String wS_IntegrationSettingName
                                                , String contentType
                                                , String bodyOfMessage
                                                , Boolean retryIfBusy) {  

        // Set the values to be used in the request
        HttpRequest req = setHTTPRequestValues(method
                                                , endpoint
                                                , wS_IntegrationSettingName
                                                , contentType
                                                , bodyOfMessage);

        // Create an instance of a response
        HTTPResponse response;

        // The for loop is used to call again if the service is busy (returns a 429 error)
        for (Integer i = 0; i <= 1; i++) {
            // Make the callout and populate the response object
            response = sendRequest(req);  
  
            // If no response was returned the return this to the calling method            
            if (response == null) {
                return null;
            // Else if the status is NOT a 429 then break (do not attempt a second time)
            } else if (!retryIfBusy || String.valueOf(response.getStatusCode()) != '429') { 
                break;
            }
        }       
        
        lastEndpointCalled = endpoint;
        // Interpret the response and return to the calling system                 
        return interpretResponse(response, req);                                                         
        
    }

    /*******************************************************************
    * @description Sends a request and returns the response 
    * @param  HTTPRequest req populated Request Object
    * @return HTTPResponse - HTTP response object
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/
    protected virtual HTTPResponse sendRequest(HTTPRequest req) {
       
        Http http = new Http();
        HTTPResponse response = new HTTPResponse();

        try {
            response = http.send(req); 
        } catch (Exception e) { 
            //<<TO DO ADD EXCEPTION FRAMEWORK>>
        }  
        return response;
    }  
  
    /*******************************************************************
    * @description Sets Method for the Callout
    * @param  String method - the HTTP Method that should be used
    * @param  HTTPRequest req - Request object to populate the method =
    * @Throws [Exceptions]: None
    ********************************************************************/  
    protected virtual Void setMethodForCallout(String method, HttpRequest req){
        //Populates the Method of the API request
        if (method == null || method == '') {
            //Do not add Method
        } else if (method.tolowerCase() == GeWS_Constants.WS_METHOD_PATCH) {
            req.setMethod(GeWS_Constants.WS_METHOD_POST);
            req.setHeader(GeWS_Constants.WS_X_HTTP_METHOD_OVERRIDE_HEADER, method);
        } else {
            req.setMethod(method);
        }
    }

    /*******************************************************************
    * @description Sets the HTTP Request Values
    * @param  String method - the HTTP Method that should be used in HTTP Req
    * @param  String endpoint - The endpoint to add to the request
    * @param  String contentType - Content Type to use in the header
    * @return HttpRequest - HTTP request object with request populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual HttpRequest setHTTPRequestValues(   String method
                                                        , String endpoint
                                                        , String contentType) {
        // Create a new instance of the HTTP Request
        HttpRequest req = new HttpRequest();

        // Populate the mandatory properties for the HTTP Request
        if (endpoint != null && endpoint != '') {        
            req.setEndpoint(endpoint);
        }

        //Set the HTTP Method for Callout
        setMethodForCallout(method,req);

        //Set the Content Type
        if (contentType != null && contentType != '') {
            req.setHeader(GeWS_Constants.CONTENT_TYPE, contentType);
        }

        return req;
    }

    /*******************************************************************
    * @description Sets the HTTP Request Values
    * @param  String method - the HTTP Method that should be used in HTTP Req
    * @param  String endpoint - The endpoint to add to the request
    * @param  String wS_IntegrationSettingName - The integreation setting to be used
    * @param  String contentType - Content Type to use in the header
    * @param  String bodyOfRequest - The body of the request to use
    * @return HttpRequest - HTTP request object with request populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/   
    protected virtual HttpRequest setHTTPRequestValues(   String method
                                                        , String endpoint
                                                        , String wS_IntegrationSettingName
                                                        , String contentType
                                                        , String bodyOfRequest) {
        //sets the Request Values
        HttpRequest req = setHTTPRequestValues(method,endpoint,contentType);

        //Set Header Values
        req = setHeaderValues(req, wS_IntegrationSettingName);
        
        // If a body for the request was supplied 
        if (bodyOfRequest != null && bodyOfRequest != '') {
            req.setBody(bodyOfRequest);
        }
        
        return req;
    }
   
    /*******************************************************************
    * @description Adds the Timeout to the request 
    * @param  HttpRequest request - request to add timeout to
    * @param  String wS_IntegrationSettingName - setting identifier to add timeout from
    * @return HttpRequest - HTTP Request object with timeout populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual HttpRequest addTimeOut(HttpRequest request, String wS_IntegrationSettingName){
        Integer apiTimeout 
                    = Integer.valueof(
                        GeWS_WebService_Integration_Settings__c.getValues(wS_IntegrationSettingName).GeWS_Timeout__c);

        if(apiTimeout != null){
            request.setTimeout(apiTimeout);
        }
        return request;                 
    }

    /*******************************************************************
    * @description Adds the credentials to the callout
    * @param  HttpRequest request - request to authentication to
    * @param  String wS_IntegrationSettingName - setting to  use to find security crenedtial
    * @return HttpRequest - HTTP request object with timeout populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual HttpRequest addCredentials(HttpRequest request, String wS_IntegrationSettingName){
        //Get the Identifer for the Credentials used
        String credentialIdentifier 
                    = GeWS_WebService_Integration_Settings__c.getValues(wS_IntegrationSettingName).GeWS_IntegrationCredentialIdentifier__c;
        
        if(credentialIdentifier != null){

            //Get an instance of the credentials to use for this callout
            GeWs_SecuritCredential_DAO secCredDAC = new GeWs_SecuritCredential_DAO();
            GeWS_Security_Credential__c secCred = secCredDAC.getSecurityCredentialByIdentifier(credentialIdentifier);

            //determine the approrpaite authentication to use
            if(secCred != null){
                //Set userAgent for Requests
                request.setHeader(GeWS_Constants.WS_USER_AGENT, secCred.GeWS_User_Agent__c);
                //Set Certificate if required
                if(secCred.GeWS_Certificate_Name__c != null){
                    request.setClientCertificateName(secCred.GeWS_Certificate_Name__c);
                }
                //Call Method to build Basic Authentication
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_BASIC_AUTH)){
                    return setBasicAuth(request, secCred);
                }
                //Call Method to build OAuth2 Authentication
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_OAUTH_2)){ 
                    return setOAuth2(request, secCred);
                }
                //Call Method to build Other Authentication
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_API_KEY_ONLY)){ 
                    return setAPIKeyOnly(request, secCred);
                }
                //Call Method to build Other Authentication
                if(secCred.GeWS_Credential_Type__c.equals(GeWS_Constants.WS_OCP_APIM_SUBSCRIPTION_KEY)){ 
                    return setOCPSubscriptionKey(request, secCred);
                }                 
            }
        }

        return request;                 
    }

    /*******************************************************************
    * @description Sets the header values on the request object
    * @param  HttpRequest request - request object to set header value on
    * @param  String wS_IntegrationSettingName - setting to  use to find security creds
    * @return HttpRequest - HTTP request object with header values populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual HttpRequest setHeaderValues (HttpRequest request, String wS_IntegrationSettingName) {
        request = addTimeOut(request,wS_IntegrationSettingName);
        request = addCredentials(request,wS_IntegrationSettingName);
        return request;
    }

    /*******************************************************************
    * @description Sets the OCP subscription Header (used on some Microsoft API's)
    * @param  HttpRequest request - request object to set header value on
    * @param  String wS_IntegrationSettingName - setting to  use to find security creds
    * @return HttpRequest - HTTP request object with header values populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual HttpRequest setOCPSubscriptionKey ( HttpRequest request
                                                        , GeWS_Security_Credential__c credentials) {
        request.setHeader(GeWS_Constants.WS_OCP_APIM_SUBSCRIPTION_KEY
                        , credentials.GeWS_API_Key__c);
        return request;
    }

    /*******************************************************************
    * @description Sets basic auth header
    * @param  HttpRequest request - request object to set header auth
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return HttpRequest - HTTP request object with authentication populated
    * @Throws [Exceptions]: None
    ********************************************************************/ 
    protected virtual HttpRequest setBasicAuth (  HttpRequest request
                                                , GeWS_Security_Credential__c credentials) {
        request.setHeader(GeWS_Constants.WS_AUTHORIZATION_HEADER, GeWS_Constants.WS_AUTH_TYPE_BASIC 
                + EncodingUtil.base64Encode(
                    blob.valueOf(credentials.GeWS_Username__c + ':' + credentials.GeWS_Password__c)
                )
            );
        return request;
    }

    /*******************************************************************
    * @description Sets Headers for OAuth2
    * @param  HttpRequest request - request object to set header auth
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return HttpRequest - HTTP request object with authentication populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/  
    protected virtual HttpRequest setOauth2 ( HttpRequest request
                                            , GeWS_Security_Credential__c credentials) {

        String accessToken = null;
        //Set the elements for the callout
        HttpRequest accessRequest = setHTTPRequestValues(GeWS_Constants.WS_METHOD_POST
                                                        , oAuthEndPoint(credentials)
                                                        , GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
      
        HTTPResponse accessResponse = this.sendRequest(accessRequest);
        String responseBody = accessResponse.getBody();

        accessToken = String.valueOf(
                        ((Map<String, Object>) JSON.deserializeUntyped(responseBody))
                                .get(GeWS_Constants.WS_OAUTH_ACCESS_TOKEN));
        
        //Set the Header
        request.setHeader(GeWS_Constants.WS_AUTHORIZATION_HEADER, GeWS_Constants.WS_BEARER + accessToken);
        
        return request;
    }
    
    /*******************************************************************
    * @description Sets Headers for APIKEY
    * @param  HttpRequest request - request object to set header auth
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return HttpRequest - HTTP request object with authentication populated
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/  
    protected virtual HttpRequest setAPIKeyOnly ( HttpRequest request
                                                , GeWS_Security_Credential__c credentials) {

        if(credentials.GeWS_API_Key_Location__c == GeWS_Constants.WS_HEADER){
            request.setHeader(credentials.GeWS_API_key_Variable_to_use__c,credentials.GeWS_API_Key__c);
        } else {
            Map<String, String> params = new Map<String, String>();
            params.put(credentials.GeWS_API_key_Variable_to_use__c,credentials.GeWS_API_Key__c);
            request.setEndpoint(addParameters(request.getEndpoint(), params));
        }
        return request;
    }

    /*******************************************************************
    * @description Sets the oAuth Endpoint
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return String - Oauth 2 Endpoint ot be used
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    protected virtual String oAuthEndPoint(GeWS_Security_Credential__c credentials){
        String oAuth2EndPoint = credentials.GeWS_Authentication_Endpoint__c;

        Map<String, String> urlParameters;
        if(credentials.GeWS_Grant_Type__c == GeWS_Constants.HTTP_GRANT_TYPE_PASSWORD){
            urlParameters = oAuthGrantTypePassword(credentials);
        }
        else if(credentials.GeWS_Grant_Type__c == GeWS_Constants.HTTP_GRANT_TYPE_CLIENT_CREDENTIALS){ 
            urlParameters = oAuthGrantTypeClientCredentials(credentials);
        }
        
        if(urlParameters != null && !urlParameters.isEmpty()){
            oAuth2EndPoint = addParameters(oAuth2EndPoint, urlParameters);
        }

        return oAuth2EndPoint;
    }

    /*******************************************************************
    * @description Sets oauth of Grant Type is Password
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return Map<String, String> - used for url params (key value pairs)
    * @Throws [Exceptions]: None
    ********************************************************************/ 
    protected virtual Map<String, String> oAuthGrantTypePassword(GeWS_Security_Credential__c credentials){
        Map<String, String> urlParameters = new Map<String, String>();
        urlParameters.put(GeWS_Constants.GRANT_TYPE,GeWS_Constants.HTTP_GRANT_TYPE_PASSWORD);
        if(credentials != null){
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_ID, credentials.GeWS_API_Key__c);
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_SECRET, credentials.GeWS_API_Secret__c);
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_USERNAME, credentials.GeWS_Username__c);
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_PASSWORD, credentials.GeWS_Password__c);
        }
        return urlParameters;   
    }
    
    /*******************************************************************
    * @description Sets oauth of Grant Type client creds
    * @param  String GeWS_Security_Credential__c - Sec creds object
    * @return Map<String, String> - used for url params (key value pairs)
    * @Throws [Exceptions]: None
    ********************************************************************/ 
    protected virtual Map<String, String> oAuthGrantTypeClientCredentials(GeWS_Security_Credential__c credentials){
        Map<String, String> urlParameters = new Map<String, String>();
        urlParameters.put(GeWS_Constants.GRANT_TYPE,GeWS_Constants.HTTP_GRANT_TYPE_CLIENT_CREDENTIALS);
        if(credentials != null){
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_ID, credentials.GeWS_API_Key__c);
            urlParameters.put(GeWS_Constants.HTTP_PARAMETER_CLIENT_SECRET, credentials.GeWS_API_Secret__c);
        }
        return urlParameters;   
    }
 
    /*******************************************************************
    * @description ABSTRACT for deserialising the error response
    *              This method should be overridden for specific Web Service providers
    * @param  String responseString - The response body as a String
    * @param  String statusCode - Status code of the response
    * @param  HTTPRequest req - The HTTP Request
    * @return Map<String, Object> - interpreted error response
    * @Throws [Exceptions]: N/A
    ********************************************************************/ 
    protected abstract Map<String, Object> deserializeErrorResponse(String responseString
                                                                    , String statusCode
                                                                    , HTTPRequest req);

    /*******************************************************************
    * @description ABSTRACT for deserialising the error response
    *              This method should be overridden for specific Web Service providers
    * @param  HTTPResponse response - The HTTP Response 
    * @param  HTTPRequest request - The HTTP Request
    * @return Map<String, Object> - interpreted error response
    * @Throws [Exceptions]: N/A
    ********************************************************************/        
    protected abstract CallOutResults interpretResponse(HTTPResponse response
                                                      , HTTPRequest request);    
    
    /*******************************************************************
        Purpose: Inner class for holding results of the callout 
    ********************************************************************/     
    public class CallOutResults {
        public Integer statusCode;
        public String status;
        public String body;
        public Boolean hasErred;
        public String errorMessage;
        public Map<String, Object> errorResponseMap; 
        public String errorCode;
        public String requestBody;
        public String requestMethod;
    }  
}