@isTest
public class EventSurveyHandler_Test {
     
    @TestSetup
    static void makeData() {
        // User
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'nogroup', Email='standardusernogroup@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='nogroup@anywhere.com', FederationIdentifier='nogroup');
        insert u;           
        // Account
        Account acc = new Account(Name='testAccount', Type='Customer', BillingCountry='United Kingdom', 
                                  BillingCity='Blyth', BillingStreet='Salisbury Street');
        
        Account accNoCountry = new Account(Name='testAccNoCountry', Type='Customer', BillingCity='Blyth', BillingStreet='Salisbury Street');
        List<Account> accs = new List<Account>{acc,accNoCountry};
        insert accs;
        
        
        // Contact
        List<Contact> contacts = new List<Contact>();
        Contact con1 = new Contact(FirstName='Roger', LastName='Hunt', Email='roger.hunt@test.com.donotcall', 
                                   AccountId=accs[0].Id, Allow_Experience_Feedback__c='Yes',
                                   Allow_Email__c='Yes', HasOptedOutOfEmail=false, Last_Survey_Date__c=System.now()-30);
        contacts.add(con1);
        Contact optOutcon1 = new Contact(FirstName='Roger', LastName='Hunt', Email='roger.hunt@test.com.donotcall', AccountId=accs[0].Id, 
                                         Allow_Experience_Feedback__c='No', Allow_Email__c='No', HasOptedOutOfEmail=false, Last_Survey_Date__c=System.now()-30);
        contacts.add(optOutcon1);
		Contact con3 = new Contact(FirstName='Nobby', LastName='Stiles', Email='nobby.stiles@test.com.donotcall', 
                                   AccountId=accs[1].Id, Allow_Experience_Feedback__c='Yes',
                                   Allow_Email__c='Yes', HasOptedOutOfEmail=false, MailingCountry='Albania');
        contacts.add(con3);
        insert contacts;        
        // Opportunity
        List<Opportunity> opportunities = new List<Opportunity>();
        Opportunity opp1 = new Opportunity(Name='TestOpp', AccountId=acc.Id, StageName='Qualify', CloseDate=System.today());
        opportunities.add(opp1);
        Opportunity opp2 = new Opportunity(Name='TestOpp2', AccountId=accNoCountry.Id, StageName='Qualify', CloseDate=System.today());
        opportunities.add(opp2);
        insert opportunities;
        // Call Items
        Call_Item__c call1 = new Call_Item__c(Name='testCall1', FederationUserID__c=u.FederationIdentifier, 
                                              Call_List_Type__c='Upsell', Priority__c='P2', Status__c='Working', Account__c=acc.Id);
        insert call1;
        // Leads
        Lead lead1 = new Lead(FirstName='Jeff', LastName='Astle', Email='jeff.astle@westbrom.com.donotcall', Country='Finland', Language__c='English',
                              Company='WBA',Product_Solution__c='Other',Status='Qualified',Lead_Source__c='Marketing');
        insert lead1;
        // Events
        List<Event> events = new List<Event>();
        Event event1 = new Event(WhatId=acc.Id, WhoId=con1.Id, Description='testevent1', Status__c='Not Started', Support_Type__c='Welcome Call',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event1);
        Event event2 = new Event(WhatId=acc.Id, WhoId=optOutcon1.Id, Description='testevent2', Status__c='Completed', Support_Type__c='Demo',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event2);
        Event event3 = new Event(WhatId=opp1.Id, WhoId=con1.Id, Description='testevent3', Status__c='Completed', Support_Type__c='Welcome Call',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event3);
        Event event4 = new Event(WhatId=opp2.Id, WhoId=con3.Id, Description='testevent4', Status__c='Completed', Support_Type__c='Welcome Call',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event4);
        Event event5 = new Event(WhatId=call1.Id, WhoId=con3.Id, Description='testevent5', Status__c='Completed', Support_Type__c='Demo',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event5);
        Event event6 = new Event(WhoId=lead1.Id, Description='testevent6', Status__c='Completed', Support_Type__c='Welcome Call',
                                 DurationInMinutes=1, ActivityDateTime=System.now());
        events.add(event6);
        insert events;
    }

