@isTest
public class ConsumeMuleMessagesQueueableTest {
    public static testmethod void testConsume1(){
             Account acc = new Account(Name='TestAccount',Sales_Office__c='Atlanta CBC',Type='Analyst',CurrencyIsoCode='USD',Phone='1234567899');
    insert acc;
    Contact cont = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Last_Survey_Date__c = system.now().adddays(-40));
    insert cont;
      DateTime lastSurveyDate = system.now().adddays(-30);
        
        Contact cont1 = [select id,Last_Survey_Date__c from Contact where id=: cont.id];
        system.debug(cont1);
   Case c = new Case(Type='Problem', ContactId=cont.id,Case_Category__c = 'Integration',Customer_Lifecycle_Stage__c ='Trial', Subject='test',Status = 'Closed',Priority = 'High',
                    Origin = 'Chat',Event_Id__c='test');
    insert c;
        
        Test.startTest();
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())// Checking the limit for Queueable 
          {
           System.enqueueJob(new ConsumeMuleMesssagesQueueable('Survey'));
          } 
       // Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPContactMockTest());
      //  ConsumeMuleMesssagesHelper consumeMsgs = new ConsumeMuleMesssagesHelper('Survey');
      //  Database.executeBatch(consumeMsgs);
        Test.StopTest();
    }
     public static testmethod void testConsume2(){
             Account acc = new Account(Name='TestAccount',Sales_Office__c='Atlanta CBC',Type='Analyst',CurrencyIsoCode='USD',Phone='1234567899');
    insert acc;
    Contact cont = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Last_Survey_Date__c = system.now().adddays(-40));
    insert cont;
      DateTime lastSurveyDate = system.now().adddays(-30);
        
        Contact cont1 = [select id,Last_Survey_Date__c from Contact where id=: cont.id];
        system.debug(cont1);
   Case c = new Case(Type='Problem', ContactId=cont.id,Case_Category__c = 'Integration',Customer_Lifecycle_Stage__c ='Trial', Subject='test',Status = 'Closed',Priority = 'High',
                    Origin = 'Chat',Event_Id__c='test');
    insert c;
        
        Test.startTest();
       // Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPContactMockTest());
        if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs())// Checking the limit for Queueable 
          {
           System.enqueueJob(new ConsumeMuleMesssagesQueueable('Survey'));
          } 
        Test.StopTest();
    }
}