/**
 * Created by mike.jutzin on 4/7/2017.
 */

@IsTest
private class UserDAO_Test {
	static testMethod void testGetContactById() {
		Contact c = createNewContact();
		insert c;

		System.assertEquals( c.Id, new UserDAO().getContactById( c.Id ).Id );
	}

	static testMethod void testInsertContacts() {
		List<Contact> contacts = new List<Contact>();
		Contact c = createNewContact();
		contacts.add( c );

		List<Contact> result = new UserDAO().insertContacts( contacts );
		System.assertEquals( contacts[0].id, result[0].id );
	}

	static Contact createNewContact() {
		Account acct = new Account( Name = 'TestAccount' );
		insert acct;
		Contact con = new Contact( LastName = 'McLastname', AccountId = acct.Id );
		return con;
	}
}