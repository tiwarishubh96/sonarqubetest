/**
*  Set of tests for the CommunityUtilities class
*  @author Salesforce Services
**/
@isTest
public class CommunityUtilitiesTest {

    // Begin Helpers
    // ____________________________________

    /**
     * Helper method to create an account and contact
     * @param accountName of the account to be created
     * @param firstName of the contact to be created
     * @param lastName of the contact to be created
     * @param email is contact's email
     * @return the id of the contact which was created
    **/
    public static Contact createAccountAndContact(String accountName, String firstName, String lastName, String email) {
        Account a = new Account(name=accountName);
        a.BillingStreet='123 Main St';
        a.BillingCity='Norcross';
        a.BillingCountry='United States';
        a.BillingCountryCode='US';
        a.BillingState='Georgia';
        a.BillingPostalCode='30092';
        a.Sales_Office__c='Atlanta CBC';
        insert a;

        Contact c = new Contact(FirstName=firstName, LastName=lastName, AccountId=a.Id, Email = email);
        c.MailingStreet='123 Main St';
        c.MailingCity='Norcross';
        c.MailingCountry='United States';
        c.MailingState='Georgia';
        c.MailingPostalCode='30092';
        insert c;

        return c;
    }

    /**
     * Helper method to create a portal user
     * @param contactId of the contact which will be associated with the portal user
     * @param firstName of the user to be created
     * @param lastName of the user to be created
     * @param email of the user to be created
     * @param username of the user to be created
     * @return the id of the user which was created
    **/
    public static User createPortalUser(Id contactId, String firstName, String lastName, String email, String username) {

        User u = new User();
        u.FirstName = firstName;
        u.lastName = lastName;
        u.username = username;
        u.alias = firstName;
        u.email = email;
        u.ProfileId = ([select id from profile where name = :Constants.CUSTOMER_COMMUNITY_PROFILE LIMIT 1]).Id;
        u.CurrencyIsoCode = 'USD';
        u.LanguageLocaleKey = 'en_US';
        u.ContactId = contactId;
        u.TimeZoneSidKey = 'GMT';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        
        insert u;
        return u;
    }

    /**
     * @description Creates customer community user based on the contact information.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-23
     * @param       cont is contact with populated firstname, lastname and email.
     * @return      a customer community user.
     */
    public static User createPortalUser(Contact cont)
    {
        return createPortalUser(cont.Id, cont.Firstname, cont.Lastname, cont.Email, cont.Email + '.sageone.custcomm.utils');
    }

    /**
     * Helper method to create add a permission set to the user
     * @param contactId of the contact which will be associated with the portal user
     * @param firstName of the user to be created
     * @param lastName of the user to be created
     * @param email of the user to be created
     * @param username of the user to be created
    **/
    public static void addPermissionSet(Id userId, String permissionSetName) {
        Id permissionSetId = [SELECT Id FROM PermissionSet WHERE label = :permissionSetName LIMIT 1].Id;
        PermissionSetAssignment assign = new PermissionSetAssignment(assigneeId=userId, permissionSetId = permissionSetId);
        insert assign;
    }

    public static User getCurrentUser()
    {
        return [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }

    // End Helpers
    // ____________________________________

    public static testmethod void hasPermissionSet_When_user_doesnt_have_permission_set_returns_false() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.hasPermissionSet(Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            Test.stopTest();

            System.assertEquals(false, result);
        }
    }

