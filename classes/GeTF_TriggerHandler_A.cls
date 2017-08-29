/**********************************************************************
 Name:  GeTF_TriggerHandler_A
 Copyright © 2016
 ======================================================
======================================================
Purpose:  interface to  methods used in trigger helper classes
		  provides some helpful variables to reduce clutter and repetitiveness in classes.

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Mark Cook 		    01/02/2017      
***********************************************************************/   
 
 public abstract class GeTF_TriggerHandler_A implements GeTF_Trigger_I {
 	public static Boolean recurseFlag = false;

// <<TO DO>> STRIP  OUT REDUNDANT CODE (AS BELOW)
    /* list of operations to be completed by the dispatcher */
    private List<GeTF_Trigger_I> operations = new List<GeTF_Trigger_I>();
    
    /* variables that can be used to hold the initial trigger lists */
    protected Map<Id, SObject> newTrig = new Map<Id, SObject>();
    protected Map<Id, SObject> oldTrig = new Map<Id, SObject>();
    protected List<SObject> trigList = new List<SObject>();
    
    /* this map can be used to store records for processing
     * after the raw trigger input has been filtered.   
     * */ 
    protected Map<Id, SObject> recordsToProcessMap = new Map<Id, SObject>();
    protected List<SObject> recordsToProcessList = new List<SObject>();
    protected List<Id> recordIdsToProcessList = new List<Id>();
    
    
     /* Filters the records passed for 
      * logic to by applied.  This has no parameters.
      * Constructors need be overriden to pass params.
      * */
  	protected abstract void filterRecords();
         
     /* this method should be used to do the logic 
      * for every class. 
      * */
    protected abstract void execute();

     /* Used to determine if there are records that should 
      * be processed by this instance of a trigger
      * */
    public boolean hasRecordsToProcess(){
      boolean recordsToProcess = true;

      if(recordsToProcessMap.isEmpty() 
          && recordsToProcessList.isEmpty() 
          && recordIdsToProcessList.isEmpty()){
        recordsToProcess = false;
      }
      return recordsToProcess;
    }
 }