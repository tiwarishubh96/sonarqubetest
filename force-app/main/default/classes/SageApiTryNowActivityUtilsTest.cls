/**
 * @description Written by Salesforce Services on behalf of Mick Andrew’s team for code coverage.
 * 
 *              Tests for associated class.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest(SeeAllData=false)
private class SageApiTryNowActivityUtilsTest
{
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupCommunity();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testValidatePayloadNoActivity()
    {
        SageApiActivity__c activity = null;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

        System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoStep()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = null;
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

        System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadSuccess()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( true, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidPayload()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity( 'TryNow', '{' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadEmptyPayload()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity( 'TryNow', 'null' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadBlankStartDate()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.startDate = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadStartDateBeforeToday()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.startDate = System.now().addDays( -5 ).format('yyyy-MM-dd');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadStartDateInvalidFormat()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.startDate = 'abc';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadEndDateBeforeStartDate()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.endDate = System.now().addDays( -5 ).format('yyyy-MM-dd');
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadEndDateInvalidFormat()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.endDate = 'abc';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoAccount()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.account = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoAccountName()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.account.name = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoContact()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoContactInfo()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.identityType = null;
        payload.contact.identityId = null;
        payload.contact.firstName = null;
        payload.contact.lastName = null;
        payload.contact.email = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoProducts()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.products = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadTooManyProducts()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivityRequestObjects.Product otherProduct = new SageApiActivityRequestObjects.Product();
        otherProduct.tierCode = 'Some-Other-Product';
        otherProduct.tierRatePlanCode = 'Monthly';
        payload.products.add( otherProduct );
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidProductInfo()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.products[0].tierCode = null;
        payload.products[0].tierRatePlanCode = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( false, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidatePayloadWithLeadSuccess()
    {
        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        leads.add( new Lead( Firstname = 'Some', Lastname = 'One', Company = 'Example Inc.', Sales_Office__c = 'Atlanta Office', RecordTypeId = recordTypeId ) );
        insert leads;
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        leadMap.putAll(leads);

        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.leadId = leads[0].Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        List<Product_Tier__c> productTiers = new List<Product_Tier__c>{ new Product_Tier__c( Product_Tier_Code__c = 'SageOne-Start-US' ) };
        List<Product_Tier_Rate_Plan__c> productTierRatePlans = new List<Product_Tier_Rate_Plan__c>{ new Product_Tier_Rate_Plan__c( Name = 'Monthly', Product_Tier__r = productTiers[0] ) };


        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();

        Test.startTest();

            System.assertEquals( true, SageApiTryNowActivityUtils.validatePayload( activity, step, productTiers, productTierRatePlans, leadMap, pricingChargeMap, null, null, null, null, null, null ) );

        Test.stopTest();
    }

    @IsTest static void testValidateTetrisStartTrialPayloadNoAccountId()
    {
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        payload.account.AccountId = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
        Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
        Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
        Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        Test.startTest();

            Boolean isValid = SageApiTryNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), leadMap, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);

            System.assertEquals( false, isValid );

        Test.stopTest();
    }

/**//**/
    @IsTest static void testValidateTetrisStartTrialPayloadNoContactId()
    {
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        payload.contact.ContactId = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
        Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
        Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
        Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        Test.startTest();

            Boolean isValid = SageApiTryNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), leadMap, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);

            System.assertEquals( false, isValid );

        Test.stopTest();
    }

/**//**/
    @IsTest static void testValidateTetrisStartTrialPayloadSuccess()
    {
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
        Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
        Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
        Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        Test.startTest();

            Boolean isValid = SageApiTryNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), leadMap, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);

            System.assertEquals( true, isValid );

        Test.stopTest();
    }

/**//**/
    @IsTest static void testValidateTetrisStartTrialPayloadWithIdentitySuccess()
    {
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Profile profile = [Select Id from Profile where name = 'Sage: CBC Customer Community User'];
        User user = new User(
            Username='username@companyname.com', FirstName='FirstName', Lastname='LastName',
            CompanyName='CompanyName', Alias='abc', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId = profile.Id,
            LocaleSidKey='en_US',TimeZoneSidKey='GMT',
            Email='username@companyname.com',
            ContactId = payload.contact.contactId,
            IsActive=true
        );
        insert user;

        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        CommunityX__c comm = [SELECT Id FROM CommunityX__c WHERE Name=:SageApiActivityUtils.setting_CustomerCommunityName LIMIT 1];
        Community_Membership__c memebership = new Community_Membership__c(
            Community__c = comm.Id
            , Community_Role__c = roles[0].Id
            , Contact__c = payload.contact.contactId);
        insert memebership;

        String uniqueId = payload.account.AccountId + ':' + payload.contact.identityType + ':' + payload.contact.identityId;
        SageUserIdentityProvider__c ident = new SageUserIdentityProvider__c(
            Name = uniqueId
            , Account__c = payload.account.AccountId
            , IdentityID__c = payload.contact.identityId
            , IdentityProvider__c = payload.contact.identityType
            , SFBridgeID__c = uniqueId
            , User__c = user.Id
        );
        insert ident;

        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        Map<Id, Lead> leadMap = SageApiTryNowActivityUtils.getRequestLeads(activities);
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
        Map<Id, Account> accounts = SageApiTryNowActivityUtils.getValidRequestAccounts(activities);
        Map<Id, Contact> contacts = SageApiTryNowActivityUtils.getValidRequestContacts(activities);
        Map<string, SageUserIdentityProvider__c> identities = SageApiTryNowActivityUtils.getValidRequestIdentities(activities);
        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        Test.startTest();

            Boolean isValid = SageApiTryNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), leadMap, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);

            System.assertEquals( true, isValid );

        Test.stopTest();
    }

