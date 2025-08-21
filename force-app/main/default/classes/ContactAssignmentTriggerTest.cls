/*
 * ContactAssignmentTriggerTest
 * Tests the ContactAssignmentTrigger and its helper class
 */
@IsTest
public class ContactAssignmentTriggerTest {
    @TestSetup
    static void dataSetup() {
      Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(Alias='contacta',
                           Email='a@aac.com',
                           EmailEncodingKey='ISO-8859-1',
                           FirstName='aaa',
                           LastName='aaa',
                           LanguageLocaleKey='en_US',
                           LocaleSidKey='en_GB',
                           ProfileId=p1.Id,
                           TimeZoneSidKey='Europe/London',
                           CommunityNickname = 'aaa',
                           IsActive=true,
                           username='a@aac.com.sage');
        insert u1;
        // Create Account 
        Account a = new Account();            
        a.Name = 'EAD1539Account'; 
        a.Type = 'Accountant Customer';
        a.BillingCity = 'Atlanta';
        a.BillingStreet = '123 Technology dr';
        a.BillingState = '';
        a.BillingCountry = 'Iceland';
        a.BillingPostalCode = '22222-2222';
        a.CurrencyIsoCode = 'USD';
        a.Industry = 'Retail';
        a.Partner_Type__c = 'Accountant';
        a.OwnerId = u1.id;
        a.Phone = '9999999999';
        a.Sales_Office__c = 'Atlanta CBC';    
        insert a;
    
        // Create Contact with minimum required fields
        List<Contact> cList = new List<Contact>();
        for (Integer i=0; i<10; i++) {
            Contact c = new Contact();   
            c.AccountId = a.id;
            c.FirstName = 'EAD1539FirstName' + i;
			c.LastName = 'EAD1539FirstName' + i;
			c.Email = 'EAD1539' + i + '@email.com';
            c.Job_Role__c = 'Manager';
            c.CurrencyIsoCode = 'USD';
            // mandatory fields
            c.MailingCity = 'Atlanta';
            c.MailingState = 'Georgia';
            c.MailingCountry = 'United States';
            c.MailingPostalCode = '11111-1111';                           
            cList.add(c);
        } 
        System.Debug('Create Contacts =' + cList);        
        insert cList;
    }
    
    @IsTest
    static void testContactAssignment() {       
        System.debug('ContactAssignmentTriggerTest: testContactAssignment START');
        // Retrieve test data
        List<Contact> contactIds = [SELECT Id FROM Contact];     
        // Switch on validation rules which have the bypass setting to catch Contact errors
        ContactControlSwitch__c setting = new ContactControlSwitch__c ();
		setting.Name = 'VR';
		setting.RunValidationRules__c = true;
		insert setting;
        
        Test.startTest();
        System.Debug('ContactAssignmentTriggerTest ContactIds=' + contactIds);        
        List<Contact_Assignment__c> caList = new List<Contact_Assignment__c>();  
        //Contact_Assignment__c ca = new Contact_Assignment__c();  // w/o it has error Before Insert or Upsert list must not have two identically equal elements?      
        for (Integer j=0; j<10; j++) {        
            Contact_Assignment__c ca = new Contact_Assignment__c();
			// update new value
			ca.Contact__c = contactIds[j].Id;
            ca.Contact_Email__c = 'newemail' + j + '@email.com';
            ca.Contact_Job_Role__c = 'Director';
            ca.Contact_FirstName__c = 'newFirstName' + j;
            ca.Contact_LastName__c = 'newLastName' + j;
            ca.Contact_Owner__c = '00524000000GluHAAS';
            ca.Contact_Phone__c = '999990' + j;
            ca.Contact_Title__c = 'Dr';                       
            
            // fail case,  don't have any validation rule on update fields... can't test fail case
//            if  (j == 9){
//                ca.Contact_Job_Role__c = 'InvalidJobRole';
//            } 
            caList.add(ca);

        }
                           
        // Duplicate case same Contact id
        Contact_Assignment__c caDuplicated = new Contact_Assignment__c();   
	    caDuplicated.Contact__c = contactIds[0].Id;  // same Contact ID
        caList.add(caDuplicated);
        
        // Inserting the Contact_Assignment__c objects should fire the associated trigger       
        System.Debug('---caList=' + caList);
        insert caList;  
                
        // Ensure trigger completed (and hopefully the batch)
		Long startingTime = System.now().getTime(); 
	    Integer delayInMilliseconds = 3000; // Three-second delay
		while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
 		}

         Test.stopTest(); 
        // Check only the good 
  //      System.debug('ContactAssignmentTriggerTest: Good Contacts');
  //      Integer goodContacts = [SELECT COUNT() FROM Contact where  Name like '%new%' ];
  //      System.assertEquals(9, goodContacts);
        // Check all of the Contact Assignments changed status appropriately
        // 
        System.debug('ContactAssignmentTriggerTest: Success');
        List<Contact_Assignment__c> caAfter  = new List<Contact_Assignment__c>();   
        caAfter = [SELECT Id, Status__c FROM Contact_Assignment__c];
        System.Debug('---- Results=' + caAfter);
        Integer retOAs = [SELECT COUNT() FROM Contact_Assignment__c WHERE Status__c = 'Success'];              
        System.assertEquals(10, retOAs);
        System.debug('ContactAssignmentTriggerTest: Fail');
        Integer retOAs2 = [SELECT COUNT()  
                          FROM Contact_Assignment__c
                          WHERE Status__c = 'Fail'];
        System.assertEquals(0, retOAs2);
        
        System.debug('ContactAssignmentTriggerTest: Duplicate');
        Integer retOAs3 = [SELECT COUNT()  
                           FROM Contact_Assignment__c
                           WHERE Status__c = 'Duplicate'];
        System.assertEquals(1, retOAs3);
        System.debug('ContactAssignmentTriggerTest: testContactAssignment FINISH');

    }
}