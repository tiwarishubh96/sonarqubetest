/**
 * Created by mike.jutzin on 4/7/2017.
 */

@IsTest
private class ContactDAO_Test {
	static testMethod void testGetContactById() {
		Contact c = createNewContact();
		insert c;

		System.assertEquals( c.Id, new ContactDAO().getContactById( c.Id ).Id );
	}

	static testMethod void testGetContactsByAccountId() {
		Contact c = createNewContact();
		insert c;
		
		System.assertEquals(
			c.Id,
			new ContactDAO().getContactsByAccountId( c.AccountId ).get( 0 ).Id );

	}

	static testMethod void testUpdateContacts() {
		List<Contact> contacts = new List<Contact>();
		Contact c = createNewContact();
		insert c;

		c.LastName = 'Lastnamerson';
		contacts.add( c );

		System.assertEquals(
			'Lastnamerson',
			new ContactDAO().updateContacts( contacts ).get( 0 ).LastName
		);
	}

	static testMethod void testInsertContacts() {
		List<Contact> contacts = new List<Contact>();
		Contact c = createNewContact();
		contacts.add( c );

		List<Contact> result = new ContactDAO().insertContacts( contacts );
		System.assertEquals( contacts[0].id, result[0].id );
	}

	static Contact createNewContact() {
		Account acct = new Account( Name = 'TestAccount' );
		insert acct;
		Contact con = new Contact( LastName = 'McLastname', AccountId = acct.Id );
		return con;
	}
}