/**//**/
    @IsTest static void testCreateOrUpdateLeadSuccess()
    {
        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();

        for(Integer i = 0; i < 8; i++)
        {
            leads.add( new Lead( Firstname = 'Some', Lastname = 'One'+i, Company = 'Example Inc.', Sales_Office__c = 'Atlanta Office', RecordTypeId = recordTypeId ) );
        }
        insert leads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 8; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            if( i == 0 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.phone = '123456';
            }
            else if( i == 1 )
            {
                payload.contact.leadId = leads[i].id;
                payload.contact.phone = '123456';
            }
            else if( i == 2 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.address1 = null;
                payload.contact.address1 = 'Downing Street';
            }
            else if( i == 3 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.city = null;
            }
            else if( i == 4 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.state = 'SRY';
            }
            else if( i == 5 )
            {
                payload.contact.leadId = leads[i].id;
                payload.contact.state = 'SRY';
            }
            else if( i == 6 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.postalCode = null;
            }
            else if( i == 7 )
            {
                payload.contact.leadId = leads[i].id;
                payload.account.countryCode = null;
            }
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLead( step, activities );

        Test.stopTest();

        System.assertEquals( 8, [SELECT Count() FROM Lead] );
    }

    @IsTest static void testCreateOrUpdateLeadExistingLead()
    {
        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();

        leads.add( new Lead( Firstname = 'Some', Lastname = 'One', Company = 'Example Inc.', Sales_Office__c = 'Atlanta Office', RecordTypeId = recordTypeId ) );
        insert leads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.leadId = leads[0].id;
        payload.account.phone = '123456';

        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Lead__c = leads[0].Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLead( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Lead] );
    }

    @IsTest static void testCreateOrUpdateLeadFromContactSuccess()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoAccountFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.ContactId = cont.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoContactFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Account__c = acct.Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactBadPayloadFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activity.Payload__c = '{';
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactNoProductFailure()
    {
        Account acct = new Account(
                Name = 'Unknown Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  );
        insert acct;

        Contact cont = new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One'
                        , AccountId = acct.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        );
        insert cont;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.ContactId = cont.Id;
        payload.account.accountId = acct.Id;
        payload.products = null;
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Account__c = acct.Id;
        activity.Contact__c = cont.Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.ManualInterventionRequired, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadFromContactExistingLead()
    {
        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();

        leads.add( new Lead( Firstname = 'Some', Lastname = 'One', Company = 'Example Inc.', Sales_Office__c = 'Atlanta Office', RecordTypeId = recordTypeId ) );
        insert leads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.leadId = leads[0].id;
        payload.account.phone = '123456';

        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activity.Lead__c = leads[0].Id;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLeadFromContact( step, activities );

            SageApiActivityUtils.refreshActivities(activities);

            System.assertEquals(SageApiStatus.Success, activities[0].ActivityStatus__c);
        Test.stopTest();
    }

    @IsTest static void testCreateOrUpdateLeadAccountCountryCode()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.contact.countryCode = null;
        payload.account.phone = '123456';
        payload.account.countryCode = 'US';

        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLead( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Lead] );
    }

    @IsTest static void testCreateOrUpdateLeadInvalidPayload()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 5; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity;
            if( i < 1 )
            {
                activity = SageApiTestUtils.createActivity( 'TryNow', '{' );
            }
            else if( i > 1 && i < 3 )
            {
                payload.account = null;
                activity = SageApiTestUtils.createActivity( payload );
            }
            else if( i > 3 )
            {
                payload.contact = null;
                activity = SageApiTestUtils.createActivity( payload );
            }
            else
            {
                activity = SageApiTestUtils.createActivity( payload );
            }
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateLead( step, activities );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Lead] );
    }
/**//**/
    @IsTest static void testConvertLeadSuccess()
    {
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        List<Lead> convertableLeads = new List<Lead>();
        for(Integer i = 0; i < 2; i++)
        {
            convertableLeads.add( new Lead( Firstname='Some',Lastname='One'+i,Email='a@b.com',phone='1231212',Company='Example Inc.',Street='122 st',City='Atlanta',CurrencyIsoCode='USD',Sales_Office__c='Atlanta CBC',CountryCode='US',PostalCode='30332',StateCode='GA',IsPartner__c=false,Language__c='English',RecordTypeId=recordTypeId ) );
        }
        insert convertableLeads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
            payload.account.paymentMethodType = 'Credit-Card';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            if( i < 2 )
            {
                SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
                resp.data = new SageApiTryNowActivityResponse.ResponseData();
                resp.data.leadId = convertableLeads[i].Id;
                activity.Artifacts__c = JSON.serialize( resp );
                activity.Lead__c = convertableLeads[i].Id;
            }

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertLead( step, activities );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Lead] );
        System.assertEquals( SageApiActivityUtils.setting_OpportunityStageEvaluating, [SELECT StageName FROM Opportunity LIMIT 1].StageName );
        System.assertEquals( 2, [SELECT Count() FROM Account] );
        System.assertEquals( 2, [SELECT Count() FROM Contact] );
    }

    @IsTest static void testConvertLeadNoLeads()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
            payload.account.paymentMethodType = 'Credit-Card';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertLead( step, activities );

        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM Account] );
    }

    @IsTest static void testCreatePaymentUrlCalloutSuccess() {
        SageApiActivityRequestObjects.PaymentRequest req = new SageApiActivityRequestObjects.PaymentRequest();
        req.completionNotifyUrl = 'completionNotifyUrl';
        req.successRedirectUrl = 'successRedirectUrl';
        req.errorRedirectUrl = 'errorRedirectUrl';
        req.products = new List<SageApiActivityRequestObjects.Product>();
        SageApiActivityRequestObjects.Product p = new SageApiActivityRequestObjects.Product();
        p.tierCode = 'SageOne-Start-US';
        p.tierRatePlanCode = 'Monthly';
        req.products.add(p);

        Test.startTest();

            SageApiActivityRequestObjects.PaymentResponse res = SageApiTryNowActivityUtils.createPaymentUrl(req);

        Test.stopTest();

        System.assert( res.success );
    }

    @IsTest static void testCreatePaymentUrlFutureSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( SageApiActivityTriggerHandler.TryNow2ActivityType, JSON.serialize(payload));
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityStep step = new SageApiActivityStep(1, 'Test');
        activities.add(activity);
        insert activities;

        Test.startTest();

            SageApiTryNowActivityUtils.getPaymentUrl(JSON.serialize(step), JSON.serialize(activities), null);

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assert( String.isNotBlank( activities[0].PaymentUrl__c ) );
    }

    @IsTest static void testConvertLeadPayloadError()
    {
        List<Lead> convertableLeads = new List<Lead>();
        for(Integer i = 0; i < 2; i++)
        {
            convertableLeads.add( new Lead( Firstname = 'Some', Lastname = 'One'+i, Company = 'Example Inc.' ) );
        }
        insert convertableLeads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 2; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.account.paymentMethodId = GenericUtilities.getRandomUUIDv4();
            payload.account.paymentMethodType = 'Credit-Card';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( 'TryNow', '{' );
            if( i < 2 )
            {
                SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
                resp.data = new SageApiTryNowActivityResponse.ResponseData();
                resp.data.leadId = convertableLeads[i].Id;
                activity.Artifacts__c = JSON.serialize( resp );
            }

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertLead( step, activities );

        Test.stopTest();

        System.assert( activities[0].ActivitySteps__c.contains('ManualInterventionRequired'));
    }
