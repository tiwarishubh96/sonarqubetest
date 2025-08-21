public with sharing class OpaStaticVariables 
{
    public static String orgId = UserInfo.getOrganizationId().substring(0,15);
    
    // START Token Generator Class Variables
        public static Integer requestTimeout = 59900; //59.9 seconds in miliseconds
        public static String jwtHeader = '{"alg":"HS256"}';
        public static String jwtSigningAlgorithm = 'HmacSHA256';
    // END Token Generator Class Varibles
    
    public static String salesforceBaseURL = System.URL.getSalesforceBaseURL().toExternalForm();
    public static String opaRestEndpointPath = '/services/apexrest/CustomerSite/notifyProvisionStatus';
}