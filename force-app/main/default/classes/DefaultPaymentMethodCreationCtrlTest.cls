@isTest
public with sharing class DefaultPaymentMethodCreationCtrlTest {

	@isTest
	static void shouldInit(){
		Account acc = createAccount();
		Zuora__CustomerAccount__c billingAccount = createBillingAccount(acc.Id);
		ApexPages.StandardController ctrl = new ApexPages.StandardController(billingAccount);
		DefaultPaymentMethodCreationController ext = new DefaultPaymentMethodCreationController(ctrl);
		ext.next();
		ext.cancel();		
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
}