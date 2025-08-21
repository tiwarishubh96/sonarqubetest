/**
* @description Tests for SageApiBuyNowActivityUtils class.
* - Written by Salesforce Services on behalf of Mick Andrew’s team for code coverage
*
* @author Richard Wintle
*/
@isTest(SeeAllData=false)
public class SageApiBuyNowActivityUtilsTest {
    private static Datetime todaysDate;
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class 

    static {
        // setup default records and variables
        // 
        todaysDate=Date.today();
    }

    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupLocale();
        SageApiTestUtils.setupProductCatalog();
        SageApiTestUtils.setupCommunity();
    }

    /**
     * Test validatePayload - Successful execution.
     */
    static testmethod void validatePayload() {
        //
        // setup product tier and product tier rate plan lists
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        List<Product_Tier__c> tierList = new List<Product_Tier__c>();
        tierList.add(createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2'));
        Product_Tier_Rate_Plan__c ptrp=createProductTierRatePlan(tierList[0].Id, ratePlan.Id, 'Monthly');
        List<Product_Tier_Rate_Plan__c> ptrpList=[select Name, Product_Tier__r.Product_Tier_Code__c from Product_Tier_Rate_Plan__c where id=:ptrp.Id];
        //
        // setup valid activity
        SageApiActivity__c saa=createValidActivity(1);
        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        //
        // execute the test
        Test.startTest();
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep, tierList, ptrpList, tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);
        Test.stopTest();
        //
        // check success
        system.assert(isValidPayload);
    }
    /**
     * Test validatePayload, fail - null payload
     * NOTE: Can only test throws exception. It cannot complete parse of payload without throwing exception and have 'req'=null
     */
    static testmethod void validatePayload_NullPayload() {
        SageApiActivity__c saa=createSageApiActivity(1, null, null, null);
        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        Test.startTest();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep, new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
        Test.stopTest();
        //
        // check expected errors
        system.assert(!isValidPayload);
    }
    /**
     * Test validatePayload, fail - bad details in Contact, Account and Product in the payload.
     */
    static testmethod void validatePayload_BadConAccProd() {
        String startDate=todaysDate.addDays(-2).format('yyyy-MM-dd'); // before todays date -1
        String endDate=todaysDate.addDays(-30).format('yyyy-MM-dd');	// before start date
        SageApiActivity__c saa=createSageApiActivity(1, startDate, endDate, ' "contact": '+
                '{"identityType": "",'+
                '"identityId": "",'+
                '"leadId": null,"firstName": "","lastName": "",'+
                '"email": "","phone": null,'+
                '"address1": null,"address2": null,"city": null,'+
                '"county": null,    "postalCode": null,    "state": null,    '+
                '"countryCode": null  },  "account": {    "name": "",    '+
                '"phone": "14704474146",    "address1": "25 The Street",    '+
                '"address2": "The Village",    "city": "The City",    "state": "GA",   '+
                ' "countryCode": "US",    "postalCode": "30318",    '+
                '"paymentMethodId": "",    '+
                '"paymentMethodType": "",    "currencyCode": null  },  '+
                '"products": [{ "tierCode": "", "tierRatePlanCode": "" },{"tierCode":""} ],'+
                ' "completionNotifyUrl": null,  "version": null}');

        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        Test.startTest();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep,new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
        Test.stopTest();
        //
        // check expected errors
        system.assert(!isValidPayload);
    }
    /**
     * Test validatePayload, fail - blank dates in payload.
     */
    static testmethod void validatePayload_BlankDates() {
        String startDate=''; // blank date
        String endDate='';	// blank date
        SageApiActivity__c saa=createSageApiActivity(1, startDate, endDate, ' "contact": '+
                '{"identityType": "",'+
                '"identityId": "",'+
                '"leadId": null,"firstName": "","lastName": "",'+
                '"email": "","phone": null,'+
                '"address1": null,"address2": null,"city": null,'+
                '"county": null,    "postalCode": null,    "state": null,    '+
                '"countryCode": null  },  "account": {    "name": "",    '+
                '"phone": "14704474146",    "address1": "25 The Street",    '+
                '"address2": "The Village",    "city": "The City",    "state": "GA",   '+
                ' "countryCode": "US",    "postalCode": "30318",    '+
                '"paymentMethodId": "",    '+
                '"paymentMethodType": "",    "currencyCode": null  },  '+
                '"products": [{ "tierCode": "", "tierRatePlanCode": "" },{"tierCode":""} ],'+
                ' "completionNotifyUrl": null,  "version": null}');

        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        Test.startTest();
        // no activity - code coverage only
        try {
            Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(null, saaStep,new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
            system.assert(!isValidPayload);
        }catch(Exception e) {}

        // no step - code coverage only
        try {
            Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, null,new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
            system.assert(!isValidPayload);
        }catch(Exception e) {}

        // blank dates
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep,new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
        system.assert(!isValidPayload);
        Test.stopTest();
    }
    /**
     * Test validatePayload, fail - blank Account, Contact and Product in payload.
     */
    static testmethod void validatePayload_BlankConAccProd() {
        String startDate=todaysDate.addDays(-1).format('yyyy-MM-dd'); // before todays date
        String endDate=todaysDate.addDays(-30).format('yyyy-MM-dd');	// before start date
        SageApiActivity__c saa=createSageApiActivity(1, startDate, endDate, ' "contact": null, '+
                '"account": null, '+
                '"products": null ,'+
                ' "completionNotifyUrl": null,  "version": null}');

        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        Test.startTest();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep,new List<Product_Tier__c>(), new List<Product_Tier_Rate_Plan__c>(), null, null, null, null, null, null, null, null);
        Test.stopTest();
        system.assert(!isValidPayload);
    }

    static testmethod void validatePayloadWithTokens() {
        //
        // setup valid activity
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);
        activity.PayNowToken__c = t.Id;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        insert activities;
        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');

        List<PayNowToken__c> tokens = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
