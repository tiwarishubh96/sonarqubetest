@IsTest
private class SageApiActivityTriggerTest
{
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
        return SageApiTestUtils.createActivity( 'TryNowLead', JSON.serialize( payload ) );
    }
    
    @IsTest(SeeAllData=false)
    private static void testTryNowLeadViaDML() {
        SageApiTestUtils.setup();
        
        Test.startTest();
    
            SageApiTryNowLeadActivityRequest payload = createPayload();
            SageApiActivity__c activity = createActivity( payload );
            insert activity;
    
        Test.stopTest();
    
        SageApiActivity__c persistedActivity = [SELECT Id, ActivityStatus__c FROM SageApiActivity__c WHERE Id=:activity.Id];
        System.assert( persistedActivity.ActivityStatus__c == SageApiStatus.Unknown || persistedActivity.ActivityStatus__c == SageApiStatus.InProgress || persistedActivity.ActivityStatus__c == SageApiStatus.Success );
    }
}