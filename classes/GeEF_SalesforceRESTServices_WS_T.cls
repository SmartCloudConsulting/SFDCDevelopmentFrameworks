/**********************************************************************
Name:  GeEF_SalesforceRESTServices_WS_T
Copyright © 2016
======================================================
======================================================
Purpose:  Tests the Salesforce REST API Calls back into Salesforce itself
		  Also inlcudes tests of the Abstract class

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0    	Smart Cloud Solutions  01/02/2016          
***********************************************************************/  
@isTest
public with sharing class GeEF_SalesforceRESTServices_WS_T implements geTF_Test_I {
	private static Account testAcc;
	private static List<Account> testAccounts;
	private static String serviceEndPoint = 'https://testResource.com';
	private static GeWS_Security_Credential__c secSetting;


   /*******************************************************************
    * @description Sets up the test data, in this example this includes : 
    *			    Creation of Integration Custom Setting
    *				Creation of Security Credential Object
    *				Creation of Account record to use        
    * @Throws [Exceptions]: None                                                 
    ********************************************************************/
	public static void testDataSetup(){
		GeTD_TestData_TF_T testF = new GeTD_TestData_TF_T();
		//Used the Exceptions DAO as these are linked
		GeEF_Exception_DAO excptionDAO = new GeEF_Exception_DAO();

		String credentialIdentifier = 'Salesforce';
		//Create the new custom setting
		GeWS_WebService_Integration_Settings__c newSetting 
									= testF.newWSIntegrationSetting(  serviceEndPoint
																	, credentialIdentifier
																	, credentialIdentifier);
		insert newSetting;

		GeWS_Security_Credential__c newSecCred
									= testF.newoAuth2SecurityCredential( 'http://authenticate.com'
																		, credentialIdentifier
																		, serviceEndPoint);
		insert newSecCred;
		testAcc = testF.createNewAccount();
		testAccounts = testF.createTestAccounts(40);

	}

    /*******************************************************************
    * @description tests the ability to create a record using the current instance                      
    ********************************************************************/ 
	@isTest static void createRecordStandardTest() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGenerator());
		Test.startTest();
			//Create instance of WS and call to create a record
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			String response = sfdcWsRest.createRecord(testAcc);
			//The response should be 
			System.assertEquals(response, 'a2A7E000000B7kfUAC');

		Test.stopTest();
	}

    /*******************************************************************
    * @description tests the ability to create a record specifying instance                         
    ********************************************************************/ 
	@isTest static void createRecordSpecificEnvTest() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGenerator());
		Test.startTest();
			//Create instance of WS and call to create a record
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			String response = sfdcWsRest.createRecord(testAcc, GeWS_Constants.SALESFORCE_API);
			//Check response contains ID
			System.assertEquals(response, 'a2A7E000000B7kfUAC');


		Test.stopTest();
	}

    /*******************************************************************
    * @description tests the error scenario and the creation of an exception                     
    ********************************************************************/ 
	@isTest static void createRecordError() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseErrorGenerator());
		Test.startTest();
			//Create instance of WS and call to create a record
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			String response = sfdcWsRest.createRecord(testAcc);
			//Nothing should be returned, but an exception should be created
			System.assertEquals(response, null);
		Test.stopTest();
	}


    /*******************************************************************
    * @description tests the ability to create multiple records                         
    ********************************************************************/ 
	@isTest static void createMulitRecord() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGeneratorMulti());
		Test.startTest();
			//Create instance of WS and call to create a records
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			Boolean response = sfdcWsRest.createRecords(testAccounts);
			//Check response is true
			System.assert(response);

		Test.stopTest();
	}

    /*******************************************************************
    * @description tests the ability to create multiple records                         
    ********************************************************************/ 
	@isTest static void createMulitRecordSpecificEnv() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGeneratorMulti());
		Test.startTest();
			//Create instance of WS and call to create a records
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			Boolean response = sfdcWsRest.createRecords(testAccounts, GeWS_Constants.SALESFORCE_API);
			//Check response is true
			System.assert(response);

		Test.stopTest();
	}

    /*******************************************************************
    * @description tests the error scenario and the creation of an exception                     
    ********************************************************************/ 
	@isTest static void createMultiRecordError() {
		testDataSetup();

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseErrorGeneratorMulti());
		Test.startTest();
			//Create instance of WS and call to create a records
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			Boolean response = sfdcWsRest.createRecords(testAccounts);
			//check the response is false
			System.assert(!response);
		Test.stopTest();
	}

    /*******************************************************************
    * @description Error when attempting to creating records of a mixed type (accounts and contacts)                  
    ********************************************************************/ 
	@isTest static void createMultiRecordErrorDueToMixedReocrds() {
		testDataSetup();
		List<sObject> testRecords = new List<sObject>();
		testRecords.add(testAcc);
		testRecords.add(new Contact());

		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseErrorGeneratorMulti());
		Test.startTest();
			//Create instance of WS and call to create a records
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			Boolean response = sfdcWsRest.createRecords(testRecords);
			//check the response is false
			System.assert(!response);

			//what happens if we pass a null list
			response = sfdcWsRest.createRecords(null);
			//check the response is false
			System.assert(!response);

		Test.stopTest();
	}


