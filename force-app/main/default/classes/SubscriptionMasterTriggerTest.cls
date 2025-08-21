/**
 * @description Tests for Subscription Master Trigger.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest(SeeAllData=false)
private class SubscriptionMasterTriggerTest
{
    @testSetup static void setupTestRecords() {
        setup();
    }

    static void setup()
    {
        Application_Control__c set1 = Application_Control__c.getOrgDefaults();
        set1.Run_Triggers__c = true;
        set1.Run_Validation_Rules__c = false;
        try { upsert set1; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }

        CBC_Application_Control__c set2 = CBC_Application_Control__c.getOrgDefaults();
        set2.Run_Triggers__c = true;
        set2.Run_Validation_Rules__c = false;
        try { upsert set2; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }

        SageApiTestUtils.setup();
    }

    @IsTest static void testCreateEntitlementsInInsert()
    {
        EntitlementEngineTest.setup( false );

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 2; i++)
        {
            Subscription_Master__c subsMaster = EntitlementEngineTest.createSubsMaster();
            subsMaster.Status__c = i < 1 ? SubscriptionMasterTriggerHandler.SUBSCRIPTION_MASTER_STATUS_TRIAL : SubscriptionMasterTriggerHandler.SUBSCRIPTION_MASTER_STATUS_BUYNOW;
            subsMasters.add( subsMaster );
        }
    
        Test.startTest();
        
            insert subsMasters;
    
        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testCreateEntitlementsInUpdate()
    {
        EntitlementEngineTest.setup( false );

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Status__c = SubscriptionMasterTriggerHandler.SUBSCRIPTION_MASTER_STATUS_BUYNOW;
        }
    
        Test.startTest();
        
            update EntitlementEngineTest.subsMasters;
    
        Test.stopTest();

        System.assertEquals( 2, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :EntitlementEngineTest.subsMasters] );
    }

    @IsTest static void testCancelEntitlements()
    {
        EntitlementEngineTest.setup( true );

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Submit_For_Cancellation__c = true;
        }
    
        Test.startTest();
        
            update EntitlementEngineTest.subsMasters;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            System.assertEquals( false, subsMaster.Submit_For_Cancellation__c );
            System.assertEquals( true, subsMaster.Is_Cancelled__c );
        }
    }

    @IsTest static void testUpgradeEntitlements()
    {
        EntitlementEngineTest.setup( true );

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Submit_For_Upgrade__c = true;
        }
    
        Test.startTest();
        
            update EntitlementEngineTest.subsMasters;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            ////quick fix for marketplace production deployment
            ////System.AssertException: Assertion Failed: Expected: false, Actual: true 
            ////Stack Trace: Class.SubscriptionMasterTriggerTest.testUpgradeEntitlements: line 112, column 1            
            System.assertEquals( false, subsMaster.Submit_For_Upgrade__c );
            System.assertEquals( true, subsMaster.Is_Upgraded__c );
            //System.assert(1 == 1);
        }
    }

    @IsTest static void testTryNowUpgradeEntitlements()
    {
        EntitlementEngineTest.setup( true );

        List<PayNowToken__c> tokens = new List<PayNowToken__c>();
        Integer i = 0;
        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            if (i > 0) break;
            PayNowToken__c token = new PayNowToken__c(name='Test');
            tokens.add(token);
            i++;
        }
        insert tokens;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        i = 0;
        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            if (i > 0) break;
            SageApiActivity__c activity = new SageApiActivity__c(Name='Test '+i, ActivityType__c=SageApiActivityTriggerHandler.TryNowActivityType, ActivityID__c='Test '+i, PayNowToken__c = tokens[i].Id);
            activities.add(activity);
            i++;
        }
        insert activities;

        i = 0;
        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            if (i > 0) break;
            subsMaster.Sage_API_Activity__c = activities[i].Id;
            i++;
        }
        update EntitlementEngineTest.subsMasters;
        i = 0;
        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            if (i > 0) break;
            subsMaster.Submit_For_Upgrade__c = true;
            i++;
        }
    
        Test.startTest();
        
            update EntitlementEngineTest.subsMasters;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            if (i > 0) break;
            System.assertEquals( false, subsMaster.Submit_For_Upgrade__c );
            System.assertEquals( true, subsMaster.Is_Upgraded__c );
        }
    }

    @IsTest static void testConvertEntitlements()
    {
        EntitlementEngineTest.setup( true );

        List<Subscription_Master__c> subsMasters = new List<Subscription_Master__c>();
        for( Integer i = 0; i < 2; i++)
        {
            Subscription_Master__c subsMaster = EntitlementEngineTest.createSubsMaster();
            subsMaster.Status__c = SubscriptionMasterTriggerHandler.SUBSCRIPTION_MASTER_STATUS_TRIAL;
            subsMasters.add( subsMaster );
        }
        insert subsMasters;

        for( Subscription_Master__c subsMaster : subsMasters )
        {
            subsMaster.Status__c = SubscriptionMasterTriggerHandler.SUBSCRIPTION_MASTER_STATUS_BUYNOW;
        }
    
        Test.startTest();

            update subsMasters;
    
        Test.stopTest();

        System.assertEquals( 6, [SELECT Count() FROM Entitlement_Message__c WHERE Subscription_Master__c IN :subsMasters] );
    }

    @IsTest static void testReactivateEntitlements()
    {
        EntitlementEngineTest.setup( true );

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Is_Cancelled__c = true;
        }
        update EntitlementEngineTest.subsMasters;

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Submit_For_Reactivation__c = true;
        }
    
        Test.startTest();
        
            update EntitlementEngineTest.subsMasters;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            System.assertEquals( false, subsMaster.Submit_For_Reactivation__c );
            System.assertEquals( false, subsMaster.Is_Cancelled__c );
        }
    }

    @IsTest static void testReactivateEntitlementsError()
    {
        EntitlementEngineTest.setup( true );

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Is_Cancelled__c = false;
        }
        update EntitlementEngineTest.subsMasters;

        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Submit_For_Reactivation__c = true;
        }
    
        Test.startTest();
        
            try {
                update EntitlementEngineTest.subsMasters;
            }
            catch( Exception ex )
            {
                TestExc.isExcThrown = true;
            }
    
        Test.stopTest();

        System.assertEquals( true, TestExc.isExcThrown );
    }


}