/*
        Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
        List<PayNowToken__c> tokens = (tokenActivityMap == null ? null : new List<PayNowToken__c>(tokenActivityMap.keySet()));
 */
        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        if (products == null) products = new List<SageApiActivityRequestObjects.Product>();
        if (tokens != null)
            for (PayNowToken__c token : tokens) {
                if (String.isBlank(token.Products__c)) continue;

                List<SageApiActivityRequestObjects.ProductConfig> productConfigs = (List<SageApiActivityRequestObjects.ProductConfig>) JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                if (productConfigs == null || productConfigs.size() == 0) continue;

                for (SageApiActivityRequestObjects.ProductConfig productConfig : productConfigs) {
                    SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                    product.tierCode = productConfig.tierCode;
                    product.pricingCode = productConfig.pricingCode;
                    if (String.isBlank(product.pricingCode))
                        product.pricingCode = '_LIST';
                    if (productConfig.tierRatePlanCodes!=null && productConfig.tierRatePlanCodes.size()>0)
                        product.tierRatePlanCode = productConfig.tierRatePlanCodes[0].tierRatePlanCode;
                    products.add(product);
                }
            }
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);

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

        //
        // execute the test
        Test.startTest();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);
        Test.stopTest();
        //
        // check success
        system.assert(isValidPayload);
    }
    static testmethod void validatePayloadWithAccountAndContact() {
        //
        // setup valid activity
        SageApiTryNowActivityRequest payload =  SageApiTestUtils.createTetrisStartTrialPayload();
        SageApiActivity__c activity = SageApiTestUtils.createActivity( payload );

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

        activity.User__c = user.Id;
        activity.CommunityMembership__c = memebership.Id;
        activity.SageUserIdentityProvider__c = ident.Id;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        insert activities;
        SageApiActivityStep step=new SageApiActivityStep(1, 'stepNameTest');

        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        List<SageApiActivityRequestObjects.Product> products = SageApiTryNowActivityUtils.getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(products);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);

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

        //
        // execute the test
        Test.startTest();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(activity, step, productTiers, (listTierMap == null ? null :listTierMap.values()), tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);
        Test.stopTest();
        //
        // check success
        system.assert(isValidPayload);
    }

    /**
     * Test validatePayload - no zuoraSubscriptonId.
     */
    static testmethod void validatePayloadNoZuoraSubscriptonId() {
        //
        // setup product tier and product tier rate plan lists
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        List<Product_Tier__c> tierList = new List<Product_Tier__c>();
        tierList.add(createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2'));
        Product_Tier_Rate_Plan__c ptrp=createProductTierRatePlan(tierList[0].Id, ratePlan.Id, 'Monthly');
        List<Product_Tier_Rate_Plan__c> ptrpList=[select Name, Product_Tier__r.Product_Tier_Code__c from Product_Tier_Rate_Plan__c where id=:ptrp.Id];
        //
        // setup valid activity
        SageApiActivity__c saa=createValidActivity(1);
        SageApiBuyNowActivityRequest req = (SageApiBuyNowActivityRequest)JSON.deserialize(saa.Payload__c, SageApiBuyNowActivityRequest.class);
        req.zuoraSubscriptionId = null;
        saa.Payload__c = JSON.serialize(req);
        saa.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartPaidActivityType;
        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        //
        // execute the test
        Test.startTest();
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep, tierList, ptrpList, tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);
        Test.stopTest();
        //
        // check success
        system.assert(!isValidPayload);
    }
    /**
     * Test validatePayload - no zuoraSubscriptonId.
     */
    static testmethod void validatePayloadWithZuoraSubscriptonId() {
        //
        // setup product tier and product tier rate plan lists
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        List<Product_Tier__c> tierList = new List<Product_Tier__c>();
        tierList.add(createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2'));
        Product_Tier_Rate_Plan__c ptrp=createProductTierRatePlan(tierList[0].Id, ratePlan.Id, 'Monthly');
        List<Product_Tier_Rate_Plan__c> ptrpList=[select Name, Product_Tier__r.Product_Tier_Code__c from Product_Tier_Rate_Plan__c where id=:ptrp.Id];
        //
        // setup valid activity
        SageApiActivity__c saa=createValidActivity(1);
        SageApiBuyNowActivityRequest req = (SageApiBuyNowActivityRequest)JSON.deserialize(saa.Payload__c, SageApiBuyNowActivityRequest.class);
        req.zuoraSubscriptionId = 'SomeID';
        saa.Payload__c = JSON.serialize(req);
        saa.ActivityType__c = SageApiActivityTriggerHandler.TetrisStartPaidActivityType;
        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        //
        // execute the test
        Test.startTest();
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep, tierList, ptrpList, tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, null, null);
        Test.stopTest();
        //
        // check success
        system.assert(isValidPayload);
    }
    /**
     * Test validatePayload - Successful execution.
     */
    static testmethod void validatePayloadWithSubscriptionMaster() {
        //
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();

        // setup product tier and product tier rate plan lists
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        List<Product_Tier__c> tierList = new List<Product_Tier__c>();
        tierList.add(createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2'));
        Product_Tier_Rate_Plan__c ptrp=createProductTierRatePlan(tierList[0].Id, ratePlan.Id, 'Monthly');
        List<Product_Tier_Rate_Plan__c> ptrpList=[select Name, Product_Tier__r.Product_Tier_Code__c from Product_Tier_Rate_Plan__c where id=:ptrp.Id];

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Product_Tier__c = tierList[0].Id;
        sm.Product_Tier_Rate_Plan__c = ptrp.Id;
        sm.Quote__c = zquote.Id;
        sm.Product__c = prod.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Trial';
        insert sm;
        //
        // setup valid activity
        SageApiActivity__c saa=createValidActivity(1);
        saa.SubscriptionMaster__c = sm.Id;
        insert saa;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        //
        // execute the test
        Test.startTest();
        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = new Map<string, List<PricingCodeCharge__c>>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        Map<ID, ID> activitySubMasterMap = new Map<ID, ID>();
        activitySubMasterMap.put(saa.Id, sm.Id);
        Boolean isValidPayload=SageApiBuyNowActivityUtils.validatePayload(saa, saaStep, tierList, ptrpList, tokens, pricingChargeMap, accounts, contacts, identities, contactCommunitiesMap, activitySubMasterMap, null);
        Test.stopTest();
        //
        // check success
        system.assert(!isValidPayload);
    }
    /**
     * CreateSubscription method test - successful execution.
     */
    static testMethod void createSubscriptionWithQuoteTest() {
        Locale__c locale = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
        Account acc = TestDataUtility.createAccount(locale.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, null);
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Test.startTest();
        SageApiBuyNowActivityUtils.createSubscription(saaStep, activityList, null);
        Test.stopTest();
        //
        // check for success
        List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c, ZuoraSubscriptionId__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        system.assertEquals(null,saaList[0].ZuoraSubscriptionId__c);
    }

    static testMethod void createSubscriptionWithQuoteFutureCallTest() {
        Locale__c locale = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
        Account acc = TestDataUtility.createAccount(locale.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, 'New Subscription', 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, null);
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Test.startTest();
        SageApiBuyNowActivityUtils.createSubscription(JSON.serialize(saaStep), JSON.serialize(activityList), null);
        Test.stopTest();
        //
        // check for success
        List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c, ZuoraSubscriptionId__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        system.assertEquals(null,saaList[0].ZuoraSubscriptionId__c);
    }

    static testMethod void createSubscriptionNoQuoteFoundFutureCallTest() {
        Locale__c locale = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
        Account acc = TestDataUtility.createAccount(locale.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, 'New Subscription', 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, null);
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        delete zquote;

        Test.startTest();
        SageApiBuyNowActivityUtils.createSubscription(JSON.serialize(saaStep), JSON.serialize(activityList), null);
        Test.stopTest();
        //
        // check for success
        List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c, ZuoraSubscriptionId__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        system.assertEquals(null,saaList[0].ZuoraSubscriptionId__c);
    }

    static testMethod void createSubscriptionNoQuoteTest() {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, null);
        activityList[0].Quote__c = null;
        update activityList;

        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Test.startTest();
        SageApiBuyNowActivityUtils.createSubscription(saaStep, activityList, null);
        Test.stopTest();
        //
        // check for success
        List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c, ZuoraSubscriptionId__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        system.assertEquals(null,saaList[0].ZuoraSubscriptionId__c);
    }

    static testMethod void createSubscriptionWithNullQuoteFutureCallTest() {
        Locale__c locale = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
        Account acc = TestDataUtility.createAccount(locale.Id);
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, 'New Subscription', 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, null);
        activityList[0].Quote__c = null;
        update activityList;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Test.startTest();
        SageApiBuyNowActivityUtils.createSubscription(JSON.serialize(saaStep), JSON.serialize(activityList), null);
        Test.stopTest();
        //
        // check for success
        List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c, ZuoraSubscriptionId__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        system.assertEquals(null,saaList[0].ZuoraSubscriptionId__c);
    }

    /**
     * Test createOrUpdateSubscriptionMaster method - successful execution
     */
    static testMethod void createOrUpdateSubscriptionMasterTest() {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Test.startTest();
        SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster(saaStep, activityList);
        Test.stopTest();
        //
        // check for success
        //List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        //system.assertEquals('Success',steps[0].StepStatus);
        //
        // check subscription master
        List<Subscription_Master__c> subsMasterList=[select id, name, Product__c, Product_Tier__c, Product_Tier_Rate_Plan__c,
                Start_Date__c, End_Date__c, Status__c, Account__c, Quote__c,
                External_Id__c
        from Subscription_Master__c where
        Account__c=:acc.Id
        and Product__c=:prod.Id
        and Product_Tier__c=:tier.Id
        and Product_Tier_Rate_Plan__c=:ratePlanTier.Id];
        system.debug('subsMasterList:'+subsMasterList[0]);
        system.assertEquals('Active', subsMasterList[0].Status__c);
        system.assertNotEquals(null, subsMasterList[0].Start_Date__c);
        system.assertNotEquals(null, subsMasterList[0].End_Date__c);
    }
    static testMethod void createOrUpdateSubscriptionMasterWithExistingTest() {
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
        zqu__Quote__c zquote = TestDataUtility.createZQuote(acc.Id, con.Id, null, 'testElecMethodID', zuoraId);

        TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        TestDataUtility.createInvoiceTemplate(zuoraId);
        TestDataUtility.createHostedPageLiteSetting(zuoraId, 'PayNow-SageOne');
        TestDataUtility.createComunicationProfile(zuoraId);
        TestDataUtility.createZuoraInvoiceMapping();
        //
        Product2 prod = createZProduct('Sage One Start');
        zqu__ProductRatePlan__c ratePlan = createRatePlan(prod.Id, 'Monthly');
        Product_Tier__c tier = createProductTier(prod.Id, 'SageOne Start US', 'SageOne-Start-US2');
        Product_Tier_Rate_Plan__c ratePlanTier = createProductTierRatePlan(tier.Id, ratePlan.Id, 'Monthly');

        List<SageApiActivity__c> activityList=setupQuotesActivities(zquote.Id, acc.Id, 'subsID1234');
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');

        Entitlement_Message__c msg = new Entitlement_Message__c();
        msg.Status__c = 'Processed';
        insert msg;

        Subscription_Master__c sm = new Subscription_Master__c();
        sm.Account__c = acc.Id;
        sm.Product_Tier__c = tier.Id;
        sm.Product_Tier_Rate_Plan__c = ratePlanTier.Id;
        sm.Quote__c = zquote.Id;
        sm.Product__c = prod.Id;
        sm.Start_Date__c = System.now();
        sm.End_Date__c = System.now().addDays( 30 );
        sm.Status__c = 'Trial';
        sm.Entitlement_Id__c = msg.Id;
        insert sm;

        activityList[0].SubscriptionMaster__c = sm.Id;
        activityList[0].Entitlement_Message__c = msg.Id;
        update activityList;

        Test.startTest();
        SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster(saaStep, activityList);
        Test.stopTest();
        //
        // check for success
        //List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c from SageApiActivity__c];
        //List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(saaList[0].ActivitySteps__c, List<SageApiActivityStep>.class);
        //system.assertEquals('Success',steps[0].StepStatus);
        //
        // check subscription master
        List<Subscription_Master__c> subsMasterList=[select id, name, Product__c, Product_Tier__c, Product_Tier_Rate_Plan__c,
                Start_Date__c, End_Date__c, Status__c, Account__c, Quote__c,
                External_Id__c
        from Subscription_Master__c where
        Account__c=:acc.Id
        and Product__c=:prod.Id
        and Product_Tier__c=:tier.Id
        and Product_Tier_Rate_Plan__c=:ratePlanTier.Id];
        system.debug('subsMasterList:'+subsMasterList[0]);
        system.assertEquals('Trial', subsMasterList[0].Status__c);
        system.assertNotEquals(null, subsMasterList[0].Start_Date__c);
        system.assertNotEquals(null, subsMasterList[0].End_Date__c);
    }
    /**
     * Test createOrUpdateSubscriptionMaster method - failure
     */
    static testMethod void createOrUpdateSubscriptionMaster_Fail() {
        List<SageApiActivity__c> activityList = new List<SageApiActivity__c>();

        Date d = date.today();
        String dt = DateTime.newInstance(d.year(),d.month(),d.day()).format('yyyy-MM-dd');
        Date nd = d.addDays(30);
        String ndt = DateTime.newInstance(nd.year(),nd.month(),nd.day()).format('yyyy-MM-dd');
        string guid = GenericUtilities.getRandomUUIDv4();
        string random = string.valueOf(Math.abs(GenericUtilities.getRandom()));
        string paymentMethodId = '2c92c0f856a281e50156a99a87e8793f';
        string payload = ' "contact": {"identityType": "SageID","identityId": "13139943-14d7-445e-82cf-57e84bf779e0","leadId": null,"firstName": "'+random+'","lastName": "'+random+'","email": "'+random+'@example.com","phone": null,"address1": null,"address2": null,"city": null,"county": null,"postalCode": "30332","state": "GA","countryCode": "US"},"account": {"paymentMethodId": "'+paymentMethodId+'","paymentMethodType": "Credit Card","name": "Business '+random+'","phone": "+440879213456","address1": "71136 The Street","address2": "The Village","city": "The City","state": "GA","countryCode": "US","postalCode": "30332","currencyCode": null},"products": [{"tierCode": "SageOne-Start-US","tierRatePlanCode": "Monthly"}],"completionNotifyUrl": null,"version": null}';
        SageApiActivity__c activity = createSageApiActivity(1, dt, ndt, payload);
        activity.Artifacts__c = '{"status":"Success","errors":null,"activityId":"BuyNow:976aff0e-3a66-42e1-8bb4-ccb3eb8318f6","data":{"userId":"005260000015iFPAAY","quoteId":"a1426000000dW1NAAU","paymentUrl":null,"opportunityId":"00626000004FqdLAAS","leadId":"00Q26000002F1OmEAK","contactId":"0032600000E1bezAAB","communityMembershipId":"a1v26000000KuM7AAK","bridgeServiceId":"a1w260000005LtNAAU","assetId":"a2A260000004md7EAA","accountId":"0012600000GZTsvAAH"}}';
        activityList.add(activity);
        insert activityList;
        SageApiActivityStep saaStep=new SageApiActivityStep(1, 'stepNameTest');
        //
        boolean failTest=false;
        Test.startTest();
        try {
            SageApiTryNowActivityUtils.createOrUpdateSubscriptionMaster(saaStep, activityList);
            activityList = SageApiActivityUtils.refreshActivities(activityList);
            activity = activityList[0];
            SageApiActivityUtils.debug(activity.ActivitySteps__c);
            failTest = activity.ActivitySteps__c.contains(SageApiStatus.ManualInterventionRequired);
        }catch (Exception e) {
            failTest=true;
        }
        Test.stopTest();
        //
        // check for failure
        system.assert(failTest);
        //List<SageApiActivity__c> saaList=[select id, name, Artifacts__c, ActivitySteps__c from SageApiActivity__c];
        //system.debug('subs master fail saaList:'+saaList);
    }
    /**
     * Test updateArtifactWithErrorString method
     */
    static testMethod void updateArtifactsTest() {
        SageApiActivity__c saa=new SageApiActivity__c(ActivityID__c='act000',ActivityType__c='BuyNow', Artifacts__c=null);
        SageApiActivityStep step = new SageApiActivityStep(1, 'Step1');
        SageApiActivityUtils.setSuccess(saa, step);
        system.debug('Artifacts saa:'+saa);
        String artifacts=saa.Artifacts__c;
        system.assert(artifacts.contains('act000'));
    }
    /**
     * --- Helper methods ---
     *
     * Create SageAPIActivity record.
     */
    private static SageApiActivity__c createSageApiActivity(Integer idx, String startDate, String endDate, String payload) {
        if(payload!=null) {
            payload='{"startDate": "'+startDate+'","endDate":"'+endDate+'", '+payload;
        }
        SageApiActivity__c saa=new SageApiActivity__c(ActivityID__c='act000'+idx,ActivityType__c='BuyNow', Payload__c=payload);
        return saa;
    }
    /**
     * Create Quotes and Activities. Including supporting object records (account, contact opportunity)
     */
    public static List<SageApiActivity__c> setupQuotesActivities(Id quoteId, Id accId, String subsId) {
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        SageApiActivity__c saa=createValidActivity(1);
        SageApiBuyNowActivityResponse resp = new SageApiBuyNowActivityResponse();
        resp.data = new SageApiBuyNowActivityResponse.ResponseData();
        resp.data.quoteId = quoteId;
        resp.data.subscriptionId=subsId;
        resp.data.accountId=accId;
        resp.data.assetId=null;
        saa.Artifacts__c = JSON.serialize( resp );
        saa.Account__c = accId;
        saa.ZuoraSubscriptionId__c = subsId;
        saa.Quote__c = quoteId;

        system.debug('test artifacts:'+saa.Artifacts__c);
        activities.add( saa );

        insert activities;
        return activities;
    }

    /**
     * Create valid SageAPIActivity record.
     */
    private static SageApiActivity__c createValidActivity(Integer idx) {
        String startDate=todaysDate.format('yyyy-MM-dd');
        String endDate=todaysDate.addDays(30).format('yyyy-MM-dd');
        return createSageApiActivity(idx, startDate, endDate, ' "contact": '+
                '{    "identityType": "SageID",    '+
                '"identityId": "eca310e3-2baf-461c-aa38-cb310bdfb8ce",    '+
                '"leadId": null,    "firstName": "Tom",    "lastName": "Jones",    '+
                '"email": "someone@sage.com",    "phone": null,    '+
                '"address1": null,    "address2": null,    "city": null,    '+
                '"county": null,    "postalCode": null,    "state": null,    '+
                '"countryCode": null  },  "account": {    "name": "Business User",    '+
                '"phone": "14704474146",    "address1": "25 The Street",    '+
                '"address2": "The Village",    "city": "The City",    "state": "GA",   '+
                ' "countryCode": "US",    "postalCode": "30318",    '+
                '"paymentMethodId": "36bfb750-5e3b-4b78-b919-a7fc8983d19f",    '+
                '"paymentMethodType": "Credit Card",    "currencyCode": null  },  '+
                '"products": [{ "tierCode": "SageOne-Start-US2", "tierRatePlanCode": "Monthly" } ],'+
                '"payNowToken": "token",'+
                ' "completionNotifyUrl": null,  "version": null}');
    }
    /**
     * Creates a product tier
     * @author Salesforce Services
     * @param name of the tier to create
     * @return tier record created
    **/
    public static Product_Tier__c createProductTier(Id zProductId, String name, String code) {
        Product_Tier__c tier = new Product_Tier__c();
        tier.Name = name;
        tier.Product_Tier_Code__c = code;
        tier.Product__c = zProductId;
        tier.Product_Use_Region__c = 'US - United States';
        tier.PayNow_PageType__c = 'SageOne';
        insert tier;
        return tier;
    }
    /**
     * Creates a product tier rate plan
     * @author Salesforce Services
     * @param tierId of the tier to associate this rate plan to
     * @param name of the tier to create
     * @return tier rate plan record created
    **/
    public static Product_Tier_Rate_Plan__c createProductTierRatePlan(Id tierId, Id ratePlanId, String name) {
        Locale__c loc = [SELECT Id, Name FROM Locale__c WHERE Name='en_US' LIMIT 1];
        Product_Tier_Rate_Plan__c ratePlanTier = new Product_Tier_Rate_Plan__c();
        ratePlanTier.Name = name;
        ratePlanTier.Start_Date__c = System.today();
        ratePlanTier.End_Date__c = System.today().addDays(100);
        ratePlanTier.Product_Rate_Plan__c = ratePlanId;
        ratePlanTier.Product_Tier__c = tierId;
        ratePlanTier.Locale__c=loc.Id;
        insert ratePlanTier;
        return ratePlanTier;
    }
    /**
     * Creates a Z Product
     * @author Salesforce Services
     * @param name of the ZProduct to create
     * @return ZProduct record created
    **/
    public static Product2 createZProduct(String name) {
        Product2 p = new Product2();
        p.Name = name;
        p.zqu__SKU__c = name;
        p.zqu__ZuoraId__c = name;
        insert p;
        return p;
    }
    /**
     * Creates a Z Product
     * @author Salesforce Services
     * @param name of the ZProduct to create
     * @return ZProduct record created
    **/
    public static zqu__ProductRatePlan__c createRatePlan(Id zProductId, String name) {
        zqu__ProductRatePlan__c rp = new zqu__ProductRatePlan__c();
        rp.Name = name;
        rp.zqu__Product__c = zProductId;
        rp.zqu__ZuoraId__c = name;
        insert rp;
        return rp;
    }

    static testmethod void testGetPayNowTokenBadPayload() {
        //
        // setup valid activity
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);
        activity.Payload__c = '{';
        activity.PayNowToken__c = t.Id;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};
        insert activities;

        //
        // execute the test
        Test.startTest();
        List<PayNowToken__c> tokens = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