/**//**/
    @IsTest static void testCreateUserSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];

        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', Locale__c = loc.Id, Locale_Billing_CC__c = 'US' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id, MailingCountryCode = 'US' ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Contact con : cons)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
            resp.data = new SageApiTryNowActivityResponse.ResponseData();
            resp.data.contactId = con.Id;
            activity.Contact__c = con.Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;
        System.debug('accs: ' + accs);
        System.debug('cons: ' + cons);
        System.debug('activities: ' + activities);

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.provisionUser( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserNoContacts()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
            resp.data = new SageApiTryNowActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.provisionUser( step, activities );

        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserNoCandidates()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
            resp.data = new SageApiTryNowActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        delete cons;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.provisionUser( step, activities );

        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserPayloadFailure()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( 'TryNow', '{' );
            SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
            resp.data = new SageApiTryNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            activity.Contact__c = cons[i].Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.provisionUser( step, activities );

        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
        Map<Id, SageApiActivity__c> mapActivites = new Map<Id, SageApiActivity__c>((List<SageApiActivity__c>)GenericUtilities.resetSObjects( activities ));
        Set<String> possibleErrors = new Set<String>{ SageApiStatus.ManualInterventionRequired, SageApiStatus.Abandoned };
        for( SageApiActivity__c act : mapActivites.values() )
        {
            System.assertEquals( false, possibleErrors.contains( act.ActivityStatus__c ) );
        }
    }
/**//**/
    // FIXME: This test method throws exception because of Zuora API methods failing or returning nulls.
    @IsTest static void testCreateQuoteSuccess()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);

        zqu__Quote_Template__c template = new zqu__Quote_Template__c(Name='test', zqu__Quote_Type__c='New Subscription', Country__c='US - United States', Language__c='English', zqu__Template_Id__c='2c92c0f9560cb90d01560f2dbed2080d');
        insert template;
        System.debug('template: '+template);

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
        resp.data = new SageApiTryNowActivityResponse.ResponseData();
        resp.data.contactId = con.Id;
        resp.data.accountId = con.AccountId;
        activity.Artifacts__c = JSON.serialize( resp );
        activity.Account__c = con.AccountId;
        activity.Contact__c = con.Id;
        activity.ActivityStatus__c = SageApiStatus.InProgress;

        activities.add( activity );

        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            try {
                SageApiTryNowActivityUtils.createQuote( step, activities );
            }
            catch(Exception ex)
            {
                System.debug( LoggingLevel.Error, ex.getMessage() + '\n' + ex.getStackTraceString() );
            }

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM zqu__Quote__c] );
    }
