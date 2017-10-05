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
   1.0      Smart Cloud Framework    23/08/2017          
***********************************************************************/  
public with sharing class GeEF_SalesforceRESTServices_WS  extends GeEF_SalesforceServiceProvider_WS {
    private String serviceName;
    private final String sObjectService = '/services/data/v40.0/sobjects/';
    private final String sObjectTreeService = '/services/data/v40.0/composite/tree/';

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
    *         associated to the Salesforce instance   
    * @param: sObject recordToCreate - The sObject to create
    * @return: String - the id of the record, null if not created
    * @Throws [Exceptions]: <<TO DO>>
    ********************************************************************/ 
    public String createRecord(sObject recordToCreate, String instanceIdentifier){
        
        //Setup Required Parameters
        serviceName = instanceIdentifier;
        super.initaliseForWebServiceCall(serviceName);
        addServiceToEndPoint(recordToCreate, sObjectService);

        //Make callout
        callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                              , endpoint
                                              , serviceName
                                              , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                              , (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(recordToCreate))
                                              , true ); 

        String responseBody = callOutResult.body;

        Map<String,Object> recordResponse = new Map<String,Object> ();

        //If the callout was a success
        if(callOutResult.statusCode == 201 || callOutResult.statusCode == 200){
            createSobjectResponse sObjectResponse 
                    = (createSobjectResponse)JSON.deserialize(responseBody,createSobjectResponse.class);
            return sObjectResponse.id;
        } else {


            //the callout has failed and needs to be handled
            new GeWS_WebServiceException_EH('GeEF_SalesforceRESTServices_WS.createRecord'
                                            , callOutResult
                                            , ''
                                            , 'There has been an error creating a record');
            return null;
        }
    }

    /*******************************************************************
    * @description: attempts to create a list of records in Salesforce
    *               these records MUST BE OF THE SAME TYPE
    * @param: List<sObject> records - list of records to create
    * @return: Boolean - True if the records were created
    * @Throws [Exceptions]: GeWS_WebServiceException_EH
    ********************************************************************/ 
    public Boolean createRecords(List<sObject> records){
        return createRecords(records, GeWS_Constants.SALESFORCE_API);
    }

    /*******************************************************************
    * @description: attempts to create a list of records in Salesforce
    *               these records MUST BE OF THE SAME TYPE
    * @param: String instanceIdentifier - used to identify the custom setting
    *         associated to the Salesforce instance   
    * @param: List<sObject> records - list of records to create
    * @return: Boolean - True if the records were created
    * @Throws [Exceptions]: GeWS_WebServiceException_EH
    ********************************************************************/ 
    public Boolean createRecords(List<sObject> records, String instanceIdentifier){
        //check the records are of the same type
        if(validateRecords(records)){

            //Setup Required Parameters
            serviceName = instanceIdentifier;
            super.initaliseForWebServiceCall(serviceName);
            addServiceToEndPoint(records[0], sObjectTreeService);

            //Make callout
            callOutResult = callOutToWebService ( GeWS_Constants.WS_METHOD_POST
                                                  , endpoint
                                                  , serviceName
                                                  , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
                                                  , JSON.serialize(new createMultipleRequest(records))
                                                  , true ); 
            //If the callout was a success
            if(callOutResult.statusCode == 201 || callOutResult.statusCode == 200){
                createSobjectResponse sObjectResponse 
                        = (createSobjectResponse)JSON.deserialize(callOutResult.body,createSobjectResponse.class);
                return true;
            } else {


                //the callout has failed and needs to be handled
                new GeWS_WebServiceException_EH('GeEF_SalesforceRESTServices_WS.createRecord'
                                                , callOutResult
                                                , ''
                                                , 'There has been an error creating a record');

            }
        }

        return false;
    }

    /*******************************************************************
    * @description: Adds the correct services to the Salesforce endpoint
    * @param: sObject aRecord - The sObject 
    * @Throws [Exceptions]: NullPointerException
    ********************************************************************/ 
    private void addServiceToEndPoint(sObject aRecord , String serviceType){
        endpoint = endpoint.removeEnd('/');
        endpoint = endpoint + serviceType + aRecord.getSobjectType();
    }

    /*******************************************************************
    * @description: determines if the list of records is valid has at 
    *               least 1 and less then 200 records of the same type
    * @param:  List<sObject> records - list of Sobjects to process
    * @return: Boolean - TRUE if valid otherwise FALSE
    * @Throws [Exceptions]: None
    ********************************************************************/ 
    private Boolean validateRecords(List<sObject> records){
        Boolean isValid = true;
        Schema.sObjectType objectType;

        //Check that the record has at least 1 and less then 200 records
        if(records != null && records.size() > 0 && records.size() < 201){
            //Get the object Type
            objectType = records[0].getSobjectType();

            //loop through records check that each record is of the same object type
            for(sObject aRecord : records){
                if(aRecord.getSobjectType() != objectType){
                    isValid = false;
                    break;
                }
            }
        //else this list is not valie
        } else {
            isValid = false;
        }

        return isValid;
    }

    /*******************************************************************
        Purpose: Inner class which is used to create requests for creating multiple records
    ********************************************************************/    
    class createMultipleRequest {
        public List<Map<String, Object>> records;

        //Constructor
        createMultipleRequest(List<sObject> newRecords){
            //Create an instance of the map that represents the records
            records = new List<Map<String, Object>>();
            //a counter is used to populate the reference for each object
            Integer count = 0;
            for(sObject aRecord : newRecords){
                //final map will hold what is used by the API call
                Map<String, Object> finalMapOfObject = new Map<String, Object>();
                //Create a map of all the populated fields for the object
                Map<String, Object> mapOfObject = aRecord.getPopulatedFieldsAsMap();
                //Attributes of type and reference ID must be created
                Map<String, String> attributes = new Map<String, String>();
                attributes.put('type', String.valueOf(aRecord.getSobjectType()));
                attributes.put('referenceId', String.valueOf(count));
                finalMapOfObject.put('attributes', attributes);

                //loop thorugh the fields from the account adding them to 
                //the map of fields that will be used 
                for(String key : mapOfObject.keySet()){
                    finalMapOfObject.put(key,mapOfObject.get(key));
                }
                //add the representation of the current object to the list
                records.add(finalMapOfObject);
                count ++;
            }
        }
    }

    /*******************************************************************
        Purpose: Inner class which is used for responses when Creating records
    ********************************************************************/
    class createSobjectResponse {
        public String id;
        public boolean success;
    }
}