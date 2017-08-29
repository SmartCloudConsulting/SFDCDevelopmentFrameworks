/**********************************************************************
 Name:  GeTF_Trigger_I
 Copyright © 2016
 ======================================================
======================================================
Purpose:  interface to  methods used in trigger helper classes

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Mark Cook 		    01/02/2017          
***********************************************************************/  

public interface GeTF_Trigger_I {
     /* Filters the records passed for 
      * logic to by applied.  This has no parameters.
      * Constructors need be overriden to pass params.
      * */
      void filterRecords();

     /* Used to determine if there are records that should 
      * be processed by this instance of a trigger
      * */
      boolean hasRecordsToProcess();
         
     /* this method should be used to do the logic 
      * for every class. 
      * */
      void execute();
}