/**//**/
    // FIXME: Throws hidden uncommitted work pending exception when debug logs are reviewed.
    @IsTest static void testGetPayNowTokenSuccess()
    {
        List<SageApiActivity__c> activities;
        SageApiActivityStep step;

        System.runAs( new User( Id = UserInfo.getUserId() ) )
        {
            PayNowSetting__c setting1 = new PayNowSetting__c( Name = 'PurchaseRequest.GB.ZuoraInstanceName', Value__c = 'https://example.com' );
            PayNowSetting__c setting2 = new PayNowSetting__c( Name =  'ContactPhone_GB', Value__c = '020388888888' );
            PayNowSetting__c pnUserName = new PayNowSetting__c( Name = 'payNowServiceUserName', Value__c = 'test' );
            PayNowSetting__c pnPassword = new PayNowSetting__c( Name = 'payNowServicePassword', Value__c = 'test' );
            insert new PayNowSetting__c[] { setting1, setting2, pnUserName, pnPassword };

            List<Account> accs = new List<Account>();
            for( Integer i = 0; i < 1; i++ )
            {
                accs.add( new Account( Name = 'Unknown' + i + ' Inc.', BillingCountryCode = 'GB' ) );
            }
            insert accs;

            List<Contact> cons = new List<Contact>();
            List<Opportunity> opps = new List<Opportunity>();
            for( Account acc : accs )
            {
                cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
                opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
            }
            insert cons;
            insert opps;

            List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
            for( Integer i = 0; i < 1; i++ )
            {
                zqu__Quote__c newQuote = new zqu__Quote__c();
                newQuote.zqu__Currency__c = 'USD';
                newQuote.zqu__Account__c = cons[i].AccountId;
                newQuote.zqu__SoldToContact__c = cons[i].Id;
                newQuote.zqu__BillToContact__c = cons[i].Id;
                newQuote.zqu__Previewed_SubTotal__c = 100;
                newQuote.zqu__Previewed_Total__c = 100;
                newQuote.zqu__Previewed_Tax__c = 20;
                newQuote.zqu__Opportunity__c = opps[i].Id;
                newQuote.zqu__PaymentMethod__c = 'Credit Card';
                newQuote.zqu__ValidUntil__c = System.today().addDays( 30 );
                quotes.add( newQuote );
            }
            insert quotes;

            activities = new List<SageApiActivity__c>();
            for(Integer i = 0; i < 1; i++)
            {
                SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
                SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
                SageApiTryNowActivityResponse resp = new SageApiTryNowActivityResponse();
                resp.data = new SageApiTryNowActivityResponse.ResponseData();
                resp.data.quoteId = quotes[i].Id; // any id works here
                activity.Quote__c = quotes[i].Id;
                activity.Artifacts__c = JSON.serialize( resp );

                activities.add( activity );
            }
            insert activities;

            step = new SageApiActivityStep( 1, 'DoStuff' );
        }


        Test.startTest();

            System.runAs( new User( Id = UserInfo.getUserId() ) )
            {
                Test.setMock( HttpCalloutMock.class , new SageApiTestUtils.PayNowPurchaseTokenMock() );
                SageApiTryNowActivityUtils.getPaymentUrl( step, activities, '123456' );
            }

        Test.stopTest();


        //System.assertEquals( 200, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
        }
        insert cons;

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;

            if( i > 99 )
            {
                activity.ActivityType__c = 'BuyNow';
                activity.ActivityID__c = 'BuyNow:' + activity.Name;
            }

            if( i == 100 )
            {
                resp.data.subscriptionId = 'abcdef123';
            }

            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Subscription_Master__c] );
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterWithEMSuccess()
    {
        Account acc = new Account(
                Name = 'Test Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'
            );
        insert acc;

        Contact con = new Contact(
                Firstname = 'Some'
                , Lastname = 'One' + acc.Name.substringBefore(' ')
                , AccountId = acc.Id
                , MailingCity = 'London'
                , MailingPostalCode = '30318'
                , MailingCountryCode = 'US'
                , MailingStreet = 'Downing Street'
            );
        insert con;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        Entitlement_Message__c msg = new Entitlement_Message__c();
        msg.Status__c = 'Processed';
        insert msg;

        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', '2c92c0f84dfff49f014e021c79b82bb6');

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Product_Tier__c = tier.Id;
        sm.Product_Tier_Rate_Plan__c = plan.Id;
        sm.Quote__c = zquote.Id;
        sm.Product__c = zproduct.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Trial';
        sm.Entitlement_Id__c = msg.Id;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.products[0].tierCode = 'SageOne-Start-US';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
        resp.data = new SageApiBuyNowActivityResponse.ResponseData();
        resp.data.contactId = con.Id;
        resp.data.accountId = con.AccountId;

        activity.Artifacts__c = JSON.serialize( resp );
        activity.Account__c = con.AccountId;
        activity.Contact__c = con.Id;
        activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Subscription_Master__c] );
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterWithEMErrorSuccess()
    {
        Account acc = new Account(
                Name = 'Test Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'
            );
        insert acc;

        Contact con = new Contact(
                Firstname = 'Some'
                , Lastname = 'One' + acc.Name.substringBefore(' ')
                , AccountId = acc.Id
                , MailingCity = 'London'
                , MailingPostalCode = '30318'
                , MailingCountryCode = 'US'
                , MailingStreet = 'Downing Street'
            );
        insert con;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        Entitlement_Message__c msg = new Entitlement_Message__c();
        msg.Status__c = 'Error';
        insert msg;

        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', '2c92c0f84dfff49f014e021c79b82bb6');

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Product_Tier__c = tier.Id;
        sm.Product_Tier_Rate_Plan__c = plan.Id;
        sm.Quote__c = zquote.Id;
        sm.Product__c = zproduct.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Trial';
        sm.Entitlement_Id__c = msg.Id;
        insert sm;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        payload.products[0].tierCode = 'SageOne-Start-US-Test';
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
        resp.data = new SageApiBuyNowActivityResponse.ResponseData();
        resp.data.contactId = con.Id;
        resp.data.accountId = con.AccountId;

        activity.Artifacts__c = JSON.serialize( resp );
        activity.Account__c = con.AccountId;
        activity.Contact__c = con.Id;
        activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
        activity.SubscriptionMaster__c = sm.Id;
        activity.Entitlement_Message__c = msg.Id;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activities.add( activity );
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Subscription_Master__c] );
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterWithoutTierRatePlanSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
        }
        insert cons;

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            payload.products[0].tierRatePlanCode = null;
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;

            if( i > 99 )
            {
                activity.ActivityType__c = 'BuyNow';
                activity.ActivityID__c = 'BuyNow:' + activity.Name;
            }

            if( i == 100 )
            {
                resp.data.subscriptionId = 'abcdef123';
            }

            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Subscription_Master__c] );
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterWithoutProductsFailure()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
        }
        insert cons;

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products = null;
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;

            if( i > 99 )
            {
                activity.ActivityType__c = 'BuyNow';
                activity.ActivityID__c = 'BuyNow:' + activity.Name;
            }

            if( i == 100 )
            {
                resp.data.subscriptionId = 'abcdef123';
            }

            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

            activities = SageApiActivityUtils.refreshActivities(activities);
            System.debug('activities: ' + JSON.serialize(activities));

            System.assert( activities[0].ActivityStatus__c == SageApiStatus.ManualInterventionRequired );
        Test.stopTest();
    }
/**//**/
    @IsTest static void testCreateOrUpdateSubscriptionMasterWithoutAccountFailure()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
        }
        insert cons;

        Zuora__Subscription__c subs = new Zuora__Subscription__c();
        subs.Zuora__Zuora_Id__c = 'abcdef123';
        insert subs;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;

            if( i > 99 )
            {
                activity.ActivityType__c = 'BuyNow';
                activity.ActivityID__c = 'BuyNow:' + activity.Name;
            }

            if( i == 100 )
            {
                resp.data.subscriptionId = 'abcdef123';
            }

            activity.Artifacts__c = JSON.serialize( resp );
            //activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.ZuoraSubscriptionId__c = subs.Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster( step, activities );

            activities = SageApiActivityUtils.refreshActivities(activities);
            System.debug('activities: ' + JSON.serialize(activities));

            System.assert( activities[0].ActivityStatus__c == SageApiStatus.ManualInterventionRequired );
        Test.stopTest();
    }
