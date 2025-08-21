@IsTest(SeeAllData=false)
private class SageApiAddCommUserActivityUtilsTest
{
    static locale__c loc;
    static {
        TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
        loc = [SELECT ID FROM locale__c WHERE name = 'en_US' LIMIT 1]; //TestDataUtility.createLocale('US - United States', 'Yes', 'en_US', 'English');
    }

    @testSetup static void setupTestRecords() {
        SageApiTestUtils.setup();
        SageApiTestUtils.setupCommunity();
    }
    
    static private SageUserIdentityProvider__c setupIdentity(string accountId, string identityType, string identityId, string userId)
    {
        //Account__c,Id,IdentityID__c,IdentityProvider__c,Name,SFBridgeID__c,User__c
        String bridgeId = accountId + ':' + identityType + ':' + identityId;
        SageUserIdentityProvider__c identity = new SageUserIdentityProvider__c( 
            Name = bridgeId
            , Account__c = accountId
            , SFBridgeID__c = bridgeId
            , IdentityProvider__c = identityType
            , IdentityID__c = identityId
            , User__c = userId
        );
        insert identity;
        return identity;
    }

    static private SageApiAddCommUserActivityRequest createPayload()
    {
        return createPayload('SageID', GenericUtilities.getRandomUUIDv4(), 'Customer', 'Customer Account Administrator');
    }
    
    static private SageApiAddCommUserActivityRequest createPayload(string identityType, string identityId, string communityType, string communityRoleName)
    {
        Account acc = TestDataUtility.createAccount(loc.Id);
        SageApiAddCommUserActivityRequest payload = new SageApiAddCommUserActivityRequest();
        payload.AccountId = acc.Id;
        payload.firstName = 'TestFirstName1';
        payload.lastName = 'TestLastName1';
        payload.email = 'test@email.com';
        payload.phone = '123123123';
        payload.address1 = '1000 Peacthree St';
        payload.address2 = '';
        payload.city = 'Atlanta';
        payload.postalCode = '30075';
        payload.state = 'GA';
        payload.countryCode = 'US';
        payload.communityType = communityType;
        payload.communityRole = communityRoleName;
        payload.identityType = identityType;
        payload.identityId = identityId;
        return payload; 
    }

    static private SageApiActivity__c createActivity( SageApiAddCommUserActivityRequest payload )
    {
        return SageApiTestUtils.createActivity( 'AddCommunityUser', JSON.serialize( payload ) );
    }

    @IsTest static void testValidatePayloadNoActivity()
    {
        SageApiActivity__c activity = null;
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = new List<Community_Role__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
   
        Test.startTest();
        
            System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoStep()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = null;
		Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = new List<Community_Role__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }
    
    @IsTest static void testValidatePayloadInvalidPayload()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity( 'AddCommunityUser', '{' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = new List<Community_Role__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
        
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadEmptyPayload()
    {
        SageApiActivity__c activity = SageApiTestUtils.createActivity( 'AddCommunityUser', 'null' );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = new List<Community_Role__c>();
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
        
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoAccountId()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.AccountId = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoIdentityType()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.IdentityType = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidIdentityType()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.IdentityType = 'WrongIdentityType';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoIdentityID()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.IdentityId = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoCommunityType()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.communityType = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidCommunityType()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.communityType = 'WrongCommunityType';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }
    
    @IsTest static void testValidatePayloadNoCustomerCommunityRole()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.communityRole = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidCustomerCommunityRole()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.communityRole = 'WrongCommunityRole';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoFirstName()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.firstName = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadNoLastName()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.lastName = null;
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidAccount()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.AccountId = 'a1t8E000000pWv7';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadInvalidCommunityTypeForCustomerAccount()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        payload.communityType = 'Partner';
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidatePayloadExistingIdentity()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Set<Id> keys = accounts.keyset();
        Id key1 = (new list<Id>(keys) )[0];
        Account acc = (Account)accounts.get(key1);
        setupIdentity(acc.id, payload.identityType, payload.identityId, null);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        identities.putAll([SELECT Id, SFBridgeID__c FROM SageUserIdentityProvider__c]);
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        Contact con = new Contact(Email='a@b.com', lastName='Test', AccountId=acc.Id);
        insert con;
        CommunityX__c comm = [SELECT Id FROM CommunityX__c WHERE Name=:SageApiActivityUtils.setting_CustomerCommunityName LIMIT 1];
        Community_Membership__c memebership = new Community_Membership__c(
            Community__c = comm.Id
            , Community_Role__c = roles[0].Id
            , Contact__c = con.Id);
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        contactCommunitiesMap.put(con.Id, memebership);
    
        Test.startTest();
        
             System.assertEquals( false, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }


    @IsTest static void testValidatePayloadSuccess()
    {
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);

        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Map<Id, Contact> contacts = new Map<Id, Contact>();
        contacts.putAll([SELECT id, AccountId FROM Contact]);
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        CommunityX__c comm = [SELECT Id FROM CommunityX__c WHERE Name=:SageApiActivityUtils.setting_CustomerCommunityName LIMIT 1];
        Community_Membership__c memebership = new Community_Membership__c(
            Community__c = comm.Id
            , Community_Role__c = roles[0].Id
            , Contact__c = con.Id);
        insert memebership;
        Map<ID, Community_Membership__c> contactCommunitiesMap = new Map<ID, Community_Membership__c>();
        contactCommunitiesMap.put(con.Id, memebership);
        String uniqueId = acc.Id + ':' + payload.identityType + ':' + payload.identityId;
        Profile profile = [Select Id from Profile where name = 'Sage: CBC Customer Community User'];
        User user = new User(
            Username=payload.email, FirstName=payload.firstName, Lastname=payload.lastName,
            CompanyName=payload.lastName, Alias='abc', EmailEncodingKey='UTF-8',
            LanguageLocaleKey='en_US', ProfileId = profile.Id,
            LocaleSidKey='en_US',TimeZoneSidKey='GMT',
            Email=payload.email, ContactId=con.Id, IsActive=true
        );
        insert user;

        SageUserIdentityProvider__c ident = new SageUserIdentityProvider__c(
            Name = uniqueId
            , Account__c = acc.Id
            , IdentityID__c = payload.identityId
            , IdentityProvider__c = payload.identityType
            , SFBridgeID__c = uniqueId
            , User__c = user.Id
        );
        insert ident;

        Test.startTest();
        
             System.assertEquals( true, SageApiAddCommUserActivityUtils.validatePayload( activity, step, accounts, contacts, identities, roles, contactCommunitiesMap ) );
    
        Test.stopTest();
    }

