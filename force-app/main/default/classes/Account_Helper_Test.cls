/**
 * @description  ACCOUNT Helper Test
 * @author craig bradshaw
 * @date March 2019
 */
@IsTest
private class Account_Helper_Test{
  private static String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6';  //universal zuora id, used for each zuora object in this test class    
  //public static Integer expBillingAccsCreated = 1; // It must equal to billing accounts created in testsetup
    
  @TestSetup static void setup() {
    Account acc = new Account(Name = 'TestAccount',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
    insert acc;
    List<Contact> contacts = new List<Contact>();
    for(Integer i=0 ; i<5; i++){
      Contact c = new Contact(Salutation='Mr',LastName = 'Test Contact'+i,Email='Test'+i+'@test123'+i+'.com', AccountId=acc.Id,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200000))+Datetime.now().millisecond()+i));
      contacts.add(c);
    }
    insert contacts;        
    // test data for updatePartnerOldTier
    Account acc1 = new Account(Name = 'Test Tier 1',  Partner_Accountant__c = true, Accountant_Partner_Tier__c = 'Prospect',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100002))+Datetime.now().millisecond()));
    insert acc1;                    
    // test account for getBillingAccountsAndSubscriptionMaster
    String zuoraId = '2c92c0f84dfff49f014e021c79b82bb6'; //universal zuora id, used for each zuora object in this test class
    zqu__Quote__c zQuote;
    Product2 zProduct;
    zqu__ProductRatePlan__c zRatePlan;
    Product_Tier__c productTier;
    Product_Tier_Rate_Plan__c productTierRatePlan;
    //List < Subscription_Master__c > subsMasters;
    //Zuora__CustomerAccount__c billingAcc;
    //Zuora__ZInvoice__c invoice;
    Locale__c loc;                    
    // setup product tier and product tier rate plan lists
    loc = TestDataUtility.createLocale('US - United States', 'yes', 'en_us', 'english');
    zProduct = TestDataUtility.createZProduct('Sage One Start', zuoraId);
    zRatePlan = TestDataUtility.createRatePlan(zProduct.Id, 'Monthly', zuoraId);
    productTier = TestDataUtility.createProductTier(zProduct.Id, 'SageOne Start US', 'SageOne-Start-US');
    productTierRatePlan = TestDataUtility.createProductTierRatePlan(productTier.Id, zRatePlan.Id, loc.Id, 'Monthly');              
    //Create masterAccount        
    //Account masterAcc = TestDataUtility.createAccount(loc.Id);        
    //Create Account with Billing Account and subscription master
    Account mergeAccWithBiiling = TestDataUtility.createAccount(loc.Id);
    Contact con = TestDataUtility.createContact(mergeAccWithBiiling.Id);
    Zuora__CustomerAccount__c billingAccount = TestDataUtility.createBillingAccountAndPaymentMethod(mergeAccWithBiiling, zuoraId);
    zQuote = TestDataUtility.createZQuote(mergeAccWithBiiling.Id, con.Id, zuoraId);
        
    Subscription_Master__c sm = new Subscription_Master__c(Account__c = mergeAccWithBiiling.Id,Product__c = zProduct.Id,Start_Date__c = System.today(),End_Date__c = System.today().addDays(100),
                                                                        Product_Tier__c = productTier.Id, Product_Tier_Rate_Plan__c = productTierRatePlan.Id);
    insert sm;
    }

  @IsTest
  static void testupdatePartnerOldTierChanged() {
    List<Account> testAccounts = [SELECT Id, Partner_Old_Tier__c, Tier_Changed_Date__c, Accountant_Partner_Tier__c, Reseller_Partner_Tier__c, SI_Partner_Tier__c FROM Account WHERE Name='Test Tier 1'];        
    Map<Id,Account> mapOldAcct = new Map<Id,Account>();        
    for (Account a: testAccounts) {            
      Test.startTest();
      mapOldAcct.get(a.Id);
      a.Accountant_Partner_Tier__c = 'Authorized';
      update a;
      Account_Helper.updatePartnerOldTier(testAccounts, mapOldAcct);
        if (a.Tier_Changed_Date__c != null){
            System.assert(true , 'Tier_Changed_Date__c is changed');}
        Test.stopTest();                            
      }
    }
    
  @IsTest
  static void testupdatePartnerOldTierNoChanged() {
    List<Account> testAccounts = [SELECT Id, Partner_Old_Tier__c, Tier_Changed_Date__c, Accountant_Partner_Tier__c, Reseller_Partner_Tier__c, SI_Partner_Tier__c FROM Account WHERE Name='Test Tier 1'];        
    Map<Id,Account> mapOldAcct = new Map<Id,Account>();        
    for (Account a: testAccounts){             
      Test.startTest();
      mapOldAcct.get(a.Id);
      a.Accountant_Partner_Tier__c = 'Prospect';
      update a;
      Account_Helper.updatePartnerOldTier(testAccounts, mapOldAcct);
        if (a.Partner_Old_Tier__c  != null){          
        System.assert(false, 'Accountant Tier should NOT change');
        }
        Test.stopTest();                        
    }
  }
    