/**//**/
    @IsTest static void testConvertSubscriptionMasterSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'subscription_' + i;
            subs.add( sub );
        }
        insert subs;

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'TestQuote_' + i;
            quote.zqu__Opportunity__c = opps[i].Id;
            quote.zqu__Account__c = cons[i].AccountId;
            quote.zqu__BillToContact__c = cons[i].Id;
            quotes.add( quote );
        }
        insert quotes;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Quote__c = quotes[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;
            resp.data.quoteId = quotes[i].Id;
            resp.data.subscriptionId = subs[i].Zuora__Zuora_Id__c;

            activity.ActivityType__c = 'TryNowConvert';
            activity.ActivityID__c = 'TryNowConvert:' + activity.Name;
            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Opportunity__c = opps[i].Id;
            activity.Quote__c = quotes[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [ SELECT Count() FROM Subscription_Master__c WHERE Subscription__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertSubscriptionMasterWithEMSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'subscription_' + i;
            subs.add( sub );
        }
        insert subs;

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'TestQuote_' + i;
            quote.zqu__Opportunity__c = opps[i].Id;
            quote.zqu__Account__c = cons[i].AccountId;
            quote.zqu__BillToContact__c = cons[i].Id;
            quotes.add( quote );
        }
        insert quotes;

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Processed';
            msgs.add(msg);
        }
        insert msgs;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Quote__c = quotes[i].Id;
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Trial';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;
            resp.data.quoteId = quotes[i].Id;
            resp.data.subscriptionId = subs[i].Zuora__Zuora_Id__c;

            activity.ActivityType__c = 'TryNowConvert';
            activity.ActivityID__c = 'TryNowConvert:' + activity.Name;
            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Opportunity__c = opps[i].Id;
            activity.Quote__c = quotes[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [ SELECT Count() FROM Subscription_Master__c WHERE Subscription__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertSubscriptionMasterWithEMErrorSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'subscription_' + i;
            subs.add( sub );
        }
        insert subs;

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'TestQuote_' + i;
            quote.zqu__Opportunity__c = opps[i].Id;
            quote.zqu__Account__c = cons[i].AccountId;
            quote.zqu__BillToContact__c = cons[i].Id;
            quotes.add( quote );
        }
        insert quotes;

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Error';
            msgs.add(msg);
        }
        insert msgs;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Quote__c = quotes[i].Id;
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Trial';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
            resp.data = new SageApiBuyNowActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            resp.data.accountId = cons[i].AccountId;
            resp.data.quoteId = quotes[i].Id;
            resp.data.subscriptionId = subs[i].Zuora__Zuora_Id__c;

            activity.ActivityType__c = 'TryNowConvert';
            activity.ActivityID__c = 'TryNowConvert:' + activity.Name;
            activity.Artifacts__c = JSON.serialize( resp );
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Opportunity__c = opps[i].Id;
            activity.Quote__c = quotes[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertSubscriptionMaster( step, activities );

        Test.stopTest();

        System.assertEquals( 1, [ SELECT Count() FROM Subscription_Master__c WHERE Subscription__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertSubscriptionMasterBadPayloadFailure()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'London'
                , BillingPostalCode = 'SW1A 2AA'
                , BillingCountryCode = 'GB'
                , BillingStreet = 'Downing Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'London'
                        , MailingPostalCode = 'SW1A 2AA'
                        , MailingCountryCode = 'GB'
                        , MailingStreet = 'Downing Street'
                        )
            );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'subscription_' + i;
            subs.add( sub );
        }
        insert subs;

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Name = 'TestQuote_' + i;
            quote.zqu__Opportunity__c = opps[i].Id;
            quote.zqu__Account__c = cons[i].AccountId;
            quote.zqu__BillToContact__c = cons[i].Id;
            quotes.add( quote );
        }
        insert quotes;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 1; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Quote__c = quotes[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            activity.ActivityType__c = SageApiActivityTriggerHandler.TryNowConvertActivityType;
            activity.ActivityID__c = SageApiActivityTriggerHandler.TryNowConvertActivityType + activity.Name;
            activity.Payload__c = '{';
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Opportunity__c = opps[i].Id;
            activity.Quote__c = quotes[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertSubscriptionMaster( step, activities );

            activities = SageApiActivityUtils.refreshActivities(activities);
            System.debug('activities: ' + JSON.serialize(activities));

            System.assert( activities[0].ActivityStatus__c == SageApiStatus.ManualInterventionRequired );
        Test.stopTest();
    }
/**//**/
    @IsTest static void testConvertTrialToPaidSuccess()
    {
        Integer count = 1;
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        )
            );
        }
        insert cons;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Processed';
            msgs.add(msg);
        }
        insert msgs;

        List<SageApiActivity__c> trialActivities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            trialActivities.add( activity );
        }
        insert trialActivities;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Trial';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsmaster.CbcSubscriptionId__c = 'CbcSubscriptionId__c:'+i;
            subsMaster.Sage_API_Activity__c = trialActivities[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c:' + i;
            subs.add( sub );
        }
        insert subs;

        for(Integer i = 0; i < count; i++)
        {
            trialActivities[i].Entitlement_Message__c = msgs[i].Id;
            trialActivities[i].SubscriptionMaster__c = subsMasters[i].Id;
            trialActivities[i].ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
        }

        update trialActivities;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMasters[i].CbcSubscriptionId__c, subs[i].Zuora__Zuora_Id__c);
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertTrialToPaid( step, activities );

        Test.stopTest();

        List<Subscription_Master__c> subms = [ SELECT Id, CbcSubscriptionId__c, Status__c FROM Subscription_Master__c ];
        System.debug('subms: ' + JSON.serialize(subms));

        System.assertEquals( count, [ SELECT Count() FROM Subscription_Master__c WHERE CbcSubscriptionId__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertTrialToPaidWithEMSuccess()
    {
        Integer count = 1;
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        )
            );
        }
        insert cons;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Processed';
            msgs.add(msg);
        }
        insert msgs;

        List<SageApiActivity__c> trialActivities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            trialActivities.add( activity );
        }
        insert trialActivities;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Active';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsmaster.CbcSubscriptionId__c = 'CbcSubscriptionId__c:'+i;
            subsMaster.Sage_API_Activity__c = trialActivities[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c:' + i;
            subs.add( sub );
        }
        insert subs;

        for(Integer i = 0; i < count; i++)
        {
            trialActivities[i].Entitlement_Message__c = msgs[i].Id;
            trialActivities[i].SubscriptionMaster__c = subsMasters[i].Id;
            trialActivities[i].ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
        }

        update trialActivities;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMasters[i].CbcSubscriptionId__c, subs[i].Zuora__Zuora_Id__c);
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertTrialToPaid( step, activities );

        Test.stopTest();

        List<Subscription_Master__c> subms = [ SELECT Id, CbcSubscriptionId__c, Status__c FROM Subscription_Master__c ];
        System.debug('subms: ' + JSON.serialize(subms));

        System.assertEquals( count, [ SELECT Count() FROM Subscription_Master__c WHERE CbcSubscriptionId__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertTrialToPaidWithEMErrorSuccess()
    {
        Integer count = 1;
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        )
            );
        }
        insert cons;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Error';
            msgs.add(msg);
        }
        insert msgs;

        List<SageApiActivity__c> trialActivities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            trialActivities.add( activity );
        }
        insert trialActivities;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Active';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsmaster.CbcSubscriptionId__c = 'CbcSubscriptionId__c:'+i;
            subsMaster.Sage_API_Activity__c = trialActivities[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c:' + i;
            subs.add( sub );
        }
        insert subs;

        for(Integer i = 0; i < count; i++)
        {
            trialActivities[i].Entitlement_Message__c = msgs[i].Id;
            trialActivities[i].SubscriptionMaster__c = subsMasters[i].Id;
            trialActivities[i].ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
        }

        update trialActivities;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMasters[i].CbcSubscriptionId__c, subs[i].Zuora__Zuora_Id__c);
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertTrialToPaid( step, activities );

        Test.stopTest();

        List<Subscription_Master__c> subms = [ SELECT Id, CbcSubscriptionId__c, Status__c FROM Subscription_Master__c ];
        System.debug('subms: ' + JSON.serialize(subms));

        System.assertEquals( count, [ SELECT Count() FROM Subscription_Master__c WHERE CbcSubscriptionId__c != null AND Status__c = 'Active' ] );
    }
