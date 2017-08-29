/**********************************************************************
Name:  GeWS_ExampleServiceProvider_WS
Copyright © 2016
======================================================
======================================================
Purpose:  This represents a Service Providers 
		  whos interfaces will follow a specific pattern.

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Framework    06/08/2016          
***********************************************************************/  
public abstract with sharing class GeWS_ExampleServiceProvider_WS extends GeWS_WebService_A {

  	/*******************************************************************
    * @description User to interpret the response, this should be a generic
    				method used to interpret all responses from this service
    				provider  
    * @Param HttpResponse
    * @Param httpReq     
    * @return GeWS_WebService_A.CallOutResults
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public override GeWS_WebService_A.CallOutResults interpretResponse(HttpResponse httpRes
                                                                    , HttpRequest httpReq) {
        //Standard location to interpret the response
        GeWS_WebService_A.CallOutResults callOutResult = new GeWS_WebService_A.CallOutResults();
        callOutResult.statusCode = httpRes.getStatusCode();
        callOutResult.status = httpRes.getStatus();
        callOutResult.body = httpRes.getBody();

  //System.debug('This is the result ' +  callOutResult.body);
        //Populated Error Fields
        if (!String.valueOf(callOutResult.statusCode)
        			.startsWith(GeWS_Constants.WS_HTTP_CODE_SUCCESS_START)) {
        	//Populate the error portion
            populateErrorDetails(callOutResult,httpRes, httpReq );
        } 
        return callOutResult;
    }

  	/*******************************************************************
    * @description Populates the error components of a response message 
    * @Param String
    * @Param String
    * @Param HTTPRequest 
    * @Param HttpRequest    
    * @return Map<String, Object>
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    private void populateErrorDetails(GeWS_WebService_A.CallOutResults callOutResult
    								, HttpResponse httpRes
    								, HttpRequest httpReq
    								){
		callOutResult.hasErred = true;
        String contentType = httpRes.getHeader(GeWS_Constants.CONTENT_TYPE);

  	
    }
  
  	/*******************************************************************
    * @description interpret the error response   
    * @Param String
    * @Param String
    * @Param HTTPRequest     
    * @return Map<String, Object>
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public override Map<String, Object> deserializeErrorResponse(String responseString
														    	, String statusCode
														    	, HTTPRequest req) {       
        Map<String, Object> callOutErrorResponseMap = new Map<String, Object>();
        //DO SOME LOGIC TO MAP THIS BACK
        return callOutErrorResponseMap;     
    }
}