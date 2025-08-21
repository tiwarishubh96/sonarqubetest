@isTest
public class PopulateLocalCRMFieldsOnContactTest 
{
    Static RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account'];
    Static testmethod void createContacts()
    {
        Account acc = new Account(Name = 'TestAccount', BillingStreet = 'Test Street', BillingCity = 'Manville', 
                                  BillingState = 'New Jersey', BillingPostalCode = '08807', 
                                  BillingCountry = 'United States', Sales_Office__c = 'Atlanta CBC', Phone = '234-456-6789',
                                  RecordTypeId = rt.Id);
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ; i<5; i++)
        {
           Contact c = new Contact(HasOptedOutOfEmail=true, Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com',
                                   MailingCity = 'Manville',SyncDateTime__c=System.NOW(),
                                   AccountId=acc.id); 
           contacts.add(c);
        }
        
        insert contacts;
        
        Map<Id, Contact> contacts2 = new Map<Id, Contact>([SELECT Id, SyncDateTime__c FROM Contact]);
        RecursiveTriggerHandler.isFirstTime = true;
        contacts[0].firstName = 'Test';
        update contacts[0];
        RecursiveTriggerHandler.isFirstTime = true;
        PopulateLocalCRMFieldsOnContact lcrm = new PopulateLocalCRMFieldsOnContact();
        lcrm.populateLocalCRMCountry(contacts);
        lcrm.updateSyncDateTime(contacts, contacts2);
        lcrm.updateEmailOptOutLMT(contacts);
        contacts[0].isLeadConverted__c = false;
        contacts[0].MailingCountryCode = 'US';
        update contacts[0];
        RecursiveTriggerHandler.isFirstTime = true;
        lcrm.billingCityandStreetCheck(contacts);
    }
}