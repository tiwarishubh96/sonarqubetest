/**
 * @Name		redirectToCommunityControllerTest
 * @Description Tests the throughput to Salesforce Communities.
 * @Created		05/12/16
 * @Author		Shion Earl-Krogseth (shion.earl-krogseth@sage.com/shion@hyrez.co.uk)
 */
@isTest
private class redirectToCommunityControllerTest {
			
	private static CommunityRedirectorSettings__c  COMMUNUTY_REDIRECT_SETTINGS; 
	private static final string  testProviderId =  '072165cc-2815-4b21-a527-eeb592441595'; 



	@isTest static void singlePositiveTestAsAuthenticatedUserFacebookProvider() {

		
		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Facebook', redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id),false);		
		testPageRef.getParameters().put('previousAccountContext',redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id));
        Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Facebook',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult: ' + pageRefResult);
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(TRUE, pageRefResult.getUrl().contains(EncodingUtil.urlDecode(testPageRef.getParameters().get('startURL'),'UTF-8')));
		}	
	}

	@isTest static void singleNegativeTestAsAuthenticatedUserFacebookProvider() {
		
		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Facebook1', '1234567890-=1234567890-=1234',false);		
		Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Facebook1',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();			
			//system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(FALSE, pageRefResult.getUrl().contains(COMMUNUTY_REDIRECT_SETTINGS.FacebookSSOURL__c));
		}
	}

	@isTest static void singlePositiveTestAsAuthenticatedUserGoogleProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Google', redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id),false);		
        testPageRef.getParameters().put('previousAccountContext',redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id));
        Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Google',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(TRUE, pageRefResult.getUrl().contains(EncodingUtil.urlDecode(testPageRef.getParameters().get('startURL'),'UTF-8')));
		}

	}

		@isTest static void singleNegativeTestAsAuthenticatedUserGoogleProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Google1', '1234567890-=1234567890-=1234',false);		
		Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Google1',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(FALSE, pageRefResult.getUrl().contains(COMMUNUTY_REDIRECT_SETTINGS.GoogleSSOURL__c));
		}

	}


	@isTest static void singlePositiveTestAsAuthenticatedUserSageIdProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('SageId', redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id),false);
        testPageRef.getParameters().put('previousAccountContext',redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id));
        Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('SageId',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(TRUE, pageRefResult.getUrl().contains(EncodingUtil.urlDecode(testPageRef.getParameters().get('startURL'),'UTF-8')));
		}
	}
	
	@isTest static void singlePositiveTestAsNotAuthenticatedUserSageIdProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('SageId', redirectToCommunityControllerTest.generateToken(testProviderId,null),false);
        testPageRef.getParameters().put('previousAccountContext',redirectToCommunityControllerTest.generateToken(testProviderId,null));
        Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('SageId',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(FALSE, pageRefResult.getUrl().contains(EncodingUtil.urlDecode(testPageRef.getParameters().get('startURL'),'UTF-8')));
		}
	}

	@isTest static void singleNegativeTestAsAuthenticatedUserSageIdProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);			
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('SageId1', '1234567890-=1234567890-=1234',false);
		Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();
		
		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('SageId1',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			System.assertEquals(FALSE, pageRefResult.getUrl().contains(COMMUNUTY_REDIRECT_SETTINGS.SageIdSSOURL__c));
		}
	
	}



	@isTest static void singlePositiveTestAsAuthenticatedUserSalesforceProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);			
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Salesforce', redirectToCommunityControllerTest.generateToken(testProviderId,UserInfo.getOrganizationId()),false);		
		testPageRef.getParameters().put('previousAccountContext',redirectToCommunityControllerTest.generateToken(testProviderId,acc.Id));		
        Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Salesforce',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			/* Implementation not yet completed
			System.assertEquals(TRUE, pageRefResult.getUrl().contains(EncodingUtil.urlDecode(testPageRef.getParameters().get('startURL'),'UTF-8')));
			*/
		}


	}

	@isTest static void singleNegativeTestAsAuthenticatedUserSalesforceProvider() {

		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference testPageRef = setupRedirectToCommunityTestPageRef('Salesforce1', '1234567890-=1234567890-=1234',false);		
		Test.setCurrentPage(testPageRef);
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('Salesforce1',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();
			system.debug('pageRefResult.getUrl(): ' + pageRefResult.getUrl());
			/* Implementation not yet completed
			System.assertEquals(TRUE, pageRefResult.getUrl().contains(COMMUNUTY_REDIRECT_SETTINGS.SalesforceSSOURL__c));
			*/
		}		
	}

	
	@isTest static void singleInvalidParametersTest() {
		
		COMMUNUTY_REDIRECT_SETTINGS = redirectToCommunityControllerTest.SetupTestCustomerSetting();
		Account acc = TestDataUtility.createAccount();
		Contact con = TestDataUtility.createContact(acc.Id);
		User testUser = redirectToCommunityControllerTest.salesforceCommunitiesUserTestProvider(con);	
		PageReference pageRef = setupRedirectToCommunityTestPageRef('Facebook', '1234567890-=1234567890-=1234',false);				
		Test.setCurrentPage(pageRef);
		pageRef.getParameters().put('idProvider','nonexistant');		
		Test.startTest();
		redirectToCommunityController test_redirectToCommunityController = new redirectToCommunityController();

		System.runAs(testUser) {
			
			SageUserIdentityProvider__c testProviderRecord = redirectToCommunityControllerTest.sageUserIdentityProvProvider('nonexistant',testProviderId,acc,UserInfo.getOrganizationId(),testUser);
			PageReference pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();						
			pageRef.getParameters().put('startUrl',null);			
			pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();				
			pageRef.getParameters().put('accountContext','1234null');			
			pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();				
			pageRef.getParameters().put('culture','en-XX');			
			pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();				
			pageRef.getParameters().put('sageIdRegion','na2');			
			pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();			
			pageRef.getParameters().put('isHelpPage','true22222');			
			pageRefResult = test_redirectToCommunityController.AuthenticateUserForCommunity();	
			
		}
	}


	//Helper methods
	private static PageReference setupRedirectToCommunityTestPageRef(string pidProvider, string paccountContext, Boolean IsHelp) {
		
		PageReference pageRef = Page.redirectToCommunity;
		
		//add  test querystring parameters.
		pageRef.getParameters().put('startUrl','/s/sage-one-home');
		pageRef.getParameters().put('idProvider',pidProvider);
		pageRef.getParameters().put('accountContext',paccountContext);
		pageRef.getParameters().put('sageIdRegion','na');
		pageRef.getParameters().put('culture','en-GB');
		if(IsHelp) {
			pageRef.getParameters().put('isHelpPage','true');	
		}
		

		return pageRef;

	}


	private static User salesforceCommunitiesUserTestProvider(Contact pContact) {

		Profile p = [SELECT Id FROM Profile WHERE Name='Sage: Customer Community User']; 
        User u = new User(Alias = 'commuser', Email='communitiesUSer@sage.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_GB', ProfileId = p.Id, 
            TimeZoneSidKey='Europe/London', UserName='communitiesuser@sage.com', ContactId= pContact.Id);

        return u;

	}
	private static User salesforceGuestCommunitiesUserTestProvider() {

		return [select id, name from User where userType = 'Guest' LIMIT 1]; //salesforce orgs have basic guest accounts setup by default.	

	}

	private static SageUserIdentityProvider__c sageUserIdentityProvProvider(string pProvider, string pProviderId, Account pAccount, Id pOrgId, User pUser) {

		SageUserIdentityProvider__c testProviderRecord = new SageUserIdentityProvider__c();
		testProviderRecord.Account__c = pAccount.Id;
		testProviderRecord.IdentityID__c = pProviderId;
		testProviderRecord.IdentityProvider__c = pProvider;
		testProviderRecord.User__c = pUser.Id;
		if(pProvider == 'Salesforce') {
			testProviderRecord.SFBridgeID__c = pAccount.Id + ':' + pProvider+ ':' + pOrgId;	
		} else {
			testProviderRecord.SFBridgeID__c = pAccount.Id + ':' + pProvider+ ':' + pProviderId;	
		}
		
		insert testProviderRecord; 
		//reload to ensure any triggers being used have effected data correctly.
		SageUserIdentityProvider__c returnTestProviderRecord = [select Account__c, IdentityID__c, IdentityProvider__c, User__c,SFBridgeID__c FROM  SageUserIdentityProvider__c WHERE Id = : testProviderRecord.Id];
		return returnTestProviderRecord;
	}		


	 private static List<Account> bulkCreateAccounts(Integer pCount){
        
	 	List<Account> accountCollection = new List<Account>();
	 	for (Integer i = 0; i < pCount; i++) {
		    Account acc = new Account();
	        acc.Name = 'acme' + i;
	        acc.BillingCity = 'Atlanta';
	        acc.BillingCountry = 'United States';  
	        acc.BillingCountryCode = 'US';
	        acc.BillingStreet ='Some Street' + i;
	        acc.BillingPostalCode = '30' + i; 
	        acc.BillingState = 'Georgia';
	        acc.BillingStateCode = 'GA';
	        acc.Sales_Office__c = 'Atlanta CBC';
	        acc.locale_billing_cc__c = 'US';
	        
	        accountCollection.add(acc);
		}
        
        insert accountCollection;          
        return accountCollection;
    }

    private static List<Contact> bulkCreateContactsForEachAccount(List<Account> pAccountCollection){
        
	 	List<Contact> contactCollection = new List<Contact>();
	 	for (Integer i = 0; i < contactCollection.size(); i++) {
		    Contact contact = new Contact();
		    contact.FirstName = 'John' + i;
		    contact.LastName = 'Smith' + i;
		    contact.Email = 'john' + i + '.' + 'smith' + i + '@sage.com';		    
	        contactCollection.add(contact);
		}        
        insert contactCollection;          
        return contactCollection;
    }

    private static CommunityRedirectorSettings__c SetupTestCustomerSetting() {
    	CommunityRedirectorSettings__c testCS = new CommunityRedirectorSettings__c();    	    	
    	testCS.DefaultErrorURL__c = 'defaulterrorpage';
    	testCS.DefaultErrorURL__c = 'defaulterrorpage';
    	testCS.FacebookSSOURL__c = 'CBCCommunityFacebook';
    	testCS.GoogleSSOURL__c = 'CBCCommunityGoogle'; 
    	testCS.SageIdSSOURL__c = 'CBCCommunitySageID'; 
    	testCS.SalesforceSSOURL__c = 'SageLiveCommunity'; 
    	testCS.SupportedSageRegionIds__c ='na;eu;';
    	testCS.Cultures__c = 'en-GB;en-US;de-DE;fr-FR;fr-CA;es-ES';
    	testCS.BaseURL__c = 'https://sage1dev-sagegroup.cs88.force.com/community';
    	insert testCS;
    	return testCS;
    }   

    private static string generateToken(string value1, string value2) {		
		string token = value1 + value2;
		token = token.toLowerCase();				
		Blob signature = Crypto.generateDigest('SHA1',Blob.valueof(token));            
		token = EncodingUtil.base64Encode(signature);
		return token;			
	}
}