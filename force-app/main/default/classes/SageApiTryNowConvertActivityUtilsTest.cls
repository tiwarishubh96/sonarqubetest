@IsTest(SeeAllData=false)
private class SageApiTryNowConvertActivityUtilsTest {
    static locale__c loc;
    static {
        TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        loc = [SELECT ID FROM locale__c WHERE name = 'en_US' LIMIT 1]; //TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
    }

    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
    }

    static private SageApiTryNowConvertActivityRequest createPayload()
    {
        Account acc = TestDataUtility.createAccount(loc.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c quo = TestDataUtility.createZQuote(acc.Id, con.Id, null);
        
        SageApiTryNowConvertActivityRequest payload = new SageApiTryNowConvertActivityRequest();
        payload.quoteId = quo.Id;
        payload.accountId = acc.Id;
        return payload; 
    }

    static private SageApiActivity__c createActivity( SageApiTryNowConvertActivityRequest payload )
    {
        return SageApiTestUtils.createActivity( 'TryNowConvert', JSON.serialize( payload ) );
    }

    @IsTest static void testValidatePayloadSuccess()
    {
        SageApiTryNowConvertActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();
        
            System.assertEquals( true, SageApiTryNowConvertActivityUtils.validatePayload( activity, step, null, null, null, null, null, null ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadErrors()
    {
        Test.startTest();
   
            // null activity
            SageApiActivity__c activity1 = null;
            SageApiActivityStep step1 = new SageApiActivityStep( 1, 'DoStuff' );
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validatePayload( activity1, step1, null, null, null, null, null, null ) );
    
            // null step
            SageApiTryNowConvertActivityRequest payload2 = createPayload();
            SageApiActivity__c activity2 = createActivity( payload2 );
            SageApiActivityStep step2 = null;
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validatePayload( activity2, step2, null, null, null, null, null, null ) );

            // invalid payload
            SageApiActivity__c activity3 = SageApiTestUtils.createActivity( 'TryNowConvert', '{' );
            SageApiActivityStep step3 = new SageApiActivityStep( 1, 'DoStuff' );
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validatePayload( activity3, step3, null, null, null, null, null, null ) );

            // null payload
            SageApiActivity__c activity4 = SageApiTestUtils.createActivity( 'TryNowConvert', 'null' );
            SageApiActivityStep step4 = new SageApiActivityStep( 1, 'DoStuff' );
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validatePayload( activity4, step4, null, null, null, null, null, null ) );

            // missing required
            String activityType = SageApiActivityTriggerHandler.TryNowConvertActivityType;
/*
            Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
            Account acct = new Account(
                    Name = 'Test Biz', 
                    Locale_Billing_CC__c = 'US',
                    Locale__c = loc.id,
                    Type = 'Customer'
                );
            insert acct;
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'Test';
            insert quote;
            SageApiTryNowConvertActivityRequest payload5 = SageApiTestUtils.createTryNowConvertPayload(acct.Id, quote.Id);
*/
            SageApiTryNowConvertActivityRequest payload5 = SageApiTestUtils.createTryNowConvertPayload(null, null);
            String token = 'token';
            //payload5.accountId = null;
            //payload5.quoteId = null;
            payload5.payNowToken = token;
            payload5.cbcTrialId = null;
            SageApiActivity__c activity5 = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload5 ) );
            activity5.ActivityStatus__c = SageApiStatus.InProgress;
            System.debug('activity5: '+JSON.serialize(activity5));

            List<PayNowToken__c> tokens = new List<PayNowToken__c>{new PayNowToken__c(name=token)};
            insert tokens;
            SageApiActivity__c activity5T = SageApiTestUtils.createActivity( SageApiTestUtils.createPayload() );
            insert activity5T;
            Map<String, SageApiActivity__c> tokenTryNowActivityMap = new Map<String, SageApiActivity__c> {token=>activity5T};
            SageApiActivityRequestObjects.Product prod = new SageApiActivityRequestObjects.Product();
            prod.tierCode='sageoneus';
            prod.tierRatePlanCode='monthly';
            Map<String, List<SageApiActivityRequestObjects.Product>> tokenProductsMap = new Map<String, List<SageApiActivityRequestObjects.Product>>{token=>new List<SageApiActivityRequestObjects.Product>{prod}};

            List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
            List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };

            SageApiActivityStep step5 = new SageApiActivityStep( 1, 'DoStuff' );
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validateTryNowConvertPayload( activity5, step5, productTiers, productTierRatePlans, tokens, tokenProductsMap, tokenTryNowActivityMap ) );

            // missing required - Tetris
            SageApiTryNowConvertActivityRequest payload6 = SageApiTestUtils.createTetrisConvertTrialPayload('trialId', 'zuoraSubscriptionId');
            payload6.payNowToken = token;
            SageApiActivity__c activity6 = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.TetrisConvertTrialActivityType, JSON.serialize( payload6 ) );
            Map<String, Subscription_Master__c> subscriptionMasterMap6_1 = new Map<String, Subscription_Master__c>{payload6.cbcTrialId=>new Subscription_Master__c(Status__c='Trial')};
            System.assertEquals( true, SageApiTryNowConvertActivityUtils.validatePayload( activity6, step5, productTiers, productTierRatePlans, tokens, tokenProductsMap, tokenTryNowActivityMap, subscriptionMasterMap6_1 ) );

            Map<String, Subscription_Master__c> subscriptionMasterMap6_2 = new Map<String, Subscription_Master__c>{'differentTrialId'=>new Subscription_Master__c(Status__c='Trial')};
            System.assertEquals( false, SageApiTryNowConvertActivityUtils.validatePayload( activity6, step5, productTiers, productTierRatePlans, tokens, tokenProductsMap, tokenTryNowActivityMap, subscriptionMasterMap6_2 ) );

        Test.stopTest();
    }


    @IsTest static void testUpdateQuotes()
    {
        Test.startTest();

            // missing required
            String activityType = SageApiActivityTriggerHandler.TryNowConvertActivityType;
            Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
            Account acct = new Account(
                    Name = 'Test Biz', 
                    Locale_Billing_CC__c = 'US',
                    Locale__c = loc.id,
                    Type = 'Customer'
                );
            insert acct;
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'Test';
            insert quote;
            SageApiTryNowConvertActivityRequest payload5 = SageApiTestUtils.createTryNowConvertPayload(acct.Id, quote.Id);
            String token = 'token';
            payload5.payNowToken = token;
            SageApiActivity__c activity5 = SageApiTestUtils.createActivity( activityType, JSON.serialize( payload5 ) );
            activity5.Quote__c = quote.Id;

            SageApiActivityRequestObjects.ProductConfig prod = new SageApiActivityRequestObjects.ProductConfig();
            prod.tierCode = 'sageoneus';
            SageApiActivityRequestObjects.TierRatePlan trp = new SageApiActivityRequestObjects.TierRatePlan();
            trp.tierRatePlanCode = 'Monthly';
            List<SageApiActivityRequestObjects.TierRatePlan> trps = new List<SageApiActivityRequestObjects.TierRatePlan>{trp};
            prod.tierRatePlanCodes = trps;
            List<SageApiActivityRequestObjects.ProductConfig> products = new List<SageApiActivityRequestObjects.ProductConfig>{prod};
            List<PayNowToken__c> tokens = new List<PayNowToken__c>{new PayNowToken__c(name=token, Products__c=JSON.serialize(products), PaymentMethodId__c='paymentId')};
            insert tokens;
            activity5.PayNowToken__c = tokens[0].id;

            SageApiActivity__c activity5T = SageApiTestUtils.createActivity( SageApiTestUtils.createPayload() );
            insert activity5T;
            Map<String, SageApiActivity__c> tokenTryNowActivityMap = new Map<String, SageApiActivity__c> {token=>activity5T};

            SageApiActivityStep step5 = new SageApiActivityStep( 1, 'DoStuff' );
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>{activity5};
            SageApiTryNowConvertActivityUtils.updateQuote( step5, activities );
            System.assertEquals( SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c );

        Test.stopTest();
    }

}