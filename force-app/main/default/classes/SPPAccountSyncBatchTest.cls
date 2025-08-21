@istest
public class SPPAccountSyncBatchTest 
{
    static RecordType rt = [SELECT ID, Name FROM RecordType WHERE Name = 'Partner Account' LIMIT 1];
    

	static testMethod void testMethodforAccountSync()
 	{
        insert new LocalCRM__c(Name='GB',SQSName__c = 'UKI', Region__c='EUR',Default_CRM__c='INT - InTouch',Country__c='GB - United Kingdom');
    	insert new LocalCRM__c(Name='US',SQSName__c = 'NorthAmerica', Region__c='AMR',Default_CRM__c='FUS - Fusion',Country__c='US - United States');

        List<Account> testAccs=SPPTestData.forParentcreatAccount(10);
        List<LocalCRM__c> crms = LocalCRM__c.getAll().values();
        for(Account acc :testAccs)
        {
            acc.Local_CRM_Region__C = 'AMR';
            acc.Local_CRM_Country__C = 'US - United States';
			acc.Local_CRM_Name__c = 'FUS - Fusion';
            acc.RecordTypeId = rt.id;
            acc.Partner_Agreement__c = 'Local';
            acc.Description = 'Code coverage percentage is a calculation of the number of covered lines divided by the sum of the'+
                'number of covered lines and uncovered lines. Only executable lines of code are included. Comments and blank lines'+
                'aren not counted. System.debug statements and curly brackets are excluded when they appear alone on one line. '+
                'Multiple statements on one line are counted as one line for the purpose of code coverage. If a statement consists '+
                'of multiple expressions that are written on multiple lines, each line is counted for code coverage.';
        }
        update testAccs;
        System.debug(testAccs[0].Local_CRM_Country__C);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPAccountMockTest());
        SPPAccountSyncBatch spp = new SPPAccountSyncBatch();
		Database.executeBatch(spp);
        SPPScheduleAccountSyncBatch sh1 = new SPPScheduleAccountSyncBatch();
        String sch = '0  00 1 3 * ?';
        System.schedule('Test', sch, sh1);
        //SPPAccountResponseWrapper rep = new SPPAccountResponseWrapper();
        Test.StopTest();
 	}
    static testMethod void testMethodforAccountSync2()
 	{
        List<Account> testAccs2=SPPTestData.forParentcreatAccount(55);
        for(Account acc :testAccs2)
        {
            acc.BillingCountry = 'United Kingdom';
            acc.BillingState = 'Devon';
           	acc.Local_CRM_Region__C = 'EUR';
            acc.Local_CRM_Country__C = 'GB - United Kingdom';
			acc.Local_CRM_Name__c = 'INT - InTouch';
            acc.RecordTypeId = rt.id;
            acc.Partner_Agreement__c = 'Local';
            acc.Description = 'Code coverage percentage is a calculation of the number of covered lines divided by the sum of the'+
                'number of covered lines and uncovered lines. Only executable lines of code are included. Comments and blank lines'+
                'aren not counted. System.debug statements and curly brackets are excluded when they appear alone on one line. '+
                'Multiple statements on one line are counted as one line for the purpose of code coverage. If a statement consists '+
                'of multiple expressions that are written on multiple lines, each line is counted for code coverage.';
        }
        update testAccs2;
        System.debug(testAccs2[0].Local_CRM_Country__C);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPAccountMockTest());
        SPPAccountSyncBatch spp2 = new SPPAccountSyncBatch();
		Database.executeBatch(spp2);
        SPPScheduleAccountSyncBatch sh2 = new SPPScheduleAccountSyncBatch();
        String sch2 = '0  00 1 3 * ?';
        System.schedule('Test', sch2, sh2);
        //SPPAccountResponseWrapper rep = new SPPAccountResponseWrapper();
        Test.StopTest();
 	}
    static testMethod void testMethodforAccountSync3()
 	{
        List<Account> testAccs3=SPPTestData.forParentcreatAccount(10);
        for(Account acc :testAccs3)
        {
            acc.BillingCountry = 'United Kingdom';
            acc.BillingState = 'Devon';
           	acc.Local_CRM_Region__C = 'EUR';
            acc.Local_CRM_Country__C = 'GB - United Kingdom';
			acc.Local_CRM_Name__c = 'INT - InTouch';
            acc.RecordTypeId = rt.id;
            acc.Partner_Agreement__c = 'Local';
            acc.Description = 'Code coverage percentage is a calculation of the number of covered lines divided by the sum of the'+
                'number of covered lines and uncovered lines. Only executable lines of code are included. Comments and blank lines'+
                'aren not counted. System.debug statements and curly brackets are excluded when they appear alone on one line. '+
                'Multiple statements on one line are counted as one line for the purpose of code coverage. If a statement consists '+
                'of multiple expressions that are written on multiple lines, each line is counted for code coverage.';
        }
        update testAccs3;
        List<PublishMuleMessageWrapper.publishMuleResponse> reponseList = new List<PublishMuleMessageWrapper.publishMuleResponse>(); 
        for(Integer i=0; i<=5; i++){
        	PublishMuleMessageWrapper.publishMuleResponse pp = new PublishMuleMessageWrapper.publishMuleResponse();
            pp.eventId = '123';
            pp.messageId = '123';
            pp.recordId = testAccs3[i].Id;
            reponseList.add(pp);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPAccountMockTest());
        SPPAccountSyncBatch spp3 = new SPPAccountSyncBatch();
        spp3.updateSyncDateTime(reponseList);
        reponseList[0].recordId = null;
        spp3.updateSyncDateTime(reponseList);
        Test.StopTest();
    }
}