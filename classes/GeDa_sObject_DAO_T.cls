/**********************************************************************
Name:  GeDA_sObject_DAO_T
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
@isTest
private class GeDa_sObject_DAO_T {
	//Private Variables for this test class
	private static GeDA_Activities_DAO testDAO;
	private static List<Account> testAccounts;
	private static final String stringToShowUpdate = '-UpdatedName';

    /*******************************************************************
    * @description Used to create the relevant test data for each of the 
    				test                          
    ********************************************************************/ 
	private static void testDataSetup(){
		// Create new instance of required classes
		GeTD_TestData_TF_T testDataSetup = new GeTD_TestData_TF_T();
		testDAO = new GeDA_Activities_DAO();
		//Populate the test Accounts
		testAccounts = testDataSetup.createTestAccounts(10);
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it inserts 
    				the record                            
    ********************************************************************/   
	@isTest static void insertARecord() {
		testDataSetup();
		Test.startTest();
			Account anAccount = testAccounts[0];
			testDAO.doInsert(anAccount);
			System.assert(
							!String.isBlank(
									String.valueOf(anAccount.Id)
								)
						);
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it inserts 
    			   a list of records                           
    ********************************************************************/   
	@isTest static void insertListOfRecords() {
		testDataSetup();
		Test.startTest();
			testDAO.doInsert(testAccounts);
			for(Account anAccount : testAccounts){
				System.assert(
								!String.isBlank(
										String.valueOf(anAccount.Id)
									)
							);
			}
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it upserts 
    				the record                            
    ********************************************************************/   
	@isTest static void upsertARecord() {
		testDataSetup();
		Test.startTest();
			Account anAccount = testAccounts[0];
			testDAO.doUpsert(anAccount);
			System.assert(
							!String.isBlank(
									String.valueOf(anAccount.Id)
								)
						);
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it upserts 
    			   a list of records                           
    ********************************************************************/   
	@isTest static void upsertListOfRecords() {
		testDataSetup();
		Test.startTest();
			testDAO.doUpsert(testAccounts);
			for(Account anAccount : testAccounts){
				System.assert(
								!String.isBlank(
										String.valueOf(anAccount.Id)
									)
							);
			}
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it updates 
    				the record                            
    ********************************************************************/   
	@isTest static void updateARecord() {
		testDataSetup();
		Test.startTest();
			//Create Record
			Account anAccount = testAccounts[0];
			testDAO.doInsert(anAccount);
			//Update Name In Record
			anAccount.Name = anAccount.Name + stringToShowUpdate;
			testDAO.doUpdate(anAccount);
			//Query name stored
			Account updatedAccount = [SELECT Name FROM Account WHERE id=:anAccount.Id];

			System.assert( updatedAccount.name.contains(stringToShowUpdate));
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it updates 
    			   a list of records                           
    ********************************************************************/   
	@isTest static void updateListOfRecords() {
		testDataSetup();
		Test.startTest();
			//Create Records
			testDAO.doInsert(testAccounts);
			List<String> listOfIds = new List<String>();
			//update name of all records and capture ID of records
			for(Account anAccount : testAccounts){
				anAccount.Name = anAccount.Name+stringToShowUpdate;
				listOfIds.add(anAccount.Id);
			}
			//Query updated records
			testDAO.doUpdate(testAccounts);
			for(Account updatedAccount : [SELECT Name FROM Account WHERE id IN :listOfIds]){
				System.assert( updatedAccount.name.contains(stringToShowUpdate));
			}
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it deletes 
    				the record                            
    ********************************************************************/   
	@isTest static void deleteARecord() {
		testDataSetup();
		Test.startTest();
			//Create record
			Account anAccount = testAccounts[0];
			testDAO.doInsert(anAccount);
			//delete Record
			testDAO.doDelete(anAccount);
			List<Account> deletedAccounts = new List<Account>();
			//query delted record
			deletedAccounts = [SELECT Name FROM Account WHERE id=:anAccount.Id];
			System.assert( deletedAccounts.size() == 0);
		Test.stopTest();
	}

    /*******************************************************************
    * @description This tests the doInsert Method to ensure it deletes 
    			   a list of records                           
    ********************************************************************/   
	@isTest static void deleteListOfRecords() {
		testDataSetup();
		Test.startTest();
			//Create Record
			testDAO.doInsert(testAccounts);
			List<String> listOfIds = new List<String>();
			//Get list of ID's for records
			for(Account anAccount : testAccounts){
				listOfIds.add(anAccount.Id);
			}
			//Delete Records
			testDAO.doDelete(testAccounts);
			List<Account> deletedAccounts = new List<Account>();
			//query for Deleted records
			deletedAccounts = [SELECT Name FROM Account WHERE id IN :listOfIds];
			System.assert( deletedAccounts.size() == 0);
		Test.stopTest();
	}

    /*******************************************************************
    * @description Unset the SavePoint                         
    ********************************************************************/   
	@isTest static void checkUnSetSavePoint() {	
		testDataSetup();
		Test.startTest();
			System.assert(testDAO.sp == null);
			testDAO.setSavePoint();
			System.assert(testDAO.sp != null);
			testDAO.unSetSavePoint();
			System.assert(testDAO.sp == null);
		Test.stopTest();
	}
}