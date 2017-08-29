/**********************************************************************
Name:  GeWS_Constants
Copyright © 2017
======================================================
======================================================
Purpose:  Constants class to store WS Related Constants

-------                                                             
======================================================
======================================================
History                                                            
-------                                                            
VERSION      AUTHOR                DATE             DETAIL             Description
   1.0      Smart Cloud Framework    06/08/2016          
***********************************************************************/ 
public with sharing class GeWS_Constants {
    /****************************************************************
     * WEB SERVICE
     * All web service related constants go here 
     ****************************************************************/
    public static final String WS_AUTHORIZATION_HEADER                      = 'Authorization'; 
    public static final String WS_X_HTTP_METHOD_OVERRIDE_HEADER             = 'X-HTTP-Method-Override';
    public static final String WS_X_FULLCONTACT_APIKEY_HEADER               = 'X-FullContact-APIKey';
    public static final String WS_HEADER                                    = 'Header';
    public static final String WS_AUTH_TYPE_BASIC                           = 'Basic ';
    public static final String WS_BEARER                                    = 'Bearer ';
    public static final String WS_BASIC_AUTH                                = 'Basic Auth';
    public static final String WS_OAUTH_2                                   = 'OAuth 2.0';
    public static final String WS_OTHER                                     = 'Other';
    public static final String WS_API_KEY_ONLY                              = 'API Key Only';
    public static final String WS_OCP_APIM_SUBSCRIPTION_KEY                 = 'Ocp-Apim-Subscription-Key';
    public static final String WS_USER_AGENT                                = 'User-Agent';
    public static final String WS_EXCEPTION                                 = 'Exception';
    public static final String CONTENT_TYPE                                 = 'Content-Type';
    public static final String GRANT_TYPE                                   = 'grant_type';
    public static final String WS_HTTP_CODE_SUCCESS_START                   = '2';
    public static final String HTTP_CONTENT_TYPE_JSON                       = 'application/json';
    public static final String HTTP_CONTENT_TYPE_URL                        = 'application/x-www-form-urlencoded';
    public static final String HTTP_GRANT_TYPE_PASSWORD                     = 'password';
    public static final String HTTP_GRANT_TYPE_CLIENT_CREDENTIALS           = 'client_credentials';
    public static final String HTTP_PARAMETER_USERNAME                      = 'username';
    public static final String HTTP_PARAMETER_PASSWORD                      = 'password';
    public static final String HTTP_PARAMETER_CLIENT_ID                     = 'client_id';
    public static final String HTTP_PARAMETER_CLIENT_SECRET                 = 'client_secret';
    public static final String WS_OAUTH_ACCESS_TOKEN                        = 'access_token';
    public static final String HTTP_CONTENT_TYPE_TEXT                       = 'text/plain';
    public static final String HTTP_CHARSET_UTF8                            = 'UTF-8';
    public static final String HTTP_LANG_EN_US                              = 'en-us';
    public static final String WS_SOURCE_TWITTER                            = 'twitter';
    public static final String WS_METHOD_GET                                = 'GET';
    public static final String WS_METHOD_POST                               = 'POST';
    public static final String WS_METHOD_PATCH                              = 'patch';

    /****************************************************************
     * Salesforce API
     * All Salesforce API Constants
     ****************************************************************/   
    public static final String SALESFORCE_API                               = 'Salesforce';

    /****************************************************************
     * JSON PARSER
     * All web service related constants go here 
     ****************************************************************/
    public static final String JSON_PARSE_ERRORS_TEXT                        = 'errors';
    public static final String JSON_PARSE_ERROR_TEXT                         = 'error';
    public static final String JSON_PARSE_CODE_TEXT                          = 'code';
    
         
}