//<<TO DO>> Need to TEST FAILED AUTHENTICATE
/********************************* Classes to Store Mock WS Call Responses *********************************/
    /*******************************************************************
    * @description generates a Successfull Auth call and a faied record Create                 
    ********************************************************************/ 
    public class MockHttpResponseErrorGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) 
        {   
            HttpResponse res = new HttpResponse();
            res.setHeader(GeWS_Constants.CONTENT_TYPE, GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
            if(req.getEndpoint().contains('http://authenticate.com')){
                res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://gimsf--Sprint9Dev.cs86.my.salesforce.com","id":"https://test.salesforce.com/id/00D7E0000008tG7UAI/00558000001jyAsAAI","token_type":"Bearer","issued_at":"1505415231637","signature":"ZMSkPPjzFxTBT13JIMOSLK6+mnVVN3snghF0qwM4sMs="}');
            	res.setStatusCode(200);
            } else {
                res.setBody('[{"message":"Required fields are missing: [Name]","errorCode":"REQUIRED_FIELD_MISSING","fields":["Name"]}]');
            	res.setStatusCode(400);
            } 
            return res;
        }
    }

    /*******************************************************************
    * @description generates a Successfull Auth call and a Successfull record Create                 
    ********************************************************************/ 
    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        {   
            HttpResponse res = new HttpResponse();
            res.setHeader(GeWS_Constants.CONTENT_TYPE, GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
            if(req.getEndpoint().contains('http://authenticate.com')){
                res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://gimsf--Sprint9Dev.cs86.my.salesforce.com","id":"https://test.salesforce.com/id/00D7E0000008tG7UAI/00558000001jyAsAAI","token_type":"Bearer","issued_at":"1505415231637","signature":"ZMSkPPjzFxTBT13JIMOSLK6+mnVVN3snghF0qwM4sMs="}');
            	res.setStatusCode(200);
            } else {
            	res.setBody('{"id":"a2A7E000000B7kfUAC","success":true}');
            	res.setStatusCode(201);
            }
            return res;
        }
    }

    /*******************************************************************
    * @description generates a Successfull Auth call and a Successfull record Create                 
    ********************************************************************/ 
    public class MockHttpResponseGeneratorMulti implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) 
        {   
            HttpResponse res = new HttpResponse();
            res.setHeader(GeWS_Constants.CONTENT_TYPE, GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
            if(req.getEndpoint().contains('http://authenticate.com')){
                res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://gimsf--Sprint9Dev.cs86.my.salesforce.com","id":"https://test.salesforce.com/id/00D7E0000008tG7UAI/00558000001jyAsAAI","token_type":"Bearer","issued_at":"1505415231637","signature":"ZMSkPPjzFxTBT13JIMOSLK6+mnVVN3snghF0qwM4sMs="}');
            	res.setStatusCode(200);
            } else {
            	res.setBody('{"hasErrors":false,"results":[{"referenceId":"0","id":"0017E00000coRVyQAM"},{"referenceId":"1","id":"0017E00000coRVzQAM"},{"referenceId":"2","id":"0017E00000coRW0QAM"},{"referenceId":"3","id":"0017E00000coRW1QAM"},{"referenceId":"4","id":"0017E00000coRW2QAM"},{"referenceId":"5","id":"0017E00000coRW3QAM"},{"referenceId":"6","id":"0017E00000coRW4QAM"},{"referenceId":"7","id":"0017E00000coRW5QAM"},{"referenceId":"8","id":"0017E00000coRW6QAM"},{"referenceId":"9","id":"0017E00000coRW7QAM"},{"referenceId":"10","id":"0017E00000coRW8QAM"},{"referenceId":"11","id":"0017E00000coRW9QAM"},{"referenceId":"12","id":"0017E00000coRWAQA2"},{"referenceId":"13","id":"0017E00000coRWBQA2"},{"referenceId":"14","id":"0017E00000coRWCQA2"},{"referenceId":"15","id":"0017E00000coRWDQA2"},{"referenceId":"16","id":"0017E00000coRWEQA2"},{"referenceId":"17","id":"0017E00000coRWFQA2"},{"referenceId":"18","id":"0017E00000coRWGQA2"},{"referenceId":"19","id":"0017E00000coRWHQA2"},{"referenceId":"20","id":"0017E00000coRWIQA2"},{"referenceId":"21","id":"0017E00000coRWJQA2"},{"referenceId":"22","id":"0017E00000coRWKQA2"},{"referenceId":"23","id":"0017E00000coRWLQA2"},{"referenceId":"24","id":"0017E00000coRWMQA2"},{"referenceId":"25","id":"0017E00000coRWNQA2"},{"referenceId":"26","id":"0017E00000coRWOQA2"},{"referenceId":"27","id":"0017E00000coRWPQA2"},{"referenceId":"28","id":"0017E00000coRWQQA2"},{"referenceId":"29","id":"0017E00000coRWRQA2"},{"referenceId":"30","id":"0017E00000coRWSQA2"},{"referenceId":"31","id":"0017E00000coRWTQA2"},{"referenceId":"32","id":"0017E00000coRWUQA2"},{"referenceId":"33","id":"0017E00000coRWVQA2"},{"referenceId":"34","id":"0017E00000coRWWQA2"},{"referenceId":"35","id":"0017E00000coRWXQA2"},{"referenceId":"36","id":"0017E00000coRWYQA2"},{"referenceId":"37","id":"0017E00000coRWZQA2"},{"referenceId":"38","id":"0017E00000coRWaQAM"},{"referenceId":"39","id":"0017E00000coRWbQAM"}]}');
            	res.setStatusCode(201);
            }
            return res;
        }
    }

    /*******************************************************************
    * @description generates a Successfull Auth call and a faied record Create                 
    ********************************************************************/ 
    public class MockHttpResponseErrorGeneratorMulti implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) 
        {   
            HttpResponse res = new HttpResponse();
            res.setHeader(GeWS_Constants.CONTENT_TYPE, GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
            if(req.getEndpoint().contains('http://authenticate.com')){
                res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://gimsf--Sprint9Dev.cs86.my.salesforce.com","id":"https://test.salesforce.com/id/00D7E0000008tG7UAI/00558000001jyAsAAI","token_type":"Bearer","issued_at":"1505415231637","signature":"ZMSkPPjzFxTBT13JIMOSLK6+mnVVN3snghF0qwM4sMs="}');
            	res.setStatusCode(200);
            } else {
                res.setBody('[{"message":"Required fields are missing: [Name]","errorCode":"REQUIRED_FIELD_MISSING","fields":["Name"]}]');
            	res.setStatusCode(400);
            } 
            return res;
        }
    }

