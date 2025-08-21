@isTest
public class CaseSharingRulesBatchTest {

    static testMethod void testSharingRulesBatch() {

        Id recordTypeId = [Select Id from RecordType where sobjecttype = 'Account' and Name = 'Partner Account'].Id;
        Locale__c locale = DataFactoryForTesting.createLocale();
        DataFactoryForTesting.createPartnerCommunityLocaleMapping();
        Account a = DataFactoryForTesting.createAccountWithLoc(locale.Id);
        a.RecordTypeId = recordTypeId;
        update a;
        Contact c1 = DataFactoryForTesting.createContact(a.Id);
        User u1 =  DataFactoryForTesting.createUser(c1.Id);
        insert u1;
		Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        Test.startTest();
        Case newCase = DataFactoryForTesting.createCase(c1);
        System.Schedule('Case Sharing Scheduler', CRON_EXP, new CaseSharingRulesBatchScheduler () );  
        Test.stopTest();
        //CaseSharingRulesBatch batchJob = new CaseSharingRulesBatch();
        //Database.executeBatch(batchJob);

    }

}