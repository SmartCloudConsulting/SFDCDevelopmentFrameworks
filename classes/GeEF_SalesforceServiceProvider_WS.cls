/**********************************************************************
Name:  GeEF_SalesforceServiceProvider_WS
Copyright © 2017
======================================================
======================================================
Purpose:  High level Service Provider used to interpret the response from the 
          Standard Salesforce APIs

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Framework    21/08/2017          
***********************************************************************/  
public abstract with sharing class GeEF_SalesforceServiceProvider_WS extends GeWS_WebService_A {

    /*******************************************************************
    * @description: Returns a map of objects against their fields with their errors
    * @param: 
    * @return: Results of callout
    * @Throws [Exceptions]: MM_OSTErrorResponseFieldsException
    ********************************************************************/     
    public override GeWS_WebService_A.CallOutResults interpretResponse(System.HttpResponse httpResponse
                                                                    , System.HttpRequest httpRequest) {
        GeWS_WebService_A.CallOutResults callOutResult = new GeWS_WebService_A.CallOutResults();
        callOutResult.statusCode = httpResponse.getStatusCode();
        callOutResult.status = httpResponse.getStatus();
        callOutResult.body = httpResponse.getBody();

        return calloutResult; 
    }

    /*******************************************************************
    * @description: Returns a map of objects against their fields with their errors
    * @param: 
    * @return: Results of callout
    * @Throws [Exceptions]: MM_OSTErrorResponseFieldsException
    ********************************************************************/ 
    public override Map<String, Object> deserializeErrorResponse(String responseString
                                                                 , String statusCode
                                                                 , HTTPRequest req) {
        Map<String, Object> errorResponse;
        try {
            errorResponse = (Map<String, Object>)JSON.deserializeUntyped(responseString); // pass
        } catch (Exception e) {
            List<Object> errorResponses = (List<Object>)JSON.deserializeUntyped(responseString);
        }
        return errorResponse; 
    }

}