/******* Methods to test abstract Framworks - this is the first concrete class of the abstract framework ********/

	private static void createBasicAuth(){

	}

	private static void createSetApiKey(){

	}


    /*******************************************************************
    * @description Calls the abstract method to intialise variables                        
    ********************************************************************/ 
	@isTest static void testInitaliseMethod() {
		testDataSetup();

		Test.startTest();
			//create an instance of a SFDC WS
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			sfdcWsRest.initaliseForWebServiceCall(GeWS_Constants.SALESFORCE_API);
			//Check that the endpoint is initalised as expected
			System.assertEquals(sfdcWsRest.endPoint, serviceEndPoint);
			System.assert(sfdcWsRest.parameters.isEmpty());
			System.assert(sfdcWsRest.urlReplacements.isEmpty());
		Test.stopTest();
	}


    /*******************************************************************
    * @description Adding Parameters to a URL                       
    ********************************************************************/ 
	@isTest static void testAddingParameters() {
		testDataSetup();

		Test.startTest();
			//create an instance of a SFDC WS
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();

			Map<String, String> params = new Map<String, String>();

			params.put('ExampleParam1','Value1');
			params.put('ExampleParam2','Value2');

			String results = sfdcWsRest.addParameters(serviceEndPoint, params);
			//order in the result do not matter
			System.assert(results.contains('?ExampleParam1=Value1') || results.contains('&ExampleParam1=Value1'));
			System.assert(results.contains('?ExampleParam2=Value2') || results.contains('&ExampleParam2=Value2'));
		Test.stopTest();
	}

    /*******************************************************************
    * @description Tests the setting of the method on a Http Request                   
    ********************************************************************/ 
	@isTest static void testAddingRequestMethods() {
		testDataSetup();
		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGenerator());
		Test.startTest();
			//create an instance of a SFDC WS
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();

			String bodyOfRequest = 'Test';

			HTTPRequest aRequest = sfdcWsRest.setHTTPRequestValues(	  GeWS_Constants.WS_METHOD_POST
																	, serviceEndPoint
																	, GeWS_Constants.SALESFORCE_API
																	, GeWS_Constants.HTTP_CONTENT_TYPE_JSON
																	, bodyOfRequest);
			//Check the method, Endpoint and Header was set on the HTTP Request
			System.assertEquals(aRequest.getMethod(), GeWS_Constants.WS_METHOD_POST);
			System.assertEquals(aRequest.getEndpoint(), serviceEndPoint);
			System.assertEquals(aRequest.getHeader(GeWS_Constants.CONTENT_TYPE), GeWS_Constants.HTTP_CONTENT_TYPE_JSON);
			System.assertEquals(aRequest.getBody(), bodyOfRequest);

		Test.stopTest();
	}

    /*******************************************************************
    * @description populating the endpoint, adding params and replacing elements in URL             
    ********************************************************************/ 
	@isTest static void testpopulatingTheEndpoint() {
		testDataSetup();

		Test.startTest();
			//create an instance of a SFDC WS
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			//Create a URL with a String Replacement
			String endPointWithReplacement = serviceEndPoint + '/{replace}';
			//Create thge URL replacements
			Map<String, String> urlReplacement = new Map<String, String>();
			urlReplacement.put('{replace}', 'example');
			//Create the parameters to add to the URL
			Map<String, String> params = new Map<String, String>();
			params.put('ExampleParam1','Value1');
			params.put('ExampleParam2','Value2');			

			String results = sfdcWsRest.populateEndPoint(endPointWithReplacement
														, urlReplacement
														, params);
			//order in the results do not matter
			System.assert(results.contains(serviceEndPoint + '/example'));
			System.assert(results.contains('?ExampleParam1=Value1') || results.contains('&ExampleParam1=Value1'));
			System.assert(results.contains('?ExampleParam2=Value2') || results.contains('&ExampleParam2=Value2'));

		Test.stopTest();
	}

    /*******************************************************************
    * @description test calling out          
    ********************************************************************/ 
	@isTest static void testCallingOut() {
		testDataSetup();
		GeTD_TestData_TF_T testF = new GeTD_TestData_TF_T();
		GeWS_WebService_Integration_Settings__c newSetting 
									= testF.newWSIntegrationSetting(  serviceEndPoint
																	, ''
																	, 'Sample');
		insert newSetting;
		Test.setMock(HttpCalloutMock.class, new GeEF_SalesforceRESTServices_WS_T.MockHttpResponseGenerator());
		Test.startTest();
			//create an instance of a SFDC WS
			GeEF_SalesforceRESTServices_WS sfdcWsRest = new GeEF_SalesforceRESTServices_WS();
			//attempt callout
			sfdcWsRest.callOutResult = sfdcWsRest.callOutToWebService(GeWS_Constants.WS_METHOD_POST
																	  , serviceEndPoint
																	  , 'Sample'
																	  , GeWS_Constants.HTTP_CONTENT_TYPE_JSON
																	  , true);
			System.assertEquals(sfdcWsRest.callOutResult.statusCode, 201);
			System.assertEquals(sfdcWsRest.callOutResult.body, '{"id":"a2A7E000000B7kfUAC","success":true}');
		Test.stopTest();
	}

}