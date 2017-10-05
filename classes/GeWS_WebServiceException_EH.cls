/******************************************************************
 Name:  GeWS_WebServiceException_EH
 Copyright © 2017
 ======================================================
======================================================
Purpose:  Generic web service exception
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Mark Cook 		    21/08/2017          
***********************************************************************/
public with sharing class GeWS_WebServiceException_EH extends GeEF_ExceptionHandler_A {

    /*******************************************************************
    * @description XXXX
    * @param  String theSource - The class and method source of exception
    * @param  GeWS_WebService_A.CallOutResults wsException - Callout results object
    * @param  Exception e - The exception that has been thrown
    * @param  String recordID - the record id related to the exception or record being processed
    * @param  String exceptionMessage - the exception message
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public GeWS_WebServiceException_EH (  String theSource
										, GeWS_WebService_A.CallOutResults wsException
										, Exception e
										, String recordID
										, String exceptionMessage){
		super.populateBaseExceptionObject(theSource, wsException.errorMessage, e);
		addExceptionDetails(recordID, wsException, exceptionMessage);

		processExceptions();
	}


    /*******************************************************************
    * @description XXXX
    * @param  String theSource - The class and method source of exception
    * @param  GeWS_WebService_A.CallOutResults wsException - Callout results object
    * @param  String recordID - the record id related to the exception or record being processed
    * @param  String exceptionMessage - the exception message
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public GeWS_WebServiceException_EH(   String theSource
										, GeWS_WebService_A.CallOutResults wsException
										, String recordID
										, String exceptionMessage){
		try {
			throw new GeEF_Exception('Standard Web Service Exception');
		} catch (Exception e){

			super.populateBaseExceptionObject(theSource, wsException.errorMessage, e);
			addExceptionDetails(recordID, wsException, exceptionMessage);
			processExceptions();
		}
		
	}
    /*******************************************************************
    * @description Populates the exception message with specific details
    *			   relating to this process
    * @param  String recordID - the record id
    * @param  GeWS_WebService_A.CallOutResults wsException - Callout results object
    * @param  String exceptionMessage - the exception message
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	private void addExceptionDetails(  String recordID
									 , GeWS_WebService_A.CallOutResults wsException
									 , String exceptionMessage){

		instanceOfException.RecordtypeId = Ge_CommonUtility_U.getSObjectRecordTypeId(GeEL_Exception__c.sObjectType
																					, 'Web_Service' );
		instanceOfException.System_of_origin__c = 'Salesforce';
		instanceOfException.Record_ID__c = recordID;
		instanceOfException.Web_Service_Method__c = wsException.requestMethod;
		instanceOfException.Status_Code__c = String.valueOf(wsException.statusCode);
		instanceOfException.Request_Body__c = wsException.requestBody;
		instanceOfException.Response_Body__c = wsException.body;
		instanceOfException.Custom_Exception_Message__c = exceptionMessage;

	}

    /*******************************************************************
    * @description Processes the new exception record
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public override void processExceptions() {
		super.createExceptionRecord(false);
	}
}