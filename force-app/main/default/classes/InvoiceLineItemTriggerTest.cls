/**
 * @description Tests for Invoice_Line_Item__c Trigger.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest
private class InvoiceLineItemTriggerTest
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

    @IsTest(SeeAllData=false) static void testBlockedEntitlements()
    {
        setup();
    
        EntitlementEngineTest.setup( true );

        Test.startTest();
        
            Invoice_Line_Item__c item = new Invoice_Line_Item__c( 
                Invoice__c = EntitlementEngineTest.invoice.Id
                , Gateway_Response__c = 'Something went wrong.'
                , Product__c = EntitlementEngineTest.zproduct.Id
                , Zuora_Id__c = 'somezuoraid1234' );
            insert item;
    
        Test.stopTest();

        Map<Id, Subscription_Master__c> mapSubsMasters = new Map<Id, Subscription_Master__c>((List<Subscription_Master__c>)GenericUtilities.resetSObjects( EntitlementEngineTest.subsMasters ));
        for( Subscription_Master__c subsMaster : mapSubsMasters.values() )
        {
            System.assertEquals( true, subsMaster.Is_Blocked__c );
        }
    }
}