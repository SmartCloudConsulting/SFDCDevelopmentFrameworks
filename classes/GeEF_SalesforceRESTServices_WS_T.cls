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
																		, credentialIdentifier);
		insert newSecCred;
		testAcc = testF.createNewAccount();

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
//Check Exception is created? - if this is donve via WS call this might not be possible
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