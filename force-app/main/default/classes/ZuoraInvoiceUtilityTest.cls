/**
*  Set of tests for the ZuoraInvoiceUtility class
*  @author Salesforce Services
**/
@isTest
public class ZuoraInvoiceUtilityTest {

    private static String ACCOUNT_NAME = 'Test Account';
    private static String ACCOUNT_OFFICE = 'Atlanta CBC';
    private static String ACCOUNT_CITY = 'New York';
    private static String ACCOUNT_COUNTRY = 'United States';
    private static String ACCOUNT_STATE = 'New York';
    private static String ACCOUNT_POSTAL_CODE = '12345';
    private static String ACCOUNT_STREET = 'Lot 49';
    private static String CONTACT_FIRST_NAME = 'Thomas';
    private static String CONTACT_LAST_NAME = 'Pynchon';
    private static String CONTACT_EMAIL = 'tpynch@somewhere.com';
    private static String ZUORA_ACCOUNT_ID = '2c92c0f94e03d39e014e05cd105f17E0';
    private static String ZUORA_INVOICE_ID = '2c92c09454a989420154aa577aaa7e90';

    static {
        // Create a contact and account
        Account a = new Account(Name = ACCOUNT_NAME, Sales_Office__c = ACCOUNT_OFFICE, BillingCity = ACCOUNT_CITY, BillingCountry = ACCOUNT_COUNTRY,
                                BillingState = ACCOUNT_STATE, BillingStreet = ACCOUNT_STREET, BillingPostalCode = ACCOUNT_POSTAL_CODE);
        insert a;
        Contact c = new Contact(AccountId = a.Id, FirstName = CONTACT_FIRST_NAME, LastName = CONTACT_LAST_NAME, Email = CONTACT_EMAIL, MailingCity = ACCOUNT_CITY,
                                MailingState = ACCOUNT_STATE, MailingCountry = ACCOUNT_COUNTRY, MailingPostalCode = ACCOUNT_POSTAL_CODE, MailingStreet = ACCOUNT_STREET);
		    insert c;
        // Create a portal user
        User commUser = CommunityUtilitiesTest.createPortalUser(c);
        // Insert a Zuora Billing Account
        Zuora__CustomerAccount__c billingAcc = new Zuora__CustomerAccount__c(Zuora__Account__c = c.AccountId, Zuora__Zuora_Id__c = ZUORA_ACCOUNT_ID);
        insert billingAcc;
        // Create an Invoice for that Billing Account
        Zuora__ZInvoice__c inv = new Zuora__ZInvoice__c(Zuora__Account__c = c.AccountId, Zuora__BillingAccount__c = billingAcc.Id, Zuora__Zuora_Id__c = ZUORA_INVOICE_ID);
        insert inv;
    }

    /**
     * @description Test the method that retrieve the invoices
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-07
     */
    @isTest(SeeAllData=false)
    static void testGetInvoices(){
        // Get the community user created for the test
        User commUser = [SELECT Id, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL)];
        List<sObject> invoices = new List<sObject>();
        Test.startTest();
            System.runAs(commUser){
                CommunityUtilitiesTest.addPermissionSet(commUser.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
                invoices = ZuoraInvoiceUtility.getInvoices(new List<String>{'Name', 'Zuora__TotalAmount__c', 'Zuora__Zuora_Id__c'}, 'Name', '10');
            }
        Test.stopTest();
        // Verify that the invoice created on the static method is returned
        System.assertEquals(1, invoices.size());
        System.assertEquals(ZUORA_INVOICE_ID, invoices.get(0).get('Zuora__Zuora_Id__c'));
    }

