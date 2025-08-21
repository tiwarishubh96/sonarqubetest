@isTest
public class OpportunitySurveyHelper_Test {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='testAccount', Type='Customer', BillingCountry='United Kingdom',
                BillingCity='Blyth', BillingStreet='Salisbury Street');
        insert acc;

        Contact con1 = new Contact(FirstName='Roger', LastName='Hunt', Email='roger.hunt@test.com.donotcall',
                AccountId=acc.Id, Allow_Experience_Feedback__c='Yes', Allow_Email__c='Yes',Language__c='English',
                HasOptedOutOfEmail=false,Last_Survey_Date__c=System.now()-30);
        insert con1;

        //create Opp
        Opportunity qual1 = new Opportunity(Name='Excluded1', AccountId=acc.Id, StageName='Qualify',
                CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        insert qual1;
        Opportunity discovery1 = new Opportunity(Name='Excluded2', AccountId=acc.Id, StageName='Discovery',
                CloseDate=System.today() + 20, Lead_Source__c='Marketing');
        insert discovery1;
        Opportunity surveyOk1 = new Opportunity(Name='closedWon1', AccountId=acc.Id, StageName='Closed Won',
                CloseDate=System.today() + 20,Primary_Contact__c=con1.Id);
        insert surveyOk1;
        Opportunity surveyOk2 = new Opportunity(Name='closedLost1', AccountId=acc.Id, StageName='Closed Lost',
                CloseDate=System.today() + 20,Primary_Contact__c=con1.Id,Why_We_Lost__c='No Reason Specified');
        insert surveyOk2;

        // do stuff with old and new
    }


    @isTest
    /*
    * @criteria - Not Closed Won | Closed Lost. New stageName != old &
    * @critera - Qualification + converted + with a primary contact that has been added in this update
    */
    static void test_OpportunityDoesNotMeetCriteria(){
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());

        OpportunitySurveyHelper handler = new OpportunitySurveyHelper();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        Opportunity opp1 = [SELECT Id,AccountId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='Excluded2' LIMIT 1];
        Opportunity oldOpp = new Opportunity(StageName='New');
        // Expect Status to mean no requests are added
        ISurveyRequest request = handler.solicitSurvey(new List<Opportunity>{opp1},new Map<Id, Opportunity>{opp1.Id => oldOpp});
        // no requests
        System.assert(request.getRequests().size()==0);
        // Qualified
        opp1 = [SELECT Id,AccountId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='Excluded1' LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact WHERE Email='roger.hunt@test.com.donotcall' LIMIT 1];
        opp1.Is_Converted__c = true;
        opp1.Primary_Contact__c = con1.id;
        request = handler.solicitSurvey(new List<Opportunity>{opp1},new Map<Id, Opportunity>{opp1.Id => oldOpp});
        // no requests
        System.assert(request.getRequests().size()==0);
    }

    @isTest
    static void test_sendRequests(){
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());

        OpportunitySurveyHelper handler = new OpportunitySurveyHelper();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        Opportunity opp1 = [SELECT Id,AccountId,OwnerId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='closedWon1' LIMIT 1];
		Opportunity opp2 = [SELECT Id,AccountId,OwnerId,Primary_Contact__c,StageName,Is_Converted__c,Why_We_Lost__c FROM Opportunity WHERE Name='closedLost1' LIMIT 1];

        // Expect Status to mean no requests are added
        ISurveyRequest request = handler.solicitSurvey(new List<Opportunity>{opp1},new Map<Id,Opportunity>{opp1.Id => new Opportunity(StageName='Discovery')});
        ISurveyRequest request2 = handler.solicitSurvey(new List<Opportunity>{opp2},new Map<Id,Opportunity>{opp2.Id => new Opportunity(StageName='Discovery')});
        
        List<ICustomerRequest> surveyRequests = request.getRequests();
        List<ICustomerRequest> surveyRequests2 = request2.getRequests();
        // THEN
        System.assert(surveyRequests.size()==1,'expect 1 but was ' + request.getRequests().size());
        System.assertEquals(opp1.Primary_Contact__c, surveyRequests.get(0).getCustomer());
        System.assertEquals('Email', surveyRequests.get(0).getContactType());
        System.assertEquals(0, surveyRequests.get(0).getDelay());
        System.assert(surveyRequests.get(0).getEvent() != null);
        System.assertEquals('Opportunity', surveyRequests.get(0).getSurveyType());
        System.assertEquals(true, surveyRequests.get(0).getCanContactCustomer());
        System.assertEquals(true, surveyRequests.get(0).getCustomerHasEmail());
         System.assertEquals('English', surveyRequests.get(0).getLanguage());
    }


    @isTest static void oppSolicitSurveyInsertTest(){
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());

        // GIVEN
        OpportunitySurveyHelper handler = new OpportunitySurveyHelper();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        Opportunity opp1 = [SELECT Id,AccountId,OwnerId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='closedWon1' LIMIT 1];

        // WHEN
        Test.startTest();
        ISurveyRequest request = handler.solicitSurvey(new List<Opportunity>{opp1});
        List<ICustomerRequest> surveyRequests = request.getRequests();
        Test.stopTest();

        // THEN
        System.assert(surveyRequests.size()==1,'expect 1 but was ' + request.getRequests().size());
        System.assertEquals(opp1.Primary_Contact__c, surveyRequests.get(0).getCustomer());
        System.assertEquals('Email', surveyRequests.get(0).getContactType());
        System.assertEquals(0, surveyRequests.get(0).getDelay());
        System.assert(surveyRequests.get(0).getEvent() != null);
        System.assertEquals('Opportunity', surveyRequests.get(0).getSurveyType());
        System.assertEquals(true, surveyRequests.get(0).getCanContactCustomer());
        System.assertEquals(true, surveyRequests.get(0).getCustomerHasEmail());
    }

    @isTest static void oppSolicitSurveyInsertNegativeTest(){
        ServiceInvocation mockInvocation = (ServiceInvocation)Test.createStub(ServiceInvocation.class,new MockServiceInvocation());

        // GIVEN
        OpportunitySurveyHelper handler = new OpportunitySurveyHelper();
        handler.getInvoker().setOverride(SurveyTypes.RNR_Async, mockInvocation);
        Opportunity opp1 = [SELECT Id,AccountId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='Excluded2' LIMIT 1];
        Opportunity oldOpp = new Opportunity(StageName='New');


        // WHEN
        Test.startTest();
        // Expect Status to mean no requests are added
        ISurveyRequest request = handler.solicitSurvey(new List<Opportunity>{opp1});
        Test.stopTest();

        // THEN
        // no requests
        System.assert(request.getRequests().size()==0);
        // Qualified
        opp1 = [SELECT Id,AccountId,Primary_Contact__c,StageName,Is_Converted__c FROM Opportunity WHERE Name='Excluded1' LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact WHERE Email='roger.hunt@test.com.donotcall' LIMIT 1];
        opp1.Is_Converted__c = true;
        opp1.Primary_Contact__c = con1.id;
        request = handler.solicitSurvey(new List<Opportunity>{opp1},new Map<Id, Opportunity>{opp1.Id => oldOpp});
        // no requests
        System.assert(request.getRequests().size()==0);
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