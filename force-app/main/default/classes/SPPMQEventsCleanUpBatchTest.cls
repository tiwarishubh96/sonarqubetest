@isTest
public class SPPMQEventsCleanUpBatchTest {
    static testMethod void testMQEventscleanupBatch() {
    // setup test data 
      List<MQ_Event__c> events = new List<MQ_Event__c>{
                                    new MQ_Event__c(Name = 'Test1', EventDate__c = System.now(),EventSource__c = 'Global-SFDC',
                                                    EventId__c='8202ce6c-6be9-4ed7-b431-4efd24d41113',RecordType__c ='Account', 
                                                    MessageType__c='Record', Region__c ='UKI'),
                                    new MQ_Event__c(Name='Test2', EventDate__c = System.now(),EventSource__c = 'Global-SFDC',
                                                    EventId__c='8202ce6c-6be9-4ed7-b431-4efd24d41125',RecordType__c ='Account',
                                                    MessageType__c='Record', Region__c = 'UKI')}; 
        insert events;  
        Test.setCreatedDate(events[0].Id, DateTime.now().addDays(-15));
        Test.setCreatedDate(events[1].Id, DateTime.now().addDays(-18));
        Test.startTest();
        SPPMQEventsCleanUpBatch sppMQEvents = new SPPMQEventsCleanUpBatch();
        Database.executeBatch(sppMQEvents);
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM MQ_Event__c]);
    }
}