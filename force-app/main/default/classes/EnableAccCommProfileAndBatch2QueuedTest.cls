@isTest
public class EnableAccCommProfileAndBatch2QueuedTest {
    /**
    * Testing the EnableAccCommProfile a Z Product
    * @param commProfileId [Zuora Id of the communication profile]
    * @param invTemplateId [Zuora Id of the invoice template]
    * @param zuoraAccountId [Zuora Id of the account]
    * @param vatNumber [VAT Number]
    *  @param taxExemptStatus [tax exempt status]
    * @param defaultPaymentMethodId [Name of the Zuora Id of the default payment method]
    * @param defaultPaymentGateway [Name of the default payment gateway]
    **/
    static String commProfileId;
    static String invTemplateId;
    static String zuoraAccountId;
    static String vatNumber;
    static String taxExemptStatus;
    static String defaultPaymentMethodId;
    static String defaultPaymentGateway;
    /**
    * Create Communication Profile
    */
    public static zqu__CommunicationProfile__c createCommProf(String name) {
        zqu__CommunicationProfile__c cp = new zqu__CommunicationProfile__c(Name=name,zqu__ZuoraId__c='2c92c0f84dfff49f014e021c79b82bb6');
        insert cp;
        return cp;
    }
   
    public static zqu__InvoiceTemplate__c  createinvTemp(String name) {
        zqu__InvoiceTemplate__c iT = new zqu__InvoiceTemplate__c(Name=name,zqu__ZuoraId__c='2c92c0f84dfff49f014e021c79b82bb6');
        insert iT;
        return iT;
    }
    /**
    * Create Account to insert VAT Number and make sure taxExemptStatus Popualted
    */
    public static Account createVatNum(String name){
        Account acc = new Account(Industry='Energy', Name=name, Type='Press', VAT_Number__c='FR23444422',BillingCountryCode='FR', Phone='9876543210', CurrencyIsoCode='EUR', Sales_Office__c='Dublin CBC');
        insert acc;
        acc =[select id,VAT_Number__c,taxExemptStatus__c from Account where id =:  acc.id];
        system.debug('tax Exempt Status '+acc.TaxExemptStatus__c);

        return acc;
    }
    /**
    * Create Invoice Line Item
    
    public static Invoice_Line_Item__c createZuoraAcc( ) {
        Zuora__ZInvoice__c zI=new Zuora__ZInvoice__c(Zuora__ZuoraId__c='2c92c0f84dfff49f014e021c79b82bb6', Invoice_Sequence_Number__c='i12345');
        insert zI;
        Invoice_Line_Item__c iLV = new Invoice_Line_Item__c(Invoice__c =zI.Id);
        insert iLV;
        return iLV;
    }
*/
    /**
    * Create Default Payment Method
    */
    public static Zuora__PaymentMethod__c createDefPayMethod(String name){
        Account acc = new Account(Industry='Energy', Name=name, Type='Press', VAT_Number__c='FR23444422', Phone='9876543210',BillingCountryCode = 'FR', CurrencyIsoCode='EUR', Sales_Office__c='Dublin');
        insert acc;
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c(Name='Sage', Zuora__Account__c=acc.Id, Zuora__Zuora_Id__c='2c92c0f84dfff49f014e021c79b82bb6');
        insert ca;
        Zuora__PaymentMethod__c  zpm = new Zuora__PaymentMethod__c (Name=name, Zuora__BillingAccount__c=ca.Id);
        insert zpm;
        return zpm;
    }
    /**
    * Create Hosted PageLite Setting
    */
    public static zqu__HostedPageLiteSetting__c createDefPayGate(String name) {
        zqu__HostedPageLiteSetting__c hPLS = new zqu__HostedPageLiteSetting__c(Name=name, zqu__PageId__c='2c92c0o8533b026b0153443esgd2782a', zqu__ComponentName__c='PaymentGate', zqu__PaymentMethodType__c='SEGA');
        insert hPLS;
        return hPLS;
    }
    /**
    * Test EnableAccCommProfileAndBatch2Queued
    */    
    static testmethod void verifyEnableAccCommProfileAndBatch2Queued(){
        zqu__CommunicationProfile__c cP = createCommProf('SageCommunicationProf');
        commProfileId=''+cP.Id;
        zqu__InvoiceTemplate__c zIT     = createinvTemp('SageInvTemp');
        invTemplateId = ''+zIT.Id;
        Account ac                      = createVatNum('SageAcc');
        vatNumber = ''+ac.VAT_Number__c;
        // Invoice_Line_Item__c lI      = createZuoraAcc();
        taxExemptStatus=''+ac.taxExemptStatus__c;
        zuoraAccountId= '2c92c0o8533b026b0153443esgd2782a';
        Zuora__PaymentMethod__c pM= createDefPayMethod('VISA');
        defaultPaymentMethodId=''+pM.Id;
        zqu__HostedPageLiteSetting__c hPLS=createDefPayGate('SEGUS');
        defaultPaymentGateway=''+hPLS.Name;
        Test.startTest();
        System.enqueueJob(new EnableAccCommProfileAndBatch2Queued( commProfileId,  invTemplateId,  zuoraAccountId,  vatNumber, taxExemptStatus, defaultPaymentMethodId,  defaultPaymentGateway, false, 'batch2','SGS LTD','UK'));
        System.enqueueJob(new EnableAccCommProfileAndBatch2Queued( commProfileId,  invTemplateId,  zuoraAccountId,  vatNumber, taxExemptStatus, defaultPaymentMethodId,  defaultPaymentGateway, true, 'batch3', 'SGS Inc','NA'));
        Test.stopTest();
        
    } 
    
}