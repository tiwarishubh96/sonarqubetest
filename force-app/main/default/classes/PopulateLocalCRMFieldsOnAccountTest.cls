/******************************************************************************
 *                 
 *                 CONSIDER FOR DELETION
 * 
 ******************************************************************************
**/
@isTest
public class PopulateLocalCRMFieldsOnAccountTest {
    static RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account'];
    static testMethod void populateLcrms()
    {
        Profile sysProfile = [ select Id from Profile where Name = 'System Administrator'];
        User sysadmin = new User(alias = 'testuser',
                        email = 'testsysadmin@myexample.com', emailencodingkey = 'UTF-8', lastname = 'sysadmin',
                        languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = sysprofile.Id, 
                        timezonesidkey = 'America/New_York',username = 'testsysadmin@myexample.com');
        insert sysadmin;
        List<LocalCRM__c> lcrms = new List<LocalCRM__c>();
        System.runAs(sysadmin){
            LocalCRM__c lcrmUS = new LocalCRM__c(Name = 'US', Region__c = 'AMR', Country__C = 'US - United States');
            lcrms.add(lcrmUS);
            LocalCRM__c lcrmGB = new LocalCRM__c(Name = 'GB', Region__c = 'EUR', Country__C = 'GB - United Kingdom');
            lcrms.add(lcrmGB);
            insert lcrms;
        }
        List<Account> accs = new List<Account>();
        Account aUS = new Account(Name = 'TestAccountUS', BillingStreet = 'Test Street', BillingCity = 'Manville', 
                                  BillingState = 'New Jersey', BillingPostalCode = '08807', 
                                  BillingCountry = 'United States', Sales_Office__C = 'Atlanta CBC', Phone = '234-456-6789',
                                  RecordTypeId = rt.Id);
        accs.add(aUS);
        Account aUK = new Account(Name = 'TestAccountUK', BillingStreet = 'Test Street', BillingCity = 'Reading', 
                                  BillingState = 'Berkshire', BillingPostalCode = 'RG1 5AN', 
                                  BillingCountry = 'United Kingdom', Sales_Office__C = 'Dublin CBC', Phone = '234-456-6789',
                                  RecordTypeId = rt.Id);
        accs.add(aUK);
        insert accs;
        
        Map<Id, Account> accounts2 = new Map<Id, Account>(
            [SELECT ID, RecordTypeId, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                    BillingCountryCode, Local_CRM_Region__c, Local_CRM_Country__c, Local_CRM_Name__c,
                    Partner_Agreement__c, Partner_Accountant_TnC__c, Partner_Alliance_TnC__c, Partner_Implementation_TnC__c,
                    Partner_ISV_TnC__c, Partner_Reseller_TnC__c
             FROM Account]);
        
        System.debug('accounts2 >>> ' + accounts2.values());
        PopulateLocalCRMFieldsOnAccount lcrmAccount = new PopulateLocalCRMFieldsOnAccount();

        lcrmAccount.populateLocalCRMCountry(accounts2.values(), accounts2);
        System.debug('LCRMS >>>> '+ LocalCRM__c.getAll());
        
        System.debug('accounts2>>> '+accounts2);
        System.assertEquals('US - United States', accounts2.values()[0].Local_CRM_Country__c);
        System.assertEquals('GB - United Kingdom', accounts2.values()[1].Local_CRM_Country__c);
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0; i<3; i++)
        {
           Contact c = new Contact(Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com',AccountId=accs[0].Id); 
           contacts.add(c);
        }
        insert contacts;
        lcrmAccount.populateConCRMFields(accounts2.values(), accounts2);
        lcrmAccount.updateSyncDateTime(accounts2.values(), accounts2);
    }
}