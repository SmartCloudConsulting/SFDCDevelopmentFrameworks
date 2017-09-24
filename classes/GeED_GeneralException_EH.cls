/******************************************************************
 Name:  GeED_GeneralException_EH
 Copyright © 2017
 ======================================================
======================================================
Purpose:  General exception object
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Mark Cook 		    21/08/2017          
***********************************************************************/
public with sharing class GeED_GeneralException_EH extends GeEF_ExceptionHandler_A {
	private String anErrorMessage;
    private Boolean throwAnotherException;

    /*******************************************************************
    * @description Constructor that populates an exception an instanly 
    *			   processes
    * @param  Exception e - an instance of a Salesforce Exception record
    * @param  String errorMessage - a String of any custom error details
    * @param  String theSource - a string representation of the source
    *							 of the exception e.g aClass.aMethod
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public GeED_GeneralException_EH(String theSource, String errorMessage, Exception e){

        this.throwAnotherException = true;
		super.populateBaseExceptionObject(theSource, errorMessage, e);
		this.anErrorMessage = errorMessage;

		processExceptions();
	}
    /*******************************************************************
    * @description Constructor that populates an exception an instanly 
    *              processes
    * @param  Exception e - an instance of a Salesforce Exception record
    * @param  String errorMessage - a String of any custom error details
    * @param  String theSource - a string representation of the source
    *                            of the exception e.g aClass.aMethod
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public GeED_GeneralException_EH(  String theSource
                                    , String errorMessage
                                    , Exception e
                                    , String relatedProcess
                                    , Boolean throwAnotherException
                                    , String recordId){
        this.throwAnotherException = throwAnotherException;
        super.populateBaseExceptionObject(theSource, errorMessage, e);
        this.anErrorMessage = errorMessage;
        instanceOfException.Related_Process__c = relatedProcess;
        instanceOfException.Record_ID__c = recordId;
        processExceptions();
    }

    /*******************************************************************
    * @description Processes the new exception record
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public override void processExceptions() {
		super.createExceptionRecord(false, throwAnotherException, anErrorMessage);
	}
}