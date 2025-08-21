@IsTest
public class CustCommLiveAgentButtonCtrlTest
{
   
    @IsTest(SeeAllData=false) static void testGetInitParams()
    {
        LiveChatDeployment depl = [SELECT Id, DeveloperName FROM LiveChatDeployment LIMIT 1];
        LiveChatButton btn = [SELECT Id, DeveloperName FROM LiveChatButton LIMIT 1];
        
		Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
   
        
        String productNameSageOne = 'Sage One';
        zqu__ZProduct__c zProduct = new zqu__ZProduct__c(zqu__ZuoraId__c = '5678',zqu__SKU__c = 'testSKU',Name='Sage One');
        insert zProduct;
        
        Subscription_Master__c subMaster = new Subscription_Master__c(Account__c=c.AccountId, Status__c='Trial',ZProduct__c=zProduct.Id, Start_Date__c = System.now(), End_Date__c = System.now());
        insert subMaster;
        
        subMaster.Account__c = c.AccountId;
        upsert subMaster;
        
        System.debug('Subs masters'+[select Id,Status__c,Account__c from Subscription_Master__c where ZProduct__c=:zProduct.Id]);
        
        
			system.runAs(u){
            CustCommLiveAgentButtonCtrl.InitParams params = CustCommLiveAgentButtonCtrl.getInitParams(depl.DeveloperName, 'Sage One');
        	System.debug('Subs masters 2'+[SELECT Id,ZProduct__c FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Status__c = 'Trial']);
    
            }
        
        
        String productNameSageLive = 'Sage Live';
        zProduct.Name='SageLive';
        upsert zProduct;
        
        subMaster.ZProduct__c=zProduct.Id;
        upsert subMaster;
        
        subMaster.Account__c = c.AccountId;
        upsert subMaster;
        system.runAs(u){
            CustCommLiveAgentButtonCtrl.InitParams params = CustCommLiveAgentButtonCtrl.getInitParams(depl.DeveloperName, 'Sage Live');
        	System.debug('Subs masters 2'+[SELECT Id,ZProduct__c FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Status__c = 'Trial']);
            
            }
        
        Account a1 = createAccount('Account1','Dublin CBC');
        Contact c1 = createContact(a1, 'test', 'test', 'hasPermissionSet@sage.com');
        zProduct.Name='SageOne';
        upsert zProduct;
        
        subMaster.ZProduct__c=zProduct.Id;
        upsert subMaster;
        
        subMaster.Account__c = c1.AccountId;
        upsert subMaster;
        User sageOneFR = createPortalUser(c1.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'dfgdfgd@sage.com','fr');
			system.runAs(sageOneFR){
            CustCommLiveAgentButtonCtrl.InitParams params = CustCommLiveAgentButtonCtrl.getInitParams(depl.DeveloperName, 'Sage One');
        	System.debug('Subs masters 2'+[SELECT Id,ZProduct__c FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Status__c = 'Trial']);

            }
		Account a2 = createAccount('Account1','Dublin CBC');
        Contact c2 = createContact(a2, 'test', 'test', 'hasPermissionSet@sage.com');
        subMaster.Account__c = c2.AccountId;
        upsert subMaster;
        User sageOneDE = createPortalUser(c2.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'dfgdfgdft@sage.com','de');
			system.runAs(sageOneDE){
            CustCommLiveAgentButtonCtrl.InitParams params = CustCommLiveAgentButtonCtrl.getInitParams(depl.DeveloperName, 'Sage One');
        	System.debug('Subs masters 2'+[SELECT Id,ZProduct__c FROM Subscription_Master__c WHERE Account__c = :u.AccountId AND Status__c = 'Trial']);
     
            }
  
    }
    
