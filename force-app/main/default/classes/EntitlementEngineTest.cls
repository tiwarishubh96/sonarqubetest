/**
 * @description Tests EntitlementEngine class.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest(SeeAllData=false)
public with sharing class EntitlementEngineTest
{
    static public Account acc;
    static public Product2 zproduct;
	static public Product_Tier__c tier;
	static public Product_Tier_Rate_Plan__c plan;
    static public List<Subscription_Master__c> subsMasters;
    static public List<Id> subsMasterIds;
    static public Zuora__CustomerAccount__c billingAcc;
    static public Zuora__ZInvoice__c invoice;

    static public void setup( Boolean mockEntitlementId )
    {
        acc = new Account( Name = 'Test Account 1', BillingCity = 'London', BillingCountry = 'United Kingdom', BillingStreet = 'Example Street', Sales_Office__c = 'Atlanta CBC' );
        insert acc;

        billingAcc = new Zuora__CustomerAccount__c( Name = 'Test Biling Acc', Zuora__Account__c = acc.Id );
        insert billingAcc;

        invoice = new Zuora__ZInvoice__c( Name = 'Test Invoice', Zuora__Account__c = acc.Id, Zuora__BillingAccount__c = billingAcc.Id );
        insert invoice;

        Product2 upgradeToZProduct = new Product2( Name = 'Sage One Accounting', zqu__SKU__c = 'skuidhere1', zqu__ZuoraId__c = 'zuoraid1' );
        insert upgradeToZProduct;

        zproduct = new Product2( Name = 'Sage One Starter', Upgrade_To__c = upgradeToZProduct.Id, zqu__SKU__c = 'skuidhere2', zqu__ZuoraId__c = 'zuoraid2' );
        insert zproduct;

        SageApiTestUtils.setupLocale();
        Locale__c loc = [SELECT ID FROM Locale__c LIMIT 1];
        Product_Tier__c tier2 = new Product_Tier__c();
        tier2.Name = 'Sage One Accounting US';
        tier2.Product_Tier_Code__c = 'SageOne-Accounting-US';
        tier2.Product_Use_Region__c = 'US - United States';
        tier2.Product__c = upgradeToZProduct.Id;
        tier2.PayNow_PageType__c = 'SageOne';
        insert tier2;

        Product_Tier_Rate_Plan__c plan2 = new Product_Tier_Rate_Plan__c();
        plan2.Name = 'Monthly';
        plan2.End_Date__c = System.today().addDays( 100 );
        plan2.Start_Date__c = System.today().addYears( -1 );
        plan2.Trial_Period__c = 30;
        plan2.Product_Tier__c = tier2.Id;
        plan2.Payment_Grace_Period__c = 0;
        plan2.CurrencyIsoCode = 'USD';
        plan2.Locale__c = loc.Id;
        insert plan2;

        tier = new Product_Tier__c();
        tier.Name = 'Sage One Start US';
        tier.Product_Tier_Code__c = 'SageOne-Start-US';
        tier.Product_Use_Region__c = 'US - United States';
        tier.Product__c = zproduct.Id;
        tier.PayNow_PageType__c = 'SageOne';
        tier.UpgradeToProductTier__c = tier2.Id;
        insert tier;

        plan = new Product_Tier_Rate_Plan__c();
        plan.Name = 'Monthly';
        plan.End_Date__c = System.today().addDays( 100 );
        plan.Start_Date__c = System.today().addYears( -1 );
        plan.Trial_Period__c = 30;
        plan.Product_Tier__c = tier.Id;
        plan.Payment_Grace_Period__c = 0;
        plan.CurrencyIsoCode = 'USD';
        plan.UpgradeToProductTierRatePlan__c = plan2.Id;
        plan.Locale__c = loc.Id;
        insert plan;

        subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 2; i++)
        {
            Subscription_Master__c subsMaster = createSubsMaster();
            if( mockEntitlementId ) subsMaster.Entitlement_Id__c = 'ent-' + i * 1000;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        subsMasterIds = new List<Id>( new Map<Id, Subscription_Master__c>( subsMasters ).keySet() );
    }

    static public Subscription_Master__c createSubsMaster()
    {
        return new Subscription_Master__c( Account__c = acc.Id, Product__c = zproduct.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(100), Product_Tier__c = tier.Id, Product_Tier_Rate_Plan__c = plan.Id );
    }

    @IsTest static void testCreateEntitlements()
    {
        setup( false );

        Test.startTest();
        
            List<EntitlementEngine.CreateEntitlementRequest> reqs = new List<EntitlementEngine.CreateEntitlementRequest>();
            Boolean isTrial = false;
            for( Subscription_Master__c subsMaster : subsMasters )
            {
                reqs.add( new EntitlementEngine.CreateEntitlementRequest( subsMaster.Id, isTrial) );
                isTrial = !isTrial;
            }

            EntitlementEngine.createEntitlements( reqs );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testCreateEntitlement()
    {
        setup( false );

        Test.startTest();
        
            EntitlementEngine.createEntitlement( subsMasterIds[0], true );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testBlockEntitlements()
    {
        setup( true );
    
        Test.startTest();

            Map<Id, String> mapSubsMasterId_Reason = new Map<Id, String>();
            for( Id subsMasterId : subsMasterIds )
            {
                mapSubsMasterId_Reason.put( subsMasterId, 'No Good Reason' );
            }
        
            EntitlementEngine.blockEntitlements( mapSubsMasterId_Reason );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testBlockEntitlement()
    {
        setup( true );
    
        Test.startTest();

            EntitlementEngine.blockEntitlement( subsMasterIds[0], 'Some Reason' );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testUnblockEntitlements()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.unblockEntitlements( subsMasterIds );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testUnblockEntitlement()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.unblockEntitlement( subsMasterIds[0] );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testCancelEntitlements()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.cancelEntitlements( subsMasterIds );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testCancelEntitlement()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.cancelEntitlement( subsMasterIds[0] );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testUpgradeEntitlements()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.upgradeEntitlements( subsMasterIds );

        Test.stopTest();

        System.assertEquals( 4, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testUpgradeEntitlement()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.upgradeEntitlement( subsMasterIds[0] );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testConvertTrialEntitlements()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.convertTrialEntitlements( subsMasterIds );

        Test.stopTest();

        System.assertEquals( 4, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testConvertTrialEntitlement()
    {
        setup( true );
    
        Test.startTest();
        
            EntitlementEngine.convertTrialEntitlement( subsMasterIds[0] );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testReactivateEntitlements()
    {
        setup( true );

        for( Subscription_Master__c subsMaster : subsMasters )
        {
            subsMaster.Is_Cancelled__c = true;
        }
        update subsMasters;
    
        Test.startTest();
        
            EntitlementEngine.reactivateEntitlements( subsMasterIds );

        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            System.assertEquals( false, subsMaster.Is_Cancelled__c );
        }
    }

    @IsTest static void testReactivateEntitlement()
    {
        setup( true );

        for( Subscription_Master__c subsMaster : subsMasters )
        {
            subsMaster.Is_Cancelled__c = true;
        }
        update subsMasters;
    
        Test.startTest();
        
            EntitlementEngine.reactivateEntitlement( subsMasterIds[0] );

        Test.stopTest();

        System.assertEquals( 1, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            if( subsMaster.Id == subsMasterIds[0] )
            {
                System.assertEquals( false, subsMaster.Is_Cancelled__c );
            }
            else
            {
                System.assertEquals( true, subsMaster.Is_Cancelled__c );
            }
        }
    }
}