/**//**/
    @IsTest static void testConvertTrialToPaidNoPayloadError()
    {
        Integer count = 1;
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        )
            );
        }
        insert cons;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Processed';
            msgs.add(msg);
        }
        insert msgs;

        List<SageApiActivity__c> trialActivities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            trialActivities.add( activity );
        }
        insert trialActivities;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Trial';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            subsmaster.CbcSubscriptionId__c = 'CbcSubscriptionId__c:'+i;
            subsMaster.Sage_API_Activity__c = trialActivities[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c:' + i;
            subs.add( sub );
        }
        insert subs;

        for(Integer i = 0; i < count; i++)
        {
            trialActivities[i].Entitlement_Message__c = msgs[i].Id;
            trialActivities[i].SubscriptionMaster__c = subsMasters[i].Id;
            trialActivities[i].ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
        }

        update trialActivities;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMasters[i].CbcSubscriptionId__c, subs[i].Zuora__Zuora_Id__c);
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            activity.Payload__c = null;

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertTrialToPaid( step, activities );

        Test.stopTest();

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.debug('activities: ' + JSON.serialize(activities));

        System.assert( activities[0].ActivityStatus__c == SageApiStatus.ManualInterventionRequired );
    }
/**//**/
    @IsTest static void testConvertTrialToPaidNoTrialIdError()
    {
        Integer count = 1;
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account(
                Name = 'Unknown' + i + ' Inc.'
                , BillingCity = 'Atlanta'
                , BillingPostalCode = '30318'
                , BillingCountryCode = 'US'
                , BillingStreet = 'Peachtree Street'
                , Sales_Office__c = 'Atlanta CBC'  )
            );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact(
                        Firstname = 'Some'
                        , Lastname = 'One' + acc.Name.substringBefore(' ')
                        , AccountId = acc.Id
                        , MailingCity = 'Atlanta'
                        , MailingPostalCode = '30318'
                        , MailingCountryCode = 'US'
                        , MailingStreet = 'Peachtree Street'
                        )
            );
        }
        insert cons;

        Product2 zproduct = [SELECT id FROM Product2 WHERE zqu__ZuoraId__c='p2' LIMIT 1];
        Product_Tier__c tier = [SELECT id FROM Product_Tier__c WHERE Product_Tier_Code__c='SageOne-Start-US-Test' LIMIT 1];
        Product_Tier_Rate_Plan__c plan = [SELECT id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: tier.Id AND Name = 'Monthly' LIMIT 1];

        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Entitlement_Message__c msg = new Entitlement_Message__c();
            msg.Status__c = 'Processed';
            msgs.add(msg);
        }
        insert msgs;

        List<SageApiActivity__c> trialActivities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.products[0].tierCode = 'SageOne-Start-US-Test';
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisStartTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            trialActivities.add( activity );
        }
        insert trialActivities;

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Subscription_Master__c subsMaster = new Subscription_Master__c();
            subsMaster.Account__c = accs[i].Id;
            subsMaster.Product_Tier__c = tier.Id;
            subsMaster.Product_Tier_Rate_Plan__c = plan.Id;
            subsMaster.Product__c = zproduct.Id;
            subsMaster.Start_Date__c = System.now();
            subsMaster.End_Date__c = System.now().addDays( 30 );
            subsMaster.Status__c = 'Trial';
            subsMaster.Entitlement_Id__c = msgs[i].Id;
            //subsmaster.CbcSubscriptionId__c = 'CbcSubscriptionId__c:'+i;
            subsMaster.Sage_API_Activity__c = trialActivities[i].Id;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        List<Zuora__Subscription__c> subs = new List<Zuora__Subscription__c>();
        for( Integer i = 0; i < count; i++ )
        {
            Zuora__Subscription__c sub = new Zuora__Subscription__c();
            sub.Zuora__Zuora_Id__c = 'Zuora__Zuora_Id__c:' + i;
            subs.add( sub );
        }
        insert subs;

        for(Integer i = 0; i < count; i++)
        {
            trialActivities[i].Entitlement_Message__c = msgs[i].Id;
            trialActivities[i].SubscriptionMaster__c = subsMasters[i].Id;
            trialActivities[i].ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
        }

        update trialActivities;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < count; i++)
        {
            SageApiTryNowConvertActivityRequest payload = SageApiTestUtils.createTetrisConvertTrialPayload(subsMasters[i].CbcSubscriptionId__c, subs[i].Zuora__Zuora_Id__c);
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

            activity.ActivityType__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType;
            activity.ActivityID__c = String.valueOf(count);
            activity.ActivityID__c = SageApiActivityTriggerHandler.TetrisConvertTrialActivityType + ':' + activity.ActivityID__c;
            activity.Account__c = cons[i].AccountId;
            activity.Contact__c = cons[i].Id;
            activity.Entitlement_Message__c = msgs[i].Id;
            activity.SubscriptionMaster__c = subsMasters[i].Id;
            activity.ZuoraSubscriptionId__c = subs[i].Zuora__Zuora_Id__c;
            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            SageApiTryNowActivityUtils.convertTrialToPaid( step, activities );

            activities = SageApiActivityUtils.refreshActivities(activities);
            System.debug('activities: ' + JSON.serialize(activities));

            System.assert( activities[0].ActivityStatus__c == SageApiStatus.ManualInterventionRequired );

        Test.stopTest();
    }
/**//**/
    @IsTest static void testUpdateArtifactWithErrorStringSuccess()
    {
        SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        payload.products[0].tierCode = 'SageOne-Start-US-Test';
        SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
        resp.data = new SageApiBuyNowActivityResponse.ResponseData();

        activity.ActivityType__c = 'TryNow';
        activity.ActivityID__c = 'TryNow:' + activity.Name;

        activity.Artifacts__c = JSON.serialize( resp );
        String artifactsBefore = activity.Artifacts__c;


        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );

        Test.startTest();

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            errors.add( new SageApiActivityError( '001', 'self', 'something went wrong' ) );
            SageApiTryNowActivityUtils.updateArtifactWithErrorString( activity, JSON.serialize( errors ) );

        Test.stopTest();

        System.assertNotEquals( artifactsBefore, activity.Artifacts__c );
    }

