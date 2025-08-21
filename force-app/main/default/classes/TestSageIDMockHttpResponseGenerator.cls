@isTest
global class TestSageIDMockHttpResponseGenerator implements HttpCalloutMock {
    public static String SCENARIO_LISTIDENTITIES_NO_MATCH = 'SCENARIO_LISTIDENTITIES_NO_MATCH';
    public static String SCENARIO_LISTIDENTITIES_MATCH = 'SCENARIO_LISTIDENTITIES_MATCH';
    public static String SCENARIO_GET_STARTURL_EXISTING_SAGEID = 'SCENARIO_GET_STARTURL_EXISTING_SAGEID';
    public static String SCENARIO_GET_FAILREASON_EXISTING_SAGEID = 'SCENARIO_GET_FAILREASON_EXISTING_SAGEID';
    public static String SCENARIO_GET_STARTURL_NEW_SAGEID = 'SCENARIO_GET_STARTURL_NEW_SAGEID';
    public static String SCENARIO_GET_FAILREASON_NEW_SAGEID = 'SCENARIO_GET_FAILREASON_NEW_SAGEID';
    
    private String scenario = null;
    public TestSageIDMockHttpResponseGenerator(String scenario){
        this.scenario = scenario;
    }
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        String endpoint = req.getEndpoint();
        String body = '';
        if(scenario == SCENARIO_LISTIDENTITIES_NO_MATCH){
            body= '<ListUserIdentitiesResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><UserIdentities xmlns="http://sso.sage.com" /><Total xmlns="http://sso.sage.com">0</Total></ListUserIdentitiesResponse>';
        } else if(scenario == SCENARIO_LISTIDENTITIES_MATCH){
            body= '<ListUserIdentitiesResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><UserIdentities xmlns="http://sso.sage.com"><UserIdentity><VersionStamp>102195054</VersionStamp><Id>196b7fb1-8b09-4859-8ffb-1d893108b26a</Id><DateCreated>2016-05-03T12:09:53.673</DateCreated><IsSystemIdentity>false</IsSystemIdentity><PassportInfo xsi:nil="true" /><EmailAddress>email@address.com</EmailAddress><Name>SF User</Name><Password xsi:nil="true" /><AccountPolicyName xsi:nil="true" /><SystemVerifiedEmail>false</SystemVerifiedEmail><LastEmailChange>None</LastEmailChange><RegistrationSecurityChallenge>false</RegistrationSecurityChallenge></UserIdentity></UserIdentities><Total xmlns="http://sso.sage.com">1</Total></ListUserIdentitiesResponse>';                
        } else if(scenario == SCENARIO_GET_STARTURL_EXISTING_SAGEID){
            body='<StartRegistrationAttemptResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RegistrationAttemptId xmlns="http://sso.sage.com">957dd30c-87ed-4de9-8c87-6d4cee229b2c</RegistrationAttemptId><RedirectUri xmlns="http://sso.sage.com">https://na-signon2.sso.staging.services.sage.com/register/957dd30c-87ed-4de9-8c87-6d4cee229b2c?f=%2fRwHnCvZeL5n85tSqFIcG8l9QPABdnxY86bEzex1bAnjUaasvEj0MEy8KdhFlQnwhZ%2baPHuKiQAyImmFchFaMQdkkwJLgxAYMhGO7YeMkiriec52u7HYS5ybVN3JWTpt</RedirectUri></StartRegistrationAttemptResponse>';
        } else if(scenario == SCENARIO_GET_FAILREASON_EXISTING_SAGEID){
            body='<EndRegistrationAttemptResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RegistrationAttemptId xmlns="http://sso.sage.com">fab237f4-1004-4b13-9b57-7d8536d53196</RegistrationAttemptId><RegistrationFailedResult xmlns="http://sso.sage.com"><Reason>RegistrationCancelled</Reason></RegistrationFailedResult></EndRegistrationAttemptResponse>';
        } else if(scenario == SCENARIO_GET_STARTURL_NEW_SAGEID){
            body='<StartRegistrationAttemptResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RegistrationAttemptId xmlns="http://sso.sage.com">8202ce6c-6be9-4ed7-b431-4efd24d41113</RegistrationAttemptId><RedirectUri xmlns="http://sso.sage.com">https://na-signon3.sso.staging.services.sage.com/register/8202ce6c-6be9-4ed7-b431-4efd24d41113?f=CaP%2fdMmazie8t1X2hnYXQ0O04RuEygq5czrTenPT4dhgDBWBe9LQT45YhJsx1hTsDhzSOWhWRfHOJ9tK9cNz9rQ%2fmFzj5V7BbYb0naNu%2fzWvuKi2q2%2fl95ckggsJ6qMr</RedirectUri></StartRegistrationAttemptResponse>';
        } else if(scenario == SCENARIO_GET_FAILREASON_NEW_SAGEID){
            body='<EndRegistrationAttemptResponse xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><RegistrationAttemptId xmlns="http://sso.sage.com">8202ce6c-6be9-4ed7-b431-4efd24d41113</RegistrationAttemptId><RegistrationFailedResult xmlns="http://sso.sage.com"><Reason>RegistrationCancelled</Reason></RegistrationFailedResult></EndRegistrationAttemptResponse>';
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}