    static Event getTestEvent(List<Event> testData,String description) {
        Event e;
        for(Event event : testData) {
            if (event.Description == description) {
                e = event;
                break;
            }
        }
        return e;
    }

    @isTest
    static void testSolicitSurvey_TypeNotMetRequirement() {
        System.debug('Running Test EventSurveyHandler_Test.testSolicitSurvey_TypeNotMetRequirement');
        Event e1 = getTestEvent([SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event],'testevent1');
        e1.Status__c = 'Completed';
        e1.Support_Type__c = null; // null
        EventSurveyHandler handler = new EventSurveyHandler();
        ISurveyRequest request = handler.solicitSurvey(new List<Event>{e1}, 
                                                       new Map<Id,Event>{e1.Id => new Event(Status__c='Not Started')});
        System.assertEquals(0,request.getRequests().size()); 
    }

    @isTest
    static void testSolicitSurvey_StatusNotMetRequirement() {
        System.debug('Running Test EventSurveyHandler_Test.testSolicitSurvey_StatusNotMetRequirement');
        Event e1 = getTestEvent([SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event],'testevent1');
        EventSurveyHandler handler = new EventSurveyHandler();
        ISurveyRequest request = handler.solicitSurvey(new List<Event>{e1}, 
                                                       new Map<Id,Event>{e1.Id => new Event(Status__c='Completed')});
        System.assertEquals(0,request.getRequests().size()); 
    }    

    @isTest
    static void testSolicitSurvey() {
        System.debug('Running Test EventSurveyHandler_Test.testSolicitSurvey');
        Event e1 = getTestEvent([SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event],'testevent1');
        e1.Status__c = 'Completed';
        EventSurveyHandler handler = new EventSurveyHandler();
        ISurveyRequest request = handler.solicitSurvey(new List<Event>{e1}, 
                                                       new Map<Id,Event>{e1.Id => new Event(Status__c='Not Started')});
        System.assertEquals(1,request.getRequests().size()); 
    }

