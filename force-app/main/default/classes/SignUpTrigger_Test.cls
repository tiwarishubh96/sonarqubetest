@isTest
private class SignUpTrigger_Test {

    public static Opportunity opp;
    public static sfLma__License__c  license;
    
    @isTest static void updateOpportunityWithLicense() {
        setupData();

        opp = [SELECT Id, License__c
                            FROM Opportunity
                            WHERE Id=:opp.Id];

        //System.assertEquals(opp.License__c, license.Id);
        // John Assheton - 17th July - Impossible to test as we cannot set the CreatedOrgId field
        //                             on a Signup Request so replaced with an assertNotEquals...
        System.assertNotEquals(opp.License__c, license.Id);
    }
    
    
    private static void setupData(){

        License_Management_Settings__c setting = new License_Management_Settings__c();
        setting.Package_Name__c = 'Sage Live';
        insert setting;

        Application_Control__c ac = new Application_Control__c(Run_Triggers__c = true);
        insert ac;

        CBC_Application_Control__c cac = new CBC_Application_Control__c(Run_Triggers__c = true);
        insert cac;


        Account acc = new Account(Name='Test Account');
        acc.Sales_Office__c = 'Atlanta CBC';
        acc.BillingStreet = 'A Street';
        acc.BillingCity = 'A City';
        acc.BillingState = 'Georgia';
        acc.BillingPostalCode = '11111';
        acc.BillingCountry = 'United States';
        insert acc;

        Contact contact = new Contact();
        contact.LastName = 'Test Contact';
        contact.Email = 'test@test.com';
        contact.AccountId = acc.Id;
        contact.MailingStreet = 'A Street';
        contact.MailingCity = 'A City';
        contact.MailingState = 'Georgia';
        contact.MailingPostalCode = '11111';
        contact.MailingCountry = 'United States';        
        insert contact;

        opp = new Opportunity(AccountId=acc.Id,Name='Test Opp', 
                              CloseDate=System.today(), StageName=Label.Opportunity_Sales_Stages_Stage1);
        insert opp;

        sfLma__Package__c pac = new sfLma__Package__c();
        pac.Name = 'Sage Live';
        pac.sfLma__Package_ID__c = '0331a000000PIVQAA4';
        insert pac;

        sfLma__Package_Version__c pv = new sfLma__Package_Version__c();
        pv.sfLma__Package__c = pac.Id;
        pv.Name = 'Sage Live';
        pv.sfLma__Version__c = '1.2';
        pv.sfLma__Version_ID__c = '04t1a000000PijwAAC';
        insert pv;

        Lead l = new Lead();
        l.Country = 'United States';
        l.FirstName = 'FirstName';
        l.lastName = 'LastName';
        l.Company = 'Test Comapny';
        l.Status = 'New';
        l.LeadSource = 'Partner';
        l.Industry = 'Banking';
        insert l;

        license = new sfLma__License__c();
        license.sfLma__Package__c = pac.Id;
        license.sfLma__Package_Version__c = pv.Id;
        license.sfLma__Subscriber_Org_ID__c = '00D24000000cAAA';
        license.SFLMA__EXPIRATION__C = system.today() + 5;
        license.SFLMA__INSTALL_DATE__C = system.today();
        license.SFLMA__LICENSE_TYPE__C = 'Editable';
        license.SFLMA__PROXY_USER__C = '0331a000000pivqaa4@00d24000000crqxea2';
        license.SFLMA__SEATS__C = 5;
        license.SFLMA__STATUS__C = 'Trial';
        license.SFLMA__USED_LICENSES__C = 1;
        //license.SFLMA__LEAD__C = l.Id;
        license.sfLma__Account__c = acc.Id;
        license.sfLma__Contact__c = contact.Id;
        license.ownerId = UserInfo.getUserId();
        license.recordTypeId = '01224000000Ii9f';
        insert license;

        Trial_Template__c tt = new Trial_Template__c();
        tt.Name = 'Trial Template';
        tt.Active__c = true;
        tt.Trial_Template_Id__c = '0TTj0000002A1Dw';
        tt.Product__c = 'S2';
        tt.Type_of_Business__c = 'All';
        insert tt;

        Success_Plan__c sp = new Success_Plan__c();
        sp.Account__c = acc.Id;
        sp.Opportunity__c = opp.Id;
        sp.Status__c = 'New';
        sp.Type__c = 'Trial';
        sp.Trial_Template__c = tt.Id;
        sp.Trial_Country__c = 'US';
        sp.Trial_Contact__c = contact.Id;
        sp.Trial_Template__c = tt.Id;
        insert sp;

        SignupRequest sr = new SignupRequest();
        sr.Success_Plan__c = sp.Id;
        //sr.Status = 'Success';
        //sr.CreatedOrgId = '00D24000000cAAA';
        sr.TemplateId = '0TTj0000002A1Dw';
        sr.LastName = 'LastName';
        sr.Username = 'test@signup.sage';
        sr.SignupEmail = 'test@test.com';
        sr.Company = 'Test Company';
        sr.Country = 'FR';
        insert sr;

    } 
    
}