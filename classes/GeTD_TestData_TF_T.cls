/**********************************************************************
Name:  GeTD_TestData_TF_T
Copyright © 2016
======================================================
======================================================
Purpose:  Creates all Test Data

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Solutions  01/02/2016          
***********************************************************************/  
@isTest
public class GeTD_TestData_TF_T {
/********************************* COMMON METHODS *********************************/

    /*******************************************************************
    * @description returns a random picklist value for a given picklist
    * @param - sObject o - an instance of an Sobject which has the picklist
    * @param - String field - the name of the picklist field
    * @return User - new User record
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
    private String returnRandomPicklistValue(sObject o, String field){
        String picklistValue = '';
        Map<String, Schema.SobjectField> fields =
                            o.getSObjectType().getDescribe().fields.getMap();
        try{
            Schema.DescribeFieldResult fieldResult = fields.get(field).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            

            for (Schema.PicklistEntry f: ple) {
                picklistValue = f.getLabel();
                //add some randomness so we don't always use the same picklist value
                if(Math.round(Math.random()*10) > Math.round(Math.random()*10)){
                    break;
                }
            }           
        } catch (Exception e){
            //DOING NOTHING ABOUT THIS
        }
    
        return picklistValue;
    }

/********************************* CREATE AN ACCOUNT RECORD *********************************/

    /*******************************************************************
    * @description Create a list of Test Accounts  
    * @Param - numberOfAccounts number of Accounts to create                          
    ********************************************************************/   
	public List<Account> createTestAccounts(Integer numberOfAccounts){
		List<Account> accountsToReturn = new List<Account>();
		for(Integer i = 0; i < numberOfAccounts; i++) {
			accountsToReturn.add(createNewAccount());
		}
		return accountsToReturn;
	}

    /*******************************************************************
    * @description Create a list of Test Accounts with a given RecordTypeId
    * @Param - recordTypeId RecordType of the record
    * @Param - numberOfAccounts number of Accounts to create                          
    ********************************************************************/  
	public List<Account> createTestAccounts(Id recordTypeId, Integer numberOfAccounts){
		List<Account> accountsToReturn = createTestAccounts(numberOfAccounts);
		for(Account anAccount : accountsToReturn){
//			anAccount.recordTypeId = recordTypeId;
		}
		return accountsToReturn;	
	}	

    /*******************************************************************
    * @description Create a list of Test Accounts with a given RecordTypeId
    * @Param - recordTypeName RecordType name of the record
    * @Param - numberOfAccounts number of Accounts to create                          
    ********************************************************************/  
    public List<Account> createTestAccounts(String recordTypeName, Integer numberOfAccounts){
        List<Account> accountsToReturn = createTestAccounts(numberOfAccounts);
        for(Account anAccount : accountsToReturn){
  //          anAccount.recordTypeId 
  //                  = Ge_CommonUtility_U.getSObjectRecordTypeId(  Account.sObjectType
  //                                                              , recordTypeName);
        }
        return accountsToReturn;    
    }

    /*******************************************************************
    * @description Create new Account with a random Account Name                        
    ********************************************************************/
	public Account createNewAccount(){
		Integer rand = Math.round(Math.random()*1000);
		return createNewAccount('Test-'+rand);
	}

    /*******************************************************************
    * @description Create a new Account with a defined Account Name
    * @Param - String accName - name for the test account                  
    ********************************************************************/
    public Account createNewAccount(String accName){
        Account aNewAccount = new Account(Name=accName);
        return aNewAccount;
    }

    /*******************************************************************
    * @description Create a list of Test Accounts with a given RecordType
    *              insert the accounts and then returns the quried values(POST TRIGGERS AND WORKFLOWS)
    * @Param - recordTypeName RecordType name of the record
    * @Param - numberOfAccounts number of Accounts to create                          
    ********************************************************************/  
    public List<Account> createAccAndQueryInsertedAcc(String recordTypeName, Integer numberOfAccounts){
        List<Account> accountsToReturn = createTestAccounts(recordTypeName, numberOfAccounts);
        Set<Id> newAccountIds = new Set<Id>();
        Ge_Account_DAO accDao = new Ge_Account_DAO();
        accDao.doInsert(accountsToReturn);
        for(Account anAcc : accountsToReturn){
            newAccountIds.add(anAcc.Id);
        }
        return accDao.getAccounts(newAccountIds);

    }


/********************************* CREATE AN CONTACT RECORD *********************************/

    /*******************************************************************
    * @description Create a list of Test Contacts  
    * @Param - numberOfContacts number of Contacts to create                          
    ********************************************************************/   
    public List<Contact> createTestContacts(Integer numberOfContacts){
        List<Contact> contactsToReturn = new List<Contact>();
        for(Integer i = 0; i < numberOfContacts; i++) {
            contactsToReturn.add(createNewContact(null));
        }
        return contactsToReturn;
    }

    /*******************************************************************
    * @description Create a list of Test Contacts  
    * @Param - numberOfContacts number of Contacts to create 
    * @Param - AccountId Account record to link the Contacts with                       
    ********************************************************************/   
    public List<Contact> createTestContacts(Integer numberOfContacts, Id accountId){
        List<Contact> contactsToReturn = new List<Contact>();
        for(Integer i = 0; i < numberOfContacts; i++) {
            contactsToReturn.add(createNewContact(accountId));
        }
        return contactsToReturn;
    }

    /*******************************************************************
    * @description Create new Contact with a random Last Name                        
    ********************************************************************/
    public Contact createNewContact(Id accountId){
        Integer rand = Math.round(Math.random()*1000);
        return createNewContact('Test-'+rand, accountId);
    }