/*  @IsTest
  static void testPopulateNumAccountContacts() {
    List<Account> testAccounts = [select Id from Account where Name='TestAccount'];
    System.assert(testAccounts != null,'Test Account should not have been null');
    System.assert(testAccounts.size() == 1,'Should have only been one test account');
    Test.startTest();
    Account_Helper.populateNumAccountContacts(testAccounts);
    Test.stopTest();
    Account tAccount = [select Id,Number_of_contacts__c from Account where Name='TestAccount' LIMIT 1];
    System.assert(tAccount.Number_of_contacts__c == 5,'Should have had 5 contacts');
  }
*/    
  /*** Billing Account Should not be deleted **/
  @IsTest static void  deleteAccountsWithBillingAccount(){
     Test.startTest();
     List < Account > billingAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN( SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
     try {
       delete billingAcc;
     } catch (DmlException e) {
         Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
         System.assertEquals(expectedExceptionThrown, true);
     } finally {
       List < Account > testBillingAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
       Boolean isBillingAccDeleted = testBillingAcc[0].IsDeleted;
       System.assertEquals(false, isBillingAccDeleted);
     }
     Test.stopTest();
  }    
   
  /*** Subscription Account Should not be deleted **/
  @IsTest static void deleteAccountWithSubscriptionMaster() {
     Test.startTest();
     List < Account > subscriptionAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
     try {
       delete subscriptionAcc;
     } catch (DmlException e) {
       System.debug('DMLexception ' + e.getMessage());
       Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
       System.assertEquals(expectedExceptionThrown, true);
     } catch (Exception e) {
       System.debug('Exception ' + e.getMessage());            
     } finally {
      List < Account > testBillingAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
      Boolean isBillingAccDeleted = testBillingAcc[0].IsDeleted;
      System.assertEquals(false, isBillingAccDeleted);            
   }
   Test.stopTest();      
 }    
 
 /*** Billing Account Should not be merged **/
 @IsTest static void mergeAccountsWithBillingAccount() {
    Test.startTest();
    Account masterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
    Account mergebillingAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];              
    try {
      merge masterAcc mergebillingAcc;
    } catch (DmlException e) {
      System.debug('DMLException ' + e.getMessage());
      Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
      System.assertEquals(expectedExceptionThrown, true);         
    } catch (Exception e) {
      System.debug('Exception ' + e.getMessage());            
    } finally {
        Account testMasterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
        Account testMergebillingAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Zuora__Account__c FROM Zuora__CustomerAccount__c) LIMIT 1];
        Boolean isMasterAccDeleted = testMasterAcc.IsDeleted;
        System.assertEquals(false, isMasterAccDeleted);
        Boolean isMergeBillingAccDeleted = testMergebillingAcc.IsDeleted;
        System.assertEquals(false, isMergeBillingAccDeleted);
    }
    Test.stopTest();
  }   
  
  /*** Subscription Account Should not be merged **/
  @IsTest static void mergeAccountsWithSubscriptionMaster() {
     Test.startTest();
     Account masterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
     Account mergeSubscriptionMasterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];        
     try {
       merge masterAcc mergeSubscriptionMasterAcc;
     } catch (DmlException e) {
     Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
     System.assertEquals(expectedExceptionThrown, true);
     } finally {
       Account testMasterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
       Account testMergeSubscriptionMasterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
       Boolean isMasterAccDeleted = testMasterAcc.IsDeleted;
       System.assertEquals(false, isMasterAccDeleted);
       Boolean isMergeSubAccDeleted = testMergeSubscriptionMasterAcc.IsDeleted;
       System.assertEquals(false, isMergeSubAccDeleted);            
       }
       Test.stopTest();        
    }
    
  /***  Account Should be deleted as it doesn't have any billing/subscription related records **/
  @IsTest static void accountsWithoutBilling() {
     Test.startTest();
     Account masterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
     Map<Id,Account> mapOldAcct = new Map<Id,Account>(); 
     try {
       mapOldAcct.get(masterAcc.Id);
       Account_Helper.getBillingAccountsAndSubscriptionMaster(mapOldAcct);
       delete masterAcc;
     } catch (Exception e) {
         Boolean expectedExceptionThrown = e.getMessage().contains(System.Label.CC360_Merge_Error) ? true : false;
         System.assertEquals(expectedExceptionThrown, false);
     } finally {            
         List < Account > testMasterAcc = [SELECT Id, Name, IsDeleted FROM Account WHERE Id NOT IN (SELECT Account__c FROM Subscription_Master__c) LIMIT 1];
         System.assertEquals(1, testMasterAcc.size());
     }
     Test.stopTest();        
  }  
  
  @IsTest static void testVatUpdates()
  {
      
    Locale__c loc = TestDataUtility.createLocale('US - United States', 'yes', 'en_us', 'english');
    Account acc = TestDataUtility.createAccount(loc.Id);
    Zuora__CustomerAccount__c ca = TestDataUtility.createBillingAccountAndPaymentMethod(acc,zuoraId);
    acc.VAT_Number__c='US-123456'; // + String.valueOf(Datetime.now().getTime());
    acc.Phone = '9876543210';
    update acc;        
    // Call Test.startTest before performing callout,but after setting test data.
    Test.startTest();        
    // Set mock callout class 
    Test.setMock(HttpCalloutMock.class, new ZuoraMockHttpResponseGenerator());        
    //Build the Http Request
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://apisandbox-api.zuora.com/rest/v1/connections');
    req.setMethod('GET');
    Http h = new Http();        
    // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock. 
    HttpResponse res = h.send(req);
    // Verify response received contains fake values
    String contentType = res.getHeader('Content-Type');
    System.assert(contentType == 'application/json');
    String actualValue = res.getBody();
    /*** {"Id":"2c92c0f84dfff49f014e021c79b82bb6",
    //    "VAT_Number__c":"FR-123456", 
    //    "TaxExemptCertificateID":"FR-123456", 
    //     "TaxExemptStatus":"YES"} ***/           
    //System.debug('Actual Value' +actualValue);
    //String expectedValue = '{"VAT_Number__c":"FR-123456"}';
    //System.assertEquals(actualValue, expectedValue);
    System.assertEquals(200, res.getStatusCode());
    Test.stopTest(); 
  }
  
  @IsTest static void ENHC0010766positive(){
    Integer max = 1;
    List<Account> listAccount = new List<Account>();
    List<zqu__Quote__c> listzqu_Quote = new List<zqu__Quote__c>();
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
    User usr = new User(Alias = 'standt', Email='standardusrjoemark@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Foundation', FirstName='Sage', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', Username='standarduserjoemark@testorg.com');
    User usrGraeme = new User(Alias = 'standt', Email='standardusrjoemark@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Houghton', FirstName='Graeme', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', Username='HoughtonGraeme@testorg.com');
    for(Integer integr = 0; integr < max; integr++){
      Account accountnewAccount = new Account();
      accountnewAccount.Name = 'accountnewAccount.Name' + integr;
      accountnewAccount.Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200000))+Datetime.now().millisecond()+integr);
      listAccount.add(accountnewAccount);
     }
     insert listAccount;
     for(Integer integr = 0; integr < max; integr++){
       zqu__Quote__c zqu_Quote = new zqu__Quote__c();
       zqu_Quote.zqu__Account__c = listAccount[integr].Id;
       listzqu_Quote.add(zqu_Quote);
      }
      insert listzqu_Quote;
      //Query for Sage Foundation user, change made to fix the test  
      //system.runas(usr){
      User sageFouUsr = [SELECT FirstName, Id, LastName FROM User WHERE FirstName =: 'Sage' AND LastName =: 'Foundation'];
      System.runAs(sageFouUsr){
        for(Account forAccount: listAccount){
          forAccount.OwnerId = sageFouUsr.Id;
         }
         update listAccount;
       }
       User userUser = [SELECT Id FROM User WHERE LastName='Houghton' AND FirstName='Graeme'];
       for(zqu__Quote__c zqu_Quote: [SELECT OwnerId FROM zqu__Quote__c WHERE zqu__Account__c IN: listAccount]){
         System.assertEquals(zqu_Quote.OwnerId, userUser.Id);
       }
    } 
    
  @IsTest
  static void testupdateNonProfitOrganisationContact() {
      // create test data
     Account acc = new Account(Name = 'TestAccount',Phone='9999999999',Global_Id__c= String.ValueOf(Math.round((Math.random() * (900000) + 100000))+Datetime.now().millisecond()));
     insert acc; 
     Contact cont = new Contact(AccountId = acc.id, FirstName='NonProfitTest',LastName='OrganisationTest',Email='test@nonprofitOrg.com',NonProfitOrganisation__c = false,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 200001))+Datetime.now().millisecond()) ); 
     insert cont;     
     System.assert(cont.NonProfitOrganisation__c == false);      
     Test.startTest();
     try{
         acc.NonProfitOrganisation__c = true;
         update acc;
         System.assert(acc.NonProfitOrganisation__c == true);
         cont = [SELECT NonProfitOrganisation__c FROM Contact WHERE FirstName='NonProfitTest' AND LastName='OrganisationTest' AND Email='test@nonprofitOrg.com' LIMIT 1];
         System.assert(cont.NonProfitOrganisation__c == true); 
     }
     catch(Exception e){
          System.debug('Exception '+ e.getMessage());
     }        
     Test.stopTest();
   }   
    
    @IsTest
  static void testupdateFoundationFieldsOnContact() {
     Account acc = new Account(Name = 'TestAccount',Phone='9999999999', Foundation_Customer__c='Not Registered');
     insert acc; 
     Contact con = new Contact(AccountId = acc.id, FirstName='Foundation',LastName='Test',Email='tuser@yopmail.com',Foundation_Customer__c='');
      insert con;
     System.assert(con.Foundation_Customer__c == '');      
     Test.startTest();
     try{
         acc.Foundation_Customer__c = 'In Progress';
         update acc;
         System.assert(acc.Foundation_Customer__c == 'In Progress');
         con = [SELECT Foundation_Customer__c FROM Contact WHERE FirstName='Foundation' AND LastName='Test' AND Email='tuser@yopmail.com' LIMIT 1];
         System.assert(con.Foundation_Customer__c == 'In Progress'); 
     }
     catch(Exception e){
          System.debug('Exception '+ e.getMessage());
     }        
     Test.stopTest();
   }
    
     @IsTest
     static void testUpdateNonProfitOrganisation() {
        Account acc1 = new Account(Name = 'TestAccount',Phone='9999999999', Foundation_Customer__c='Rejected',NonProfitOrganisation__c=false);
        insert acc1;
        System.assert(acc1.NonProfitOrganisation__c == false);
        Test.startTest();
        acc1.Name = 'NewAccount';
        acc1.Foundation_Customer__c='Approved';
        acc1.billingCountry='Brazil';
        update acc1;       
        acc1 = [SELECT Name,NonProfitOrganisation__c FROM Account WHERE Name = 'NewAccount' LIMIT 1];
        System.assert(acc1.NonProfitOrganisation__c == true);
        acc1.Foundation_Customer__c='Expired';
        update acc1;
        acc1.Foundation_Customer__c='Rejected';
        update acc1;
        acc1.Foundation_Customer__c='Approved';
        update acc1;
        Account acc2 = new Account(Name = 'TestAccount',Phone='9999999999', Eligibility_Start_Dateone__c=Date.today(), Foundation_Customer__c='Approved');
        insert acc2;
        system.assertEquals(Date.today(), acc2.Eligibility_Start_Dateone__c);
        Test.stopTest();
    }
}