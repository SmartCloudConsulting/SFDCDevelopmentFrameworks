/**********************************************************************
Name:  Account
 Copyright Â© 2017
======================================================
======================================================
Purpose: Trigger for Account
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                         FEATURES/CSR/TTP
   1.0      Mark Cook 		    28/06/2017         
***********************************************************************/
trigger Account on Account (before insert, 
							before update, 
							before delete, 
							after insert, 
							after update, 
							after delete, 
							after undelete) {

    GeTF_TriggerDispatcher_V dispatcher = new GeTF_TriggerDispatcher_V();

    if (Trigger.isAfter) {
	    if (Trigger.isUpdate) {
	    	//Update the Record type on Contacts relating to an Account
	        dispatcher.addOperation(new Ge_ContactSharing_TH(Trigger.newMap, Trigger.oldMap));
	    }
    }

    dispatcher.dispatch();
}