/******************************************************************
 Name:  GeEF_ExceptionHandler_A
 Copyright © 2017
 ======================================================
======================================================
Purpose:  Abstract method to handle all exceptions
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Mark Cook           21/08/2017          
***********************************************************************/  
public abstract class GeEF_ExceptionHandler_A implements GeEF_Exception_I{

    //Variable used if we wish to queue up exceptions before processing
    public static Boolean isInBatchMode = FALSE;
    //Captures if the EH has already processed an Exception
    private static Boolean exceptionAlreadyProcessed = FALSE;

    //list of Exception objects used in batch processing
    private static List<GeEL_Exception__c> allExceptionObjects = new List<GeEL_Exception__c>();
    private static String sessionId;
    @testvisible
    protected GeEL_Exception__c instanceOfException;

    //Abstract method overwriden in each EH to determine how records are processed
    protected abstract void processExceptions();

    /*******************************************************************
    * @description populates the core exception record fields from a standard
    *              Salesforce exception and also allows the source of the 
    *              exception to be captured
    * @param  Exception e - an instance of a Salesforce Exception record
    * @param  String errorMessage - a String of any custom error details
    * @param  String theSource - a string representation of the source
    *                            of the exception e.g aClass.aMethod
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected void populateBaseExceptionObject(String theSource, String errorMessage, Exception e){
        populateBaseExceptionObject(theSource, e);
        instanceOfException.Custom_Exception_Message__c = errorMessage;
    }

    /*******************************************************************
    * @description populates the core exception record fields from a standard
    *              Salesforce exception and also allows the source of the 
    *              exception to be captured
    * @param  Exception e - an instance of a Salesforce Exception record
    * @param  String theSource - a string representation of the source
    *                            of the exception e.g aClass.aMethod
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected void populateBaseExceptionObject(String theSource, Exception e){
        populateBaseExceptionObject(e);
        instanceOfException.ClassSource__c = theSource;
    }

    /*******************************************************************
    * @description populates the core exception record fields from a standard
    *              Salesforce exception 
    * @param  Exception e - an instance of a Salesforce Exception record       
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected void populateBaseExceptionObject(Exception e){
        attemptToCaptureSession();
        //create an isntace based on the excepton
        GeEL_Exception__c instanceOfException = new GeEL_Exception__c();
        instanceOfException.Exception_Message__c = e.getMessage();
        instanceOfException.Exception_Type__c = e.getTypeName();
        instanceOfException.Line_Number__c = String.valueOf(e.getLineNumber());
        instanceOfException.StackTrace__c = e.getStackTraceString();

        this.instanceOfException = instanceOfException;
    }

    /*******************************************************************
    * @description Creates the exception follwoing a defined process
    *              Depending on the Salesforce context a different method
    *              is required. For example no insert are allowed in a VF Constructor
    *              The below method attempts the insert using a heirarchy of 
    *              the most likely to least likey methods to work.
    * @param  Boolean overrideExceptionProcessed - Ignore the fact an existing 
    *          Exception has already been logged and might be the route cause for 
    *          this follow up exception
    * @param  Boolean throwAnotherException - throw another exception to bubble up 
    * @param  String exceptionMessage - message to use on the exception to bubble up  
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected void createExceptionRecord(  Boolean overrideExceptionProcessed
                                         , Boolean throwAnotherException
                                         , String exceptionMessage) {
        
        createExceptionRecord(overrideExceptionProcessed);

        //This prevents the use of DML to insert the Record
        if (throwAnotherException) {
            if (exceptionMessage == null) {
                exceptionMessage = '';
            }
            throw new GeEF_Exception();
        }       
    }

    /*******************************************************************
    * @description Adds the exception to a list of exceptions and if 
    *              appropriate calls the method to create the exception
    * @param  Boolean overrideExceptionProcessed - Ignore the fact an existing 
    *          Exception has already been logged and might be the route cause for 
    *          this follow up exception 
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    protected void createExceptionRecord( Boolean overrideExceptionProcessed) {

        //if not in batch
        if(!System.isBatch() && shouldCreateExceptionRecord(overrideExceptionProcessed)){
            //Add the excetion to the list of exceptions
            allExceptionObjects.add(instanceOfException);
            //If not in a batch mode then attempt to create the exception
            if(!isInBatchMode){
                createExceptionRecord();
            }
        }
        // Set static variable to prevent multiple exception emails/objects from being sent/created to true  
        exceptionAlreadyProcessed = TRUE;
    }

    /*******************************************************************
    * @description Creates the exception following a defined process
    *              Depending on the Salesforce context a different method
    *              is required. For example no insert are allowed in a VF Constructor
    *              The below method attempts the insert using a heirarchy of 
    *              the most likely to least likey methods to work.
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static void createExceptionRecord(){
        Boolean reachQueableLimit = FALSE;
        Boolean exceptionCreated = FALSE;

        //Checks if we have maxed out the queueable jobs and switches logic
        if(Limits.getLimitQueueableJobs() == Limits.getQueueableJobs()){
            reachQueableLimit = TRUE;
        }

        if(!reachQueableLimit){
            //First attempt to queue a future job to create the exception using a REST Call
            exceptionCreated = attemptToQueueJobToCreateException();           
        }

        //if failed attempt to do an API Call
        if(!exceptionCreated){
            exceptionCreated = createExceptionsWithRESTCall(allExceptionObjects);
        }
        //if failed attempt to do an Future Method
        if(!exceptionCreated){
            executeExceptionFuture(JSON.serialize(allExceptionObjects));
        }

        //If the other methods have failed attempt to create the exception using the DAO
        if(!exceptionCreated){
            exceptionCreated = insertRecords(allExceptionObjects);
        }
        //clear the list of exceptions
        allExceptionObjects = new List<GeEL_Exception__c>();
    }

    /*******************************************************************
    * @description Captures the user session to be used in API calls 
    *              where required                        
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private void attemptToCaptureSession(){
        try {
            sessionId = UserInfo.getSessionId();
        } catch (Exception e) {
            sessionId = null;
        }   
    }

    /*******************************************************************
    * @description Used to determine if an exception record should be created
    *              this based on the Hierarchical Custom Setting and
    *              if an exception has already been processed
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private boolean shouldCreateExceptionRecord(Boolean overrideExceptionProcessed){
        return GeEF_Exception_Logging__c.getInstance().Create_Exceptions__c 
                                            && (!overrideExceptionProcessed);
    }

    /*******************************************************************
    * @description Calls the appropriate Web Service to create the 
    *              Exception record
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private static Boolean createExceptionsWithRESTCall(List<GeEL_Exception__c> instanceOfExceptions){
        try{
            //create an instance of a WS
            GeEF_SalesforceRESTServices_WS sfdcWebServ = new GeEF_SalesforceRESTServices_WS();
            Boolean hasCreateRecords = FALSE;

            //Only 200 hundred records per call
            List<GeEL_Exception__c> exceptionsForWS = new List<GeEL_Exception__c>();
            //Loop through the records inserting 199 at a time
            for(GeEL_Exception__c aRecord : instanceOfExceptions){
                exceptionsForWS.add(aRecord);
                //If there are more then 198, do ws Call and refresh list
                if(exceptionsForWS.size() > 198){
                    hasCreateRecords = sfdcWebServ.createRecords(instanceOfExceptions);
                    exceptionsForWS = new List<GeEL_Exception__c>();
                }
            }

            //If there are any not yet inserted, then call WS
            if(exceptionsForWS.size() != 0){
                hasCreateRecords = sfdcWebServ.createRecords(instanceOfExceptions);
            }
            
            return hasCreateRecords; 
        } catch (Exception e){
            return FALSE;
        }
    }

    /*******************************************************************
    * @description Inserts the record using the Exception
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private static Boolean insertRecords(List<GeEL_Exception__c> exceptionsToInsert){
        try {
            insert exceptionsToInsert;
            return TRUE;
        } catch (Exception e) {
            /*
            * This is the last method of attempting insert
            * if this method fails no Exception record will be created
            */
            return FALSE;
        }
    }

    /*******************************************************************
    * @description Attempts to Queue a Job to create the Exception Record
    * @return Boolean - TRUE if the job was queued
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private static Boolean attemptToQueueJobToCreateException(){
        try {
            if (!Test.isRunningTest()) {
                System.enqueueJob(new ExecuteExceptionCalloutLogic_Q(allExceptionObjects 
                                                                    , sessionId));
                return TRUE;
            } else {
                return FALSE;
            }
        } catch (Exception e1) {
            return TRUE;
        }
    }

    /*******************************************************************
       Purpose: Handles logic to call exception service                                      
       Parameters: exceptionToInsert - an instance of an ExceptionClass object (inner class in clsUtil) which contains all necessary parameters with 
                   which to create exception object, sendEmail - if an email should be sent or not, overrideExceptionAlreadySent - overrides the static 
                   variable which prevents multiple exception emails/objects from being sent/created, throwAnotherException - if another exception 
                   should be thrown or not, exceptionMessage - the message of the exception to be thrown
       Returns: Void
       Throws [Exceptions]: N/A                                                
    ********************************************************************/  
    private static void executeCalloutLogicAsync( List<GeEL_Exception__c> exceptionObjects
                                                , String sessionId) {
        createAsyncException(exceptionObjects);
    }


    /*******************************************************************
    * @description Creates an exception using a future call
    * @param  GeEL_Exception__c - Exception object to create
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    @future (callout=true)
    public static void executeExceptionFuture(String exceptionRecord) {
        List<GeEL_Exception__c> exceptionObject 
                            = (List<GeEL_Exception__c>) JSON.deserializeStrict(exceptionRecord, List<GeEL_Exception__c>.class);
        createAsyncException(exceptionObject);
    }

    /*******************************************************************
    * @description Creates the exception in a-SyncContext
    * @param  GeEL_Exception__c - Exception object to create
    * @return VOID
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private static void createAsyncException(List<GeEL_Exception__c> exceptionObjs){
        Boolean exceptionCreated = FALSE;
        //First attempt to create using a REST Call
        exceptionCreated = createExceptionsWithRESTCall(exceptionObjs);

        //if failed attempt to create using
        if(!exceptionCreated){
            exceptionCreated = insertRecords(exceptionObjs);
        }          
    }

    /*******************************************************************
        Purpose: Inner class which implements the Queueable interface to allow callout logic to be performed asynchronously                                                                                   
    ********************************************************************/
    public class ExecuteExceptionCalloutLogic_Q implements Queueable, Database.AllowsCallouts {
        private List<GeEL_Exception__c> exceptionObjects;
        private String givenSessionId;

        public ExecuteExceptionCalloutLogic_Q(List<GeEL_Exception__c> exceptionObjects, String sessionId) {
            this.exceptionObjects = exceptionObjects;
            this.givenSessionId = sessionId;
        }        
        /*******************************************************************
            Purpose: Sends exception emails                                       
            Parameters: exceptionToInsert - the exception class which contains all details of the exception
            Returns: Set of strings
            Throws [Exceptions]:                                                         
        ********************************************************************/
        public void execute(QueueableContext context) {
            GeEF_ExceptionHandler_A.executeCalloutLogicAsync(exceptionObjects
                                                            , sessionId);
        }
    }
}