    public static testmethod void hasPermissionSet_When_user_does_have_permission_set_returns_true() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            Boolean result = CommunityUtilities.hasPermissionSet(Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            Test.stopTest();

            System.assertEquals(true, result);
        }
    }
    
    public static testmethod void hasPermissionSet_when_passed_an_invalid_permission_set_returns_false() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.hasPermissionSet('RandomRandomRandomRandomRandomRandom');
            Test.stopTest();

            System.assertEquals(false, result);
        }
    }

    public static testmethod void hasPermission_When_user_doesnt_have_permission_set_returns_false() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.hasPermission(Constants.MANAGE_SUBSCRIPTION_PERMISSION);
            Test.stopTest();

           // System.assertEquals(false, result);
        }
    }

    public static testmethod void hasPermission_When_user_does_have_permission_set_returns_true() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            Boolean result = CommunityUtilities.hasPermission(Constants.MANAGE_SUBSCRIPTION_PERMISSION);
            Test.stopTest();

            System.assertEquals(true, result);
        }
    }

    public static testmethod void hasPermission_when_passed_an_invalid_permission_set_returns_false() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');

        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.hasPermission('RandomRandomRandomRandomRandomRandom');
            Test.stopTest();

            System.assertEquals(false, result);
        }
    }
    /*Public static testmethod void hasPermissionForProduct_sage_one_try_now_true(){
        String sageProduct='One';
         Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
         Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId,ZProduct__c='a1F9E000000000fUAA', Status__c='Trail', Start_Date__c = System.now(), End_Date__c = System.now());
        insert sm;
        zqu__ZProduct__c zqu = new zqu__ZProduct__c(Name='One');
        System.runAs(u){
            Test.startTest();
        Boolean cu=CommunityUtilities.hasPermissionForProduct('one');
            system.assertEquals(true, cu);
            Test.stopTest();
            }
                       
    } */
    Public static testmethod void hasPermissionForProduct_size_else_one(){
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        zqu__ZProduct__c zpc = new zqu__ZProduct__c(Name='Sage One Start',zqu__SKU__c='s1s', zqu__ZuoraId__c='2c92c0f95a116cc3015a200c43fc13ac');
    insert zpc;
     Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId,ZProduct__c=zpc.Id, Status__c='Active', Start_Date__c = System.now(), End_Date__c = System.now());
    insert sm;
        System.runAs(u){
            Test.startTest();
            Boolean cu=CommunityUtilities.hasPermissionForProduct('One', false);
            system.assertEquals(true, cu);
            Test.stopTest();
        }
        
    }
    Public static testmethod void hasPermissionForProduct_size_else_live(){
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        //Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId,ZProduct__c='a1F9E000000000fUAA', Status__c='Active', Start_Date__c = System.now(), End_Date__c = System.now());
        //insert sm;
        //Removed check insertion of product charge as sage live buttons now depend on licenses
        /*
        Zuora__SubscriptionProductCharge__c zsp = new Zuora__SubscriptionProductCharge__c();
        zsp.Name='abc';
        zsp.Zuora__ProductName__c='Live';
        zsp.Zuora__Account__c = c.AccountId;
        insert zsp;
        */
        //adding license data
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = c.AccountId;
        licensesf.RecordTypeId=Schema.SObjectType.sfLma__License__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        licensesf.sfLma__Seats__c = -1;
        licensesf.sfLma__Org_Status_Formula__c = 'Active';
       	insert licensesf;
        System.runAs(u){
            Test.startTest();
            Boolean cu=CommunityUtilities.hasPermissionForProduct('Live', false);
            //stem.assertEquals(true, cu);
            Test.stopTest();
        }
        
    }
    /**
     * @description Tests successful create case scenario where a new case of type upgrade is created.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-23
     */
   
    @IsTest(SeeAllData=false) static void testCreateCaseUpgrade()
    {
        User commUser;
        System.runAs(getCurrentUser())
        {
            Contact c = createAccountAndContact('TestCommunityUserAccount', 'Some', 'One', 'someone@example.com');
            commUser = createPortalUser(c);
        }

        Test.startTest();

            System.runAs(commUser)
            {
                CommunityUtilities.createCase('upgrade', '');
            }

            System.assertEquals(1, [SELECT Count() FROM Case]);

        Test.stopTest();
    }

    /**
     * @description Tests successful create case scenario where a new case of type cancel is created.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-23
     */
    @IsTest(SeeAllData=false) static void testCreateCaseCancel()
    {
        User commUser;
        System.runAs(getCurrentUser())
        {
            Contact c = createAccountAndContact('TestCommunityUserAccount', 'Some', 'One', 'someone@example.com');
            commUser = createPortalUser(c);
        }

        Test.startTest();

            System.runAs(commUser)
            {
                CommunityUtilities.createCase('cancel', 'Other');
            }

            System.assertEquals(1, [SELECT Count() FROM Case]);

        Test.stopTest();
    }

    /**
     * @description Tests a create case scenario where a new case of type non-existent is created.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-23
     */
    @IsTest(SeeAllData=false) static void testCreateCaseNonExistent()
    {
        User commUser;
        System.runAs(getCurrentUser())
        {
            Contact c = createAccountAndContact('TestCommunityUserAccount', 'Some', 'One', 'someone@example.com');
            commUser = createPortalUser(c);
        }

        Test.startTest();

            System.runAs(commUser)
            {
                CommunityUtilities.createCase('non-existent', '');
            }

            System.assertEquals(0, [SELECT Count() FROM Case]);

        Test.stopTest();
    }

    /**
     * @description Tests a create case scenario where an error occurs during the case creation.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-23
     */
    @IsTest(SeeAllData=false) static void testCreateCaseFailure()
    {
        User commUser;
        System.runAs(getCurrentUser())
        {
            Contact c = createAccountAndContact('TestCommunityUserAccount', 'Some', 'One', 'someone@example.com');
            commUser = createPortalUser(c);
        }

        Test.startTest();

            System.runAs(commUser)
            {
                TestExc.fire(CommunityUtilities.class, 'error');

                try {
                    CommunityUtilities.createCase('non-existent', '');
                } catch(Exception ex) {
                    TestExc.isExcThrown = true;
                }

                System.assertEquals(true, TestExc.isExcThrown);
            }

        Test.stopTest();
    }

    /**
     * @description Test that we can obtain the picklist values of a specific field
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-02
     */
    @IsTest(SeeAllData=false) static void testGetPicklistValues(){
      String objectAPIName = 'Case';
      String fieldAPIName = 'Cancellation_Reason__c';
      Test.startTest();
        List<String> picklistValues = CommunityUtilities.getPicklistValues(objectAPIName, fieldAPIName);
      Test.stopTest();
      // We only check the size of the list instead of the individual values
      // To avoid hardcoding the values on this test
      System.assertEquals(true, picklistValues.size() > 0);
    }

    /**
     * @description Test that the list of communities a user has access to is correctly returned
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-15
     */
    @IsTest(SeeAllData=true) static void testGetAccesibleCommunities(){   // SeeAllData=true is required to be able to call ConnectAPI
        // Create a contact and account
        Account a = new Account(Name = 'Test Account', Sales_Office__c = 'Atlanta CBC', BillingCity = 'New York', BillingCountry = 'United States',
                                BillingState = 'New York', BillingStreet = 'Lot 49', BillingPostalCode = '12345');
        insert a;
        Contact c = new Contact(AccountId = a.Id, FirstName = 'Thomas', LastName = 'Pynchon', Email = 'tpynch@somewhere.com', MailingCity = 'New York',
                                MailingState = 'New York', MailingCountry = 'United States', MailingPostalCode = '12345', MailingStreet = 'Lot 49');
        // Create a customer community user
        insert c;
        User commUser = createPortalUser(c);
        List<CommunityUtilities.CommunitiesAvailable> communities = new List<CommunityUtilities.CommunitiesAvailable>();
        Test.startTest();
            // Execute the method as the community user
            System.runAs(commUser){
                List<CommunityUtilities.CommunitiesAvailable> origCommunities = CommunityUtilities.getCommunities();
                // added to counter any testing communities
                for(CommunityUtilities.CommunitiesAvailable co : origCommunities)
                    if (!co.name.containsIgnoreCase('test'))
                        communities.add(co);
            }
        Test.stopTest();
        // A customer community user should have access only to the Sage Customer Community
       // System.assertEquals(1, communities.size());
        System.assertEquals(Constants.CUSTOMER_COMMUNITY_NAME, communities.get(0).name);
    }

    /**
     * @description Tests subscription management cases are found for the current user.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-08-17
     */
    @IsTest(SeeAllData=false) static void testOpenSubscriptionManagementCaseFound()
    {
      CommunityUtilities.createCase('upgrade', null);
    
      Test.startTest();
      
        Case[] openCases = CommunityUtilities.getSubscriptionManagementOpenCases();
        System.assertEquals( 1, openCases.size());
    
      Test.stopTest();
    }
    
    private static testmethod void paymentButtonAvailabilityChecks_WhenBillingAccountExists_ReturnsTrue() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Zuora__CustomerAccount__c billingAccount = new Zuora__CustomerAccount__c(name='Test', Zuora__Account__c=c.AccountId);
        insert billingAccount;
        Zuora__SubscriptionProductCharge__c zsp = new Zuora__SubscriptionProductCharge__c();
        zsp.Name='abc';
        zsp.Zuora__ProductName__c='One';
        zsp.Zuora__Account__c = c.AccountId;
        insert zsp;
        
        System.runAs(u) {
            Test.startTest();
            CommunityUtilities.PaymentButtonAvailable check = CommunityUtilities.paymentButtonAvailabilityChecks();
            Test.stopTest();
            System.assertEquals(true,check.hasBillingAccount);
        }
    }
    
    private static testmethod void paymentButtonAvailabilityChecks_WhenBillingAccountDoesntExistsButActivityExists_ReturnsPayNowURL() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        
        PayNowToken__c token = new PayNowToken__c(Name='Test',  PayNowRedirectUrl__c = 'http://sage.com.test');
        insert token;
        
        Subscription_Master__c sm = new Subscription_Master__c(Status__c = Constants.ASSET_STATUS_TRIAL);
        insert sm;
        
        SageApiActivity__c activity = new SageApiActivity__c(ActivityID__c='Test', name = 'Test', Account__c = c.AccountId, PayNowToken__c = token.Id, ActivityType__c = 'TryNow', ActivityStatus__c = 'Success', PaymentUrl__c='http://sage.com.test');
        insert activity;
        
        System.runAs(u) {
            Test.startTest();
            CommunityUtilities.PaymentButtonAvailable check = CommunityUtilities.paymentButtonAvailabilityChecks();
            Test.stopTest();
            System.assertEquals(false, check.hasBillingAccount);
            System.assertEquals('http://sage.com.test', check.payNowURL);
        }
    }
    
    private static testmethod void paymentButtonAvailabilityChecks_WhenBillingAccountDoesntExistsButActivityExistsAndCustomerHasPaid_ReturnsBlankPayNowURL() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        
        zqu__Quote__c q = new zqu__Quote__c(name='Test', zqu__ElectronicPaymentMethodId__c = 'Test');
        insert q;
        
        PayNowToken__c token = new PayNowToken__c(Name='Test',  PayNowRedirectUrl__c = 'http://sage.com.test', Quote__c =q.Id);
        insert token;
        
        SageApiActivity__c activity = new SageApiActivity__c(ActivityID__c='Test', name = 'Test', Account__c = c.AccountId, PayNowToken__c = token.Id, ActivityType__c = 'TryNow', ActivityStatus__c = 'Success');
        insert activity;
        
        System.runAs(u) {
            Test.startTest();
            CommunityUtilities.PaymentButtonAvailable check = CommunityUtilities.paymentButtonAvailabilityChecks();
            Test.stopTest();
            System.assertEquals(false, check.hasBillingAccount);
            
        }
    }
    
    private static testmethod void paymentButtonAvailabilityChecks_WhenBillingAccountDoesntExistsAndActivityDoesntExist_ReturnsNothing() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        
        System.runAs(u) {
            Test.startTest();
            CommunityUtilities.PaymentButtonAvailable check = CommunityUtilities.paymentButtonAvailabilityChecks();
            Test.stopTest();
            System.assertEquals(false, check.hasBillingAccount);
            System.assertEquals(null, check.payNowURL);
        }
    }
    
    private static testmethod void canCancelSubscription_whenNoSubscriptionIsPresent_ReturnsFalse() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'canCancelSubscription@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'canCancelSubscription@sage.com', 'canCancelSubscription@sage.com');
        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.canCancelSubscription();
            Test.stopTest();
            System.assertEquals(false, result);
        }
    }
    
    private static testmethod void canCancelSubscription_whenActiveSubscriptionIsPresent_ReturnsTrue() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'canCancelSubscription@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'canCancelSubscription@sage.com', 'canCancelSubscription@sage.com');
        
         Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId, Status__c='Active', Start_Date__c = System.now(), End_Date__c = System.now());
        insert sm;
        
        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.canCancelSubscription();
            Test.stopTest();
            System.assertEquals(true, result);
        }
    }
    
    private static testmethod void canCancelSubscription_whenTrialSubscriptionIsPresent_ReturnsFalse() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'canCancelSubscription@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'canCancelSubscription@sage.com', 'canCancelSubscription@sage.com');
        
        Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId, Status__c='Trial', Start_Date__c = System.now(), End_Date__c = System.now());
        insert sm;
        
        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.canCancelSubscription();
            Test.stopTest();
            System.assertEquals(false, result);
        }
    }
    
    private static testmethod void canCancelSubscription_whenSubscriptionEndDateIsInThePast_ReturnsFalse() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'canCancelSubscription@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'canCancelSubscription@sage.com', 'canCancelSubscription@sage.com');
        
        Subscription_Master__c sm = new Subscription_Master__c(Account__c=c.AccountId, Status__c='Active', Start_Date__c = System.now().addDays(-365), End_Date__c = System.now().addDays(-1));
        insert sm;
        
        System.runAs(u) {
            Test.startTest();
            Boolean result = CommunityUtilities.canCancelSubscription();
            Test.stopTest();
            System.assertEquals(false, result);
        }
    }
    
    private static testmethod void hasPermissionForSuccessPlansCheck() {
        Contact c = createAccountAndContact('Test', 'test', 'test', 'canCancelSubscription@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'canCancelSubscription@sage.com', 'canCancelSubscription@sage.com');
        //remove subscription product charge as it is no longer relevant and depends on license only
        /*
        Zuora__SubscriptionProductCharge__c zsp = new Zuora__SubscriptionProductCharge__c();
        zsp.Name='abc';
        zsp.Zuora__ProductName__c='Sage live';
        zsp.Zuora__Account__c = c.AccountId;
        insert zsp;
        */
        //adding license data
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = c.AccountId;
        licensesf.RecordTypeId=Schema.SObjectType.sfLma__License__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
        licensesf.sfLma__Seats__c = -1;
        licensesf.sfLma__Org_Status_Formula__c = 'Active';
        insert licensesf;
        System.runAs(u) {
            Boolean result = CommunityUtilities.hasPermissionForSuccessPlans();
            //System.assertEquals(true, result);
        }
    }
    
    private static testmethod void getLabelsTest() {
        CommunityUtilities.getManageCasesLabel();
        CommunityUtilities.getManageSubscriptionLabel();
        CommunityUtilities.getSuccessPlanLabel();
    }
 

   
}