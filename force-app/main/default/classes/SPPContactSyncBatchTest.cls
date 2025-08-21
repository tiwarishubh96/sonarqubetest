@isTest
public class SPPContactSyncBatchTest {
    static RecordType rt = [SELECT ID, Name FROM RecordType WHERE Name = 'Partner Account' LIMIT 1];
    static testMethod void testMethodforContactSync(){
        insert new LocalCRM__c(Name='GB',SQSName__c = 'UKI', Region__c='EUR',Default_CRM__c='INT - InTouch',Country__c='GB - United Kingdom');
    	insert new LocalCRM__c(Name='US',SQSName__c = 'NorthAmerica', Region__c='AMR',Default_CRM__c='FUS - Fusion',Country__c='US - United States');

        List<Account> testAccs=SPPTestData.forParentcreatAccount(1);
        for(Account acc :testAccs)
        {
            acc.RecordTypeId = rt.id;
            acc.Local_CRM_Region__C = 'AMR';
            acc.Local_CRM_Country__C = 'US - United States';
            acc.Local_CRM_Name__c = 'FUS - Fusion';
            acc.Partner_Agreement__c = 'Local';
        }
        update testAccs;
        List<Contact> contacts = new LisT<Contact>();
        for(Integer i=0; i<=50; i++){
            contacts.add(new Contact(FirstName = 'Test'+i,LastName='Contact'+i, AccountId = testAccs[0].Id, email = 'test'+i+'@contact.com',MailingStreet = 'TestStreet',
                                 MailingCity='Atlanta',MailingCountry='United States',MailingState='Georgia',MailingPostalCode='30092',
                                 Local_CRM_Region__C = 'AMR',Local_CRM_Country__C = 'US - United States',Local_CRM_Name__c = 'FUS - Fusion'));
        }
        insert contacts;
        System.debug('con ids > '+contacts);
        List<Contact> cons = [SELECT Id, Name, Local_CRM_Region__C, Local_CRM_Country__C,Local_CRM_Name__c, SyncDateTime__C FROM Contact ];
        System.debug('cons > '+cons);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPContactMockTest());
        SPPContactSyncBatch spp = new SPPContactSyncBatch();
        Database.executeBatch(spp);
        Test.StopTest();
    }
    static testMethod void testMethodforContactSync2(){
        List<Account> testAccs2=SPPTestData.forParentcreatAccount(1);
        for(Account acc :testAccs2)
        {
            acc.RecordTypeId = rt.id;
            acc.BillingCountry = 'United Kingdom';
            acc.BillingState = 'Devon';
            acc.Local_CRM_Region__C = 'EUR';
            acc.Local_CRM_Country__C = 'GB - United Kingdom';
            acc.Local_CRM_Name__c = 'INT - InTouch';
            acc.Partner_Agreement__c = 'Local';
        }
        update testAccs2;
        List<Contact> contacts2 = new LisT<Contact>();
        for(Integer i=0; i<=25; i++){
            contacts2.add(new Contact(FirstName = 'Test'+i,LastName='Contact'+i, AccountId = testAccs2[0].Id, email = 'test'+i+'@contact.com',MailingStreet = 'TestStreet',
                                 MailingCity='Atlanta',MailingCountry='United Kingdom',MailingState='Devon',MailingPostalCode='30092',
                                 Local_CRM_Region__C = 'EUR',Local_CRM_Country__C = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch'));
        }
        insert contacts2;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPContactMockTest());
        SPPContactSyncBatch spp2 = new SPPContactSyncBatch();
        Database.executeBatch(spp2);
        SPPScheduleContactSyncBatch sh1 = new SPPScheduleContactSyncBatch();
        String sch = '0  00 1 3 * ?';
        System.schedule('Test', sch, sh1);
        //SPPContactResponseWrapper rep = new SPPContactResponseWrapper();
        Test.StopTest();
    }
    static testMethod void testMethodforContactSync3(){
        List<Account> testAccs3=SPPTestData.forParentcreatAccount(1);
        for(Account acc :testAccs3)
        {
            acc.RecordTypeId = rt.id;
            acc.BillingCountry = 'United Kingdom';
            acc.BillingState = 'Devon';
            acc.Local_CRM_Region__C = 'EUR';
            acc.Local_CRM_Country__C = 'GB - United Kingdom';
            acc.Local_CRM_Name__c = 'INT - InTouch';
            acc.Partner_Agreement__c = 'Local';
        }
        update testAccs3;
        List<Contact> contacts3 = new LisT<Contact>();
        for(Integer i=0; i<=25; i++){
            contacts3.add(new Contact(FirstName = 'Test'+i,LastName='Contact'+i, AccountId = testAccs3[0].Id, email = 'test'+i+'@contact.com',MailingStreet = 'TestStreet',
                                 MailingCity='Atlanta',MailingCountry='United Kingdom',MailingState='Devon',MailingPostalCode='30092',
                                 Local_CRM_Region__C = 'EUR',Local_CRM_Country__C = 'GB - United Kingdom',Local_CRM_Name__c = 'INT - InTouch'));
        }
        insert contacts3;
        List<PublishMuleMessageWrapper.publishMuleResponse> reponseList = new List<PublishMuleMessageWrapper.publishMuleResponse>(); 
        for(Integer i=0; i<=5; i++){
        	PublishMuleMessageWrapper.publishMuleResponse pp = new PublishMuleMessageWrapper.publishMuleResponse();
            pp.eventId = '123';
            pp.messageId = '123';
            pp.recordId = contacts3[i].Id;
            reponseList.add(pp);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPPSyncMockCalloutTest.SPPContactMockTest());
        SPPContactSyncBatch spp3 = new SPPContactSyncBatch();
        spp3.updateSyncDateTime(reponseList);
        reponseList[0].recordId = null;
        spp3.updateSyncDateTime(reponseList);
        Test.StopTest();
    }
}