@isTest
private class MySuccessPlansUtilityTest
{

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
        Account a = new Account(name=accountName, Foundation_Customer__c = 'Approved',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
        insert a;

        Contact c = new Contact(FirstName=firstName, LastName=lastName, AccountId=a.Id, Email = email,Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
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

    @testSetup
    static void testData()
    {
        Contact cont = createAccountAndContact('accountName', 'testName', 'testName', 'email@gmail.com');
        User u = createPortalUser(cont);

    }

    @isTest
    static void itShould()
    {
        // Given
        Account acc =new Account(name='testAcc',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
        insert acc;
        Success_Plan__c plan = new Success_Plan__c(Name='test',Account__c=acc.id);
        insert plan;
        // When
        MySuccessPlansUtility mysuccess = new MySuccessPlansUtility();
        id successPlanId = MySuccessPlansUtility.getSuccessPlanBody('test');
        system.assertNotEquals(successPlanId,null);

        // Then

    }

    @isTest
    static void test1()
    {
        // Given
        Account acc1 =new Account(name='testAcc11',Global_Id__c=String.ValueOf(Math.round((Math.random() * (900000) + 100003))+Datetime.now().millisecond()));
        insert acc1;
        Success_Plan__c plan1 = new Success_Plan__c(Name='test',Account__c=acc1.id);
        insert plan1;
        Success_Plan__c plan2 = new Success_Plan__c(Name='aTest',Account__c=acc1.id);
        insert plan2;

        // When
        MySuccessPlansUtility mysuccess = new MySuccessPlansUtility();
        List<String> fieldsName = new List<String>();
        fieldsName.add('Name');
        fieldsName.add('Account__c');
        try{
        MySuccessPlansUtility.getSuccessPlans(fieldsName,'Name','2');
        }catch(Exception ex)
        {

        }
        //system.assertNotEquals(successPlanId,null);
        
        // Then

    }

    @isTest
    static void test2()
    {
        // Given
        //User u = [select Id,Name,AccountId from User where firstname = 'testName'];
		Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
		
        Zuora__SubscriptionProductCharge__c zuora =
         new Zuora__SubscriptionProductCharge__c(Zuora__ProductName__c='ZuoraTest Live', Zuora__Account__c = u.AccountId);
        
         insert zuora;
        //adding license data
        sfLma__License__c licensesf = new sfLma__License__c();
        licensesf.sfLma__Subscriber_Org_ID__c = '00Dd0000000cnGD';
        licensesf.sfLma__Expiration__c = Date.today();
        licensesf.sfLma__Account__c = c.AccountId;
        licensesf.RecordTypeId=Schema.SObjectType.sfLma__License__c.getRecordTypeInfosByName().get('Active').getRecordTypeId();
         licensesf.sfLma__Seats__c = -1;
        insert licensesf;
        // When
        System.runAs(u)
        {

            MySuccessPlansUtility mysuccess = new MySuccessPlansUtility();
            List<String> fieldsName = new List<String>();
            fieldsName.add('Name');
            fieldsName.add('Account__c');
            fieldsName.add('Org_Installation_Date__c');
            MySuccessPlansUtility.getSuccessPlans(fieldsName,'Name','2');
        


        }
        //system.assertNotEquals(successPlanId,null);
        
        // Then

    }
     @isTest
    Public static void hasPermissionForSuccessPlans_size(){
        Contact c = createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Success_Plan__c sp = new Success_Plan__c();
        sp.Name = 'success_test';
        sp.Account__c = c.AccountId;
        insert sp;
        System.runAs(u){
            Test.startTest();
            Boolean cu=MySuccessPlansUtility.hasPermissionForSuccessPlans();
            system.assertEquals(true, cu);
            Test.stopTest();
    }
    }


}