@isTest
public class SPPMQEventRestTest {

  static {
    // setup test data 
      List<MQ_Event__c> events = new List<MQ_Event__c>{
          							new MQ_Event__c(Name = 'Test1', EventDate__c = System.now(),EventSource__c = 'Global-SFDC',
                                                    EventId__c='8202ce6c-6be9-4ed7-b431-4efd24d41113',RecordType__c ='Account', 
                                                    MessageType__c='Record', Region__c ='UKI'),
          							new MQ_Event__c(Name='Test2', EventDate__c = System.now(),EventSource__c = 'Global-SFDC',
                                                 	EventId__c='8202ce6c-6be9-4ed7-b431-4efd24d41125',RecordType__c ='Account',
                                                 	MessageType__c='Record', Region__c = 'UKI')}; 
      insert events;
      
  }

  static testMethod void testDoGet() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
       
	String reqJSON = '[{"eventId" : "8202ce6c-6be9-4ed7-b431-4efd24d41113","messageType" : "record","region" : "UKI"},'+
        '{"eventId" : "8202ce6c-6be9-4ed7-b431-4efd24d41125","messageType" : "record","region" : "EUR"},'+
        '{"eventId" : "8202ce6c-6be9-4ed7-b431-4efd24d41127","messageType" : "record","region" : "UKI"}]';
    req.requestURI = '/services/apexrest/v.9/messages/find';  
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(reqJSON);
    RestContext.request = req;
    RestContext.response = res;
    SPPMQEventRest.findMessage();
    System.debug('RestContext.response>> '+RestContext.response);
    System.assertNotEquals(null, RestContext.response);
  }
    static testMethod void testDoPost() {

    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
	String reqJSON = '[{"eventId" : "0311dc4f-d764-45fd-888a-33ff54fefafb","messageType" : "record","eventSource" : "Global-SFDC",'+
        '"region" : "UKI","eventDate" : "2017-08-09T19:45:26.000Z","recordType" : "Account"},'+
        '{"eventId" : "0311dc4f-d764-45fd-888a-33ff54fefakr","messageType" : "record","eventSource" : "Global-SFDC","region" : "UKI",'+
        '"eventDate" : "2017-08-09T19:45:26.000Z","recordType" : "Account"}]';
    req.requestURI = '/services/apexrest/v.9/messages/find';  
    req.httpMethod = 'PUT';
    req.requestBody = Blob.valueOf(reqJSON);
    RestContext.request = req;
    RestContext.response = res;
    SPPMQEventRest.insertMessageData();
    System.debug('RestContext.response>> '+RestContext.response);
    System.assertNotEquals(null, RestContext.response);
  }

}