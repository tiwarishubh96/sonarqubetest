@isTest
public with sharing class PaymentPageCallbackExtensionTest {

	@isTest
	static void shouldUpdateBillingAccount(){
		Account acc = createAccount();
		Zuora__CustomerAccount__c billingAccount = createBillingAccount(acc.Id);
		zqu.PaymentPageCallbackController ctrl = new zqu.PaymentPageCallbackController();
		PaymentPageCallbackExtension ext = new PaymentPageCallbackExtension(ctrl);
		ext.objectId = billingAccount.Id;
		ext.paymentId ='123';
		Test.startTest();
		ext.setParams();
		Test.stopTest();
		System.assert(!ext.isQuote);
	}
	
	@isTest
	static void shouldNotUpdateBillingAccount(){
		Account acc = createAccount();
		Contact con = createContact(acc.Id);
		zqu__Quote__c zquote = createZQuote(acc.Id, con.Id); 
		zqu.PaymentPageCallbackController ctrl = new zqu.PaymentPageCallbackController();
		PaymentPageCallbackExtension ext = new PaymentPageCallbackExtension(ctrl);
		ext.objectId = zquote.Id;
		ext.paymentId ='123';
		Test.startTest();
		ext.setParams();
		Test.stopTest();
		System.assert(ext.isQuote);
	}
	/**
     * [createAccount creates new account in SFDC]
     * @return [new SFDC account]
     */
	private static Account createAccount(){      
        Account acc = new Account();
        acc.Name = 'acme'; 
        acc.Sales_Office__c = 'Atlanta CBC';  
        insert acc;       
        System.debug('Account Id created:'+acc.Id);
        return acc;
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
	/**
     * [createContact creates new contact in SFDC]
     * @param  accountId [SFDC account id]
     * @return           [new SFDC contact]
     */
	private static Contact createContact(Id accountId){      
        Contact con = new Contact();
        con.firstName = 'mark';   
        con.lastName = 'lawes';   
        con.accountId = accountId;
        insert con;       
        System.debug('Contact Id created:'+con.Id);
        return con;
	}

    /**
     * [createZQuote creates new zuora quote in SFDC]
     * @param  accountId [SFDC account id]
     * @param  contactId [SFDC contact id]
     * @return           [new SFDC quote]
     */
	public static zqu__Quote__c createZQuote(Id accountId, Id contactId) 
	{      
        zqu__Quote__c zquote = new zqu__Quote__c();
        
        zquote.zqu__Account__c = accountId;
        zquote.zqu__BillToContact__c = contactId;
        zquote.zqu__SoldToContact__c = contactId;
        zquote.zqu__Currency__c = 'USD';
        zquote.zqu__ProcessPayment__c = false;
        zquote.zqu__RenewalTerm__c = 12;
        zquote.zqu__InitialTerm__c = 12;
        zquote.zqu__ValidUntil__c  = Date.today().addDays(2);
        zquote.zqu__StartDate__c = Date.today();
        zquote.zqu__GenerateInvoice__c = true;
        zquote.zqu__PaymentMethod__c = 'Credit Card';
        zquote.zqu__ZuoraAccountID__c = '2c92c0f84dfff49f014e021c79b82bb6';

        insert zquote;
      
        return zquote;
	}
}