    /*******************************************************************
    * @description Create a new Contact with a defined Last Name
    * @Param - String contactName - name for the test Contact
     * @Param - Id accountId - Account Id to link the contact with                
    ********************************************************************/
    public Contact createNewContact(String contactName, Id accountId){
        Contact aNewContact = new Contact(LastName=contactName);
        if(accountId != null){
            aNewContact.AccountId = accountId;
        }
        return aNewContact;
    }

/********************************* CREATE AN Opportunity RECORD *********************************/

    /*******************************************************************
    * @description Create a list of Test Accounts with a given RecordTypeId
    * @Param - recordTypeId RecordType of the record
    * @Param - numberOfAccounts number of Accounts to create                          
    ********************************************************************/
    public List<Opportunity> createOpportunities(Integer count
    											, List<Account> accounts
    											, String stage
    											, String recordTypeId
    											, String type){

        List<Opportunity> opps = new List<Opportunity>();   

            for (Integer i = 0; i < count; i++)
            {
            	Integer rand = Math.round(Math.random()*1000);
                Opportunity opp = new Opportunity();
                opp.Name = 'Test Opportunity '+ rand;
                opp.AccountId = accounts.get(i).Id;
                opp.Amount = 1000;
                opp.StageName = stage;
                opp.CloseDate = System.today() + 30;
//                opp.RecordTypeId = recordTypeId;    
                opp.Type = type;

                opps.add(opp);
            }
        return opps;
    }




/********************************* CREATE AN CASE RECORD *********************************/

    /*******************************************************************
    * @description Creates a new basic Case Record
    * @param - String accountId account Id for the Case
    * @param - Integer recordsToReturn - Number of records to create
    * @param - String recordType - record type of case to create
    ********************************************************************/
    public List<Case> createListOfCases (String accountId
                                       , Integer recordsToReturn
                                       , String recordTypeDevName){
        List<Case>  listOfCases = new List<Case> ();

        for (Integer i = 0; i < recordsToReturn; i++){
           listOfCases.add(newCaseRecord(accountId,recordTypeDevName));
        }
        return listOfCases;
    }

    /*******************************************************************
    * @description Creates a new basic Case Record
    * @param - String accountId account Id for the Case
    ********************************************************************/
    public Case newCaseRecord(String accountId
                            , String recordTypeDevName){
        Case aNewCase = new Case();
        String recordTypeId = Ge_CommonUtility_U.getSObjectRecordTypeId(  Case.sObjectType
                                                                        , recordTypeDevName);

        aNewCase.AccountId = accountId;
//        aNewCase.RecordTypeId = recordTypeId;

        return aNewCase;
    }

/********************************* CREATE A TASK RECORD *********************************/

    /*******************************************************************
    * @description Creates a new basic Task Record
    * @param - String whatId record the task is associated to
    * @param - Integer recordsToReturn - Number of records to create
    * @param - String recordType - record type of Task to create
    ********************************************************************/
    public List<Task> createListOfTasks (String whatId
                                       , Integer recordsToReturn
                                       , String recordTypeDevName){
        List<Task>  listOfTasks = new List<Task> ();

        for (Integer i = 0; i < recordsToReturn; i++){
           listOfTasks.add(newTaskRecord(whatId, recordTypeDevName));
        }
        return listOfTasks;
    }

    /*******************************************************************
    * @description Creates a new basic Case Record
    * @param - String whatId record the task is associated to
    * @param - String recordType - record type of Task to create
    ********************************************************************/
    public Task newTaskRecord(String whatId
                            , String recordTypeDevName){
        Task aNewTask = new Task();
        String recordTypeId = Ge_CommonUtility_U.getSObjectRecordTypeId(  Task.sObjectType
                                                                        , recordTypeDevName);
        Integer rand = Math.round(Math.random()*1000);
        aNewTask.WhatId = whatId;
//        aNewTask.RecordTypeId = recordTypeId;
        aNewTask.ActivityDate = Date.valueOf(System.now());
        aNewTask.Subject = 'A Test Subject ' + rand;

        return aNewTask;
    }

/********************************* CREATE AN CAMPAIGN RECORD *********************************/

    /*******************************************************************
    * @description Creates a new basic Campaign Record
    * @param - String recordType - record type of Campaign to create
    ********************************************************************/
    public Campaign newCampaignRecord(String recordTypeDevName){
        Campaign aNewCampaign = new Campaign();
        String recordTypeId = Ge_CommonUtility_U.getSObjectRecordTypeId(  Campaign.sObjectType
                                                                        , recordTypeDevName);
        Integer rand = Math.round(Math.random()*1000);

        aNewCampaign.RecordTypeId = recordTypeId;
        aNewCampaign.Name = 'This is a Test Campaign ' + rand;

        return aNewCampaign;
    }

/********************************* CREATE AN CAMPAIGN MEMBER RECORDS *********************************/

    /*******************************************************************
    * @description Creates a new basic Campaign Record
    * @param - String recordType - record type of Campaign to create
    ********************************************************************/
    public List<CampaignMember> newCampaignMemebers(ID campaignID , List<Contact> contacts){
        List<CampaignMember> newCampaignMemebers = new List<CampaignMember>();

        for(Contact aRecord : contacts){
            if(aRecord.Id != null){
                CampaignMember aCampMember = new CampaignMember();
                aCampMember.CampaignId = campaignID;
//                aCampMember.ContactId = aRecord.Id;
                newCampaignMemebers.add(aCampMember);
            }
        }

        return newCampaignMemebers;
    }
}