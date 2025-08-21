/**
 * Created by 2019/05/10 bphan
 */
@IsTest
private class Contact_ValidationRules_Test {
    
    static RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account'];
    static testMethod void createContacts()
    {
        ContactControlSwitch__c contactSwitch = ContactControlSwitch__c.getInstance();
        contactSwitch.RunAssignmentRules__c = true;
        RecursiveTriggerHandler.isFirstTime = true;
        
        Account acc = new Account(Name = 'TestAccount', BillingStreet = 'Test Street', BillingCity = 'Manville', 
                                  BillingState = 'New Jersey', BillingPostalCode = '08807', 
                                  BillingCountry = 'United States', Sales_Office__c = 'Atlanta CBC', Phone = '234-456-6789',
                                  RecordTypeId = rt.Id);
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ; i<5; i++)
        {
           Contact c = new Contact(HasOptedOutOfEmail=true, Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com',
                                   AccountId=acc.Id); 
           contacts.add(c);
        }
        
        insert contacts;

        contacts[0].FirstName = 'Test';
        contacts[0].isLeadConverted__c = false;
        update contacts[0];
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);            
        }finally{                
            System.assertEquals( false, contacts[0].isLeadConverted__c);            
        }
        
        contacts[1].isLeadConverted__c = false;
        contacts[1].MailingCountryCode = 'CN';
        contacts[1].MailingCity = 'Atlanta';
        contacts[1].MailingStreet = 'Street2';
        update contacts[1];
        RecursiveTriggerHandler.isFirstTime = true;
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, false);            
        }finally{          
            System.assertEquals(false, contacts[1].isLeadConverted__c);            
        }
        
        contacts[1].isLeadConverted__c = true;
        contacts[1].MailingCountryCode = 'MX';
        contacts[1].MailingStreet =' ';
        contacts[1].MailingCity =' ';
        update contacts[1];
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);            
        }finally{          
            System.assertEquals(true, true);            
        }
        contacts[1].isLeadConverted__c = true;
        contacts[1].MailingCountryCode = 'MX';
        contacts[1].MailingStreet =' ';
        contacts[1].MailingCity ='Atlanta ';
        update contacts[1];
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);            
        }finally{          
            System.assertEquals(true, true);            
        }
        
        contacts[1].isLeadConverted__c = true;
        contacts[1].MailingCountryCode = 'MX';
        contacts[1].MailingStreet ='Technology Dr ';
        contacts[1].MailingCity =' ';
        update contacts[1];
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);            
        }finally{          
            System.assertEquals(true, true);            
        }
        
        contacts[1].isLeadConverted__c = false;
        contacts[1].MailingCountryCode = 'CA';
        contacts[1].MailingCity = '';
        contacts[1].MailingStreet = '';        
        update contacts[1];
        try{
          Contact_ValidationRules.validateMailingCityandStreet(contacts);
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
            System.assertEquals(expectedExceptionThrown, true);            
        }finally{          
            System.assertEquals(true, true);            
        }        
        
        // Run As Eloqua user
        User thisUser = [ SELECT Id FROM User WHERE FirstName = 'Eloqua' AND LastName = 'Integration']; 

        System.runAs ( thisUser ) 
        {   contacts[2].MailingCountryCode = 'US';
            contacts[2].isLeadConverted__c = true;
            contacts[2].MailingCity = '';
            contacts[2].MailingStreet = '';
            update contacts[2];
         try{
            Contact_ValidationRules.validateMailingCityandStreet(contacts);
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
                System.assertEquals(expectedExceptionThrown, true);            
            }finally{   
               System.assertEquals(true, true);            
            }   
         
            contacts[2].MailingCountryCode = 'CA';
            contacts[2].isLeadConverted__c = true;
            contacts[2].MailingCity = '';
            contacts[2].MailingStreet = '';
            update contacts[2];
         try{
            Contact_ValidationRules.validateMailingCityandStreet(contacts);
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
                System.assertEquals(expectedExceptionThrown, true);            
            }finally{   
               System.assertEquals(true, true);            
            } 
         
           contacts[2].MailingCountryCode = 'US';
            contacts[2].isLeadConverted__c = false;
            contacts[2].MailingCity = '';
            contacts[2].MailingStreet = '';
            update contacts[2];
         try{
            Contact_ValidationRules.validateMailingCityandStreet(contacts);
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_CITY_STREET_REQUIRED) ? true : false;
                System.assertEquals(expectedExceptionThrown, true);            
            }finally{   
               System.assertEquals(true, true);            
            } 

         CBC_Application_Control__c.getInstance().Run_Triggers_for_Specific_App__c  = false;
         contactSwitch.RunAssignmentRules__c = false;
         
            contacts[2].MailingCountryCode = 'CA';
            contacts[2].isLeadConverted__c = false;
            contacts[2].MailingCity = 'Montreal';
            contacts[2].MailingStreet = '';
          try{
            Contact_ValidationRules.validateMailingCityandStreet(contacts);
            } catch (Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains(Label.CONTACT_MAILING_STREET_REQUIRED) ? true : false;
                System.assertEquals(expectedExceptionThrown, true);            
            }finally{   
               System.assertEquals(true, true);            
            }          
        }
        
   }
}