    @IsTest(SeeAllData=false) static void testGetInitParamsWithSubscriptionProduct() {
        LiveChatDeployment depl = [SELECT Id, DeveloperName FROM LiveChatDeployment LIMIT 1];
        LiveChatButton btn = [SELECT Id, DeveloperName FROM LiveChatButton LIMIT 1];
        
		Contact con = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'James', 'Corden', 'jcorden@gmail.com');
        User u = CommunityUtilitiesTest.createPortalUser(con);
        Zuora__SubscriptionProductCharge__c subProd = new Zuora__SubscriptionProductCharge__c();
        subProd.Zuora__Account__c = con.AccountId;
        subProd.Zuora__ProductName__c = 'Sage Live';
         subProd.Name='abc';
        insert subProd;
        subProd.Zuora__Account__c = con.AccountId;
        upsert subProd;
        System.runAs(u) {
            CustCommLiveAgentButtonCtrl.getInitParams(depl.DeveloperName, 'Live');
        }
        
    }

    /**
     * @description Test the method to check if the current user is authenticated
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-14
     */
       Static  String ACCOUNT_NAME = 'Test Account';
    	 Static String ACCOUNT_OFFICE = 'Atlanta CBC';
     	  Static String ACCOUNT_CITY = 'New York';
         Static String ACCOUNT_COUNTRY = 'United States';
         Static String ACCOUNT_STATE = 'New York';
         Static String ACCOUNT_POSTAL_CODE = '12345';
         Static String ACCOUNT_STREET = 'Lot 49';
         Static String CONTACT_FIRST_NAME = 'Thomas';
         Static String CONTACT_LAST_NAME = 'Pynchon';
         Static String CONTACT_EMAIL = 'tpynch@somewhere.com';
         
        
    static {
          Account a = new Account(Name = ACCOUNT_NAME, Sales_Office__c = ACCOUNT_OFFICE, BillingCity = ACCOUNT_CITY, BillingCountry = ACCOUNT_COUNTRY,
                                BillingState = ACCOUNT_STATE, BillingStreet = ACCOUNT_STREET, BillingPostalCode = ACCOUNT_POSTAL_CODE);
          insert a;
          Contact c = new Contact(AccountId = a.Id, FirstName = CONTACT_FIRST_NAME, LastName = CONTACT_LAST_NAME, Email = CONTACT_EMAIL, MailingCity = ACCOUNT_CITY,
                                MailingState = ACCOUNT_STATE, MailingCountry = ACCOUNT_COUNTRY, MailingPostalCode = ACCOUNT_POSTAL_CODE, MailingStreet = ACCOUNT_STREET);
		  insert c;
        // Create a portal user
        User commUser = CommunityUtilitiesTest.createPortalUser(c);
    }
    
    
    @IsTest(SeeAllData=false) static void testIsAuthenticatedUser()
    {
        // Create a customer community user
        Contact authContact = CommunityUtilitiesTest.createAccountAndContact('Test Account', 'Auth', 'User', 'auth@example.com');
        User authenticatedUser = CommunityUtilitiesTest.createPortalUser(authContact);
        // Variable that will hold the value returned by the controller
        Boolean resultForAuthUser;
        Test.startTest();
            System.runAs(authenticatedUser){
                resultForAuthUser = CustCommLiveAgentButtonCtrl.isAuthenticatedUser();
            }
        Test.stopTest();
        // Verify that the correct boolean value is returned from the controller
        System.assertEquals(true, resultForAuthUser);
    }
    
    @isTest(SeeAllData=false)
    public static void hasPermissionForProductTestWithSubscriptionMaster()
    {
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        System.debug(u.Id +' '+ u.AccountId+' '+u.Name);
        zqu__ZProduct__c zProductSageOne = new zqu__ZProduct__c(zqu__ZuoraId__c = '5678',zqu__SKU__c = 'testSKU',Name='SageOne');
        insert zProductSageOne;
        //zqu__ZProduct__c zProductSageLive = new zqu__ZProduct__c(zqu__ZuoraId__c = '5678',zqu__SKU__c = 'testSKU',Name='SageLive');
        //insert zProductSageLive;
        
        
        Subscription_Master__c obj = new Subscription_Master__c(Account__c=c.AccountId, Status__c='Trial',ZProduct__c=zProductSageOne.Id, Start_Date__c = System.now(), End_Date__c = System.now());
        insert obj;
        
        obj.Account__c = c.AccountId;
        upsert obj;
        
        //Subscription_Master__c subMasterSageLive = new Subscription_Master__c(ZProduct__c=zProductSageLive.Id,Status__c = 'Trial',Account__c =u.AccountId);
 		//insert subMasterSageLive;
            System.runAs(u){
                Test.startTest();
                CustCommLiveAgentButtonCtrl.hasPermissionForProduct('One');
                Test.stopTest();
            } 
    }
    
 /*   @isTest
    public static void hasPermissionForProductTestWithSubscriptionProduct() {
        Contact con = CommunityUtilitiesTest.createAccountAndContact('Unknown Ltd', 'James', 'Corden', 'jcorden@gmail.com');
        User u = CommunityUtilitiesTest.createPortalUser(con);
        System.debug(u.Id +' '+ u.AccountId+' '+u.Name);
        Zuora__SubscriptionProductCharge__c subProd = new Zuora__SubscriptionProductCharge__c();
        subProd.Zuora__Account__c = con.AccountId;
        subProd.Zuora__ProductName__c = 'Sage Live';
        insert subProd;
        subProd.Zuora__Account__c = con.AccountId;
        upsert subProd;
        System.runAs(u){
                Test.startTest();
                CustCommLiveAgentButtonCtrl.hasPermissionForProduct('Live');
                Test.stopTest();
            }
    }*/
    
    public static User createPortalUser(Id contactId, String firstName, String lastName, String email, String username, String languageLocaleKey) {

        User u = new User();
        u.FirstName = firstName;
        u.lastName = lastName;
        u.username = username;
        u.alias = firstName;
        u.email = email;
        u.ProfileId = ([select id from profile where name = :Constants.CUSTOMER_COMMUNITY_PROFILE LIMIT 1]).Id;
        u.CurrencyIsoCode = 'USD';
        u.LanguageLocaleKey = languageLocaleKey;
        u.ContactId = contactId;
        u.TimeZoneSidKey = 'GMT';
		u.LocaleSidKey = languageLocaleKey+'_'+languageLocaleKey.toUpperCase();
		u.EmailEncodingKey = 'ISO-8859-1';
		
        insert u;
        return u;
    }
    
    public static Account createAccount(String accountName,String salesoffice) {
        Account a = new Account(name=accountName);
        a.BillingStreet='123 Main St';
        a.BillingCity='Norcross';
        a.BillingCountry='United States';
        a.BillingCountryCode='US';
        a.BillingState='Georgia';
        a.BillingPostalCode='30092';
        a.Sales_Office__c=salesoffice;
        insert a;
        return a;
    }
    
    public static Contact createContact(Account a,String firstName, String lastName, String email) {
        Contact c = new Contact(FirstName=firstName, LastName=lastName, AccountId=a.Id, Email = email);
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
		insert c;
        return c;
    }
    
}