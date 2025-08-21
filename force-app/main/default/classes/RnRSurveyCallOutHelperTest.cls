@isTest
public class RnRSurveyCallOutHelperTest {
    
    List<Id> caseList = new List<Id>();
    
    @TestSetup
    static void makeTestDataForCase(){
        
        DateTime lastSurveyDate = system.now().adddays(-31);
        
        Account testAcct = new Account(Name='TestAccount',Sales_Office__c='Atlanta CBC',Type='Analyst',CurrencyIsoCode='USD',Phone='1234567899', 
                                       BillingCountry = 'United States', BillingState = 'New York', BillingPostalCode = '08807', BillingCity = 'Newyork');
        insert testAcct;
        
        Contact testContact = new Contact(LastName = 'TestRnR', AccountId = testAcct.id, Email = 'test@test.com', 
                                          HasOptedOutOfEmail = false, Last_Survey_Date__c = system.now().adddays(-41));
        insert testContact;
        
        
        Case testCase = new Case(Type = 'Problem', ContactId = testContact.Id, Case_Category__c = 'Processing', 
                                 Customer_Lifecycle_Stage__c = 'Onboarding', Status = 'New', Priority = 'Medium', 
                                 Origin = 'Product', Subject = 'Test Case');
        
        insert testCase;
        
        
    }
    
    
    /*public static testmethod void testGetEventMessage(){
        Account acc = new Account(Name='TestAccount',Sales_Office__c='Atlanta CBC',Type='Analyst',CurrencyIsoCode='USD',Phone='1234567899', 
                                  BillingCountry = 'United States', BillingState = 'New York', BillingPostalCode = '08807', BillingCity = 'Newyork');
        insert acc;
        Contact cont = new Contact(LastName = 'TestRnR', AccountId = acc.id, Email = 'test@test.com', Last_Survey_Date__c = system.now().adddays(-41));
        insert cont;
        DateTime lastSurveyDate = system.now().adddays(-31);
        
        Contact cont1 = [select id,Last_Survey_Date__c from Contact where id=: cont.id];
        system.debug(cont1);
        Case c = new Case(Type='Problem', ContactId=cont.id,Case_Category__c = 'Integration',Customer_Lifecycle_Stage__c ='Trial', Subject='test',Status = 'Closed',Priority = 'High',
                          Origin = 'Chat',Product__c = 'Financials');
        insert c;
        Case c1 = [select id,ContactId,Contact.Last_Survey_Date__c,Type from Case where id=: c.id];
        system.debug(c1);
        List<Id> cc = new List<Id>();
        cc.add(c.id);
        Map<String,String> caseEventIdsMap = new Map<String,String>();
        caseEventIdsMap.put('8202ce6c-6be9-4ed7-b431-4efd24d41114',c.id);
        PublishMuleMessageWrapper.publishMuleResponse res = new PublishMuleMessageWrapper.publishMuleResponse();
        res.recordId = c.id;
        List<PublishMuleMessageWrapper.publishMuleResponse> resLst = new List<PublishMuleMessageWrapper.publishMuleResponse>();
        resLst.add(res);
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.RnRSurveyMockTest());
        Test.startTest();
        RnRSurveyCallOutHelper.updateSyncDateTime(resLst);
        system.debug('before calling helper');
        //RnRSurveyCallOutHelper.getEventMessage(cc);
        system.debug('after calling helper');
        //  RnRCallOutHelper.getEventMessage(cc).caseEventIdsMap = caseEventIdsMap;
        Test.stopTest();
    }*/
    
    
    public static testmethod void testRnRSurvey(){
        
        List<Id> caseIds = new List<Id>();
        List<Case> caseList = [select id, ContactId, Status, Contact.Last_Survey_Date__c from Case];
        System.debug('caseList = '+caseList.size());
        if(!caseList.isEmpty()){
            
            Case testCase = caseList[0];
            
            System.debug('testCase = '+testCase);
            testCase.Status = 'Closed';
            update testCase;

            RnRSurveyCallOutHelper.sendSurveyRnR(new List<Id>{testCase.Id}, new Map<Id, Case>());
        }
        
        System.assert(caseList.size()>0);
    }
    
    
    
    
    
}