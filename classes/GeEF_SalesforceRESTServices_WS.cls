/**********************************************************************
Name:  GeEF_SalesforceRESTServices_WS
Copyright © 2017
======================================================
======================================================
Purpose:  Used to create records within a Salesforce Org

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Framework    23/08/2017          
***********************************************************************/  
public with sharing class GeEF_SalesforceRESTServices_WS  extends GeEF_SalesforceServiceProvider_WS {
	private String serviceName;
    private final String sObjectService = '/services/data/v38.0/sobjects/';

    /*******************************************************************
    * @description: Adds the correct services to the Salesforce endpoint
    * @param: sObject aRecord - The sObject 
    * @Throws [Exceptions]: NullPointerException
    ********************************************************************/ 
    private void addSobjectServiceToEndPoint(sObject aRecord){
        endpoint = endpoint.removeEnd('/');
        endpoint = endpoint + sObjectService + aRecord.getSobjectType();
    }

    /*******************************************************************
    * @description: attempts to create a record within Salesforce
    * @param: sObject recordToCreate - The sObject to create
    * @return: String - the id of the record, null if not created
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
	public String createRecord(sObject recordToCreate){
        return createRecord(recordToCreate, GeWS_Constants.SALESFORCE_API);
	}

    /*******************************************************************
    * @description: attempts to create a record within Salesforce
    * @param: String instanceIdentifier - used to identify the custom setting
    *		  associated to the Salesforce instance   
    * @param: sObject recordToCreate - The sObject to create
    * @return: String - the id of the record, null if not created
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
	public String createRecord(sObject recordToCreate, String instanceIdentifier){
        
        //Setup Required Parameters
        serviceName = instanceIdentifier;
        super.initaliseForWebServiceCall(serviceName);
        addSobjectServiceToEndPoint(recordToCreate);

        //Make callout
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                              , (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordToCreate))
                                              , true );  
        String responseBody = callOutResult.body;
        Map<String,Object> recordResponse = new Map<String,Object> ();

        createSobjectResponse sObjectResponse 
                        = (createSobjectResponse)JSON.deserialize(responseBody,createSobjectResponse.class);

		return sObjectResponse.id;
	}

    /*******************************************************************
        Purpose: Inner class which is used for responses when Creating records
    ********************************************************************/
    class createSobjectResponse {
        public String id;
        public boolean success;
        public Map<String, String> errors;
    }
}