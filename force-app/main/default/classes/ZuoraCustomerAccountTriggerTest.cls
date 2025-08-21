/**
 * @description Tests for associated class.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest
private class ZuoraCustomerAccountTriggerTest
{
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
    }

    @IsTest(SeeAllData=false) static void testUnblockEntitlements()
    {
        setup();
    
        EntitlementEngineTest.setup( true );
        for( Subscription_Master__c subsMaster : EntitlementEngineTest.subsMasters )
        {
            subsMaster.Is_Blocked__c = true;
        }
        update EntitlementEngineTest.subsMasters;
    
        Test.startTest();
        
            EntitlementEngineTest.billingAcc.ElectronicPaymentMethodId__c = 'somethingelse';
            update EntitlementEngineTest.billingAcc;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            System.assertEquals( false, subsMaster.Is_Blocked__c );
        }
    }
}