/**
 * @description  Contact Helper Test
 * @author craig bradshaw
 * @date March 2019
 */
@IsTest
private class Contact_Helper_Test {

    @TestSetup static void setup() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account' AND SobjectType = 'Account'];
        Account ac1 = new Account(Name='Acc 1',Local_CRM_Country__c='CA - Canada',Local_CRM_Name__c='FUS - Fusion',Local_CRM_Region__c='AMR');
        insert ac1;
        Contact ct1 = new Contact(FirstName='Cont1',AccountId=ac1.Id,LastName='Flinstone',Email='test@test.com');
        insert ct1;
        Contact ct2 = new Contact(FirstName='Cont2',AccountId=ac1.Id,LastName='Lumberson',Email='test@telsa.com',HasOptedOutOfEmail=true,isLeadConverted__c=false);
        insert ct2;
        //ac1.Number_of_contacts__c = 2;
        //update ac1;
        Contact ct3 = new Contact(FirstName='Cont add',LastName='Testerson',Email='test@telsa.com');
        insert ct3;
        Account acc = new Account(Name = 'TestAccount', BillingStreet = 'Test Street', BillingCity = 'Manville',
                BillingState = 'New Jersey', BillingPostalCode = '08807',
                BillingCountry = 'United States', Sales_Office__c = 'Atlanta CBC', Phone = '234-456-6789',
                RecordTypeId = rt.Id);
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ; i<5; i++)
        {
            Contact c = new Contact(Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com',
                    AccountId=acc.Id);
            contacts.add(c);
        }
        insert contacts;

    }

    @IsTest
    static void testUpdateEmailOptOutLMT_Insert() {
        Contact ct1 = new Contact(FirstName='Fred',LastName='Flinstone',Email='test@tasdest.com',HasOptedOutOfEmail=true,isLeadConverted__c=false,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200000))+Datetime.now().millisecond()));
        System.assert(ct1.Email_Opt_Out_LMT__c == null);
        System.assert(ct1.HasOptedOutOfEmail == true);
        Test.startTest();
        insert ct1;
        Test.stopTest();
        ct1 = [SELECT FirstName, LastName,Email_Opt_Out_LMT__c FROM Contact WHERE FirstName='Fred' AND LastName='Flinstone' AND Email='test@tasdest.com' LIMIT 1];
        System.assert(ct1.Email_Opt_Out_LMT__c != null);
    }
/*
    @IsTest
    static void testUpdateSyncDateTime(){
        User eloquaUser = [SELECT Id FROM User WHERE Name = 'Eloqua Integration' LIMIT 1];
    }
*/
    @IsTest
    static void testPopulateLocalCRMData(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        acc.Local_CRM_Region__c = 'AMR';
        acc.Local_CRM_Country__c = 'CA - Canada';
        acc.Local_CRM_Name__c = 'FUS - Fusion';
        update acc;
        Contact cont1 = new Contact(Salutation='Mr',LastName = 'Test Contact',Email='Test@test123.com',
                AccountId=acc.Id);
        Test.startTest();
        Contact_Helper.populateLocalCRMData(new Contact[]{cont1});
        Test.stopTest();
        System.assert(cont1.Local_CRM_Name__c.equals(acc.Local_CRM_Name__c),'Contact should have Local CRM Name Set from Account');
        System.assert(cont1.Local_CRM_Country__c.equals(acc.Local_CRM_Country__c),'Contact should have Local CRM Country Set from Account');
        System.assert(cont1.Local_CRM_Region__c.equals(acc.Local_CRM_Region__c),'Contact should have Local CRM Region Set from Account');


    }
    @IsTest
    static void testAlignedHardBounce() {
        Contact ct1 = new Contact(FirstName='HardTest',LastName='BounceTest',Email='test@hardbounce.com',HardBounce__c = true,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200001))+Datetime.now().millisecond()));
        insert ct1;
        System.assert(ct1.HardBounce__c == true);
        Test.startTest();
        ct1.Email = 'testupdate@hardbounce.com';
        update ct1;
        Test.stopTest();
        ct1 = [SELECT FirstName, LastName,HardBounce__c FROM Contact WHERE FirstName='HardTest' AND LastName='BounceTest' AND Email='testupdate@hardbounce.com' LIMIT 1];
        System.assert(ct1.HardBounce__c == false);
    }
