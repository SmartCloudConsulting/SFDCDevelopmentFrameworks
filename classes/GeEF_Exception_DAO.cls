/**********************************************************************
Name:  GeEF_Exception_DAO
Copyright © 2017
======================================================
======================================================
Purpose:  Used to store all queries related to the 
          Exceptions object

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Mark Cook 		    14/03/2017          
***********************************************************************/ 
public with sharing class GeEF_Exception_DAO extends GeDA_SObject_DAO {

    /*******************************************************************
    * @description returns a Map of Exception objects                          
    * @return Map<Id,GeEL_Exception__c>
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public Map<Id,GeEL_Exception__c> getMapOfExceptions(){
        Map<Id, GeEL_Exception__c> mapOfExceptions = new Map<Id,GeEL_Exception__c>();

        for(GeEL_Exception__c objCS : [SELECT Id
        									  , Related_Process__c
        									  , Record_ID__c
        									  , Exception_Message__c
        									  , Exception_Type__c
                            		   FROM GeEL_Exception__c ]){

            mapOfExceptions.put(objCS.id,objCS);
        }
        
        return mapOfExceptions;
    }

}