    /**
     * @description Test the method to get the invoice body
     * @author      Santiago Colman <scolman@altimetrik.com>
     * @date        2016-06-06
     */
    @isTest(SeeAllData=true) //SeeAllData is needed to prevent 'Please upload Zuora WSDL at first.' error, caused by internal setting of zuora.
    static void testGetInvoiceBody(){
        // Get the community user created for the test
        User commUser = [SELECT Id, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL)];
        String bodyString = 'Some random body';
        String base64Body = EncodingUtil.base64Encode(Blob.valueOf(bodyString));
        Zuora.zObject zObj = new Zuora.zObject('Invoice');
        zObj.setValue('Id', '123456');
        zObj.setValue('Body', base64Body);
        ZuoraInvoiceUtility.testZObject = zObj;
        String attachmentId;
        Test.startTest();
            System.runAs(commUser){
                attachmentId = ZuoraInvoiceUtility.getInvoiceBody(ZUORA_INVOICE_ID);
            }
        Test.stopTest();
        // Verify that the attachment was related to the Invoice
        Zuora__ZInvoice__c invoice = [SELECT Id, (SELECT Id FROM Attachments) FROM Zuora__ZInvoice__c WHERE Zuora__Zuora_Id__c = :ZUORA_INVOICE_ID];
        System.assertEquals(attachmentId, invoice.Attachments[0].Id);
        // Verify the appropriate body was returned
        Attachment att = [SELECT Body FROM Attachment WHERE Id = :attachmentId];
        System.assertEquals(base64Body, EncodingUtil.base64Encode(att.Body));
    }
    @isTest
    static void testhasPermissionForInvoices(){
        User commUser = [SELECT Id, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL)];
        zqu__ZProduct__c zProduct = new zqu__ZProduct__c(zqu__ZuoraId__c = '12345',zqu__SKU__c = 'testSKU',Name='test');
        insert zProduct;
        Subscription_Master__c sub = new Subscription_Master__c(status__c = 'Trial', ZProduct__c = zProduct.Id, Account__c = commUser.AccountId);
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();
        invoice.Invoice_Sequence_Number__c = '123456';
        insert sub;
        insert invoice;
        system.runAs(commUser){
            test.startTest();
            ZuoraInvoiceUtility.hasPermissionForInvoices();
            test.stopTest();
        }
        
    }
    @isTest
    static void testhasPermissionForNoInvoices(){
        User commUser = [SELECT Id, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL)];
        zqu__ZProduct__c zProduct = new zqu__ZProduct__c(zqu__ZuoraId__c = '12345',zqu__SKU__c = 'testSKU',Name='test');
        insert zProduct;
        Subscription_Master__c sub = new Subscription_Master__c(status__c = 'Trial', ZProduct__c = zProduct.Id);       
        insert sub;
        system.runAs(commUser){
            test.startTest();
            ZuoraInvoiceUtility.hasPermissionForInvoices();
            test.stopTest();
        }
        
    }
    @isTest
    static void testhasPermissionForNoActivitesOrInvoices(){
        Account a1 = new Account(Name = ACCOUNT_NAME, Sales_Office__c = ACCOUNT_OFFICE, BillingCity = ACCOUNT_CITY, BillingCountry = ACCOUNT_COUNTRY,
                                BillingState = ACCOUNT_STATE, BillingStreet = ACCOUNT_STREET, BillingPostalCode = ACCOUNT_POSTAL_CODE);
        insert a1;
        Contact c1 = new Contact(AccountId = a1.Id, FirstName = 'testName', LastName = 'CONTACT_LAST_NAME', Email = 'test@sage.com', MailingCity = ACCOUNT_CITY,
                                MailingState = ACCOUNT_STATE, MailingCountry = ACCOUNT_COUNTRY, MailingPostalCode = ACCOUNT_POSTAL_CODE, MailingStreet = ACCOUNT_STREET);
		insert c1;
        User commUser1 = CommunityUtilitiesTest.createPortalUser(c1);
        zqu__ZProduct__c zProduct = new zqu__ZProduct__c(zqu__ZuoraId__c = '12345',zqu__SKU__c = 'testSKU',Name='test');
        insert zProduct;
        Subscription_Master__c sub = new Subscription_Master__c(status__c = 'Trial', ZProduct__c = zProduct.Id);       
        insert sub;
        
        system.runAs(commUser1){
            test.startTest();
            ZuoraInvoiceUtility.hasPermissionForInvoices();
            test.stopTest();
        }
        
    }
    
    @isTest
    static void hasPermissionSetTest() {
        String permissionSetName = 'Manage_Subscriptions';
        ZuoraInvoiceUtility.hasPermissionSet(permissionSetName);
    }
}