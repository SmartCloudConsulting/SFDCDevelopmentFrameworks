/**********************************************************************
 Name:  TriggerDispatcher_V
 Copyright © 2016
 ======================================================
======================================================
Purpose:  Class to control dispatch and flow of all trigger logic.  This dispatcher class
 	      should be used to execute all trigger helper classes by adding them to the 
      	  operation stack.
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Mark Cook 		     01/02/2016            
***********************************************************************/ 

/*
 * USAGE: an instance of MM_TriggerDispatcher_V should be instantiated and addOperation should
 *        be chained in order to add functionality to the trigger.  triggers should finally
 *        call the dispatch method in order to execute all functionality.
 *
 *        E.G. *********************************************************************************************
 *               MM_TriggerDispatcher_V d = new MM_TriggerDispatcher_V();                   // instantiate
 *               d.addOperation(new MM_ExampleClass_TH(Trigger.newMap, Trigger.oldMap))     // add first operation 
 *                .addOperation(new MM_AnotherClass_TH(Trigger.newMap, Trigger.oldMap));    // chain further operations
 *               d.dispatch();                                                              // dispatch the queue to be executed
 *             *********************************************************************************************
 *
 * */

public virtual class GeTF_TriggerDispatcher_V {
    /* operations to be completed by the dispatcher */
    private List<GeTF_Trigger_I> operations;
    
    /* basic instantiation of the class should initialise the op list */
    public GeTF_TriggerDispatcher_V () { 
        this.operations = new List<GeTF_Trigger_I>();
    }
    
    /* add an operation to the queue */ 
    public GeTF_TriggerDispatcher_V addOperation (GeTF_Trigger_I op) {
    	
        operations.add(op);
        return this;
    }
    
    /* dispatch all operations in the queue */
    public void dispatch() {
// @TODO: handle recursion in trigger
               
        if(!operations.isEmpty()) {
            for (GeTF_Trigger_I op : operations) { 
                try {
                    op.filterRecords(); 
                   /* If there are records to process then
                    * execute the trigger against these records
                    */
                    if(op.hasRecordsToProcess()){
                        op.execute();
                    }
                    
                } catch (Exception e) {
// @TODO: Plug in Exception Framework to handle these cleanly
                }
            }
        }
    }
}