/*
/*    @isTest
    static void testPopulateNumAccountContacts_AddContact(){
        Account ac1 = [select Id,Number_of_contacts__c from Account where Name = 'Acc 1' LIMIT 1];

        Contact ct1 = [select Id,AccountId from Contact where FirstName = 'Cont add' and LastName = 'Testerson' LIMIT 1];
        System.assert(ac1.Number_of_contacts__c == 2, 'Numnber of contacts should be 2 but was ' + ac1.Number_of_contacts__c);

        Test.startTest();
        //add new contact
        ct1.AccountId = ac1.id;
        update ct1;
        Contact_Helper.populateNumAccountContacts(new Contact[]{ct1});
        Test.stopTest();
        //check it got added
        ac1 = [select Id,Number_of_contacts__c from Account where Name = 'Acc 1' LIMIT 1];
        System.assert(ac1.Number_of_contacts__c == 3, 'Numnber of contacts should be 3 but was ' + ac1.Number_of_contacts__c);

    }
*/
/*
    @isTest
    static void testPopulateNumAccountContacts_Delete(){
        Account ac1 = [select Id,Number_of_contacts__c from Account where Name = 'Acc 1' LIMIT 1];

        Contact ct1 = [select Id,AccountId from Contact where FirstName = 'Cont2' and LastName = 'Lumberson' LIMIT 1];
        System.assert(ac1.Number_of_contacts__c == 2, 'Numnber of contacts should be 2 but was ' + ac1.Number_of_contacts__c);

        Test.startTest();
        //remove  contact

        delete ct1;
        Contact_Helper.populateNumAccountContacts(new Contact[]{ct1});
        Test.stopTest();
        //check it got added
        ac1 = [select Id,Number_of_contacts__c from Account where Name = 'Acc 1' LIMIT 1];
        System.assert(ac1.Number_of_contacts__c == 1, 'Numnber of contacts should be 1 but was ' + ac1.Number_of_contacts__c);

    }
*/
    static RecordType rt = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'Partner_Account'];
    static testMethod void createContacts()
    {
        Account acc = new Account(Name = 'TestAccount', BillingStreet = 'Test Street', BillingCity = 'Manville', 
                                  BillingState = 'New Jersey', BillingPostalCode = '08807', 
                                  BillingCountry = 'United States', Sales_Office__c = 'Atlanta CBC', Phone = '234-456-6789',
                                  RecordTypeId = rt.Id,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100000))+Datetime.now().millisecond()));
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ; i<5; i++)
        {
           Contact c = new Contact(HasOptedOutOfEmail=true, Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com',
                                   AccountId=acc.Id,  MailingCity = 'Atlanta', MailingStreet ='Technology Dr',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200006))+Datetime.now().millisecond())); 
           contacts.add(c);
        }
        
        insert contacts;
        RecursiveTriggerHandler.isFirstTime = true;
        contacts[0].FirstName = 'Test';
        update contacts[0];
        RecursiveTriggerHandler.isFirstTime = true;
        Contact_Helper.updateEmailOptOutLMT(contacts);
    }
    
    @IsTest
    static void testSyncCommunicationPreferences() {       
        System.debug('ContactCustomTriggerTest: testSyncCommunicationPreferences START');
        
        // Set up test data
        List<Contact> contacts = new List<Contact>();
        Contact con1 = new Contact(LastName='CONTACT1',Allow_Call__c='No',Allow_Mail__c='No',Allow_Email__c='No',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200001))+Datetime.now().millisecond()));
        Contact con2 = new Contact(LastName='CONTACT2',DoNotCall=true,Do_Not_Mail__c=true,HasOptedOutOfEmail=true,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200002))+Datetime.now().millisecond()));
        Contact con3 = new Contact(LastName='CONTACT3',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200003))+Datetime.now().millisecond()));
        Contact con4 = new Contact(LastName='CONTACT4',Allow_Call__c='Yes',Allow_Mail__c='Yes',Allow_Email__c='Yes',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200004))+Datetime.now().millisecond()));
        contacts.add(con1);
        contacts.add(con2);
        contacts.add(con3);
        contacts.add(con4);
        
        // On insertion, we should see field updates via the Contact trigger
        Test.startTest();
        // INSERT
        insert contacts;
        Contact retCon1 = [SELECT Id, DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail, Allow_Call__c, Allow_Mail__c, Allow_Email__c
                           FROM Contact WHERE LastName='CONTACT1'][0];
        System.assertEquals(true, retCon1.DoNotCall);
        System.assertEquals(true, retCon1.Do_Not_Mail__c);
        System.assertEquals(true, retCon1.HasOptedOutOfEmail);
        Contact retCon2 = [SELECT Id, DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail, Allow_Call__c, Allow_Mail__c, Allow_Email__c 
                           FROM Contact WHERE LastName='CONTACT2'][0];
        System.assertEquals('No', retCon2.Allow_Call__c);
        System.assertEquals('No', retCon2.Allow_Mail__c);
        System.assertEquals('No', retCon2.Allow_Email__c);
        Contact retCon3 = [SELECT Id, DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail, Allow_Call__c, Allow_Mail__c, Allow_Email__c 
                           FROM Contact WHERE LastName='CONTACT3'][0];
        System.assertEquals(false, retCon3.DoNotCall);
        System.assertEquals(false, retCon3.Do_Not_Mail__c);
        System.assertEquals(false, retCon3.HasOptedOutOfEmail);
        System.assertEquals(null, retCon3.Allow_Call__c);
        System.assertEquals(null, retCon3.Allow_Mail__c);
        System.assertEquals(null, retCon3.Allow_Email__c);
        Contact retCon4 = [SELECT Id, DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail, Allow_Call__c, Allow_Mail__c, Allow_Email__c 
                           FROM Contact WHERE LastName='CONTACT4'][0];
        System.assertEquals(false, retCon4.DoNotCall);
        System.assertEquals(false, retCon4.Do_Not_Mail__c);
        System.assertEquals(false, retCon4.HasOptedOutOfEmail);
        
        // Test updates
        List<Contact> contacts2 = new List<Contact>();
        retCon1.Allow_Call__c = 'Yes';
        retCon1.Allow_Mail__c = null;
        retCon1.Allow_Email__c = 'Yes';
        retCon2.DoNotCall = false;
        retCon2.Do_Not_Mail__c = false;
        retCon2.HasOptedOutOfEmail = false;
        retCon3.Allow_Call__c = null;
        retCon3.Allow_Mail__c = null;
        retCon3.Allow_Email__c = null;
        retCon3.DoNotCall = true;
        retCon3.Do_Not_Mail__c = true;
        retCon3.HasOptedOutOfEmail = true;
        retCon4.Allow_Call__c = 'No';
        retCon4.Allow_Mail__c = 'No';
        retCon4.Allow_Email__c = 'No';
        contacts2.add(retCon1);
        contacts2.add(retCon2);
        contacts2.add(retCon3);
        contacts2.add(retCon4);
        // UPDATE HERE
        update contacts2;
        Contact retCon5 = [SELECT DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail FROM Contact WHERE LastName='CONTACT1'][0];
        System.assertEquals(false, retCon5.DoNotCall);
        System.assertEquals(false, retCon5.Do_Not_Mail__c);
        System.assertEquals(false, retCon5.HasOptedOutOfEmail);
        Contact retCon6 = [SELECT Allow_Call__c, Allow_Mail__c, Allow_Email__c FROM Contact WHERE LastName='CONTACT2'][0];
        System.assertEquals('Yes', retCon6.Allow_Call__c);
        System.assertEquals('Yes', retCon6.Allow_Mail__c);
        System.assertEquals('Yes', retCon6.Allow_Email__c);
        Contact retCon7 = [SELECT DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail, Allow_Call__c, Allow_Mail__c, Allow_Email__c 
                           FROM Contact WHERE LastName='CONTACT3'][0];
        System.assertEquals(true, retCon7.DoNotCall);
        System.assertEquals(true, retCon7.Do_Not_Mail__c);
        System.assertEquals(true, retCon7.HasOptedOutOfEmail);
        System.assertEquals('No', retCon7.Allow_Call__c);
        System.assertEquals('No', retCon7.Allow_Mail__c);
        System.assertEquals('No', retCon7.Allow_Email__c);
        Contact retCon8 = [SELECT DoNotCall, Do_Not_Mail__c, HasOptedOutOfEmail FROM Contact WHERE LastName='CONTACT4'][0];
        System.assertEquals(true, retCon8.DoNotCall);
        System.assertEquals(true, retCon8.Do_Not_Mail__c);
        System.assertEquals(true, retCon8.HasOptedOutOfEmail);
        Test.stopTest();
 
        System.debug('ContactCustomTriggerTest: testSyncCommunicationPreferences FINISH');
    }
    /*
    @isTest
    public static void UpdateStartDateBasedOnFoundationEligibilityTest(){
        Map<Id, Contact> oldContacts=new Map<Id, Contact>();
        Account acc = new Account();  
        acc.Name = 'TestAccount';
        acc.Type='Partner';
        acc.Phone='9999999999';
        insert acc;
		Contact con = new Contact(); 
        con.AccountId=acc.Id;
        con.LastName = 'TestContact';
        con.Email='testuser@yopmail.com';
        con.Foundation_Customer__c='Approved';       
        Test.startTest();
          try
            {
               insert con;
                List<Contact> contacts=[select id,LastName,Eligibility_Start_Dateone__c,Foundation_Customer__c from Contact where id=:con.Id];
                Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts);
                System.assertEquals(System.today(), contacts[0].Eligibility_Start_Dateone__c);
            }
            catch(Exception e)
            {
                System.debug('Exception '+ e.getMessage());
            }        
        Test.stopTest();
        oldContacts.put(con.Id,con);
        con.Foundation_Customer__c='Expired';
        update con;      
        List<Contact> contacts=[select id,LastName,Eligibility_Start_Dateone__c,Foundation_Customer__c from Contact where id=:con.Id];
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts);
        con.Foundation_Customer__c='Rejected';
        update con;      
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts);
        oldContacts.put(con.Id,con);
        con.Foundation_Customer__c='Approved';
        update con;
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts);
        oldContacts.put(con.Id,con);
        con.Foundation_Customer__c='Rejected';
        update con;
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts); 
        oldContacts.put(con.Id,con);
        con.Foundation_Customer__c='Approved';
        update con;
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts, oldContacts); 
        Contact con2 = new Contact(); 
        con2.AccountId=acc.Id;
        con2.LastName = 'TestContact';
        con2.Email='testuser@yopmail.com';
        con2.Foundation_Customer__c='Expired';
        insert con2;
        List<Contact> contacts2=[select id,LastName,Eligibility_Start_Dateone__c,Foundation_Customer__c from Contact where id=:con2.Id];
        Contact_Helper.UpdateStartDateBasedOnFoundationEligibility(contacts2, oldContacts);
    }
*/
     @isTest
    public static void updateFoundationFieldsFromAccountTest(){
        Account acc = new Account();  
        acc.Name = 'TestAccount';
        acc.Type='Partner';
        acc.Phone='9999999999';
        acc.Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100001))+Datetime.now().millisecond());
        insert acc;
		Contact con = new Contact(); 
        con.AccountId=acc.Id;
        con.LastName = 'TestContact';
        con.Email='testuser@yopmail.com';
        con.Foundation_Customer__c='Approved';
        con.Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200005))+Datetime.now().millisecond());      
        Test.startTest();
          try
            {
               insert con;
                List<Contact> contacts=[select id,Foundation_Customer__c from Contact where id=:con.Id];
                Contact_Helper.updateFoundationFieldsFromAccount(contacts);
            }
          catch(Exception e)
            {
                System.debug('Exception '+ e.getMessage());
            }        
        Test.stopTest();
    }
}