/**//**/
    @IsTest static void testGetRequestProducts()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            activities.add( activity );
        }
        insert activities;

        Test.startTest();

            List<SageApiActivityRequestObjects.Product> prods = SageApiTryNowActivityUtils.getRequestProducts( activities );
            System.assertEquals( 1, prods.size() );

        Test.stopTest();
    }
/**//**/
    @IsTest static void testGetRequestLeads()
    {
        List<Lead> leads = new List<Lead>();
        for(Integer i = 0; i < 1; i++)
        {
            leads.add( new Lead( Firstname = 'Some', Lastname = 'One'+i, Company = 'Example Inc.' ) );
        }
        insert leads;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiTryNowActivityRequest payload = SageApiTestUtils.createPayload();
            payload.contact.leadId = leads[i].id;
            SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
            activities.add( activity );
        }
        insert activities;

        Test.startTest();

            Map<Id, Lead> mapLeads = SageApiTryNowActivityUtils.getRequestLeads( activities );
            System.assertEquals( 1, mapLeads.size() );

        Test.stopTest();
    }

    // need valid charge groups assigned first
    @IsTest static void testGetPricingSuccess()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            activities.add( SageApiTestUtils.createActivity(SageApiTestUtils.createPayload()) );
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', BillingCountryCode = 'GB', BillingCity='London', BillingStreet='100 My Street', BillingPostalCode = 'SW1A 2AA', Sales_Office__c='Atlanta CBC', VAT_Number__c='GB VAT' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), MailingCountryCode = 'GB', MailingStreet='100 My Street', MailingCity='London', MailingPostalCode = 'SW1A 2AA', AccountId = acc.Id ) );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        zqu__ProductRatePlan__c rate = [SELECT id FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = 'r2' LIMIT 1];

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        List<ID> quoteIds = new List<ID>();

        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c newQuote = new zqu__Quote__c();
            newQuote.zqu__Currency__c = 'USD';
            newQuote.zqu__Account__c = cons[i].AccountId;
            newQuote.zqu__SoldToContact__c = cons[i].Id;
            newQuote.zqu__BillToContact__c = cons[i].Id;
            //newQuote.zqu__Previewed_SubTotal__c = 100;
            //newQuote.zqu__Previewed_Total__c = 100;
            //newQuote.zqu__Previewed_Tax__c = 20;
            newQuote.zqu__Opportunity__c = opps[i].Id;
            newQuote.zqu__PaymentMethod__c = 'Credit Card';
            newQuote.zqu__StartDate__c = System.today();
            newQuote.zqu__ValidUntil__c = System.today().addDays( 30 );
            quotes.add( newQuote );
        }
        insert quotes;
        Integer index = 0;
        for (zqu__Quote__c quote : quotes) {
            quoteIds.add(quote.Id);
            zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
            testQuoteAmendment.Name = 'my test quote amendment';
            testQuoteAmendment.zqu__Quote__c = quote.Id;
            insert testQuoteAmendment;

            zqu__QuoteRatePlan__c testQuoteRatePlan = new zqu__QuoteRatePlan__c();
            testQuoteRatePlan.Name = 'my test quote rate plan';
            testQuoteRatePlan.zqu__QuoteAmendment__c = testQuoteAmendment.Id;
            insert testQuoteRatePlan;

            zqu__QuoteRatePlanCharge__c QuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
            QuoteRatePlanCharge.CurrencyIsoCode = quote.CurrencyIsoCode;
            QuoteRatePlanCharge.zqu__QuoteRatePlan__c=testQuoteRatePlan.Id;
            QuoteRatePlanCharge.zqu__Quantity__c = 1;
            QuoteRatePlanCharge.zqu__ProductRatePlanCharge__c = rate.Id;


            zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, rate.Id);
            if (chargeGroup != null)
                chargeGroup = zqu.ZQuoteUtil.addChargeGroup(chargeGroup);

            activities[index].Account__c = accs[index].Id;
            activities[index].Contact__c = cons[index].Id;
            activities[index].Opportunity__c = opps[index].Id;
            activities[index].Quote__c = quote.Id;
            index++;
        }

        insert activities;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        string quoteListStr = JSON.serialize(quotes);
        string quoteIdListStr = JSON.serialize(quoteIds);
        string stepStr = JSON.serialize(step);
        string activitiesStr = JSON.serialize(activities);

        Test.startTest();

        try {
            SageApiTryNowActivityUtils.getPricing(stepStr, activitiesStr, quoteListStr, quoteIdListStr);
        } catch (Exception e) {}

        Test.stopTest();
        System.assertEquals( 1, [SELECT Count() FROM zqu__Quote__c WHERE zqu__SoldToContact__c IN :cons] );
    }

    // need valid charge groups assigned first
    @IsTest static void testGetPricingPayloadError()
    {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            activities.add( SageApiTestUtils.createActivity(SageApiTestUtils.createPayload()) );
            activities[i].Payload__c = '{';
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', BillingCountryCode = 'GB', BillingCity='London', BillingStreet='100 My Street', BillingPostalCode = 'SW1A 2AA', Sales_Office__c='Atlanta CBC', VAT_Number__c='GB VAT' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), MailingCountryCode = 'GB', MailingStreet='100 My Street', MailingCity='London', MailingPostalCode = 'SW1A 2AA', AccountId = acc.Id ) );
            opps.add( new Opportunity( Name = 'SomeoneOpp_' + acc.Name.substringBefore(' '), StageName = '06 Signed Order', CloseDate = System.today().addDays( 100 ) ) );
        }
        insert cons;
        insert opps;

        zqu__ProductRatePlan__c rate = [SELECT id FROM zqu__ProductRatePlan__c WHERE zqu__ZuoraId__c = 'r2' LIMIT 1];

        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        List<ID> quoteIds = new List<ID>();

        for( Integer i = 0; i < 1; i++ )
        {
            zqu__Quote__c newQuote = new zqu__Quote__c();
            newQuote.zqu__Currency__c = 'USD';
            newQuote.zqu__Account__c = cons[i].AccountId;
            newQuote.zqu__SoldToContact__c = cons[i].Id;
            newQuote.zqu__BillToContact__c = cons[i].Id;
            //newQuote.zqu__Previewed_SubTotal__c = 100;
            //newQuote.zqu__Previewed_Total__c = 100;
            //newQuote.zqu__Previewed_Tax__c = 20;
            newQuote.zqu__Opportunity__c = opps[i].Id;
            newQuote.zqu__PaymentMethod__c = 'Credit Card';
            newQuote.zqu__StartDate__c = System.today();
            newQuote.zqu__ValidUntil__c = System.today().addDays( 30 );
            quotes.add( newQuote );
        }
        insert quotes;
        Integer index = 0;
        for (zqu__Quote__c quote : quotes) {
            quoteIds.add(quote.Id);

            zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
            testQuoteAmendment.Name = 'my test quote amendment';
            testQuoteAmendment.zqu__Quote__c = quote.Id;
            insert testQuoteAmendment;

            zqu__QuoteRatePlan__c testQuoteRatePlan = new zqu__QuoteRatePlan__c();
            testQuoteRatePlan.Name = 'my test quote rate plan';
            testQuoteRatePlan.zqu__QuoteAmendment__c = testQuoteAmendment.Id;
            insert testQuoteRatePlan;

            zqu__QuoteRatePlanCharge__c QuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
            QuoteRatePlanCharge.CurrencyIsoCode = quote.CurrencyIsoCode;
            QuoteRatePlanCharge.zqu__QuoteRatePlan__c=testQuoteRatePlan.Id;
            QuoteRatePlanCharge.zqu__Quantity__c = 1;
            QuoteRatePlanCharge.zqu__ProductRatePlanCharge__c = rate.Id;  

            zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup(quote.Id, rate.Id);
            if (chargeGroup != null)
                chargeGroup = zqu.ZQuoteUtil.addChargeGroup(chargeGroup);

            activities[index].Account__c = accs[index].Id;
            activities[index].Contact__c = cons[index].Id;
            activities[index].Opportunity__c = opps[index].Id;
            activities[index].Quote__c = quote.Id;
            index++;
        }
        
        insert activities;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
        string quoteListStr = JSON.serialize(quotes);
        string quoteIdListStr = JSON.serialize(quoteIds);
        string stepStr = JSON.serialize(step);
        string activitiesStr = JSON.serialize(activities);

        Test.startTest();

        try {
            SageApiTryNowActivityUtils.getPricing(stepStr, activitiesStr, quoteListStr, quoteIdListStr);
        } catch (Exception e) {}

        activities = SageApiActivityUtils.refreshActivities(activities);
        System.assertEquals(false, activities[0].QuoteMetricsCalculated__c);

        Test.stopTest();
    }
