/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPDocuSignRest
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPDocuSignRestTest
{
    @testSetup static void SPPTestData() {
        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c(
            dsfs__AccountId__c='Test Account ',dsfs__DocuSignBaseURL__c='Test Url',dsfs__DocuSignEnvironment__c='Test Env'
            , dsfs__DSProSFPassword__c='TestPass',dsfs__DSProSFUsername__c='Test Lucky'
        );
        insert accConFig;
    }

    @isTest
    static void sendEnvelopeTest()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());

        List<Contact> conList = [Select Id ,name,email,title from Contact ];
        List<String> tempList = new List<String>();
        tempList.add('tempList1');
        string fieldsAPIname = '';
        fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name ,Owner.Email, Owner.Name,Owner.title, Owner.Username,'+fieldsAPIname+' from Account Limit 1 ';

         
        Account acc = Database.query(strparentqry);
        
        map<Integer , String > mapTemp = new map<Integer , String >();
        mapTemp.put(1,'test2');

        SPPDocuSignRest re = new SPPDocuSignRest();
        test.startTest();
        
        SPPWrapperDocuSign sppWrapper = re.sendEnvelope( conList , mapTemp, acc ,'Accountant');
        
        test.stopTest();
    }

    @isTest
    static void sendEnvelopeTestException()
    {
        
        List<Contact> conList = [Select Id ,name,email,title from Contact ];
        List<String> tempList = new List<String>();
        tempList.add('tempList1');
        string fieldsAPIname = '';
        fieldsAPIname=SPPUtils.ObjectFields('Account');//Describe call to fetch all the fields related to an Account 
        
        //Query too fetch Account record details
        string strparentqry = 'Select Locale__r.Name ,Owner.Email, Owner.Name,Owner.title, Owner.Username,'+fieldsAPIname+' from Account Limit 1 ';

         
        Account acc = Database.query(strparentqry);
        
        map<Integer , String > mapTemp = new map<Integer , String >();
        mapTemp.put(1,'test2');
        
        SPPDocuSignRest re = new SPPDocuSignRest();
        test.startTest();
        
        SPPWrapperDocuSign sppWrapper = re.sendEnvelope( conList , mapTemp, acc ,'Accountant');
        
        test.stopTest();
    }
    
    @isTest
    static void voidEnvelopeTest()
    {
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());

        SPPDocuSignRest re = new SPPDocuSignRest();
        test.startTest();
        re.voidEnvelop('Accountant');
        test.stopTest();
        
    }
    @isTest
    static void voidEnvelopeTestWithException()
    {
        SPPDocuSignRest re = new SPPDocuSignRest();
        test.startTest();
        re.voidEnvelop('Accountant');
        test.stopTest();
        
    }
    
}