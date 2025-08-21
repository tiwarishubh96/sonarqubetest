@IsTest(SeeAllData=false)
public class SageApiActivityAjaxControllerTest {
    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupProductCatalog();
    }

    @IsTest static void testResumeActivityResumed()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.resumeActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Resumed, text );
    }

    @IsTest static void testResumeActivityRestarted()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivityStatus__c = SageApiStatus.Restarting;
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.resumeActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Resumed, text );
    }

    @IsTest static void testResumeActivityRestartedLocked()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        activity.ActivityStatus__c = SageApiStatus.Restarting;
        activity.LockedForProcess__c = SageApiProcessLocks.Restarting;
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.resumeActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Being_Restarted, text );
    }

    @IsTest static void testResumeActivityRequired()
    {
        Test.startTest();

            String text = SageApiActivityAjaxController.resumeActivity(null);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_ActivityID_Required, text );
    }

    @IsTest static void testAbandonActivityRequired()
    {
        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(null);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_ActivityID_Required, text );
    }

    @IsTest static void testAbandonActivityInvalidId()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.LeadActivityType, null);
        SageApiTryNowLeadActivityResponse res = new SageApiTryNowLeadActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity('01I24000001ZrpH');

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_ActivityID_Invalid, text );
    }

    @IsTest static void testAbandonActivityTryNowLeadAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.LeadActivityType, null);
        SageApiTryNowLeadActivityResponse res = new SageApiTryNowLeadActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testAbandonActivityTryNowAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowActivityType, null);
        SageApiTryNowActivityResponse res = new SageApiTryNowActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testAbandonActivityCreateSubscriptionAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.CreateSubscriptionActivityType, null);
        SageApiSubscriptionActivityResponse res = new SageApiSubscriptionActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;

        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testAbandonActivityBuyNowAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.BuyNowActivityType, null);
        SageApiBuyNowActivityResponse res = new SageApiBuyNowActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;
    
        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testAbandonActivityTryNowConvertAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.TryNowConvertActivityType, null);
        SageApiBuyNowActivityResponse res = new SageApiBuyNowActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;
    
        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testAbandonActivityAddCommUserAbandoned()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity(SageApiActivityTriggerHandler.AddCommunityUserType, null);
        SageApiAddCommUserActivityResponse res = new SageApiAddCommUserActivityResponse();
        res.status = SageApiStatus.InProgress;
        activity.Artifacts__c = JSON.serialize(res);
        insert activity;
    
        Test.startTest();

            String text = SageApiActivityAjaxController.abandonActivity(activity.Id);

        Test.stopTest();

        System.assertEquals( Label.ApiActivity_Activity_Abandoned, text );
    }

    @IsTest static void testSyncPricingCodeWithAzurePricingCodeRequired()
    {
        Test.startTest();

            String text = SageApiActivityAjaxController.syncPricingCodeWithAzure(null);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_IdRequired,  text);
    }

    @IsTest static void testSyncPricingCodeWithAzurePricingCodeNotValid()
    {
        Test.startTest();

            String text = SageApiActivityAjaxController.syncPricingCodeWithAzure('InvalidId');

        Test.stopTest();

        System.assertEquals( Label.PricingCode_NotValid, text );
    }

    @IsTest static void testSyncPricingCodeWithAzurePricingCodeChargeNotConfigured()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];
        pricingCode.Name = 'NOT_CONFIGURED';
        update pricingCode;
        PricingCodeCharge__c charges = [SELECT Id FROM PricingCodeCharge__c];
        delete charges;

        Test.startTest();

            String text = SageApiActivityAjaxController.syncPricingCodeWithAzure(pricingCode.Id);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_NotConfigured, text );
    }

    @IsTest static void testSyncPricingCodeWithAzurePricingCodeNotModified()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];
        pricingCode.SyncStatus__c = 'publish requested';
        update pricingCode;
 
        Test.startTest();

            String text = SageApiActivityAjaxController.syncPricingCodeWithAzure(pricingCode.Id);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_NotModified, text );
    }

    @IsTest static void testSyncPricingCodeWithAzurePricingCodePublishRequested()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];
        pricingCode.SyncStatus__c = 'is modified';
        update pricingCode;
 
        Test.startTest();

            String text = SageApiActivityAjaxController.syncPricingCodeWithAzure(pricingCode.Id);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_PublishRequested, text );
    }

    @IsTest static void testCreatePaymentUrlTierCodeRequired()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

            String text = SageApiActivityAjaxController.createPaymentUrl(pricingCode.Id, null, 'tierRatePlanCode');

        Test.stopTest();

        System.assertEquals( Label.PricingCode_TierCodeRequired, text );
    }

    @IsTest static void testCreatePaymentUrlTierRatePlanCodeRequired()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

            String text = SageApiActivityAjaxController.createPaymentUrl(pricingCode.Id, 'tierCode', null);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_TierRatePlanCodeRequired, text );
    }

    @IsTest static void testCreatePaymentUrlPricingCodeRequired()
    {
        Test.startTest();

        	String msg = SageApiActivityAjaxController.createPaymentUrl('pricingCodeId', 'SageOne-Start-US', 'Monthly');
        	System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_NotExist) );
    }

    @IsTest static void testCreatePaymentUrlCreated()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

            String text = SageApiActivityAjaxController.createPaymentUrl(pricingCode.Id, 'SageOne-Start-US', 'Monthly');

        Test.stopTest();

        System.assertEquals( Label.PricingCode_PaymentUrlCreated, text );
    }

    @IsTest static void testCreatePricingCodeChargePricingCodeRequired()
    {
        Test.startTest();

            String text = SageApiActivityAjaxController.createPricingCodeCharge(null);

        Test.stopTest();

        System.assertEquals( Label.PricingCode_IdRequired, text );
    }

    @IsTest static void testCreatePricingCodeChargePricingCodeNotExist()
    {
        Test.startTest();

        	String msg = SageApiActivityAjaxController.createPricingCodeCharge('WrongPricingCodeId');
        	System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_NotExist) );
    }

    @IsTest static void testCreatePricingCodeChargePricingCodeChargesExist()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

        	String msg = SageApiActivityAjaxController.createPricingCodeCharge(pricingCode.Id);
        	System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_ChargesExist) );
    }

    @IsTest static void testCreatePricingCodeChargeZuoraRatePlanNotExist()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];
        PricingCodeCharge__c codeCharges = [SELECT Id FROM PricingCodeCharge__c];
        delete codeCharges;
        zqu__ProductRatePlanCharge__c planCharges = [SELECT Id FROM zqu__ProductRatePlanCharge__c];
        delete planCharges;

        Test.startTest();

        	String msg = SageApiActivityAjaxController.createPricingCodeCharge(pricingCode.Id);
        	System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_ZuoraRatePlanChargesNotExist) );
    }

    @IsTest static void testCreatePricingCodeChargeCreated()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];
        PricingCodeCharge__c codeCharges = [SELECT Id FROM PricingCodeCharge__c];
        delete codeCharges;

        Test.startTest();

        	String msg = SageApiActivityAjaxController.createPricingCodeCharge(pricingCode.Id);
        	System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_ChargesCreated) );
    }

    @IsTest static void testProductTierRatePlanCreated()
    {
        Product_Tier__c tier = [SELECT Id FROM Product_Tier__c LIMIT 1];
        PricingCode__c pricingCode = [SELECT Id, Product_Tier__c FROM PricingCode__c WHERE Product_Tier__c =: tier.Id LIMIT 1];
        List<PricingCodeCharge__c> existingCharges = [SELECT Id FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCode.Id];
        List<Product_Tier_Rate_Plan__c> existingPlans = [SELECT Id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: pricingCode.Product_Tier__c];
        if (existingCharges != null) delete existingCharges;
        if (existingPlans != null) delete existingPlans;

        Test.startTest();

            String msg = SageApiActivityAjaxController.createProductTierRatePlan(tier.Id);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.ProductTier_RatePlanCreated) );
    }

    @IsTest static void testProductTierRatePlanTierIdNotProvided()
    {
        Test.startTest();

            String msg = SageApiActivityAjaxController.createProductTierRatePlan(null);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.ProductTier_IdRequired) );
    }

    @IsTest static void testProductTierRatePlanProvidedTierNotExists()
    {
        Product_Tier__c tier = [SELECT Id FROM Product_Tier__c LIMIT 1];
        PricingCode__c pricingCode = [SELECT Id, Product_Tier__c FROM PricingCode__c WHERE Product_Tier__c =: tier.Id LIMIT 1];
        List<PricingCodeCharge__c> existingCharges = [SELECT Id FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCode.Id];
        List<Product_Tier_Rate_Plan__c> existingPlans = [SELECT Id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: pricingCode.Product_Tier__c];
        if (existingCharges != null) delete existingCharges;
        if (existingPlans != null) delete existingPlans;

        Test.startTest();

            // wrong id
            String msg = SageApiActivityAjaxController.createProductTierRatePlan(pricingCode.Id);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.ProductTier_TierNotExist) );
    }

    @IsTest static void testProductTierRatePlanProvidedTierRatePlansExist()
    {
        Product_Tier__c tier = [SELECT Id FROM Product_Tier__c LIMIT 1];

        Test.startTest();

            // wrong id
            String msg = SageApiActivityAjaxController.createProductTierRatePlan(tier.Id);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.ProductTier_TierRatePlansExist) );
    }

    @IsTest static void testProductTierProductRatePlanNotExist()
    {
        Product_Tier__c tier = [SELECT Id, Product__c FROM Product_Tier__c LIMIT 1];
        PricingCode__c pricingCode = [SELECT Id, Product_Tier__c FROM PricingCode__c WHERE Product_Tier__c =: tier.Id LIMIT 1];
        List<PricingCodeCharge__c> existingCharges = [SELECT Id FROM PricingCodeCharge__c WHERE Pricing_Code__c =: pricingCode.Id];
        List<Product_Tier_Rate_Plan__c> existingPlans = [SELECT Id FROM Product_Tier_Rate_Plan__c WHERE Product_Tier__c =: pricingCode.Product_Tier__c];
        List<zqu__ProductRatePlan__c> productRatePlans = [SELECT Id FROM zqu__ProductRatePlan__c WHERE zqu__Product__c =: tier.Product__c];
        if (existingCharges != null) delete existingCharges;
        if (existingPlans != null) delete existingPlans;
        if (productRatePlans != null) delete productRatePlans;

        Test.startTest();

            String msg = SageApiActivityAjaxController.createProductTierRatePlan(tier.Id);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.ProductTier_NoProductRatePlans) );
    }

    @IsTest static void testDeletePricingCodeDeleted()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

            String msg = SageApiActivityAjaxController.deletePricingCode(pricingCode.Id);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_Deleted) );
    }

    @IsTest static void testDeletePricingCodeIdRequired()
    {
        Test.startTest();

            String msg = SageApiActivityAjaxController.deletePricingCode(null);
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_IdRequired) );
    }

    @IsTest static void testDeletePricingCodeIdNotValid()
    {
        PricingCode__c pricingCode = [SELECT Id FROM PricingCode__c LIMIT 1];

        Test.startTest();

            String msg = SageApiActivityAjaxController.deletePricingCode('01I24000001ZrpH');
            System.debug(msg);

        Test.stopTest();

        System.assert( msg.contains(Label.PricingCode_NotValid) );
    }
}