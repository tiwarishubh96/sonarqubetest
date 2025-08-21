/*-------------------------------------------------------------
    Author:         Lakshman
    Date :          08/18/2017
    Company:       Docmation LLC
    Description:   Test Class for SPPBulkScheduleDocuSign
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
@isTest
private class SPPBulkScheduleDocuSignTest
{
    @testSetup static void SPPTestData() {
        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c();
        docStatus.dsfs__DocuSign_Envelope_ID__c = '12345';
        insert docStatus;
        
        dsfs__DocuSignAccountConfiguration__c accConFig = new dsfs__DocuSignAccountConfiguration__c(
            dsfs__AccountId__c='Test Account ',dsfs__DocuSignBaseURL__c='Test Url',dsfs__DocuSignEnvironment__c='Test Env'
            , dsfs__DSProSFPassword__c='TestPass',dsfs__DSProSFUsername__c='Test Lucky'
        );
        insert accConFig;

        SPPTestData.CreateAccountAndContactForPartnerType();
        SPPTestData.CreateTandCGlobalAndVersions();
    }


    @isTest
    static void itShould()
    {
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new SPPDocuSignBulkRestTestMockGenerator());
        SPPScheduleDocuSignBulkWrapper wr = new SPPScheduleDocuSignBulkWrapper();

        List<Account> accList = [Select Id from Account];
        List<Contact> conList = [Select Id ,email,name from Contact];
        map<String,Contact> conMap = new map<String , Contact>();
        map<String,Account> accMap = new map<String , Account>();

        for(Account acc : accList)
        {
            accMap.put(conList[0].email,acc);
            conMap.put(conList[0].email , conList[0]);
        }

        wr.batchId = 'batchId';
        wr.templateVersId = [Select id from Terms_Conditions_Version__c limit 1].id;
        wr.accAndConMap = accMap;
        wr.conMap = conMap;

        SPPBulkScheduleDocuSign sppf = new SPPBulkScheduleDocuSign(JSON.serialize(wr) );
        Datetime dateT = Datetime.now();
        Datetime d = dateT.addMinutes(2);
        String hour = String.valueOf(d.hour());
        String min = String.valueOf(d.minute()); 
        String ss = String.valueOf(d.second());
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        String name = 'TermsAndConditions'+Datetime.Now().millisecond();
        system.schedule(name, nextFireTime, sppf);
        Test.stopTest();

    }
}