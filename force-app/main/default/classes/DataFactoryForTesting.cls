@isTest
public class DataFactoryForTesting {
    public static Locale__c createLocale() {
        Locale__c testLoc = new Locale__c(Name='en_US', LanguageLocaleKey__c='en_US', CurrencyIsoCode='USD', Country__c = 'US - United States');
        insert testLoc;
        return testLoc;
    }

    public static Account createAccount(){
        Account acc = new Account();
        acc.Name = 'Bacon';
        acc.BillingCity = 'Atlanta';
        acc.BillingCountry = 'United States';  
        acc.BillingCountryCode = 'US';
        acc.BillingStreet ='Some Street';
        acc.BillingPostalCode = '30318';
        acc.BillingState = 'Georgia';
        acc.BillingStateCode = 'GA';
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.locale_billing_cc__c = 'US';
        acc.Type = 'partner';
        insert acc; 
        return acc;
    }

    public static Account createAccountWithLoc(Id locId){
        Account acc = new Account();
        acc.Name = 'Bacon';
        acc.BillingCity = 'Atlanta';
        acc.BillingCountry = 'United States';  
        acc.BillingCountryCode = 'US';
        acc.BillingStreet ='Some Street';
        acc.BillingPostalCode = '30318';
        acc.BillingState = 'Georgia';
        acc.BillingStateCode = 'GA';
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.locale_billing_cc__c = 'US';
        acc.Type = 'partner';
        acc.locale__c = locId;
        insert acc; 
        return acc;
    }

    public static Account createAccountLocNotEN(Id locId){
        Account acc = new Account();
        acc.Name = 'Bacon2';
        acc.BillingCity = 'Guadalajara';
        acc.BillingCountry = 'Spain';  
        acc.BillingCountryCode = 'ES';
        acc.BillingStreet ='321 Taco St';
        //acc.BillingPostalCode = '30318';
        //acc.BillingState = 'Georgia';
        //acc.BillingStateCode = 'GA';
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.locale_billing_cc__c = 'ES';
        acc.Type = 'partner';
        acc.locale__c = locId;
        insert acc; 
        return acc;
    }
   
    public static Contact createContact(Id accId){      
        Contact con = new Contact();
        con.firstName = 'john';
        con.lastName = 'galt';
        con.Email = 'w.vinnie.t@gmail.com';
        con.accountId = accId;
        con.MailingCity = 'New York';
        con.MailingCountry = 'United States';
        con.MailingStreet = 'Some Street';
        con.MailingPostalCode = '10082';
        con.MailingState = 'New York';
        con.Language__c = 'English';
        con.ELanguage__c = 'EN';
        
        insert con;
        return con;
    }
    

    //was 1st used on PartnerCommRegistrationEmailTest
    public static CommunityX__c createComm() {
        CommunityX__c comm = new CommunityX__c();
        comm.Name = 'Sage Partner Community';
        comm.CommunityId__c ='0DB2400000083TU';
        comm.Community_Base_Url__c = 'https://ecomm2dev-sagegroup.cs86.force.com/partner';
        comm.Invite_Page_Path__c ='JoinCommunityWithInvite';
        comm.Sage_SSO_Post_Register_Failure_Page__c = 'SageId_Registration_Failure';
        comm.Sage_SSO_Post_Register_Success_Page__c = 'SageId_Registration_Success';
        comm.Default_User_Profile__c = 'Sage: Partner Community Login User';
        comm.CurrencyIsoCode = 'USD';
         insert comm;
        return comm;
    }
  
    public static Community_Membership__c createCommMem(Id contId, Id commId) {
        Community_Membership__c cm = new Community_Membership__c();
        cm.Community__c = commId;
        cm.Contact__c = contId;
        //cm.Invite_Code__c = 'a1v7E000000hTwf-20170731203030Z';
        cm.Status__c = 'Invited';
        cm.CurrencyIsoCode = 'USD';
        insert cm;
        return cm;
    }

    public static User createUser(Id contactId) {
        Profile p = [SELECT Id FROM Profile WHERE Name=: Constants.PARTNER_COMMUNITY_PROFILE];
        User u = new User(Alias = 'standt', Email='baconbitsandsoda@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, ContactId = contactId,
                          TimeZoneSidKey='America/Los_Angeles', UserName='baconbitsandsoda@testorg.com');
        return u;
    }
    
    //terms & conditions
    public static void createTC_en_US(Locale__c localrec) {
        Terms_Conditions_Community__c TC = new Terms_Conditions_Community__c();
        TC.Title__c = 'Community Terms and conditions en_US';
        TC.Partner_Locale__c = localrec.Id;
        TC.Partner_Types__c = 'Reseller';
        TC.Partner_Agreement__c = 'On-line';
        TC.Active__c = true;
        TC.Community_Only__c = true;
        insert TC;
        //return TC;
    }
   
    public static void createPCL() {
        Partner_Community_Locale_Mapping__c pcl = new Partner_Community_Locale_Mapping__c();
        pcl.Name = 'US';
        pcl.Account_Locale__c = 'en_US';
        pcl.Contact_User_Locale__c = 'en_US';
        pcl.Country_Name__c = 'United States';
        pcl.ISO_Country_Code__c = 'US';
        insert pcl;
    }
    @testSetup static void createEmplate() {
        Id FolderId = [select id from folder where name = 'sage'].id;
        EmailTemplate e = new EmailTemplate (developerName = 'test', Body='Test',FolderId = FolderId, TemplateType= 'Text', Name = 'Partner Community Registration email'); 
        insert e; 
    }

    public static Case createCase(Contact c) {

        Case newCase = new Case();
        newCase.ContactId = c.Id;
        newCase.AccountId = c.AccountId;
        newCase.Origin = 'Web';
        newCase.Subject = 'Test Case';
        newCase.Type = 'Problem';
        insert newCase;
      
        System.debug('xxcasenew' + newCase);
        return newCase;

    }

    public static void createPartnerCommunityLocaleMapping() {

        Partner_Community_Locale_Mapping__c localeMapping = new  Partner_Community_Locale_Mapping__c();
        localeMapping.Name = 'US';
        localeMapping.Country_Name__c = 'United States of America (USA)';
        localeMapping.ISO_Country_Code__c = 'US';
        localeMapping.Contact_User_Locale__c = 'en_US';
        localeMapping.Account_Locale__c = 'en_US';
        insert localeMapping;



    }
}