/**//**/
    @IsTest static void testGetQuoteTemplateSettings()
    {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];

        zqu__Quote_Template__c template = new zqu__Quote_Template__c(Name='test', zqu__Quote_Type__c='New Subscription', Country__c='US - United States', Language__c='English', zqu__Template_Id__c='2c92c0f9560cb90d01560f2dbed2080d');
        insert template;
        System.debug('template: '+template);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
        
        List<Account> accs = new List<Account>();
        Map<ID, Account> accountMap = new Map<ID, Account>();
        Integer count = 1;
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', Locale_Billing_CC__c='US', BillingCountryCode='US', BillingCity='Atlanta', BillingPostalCode='30318', BillingStateCode='GA', BillingStreet='1800 Peachtree St.', Sales_Office__c='Atlanta CBC', VAT_Number__c='US VAT', Locale__c=loc.Id, RecordTypeId=recordTypeId ) );
        }
        insert accs;
        System.debug('accs: '+accs);
        
        accountMap.putAll([SELECT ID, BillingCountryCode, Locale__r.Language__c FROM Account WHERE ID IN: accs]);
        System.debug('accountMap: '+JSON.serialize(accountMap));
        Test.startTest();
            
        List<zqu__Quote_Template__c> quoteTemplateSettings = SageApiTryNowActivityUtils.getQuoteTemplateSettings('New Subscription', accountMap);
    
        Test.stopTest();
        
        System.assert(quoteTemplateSettings!=null,'Expected quoteTemplateSettings to return a template');
    }

/**//**/
    @IsTest static void testGetActivitySubscriptionMastersSuccess()
    {
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        System.debug(activities);
    
        Test.startTest();

            Map<ID, ID> activitySMMap = SageApiTryNowActivityUtils.getActivitySubscriptionMasters(activities);
    
        Test.stopTest();
        
        System.assert( activitySMMap.isEmpty() );
    }

/**//**/
/*
    @IsTest static void testGetInvoiceTemplateSettings()
    {
        SageApiTestUtils.setup();
        
        Locale__c locale = new Locale__c(BillingBatch__c='Batch1',Country__c='US - United States',CurrencyIsoCode='USD',Default_Locale__c='Yes',Language__c='English',Name='en_US',PayNow_EmailTemplateName__c='PayNow Complete',SalesOffice__c='Atlanta CBC',TimeZone__c='America/New_York',LanguageLocaleKey__c='en_US');
        insert locale;
        System.debug('locale: '+locale);

        zqu__InvoiceTemplate__c template = new zqu__InvoiceTemplate__c(Name='US Invoice Template', Country__c='US - United States', Language__c='English', zqu__ZuoraId__c='2c92c0f9555cf10501555e43c56333e5');
        insert template;
        System.debug('template: '+template);
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
        
        List<Account> accs = new List<Account>();
        Map<ID, Account> accountMap = new Map<ID, Account>();
        Integer count = 1;
        for( Integer i = 0; i < count; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.', Locale_Billing_CC__c='US', BillingCountryCode='US', BillingCity='Atlanta', BillingPostalCode='30318', BillingStateCode='GA', BillingStreet='1800 Peachtree St.', Sales_Office__c='Atlanta CBC', Type = 'Customer', Locale__c=locale.Id, RecordTypeId=recordTypeId ) );
        }
        insert accs;
        System.debug('accs: '+accs);

        for( Integer i = 0; i < count; i++ )
            accountMap.put(accs[i].Id, accs[i]);
        
        //accountMap.putAll([SELECT ID, BillingCountryCode, Locale__r.Language__c FROM Account WHERE ID IN: accs]);
        System.debug('testGetInvoiceTemplateSettings accountMap: '+JSON.serialize(accountMap));
        Test.startTest();
            
        List<zqu__InvoiceTemplate__c> templateSettings = SageApiTryNowActivityUtils.getInvoiceTemplateSettings(accountMap);
    
        Test.stopTest();
        
        System.assertEquals(null, templateSettings);
    }
*/
}