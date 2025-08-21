public class SageApiAddCommUserActivityUtils {
    public static Boolean validatePayload(SageApiActivity__c activity, SageApiActivityStep step, Map<Id, Account> accounts, Map<Id, Contact> contacts, Map<string, SageUserIdentityProvider__c> identities, List<Community_Role__c> roles, Map<ID, Community_Membership__c> contactCommunitiesMap) {
        //TODO: add length validation
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (activity == null || step == null)
            return false;

        SageApiAddCommUserActivityRequest req = null;
        try {
            req = (SageApiAddCommUserActivityRequest)JSON.deserialize(activity.payload__c, SageApiAddCommUserActivityRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }
        
        if (req == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid: null value resulted from deserialization');
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        SageApiActivityUtils.debug('validatePayload req: ['+ req + ']');

        if (String.isBlank(req.AccountId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'AccountId', 'Account ID is required');

        if (String.isBlank(req.identityType))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityType', 'Identity Type is required');
        else if (req.identityType != 'SageID' && req.identityType != 'Facebook' && req.identityType != 'Google')
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'identityType', 'Identity Type must be either SageID, Facebook or Google');

        //TODO: add ID parsing for various types
        if (String.isBlank(req.identityId))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityId', 'Identity ID is required');

        if (String.isBlank(req.communityType))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'communityType', 'Community Type is required');
        else if (req.communityType != SageApiActivityUtils.setting_CustomerCommunityType && req.communityType != SageApiActivityUtils.setting_PartnerCommunityType)
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'communityType', 'Community Type must be either '+SageApiActivityUtils.setting_CustomerCommunityType+' or '+SageApiActivityUtils.setting_PartnerCommunityType);
           
        if (req.communityType == SageApiActivityUtils.setting_CustomerCommunityType && String.isBlank(req.communityRole))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'communityRole', 'Community Role is required when Community Type is '+SageApiActivityUtils.setting_CustomerCommunityType);
        
        if (String.isNotBlank(req.communityRole) && roles != null && roles.size() > 0) {
            Boolean roleFound = false;
            for (Community_Role__c role : roles) {
                if (role.name != req.communityRole) continue;
                roleFound = true;
                break;
            }
            if (!roleFound)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'communityRole', 'The provided Community Role does not exist');
        }

        if (String.isNotBlank(req.ContactId)) {
            Boolean matched = false;
            if (contacts != null && !contacts.isEmpty()) {
                for(Contact c : contacts.values()) {
                    if (c == null || c.Id != req.ContactId) continue;

                    matched = true;
                    activity.Contact__c = req.ContactId;
                    break;
                }
            }

            if (! matched)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ContactId', 'Contact ID does not exist');
        } else {
            if (String.isBlank(req.firstName))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required');

            if (String.isBlank(req.lastName))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required');
        }

        if (String.isNotBlank(req.AccountId)) {
            Boolean matched = false;
            if (accounts != null && accounts.size() > 0) {
                Id standardAcctRecordTypeId = null;
                Id partnerAcctRecordTypeId = null;
                
                try {
                    standardAcctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SageApiActivityUtils.setting_StandardAccountRecordType).getRecordTypeId();
                    partnerAcctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(SageApiActivityUtils.setting_PartnerAccountRecordType).getRecordTypeId();
                } catch (Exception ex) {
                    ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'Account.getRecordTypeInfosByName', ex);
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'System Configuration', 'Failed to obtain valid account record type');
                }

                for(Account a : accounts.values()) {
                    if (a == null || a.Id != req.AccountId) continue;
                    
                    matched = true;
                    activity.Account__c = req.AccountId;
                    if (req.communityType == SageApiActivityUtils.setting_CustomerCommunityType && a.recordTypeId != standardAcctRecordTypeId)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'The provided Account must be standard account type for '+SageApiActivityUtils.setting_CustomerCommunityType+' community');
                    else if (req.communityType == SageApiActivityUtils.setting_PartnerCommunityType && a.recordTypeId != partnerAcctRecordTypeId)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'The provided Account must be partner account type for '+SageApiActivityUtils.setting_PartnerCommunityType+' community');
                        
                    break;                        
                }
            }
            
            if (accounts == null || accounts.size() == 0 || ! matched)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'Account ID does not exist');
            
            if (identities != null && identities.size() > 0 && String.isNotBlank(req.identityType) && String.isNotBlank(req.identityId)) {
                try {
                    String sfBrdigeId = ID.valueOf(req.AccountId) + ':' + req.identityType + ':' + req.identityId;
                    for (SageUserIdentityProvider__c identity : identities.values()) {
                        if (identity == null || sfBrdigeId != identity.SFBridgeID__c) continue;
                        SageApiActivityUtils.debug('identity.Id: '+identity.Id);
                        SageApiActivityUtils.debug('identity.Account__c: '+identity.Account__c);
                        SageApiActivityUtils.debug('identity.User__c: '+identity.User__c);
                        SageApiActivityUtils.debug('identity.User__r.ContactId: '+identity.User__r.ContactId);
                        activity.SageUserIdentityProvider__c = identity.Id;
                        activity.Account__c = identity.Account__c;
                        activity.User__c = identity.User__c;
                        activity.Contact__c = identity.User__r.ContactId;
                       if (String.isNotBlank(activity.Contact__c)){
                            Community_Membership__c membership = contactCommunitiesMap.get(activity.Contact__c);
                            activity.CommunityMembership__c = membership.Id;
                            SageApiActivityUtils.debug('membership.Id: '+membership.Id);
                        }
                        SageApiActivityUtils.debug('Set activity artifact fields: '+activity);
                        SageApiActivityUtils.setSuccess(activity, step);
                        return true;
                    }
                } catch (Exception ex) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Locating existing user', 'Error detail: '+ex);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    return false;
                }
            }
        }
        
        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        } 

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityUtils.setSuccess(activity, step);
        SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        return true;
    }
 
    public static void createUser(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        SageApiActivityUtils.debug('SageApiAddCommUserActivityUtils.createUser starts: '+JSON.serialize(activities));

        createContacts(step, activities);
        provisionUsers(step, activities);

        SageApiActivityUtils.debug('SageApiAddCommUserActivityUtils.createUser ends: '+JSON.serialize(activities));
    }
    
    private static void createContacts(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return;
        List<Contact> contacts = new List<Contact>();

        for(SageApiActivity__c activity : activities) {
            if (String.isNotBlank(activity.Contact__c)) {
                contacts.add(new Contact(Id = activity.Contact__c));
                continue;
            }

            SageApiAddCommUserActivityRequest req = null;
            try {
                req = (SageApiAddCommUserActivityRequest)JSON.deserialize(activity.Payload__c, SageApiAddCommUserActivityRequest.class);
                if (req == null || string.isBlank(req.AccountId)) continue;
                
                Contact contact = new Contact (
                    FirstName = req.firstName,
                    LastName = req.lastName,
                    AccountId = req.AccountId,
                    Email = req.email,
                    MailingStreet = req.address1 + '\n' + req.address2,
                    MailingCity = req.city,
                    MailingStateCode = req.state,
                    MailingPostalCode = req.postalCode,
                    MailingCountryCode = req.countryCode,
                    Phone = req.phone
                );
                contacts.add(contact);
                activity.Account__c = req.AccountId;
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getRequestAccounts', ex);
            }
        }
        
        if (contacts.size() == 0) return;

        Database.UpsertResult [] contactList = Database.upsert(contacts, false);
        Integer index = 0;

        for(Database.UpsertResult result : contactList){
            SageApiActivity__c activity = activities[index];
            Contact contact = contacts[index];
            index++;

            if (result.success) {
                activity.Contact__c = result.getId();
                updateArtifact(activity, null);
                SageApiActivityUtils.debug('updateArtifact after upsert contacts: '+JSON.serialize(activity));
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createContacts', 'contact creation failed. Detail' + result.getErrors());
            SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    private static void provisionUsers(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {
        if (originalActivities == null || originalActivities.size() == 0) return;

        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        Map<ID, SageApiActivity__c> contactActivityMap = new Map<ID, SageApiActivity__c>();
        List<string> reqCommunityNames = new List<string>();
        List<string> reqCommunityRoles = new List<string>();
        List<string> reqIdentityIds = new List<string>();
        List<string> reqIdentityTypes = new List<string>();

        for (SageApiActivity__c activity : originalActivities) {
            if (String.IsNotBlank(activity.User__c) && String.IsNotBlank(activity.CommunityMembership__c) && String.IsNotBlank(activity.SageUserIdentityProvider__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            if (String.IsBlank(activity.Contact__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Contact is not created');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            try {
                SageApiAddCommUserActivityRequest request = (SageApiAddCommUserActivityRequest)JSON.deserialize(activity.payload__c, SageApiAddCommUserActivityRequest.class);
                reqIdentityIds.add(request.identityId);
                reqIdentityTypes.add(request.identityType);
                reqCommunityRoles.add(request.communityRole);
                SageApiActivityUtils.debug('request.communityType: ' + request.communityType);
                SageApiActivityUtils.debug('SageApiActivityUtils.setting_CustomerCommunityType: ' + SageApiActivityUtils.setting_CustomerCommunityType);
                SageApiActivityUtils.debug('SageApiActivityUtils.setting_PartnerCommunityName: ' + SageApiActivityUtils.setting_PartnerCommunityName);
                if (request.communityType == SageApiActivityUtils.setting_CustomerCommunityType)
                    reqCommunityNames.add(SageApiActivityUtils.setting_CustomerCommunityName);
                else if (request.communityType == SageApiActivityUtils.setting_PartnerCommunityType)
                    reqCommunityNames.add(SageApiActivityUtils.setting_PartnerCommunityName);
                else
                    reqCommunityNames.add(null);
                
                contactActivityMap.put(activity.Contact__c, activity);
                candidateActivities.add(activity);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Error detail: '+ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'provisionUsers', ex);
            }
        }

        List<Contact> candidateContacts = [SELECT ID,Account.Id,Account.name,Account.BillingCountryCode,Email,FirstName,LastName,MailingCity,MailingCountry,MailingCountryCode,MailingPostalCode,MailingState,MailingStreet,Phone FROM Contact WHERE ID in: contactActivityMap.keyset()];
        SageApiActivityUtils.debug('contacts to be processed: ' + candidateContacts);

        if (candidateContacts == null || candidateContacts.size() == 0)
            return;
        
        // community related
        // get list of reference records
        List<CommunityX__c> communityRefList = new List<CommunityX__c>();
        List<Profile> profileRefList = new List<Profile>();
        List<Community_Role__c> roleRefList = new List<Community_Role__c>();
        try {
            communityRefList = [SELECT Id, Default_User_Profile__c, Name FROM CommunityX__c];
            
            Set<string> profileNames = new Set<string>();
            Set<ID> communityIds = new Set<ID>();
            for (CommunityX__c community : communityRefList) {
                profileNames.add(community.Default_User_Profile__c);
                communityIds.add(community.Id);
            }
            
            if (profileNames.size() > 0)
                profileRefList = [SELECT Id, Name FROM Profile WHERE Name IN :profileNames];
            if (communityIds.size() > 0)
                roleRefList = [SELECT Id, Name, Community__c FROM Community_Role__c WHERE Community__c IN :communityIds];
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'CommunityX__c DML:Profile DML:Community_Role__c DML', ex);
            SageApiActivityUtils.debug('error to get CommunityX__c : Profile : Community_Role__c for reference lists: ' + ex);
        }

        // prepare for members, users, identities
        List<Community_Membership__c> members = new List<Community_Membership__c>();
        List<User> users = new List<User>();
        List<SageUserIdentityProvider__c> userIdentities = new List<SageUserIdentityProvider__c>();
        Map<ID, ID> contactToAccountMap = new Map<ID, ID>();
        List<SageApiActivity__c> memberActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> userActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> identityActivities = new List<SageApiActivity__c>();

        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, LanguageLocaleKey__c FROM Locale__c WHERE IsDeleted = false];
        
        SageApiActivityUtils.debug('reqCommunityNames: ' + reqCommunityNames);
        SageApiActivityUtils.debug('reqCommunityRoles: ' + reqCommunityRoles);
        SageApiActivityUtils.debug('reqIdentityIds: ' + reqIdentityIds);
        SageApiActivityUtils.debug('reqIdentityTypes: ' + reqIdentityTypes);        

        Integer index = -1;
        for (Contact c : candidateContacts) {
            index++;
            
            string reqCommunityName = reqCommunityNames.size() > index ? reqCommunityNames[index] : null;
            string reqCommunityRole = reqCommunityRoles.size() > index ? reqCommunityRoles[index] : null;
            string reqIdentityId = reqIdentityIds[index];
            string reqIdentityType = reqIdentityTypes[index];
            SageApiActivity__c activity = contactActivityMap.get(c.Id);
            contactToAccountMap.put(c.ID, c.AccountId);

            if (string.isBlank(reqIdentityType) || string.isBlank(reqIdentityId)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Identity ID/Type not available to create UserIdentity');
                SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            Locale__c locale = null;
            Locale__c firstLocale = null;
            Integer localeIndex = -1;
            for (Locale__c l : locales) {
                localeIndex++;
                if (l.Country_Code__c != c.Account.BillingCountryCode) continue;
                firstLocale = l;
                if (l.Default_Locale__c != 'Yes') continue;
                locale = l;
            }
            if (locale == null) locale = firstLocale;
            
            CommunityX__c reqCommunity = null;
            if (string.isNotBlank(reqCommunityName))
                reqCommunity = getCommunity(communityRefList, reqCommunityName);
            if (reqCommunity == null) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Community ['+reqCommunityName+'] not found');
                SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            
            Community_Role__c reqRole = getCommunityRole(roleRefList, reqCommunity.Id, reqCommunityRole);

            if (String.isBlank(activity.CommunityMembership__c)) {
                Community_Membership__c member = new Community_Membership__c(Contact__c = c.Id, Community__c = reqCommunity.Id);
                if (reqRole != null)
                    member.Community_Role__c = reqRole.Id;
                members.add(member);
                memberActivities.add(activity);
            }

            if (String.isBlank(activity.User__c)) {
                Profile profile = getProfile(profileRefList, reqCommunity.Default_User_Profile__c);
                User user = setUpUserRecord(c, profile, locale);
                users.add(user);
                userActivities.add(activity);
            }
            
            if (String.isNotBlank(activity.SageUserIdentityProvider__c)) continue;

            SageUserIdentityProvider__c userIdentity = new SageUserIdentityProvider__c();
            userIdentity.Account__c = c.AccountId;
            userIdentity.IdentityID__c = reqIdentityId;
            userIdentity.IdentityProvider__c = reqIdentityType;
            string bridgeId = c.AccountId + ':' + reqIdentityType + ':' + reqIdentityId;
            userIdentity.SFBridgeID__c = bridgeId;
            // name field is limited to 80 characters
            userIdentity.Name = bridgeId.length() > 80 ? bridgeId.substring(0, 80) : bridgeId;
            if (locale != null && string.isNotBlank(locale.currencyIsoCode))
                userIdentity.CurrencyIsoCode = locale.currencyIsoCode;
            userIdentities.add(userIdentity);
            identityActivities.add(activity);

        }
        
        SageApiActivityUtils.debug('users to create: '+JSON.serialize(users));
        saveCommunityUsers(step, candidateActivities, members, memberActivities, users, userActivities, userIdentities, identityActivities, contactToAccountMap);
    }

    public static Community_Role__c getCommunityRole(List<Community_Role__c> roles, ID communityId, string roleName) {
        for (Community_Role__c role : roles) {
            if (role.Community__c == communityId && role.Name.equals(roleName))
                return role;
        }
        return null;
    }

    public static Profile getProfile(List<Profile> profiles, string profileName) {
        for (Profile profile : profiles) {
            if (profile.Name.equals(profileName))
                return profile;
        }
        return null;
    }
    
    public static CommunityX__c getCommunity(List<CommunityX__c> communities, string communityName) {
        for (CommunityX__c community : communities) {
            if (community.Name.equals(communityName))
                return community;
        }
        return null;
    }
    
    public static User setUpUserRecord(Contact contact, Profile profile, Locale__c locale) {
        //Required fields: LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey
        long aNumber = datetime.now().getTime();
        String namePart = (String.isBlank(contact.LastName) ? '' : contact.LastName);
        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
        Matcher matcher = nonAlphanumeric.matcher(namePart);
        namePart = matcher.replaceAll('');
        string uniqueString = namePart+aNumber+'@community.sage.com'+SageApiActivityUtils.setting_EmailSuffix;
        String email = uniqueString.length() <= 80 ? uniqueString : uniqueString.substring(uniqueString.length()-80, uniqueString.length());
        string communityNickName = contact.LastName+aNumber;
        communityNickName = communityNickName.length() <= 40 ? communityNickName : communityNickName.substring(communityNickName.length()-40, communityNickName.length());
        User user = new User();
        user.Username = email;
        user.Email = (String.isBlank(contact.Email) ? email : contact.Email);
        user.LastName = contact.LastName;
        user.FirstName = contact.FirstName;
        String companyName = contact.Account.Name;
        companyName = (String.isNotBlank(companyName) && companyName.length()>80 ? companyName.substring(0,80) : companyName);
        user.CompanyName = companyName;
        user.Alias = (contact.LastName+aNumber).substring(0,8);
        // TODO: something to improve later
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey = ((locale == null || string.isBlank(locale.LanguageLocaleKey__c)) ? 'en_US' : locale.LanguageLocaleKey__c);
        user.LocaleSidKey = ((locale == null || string.isBlank(locale.name)) ? 'en_US' : locale.name);
        if (profile != null)
            user.ProfileId = profile.Id;
        user.TimeZoneSidKey = ((locale == null || string.isBlank(locale.TimeZone__c)) ? 'GMT' : locale.TimeZone__c);
        user.ContactId = contact.Id;
        user.CommunityNickname = communityNickName;
        // set to false to avoid consuming license
        user.IsActive = false;
        if (locale != null && string.isNotBlank(locale.currencyIsoCode)) {
            user.CurrencyIsoCode = locale.CurrencyIsoCode;
            user.DefaultCurrencyIsoCode = locale.CurrencyIsoCode;
        }
        return user;
    }
    
    public static void saveCommunityUsers(SageApiActivityStep step, List<SageApiActivity__c> activities, List<Community_Membership__c> members, List<SageApiActivity__c> memberActivities, List<User> users, List<SageApiActivity__c> userActivities, List<SageUserIdentityProvider__c> userIdentities, List<SageApiActivity__c> identityActivities, Map<ID, ID> contactToAccountMap) {
        SageApiActivityUtils.debug('saveCommunityUsers start');
        SageApiActivityUtils.debug('users: ' + users);
        SageApiActivityUtils.debug('userIdentities: ' + userIdentities);
        SageApiActivityUtils.debug('contactToAccountMap: ' + contactToAccountMap);
        SageApiActivityUtils.debug('members: ' + members);
        
        // Shekhar: Update Community Membership
        Database.UpsertResult [] memberResult = Database.upsert(members, false);
        Integer index = 0;
        for(Database.UpsertResult result : memberResult){
            Community_Membership__c member = members[index];
            SageApiActivity__c activity = memberActivities[index];
            index++;

            if (result.success) {
                activity.CommunityMembership__c = result.getID();
                updateArtifact(activity, null);
                SageApiActivityUtils.debug('updateArtifact with Members: '+JSON.serialize(activity));
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'CommunityMembershipCreation', 'Community membership failed :' + result.getErrors());
            SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);

            for (Integer i=userActivities.size()-1; i>=0; i--)
                if (userActivities[i].Id == activity.Id) {
                    users.remove(i);
                    userActivities.remove(i);
                }

            for (Integer i=identityActivities.size()-1; i>=0; i--)
                if (identityActivities[i].Id == activity.Id) {
                    userIdentities.remove(i);
                    identityActivities.remove(i);
                }
        }

        // create users
        Database.UpsertResult [] userLst = Database.upsert(users,false);
        index = 0;

        for(Database.UpsertResult result : userLst){
            User user = users[index];
            SageApiActivity__c activity = userActivities[index];
            index++;

            if (result.success) {
                activity.User__c = user.Id;
                updateArtifact(activity, null);
                SageApiActivityUtils.debug('updateArtifact after upsert users: '+JSON.serialize(activity));

                for (Integer i=0; i<identityActivities.size(); i++)
                    if (identityActivities[i].Id == activity.Id)
                        userIdentities[i].User__c = user.Id;

                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createUser', 'User creation failed. Detail' + result.getErrors());
            SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);

            for (Integer i=identityActivities.size()-1; i>=0; i--)
                if (identityActivities[i].Id == activity.Id) {
                    userIdentities.remove(i);
                    identityActivities.remove(i);
                }
        }

        Database.UpsertResult [] srIdentityLst = Database.upsert(userIdentities,false);
        index = 0;
        for(Database.UpsertResult result : srIdentityLst){
            SageUserIdentityProvider__c userIdentity = userIdentities[index];
            SageApiActivity__c activity = identityActivities[index];
            index++;

            if (result.success) {
                activity.SageUserIdentityProvider__c = userIdentity.Id;
                SageApiActivityUtils.setSuccess(activity, step);
                SageApiActivityUtils.debug('updateArtifact: '+JSON.serialize(activity));
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'UserToBridgeServerMapping', 'Creation of user to Bridge Service mapping failed. Detail' + result.getErrors());
            SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);
        }
        
        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.debug('createCommunityUsers end');
    }
    
    public static SageApiAddCommUserActivityResponse createResponse() {
        SageApiAddCommUserActivityResponse response = new SageApiAddCommUserActivityResponse();
        response.data = new SageApiAddCommUserActivityResponse.ResponseData();
        SageApiActivityUtils.debug('createResponse: '+JSON.serialize(response));
        return response;
    }

    public static void updateArtifact(SageApiActivity__c activity, List<SageApiActivityError> errors) {
        SageApiAddCommUserActivityResponse response = null;
        if (String.isNotBlank(activity.Artifacts__c))
            response = (SageApiAddCommUserActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiAddCommUserActivityResponse.class);
        if (response == null)
            response = createResponse();
        
        response.activityId = activity.ActivityID__c;
        response.status = activity.ActivityStatus__c;
        response.errors = errors;
        response.data.accountId = String.ValueOf(activity.Account__c);
        response.data.contactId = String.ValueOf(activity.Contact__c);
        response.data.communityMembershipId = activity.CommunityMembership__c;
        response.data.userId = String.ValueOf(activity.User__c);
        response.data.bridgeServiceId = String.ValueOf(activity.SageUserIdentityProvider__c);
        
        string artifact = JSON.serialize(response);
        if (artifact.length() > 131072)
            artifact = artifact.substring(0, 131060) + '.TRUNCATED.';
        activity.Artifacts__c = artifact;
        SageApiActivityUtils.debug('activity.Artifacts__c: '+activity.Artifacts__c);
    }

    public static Map<Id, Account> getValidRequestAccounts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Account> accounts = new Map<Id, Account>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiAddCommUserActivityRequest req = null;
            try {
                req = (SageApiAddCommUserActivityRequest)JSON.deserialize(payload, SageApiAddCommUserActivityRequest.class);
                if (req == null || string.isBlank(req.AccountId)) continue;

                accounts.put(req.AccountId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getRequestAccounts', ex);
            }
        }

        if (accounts.size() == 0 ) return null;

        try {
            accounts.putAll([SELECT Id, RecordTypeId FROM Account WHERE Id IN :accounts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getRequestAccounts', ex);
        }

        return accounts;
    }

    public static Map<Id, Contact> getValidRequestContacts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Contact> contacts = new Map<Id, Contact>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiAddCommUserActivityRequest req = null;
            try {
                req = (SageApiAddCommUserActivityRequest)JSON.deserialize(payload, SageApiAddCommUserActivityRequest.class);
                if (req == null || string.isBlank(req.ContactId)) continue;

                contacts.put(req.ContactId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getValidRequestContacts', ex);
            }
        }

        if (contacts.size() == 0 ) return null;

        try {
            contacts.putAll([SELECT Id, AccountId FROM Contact WHERE Id IN :contacts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getValidRequestContacts', ex);
        }

        return contacts;
    }

    public static Map<string, SageUserIdentityProvider__c> getValidRequestIdentities(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;
            
            SageApiAddCommUserActivityRequest req = null;
            try {
                req = (SageApiAddCommUserActivityRequest)JSON.deserialize(payload, SageApiAddCommUserActivityRequest.class);
                if (req == null || string.isBlank(req.AccountId)  || string.isBlank(req.identityId) || string.isBlank(req.identityType)) continue;

                identities.put(ID.valueOf(req.AccountId)+':'+req.identityType+':'+req.identityId, null);
             } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getRequestAccounts', ex);
            }
        }
        
        if (identities.size() == 0 ) return null;
        
        try {
            identities.putAll([SELECT Id, SFBridgeID__c, Account__c, User__c, User__r.ContactId FROM SageUserIdentityProvider__c WHERE SFBridgeID__c != '' AND SFBridgeID__c IN :identities.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getRequestIdentities', ex);
        }
        
        return identities;
    }

    public static Map<ID, Community_Membership__c> getValidRequestContactUserCommunity(List<ID> contactIds) {
        SageApiActivityUtils.debug('SageApiActivityUtils.setting_CustomerCommunityName: '+SageApiActivityUtils.setting_CustomerCommunityName);
        List<Community_Membership__c> memberships = [SELECT Id, Contact__c FROM Community_Membership__c WHERE Community__r.Name =: SageApiActivityUtils.setting_CustomerCommunityName AND Contact__c IN: contactIds];
        if (memberships == null || memberships.size() == 0) return null;

        Map<ID, Community_Membership__c> membershipMap = new Map<ID, Community_Membership__c>();
        for (Community_Membership__c membership : memberships)
            membershipMap.put(membership.Contact__c, membership);

        return membershipMap;
    }
 
    public static List<Community_Role__c> getValidRequestCommunityRoles() {
        List<Community_Role__c> roles = new List<Community_Role__c>();
        
        try {
            roles = [SELECT Id, Name FROM Community_Role__c WHERE IsDeleted = false];
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'getValidRequestCommunityRoles', ex);
        }
        
        return roles;
    }
}