/*
        Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = SageApiBuyNowActivityUtils.getPayNowTokens(activities);
        List<PayNowToken__c> tokens = (tokenActivityMap == null ? null : new List<PayNowToken__c>(tokenActivityMap.keySet()));
*/
        Test.stopTest();
        //
        // check success
        system.assert(tokens == null);
    }

    @IsTest static void testGetZuoraSubscriptionsNull()
    {
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();

        Map<ID, ID> subIdMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

        Test.stopTest();

        System.assert( subIdMap == null );
    }

    @IsTest static void testGetZuoraSubscriptionsNotNull()
    {
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__Zuora_Id__c = 'mysub');
        insert sub;

        SageApiBuyNowActivityRequest req = new SageApiBuyNowActivityRequest();
        req.zuoraSubscriptionId = sub.Zuora__Zuora_Id__c;
        activity.ZuoraSubscriptionId__c = sub.Zuora__Zuora_Id__c;
        activity.Payload__c = JSON.serialize(req);
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();

        Map<ID, ID> subIdMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

        Test.stopTest();

        System.assert( subIdMap != null );
    }

    @IsTest static void testGetZuoraSubscriptionsSavedActivityNotNull()
    {
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);

        Zuora__Subscription__c sub = new Zuora__Subscription__c(Zuora__Zuora_Id__c = 'mysub');
        insert sub;

        SageApiBuyNowActivityRequest req = new SageApiBuyNowActivityRequest();
        req.zuoraSubscriptionId = sub.Zuora__Zuora_Id__c;
        activity.ZuoraSubscriptionId__c = sub.Zuora__Zuora_Id__c;
        activity.Payload__c = JSON.serialize(req);
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();

        Map<ID, ID> subIdMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

        Test.stopTest();

        System.assert( subIdMap != null );
    }

    @IsTest static void testGetZuoraSubscriptionsBadPayloadNull()
    {
        PayNowToken__c t = new PayNowToken__c(Name='token', PaymentMethodId__c='PaymentMethodId', PaymentMethodType__c='Credit Card', Products__c='[{"tierCode":"SageOne-Start-US","pricingCode":"_LIST","tierRatePlanCodes":[{"tierRatePlanCode":"Monthly"}]}]');
        insert t;
        SageApiActivity__c activity=createValidActivity(1);
        activity.Payload__c = '{';
        insert activity;
        List<SageApiActivity__c> activities = new List<SageApiActivity__c> { activity };

        Test.startTest();

        Map<ID, ID> subIdMap = SageApiBuyNowActivityUtils.getZuoraSubscriptions(activities);

        Test.stopTest();

        System.assert( subIdMap == null );
    }

}