    @IsTest static void testValidRequestContactUserCommunitySuccess()
    {
        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        List<ID> ids = new List<ID> {con.Id};

        List<Community_Role__c> roles = [SELECT id, name FROM Community_Role__c];
        CommunityX__c comm = [SELECT Id FROM CommunityX__c WHERE Name=:SageApiActivityUtils.setting_CustomerCommunityName LIMIT 1];
        Community_Membership__c memebership = new Community_Membership__c(
            Community__c = comm.Id
            , Community_Role__c = roles[0].Id
            , Contact__c = con.Id);
        insert memebership;

        Test.startTest();
        
            Map<ID, Community_Membership__c> cmm = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity( ids );
            System.assert( cmm != null && cmm.size()==1 );
    
        Test.stopTest();
    }

    @IsTest static void testCreateUserWithContactSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiAddCommUserActivityRequest payload = createPayload();
            payload.AccountId = accs[i].Id;
            SageApiActivity__c activity = createActivity( payload );
            SageApiAddCommUserActivityResponse resp = new SageApiAddCommUserActivityResponse();
            resp.data = new SageApiAddCommUserActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiAddCommUserActivityUtils.createUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserSuccess()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiAddCommUserActivityRequest payload = createPayload();
            payload.accountId = accs[i].Id;
            SageApiActivity__c activity = createActivity( payload );
            SageApiAddCommUserActivityResponse resp = new SageApiAddCommUserActivityResponse();

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiAddCommUserActivityUtils.createUser( step, activities );
    
        Test.stopTest();
        
        List<Contact> cons = [SELECT id FROM Contact WHERE AccountId IN :accs];

        System.assertEquals( 1, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }
    
