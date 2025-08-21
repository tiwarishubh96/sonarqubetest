@isTest
public class ZuoraPaymentPageUtilityTest {
    public static ZuoraPaymentPageSetting__c zif;
    private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class
    
    static {
        // setup custom settings
        List<ZuoraPaymentPageSetting__c> zifList=new List<ZuoraPaymentPageSetting__c>();
        // for v1.0
        zifList.add(new ZuoraPaymentPageSetting__c(Name='testPage1', SFPageKey__c='testPage1', ppPageRef__c='', ppTenantID__c='tenID9',
                                                   ppApiSecurityKey__c='123456', ppPageID__c='testPgeId987'));
        // for V2.0
        zifList.add(new ZuoraPaymentPageSetting__c(Name='testPage2', SFPageKey__c='ACH', ppPageRef__c='/apps/PublicHostedPageLite.do', 
                                                   ppDomain__c='https://apisandbox-api.zuora.com',ppSignaturePath__c ='/rest/v1/rsa-signatures', 
                                                   ppPageID__c='pageId123ACH',apiAccessID__c='testID',apiAccessKey__c='testKey'));
        zifList.add(new ZuoraPaymentPageSetting__c(Name='testPage3', SFPageKey__c='CreditCard', ppPageRef__c='/apps/PublicHostedPageLite.do', 
                                                   ppDomain__c='https://apisandbox-api.zuora.com',ppSignaturePath__c ='/rest/v1/rsa-signatures', 
                                                   ppPageID__c='pageId123CC',apiAccessID__c='testID',apiAccessKey__c='testKey'));
        insert zifList;
		//
		// hosted page setting for payment ID account updates
        delete [select id from zqu__HostedPageLiteSetting__c]; // delete existing records because SeeAllData=true
		zqu__HostedPageLiteSetting__c hostedPage=new zqu__HostedPageLiteSetting__c(Name='Customer Community Credit Card',zqu__ComponentName__c='PaymentPage',Client_Code__c = 'Community-SageOne',
                                                                                   zqu__PageId__c=zuoraId, zqu__PaymentMethodType__c='Credit Card', Country__c = 'US - United States',
                                                                                   Payment_Gateway_Name__c='testGateway', CurrencyIsoCode = 'USD');
        insert hostedPage;
        
        
    }
    // Payment Page V2.0 tests
    // - positive test
    static testmethod void testACHCreditCardRequest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PaymentPageSignatureMockREST());
        ZuoraPaymentPageUtility.SubscriptionPaymentPages subsPP=ZuoraPaymentPageUtility.loadSubscriptionPaymentPages();
        system.debug(subsPP);
        //system.assertEquals('SUCCESS',subsPP.ppACH.status);
        //system.assertEquals('pageId123ACH',subsPP.ppACH.zppPageID);
        //system.assertEquals('SUCCESS',subsPP.ppCreditCard.status);
        //system.assertEquals('pageId123CC',subsPP.ppCreditCard.zppPageID);
        Test.stopTest();
    }
    // - negative test
    static testmethod void testRequestSignatureFail() {
        
        locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
		Account acc = TestDataUtility.createAccount(loc.Id);
        
        Contact c = new Contact(FirstName='first', LastName='lastName', AccountId=acc.Id, Email = 'email12@gmail.com');
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
		insert c;
        User ccUser = CommunityUtilitiesTest.createPortalUser(c);
			
        
        Test.startTest();
        System.runAs( ccUser )
        {
            Test.setMock(HttpCalloutMock.class, new PaymentPageSignatureMockREST());
            ZuoraPaymentPageUtility.ZPaymentPage zpp=ZuoraPaymentPageUtility.requestSignatureV2('noPage');
            system.debug(zpp);
            system.assertNotEquals('SUCCESS',zpp.status);
        }
        Test.stopTest();
    }
    //
    // Payment Page V1.0 tests
    static testmethod void testIFrameParmGenerate() {
        ZuoraPaymentPageUtility zu=new ZuoraPaymentPageUtility();
        //
        // test - get page iframe src attribute
        String zifParm=zu.iFrameSrc('testPage1');
        system.assert(zifParm.containsIgnoreCase('tenID9'));
        //
        // store the signature
        String sig=zifParm.right(zifParm.indexOf('signature='));
        //
        // test - get same page src (should be cached) and check signature hasn't changed
        String zifParm2=zu.iFrameSrc('testPage1');
        String sig2=zifParm.right(zifParm2.indexOf('signature='));
        system.assertEquals(sig,sig2);
        //
        // test - refresh page and check new src signature was generated.
        String zifParmRefresh=zu.refreshIFrameSrc('testPage1');
        String sigNew=zifParmRefresh.right(zifParmRefresh.indexOf('signature='));
        system.assertNotEquals(sig,sigNew);
    }
    //
    // test payment ID processing to account
    @isTest(SeeAllData=true) //SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal settings of zuora.
    static void testPaymentIDProcessing(){
        Account acc = TestDataUtility.createAccount();
        Contact con = TestDataUtility.createContact(acc.Id);
       // Zuora__CustomerAccount__c bAccount = TestDataUtility.createBillingAccountAndPaymentMethod(acc, zuoraId);
        Zuora__CustomerAccount__c bAccount = createBillingAccount(acc.Id);
        
        // Get Admin user details to login and create the Community User
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // Create Community User for this Contact
        User communityUser;
        
        System.runAs ( thisUser ) {
            Profile p = [select Id,name from Profile where Name  ='Sage: Customer Community User' limit 1];          
            communityUser = new User(
                profileId = p.id, 
                username = 'testSageCpqzs@test.com', 
                email = 'test@test.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_GB', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'Europe/London', 
                alias='nuser', 
                lastname='lastname', 
                contactId = con.id
            );
            insert communityUser;      
        }
        test.startTest();
        
        // Login as Community User     
        System.runAs ( communityUser ) {
                ZuoraPaymentPageUtility.getApiStub();
                ZuoraPaymentPageUtility.processPaymentID(zuoraId);
        }
        Test.stopTest();
        //
        // check payment Id is set
        List<Zuora__CustomerAccount__c> baList = [select ElectronicPaymentMethodId__c, Zuora__Zuora_Id__c, Zuora__Account__r.Zuora_Country_Code__c from Zuora__CustomerAccount__c where Id = :bAccount.Id];
        system.debug('baList:'+baList[0]);
        system.assertEquals(zuoraId, baList[0].ElectronicPaymentMethodId__c);
    }

    @IsTest(SeeAllData=false) static void testRemoteLoadSubscriptionPaymentPages_returns_non_null()
    {
        Contact ccCon = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'Some', 'One', 'someone@example.com' );
        User ccUser = CommunityUtilitiesTest.createPortalUser( ccCon );

        Test.startTest();
            
            System.runAs( ccUser )
            {
                System.assertNotEquals( null, ZuoraPaymentPageUtility.loadPage('testPage1') );
            }
            
        Test.stopTest();
    }

    @IsTest(SeeAllData=false) static void test_getBaseUrl_returns_valid_url()
    {
        Test.startTest();
        
            System.assertNotEquals( null, ZuoraPaymentPageUtility.getBaseUrl() );
    
        Test.stopTest();
    }

    @IsTest(SeeAllData=false) static void testIsSubmitLimitReached()
    {
        Contact ccCon = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'Some', 'One', 'someone@example.com' );
        User ccUser = CommunityUtilitiesTest.createPortalUser( ccCon );
        
    
        Test.startTest();
        
            System.runAs( ccUser )
            {
                Boolean isLimitReached = ZuoraPaymentPageUtility.isSubmitLimitReached();
                System.assertEquals( false, isLimitReached);
            }
    
        Test.stopTest();
    }
    
    @IsTest(SeeAllData=false) static void testIncrementSubmitCount()
    {
        try {
            Security_Payment_Change_Settings__c settings = Security_Payment_Change_Settings__c.getInstance( UserInfo.getOrganizationId() );
            settings.Payment_Details_Submit_Limit__c = 1;
            upsert settings;
        } catch(Exception ex) { System.debug( LoggingLevel.ERROR, ex.getMessage() + '\n' + ex.getStackTraceString() ); }

        Contact ccCon = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'Some', 'One', 'someone@example.com' );
        User ccUser = CommunityUtilitiesTest.createPortalUser( ccCon );
    
        Test.startTest();
        
            System.runAs( ccUser )
            {
                Boolean isLimitReached = ZuoraPaymentPageUtility.incrementSubmitCount();
                System.assertEquals( true, isLimitReached, 'Limit: ' + ZuoraPaymentPageUtility.SUBMIT_LIMIT + ' Acc: ' + ZuoraPaymentPageUtility.ccAcc);
            }
    
        Test.stopTest();
    }
    
     @isTest 
    static void testGetPaymentMethods()
    {
       	locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
		Account acc = TestDataUtility.createAccount(loc.Id);
        
         Contact c = new Contact(FirstName='first', LastName='lastName', AccountId=acc.Id, Email = 'email12@gmail.com');
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
		insert c;
        User ccUser = CommunityUtilitiesTest.createPortalUser(c);
        
        Test.startTest();
            
            System.runAs( ccUser )
            {
                ZuoraPaymentPageUtility.getPaymentMethods();
            }
            
        Test.stopTest();
        
    }
    
   @isTest 
    static void TestHasPermission()
    {
        ZuoraPaymentPageUtility.hasPermission('Manage_Subscriptions');
    } 
   
    @isTest 
    static void TestZPaymentPage()
    {
        
        ZClient sigResult = new ZClient();
        
        ZClient.RESTCalloutResult restCalloutResult = new ZClient.RESTCalloutResult();
        restCalloutResult.statusCode = 200;
        restCalloutResult.success = true;
        restCalloutResult.responseBody = 'body';
        restCalloutResult.responseMap = new Map<String, Object>();
        restCalloutResult.responseMap.put('success',true);
        
		
        
        locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
		Account acc = TestDataUtility.createAccount(loc.Id);
        
         Contact c = new Contact(FirstName='first', LastName='lastName', AccountId=acc.Id, Email = 'email12@gmail.com');
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
		insert c;
        User ccUser = CommunityUtilitiesTest.createPortalUser(c);
        
        Test.startTest();
            
            System.runAs( ccUser )
            {
                ZuoraPaymentPageUtility.ZPaymentPage pay = new ZuoraPaymentPageUtility.ZPaymentPage(restCalloutResult, 'pageURI', 'pageId');
            }
            
        Test.stopTest();
        
        
    } 
    
    
     @IsTest(SeeAllData=false) static void testgetUserLocale()
    {
       locale__c loc = TestDataUtility.createLocale('US - United States', 'Yes', 'TestLocale', 'English');
		Account acc = TestDataUtility.createAccount(loc.Id);
        
        Contact c = new Contact(FirstName='first', LastName='lastName', AccountId=acc.Id, Email = 'email12@gmail.com');
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
		insert c;
        User ccUser = CommunityUtilitiesTest.createPortalUser(c);
    
        Test.startTest();
        
            System.runAs( ccUser )
            {
                ZuoraPaymentPageUtility.getUserLocale();
               
            }
    
        Test.stopTest();
    }
    
    /**
     * [createAccount creates new account in SFDC]
     * @return [new SFDC account]
     */
	private static Zuora__CustomerAccount__c createBillingAccount(Id accountId){      
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
        ca.Zuora__Zuora_Id__c = '2c92c0f94e001371014e02a0b2e749d6';
        ca.Zuora__Account__c = accountId; 
        insert ca;       
        System.debug('billingAccount Id created:'+ca.Id);
        return ca;
	}
    

}