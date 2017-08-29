/**********************************************************************
Name:  GeWS_ExampleService_WS
Copyright © 2016
======================================================
======================================================
Purpose:  This represents a Service which makes use of a 
          Service Provider. 

          In this example it is the Address Service
-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      SmartCloud Framework    06/08/2016          
***********************************************************************/  
public with sharing class GeWS_ExampleService_WS extends GeWS_ExampleServiceProvider_WS{
    GeWS_WebService_A.CallOutResults callOutResult;
    Map<String, String> parameters;
    Map<String, String> urlReplacements;
    String endpoint;
    String serviceName;

    /*******************************************************************
    * @description Example of calling an address Search Engine 
    * @Param String
    * @Param String
    * @Param String 
    * @Param String    
    * @return List<String>
    * @Throws [Exceptions]: <<TO DO>>                                                 
    ********************************************************************/
    public List<String> findCustomerAddress(String houseNameOrNumber
                                           , String postcode
                                           , String take
                                           , String skip) {
        //Setup Required Parameters
        serviceName = 'addressSearch';
        super.initaliseForWebServiceCall(serviceName);

        //These are the parameters at the end of the URI 
        //eg www.example.com?Take=value&Skip=value
        parameters.put('Take', take);
        parameters.put('Skip', skip);
        parameters.put('Postcode', postcode);
        parameters.put('HouseNameOrNumber', houseNameOrNumber);

        endpoint = populateEndPoint(endpoint,urlReplacements, parameters);

        callOutResult = callOutToWebService( 'GET'
                                            , endpoint
                                            , serviceName
                                            , GEWs_Constants.HTTP_CONTENT_TYPE_JSON
                                            , true);

        if (!callOutResult.hasErred) {
//Handle the inerpreting the Resonse
        } else {
//Handle the appropriate error response
        }
        return null;
    }
}