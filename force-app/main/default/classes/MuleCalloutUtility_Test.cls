/**
 * Created by mike.jutzin on 4/3/2017.
 */

@IsTest
private class MuleCalloutUtility_Test {
    static testMethod void testConstructor() {
        // make sure public constructor runs without problems
        try { MuleCalloutUtility mcu = new MuleCalloutUtility(); }
        catch( Exception e ) {
            throw new AssertException( 'Failed to instantiate MuleCalloutUtility.' );
        }
    }

    static testMethod void testSendCalloutWithoutQueryString() {
        Test.setMock( HttpCalloutMock.class, new GenericHttpResponseGenerator() );

        MuleCalloutUtility mcu = new MuleCalloutUtility();
        String testBody = 'http-200-please';

        HttpResponse resp = mcu.sendCallout( testbody, 'AVALARA' );

        // delegates to sendCallout( body, queryString=>null, type ) so just exercise it once
        System.assertEquals( 200, resp.getStatusCode() );

        // let's also cover some of the methods that still exist but were removed from the list of types...
        Callout_Configuration__mdt config;
        if (new OrganizationDAO().isRunningInSandbox()) {
           config = new CustomMetadataTypeDAO_DEV().getMuleToSageOneEmailValidation();
            } else {
           config = new CustomMetadataTypeDAO_PROD().getMuleToSageOneEmailValidation();
        }
        mcu.sendCalloutSageIdEmailCheck('http://endpoint.com', '{ "json" : true } ', config);
        mcu.sendCalloutSageIdNewUserStart('http://endpoint.com', '{ "json" : true } ', config);
        mcu.sendCalloutSageIdNewUserEnd('http://endpoint.com', '{ "json" : true } ', config);
        mcu.sendCalloutSageIdExistingUserStart('http://endpoint.com', '{ "json" : true } ', config);
        mcu.sendCalloutSageIdExistingUserEnd('http://endpoint.com', '{ "json" : true } ', config);
    }

    static testMethod void testSendCalloutWithQueryString() {
        Test.setMock( HttpCalloutMock.class, new GenericHttpResponseGenerator() );
        MuleCalloutUtility mcu = new MuleCalloutUtility();

        String testBody = 'http-200-please';
        String queryString = '?queryString=true';

        // no logic here really, just exercising the utility as it delegates calls
        // based on type. should not run into any exceptions as we do this.
        List<String> types = new List<String> {
            'AVALARA',
            'ZUORA_ACCOUNT',
            'ZUORA_CONTACT',
            'ZUORA_UPDATE',
            'ZUORA_SUBSC',
            'PRODUCT_PROVISION',
            'ADDRESS_AUTO_COMPLETION',
            'SAGE_EMAIL_VALIDATION',
            // 'SAGE_ID_EMAIL_SEARCH',
            // 'SAGE_ID_NEW_USER_START',
            // 'SAGE_ID_NEW_USER_END',
            // 'SAGE_ID_EXISTING_USER_START',
            // 'SAGE_ID_EXISTING_USER_END',
            'ZUORA_DYNAMIC_SUBSC'
        };

        HttpResponse resp;

        // these should all have a 200 response
        for ( String type : types ) {
            System.debug('testing sendCallout for type: ' + type);
            resp = mcu.sendCallout( testbody, queryString, type );
            System.assertEquals( 200, resp.getStatusCode() );
        }

        // and should get a null response for any unhandled types
        resp = mcu.sendCallout( testbody, queryString, 'UNHANDLED_TYPE' );
        System.assertEquals( null, resp );
    }
}