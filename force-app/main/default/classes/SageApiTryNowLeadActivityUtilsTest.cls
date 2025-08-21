@IsTest(SeeAllData=false)
private class SageApiTryNowLeadActivityUtilsTest
{
    static locale__c loc;
    static List<Product_Tier__c> productTiers;
    static List<Product_Tier_Rate_Plan__c> productTierRatePlans;
    static {
        TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        loc = [SELECT ID FROM locale__c WHERE name = 'en_US' LIMIT 1]; //TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
    }

    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
    }
    
    static private SageApiTryNowLeadActivityRequest createPayload()
    {
        SageApiTryNowLeadActivityRequest payload = new SageApiTryNowLeadActivityRequest();
        payload.firstName = 'Some';
        payload.lastName = 'One';
        payload.email = 'someone@example.com';
        payload.products = new List<SageApiActivityRequestObjects.Product>();
        payload.products.add( new SageApiActivityRequestObjects.Product() );
        payload.products[0].tierCode = 'SageOne-Start-US';
        //payload.products[0].tierRatePlanCode = 'Monthly';

        return payload; 
    }

    static private SageApiActivity__c createActivity( SageApiTryNowLeadActivityRequest payload )
    {
        return createActivity( JSON.serialize( payload ) );
    }

    static private SageApiActivity__c createActivity( String payload )
    {
        SageApiActivity__c activity = new SageApiActivity__c();
        activity.Name = GenericUtilities.getRandomUUIDv4();
        activity.ActivityType__c = 'TryNowLead';
        activity.ActivityID__c = 'TryNowLead:' + activity.Name;
        activity.Payload__c = payload;

        return activity;
    }
    
    @IsTest static void testValidatePayloadNoActivity()
    {
        SageApiActivity__c activity = null;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoStep()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = null;

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }
    
    @IsTest static void testValidatePayloadInvalidPayload()
    {
        SageApiActivity__c activity = createActivity( '{' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
        
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadEmptyPayload()
    {
        SageApiActivity__c activity = createActivity( 'null' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
        
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoFirstName()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.firstName = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoLastName()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.lastName = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoEmail()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.email = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadSuccess()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        System.debug('productTiers: ' + productTiers);

        Test.startTest();
        
            System.assertEquals( true, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoProducts()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.products = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadTooManyProducts()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        SageApiActivityRequestObjects.Product otherProduct = new SageApiActivityRequestObjects.Product();
        otherProduct.tierCode = 'Some-Other-Product';
        otherProduct.tierRatePlanCode = 'Monthly';
        payload.products.add( otherProduct );
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidProductInfo()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.products[0].tierCode = null;
        payload.products[0].tierRatePlanCode = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidTierRatePlanCode()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.products[0].tierRatePlanCode = 'InvalidCode';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( false, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadValidTierRatePlanCode()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        payload.products[0].tierRatePlanCode = 'Monthly';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( true, SageApiTryNowLeadActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans ) );
    
        Test.stopTest();
    }
    
    @IsTest static void testCreateLeadSuccess()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c activity = createActivity( payload );
        activities.add(activity);
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            SageApiTryNowLeadActivityUtils.createLead( step, activities );
        
        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Lead] );
    }

    @IsTest static void testUpdateArtifactWithErrorStringSuccess()
    {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);
        List<SageApiActivityError> errors = new List<SageApiActivityError>();
        SageApiActivityError error = new SageApiActivityError();
        error.code = 'testCode';
        error.target = 'testTarget';
        error.message = 'testMessage';
        errors.add(error);
        SageApiActivityStep step = new SageApiActivityStep(1, 'TestStep');

        Test.startTest();
        
            SageApiActivityUtils.setError(activity,  step, SageApiStatus.ManualInterventionRequired, errors);
            SageApiTryNowLeadActivityResponse response = (SageApiTryNowLeadActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiTryNowLeadActivityResponse.class);
            System.assertEquals( true, response != null);
    
        Test.stopTest();
    }    

    @IsTest static void testUpdateArtifactSuccess() {
        SageApiTryNowLeadActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity(payload);
        activity.Lead__c = '5003000000D8cuI';
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);
        SageApiActivityStep step = new SageApiActivityStep(1, 'TestStep');

        Test.startTest();

        SageApiActivityUtils.setSuccess(activity, step);

        Test.stopTest();

        SageApiTryNowLeadActivityResponse response = (SageApiTryNowLeadActivityResponse) JSON.deserialize(activity.Artifacts__c, SageApiTryNowLeadActivityResponse.class);
        System.assertEquals(true, response != null);
    }
}