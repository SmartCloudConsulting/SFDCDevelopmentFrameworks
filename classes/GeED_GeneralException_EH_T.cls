/**********************************************************************
Name:  GeED_GeneralException_EH_T
Copyright © 2017
======================================================
======================================================
Purpose:  Tests the creation of an exception

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Solutions  22/09/2017          
***********************************************************************/ 
@isTest
public with sharing class GeED_GeneralException_EH_T implements geTF_Test_I {
	private static Account testAcc;
	private static String serviceEndPoint = 'https://testResource.com';
	private static GeWS_Security_Credential__c secSetting;
	private static String theSource;
	private static String theErrorMessage;
	private static String relatedProcess;
	private static String exceptionMessage;


   /*******************************************************************
    * @description Sets up the test data, in this example this includes : 
    *			    Creation of Integration Custom Setting
    *				Creation of Security Credential Object
    *				Creation of Account record to use        
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public static void testDataSetup(){
		GeTD_TestData_TF_T testF = new GeTD_TestData_TF_T();
		Integer rand = Math.round(Math.random()*1000);
		//Used the Exceptions DAO as these are linked
		GeEF_Exception_DAO excptionDAO = new GeEF_Exception_DAO();

		String credentialIdentifier = 'Salesforce';
		//Create the new custom setting
		GeWS_WebService_Integration_Settings__c newSetting 
									= testF.newWSIntegrationSetting(  serviceEndPoint
																	, credentialIdentifier
																	, credentialIdentifier);
		insert newSetting;

		GeWS_Security_Credential__c newSecCred
									= testF.newoAuth2SecurityCredential( 'http://authenticate.com'
																		, credentialIdentifier
																		, serviceEndPoint);
		insert newSecCred;
		testAcc = testF.createNewAccount();

		//Exception handler
		insert testF.newExceptionLogging();

		//Create static Strings used in test class
		theSource = 'theSource' + rand;
		theErrorMessage = 'theErrorMessage' + rand;
		relatedProcess = 'theRelatedProcess' + rand;
		exceptionMessage = 'theExceptionMessage' + rand;
	}




    /*******************************************************************
    * @description checks that the exception Object to be inserted is created as expected         
    ********************************************************************/
    @isTest static void creationOfExceptionObjectToInsert() {
        testDataSetup();

        Test.startTest();

	        GeED_GeneralException_EH sample;
	        //Throw a custom exception record
	        try{
	        	throw new GeEF_Exception(exceptionMessage);
	    	} catch (Exception e){
	    		//used the exception record within the exception Framework
	    		sample = new GeED_GeneralException_EH(	  theSource
														, theErrorMessage
														, e
														, relatedProcess
														, FALSE
														, 'anID');
	    	}
	    	//Assert that the exception included all the expected details
	    	System.assertEquals(sample.instanceOfException.Related_Process__c, relatedProcess);
        	System.assertEquals(sample.instanceOfException.Record_ID__c, 'anID');
        	System.assertEquals(sample.instanceOfException.Exception_Message__c, exceptionMessage);
        	System.assert(sample.instanceOfException.Exception_Type__c.contains('GeEF_Exception'));

        Test.stopTest();
    }


    /*******************************************************************
    * @description checks that the throwing another exception works as expected            
    ********************************************************************/
    @isTest static void throwAnotherException() {
        testDataSetup();

        Test.startTest();
        	//used to determine if another exception is thrown
        	Boolean threwAnotherException = false;
	        GeED_GeneralException_EH sample;
	        //Create an exception
	        try{
	        	throw new GeEF_Exception(exceptionMessage);
	    	} catch (Exception e){
	    		//Another exception will be thrown
	    		try{
		    		sample = new GeED_GeneralException_EH(	  theSource
															, theErrorMessage
															, e
															);
	    		} catch(Exception e1){
	    			threwAnotherException = true;
	    		}
	    	}
	    	//assert that the following exception was thrown as expected
        	System.assert(threwAnotherException);

        Test.stopTest();
    }

   /*******************************************************************
    * @description Creates an exception record using the framework 
    * the framework will detect that we are in a test scenario and will not queue a job
    * instead it will insert a record. To check this the query must be between the Start and stop test
    ********************************************************************/
    @isTest static void creationExceptionUsingFramework() {
        testDataSetup();

        Test.startTest();
        	GeED_GeneralException_EH sample;
	        //Create an exception
	        try{
	        	throw new GeEF_Exception(exceptionMessage);
	    	} catch (Exception e){
    
	    		sample = new GeED_GeneralException_EH(	  theSource
														, theErrorMessage
														, e
														, relatedProcess
														, false
														, 'anID');
	    		
	    	}

	        //test that the exception is created
	        GeEF_Exception_DAO excptionDao = new GeEF_Exception_DAO();
	        Map<Id, GeEL_Exception__c> someExceptions = excptionDao.getMapOfExceptions();

	        System.assert(someExceptions != null);
	        System.assert(someExceptions.values().size() == 1);
	        //test the exception record created has the expcted values
	        for(GeEL_Exception__c anException : someExceptions.values()){
		    	System.assertEquals(anException.Related_Process__c, relatedProcess);
	        	System.assertEquals(anException.Record_ID__c, 'anID');
	        	System.assertEquals(anException.Exception_Message__c, exceptionMessage);
	        	System.assert(anException.Exception_Type__c.contains('GeEF_Exception'));
	        }
        Test.stopTest();

    }


   /*******************************************************************
    * @description Creates an exception record using the framework when the queable jobs limit is reached
    * the framework will detect that we are in a test scenario and will not queue a job
    * instead it will insert a record. To check this the query must be between the Start and stop test
    ********************************************************************/
    @isTest static void creationExceptionWhenQueableJobLimitReached() {
        testDataSetup();

        Test.startTest();
        	GeED_GeneralException_EH sample;
	        //Create an exception
	        try{
	        	throw new GeEF_Exception(exceptionMessage);
	    	} catch (Exception e){
	    		//Loop through
    			while (Limits.getLimitQueueableJobs() != Limits.getQueueableJobs()) {

		        	GeEL_Exception__c atestRecord = new GeEL_Exception__c();
		        	atestRecord.Related_Process__c = relatedProcess;
		        	atestRecord.Record_ID__c = 'anID';
		        	atestRecord.Exception_Message__c = exceptionMessage;
		        	atestRecord.Exception_Type__c = 'test';
		        	List<GeEL_Exception__c> testExceptions = new List<GeEL_Exception__c>();	
		        	testExceptions.add(atestRecord);
					System.enqueueJob(new GeEF_ExceptionHandler_A.ExecuteExceptionCalloutLogic_Q(testExceptions 
																								, 'sessionId')); 

				
    			}

    			//
	    		sample = new GeED_GeneralException_EH(	  theSource + 'FutureJob'
														, theErrorMessage
														, e
														, relatedProcess + 'FutureJob'
														, false
														, 'newID');		
	    		
	    	}

	    	System.assertEquals(sample.instanceOfException.Related_Process__c, relatedProcess + 'FutureJob');
        	System.assertEquals(sample.instanceOfException.Record_ID__c, 'newID');
        	System.assertEquals(sample.instanceOfException.Exception_Message__c, exceptionMessage);
        	System.assert(sample.instanceOfException.Exception_Type__c.contains('GeEF_Exception'));

        Test.stopTest();

    }


   /*******************************************************************
    * @description Creates an exception record using the A-sync process within the framework   
    ********************************************************************/
    @isTest static void creationExceptionUsingAsync() {
        testDataSetup();

        Test.startTest();
        	GeEL_Exception__c atestRecord = new GeEL_Exception__c();
        	atestRecord.Related_Process__c = relatedProcess;
        	atestRecord.Record_ID__c = 'anID';
        	atestRecord.Exception_Message__c = exceptionMessage;
        	atestRecord.Exception_Type__c = 'test';
        	List<GeEL_Exception__c> testExceptions = new List<GeEL_Exception__c>();	
        	testExceptions.add(atestRecord);
	    	//queue a job that will insert the exception into the system
			System.enqueueJob(new GeEF_ExceptionHandler_A.ExecuteExceptionCalloutLogic_Q(testExceptions 
																						, 'sessionId'));

        Test.stopTest();
        //test that the exception is created
        GeEF_Exception_DAO excptionDao = new GeEF_Exception_DAO();
        Map<Id, GeEL_Exception__c> someExceptions = excptionDao.getMapOfExceptions();

        System.assert(someExceptions != null);
        System.assert(someExceptions.values().size() == 1);
        //test the exception record created has the expcted values
        for(GeEL_Exception__c anException : someExceptions.values()){
	    	System.assertEquals(anException.Related_Process__c, relatedProcess);
        	System.assertEquals(anException.Record_ID__c, 'anID');
        	System.assertEquals(anException.Exception_Message__c, exceptionMessage);
        	System.assert(anException.Exception_Type__c.contains('test'));
        }
    }
    
   /*******************************************************************
    * @description test a batch mode of creating exceptions
    ********************************************************************/
    @isTest static void creationExceptionUsingFrameworkInBatch() {
        testDataSetup();

        Test.startTest();
        	//Turn on bulk processing mode
        	GeEF_ExceptionHandler_A.isInBatchMode = TRUE;

        	GeED_GeneralException_EH sample;
	        //Create an exception
	        try{
	        	throw new GeEF_Exception(exceptionMessage);
	    	} catch (Exception e){
	    		for(Integer i = 0; i < 42; i++) {	
		    		sample = new GeED_GeneralException_EH(theSource
														, theErrorMessage
														, e
														, relatedProcess
														, false
														, 'anID');
	    		}
	    		
	    	}
	    	//Use the bulk option to create the exceptions at the end
	    	GeEF_ExceptionHandler_A.createExceptionRecord();

	        //test that the exception is created
	        GeEF_Exception_DAO excptionDao = new GeEF_Exception_DAO();
	        Map<Id, GeEL_Exception__c> someExceptions = excptionDao.getMapOfExceptions();

	        System.assert(someExceptions != null);
	        System.assert(someExceptions.values().size() == 42);
	        //test the exception record created has the expcted values
	        for(GeEL_Exception__c anException : someExceptions.values()){
		    	System.assertEquals(anException.Related_Process__c, relatedProcess);
	        	System.assertEquals(anException.Record_ID__c, 'anID');
	        	System.assertEquals(anException.Exception_Message__c, exceptionMessage);
	        	System.assert(anException.Exception_Type__c.contains('GeEF_Exception'));
	        }
        Test.stopTest();
    }

}