    @isTest
    static void test_sendRequests() {
        System.debug('Running Test EventSurveyHandler_Test.test_sendRequests');
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());
        EventSurveyHandler handler = new EventSurveyHandler();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        // Only one will be valid for survey
        List<Event> eventList = [SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event];
        Event notMet1 = getTestEvent(eventList,'testevent1');
        Event okEvent2 = getTestEvent(eventList,'testevent2');        
        // Expect Status to mean no requests are added
        ISurveyRequest request = handler.solicitSurvey(eventList,
                                                       new Map<Id,Event>{notMet1.Id => notMet1, 
                                                                         okEvent2.Id => new Event(Status__c='Not Started')});
        List<ICustomerRequest> surveyRequests = request.getRequests();
        // THEN
        System.assert(surveyRequests.size()==1,'expect 1 but was ' + request.getRequests().size());
        ICustomerRequest icr = surveyRequests.get(0);
        System.assertEquals(okEvent2.WhoId, icr.getCustomer());
        System.assertEquals('Email', icr.getContactType());
        System.assertEquals(0, icr.getDelay());
        System.assert(icr.getEvent() != null);
        System.assertEquals('Event', icr.getSurveyType());
        System.assertEquals(false, icr.getCanContactCustomer());
        System.assertEquals(true, icr.getCustomerHasEmail());
    }     

    @isTest
    static void test_sendRequestsForOpp() {
        System.debug('Running Test EventSurveyHandler_Test.test_sendRequestsForOpp');
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());
        EventSurveyHandler handler = new EventSurveyHandler();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        List<Event> eventList = [SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event];
        Event eventWithOpp = getTestEvent(eventList,'testevent3');
        Event eventWithOppNoCountry = getTestEvent(eventList,'testevent4');
        ISurveyRequest request = handler.solicitSurvey(eventList,
                                                       new Map<Id,Event>{eventWithOpp.Id => new Event(Status__c='Not Started')});
        List<ICustomerRequest> surveyRequests = request.getRequests();
        // THEN
        ICustomerRequest icr = surveyRequests.get(0);
        System.assertEquals(eventWithOpp.WhoId, icr.getCustomer());
        System.assertEquals('Email', icr.getContactType());
        System.assert(icr.getEvent() != null);
        System.assertEquals('Event', icr.getSurveyType());
        System.assertEquals(true, icr.getCanContactCustomer());
        System.assertEquals(true, icr.getCustomerHasEmail());
        System.assertEquals('United Kingdom', icr.getCountry());
        request = handler.solicitSurvey(eventList,
                                        new Map<Id,Event>{eventWithOppNoCountry.Id => new Event(Status__c='Not Started')});
        surveyRequests = request.getRequests();
        // THEN
        icr = surveyRequests.get(0);
        System.assertEquals(eventWithOppNoCountry.WhoId, icr.getCustomer());
        System.assertEquals('Albania', icr.getCountry());
    }     
    
    @isTest
    static void test_sendRequestsForCallItem() {
        System.debug('Running Test EventSurveyHandler_Test.test_sendRequestsForCallItem');
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());
        EventSurveyHandler handler = new EventSurveyHandler();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        List<Event> eventList = [SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event];
        Event eventC = getTestEvent(eventList,'testevent5');
        ISurveyRequest request = handler.solicitSurvey(eventList,
                                                       new Map<Id,Event>{eventC.Id => new Event(Status__c='Not Started')});
        List<ICustomerRequest> surveyRequests = request.getRequests();
        // THEN
        ICustomerRequest icr = surveyRequests.get(0);
        System.assertEquals(eventC.WhoId, icr.getCustomer());
        System.assertEquals('Email', icr.getContactType());
        System.assert(icr.getEvent() != null);
        System.assertEquals('Event', icr.getSurveyType());
        System.assertEquals(true, icr.getCanContactCustomer());
        System.assertEquals(true, icr.getCustomerHasEmail());
        System.assertEquals('United Kingdom', icr.getCountry());
    }     
    
    @isTest
    static void test_sendRequestsForLead() {
        System.debug('Running Test EventSurveyHandler_Test.test_sendRequestsForLead');
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());
        EventSurveyHandler handler = new EventSurveyHandler();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        List<Event> eventList = [SELECT Id,Status__c,WhatId,WhoId,Support_Type__c,Description,OwnerId FROM Event];
        Event eventL = getTestEvent(eventList,'testevent6');
        ISurveyRequest request = handler.solicitSurvey(eventList,
                                                       new Map<Id,Event>{eventL.Id => new Event(Status__c='Not Started')});
        List<ICustomerRequest> surveyRequests = request.getRequests();
        // THEN
        ICustomerRequest icr = surveyRequests.get(0);
        System.assertEquals(eventL.WhoId, icr.getCustomer());
        System.assertEquals('Email', icr.getContactType());
        System.assert(icr.getEvent() != null);
        System.assertEquals('Event', icr.getSurveyType());
        System.assertEquals(true, icr.getCanContactCustomer());
        System.assertEquals(true, icr.getCustomerHasEmail());
        System.assertEquals('Finland', icr.getCountry());
        //Lead Trigger will insert the langugae as English if it is not populted on the creation.
          System.assertEquals('English', icr.getLanguage());
    }
    
    public class MockServiceInvocation implements System.StubProvider {
        
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, 
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, 
            List<Object> listOfArgs) {        
            // This is a very simple mock provider that returns a hard-coded value 
            // based on the return type of the invoked.
            ISurveyResponse output;
            if (stubbedMethodName == 'invokeService' && listOfArgs != null) {
                output = new SurveyResponse();
                output.setState('SUCCESS');
                return output;
            } else if (stubbedMethodName == 'invokeService' && listOfArgs == null) {
                output = new SurveyResponse();
                output.setState('ERROR');
                return output;
            }
            else {
                return null;
            }    
        }
    }      
}