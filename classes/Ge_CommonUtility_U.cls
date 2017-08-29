/**********************************************************************
Name:  Ge_CommonUtility_U
Copyright © 2016
======================================================
======================================================
Purpose:  Used to store common Utility methods used throughout the codebase

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Smart Cloud       02/02/2017          
***********************************************************************/ 
public with sharing class Ge_CommonUtility_U {

     private static Map<String,Map<String, String>> objectRecordTypeMap;

    /*******************************************************************
    * @description get a record type given an sobject type and a record Developer  name
    *               usage ... 
    *               getSObjectRecordTypeId(Account.SObjectType, 'SomeRecordTypeDeveloperName')
    * @param  Schema.SObjectType ansObjectType - sObject Schema type
    * @param  String rTName - name of Record Type (DEVELOPER NAME)
    * @return String - the record Type ID
    * @Throws [Exceptions]: RecordTypeException                                                 
    ********************************************************************/
    public static String getSObjectRecordTypeId(Schema.SObjectType ansObjectType, String rTName) {
        Map<String, String> anObjectRTMap;

        //Sets the static resource
        if(objectRecordTypeMap == null){
            objectRecordTypeMap = new Map<String,Map<String, String>>();
        }

        //if object exists in map of Objects and Record Types
        if(objectRecordTypeMap.containsKey(String.valueof(ansObjectType))){
            //Get map of RT's for an Object
            anObjectRTMap = objectRecordTypeMap.get(String.valueof(ansObjectType));

            //If the required RT exists return else exception
            if(anObjectRTMap.containsKey(rTName)){
                return anObjectRTMap.get(rTName);
            } else {
//Exception Framework Needs to be plugged in here<<TO DO>>  
                return null;   
            }

            // Object does not exist in Map of objects
        } else {
            anObjectRTMap = new Map<String, String>();
            //find all RT's for an sObject
            list<RecordType> anObjectRTList = getRecordTypeForSObject(String.valueof(ansObjectType));

            //loop through all RT's and add to Map
            for(RecordType aRT : anObjectRTList){
                anObjectRTMap.put(aRT.DeveloperName, aRT.Id);
            }
            //add to static object to save querying again
            objectRecordTypeMap.put(String.valueof(ansObjectType),anObjectRTMap);

            return anObjectRTMap.get(rTName);
        }

    }  

    /*******************************************************************
    * @description returns all RecordType for a Given Object
    * @param  String ansObject - name of sOBject
    * @return List<RecordType> - Record Type objects for a given object
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static List<RecordType> getRecordTypeForSObject(String ansObject){
        return [SELECT DeveloperName, Id, Name, SobjectType 
                FROM RecordType
                WHERE SobjectType = :ansObject];
    }

    /*******************************************************************
    * @description eturns Map of RT's keyed by DeveloperName
    * @param  String ansObject - name of sOBject
    * @return Map<String, RecordType> - Record Type objects for a given object
    *                                   Dev Name > RecordType sObject
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static Map<String, RecordType> getMapOfRTForSObject(String ansObject){
        List<RecordType> listOfRTs = getRecordTypeForSObject(ansObject);
        Map<String, RecordType> mapOfRT = new Map<String, Recordtype>(); 

        for(RecordType aRecordType : listOfRTs){
            mapOfRT.put(aRecordType.DeveloperName,aRecordType);
        }
        return mapOfRT;
    }
    
    /*******************************************************************
    * @description returns Map of RT's keyed by Id
    * @param  String ansObject - name of sOBject
    * @return Map<String, RecordType> - Record Type objects for a given object
    *                                   RecordType Id > RecordType sObject
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static Map<String, RecordType> getMapOfRTAndIdsForSObject(String ansObject){
        List<RecordType> listOfRTs = getRecordTypeForSObject(ansObject);
        Map<String, RecordType> mapOfRT = new Map<String, Recordtype>(); 

        for(RecordType aRecordType : listOfRTs){
            mapOfRT.put(aRecordType.Id,aRecordType);
        }
        return mapOfRT;
    }

    /*******************************************************************
    * @description returns a RecordType for a Given RecordType ID
    * @param  String aRTID - Id of Record Type Object
    * @return RecordType - Sobject associated to Id
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static RecordType getRecordType(Id aRTID){
        return [SELECT DeveloperName, Id, Name, SobjectType 
                FROM RecordType
                WHERE Id = :aRTID];
    }

    /*******************************************************************
    * @description Checks if a string value is blank or null
    * @param  String aString - to check
    * @return Boolean - TRUE if Blank or Null
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static Boolean isBlankOrNull(String aString) {
        return aString == null || aString == '';
    }

    /*******************************************************************
    * @description Checks if a List value is blank or null
    * @param  List<Object> o - List of undetermined objects to check
    * @return Boolean - TRUE if Blank or Null
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static Boolean isBlankOrNull(List<Object> o) {
        return o == null || o.isEmpty();
    }
    
    /*******************************************************************
    * @description Checks if a Decimal value is blank or null
    * @param  Decimal o - Decimal to check
    * @return Boolean - TRUE if Blank or Null
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public static Boolean isBlankOrNull(Decimal o){
        return o == null || (o == 0);
    }

}