    @IsTest static void testCreateUserNoContacts()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiAddCommUserActivityRequest payload = createPayload();
            SageApiActivity__c activity = createActivity( payload );
            SageApiAddCommUserActivityResponse resp = new SageApiAddCommUserActivityResponse();
            resp.data = new SageApiAddCommUserActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiAddCommUserActivityUtils.createUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserNoCandidates()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiAddCommUserActivityRequest payload = createPayload();
            SageApiActivity__c activity = createActivity( payload );
            SageApiAddCommUserActivityResponse resp = new SageApiAddCommUserActivityResponse();
            resp.data = new SageApiAddCommUserActivityResponse.ResponseData();
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        delete cons;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiAddCommUserActivityUtils.createUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
    }

    @IsTest static void testCreateUserPayloadFailure()
    {
        List<Account> accs = new List<Account>();
        for( Integer i = 0; i < 1; i++ )
        {
            accs.add( new Account( Name = 'Unknown' + i + ' Inc.' ) );
        }
        insert accs;

        List<Contact> cons = new List<Contact>();
        for( Account acc : accs )
        {
            cons.add( new Contact( Firstname = 'Some', Lastname = 'One' + acc.Name.substringBefore(' '), AccountId = acc.Id ) );
        }
        insert cons;

        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        for(Integer i = 0; i < 1; i++)
        {
            SageApiAddCommUserActivityRequest payload = createPayload();
            SageApiActivity__c activity = SageApiTestUtils.createActivity( 'AddCommunityUser', '{' );
            SageApiAddCommUserActivityResponse resp = new SageApiAddCommUserActivityResponse();
            resp.data = new SageApiAddCommUserActivityResponse.ResponseData();
            resp.data.contactId = cons[i].Id;
            activity.Artifacts__c = JSON.serialize( resp );

            activities.add( activity );
        }
        insert activities;

        SageApiActivityStep step = new SageApiActivityStep( 1, 'DoStuff' );
    
        Test.startTest();
        
            SageApiAddCommUserActivityUtils.createUser( step, activities );
    
        Test.stopTest();

        System.assertEquals( 0, [SELECT Count() FROM User WHERE ContactId IN :cons] );
        Map<Id, SageApiActivity__c> mapActivites = new Map<Id, SageApiActivity__c>((List<SageApiActivity__c>)GenericUtilities.resetSObjects( activities ));
        Set<String> possibleErrors = new Set<String>{ SageApiStatus.ManualInterventionRequired, SageApiStatus.Abandoned };
        for( SageApiActivity__c act : mapActivites.values() )
        {
            System.assertEquals( false, possibleErrors.contains( act.ActivityStatus__c ) );
        }
    }
    
    @IsTest static void testGetValidRequestAccountsSuccess()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);
        Account acct = [SELECT id, name, recordTypeId FROM Account LIMIT 1];

        Test.startTest();
        
             Map<Id, Account> acctMap = SageApiAddCommUserActivityUtils.getValidRequestAccounts( activities );
             Account pacct = acctMap.get(acct.Id);
             System.assertEquals( false, pacct == null );
    
        Test.stopTest();
    }
    
    @IsTest static void testGetValidRequestIdentitiesSuccess()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);

		Map<Id, Account> accounts = new Map<Id, Account>();
        accounts.putAll([SELECT id, name, recordTypeId FROM Account]);
        Set<Id> keys = accounts.keyset();
        Id key1 = (new list<Id>(keys) )[0];
        Account acc = (Account)accounts.get(key1);
        SageUserIdentityProvider__c ident = setupIdentity(acc.id, payload.identityType, payload.identityId, null);
        
        Test.startTest();
        
             Map<string, SageUserIdentityProvider__c> identMap = SageApiAddCommUserActivityUtils.getValidRequestIdentities( activities );
             SageUserIdentityProvider__c pident = identMap.get(ident.Id);
             System.assertEquals( false, pident == null );
    
        Test.stopTest();
    }

    @IsTest static void testGetValidRequestCommunityRolesSuccess()
    {
        Test.startTest();
        
            List<Community_Role__c> roles = SageApiAddCommUserActivityUtils.getValidRequestCommunityRoles();
            System.assertEquals( true, roles != null && roles[0].name == 'Customer Account Administrator');
    
        Test.stopTest();
    }

    @IsTest static void testUpdateArtifactWithErrorStringSuccess()
    {
        SageApiAddCommUserActivityRequest payload = createPayload();
        SageApiActivity__c activity = createActivity( payload );
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        activities.add(activity);
        List<SageApiActivityError> errors = new List<SageApiActivityError>();
        SageApiActivityError error = new SageApiActivityError();
        error.code = 'testCode';
        error.target = 'testTarget';
        error.message = 'testMessage';
        errors.add(error);
        SageApiActivityStep step = new SageApiActivityStep(1, 'TestStep');

        Test.startTest();
        
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            SageApiAddCommUserActivityResponse response = (SageApiAddCommUserActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiAddCommUserActivityResponse.class);
            System.assertEquals( true, response != null);
    
        Test.stopTest();
    }

    @IsTest static void testSetUpUserRecord() {
        Locale__c loc = [SELECT Id, Name, LanguageLocaleKey__c, TimeZone__c, currencyIsoCode FROM Locale__c LIMIT 1];

        Account acc = TestDataUtility.createAccount(loc.id);
        Contact con = TestDataUtility.createContact(acc.Id);
        CommunityX__c com = [SELECT Id, Default_User_Profile__c, Name FROM CommunityX__c LIMIT 1];
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name =: com.Default_User_Profile__c];

        Test.startTest();

            User aUser = SageApiAddCommUserActivityUtils.setUpUserRecord(con, prof, loc);
            System.assert( aUser != null);
    
        Test.stopTest();
    }
}