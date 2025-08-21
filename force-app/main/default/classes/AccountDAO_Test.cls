/**
 * Created by mike.jutzin on 4/7/2017.
 */

@IsTest
private class AccountDAO_Test {
	static testMethod void testGetAccountById() {
		Account acct = new Account(
			Name = 'TestAccount'
		);

		insert acct;
		System.assertEquals( new AccountDAO().getAccountById( acct.Id ).Id, acct.Id );
	}

	static testMethod void testGetAccountByZuoraId() {
		Account acct = new Account(
			Name = 'TestAccount',
			Zuora_Id__c = 'zuora-id'
		);

		insert acct;
		System.assertEquals( new AccountDAO().getAccountByZuoraId( acct.Zuora_Id__c ).Id, acct.Id );
	}

	static testMethod void testInsertAccounts() {
		List<Account> accts = new List<Account>();
		accts.add( new Account(
			Name = 'TestAccount',
			Zuora_Id__c = 'zuora-id'
		) );

		List<Account> result = new AccountDAO().insertAccounts( accts );
		System.assertEquals( accts[0].Id, result[0].id );
	}

	static testMethod void testUpdateAccounts() {
		List<Account> accts = new List<Account>();
		accts.add( new Account(
			Name = 'TestAccount',
			Zuora_Id__c = 'zuora-id'
		) );

		insert accts;
		accts[0].Zuora_Id__c = 'new-zuora-id';

		List<Account> result = new AccountDAO().updateAccounts( accts );
		System.assertEquals( 'new-zuora-id', result[0].Zuora_Id__c );
	}

}