/**********************************************************************
Name:  GeDA_sObject_DAO
Copyright © 2016
======================================================
======================================================
Purpose:  base type for the data access layer

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Solutions  01/02/2016          
***********************************************************************/  
public abstract class GeDA_sObject_DAO {
    @TestVisible protected transient System.savePoint sp;
    public enum MM_DmlType { INS, UPD, DEL, UPS }
    
    /*******************************************************************
    * @description Set the savepoint to the current point                                        
    ********************************************************************/
    public void setSavePoint() {
            sp = Database.setSavepoint();
    }
    
    /*******************************************************************
    * @description Set the savepoint to the current point                                     
    ********************************************************************/
    public void unsetSavePoint() {
            sp = null;
    }
    
    /*******************************************************************
    * @description Do an insert for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObject the object to insert                           
    ********************************************************************/    
    public virtual void doInsert(SObject theObject) {
        doDmlSavePointRollback(theObject, MM_DmlType.INS);
    }
    
    /*******************************************************************
    * @description Do an insert for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObjects, list of the object to insert                           
    ********************************************************************/ 
    public virtual void doInsert(List<SObject> theObjects) {
        doDmlSavePointRollback(theObjects, MM_DmlType.INS);
    }
    
    
    /*******************************************************************
    * @description Do an update for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObject the object to insert                           
    ********************************************************************/
    public void doUpdate(SObject theObject) {
        doDmlSavePointRollback(theObject, MM_DmlType.UPD);
    }
    
    /*******************************************************************
    * @description Do an Update for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObjects, list of the object to insert                           
    ********************************************************************/ 
    public void doUpdate(List<SObject> theObjects) {
        doDmlSavePointRollback(theObjects, MM_DmlType.UPD);
    }
    
    
    /*******************************************************************
    * @description Do an upsert for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObject the object to insert                           
    ********************************************************************/ 
    public void doUpsert(SObject theObject) {
        doDmlSavePointRollback(theObject, MM_DmlType.UPS);
    }
    
    /*******************************************************************
    * @description Do an Upsert for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObjects, list of the object to insert                           
    ********************************************************************/  
    public void doUpsert(List<SObject> theObjects) {
        doDmlSavePointRollback(theObjects, MM_DmlType.UPS);
    }
    
    
    /*******************************************************************
    * @description Do an delete for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObject the object to insert                           
    ********************************************************************/ 
    public void doDelete(SObject theObject) {
        doDmlSavePointRollback(theObject, MM_DmlType.DEL);
    }
    
    /*******************************************************************
    * @description Do an Delete for a list using a standardised method in 
                 the sobject dao     
    * @Param - theObjects, list of the object to insert                           
    ********************************************************************/ 
    public void doDelete(List<SObject> theObjects) {
        doDmlSavePointRollback(theObjects, MM_DmlType.DEL);
    } 
    
    /*******************************************************************
    * @description DML any sobject    
    * @Param - theObject the object to insert
    * @Param - opType the operation type to complete on the object                                      
    * @Throws [Exceptions]: Throws DML if the DML operation fails                   
    ********************************************************************/ 
    private void doDmlSavePointRollback(SObject theSObject, MM_DmlType opType) {
        if(sp == null){ 
        	setSavePoint(); 
        }

        try {
            doDml(theSObject, opType);
        } catch (DMLException e) {
            Database.rollback(sp);
//ADD EXCEPTION FRAMEWORK            
            throw e;
        }
    }
    
    /*******************************************************************
    * @description DML any List of sobject    
    * @Param - theSObject list of Sobjects
    * @Param - opType the operation type to complete on the object                                      
    * @Throws [Exceptions]: Throws DML if the DML operation fails                   
    ********************************************************************/ 
    private void doDmlSavePointRollback(List<SObject> theSObject, MM_DmlType opType) {
        if(sp == null) { 
        	setSavePoint(); 
        }

        try {
            doDml(theSObject, opType);
        } catch (DMLException e) {
            Database.rollback(sp);
//ADD EXCEPTION FRAMEWORK 
			throw e;
        }
    }
    
    
    /*******************************************************************
    * @description DML any List of sobject    
    * @Param - theSObject list of Sobjects
    * @Param - opType the operation type to complete on the object                                      
    * @Throws [Exceptions]: Throws DML if the DML operation fails                   
    ********************************************************************/ 
    protected void doDml(List<SObject> theSObject, MM_DmlType opType) {
        if(opType == MM_DmlType.INS) {
            insert theSObject;
        } else if (opType == MM_DmlType.UPD) {
            update theSObject;
        } else if (opType == MM_DmlType.UPS) {
            upsert theSObject;
        } else if (opType == MM_DmlType.DEL) {
            delete theSObject;
        }
    }
    
    
    /*******************************************************************
    * @description DML any sobject    
    * @Param - theObject the object to insert
    * @Param - opType the operation type to complete on the object                                      
    * @Throws [Exceptions]: Throws DML if the DML operation fails                   
    ********************************************************************/
    protected void doDml(SObject theSObject, MM_DmlType opType) {
        if(opType == MM_DmlType.INS) {
            insert theSObject;
        } else if (opType == MM_DmlType.UPD) {
            System.debug('Updating: ' + theSObject);
            update theSObject;
        } else if (opType == MM_DmlType.UPS) {
            upsert theSObject;
        } else if (opType == MM_DmlType.DEL) {
            delete theSObject;
        }
    }
}