/**********************************************************************
Name:  Ge_Account_DAO
Copyright © 2016
======================================================
======================================================
Purpose:  Used to store all queries related to the 
          Account object

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Mark Cook 		    02/02/2017          
***********************************************************************/ 
public with sharing class Ge_Account_DAO extends GeDA_SObject_DAO {

    /*******************************************************************
    * @description Returns the account related to the ID                          
    * @return Account
    * @param  String - accountId - Id for the Account
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public Account getAnAccount(String accountId) {
		//Create a list of Account Id's
		list<String> accountIds = new List<String>();
		accountIds.add(accountId);
		//Iterate over returned Accounts (There will only be 1)
		for(Account anAccount : getAccounts(accountIds)){
			//Return the first Account
			return anAccount;
		}
		//No Account returened so return null
 		return null;
    }

    /*******************************************************************
    * @description Returns a list of accounts related to the ID's                          
    * @return List<Account>
    * @param  List<String> - accountIds - Ids for the Accounts
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public List<Account> getAccounts(List<String> accountIds) {
 		return getMapOfAccounts(accountIds).values();
    }

    /*******************************************************************
    * @description Returns a list of accounts related to the ID's                          
    * @return List<Account>
    * @param  Set<Id> - accountIds - Ids for the Accounts
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public List<Account> getAccounts(Set<Id> accountIdsSet) {
        List<String> accountIdsList = new List <String>();
        for(Id anId : accountIdsSet){
            accountIdsList.add(anId);
        }

        return getMapOfAccounts(accountIdsList).values();
    }


    /*******************************************************************
    * @description returns a Map of Accounts given a list of Ids                          
    * @return Map<Id,Account>
    * @param  List<String> - accountIds - Ids for the Accounts
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    public Map<Id,Account> getMapOfAccounts(List<String> accountIds){
    	Map<Id, Account> mapOfAccounts = new Map<Id,Account>();

    	for(Account objCS : [SELECT Id
									, Name
									, Fax
									, Phone
									, BillingCity
									, BillingCountry
									, BillingLatitude
									, BillingLongitude
									, BillingPostalCode
									, BillingState
									, BillingStreet
									, Website     
							FROM Account
							WHERE Id IN :accountIds]){

    		mapOfAccounts.put(objCS.id,objCS);
    	}
        
    	return mapOfAccounts;
    }


}