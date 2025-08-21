public class SageApiSubscriptionActivityUtils {
    public static final string ErrorToLockAndUpdateSM = 'Another event is in the process of updating subscription master';
/*
    public static void start(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();

        for(SageApiActivity__c activity : activities) {
            if (activity == null || step == null) continue;
            System.debug('Step.stepStatus: '+Step.stepStatus);

            SageApiActivityUtils.setPending(activity, step);
            SageApiActivityUtils.debug('Pending activity.start: '+JSON.serialize(activity));
            SageApiActivityLog__c log = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, LogSource__c=(step.stepId==1?'Activity.Prepare':'Activity.InProgress'), LogMessage__c=JSON.serialize(activity), LogTime__c=Datetime.Now());
            logs.add(log);
        }

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.log(logs);
    }
*/
    public static void validateCreateSubscriptionV2Payload(SageApiActivityStep step, List<SageApiActivity__c> activities, Boolean validationOnly, Boolean activityStarted) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);
        List<Account> accounts = getActivityAccounts(activities);
        List<Contact> contacts = getActivityContacts(activities);
        List<Subscription_Master__c> existingSmsFromGroupId = getActivitySubscriptionMasterFromGroupId(activities);

        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateCreateSubscriptionV2Payload(step, activity, validationOnly, activityStarted, platforms, partners, accounts, contacts, existingSmsFromGroupId);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }
            SageApiActivityUtils.setSuccess(activity, step);
            activity.ActivityStatus__c = SageApiStatus.InProgressExternal;
            SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        }

        if (!validationOnly)
            SageApiActivityUtils.updateActivities(activities);
    }

    public static List<SageApiActivityError> validateCreateSubscriptionV2Payload(SageApiActivityStep step, SageApiActivity__c activity, Boolean validationOnly, Boolean activityStarted, Map<String, ChannelPlatform__c> platforms, Map<String, ChannelPartner__c> partners, List<Account> accounts, List<Contact> contacts, List<Subscription_Master__c> existingSmsFromGroupId) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (String.isBlank(activity.payload__c)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is required');
            return errors;
        }

        SageApiActivityRequestObjects.SubscriptionAllData req = null;
        try {
            req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateCreateSubscriptionV2Payload', ex);
            return errors;
        }

        if (String.isBlank(activity.ChannelPlatformProvided__c))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Channel Platform', ' Channel Platform is required');

        if (String.isBlank(activity.ChannelPartnerProvided__c))
            activity.ChannelPartnerProvided__c = activity.ChannelPlatformProvided__c;

        if (string.isNotBlank(activity.ChannelPlatformProvided__c)) {
            ChannelPlatform__c platform = platforms.get(activity.ChannelPlatformProvided__c.toUpperCase());
            if (platform == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Channel Platform', ' Channel Platform is invalid ['+activity.ChannelPlatformProvided__c+ ']');
        }

        if (String.isNotBlank(activity.ChannelPartnerProvided__c)) {
            ChannelPartner__c partner = partners.get(activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase());
            if (partner == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Channel Partner', ' Channel Partner is invalid ['+activity.ChannelPartnerProvided__c+ ']');
            else
                    activity.ChannelPartner__c = partner.Id;
        }

        if (req != null) {
            if (activityStarted) {
                if (String.isBlank(req.subscriptionId)) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Subscription ID', 'subscriptionId is required');
                } else {
                    activity.SubscriptionId__c = req.subscriptionId;
                }

                if (String.isBlank(req.state))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'State', 'state is required');

                if (req.entitlement == null || String.isBlank(req.entitlement.entitlementId))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Entitlement ID', 'entitlementId is required');
                else
                        activity.EntitlementId__c = req.entitlement.entitlementId;
            }

            if (String.isBlank(activity.SubscriptionGroupId__c) && String.isBlank(req.subscriptionGroupId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Subscription Group ID', 'subscriptionGroupId is required');
            } else if (String.isBlank(activity.SubscriptionGroupId__c)) {
                // existing id needs verification
                activity.SubscriptionGroupId__c = req.subscriptionGroupId;

                if (existingSmsFromGroupId==null || existingSmsFromGroupId.size() == 0) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Subscription Group ID', 'The provided subscriptionGroupId is not valid ['+activity.SubscriptionGroupId__c+ ']');
                } else {
                    Boolean validGroupId = false;
                    for (Subscription_Master__c sm : existingSmsFromGroupId) {
                        if (sm.SubscriptionGroupId__c == activity.SubscriptionGroupId__c) {
                            validGroupId = true;
                            break;
                        }
                    }
                    if (! validGroupId)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Subscription Group ID', 'The provided subscriptionGroupId is not valid (no matching) ['+activity.SubscriptionGroupId__c+ ']');
                }
            }

            activity.ClientRef__c = req.clientRef;

            if (!validationOnly && (req.managingAccount == null || String.isBlank(req.managingAccount.id))) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Managing Account ID', 'managingAccount.id is required');
            } else if (req.managingAccount != null && String.isNotBlank(req.managingAccount.id)) {
                if (isValidAccount(accounts, req.managingAccount.id))
                    activity.ManagingAccount__c = ID.valueOf(req.managingAccount.id);
                else
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Managing Account ID', 'managingAccount.id is invalid ['+req.managingAccount.id+ ']');
            }

            if (!validationOnly && (req.entitledAccount == null || String.isBlank(req.entitledAccount.id))) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Entitled Account ID', 'entitledAccount.id is required');
            } else if (req.entitledAccount != null && String.isNotBlank(req.entitledAccount.id)) {
                if (isValidAccount(accounts, req.entitledAccount.id)) {
                    activity.AccountId__c = req.entitledAccount.id;
                    activity.AccountIdType__c = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
                    activity.Account__c = ID.valueOf(req.entitledAccount.id);
                } else {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Entitled Account ID', 'entitledAccount.id is invalid ['+req.entitledAccount.id+ ']');
                }
            }

            if (req.partner != null && (req.partner.account != null || req.partner.contact != null)) {
                if (!validationOnly && (req.partner.account == null || req.partner.contact == null || String.isBlank(req.partner.account.id) || String.isBlank(req.partner.contact.id))) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Partner Account/Contact', 'Both partner.account.id and partner.contact.id must be provided at the same time');
                } else {
                    if (String.isNotBlank(req.partner.account.id)) {
                        if (isValidAccount(accounts, req.partner.account.id))
                            activity.PartnerAccount__c = ID.valueOf(req.partner.account.id);
                        else
                                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Partner Account ID', 'partner.account.id is invalid ['+req.partner.account.id+ ']');
                    }
                    if (String.isNotBlank(req.partner.contact.id)) {
                        if (isValidContact(accounts, contacts, req.partner.contact.id))
                            activity.PartnerContact__c = ID.valueOf(req.partner.contact.id);
                        else
                                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Partner Contact ID', 'partner.contact.id is invalid ['+req.partner.contact.id+ ']');
                    }
                }
            }

            if (!validationOnly && (req.customerContact == null || String.isBlank(req.customerContact.id))) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Customer Contact ID', 'customerContact.id is required');
            } else if (req.customerContact != null && String.isNotBlank(req.customerContact.id)) {
                if (isValidContact(accounts, contacts, req.customerContact.id)) {
                    activity.ContactId__c = req.customerContact.id;
                    activity.ContactIdType__c = SageApiActivityRequestObjects.IdentifierType.Salesforce.name();
                    activity.Contact__c = ID.valueOf(req.customerContact.id);
                } else {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Customer Contact ID', 'customerContact.id is invalid ['+req.customerContact.id+ ']. Please make sure it exists and its associated account data is also provided in the payload.');
                }
            }

            if (req.customerCommunityUsers != null) //{
                //SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Customer Community Users', 'customerCommunityUsers is required');
                //SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                //} else {
                for (SageApiActivityRequestObjects.CommunityUser user : req.customerCommunityUsers)
                    if (String.isNotBlank(user.contactId) && ! isValidContact(accounts, contacts, user.contactId))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Customer Community Users', 'contactId is invalid ['+user.contactId+']. Please make sure it exists and its associated account data is also provided in the payload.');
            //}

            if (req.effectivePeriod == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Effective Period', 'effectivePeriod is required');
            } else {
                if (String.isBlank(req.effectivePeriod.notBefore))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Not Before (Effective Period)', 'effectivePeriod.notBefore is required');

                if (String.isBlank(req.effectivePeriod.notAfter))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Not After (Effective Period)', 'effectivePeriod.notAfter is required');

                Date notBefore = Date.newInstance(2000, 1, 2);
                Date notAfter = Date.newInstance(2000, 1, 1);

                if (String.isNotBlank(req.effectivePeriod.notBefore)) {
                    try {
                        String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                        Date pdtNowDate = Date.valueOf(pdtDateNowString);
                        notBefore = Date.valueOf(req.effectivePeriod.notBefore);
                    } catch (Exception ex) {
                        ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notBefore', 'notBefore not in valid format ['+req.effectivePeriod.notBefore+ ']');
                    }
                }

                if (String.isNotBlank(req.effectivePeriod.notAfter)) {
                    try {
                        String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                        Date pdtNowDate = Date.valueOf(pdtDateNowString);
                        notAfter = Date.valueOf(req.effectivePeriod.notAfter);
                    } catch (Exception ex) {
                        ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notAfter', 'notAfter not in valid format ['+req.effectivePeriod.notAfter+ ']');
                    }
                }

                if (notAfter < notBefore)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Not After (Effective Period)', 'effectivePeriod.notAfter ['+req.effectivePeriod.notAfter+ '] cannot be before effectivePeriod.notBefore ['+req.effectivePeriod.notBefore+ ']');
            }

            if (req.products == null || req.products.isEmpty())
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Products', 'products is required');
            else {
                String ids = null;
                for (SageApiActivityRequestObjects.ProductRequest pReq : req.products)
                    if (String.isNotBlank(pReq.product))
                        ids = (String.isBlank(ids) ? '' : ids + ';') + pReq.product;

                if (String.isBlank(ids))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'product', 'Entitlement Product Identifier not provided');
                else
                        activity.ProductNames__c = ids;
            }

            if (String.isBlank(activity.SubscriptionId__c) && String.isNotBlank(req.subscriptionId))
                activity.SubscriptionId__c = req.subscriptionId;
            if (String.isBlank(activity.EntitlementId__c) && req.entitlement != null && String.isNotBlank(req.entitlement.entitlementId))
                activity.EntitlementId__c = req.entitlement.entitlementId;
           
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            return errors;
        }

        return null;
    }

    public static void validateCreateSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivityRequestObjects.Product> requestedProducts = getRequestProducts(activities);
        List<Product_Tier__c> productTiers = SageApiActivityUtils.getProductTiers(requestedProducts);
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(requestedProducts);
        Map<Id, Lead> leadMap = getRequestLeads(activities);
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(requestedProducts);
        Map<String, Account> accounts = getValidRequestAccounts(activities);
        Map<String, Contact> contacts = getValidRequestContacts(activities);
        Map<string, SageUserIdentityProvider__c> identities = getValidRequestIdentities(activities);

        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        activities = validateAndMapToInternalAccounts(activities);
        activities = validateAndMapToInternalContacts(activities);

        Map<ID, String> activitySubIdMap = getActivityCbcSubscriptionIds(activities);
        Map<String, Subscription_Master__c> subMasterMap = null;
        Map<String, List<Entitlement_Message__c>> messageMap = null;
        if (activitySubIdMap != null && activitySubIdMap.size() > 0) {
            subMasterMap = getSubscriptionMasters(activitySubIdMap.values());
            messageMap = getEntitlementMessages(activitySubIdMap.values());
        }

        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);

        for(SageApiActivity__c activity : activities) {
            if (activity == null || step == null) continue;
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                continue;
            }

            if (req.subscription == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'subscription', 'subscription is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isBlank(activity.ChannelPlatformProvided__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'source (Channel Platform)', ' Channel Platform value is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isBlank(activity.ChannelPartnerProvided__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'salesChannel (Channel Partner)', ' Channel Partner value is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            ChannelPlatform__c platform = platforms.get(activity.ChannelPlatformProvided__c.toUpperCase());
            if (platform == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'source (Channel Platform)', ' Channel Platform value is invalid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            ChannelPartner__c partner = partners.get(activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase());
            if (partner == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'salesChannel (Channel Partner)', ' Channel Partner value is invalid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            activity.ChannelPartner__c = partner.Id;

            // validate root-level attributes
            if (String.isBlank(req.subscription.startDate))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'startDate', 'Start Date is required');

            Date startDate = Date.newInstance(2000, 1, 1);
            Date endDate = Date.newInstance(2000, 1, 1);

            if (String.isNotBlank(req.subscription.startDate)) {
                try {
                    String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                    Date pdtNowDate = Date.valueOf(pdtDateNowString);
                    startDate = Date.valueOf(req.subscription.startDate);

                    // allow 1 day to offset timezone difference
                    if (startDate.addDays(1) < pdtNowDate)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'startDate', 'Start Date cannot be a past date');
                } catch (Exception ex) {
                    ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'startDate', 'Start Date not in valid format');
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    continue;
                }
            }

            if (String.isNotBlank(req.subscription.endDate)) {
                try {
                    endDate= Date.valueOf(req.subscription.endDate);

                    if (endDate < startDate) {
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date must be later than Start Date');
                    }
                } catch (Exception ex) {
                    ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date not in valid format');
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    continue;
                }
            }

            SageApiActivityRequestObjects.Account account = req.account;
            if (account == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'account', 'Account is required');

            if (account != null) {
                if (String.isBlank(account.accountId) && String.isBlank(account.name))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'name', 'Account Name is required');

                if (String.isNotBlank(account.accountType) && String.isBlank(account.accountId))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'accountId', 'Account Id is not provided');

                if (String.isNotBlank(account.accountId))
                    if (! SageApiActivityUtils.identifierTypeExists(account.accountType))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'accountType', 'Account Type is not valid');

                if (activity.accountIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) {
                    Boolean matched = false;
                    if (accounts != null && accounts.size() > 0)
                        for(Account c : accounts.values()) {
                            if (c == null || c.Id != activity.AccountId__c) continue;
                            matched = true;
                            break;
                        }

                    if (accounts == null || accounts.size() == 0 || ! matched)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'Provided Salesforce Account ID does not exist');
                }
            }

            SageApiActivityRequestObjects.Contact contact = req.contact;
            if (contact == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contact', 'Contact is required');

            if (contact != null) {
                if (String.isNotBlank(contact.contactId) && ! SageApiActivityUtils.identifierTypeExists(contact.contactType))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contactType', 'Contact Type is not valid');

                if (String.isBlank(contact.identityType))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityType', 'Identity Type is required');

                if (String.isBlank(contact.identityId))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityId', 'Identity ID is required');

                if (String.isBlank(contact.contactId) || (String.isNotBlank(contact.contactId) && contact.contactType == SageApiActivityRequestObjects.IdentifierType.Salesforce.name())) {
                    if (String.isBlank(contact.firstName))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required when Lead id is not provided');

                    if (String.isBlank(contact.lastName))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required when Lead id is not provided');

                    if (String.isBlank(contact.email))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'email', 'Email is required when Lead id is not provided');
                }

                if (String.isNotBlank(contact.email)) activity.ContactEmail__c = contact.email;

                if (activity.contactIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) {
                    Boolean matched = false;
                    if (contacts != null && contacts.size() > 0)
                        for(Contact c : contacts.values()) {
                            if (c == null || c.Id != activity.ContactId__c) continue;
                            matched = true;
                            break;
                        }

                    if (contacts == null || contacts.size() == 0 || ! matched)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ContactId', 'Provided Salesforce Contact ID does not exist');
                }
            }

            if (String.isNotBlank(activity.Contact__c) && String.isBlank(activity.Account__c))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'contactId', 'The Contact ID provided is already linked to a different account');

            if (identities != null && identities.size() > 0 && String.isNotBlank(activity.Account__c) && String.isNotBlank(activity.Contact__c) && req.contact != null && String.isNotBlank(req.contact.identityType) && String.isNotBlank(req.contact.identityId)) {
                String sfBrdigeId = ID.valueOf(activity.Account__c) + ':' + req.contact.identityType + ':' + req.contact.identityId;
                SageApiActivityUtils.debug('sfBrdigeId: '+sfBrdigeId);
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
                    break;
                }
            }

            // validate products
            List<SageApiActivityRequestObjects.Product> products = req.subscription.products;

            if (products != null) {
                if (products.size() > 1)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.ValueOutOfRange, 'tierCode', 'Only one Product Tier Code is supported');

                if (products.size() > 0 && String.IsBlank(products[0].tierCode))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code is required');

                if ((activity.ActivityType__c == SageApiActivityTriggerHandler.TryNowActivityType) && products.size() > 0 && String.IsBlank(products[0].tierRatePlanCode))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code is required');

                if (products.size() > 0 && String.IsNotBlank(products[0].pricingCode)) {
                    List<PricingCodeCharge__c> pricingCharges = pricingChargeMap.get(products[0].tierCode+':'+products[0].tierRatePlanCode+':'+products[0].pricingCode);
                    if (pricingCharges == null || pricingCharges.size() == 0)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'pricingCharges', 'Pricing code [' +products[0].pricingCode+ '] is not configured properly.');
                }

                Boolean hasMatchingPt = false;
                for (Product_Tier__c pt : productTiers) {
                    if (pt != null && pt.Product_Tier_Code__c == products[0].tierCode) {
                        hasMatchingPt = true;
                        activity.ProductTier__c = pt.Id;
                        break;
                    }
                }

                if (!hasMatchingPt)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code not found');

                if (listTierMap != null && products.size() > 0 && String.IsNotBlank(products[0].tierRatePlanCode)) {
                    Boolean hasMatchingPtrp = false;
                    SageApiActivityUtils.debug('products[0]: ' + products[0]);
                    for (Product_Tier_Rate_Plan__c ptrp : listTierMap.values()) {
                        if (products[0] != null && ptrp != null && ptrp.Product_Tier__r != null && ptrp.Product_Tier__r.Product_Tier_Code__c == products[0].tierCode && ptrp.name == products[0].tierRatePlanCode) {
                            hasMatchingPtrp = true;
                            activity.ProductTierRatePlan__c = ptrp.Id;
                            break;
                        }
                    }

                    if (!hasMatchingPtrp)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code not found');
                }
            }

            // check existing cbcSubscriptionId
            String subId = activitySubIdMap.get(activity.Id);
            if (subId != null) {
                Subscription_Master__c sm = subMasterMap.get(subId);

                if (sm != null) {
                    if (String.isNotBlank(activity.SubscriptionMaster__c) && activity.SubscriptionMaster__c != sm.Id)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'subscriptionMaster', 'The subscription master record linked to the cbcSubscriptionId does not match that linked to activity');
                    else {
                        activity.SubscriptionMaster__c = sm.Id;

                        if (activity.Account__c != sm.Account__c)
                            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'subscriptionMaster', 'The account linked to subscription master record does not match that linked to activity');

                        if (sm.Is_Blocked__c) {
                            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'New subscription cannot be created while an existing subscription is in blocked state');
                            //SageApiActivityUtils.setError(activity, step, SageApiStatus.Abandoned, errors);
                        }

                        if (!sm.Is_Cancelled__c) {
                            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The account has already subscribed to this product');
                            //SageApiActivityUtils.setError(activity, step, SageApiStatus.Abandoned, errors);
                        }
                    }
                }
            }

            if (errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == account.accountType && String.isNotBlank(account.accountId))
                activity.Account__c = account.accountId;
            if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == contact.contactType && String.isNotBlank(contact.contactId))
                activity.Contact__c = contact.contactId;
            if (String.isNotBlank(req.paymentUrl))
                activity.paymentUrl__c = req.paymentUrl;
            activity.ActivityStatus__c = SageApiStatus.InProgress;
            SageApiActivityUtils.setSuccess(activity, step);
            SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void validateDeleteSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);

        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateActivity(step, activity, platforms, partners);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, false, subActivityMap);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static void validateSuspendSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);

        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateActivity(step, activity, platforms, partners);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, false, subActivityMap);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static void validateReactivateSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);

        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateActivity(step, activity, platforms, partners);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, false, subActivityMap);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static void validateConvertSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);
        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();

        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateActivity(step, activity, platforms, partners);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            errors = validateConvertSubscriptionPayload(step, activity);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, false, subActivityMap);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static List<SageApiActivityError> validateConvertSubscriptionPayload(SageApiActivityStep step, SageApiActivity__c activity) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (String.isBlank(activity.Payload__c)) return null;

        SageApiActivityRequestObjects.SubscriptionRequest req = null;
        try {
            req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateConvertSubscriptionPayload', ex);
            return errors;
        }

        if (req.effectivePeriod == null)
            return null;

        Date notBefore = Date.newInstance(2000, 1, 1);
        Date notAfter = Date.newInstance(2000, 1, 1);

        if (String.isNotBlank(req.effectivePeriod.notBefore)) {
            try {
                String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                Date pdtNowDate = Date.valueOf(pdtDateNowString);
                notBefore = Date.valueOf(req.effectivePeriod.notBefore);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notBefore', 'notBefore not in valid format ['+req.effectivePeriod.notBefore+ ']');
                return errors;
            }
        }

        if (String.isNotBlank(req.effectivePeriod.notAfter)) {
            try {
                String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                Date pdtNowDate = Date.valueOf(pdtDateNowString);
                notAfter = Date.valueOf(req.effectivePeriod.notAfter);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notAfter', 'notAfter not in valid format ['+req.effectivePeriod.notAfter+ ']');
                return errors;
            }
        }

        if (String.isNotBlank(req.effectivePeriod.notBefore) && String.isNotBlank(req.effectivePeriod.notAfter) && notAfter < notBefore) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Not After (Effective Period)', 'effectivePeriod.notAfter ['+req.effectivePeriod.notAfter+ '] cannot be before effectivePeriod.notBefore ['+req.effectivePeriod.notBefore+ ']');
            return errors;
        }
        return null;
    }

    public static void validateRegradeSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities, Boolean activityStarted) {
        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);

        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateActivity(step, activity, platforms, partners);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            errors = validateRegradeSubscriptionPayload(step, activity, activityStarted);
            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, activityStarted, subActivityMap);
        if (activityStarted)
            SageApiActivityUtils.updateActivities(activities);
    }

    public static List<SageApiActivityError> validateRegradeSubscriptionPayload(SageApiActivityStep step, SageApiActivity__c activity, Boolean activityStarted) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (String.isBlank(activity.payload__c)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is required');
            return errors;
        }

        SageApiActivityRequestObjects.SubscriptionAllData req = null;
        try {
            req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateRegradeSubscriptionPayload', ex);
            return errors;
        }

        if (activityStarted) {
            if (String.isBlank(req.state))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'State', 'state is required');

            if (req.entitlement == null || String.isBlank(req.entitlement.entitlementId))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Entitlement ID', 'entitlementId is required');
            else
                    activity.EntitlementId__c = req.entitlement.entitlementId;

            if (errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                return errors;
            }
        }

        // validate products
        if (req.products == null || req.products.isEmpty())
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Products', 'No product is provided');
        else {
            String ids = null;
            for (SageApiActivityRequestObjects.ProductRequest pReq : req.products)
                if (String.isNotBlank(pReq.product))
                    ids = (String.isBlank(ids) ? '' : ids + ';') + pReq.product;

            if (String.isBlank(ids))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'product', 'No product identifier is provided');
            else
                    activity.ProductNames__c = ids;
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            return errors;
        }
        return null;
    }

    public static void validateUpdateSubscriptionEffectivePeriodPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, SageApiActivity__c> subActivityMap = new Map<String, SageApiActivity__c>();
        for(SageApiActivity__c activity : activities) {
            if (activity == null) continue;
            List<SageApiActivityError> errors = validateUpdateSubscriptionEffectivePeriodPayload(step, activity);

            if (errors != null && errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionId__c, activity);
        }

        locateAndCopyActivityData(step, activities, false, subActivityMap);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static List<SageApiActivityError> validateUpdateSubscriptionEffectivePeriodPayload(SageApiActivityStep step, SageApiActivity__c activity) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (String.isBlank(activity.SubscriptionId__c)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Activity', 'SubscriptionId is required');
            return errors;
        }

        SageApiActivityRequestObjects.SubscriptionRequest req = null;
        try {
            req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateUpdateSubscriptionEffectivePeriodPayload', ex);
            return errors;
        }

        if (req.effectivePeriod == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Effective Period', 'effectivePeriod is required');
            return errors;
        }

        if (String.isBlank(req.effectivePeriod.notAfter)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Not After (Effective Period)', 'effectivePeriod.notAfter is required');
            return errors;
        }

        Date notBefore = Date.newInstance(2000, 1, 1);
        Date notAfter = Date.newInstance(2000, 1, 1);

        if (String.isNotBlank(req.effectivePeriod.notBefore)) {
            try {
                String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                Date pdtNowDate = Date.valueOf(pdtDateNowString);
                notBefore = Date.valueOf(req.effectivePeriod.notBefore);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notBefore', 'notBefore not in valid format ['+req.effectivePeriod.notBefore+ ']');
                return errors;
            }
        }

        if (String.isNotBlank(req.effectivePeriod.notAfter)) {
            try {
                String pdtDateNowString = DateTime.now().formatGmt('yyyy-MM-dd');
                Date pdtNowDate = Date.valueOf(pdtDateNowString);
                notAfter = Date.valueOf(req.effectivePeriod.notAfter);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validatePayload', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'notAfter', 'notAfter not in valid format ['+req.effectivePeriod.notAfter+ ']');
                return errors;
            }
        }

        if (notAfter < notBefore) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Not After (Effective Period)', 'effectivePeriod.notAfter ['+req.effectivePeriod.notAfter+ '] cannot be before effectivePeriod.notBefore ['+req.effectivePeriod.notBefore+ ']');
            return errors;
        }

        return null;
    }

    public static void validateCreateAccountPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, Account> accounts = getValidRequestAccounts(activities);
        Map<String, Contact> contacts = getValidRequestContacts(activities);
        activities = validateAndMapToInternalAccounts(activities);
        activities = validateAndMapToInternalContacts(activities);

        for(SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            if (activity == null || step == null) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateCreateAccountPayload', ex);
                continue;
            }

            SageApiActivityRequestObjects.Account account = req.account;
            if (account == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'account', 'Account is required');

            if (account != null) {
                if (String.isBlank(account.accountId) && String.isBlank(account.name))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'name', 'Account Name is required');

                if (String.isNotBlank(account.accountId))
                    if (! SageApiActivityUtils.identifierTypeExists(account.accountType))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'accountType', 'Account Type is not valid');

                if (activity.accountIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) {
                    Boolean matched = false;
                    if (accounts != null && accounts.size() > 0)
                        for(Account c : accounts.values()) {
                            if (c == null || c.Id != activity.AccountId__c) continue;
                            matched = true;
                            break;
                        }

                    if (accounts == null || accounts.size() == 0 || ! matched)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'Provided Salesforce Account ID does not exist');
                }
            }

            SageApiActivityRequestObjects.Contact contact = req.contact;
            if (contact == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contact', 'Contact is required');

            if (contact != null) {
                if (String.isNotBlank(contact.contactId) && ! SageApiActivityUtils.identifierTypeExists(contact.contactType))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contactType', 'Contact Type is not valid');

                if (String.isBlank(contact.identityType))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityType', 'Identity Type is required');

                if (String.isBlank(contact.identityId))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityId', 'Identity ID is required');

                if (String.isBlank(contact.contactId) || (String.isNotBlank(contact.contactId) && contact.contactType == SageApiActivityRequestObjects.IdentifierType.Salesforce.name())) {
                    if (String.isBlank(contact.firstName))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required when Lead id is not provided');

                    if (String.isBlank(contact.lastName))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required when Lead id is not provided');

                    if (String.isBlank(contact.email))
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'email', 'Email is required when Lead id is not provided');
                }

                if (String.isNotBlank(contact.email)) activity.ContactEmail__c = contact.email;

                if (activity.contactIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) {
                    Boolean matched = false;
                    if (contacts != null && contacts.size() > 0)
                        for(Contact c : contacts.values()) {
                            if (c == null || c.Id != activity.ContactId__c) continue;
                            matched = true;
                            break;
                        }

                    if (contacts == null || contacts.size() == 0 || ! matched)
                        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ContactId', 'Provided Salesforce Contact ID does not exist');
                }
            }

            if (errors.size() > 0) {
                SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == account.accountType && String.isNotBlank(account.accountId))
                activity.Account__c = account.accountId;
            if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == contact.contactType && String.isNotBlank(contact.contactId))
                activity.Contact__c = contact.contactId;
            activity.ActivityStatus__c = SageApiStatus.InProgress;
            SageApiActivityUtils.setSuccess(activity, step);
            SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void validateUpdateSubscriptionPayload(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<ID, String> activitySubIdMap = getActivityCbcSubscriptionIds(activities);
        if (activitySubIdMap == null || activitySubIdMap.size() == 0) {
            for (SageApiActivity__c activity : activities) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid: cbcSubscriptionId is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            SageApiActivityUtils.updateActivities(activities);
            return;
        }

        Map<String, Subscription_Master__c> subMasterMap = getSubscriptionMasters(activitySubIdMap.values());
        Map<String, List<Entitlement_Message__c>> messageMap = getEntitlementMessages(activitySubIdMap.values());
        Map<ID, List<SageApiActivityRequestObjects.Product>> productMap = getActivityProducts(activities);
        String actionValues = '';
        for (SageApiActivityRequestObjects.ActivityAction a : SageApiActivityRequestObjects.ActivityAction.values())
            actionValues = String.isBlank(actionValues) ? a.name() : actionValues + ', ' + a.name();

        Map<String, ChannelPlatform__c> platforms = getActivityPlatforms(activities);
        Map<String, ChannelPartner__c> partners = getActivityPartners(activities);
        List<Subscription_Master__c> smsToUpdate = new List<Subscription_Master__c>();

        for(SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            if (activity == null || step == null) continue;

            if (String.isBlank(activity.ActivityAction__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ActivityAction__c', 'ActivityAction__c is required. Possible values ['+actionValues+']');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            //if (! SageApiActivityUtils.activityActionExists(activity.ActivityAction__c)) {
            //    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ActivityAction__c', 'ActivityAction__c is not valid. Possible values ['+actionValues+']');
            //    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            //  continue;               
            //}

            String subId = activitySubIdMap.get(activity.Id);
            if (subId == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'cbcSubscriptionId', 'cbcSubscriptionId is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            Subscription_Master__c sm = subMasterMap.get(subId);
            if (sm == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'cbcSubscriptionId', 'cbcSubscriptionId is not valid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isBlank(activity.ChannelPlatformProvided__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'source (Channel Platform)', ' Channel Platform value is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isBlank(activity.ChannelPartnerProvided__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'salesChannel (Channel Partner)', ' Channel Partner value is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            ChannelPlatform__c platform = platforms.get(activity.ChannelPlatformProvided__c.toUpperCase());
            if (platform == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'source (Channel Platform)', ' Channel Platform value is invalid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            ChannelPartner__c partner = partners.get(activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase());
            if (partner == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'salesChannel (Channel Partner)', ' Channel Partner value is invalid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (sm.ChannelPartner__c != partner.Id) {
                sm.ChannelPartner__c = partner.Id;
                smsToUpdate.add(sm);
            }

            activity.ChannelPartner__c = partner.Id;
            activity.SubscriptionMaster__c = sm.Id;
            activity.Account__c = sm.Account__c;
            activity.Contact__c = sm.Sage_API_Activity__r.Contact__c;
            activity.AccountId__c = sm.Sage_API_Activity__r.AccountId__c;
            activity.AccountIdType__c = sm.Sage_API_Activity__r.AccountIdType__c;
            List<SageApiActivityRequestObjects.Product> products = productMap.get(activity.Id);

            //if (sm.ChannelPartner__r.ChannelPartnerKey__c.toUpperCase() != activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase()) {
            //    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, SageApiActivityErrorCodes.InvalidValue, 'The Channel Platform and Channel Partner provided do not match those when the subscripton was first created');
            //    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            //  continue;               
            //}
            //activity.ChannelPartner__c = sm.ChannelPartner__c;

            if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Block.name() && (sm.Is_Blocked__c || sm.Is_Cancelled__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The state of the subscription would not be changed by this update');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Unblock.name() && (!sm.Is_Blocked__c || sm.Is_Cancelled__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The state of the subscription would not be changed by this update');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Cancel.name() && sm.Is_Cancelled__c) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The subscription has already been cancelled');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Reactivate.name() && !sm.Is_Cancelled__c) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The state of the subscription would not be changed by this update');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Convert.name() && sm.Status__c == 'Active') {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The state of the subscription is not in trial');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Upgrade.name()) {
                if (!sm.Is_ZProduct_Upgradeable__c) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The current product is not upgradeable');
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                } else if (!products.isEmpty() && sm.Product_Tier__r.UpgradeToProductTier__c != products[0].tierCode) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The current product can only be upgraded to '+sm.Product_Tier__r.UpgradeToProductTier__c+', instead of '+products[0].tierCode );
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                } else if (String.isBlank(sm.Product_Tier__r.UpgradeToProductTier__c)) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Invalid Operation', 'The current product is not configured for upgrade');
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                }

                continue;
            }

            //List<Entitlement_Message__c> msgs = messageMap.get(subId);
            //if (msgs != null && msgs.size() > 0)
            //  if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Block.name() && msgs[0].Message_Definition_Name__c == SageApiActivityRequestObjects.EntitlementMessage.Block_Entitlement.name().replace('_',''))
            //      activity.Entitlement_Message__c = msgs[0].Id;
            //    else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Unblock.name() && msgs[0].Message_Definition_Name__c == SageApiActivityRequestObjects.EntitlementMessage.Unblock_Entitlement.name().replace('_',''))
            //      activity.Entitlement_Message__c = msgs[0].Id;
            //    else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Cancel.name() && msgs[0].Message_Definition_Name__c == SageApiActivityRequestObjects.EntitlementMessage.Cancel_Subscription.name().replace('_',''))
            //      activity.Entitlement_Message__c = msgs[0].Id;

            activity.ActivityStatus__c = SageApiStatus.InProgress;
            SageApiActivityUtils.setSuccess(activity, step);
            SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        }

        if (smsToUpdate.size()>0) update smsToUpdate;

        SageApiActivityUtils.updateActivities(activities);
    }

    public static List<SageApiActivityError> validateActivity(SageApiActivityStep step, SageApiActivity__c activity, Map<String, ChannelPlatform__c> platforms, Map<String, ChannelPartner__c> partners) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (activity == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Input Data', 'Activity or step cannot be null');
            return errors;
        }

        if (String.isBlank(activity.SubscriptionId__c))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'SubscriptionId', 'SubscriptionId is required');

        if (String.isBlank(activity.ChannelPlatformProvided__c))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Channel Platform', ' Channel Platform is required');

        if (String.isBlank(activity.ChannelPartnerProvided__c))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Channel Partner', ' Channel Partner is required');

        if (string.isNotBlank(activity.ChannelPlatformProvided__c)) {
            ChannelPlatform__c platform = platforms.get(activity.ChannelPlatformProvided__c.toUpperCase());
            if (platform == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Channel Platform', ' Channel Platform is invalid');
        }

        if (!errors.isEmpty()) return errors;

        if (String.isNotBlank(activity.ChannelPartnerProvided__c)) {
            ChannelPartner__c partner = partners.get(activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase());
            if (partner == null)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Channel Partner', ' Channel Partner is invalid');
            else
                    activity.ChannelPartner__c = partner.Id;
        }

        if (!errors.isEmpty()) return errors;
        return null;
    }

    public static void locateAndCopyActivityData(SageApiActivityStep step, List<SageApiActivity__c> activities, Boolean activityStarted, Map<String, SageApiActivity__c> subActivityMap) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();
        List<SageApiActivity__c> processableActivities = new List<SageApiActivity__c>();
        for(SageApiActivity__c activity : activities)
            if (activity.ActivityStatus__c != SageApiStatus.ValidationErrors && activity.ActivityStatus__c != SageApiStatus.ManualInterventionRequired)
                processableActivities.add(activity);

        List<SageApiActivity__c> parentActivities = new List<SageApiActivity__c>();
        List<Subscription_Master__c> subscriptionMasters = [SELECT id, Sage_API_Activity__c, CbcSubscriptionId__c, IsPending__c FROM Subscription_Master__c WHERE CbcSubscriptionId__c IN: subActivityMap.keyset()];
        if (subscriptionMasters == null || subscriptionMasters.isEmpty()) {
            for(SageApiActivity__c activity : processableActivities) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'subscriptionId', 'subscriptionId is not valid, no matching record found (1)');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
            }
            return;
        }

        for (Subscription_Master__c sm : subscriptionMasters) {
            SageApiActivity__c activity =  subActivityMap.get(sm.CbcSubscriptionId__c);
            if (activity == null)
                continue;
            activity.SubscriptionMaster__c = sm.Id;
            if (!activityStarted && sm.IsPending__c) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidState, 'IsPending', ErrorToLockAndUpdateSM);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }
            if (String.isBlank(sm.Sage_API_Activity__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ActivityId', 'SubscriptionMaster not linked to activity');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
                continue;
            }
            parentActivities.add(new SageApiActivity__c(Id=sm.Sage_API_Activity__c));
        }

        if (parentActivities.isEmpty())
            return;

        parentActivities = SageApiActivityUtils.refreshActivities(parentActivities);
        for(SageApiActivity__c activity : processableActivities) {
            Boolean matched = false;
            if (parentActivities != null)
                for (SageApiActivity__c originalActivity : parentActivities)
                    if (activity.SubscriptionMaster__c == originalActivity.SubscriptionMaster__c) {
                        copyActivityValues(originalActivity, activity);
                        matched = true;

                        if (activityStarted && activity.ActivityStatus__c != SageApiStatus.ManualInterventionRequired && activityStarted && activity.ActivityStatus__c != SageApiStatus.ValidationErrors) {
                            SageApiActivityUtils.setSuccess(activity, step);
                            activity.ActivityStatus__c = SageApiStatus.InProgressExternal;
                        }
                        break;
                    }

            if (! matched) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'subscriptionId is not valid, no matching record found (3)');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ValidationErrors, errors);
            }
        }
    }

    public static void createOrUpdateAccount(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.IsNotBlank(activity.Account__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            candidateActivities.add(activity);
        }

        List<Account> accts = new List<Account>();
        List<ID> localeIDs = new List<ID>();
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c, SalesOffice__c FROM Locale__c WHERE Default_Locale__c = 'Yes' AND IsDeleted = false];

        for (SageApiActivity__c activity : candidateActivities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during createOrUpdateAccount. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createOrUpdateAccount', ex);
                continue;
            }

            SageApiActivityRequestObjects.Account account = req.account;

            string countryCode = null;
            string currencyIsoCode = null;
            Locale__c locale = null;
            String salesOffice = 'Atlanta CBC';
            if (account != null && string.isNotBlank(account.countryCode))
                countryCode = account.countryCode;
            if (string.isNotBlank(countryCode)) {
                Locale__c firstLocale = null;
                for (Locale__c l : locales) {
                    if (l.Country_Code__c != countryCode) continue;
                    firstLocale = l;
                    if (l.Default_Locale__c != 'Yes') continue;
                    locale = l;
                }
                if (locale == null) locale = firstLocale;
                if (locale == null)
                    localeIDs.add(null);
                else {
                    salesOffice = locale.SalesOffice__c;
                    currencyIsoCode = locale.CurrencyIsoCode;
                    localeIDs.add(locale.Id);
                }
            }

            Account acct = new Account(
                    Name = account.name,
                    ShippingStreet = ((String.IsBlank(account.address1) ? '' : account.address1)+(String.isBlank(account.address2) ? '' : '\n'+account.address2)),
                    ShippingStateCode = account.state,
                    ShippingCity = account.city,
                    ShippingPostalCode = account.postalCode,
                    ShippingCountryCode = account.countryCode,
                    BillingStreet = ((String.IsBlank(account.address1) ? '' : account.address1)+(String.isBlank(account.address2) ? '' : '\n'+account.address2)),
                    BillingStateCode = account.state,
                    BillingCity = account.city,
                    BillingPostalCode = account.postalCode,
                    BillingCountryCode = account.countryCode,
                    Locale_Billing_CC__c = account.countryCode,
                    Locale__c = (locale == null ? null : locale.id),
                    Sales_Office__c = salesOffice,
                    VAT_Number__c = account.vatNumber,
                    Type = 'Customer',
                    CurrencyIsoCode = currencyIsoCode
            );

            accts.add(acct);
        }

        SageApiActivityUtils.debug('Accts: '+JSON.serialize(accts));

        Database.UpsertResult [] results = Database.upsert(accts, false);
        List<Account> acctsToUpdate = new List<Account>();
        Integer index = -1;
        for(Database.UpsertResult result : results){
            index++;
            SageApiActivity__c activity = candidateActivities.get(index);
            Account acct = accts[index];
            ID localeId = localeIDs[index];
            if (result.isSuccess()) {
                activity.Account__c = result.id;
                activity.CurrencyIsoCode = accts[index].CurrencyIsoCode;
                acct.Locale__c = localeId;
                acctsToUpdate.add(acct);
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateAccount', 'Create or update account failed. Detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }

        if (acctsToUpdate.size() > 0) update acctsToUpdate;

        SageApiActivityUtils.updateActivities(activities);
        saveAccountMappings(activities);
    }

    public static void createOrUpdateContact(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.IsNotBlank(activity.Contact__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            if (String.IsBlank(activity.Account__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateContact', 'Account is not created');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            candidateActivities.add(activity);
        }

        List<Contact> cons = new List<Contact>();
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c, SalesOffice__c FROM Locale__c WHERE Default_Locale__c = 'Yes' AND IsDeleted = false];
        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();

        for (SageApiActivity__c activity : candidateActivities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateContact', 'Activity Payload is not valid during lead upsert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createOrUpdateContact', ex);
                continue;
            }

            SageApiActivityRequestObjects.Contact contact = req.contact;

            string countryCode = null;
            string currencyIsoCode = null;
            Locale__c locale = null;
            String salesOffice = 'Atlanta CBC';
            if (contact != null && string.isNotBlank(contact.countryCode))
                countryCode = contact.countryCode;
            if (string.isNotBlank(countryCode)) {
                Locale__c firstLocale = null;
                for (Locale__c l : locales) {
                    if (l.Country_Code__c != countryCode) continue;
                    firstLocale = l;
                    if (l.Default_Locale__c != 'Yes') continue;
                    locale = l;
                }
                if (locale == null) locale = firstLocale;
                if (locale != null) {
                    salesOffice = locale.SalesOffice__c;
                    currencyIsoCode = locale.CurrencyIsoCode;
                }
            }

            Contact con = new Contact(
                    AccountId = activity.Account__c,
                    FirstName = contact.firstName,
                    LastName = contact.lastName,
                    Email = contact.email,
                    Phone = contact.phone,
                    MailingStreet = ((String.IsBlank(contact.address1) ? '' : contact.address1)+(String.isBlank(contact.address2) ? '' : '\n'+contact.address2)),
                    MailingStateCode = contact.state,
                    MailingCity = contact.city,
                    MailingPostalCode = contact.postalCode,
                    MailingCountryCode = contact.countryCode,
                    Language__c = (locale == null ? null : locale.Language__c),
                    CurrencyIsoCode = currencyIsoCode
            );
            cons.add(con);

            if (req.subscription == null || req.subscription.products == null || req.subscription.products.size() == 0)
                products.add(null);
            else
                    products.add(req.subscription.products[0]);
        }

        List<Product_Tier__c> listTierData = SageApiActivityUtils.getProductTiers(products);
        Integer index = -1;
        if (listTierData != null)
            for (Contact c : cons) {
                index++;
                SageApiActivityRequestObjects.Product product = products[index];
                for (Product_Tier__c tierData : listTierData) {
                    if (product != null && product.tierCode == tierData.Product_Tier_Code__c) {
                        cons[index].Product__c = tierData.SageProduct__c;
                        continue;
                    }
                }
            }

        SageApiActivityUtils.debug('cons: ' + JSON.serialize(cons));

        Database.UpsertResult [] results = Database.upsert(cons, false);
        index = 0;

        for(Database.UpsertResult result : results){
            SageApiActivity__c activity = candidateActivities.get(index);
            index++;
            if (result.isSuccess()) {
                activity.Contact__c = result.id;
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateContact', 'Create or update contact failed. Detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }

        SageApiActivityUtils.updateActivities(activities);
        saveContactMappings(activities);
    }

    public static void createOrUpdateLeadFromContact(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            if (String.IsNotBlank(activity.Lead__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            if (String.isBlank(activity.Contact__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'contactId', 'contactId missing in payload');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            if (String.isBlank(activity.Account__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'accountId', 'accountId missing in payload');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead upsert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createOrUpdateLead', ex);
                continue;
            }

            if (req.subscription == null || req.subscription.products == null || req.subscription.products.size() == 0) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Product', 'Product info missing in payload');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            contactMap.put(activity.Contact__c, null);
            accountMap.put(activity.Account__c, null);
            products.add(req.subscription.products[0]);
            candidateActivities.add(activity);
        }

        if (contactMap.size() > 0) contactMap.putAll([SELECT AccountId,Account_Sales_Office__c,CurrencyIsoCode,Email,FirstName,Id,Language__c,LastName,MailingCity,MailingCountry,MailingCountryCode,MailingPostalCode,MailingState,MailingStateCode,MailingStreet,Name,Phone,Product__c,RecordTypeId FROM Contact WHERE Id IN: contactMap.keySet()]);
        if (accountMap.size() > 0) accountMap.putAll([SELECT BillingCity,BillingCountry,BillingCountryCode,BillingPostalCode,BillingState,BillingStateCode,BillingStreet,CurrencyIsoCode,Id,Locale_Billing_CC__c,Locale__c,Name,Phone,RecordTypeId,Sales_Office__c FROM Account WHERE Id IN: accountMap.keySet()]);
        List<Product_Tier__c> listTierData = SageApiActivityUtils.getProductTiers(products);

        List<Lead> leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c, SalesOffice__c FROM Locale__c WHERE Default_Locale__c = 'Yes' AND IsDeleted = false];
        Integer index = -1;
        for (SageApiActivity__c activity : candidateActivities) {
            index++;
            Contact contact = contactMap.get(activity.Contact__c);
            Account account = accountMap.get(activity.Account__c);
            Lead lead = new Lead(
                    FirstName = contact.FirstName,
                    LastName = contact.LastName,
                    Company = account.Name,
                    Email = contact.Email,
                    Phone = String.IsBlank(Account.Phone) ? contact.Phone: account.Phone,
                    Product__c = contact.Product__c,
                    //status = 'New', leadSource = 'Other',
                    Street = String.IsBlank(account.BillingStreet) ? contact.MailingStreet : account.BillingStreet,
                    City = String.IsBlank(account.BillingCity) ? contact.MailingCity : account.BillingCity,
                    StateCode = String.IsBlank(account.BillingStateCode) ? contact.MailingStateCode : account.BillingStateCode,
                    PostalCode = String.IsBlank(account.BillingPostalCode) ? contact.MailingPostalCode : account.BillingPostalCode ,
                    CountryCode = String.IsBlank(account.BillingCountryCode) ? contact.MailingCountryCode : account.BillingCountryCode,
                    Sales_Office__c = String.IsBlank(account.Sales_Office__c) ? contact.Account_Sales_Office__c : account.Sales_Office__c,
                    RecordTypeId = recordTypeId,
                    CurrencyIsoCode = String.IsBlank(account.CurrencyIsoCode) ? contact.CurrencyIsoCode : account.CurrencyIsoCode
            );

            SageApiActivityRequestObjects.Product product = products[index];
            for (Product_Tier__c tierData : listTierData) {
                if (product != null && product.tierCode == tierData.Product_Tier_Code__c) {
                    lead.Product__c = tierData.SageProduct__c;
                    continue;
                }
            }
            leads.add(lead);
            SageApiActivityUtils.debug('new lead: ' + activity.ActivityID__c + ', lead:' + lead);
        }

        upsertLeads(step, candidateActivities, leads);
        SageApiActivityUtils.updateActivities(activities);
    }

    private static void upsertLeads(SageApiActivityStep step, List<SageApiActivity__c> activities, List<Lead> leads) {
        //process batch save results
        Database.UpsertResult [] leadResults = Database.upsert(leads, false);
        Integer index = 0;

        for(Database.UpsertResult result : leadResults){
            SageApiActivity__c activity = activities.get(index);
            index++;
            //Lead lead = leads.get(index);
            if (result.isSuccess()) {
                SageApiActivityUtils.setSuccess(activity, step);
                activity.Lead__c = result.id;
                SageApiActivityUtils.setSuccess(activity, step);
                SageApiActivityUtils.debug('SageApiSubscriptionActivityUtils.updateArtifactWithLead: '+JSON.serialize(activity));
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'upsertLead', 'upsertLead failed. Detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }
    }

    public static void convertLead(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, SageApiActivity__c> leadActivityMap = getConvertibleLeadIds(activities);
        if (leadActivityMap == null || leadActivityMap.size() == 0) {
            for (SageApiActivity__c activity : activities) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'convertLead', 'Lead is not created');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            SageApiActivityUtils.updateActivities(activities);
            return;
        }

        List<Lead> leads = null;
        List<SageApiActivity__c> activitiesForTryNow = new List<SageApiActivity__c>();
        Map<ID, SageApiActivityRequestObjects.Product> leadProductMap = new Map<ID, SageApiActivityRequestObjects.Product>();
        Map<ID, Product_Tier_Rate_Plan__c> oppProductRatePlanTierMap = new Map<ID, Product_Tier_Rate_Plan__c>();
        Map<ID, Date> leadStartDateMap = new Map<ID, Date>();
        Map<ID, Date> oppStartDateMap = new Map<ID, Date>();

        // only unconverted lead
        leads = [SELECT name, company, firstName, lastName, email, phone, status, street, city, state, postalCode, country, currencyIsoCode, isconverted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId FROM Lead WHERE id in: leadActivityMap.keySet()];
        if (leads == null) return;

        Map<Id, String> activityOppNameMap = getOpportunityNames(activities);
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        for (Lead lead : leads) {
            SageApiActivity__c activity = leadActivityMap.get(lead.id);
            if (activity == null) continue;
            // check for converted leads
            if (lead.isconverted) {
                activity.Account__c = lead.ConvertedAccountId;
                activity.Contact__c = lead.ConvertedContactId;
                activity.Opportunity__c = lead.ConvertedOpportunityId;
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            Database.LeadConvert lc = new Database.LeadConvert();
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead convert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createOrUpdateLead', ex);
                continue;
            }

            String opportunityName = activityOppNameMap.get(activity.Id);
            if (string.isBlank(opportunityName)) opportunityName = getOpportunityName(activity);
            if (string.isBlank(opportunityName)) opportunityName = String.ValueOf(lead.Name);

            lc.setLeadId(lead.Id);
            //lc.setAccountId(AccountId);
            //lc.setSendNotificationEmail(false);
            lc.setOpportunityName(opportunityName);
            //lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Qualified');

            if (String.isNotBlank(activity.Account__c)) lc.setAccountId(activity.Account__c);
            if (String.isNotBlank(activity.Contact__c)) lc.setContactId(activity.Contact__c);

            leadConverts.add(lc);

            leadStartDateMap.put(lead.Id, (String.IsBlank(req.subscription.startDate) ? Date.valueOf(Date.today()) : Date.valueOf(req.subscription.startDate)));
            if (req.subscription != null && req.subscription.products != null && req.subscription.products.size() > 0)
                leadProductMap.put(lead.Id, req.subscription.products[0]);
        }
        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(leadProductMap.values());

        //https://help.salesforce.com/apex/HTViewHelpDoc?id=lead_conversion_mapping.htm&language=en_US
        //https://help.salesforce.com/apex/HTViewHelpDoc?id=leads_notes.htm&language=en_US

        Set<ID> oppIDs = new Set<ID>();
        Set<ID> acctIDs = new Set<ID>();
        List<String> activityTypes = new List<String>();
        Map<ID, String> accountPayloadMap = new Map<ID, String>();

        try {
            List<Database.LeadConvertResult> leadResults = Database.convertLead(leadConverts);
            SageApiActivityUtils.debug('convertLead is called: ' + leadResults);

            String leadError = '';
            Integer index = 0;
            for(Database.LeadConvertResult result : leadResults){
                Lead lead = leads[index];
                index++;

                SageApiActivity__c activity = leadActivityMap.get(lead.id);
                if (result.success) {
                    acctIDs.add(result.accountId);
                    oppIDs.add(result.opportunityId);
                    activityTypes.add(activity.ActivityType__c);
                    oppStartDateMap.put(result.opportunityId, leadStartDateMap.get(result.leadId));
                    accountPayloadMap.put(result.accountId, activity.Payload__c);
                    SageApiActivityRequestObjects.Product product = leadProductMap.get(result.leadId);
                    activity.Account__c = result.accountId;
                    if (String.isNotBlank(result.opportunityId)) activity.Opportunity__c = result.opportunityId;
                    activity.Contact__c = result.contactId;
                    for (Product_Tier_Rate_Plan__c ptrp : listTierMap.values()) {
                        if (ptrp.Product_Tier__r.Product_Tier_Code__c == product.tierCode && ptrp.name == product.tierRatePlanCode) {
                            oppProductRatePlanTierMap.put(result.opportunityId, ptrp);
                            break;
                        }
                    }

                    SageApiActivityUtils.setSuccess(activity, step);
                    SageApiActivityUtils.debug('SageApiTryNowActivityUtils.updateArtifact: '+JSON.serialize(activity));
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertLead', 'Lead conversion failed. Detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                leadError += result.getErrors()+'\n';
            }
            SageApiActivityUtils.debug('convertLead errors: '+leadError);
        } catch (Exception e) {
            for (SageApiActivity__c activity : activities) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertLead', 'Lead conversion failed. Detail: ' + e.getMessage());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            SageApiActivityUtils.debug('convertLead errors: '+e);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'convertLead', e);
        }

        SageApiActivityUtils.updateActivities(activities);

        SageApiActivityUtils.debug('update opps after lead convert: '+JSON.serialize(oppIDs));
        if (oppIDs.size() > 0) {
            List<Opportunity> opps = [SELECT id, StageName FROM Opportunity WHERE id in:oppIDs];
            SageApiActivityUtils.debug('update opps after lead convert: '+JSON.serialize(opps));
            if (opps != null && opps.size() > 0 ) {
                Integer oppIndex = 0;
                for (Opportunity opp : opps) {
                    opp.Lead_Source__c = SageApiActivityUtils.Setting_OpportunityLeadSource;
                    if (activityTypes[oppIndex] == SageApiActivityTriggerHandler.BuyNowActivityType || activityTypes[oppIndex] == SageApiActivityTriggerHandler.TetrisStartPaidActivityType) {
                        // set qualified opps to closed
                        opp.CloseDate = Date.today();
                        opp.StageName = SageApiActivityUtils.setting_OpportunityStageClosedWon;
                        opp.Why_We_Lost__c = SageApiActivityUtils.setting_OpportunityClosedWonReason;
                        continue;
                    }
                    opp.StageName = SageApiActivityUtils.setting_OpportunityStageEvaluating;
                    Product_Tier_Rate_Plan__c ptrp = oppProductRatePlanTierMap.get(opp.ID);
                    if (ptrp == null) continue;
                    Date startDate = oppStartDateMap.get(opp.ID);
                    Decimal trialPlusGraceDays = ptrp.Trial_Period__c + ptrp.Payment_Grace_Period__c;
                    opp.CloseDate = startDate.addDays(trialPlusGraceDays.intValue());
                }
                update opps;
            }
        }

        // set sales office - required for generating invoice number
        SageApiActivityUtils.debug('update accts after lead convert: '+JSON.serialize(acctIDs));
        if (acctIDs.size() > 0) {
            List<Locale__c> locales = [SELECT id, Country_Code__c, CurrencyIsoCode, Name, SalesOffice__c FROM Locale__c WHERE IsDeleted = false AND Default_Locale__c = 'Yes'];
            List<Account> accts = [SELECT id, Sales_Office__c, BillingCountryCode, RecordTypeId FROM Account WHERE id in:acctIDs];
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
            SageApiActivityUtils.debug('update accts after lead convert: '+JSON.serialize(accts));
            if (accts == null || accts.size() == 0 ) return;

            for (Account acct : accts) {
                String payload = accountPayloadMap.get(acct.Id);
                if (payload != null) {
                    try {
                        SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                        if (req.account != null && req.account.vatNumber != null)
                            acct.VAT_Number__c = req.account.vatNumber;
                    } catch (Exception e){}
                }

                for (Locale__c locale : locales){
                    if (acct.BillingCountryCode == locale.Country_Code__c) {
                        acct.Locale__c = locale.id;
                        acct.Sales_Office__c = locale.SalesOffice__c; //'Atlanta CBC';
                        break;
                    }
                }
                if (recordTypeId != acct.RecordTypeId) acct.RecordTypeId = recordTypeId;
                acct.Type = 'Customer';
            }

            update accts;
        }
    }

    public static void provisionUserV2(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {
        if (originalActivities == null || originalActivities.size() == 0) return;

        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        Map<ID, SageApiActivity__c> contactActivityMap = new Map<ID, SageApiActivity__c>();
        Map<ID, Community_Role__c> contactRoleMap = new Map<ID, Community_Role__c>();
        Map<ID, string> contactIdpMap = new Map<ID, string>();
        Map<ID, string> contactIdpIdMap = new Map<ID, string>();

        CommunityX__c community = [SELECT Id, Default_User_Profile__c, Name FROM CommunityX__c WHERE Name =: SageApiActivityUtils.setting_CustomerCommunityName LIMIT 1];
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name =: community.Default_User_Profile__c LIMIT 1];
        List<Community_Role__c> roleRefList = [SELECT Id, Name, Community__c FROM Community_Role__c WHERE Community__c =: community.Id];

        for (SageApiActivity__c activity : originalActivities) {
            try {
                SageApiActivityRequestObjects.SubscriptionRequest req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);

                // no need to create user if not provided
                if (req.customerCommunityUsers == null || req.customerCommunityUsers.isEmpty()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }

                Boolean hasUserToCreate = false;
                for (SageApiActivityRequestObjects.CommunityUser user : req.customerCommunityUsers) {
                    if (String.isBlank(user.contactId) || user.identity==null || String.isBlank(user.identity.idpId) || String.isBlank(user.identity.idp))
                        continue;

                    Community_Role__c reqRole = null;
                    if (user.role == SageApiActivityRequestObjects.CommunityRoles.Admin.name())
                        reqRole = SageApiAddCommUserActivityUtils.getCommunityRole(roleRefList, community.Id, SageApiActivityUtils.setting_CustomerCommunityAdminRoleName);
                    else
                            reqRole = SageApiAddCommUserActivityUtils.getCommunityRole(roleRefList, community.Id, SageApiActivityUtils.setting_CustomerCommunityUserRoleName);

                    if (reqRole == null) continue;

                    hasUserToCreate = true;
                    contactRoleMap.put(user.contactId, reqRole);
                    contactIdpMap.put(user.contactId, user.identity.idp);
                    contactIdpIdMap.put(user.contactId, user.identity.idpId);
                    contactActivityMap.put(user.contactId, activity);
                }

                if (hasUserToCreate)
                    candidateActivities.add(activity);
                else
                        SageApiActivityUtils.setSuccess(activity, step);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUserV2', 'Error detail: '+ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiAddCommUserActivityUtils', 'provisionUserV2', ex);
            }
        }

        List<Contact> candidateContacts = [SELECT ID,Account.Id,Account.name,Account.BillingCountryCode,Email,FirstName,LastName,MailingCity,MailingCountry,MailingCountryCode,MailingPostalCode,MailingState,MailingStreet,Phone FROM Contact WHERE ID in: contactActivityMap.keyset()];
        SageApiActivityUtils.debug('contacts to be processed: ' + candidateContacts);

        // nothing to create
        if (candidateContacts == null || candidateContacts.size() == 0) {
            for (SageApiActivity__c activity : candidateActivities)
                SageApiActivityUtils.setSuccess(activity, step);
            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }

        // prepare for members, users, identities
        List<Community_Membership__c> members = new List<Community_Membership__c>();
        List<User> users = new List<User>();
        List<SageUserIdentityProvider__c> userIdentities = new List<SageUserIdentityProvider__c>();
        Map<ID, ID> contactToAccountMap = new Map<ID, ID>();
        List<SageApiActivity__c> memberActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> userActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> identityActivities = new List<SageApiActivity__c>();

        Map<ID, String> contactBridgeIdMap = new Map<ID, String>();
        for (Contact c : candidateContacts)
            contactBridgeIdMap.put(c.Id, Account.Id+':'+contactIdpMap.get(c.Id)+':'+contactIdpIdMap.get(c.Id));

        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, LanguageLocaleKey__c FROM Locale__c WHERE IsDeleted = false];
        Map<Id, User> contactUserMap = new Map<Id, User>();
        for (User user : [SELECT Id, ContactId FROM User WHERE ContactId IN: candidateContacts])
            contactUserMap.put(user.ContactId, user);

        Map<String, Community_Membership__c> contactMembershipMap = new Map<String, Community_Membership__c>();
        for (Community_Membership__c membership : [SELECT Id, Community__c, Contact__c, Community_Role__c FROM Community_Membership__c WHERE Community__c =: community.Id AND Contact__c IN: candidateContacts])
            contactMembershipMap.put(String.valueOf(membership.Contact__c)+':'+String.valueOf(Community_Role__c.Id), membership);

        Map<Id, SageUserIdentityProvider__c> contactIdentityMap = new Map<Id, SageUserIdentityProvider__c>();
        for (SageUserIdentityProvider__c identity : [SELECT Id, User__r.ContactId FROM SageUserIdentityProvider__c WHERE SFBridgeID__c IN: contactBridgeIdMap.values()])
            contactIdentityMap.put(identity.User__r.ContactId, identity);

        List<String> userIdentityKeys = new List<String>();
        for (Contact c : candidateContacts) {
            Community_Role__c reqCommunityRole = contactRoleMap.get(c.Id);
            string reqIdentityId = contactIdpIdMap.get(c.Id);
            string reqIdentityType = contactIdpMap.get(c.Id);
            SageApiActivity__c activity = contactActivityMap.get(c.Id);
            contactToAccountMap.put(c.ID, c.AccountId);

            Locale__c locale = null;
            Locale__c firstLocale = null;
            String countryCode = String.isBlank(c.MailingCountryCode) ? c.Account.BillingCountryCode : c.MailingCountryCode;
            Integer localeIndex = -1;
            for (Locale__c l : locales) {
                localeIndex++;
                if (l.Country_Code__c != countryCode) continue;
                firstLocale = l;
                if (l.Default_Locale__c != 'Yes') continue;
                locale = l;
            }
            if (locale == null) locale = firstLocale;

            //need to check with role as well
            Community_Membership__c member = contactMembershipMap.get(String.valueOf(c.Id)+':'+String.valueOf(reqCommunityRole.Id));
            if (member == null)
                member = new Community_Membership__c(Contact__c = c.Id, Community__c = community.Id, Community_Role__c = reqCommunityRole.Id);
            members.add(member);
            memberActivities.add(activity);

            //need to check whether created
            User user = contactUserMap.get(c.Id);
            if (user == null)
                user = SageApiAddCommUserActivityUtils.setUpUserRecord(c, profile, locale);
            users.add(user);
            userActivities.add(activity);

            //need to check whether created
            SageUserIdentityProvider__c userIdentity = contactIdentityMap.get(c.Id);
            if (userIdentity == null) {
                userIdentity = new SageUserIdentityProvider__c();
                userIdentity.Account__c = c.AccountId;
                userIdentity.IdentityID__c = reqIdentityId;
                userIdentity.IdentityProvider__c = reqIdentityType;
                string bridgeId = c.AccountId + ':' + reqIdentityType + ':' + reqIdentityId;
                userIdentity.SFBridgeID__c = bridgeId;
                // name field is limited to 80 characters
                userIdentity.Name = bridgeId.length() > 80 ? bridgeId.substring(0, 80) : bridgeId;

                if (locale != null && string.isNotBlank(locale.currencyIsoCode))
                    userIdentity.CurrencyIsoCode = locale.currencyIsoCode;
                userIdentityKeys.add(userIdentity.SFBridgeID__c);
            }
            userIdentities.add(userIdentity);
            identityActivities.add(activity);
        }

        List<SageUserIdentityProvider__c> existingUserIdentities = [SELECT id, SFBridgeID__c FROM SageUserIdentityProvider__c WHERE SFBridgeID__c IN: userIdentityKeys];
        for (SageUserIdentityProvider__c ei : existingUserIdentities)
            for (SageUserIdentityProvider__c ui : userIdentities)
                if (ei.SFBridgeID__c == ui.SFBridgeID__c) {
                    ui.Id = ei.Id;
                    break;
                }

        SageApiActivityUtils.debug('users to create: '+JSON.serialize(users));
        SageApiAddCommUserActivityUtils.saveCommunityUsers(step, candidateActivities, members, memberActivities, users, userActivities, userIdentities, identityActivities, contactToAccountMap);
    }

    public static void provisionUser(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {
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
                SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
                reqIdentityIds.add(req.contact.identityId);
                reqIdentityTypes.add(req.contact.identityType);
                reqCommunityRoles.add(SageApiActivityUtils.setting_CustomerCommunityAdminRoleName);
                reqCommunityNames.add(SageApiActivityUtils.setting_CustomerCommunityName);

                contactActivityMap.put(activity.Contact__c, activity);
                candidateActivities.add(activity);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Error detail: '+ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'provisionUsers', ex);
            }
        }

        List<Contact> candidateContacts = [SELECT ID,Account.Id,Account.name,Account.BillingCountryCode,Email,FirstName,LastName,MailingCity,MailingCountry,MailingCountryCode,MailingPostalCode,MailingState,MailingStreet,Phone FROM Contact WHERE ID in: contactActivityMap.keyset()];
        SageApiActivityUtils.debug('contacts to be processed: ' + candidateContacts);

        if (candidateContacts == null || candidateContacts.size() == 0) {
            for (SageApiActivity__c activity : candidateActivities) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUser', 'Contact is not created');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }

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
                reqCommunity = SageApiAddCommUserActivityUtils.getCommunity(communityRefList, reqCommunityName);
            if (reqCommunity == null) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'provisionUsers', 'Community ['+reqCommunityName+'] not found');
                SageApiActivityUtils.setError(activity, step.deepClone(), SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            Community_Role__c reqRole = SageApiAddCommUserActivityUtils.getCommunityRole(roleRefList, reqCommunity.Id, reqCommunityRole);

            if (String.isBlank(activity.CommunityMembership__c)) {
                Community_Membership__c member = new Community_Membership__c(Contact__c = c.Id, Community__c = reqCommunity.Id);
                if (reqRole != null)
                    member.Community_Role__c = reqRole.Id;
                members.add(member);
                memberActivities.add(activity);
            }

            if (String.isBlank(activity.User__c)) {
                Profile profile = SageApiAddCommUserActivityUtils.getProfile(profileRefList, reqCommunity.Default_User_Profile__c);
                User user = SageApiAddCommUserActivityUtils.setUpUserRecord(c, profile, locale);
                users.add(user);
                userActivities.add(activity);
            }

            if (String.isNotBlank(activity.SageUserIdentityProvider__c)) continue;

            SageUserIdentityProvider__c userIdentity = new SageUserIdentityProvider__c();
            userIdentity.Account__c = c.AccountId;
            userIdentity.IdentityID__c = reqIdentityId;
            userIdentity.IdentityProvider__c = reqIdentityType;
            userIdentity.SFBridgeID__c = c.AccountId + ':' + reqIdentityType + ':' + reqIdentityId;
            userIdentity.Name = userIdentity.SFBridgeID__c;
            if (locale != null && string.isNotBlank(locale.currencyIsoCode))
                userIdentity.CurrencyIsoCode = locale.currencyIsoCode;
            userIdentities.add(userIdentity);
            identityActivities.add(activity);
        }

        SageApiActivityUtils.debug('users to create: '+JSON.serialize(users));
        SageApiAddCommUserActivityUtils.saveCommunityUsers(step, candidateActivities, members, memberActivities, users, userActivities, userIdentities, identityActivities, contactToAccountMap);
    }

    public static void createOrUpdateSubscriptionMaster(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {
        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);
        List<SageApiActivity__c> activitiesWithoutSM = new List<SageApiActivity__c>();
        List<SageApiActivity__c> activitiesWithSM = new List<SageApiActivity__c>();
        List<Subscription_Master__c> subscriptionMasters = new List<Subscription_Master__c>();
        List<SageApiActivityRequestObjects.Product> products = getRequestProducts(originalActivities);
        List<Product_Tier__c> listTier = SageApiActivityUtils.getProductTiers(products);

        for (SageApiActivity__c activity : originalActivities) {
            if (String.isBlank(activity.Account__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'createOrUpdateSubscriptionMaster', 'An account is required to create subscription master record');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isNotBlank(activity.SubscriptionMaster__c) || String.isNotBlank(activity.Entitlement_Message__c)) {
                activitiesWithSM.add(activity);
                continue;
            }

            SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            if (req == null || req.subscription == null || req.subscription.products == null || req.subscription.products[0] == null) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'createOrUpdateSubscriptionMaster', 'Invalid payload data');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiActivityRequestObjects.Product product = req.subscription.products[0];

            // Create a new asset record
            Subscription_Master__c newSM = new Subscription_Master__c();
            newSM.Account__c = activity.Account__c;
            newSM.EnableInsertTrigger__c = false;
            newSM.Sage_API_Activity__c = activity.Id;
            newSM.CbcSubscriptionId__c = String.isNotBlank(req.subscription.cbcSubscriptionId) ? req.subscription.cbcSubscriptionId : GenericUtilities.getRandomUUIDv4();
            newSM.SalesChannelAuthUrl__c = getCustomAttribute(req.subscription.customAttributes, SageApiActivityRequestObjects.CustomAttribute.SalesChannelAuthUrl.name());
            newSM.External_Id__c = activity.Account__c + ':' + product.tierCode + ':' + newSM.CbcSubscriptionId__c;
            newSM.ChannelPartner__c = activity.ChannelPartner__c;

            if (product.isTrial) {
                newSM.Status__c = Constants.ASSET_STATUS_TRIAL;
                newSM.Quote__c = activity.Quote__c;
            } else {
                newSM.Status__c = Constants.ASSET_STATUS_ACTIVE;
            }

            for (Product_Tier__c tier : listTier)
                if (tier.Product_Tier_Code__c == product.tierCode) {
                    newSM.ZProduct__c = tier.ZProduct__c;
                    newSM.Product_Tier__c = tier.Id;
                    newSM.Start_Date__c = System.now();

                    if (newSM.Status__c == Constants.ASSET_STATUS_TRIAL) {
                        newSM.End_Date__c = System.now().addDays(Integer.valueOf(tier.Trial_Period__c));
                    } else {
                        newSM.End_Date__c = Date.newInstance(2099, 12, 31);
                    }
                    break;
                }

            subscriptionMasters.add(newSM);
            activitiesWithoutSM.add(activity);
        }

        List<EntitlementEngine.CreateEntitlementRequest> createEntitlementRequests = new List<EntitlementEngine.CreateEntitlementRequest>();

        // new subscription master records
        if (subscriptionMasters.size() > 0) {
            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasters, Subscription_Master__c.Fields.External_Id__c, false);
            Integer index = 0;
            List<ID> successOppIds = new List<ID>();
            for (Database.UpsertResult result : upsertResults) {
                Subscription_Master__c currentSM = subscriptionMasters.get(index);
                SageApiActivity__c activity = activitiesWithoutSM[index];
                activity.SubscriptionMaster__c = currentSM.Id;
                activity.Subscription__c = currentSM.Subscription__c;
                activity.Step_Serialised__c = JSON.serialize(step);
                index += 1;

                if (result.isSuccess()) {
                    try {
                        SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
                        createEntitlementRequests.add(new EntitlementEngine.CreateEntitlementRequest( activity.SubscriptionMaster__c, req.subscription.products[0].isTrial ));
                    } catch (Exception ex) {
                        ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createOrUpdateSubscriptionMaster', ex);
                        List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createOrUpdateSubscriptionMaster', 'Payload is not valid: ' + ex);
                        SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    }
                    successOppIds.add(activity.Opportunity__c);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createOrUpdateSubscriptionMaster', 'SM creation failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }

            if (successOppIds.size() > 0) {
                List<Opportunity> oppsToUpdate = new List<Opportunity>();
                List<Opportunity> successOpps = [SELECT ID, StageName FROM Opportunity WHERE ID IN: successOppIds];
                for (Opportunity opp : successOpps) {
                    if (opp.StageName == SageApiActivityUtils.setting_OpportunityStageClosedWon) continue;
                    opp.StageName = SageApiActivityUtils.setting_OpportunityStageClosedWon;
                    oppsToUpdate.add(opp);
                }
                if (oppsToUpdate.size()>0) upsert oppsToUpdate;
            }
        }

        // existing subscription master records
        Map<ID, String> activitySubIdMap = getActivityCbcSubscriptionIds(originalActivities);
        Map<String, Subscription_Master__c> subMasterMap = null;
        //Map<String, List<Entitlement_Message__c>> messageMap = null;
        if (activitySubIdMap != null && activitySubIdMap.size() > 0)
            subMasterMap = getSubscriptionMasters(activitySubIdMap.values());
        //messageMap = getEntitlementMessages(activitySubIdMap.values());

        List<ID> msgIdsToReset = new List<Id>();
        List<Subscription_Master__c> subMasterToUpdateActivity = new List<Subscription_Master__c>();
        for (SageApiActivity__c activity : activitiesWithSM) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            if (activity.Entitlement_Message__r.Status__c == 'Processed') {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            } else if (activity.Entitlement_Message__r.Status__c == 'Error') {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateSubscriptionMaster', 'Entitlement error: '+activity.Entitlement_Message__r.Error_Message__c);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.Entitlement_Message__r.Status__c == 'New') {
                msgIdsToReset.add(activity.Entitlement_Message__c);
                continue;
            } else if (String.isNotBlank(activity.Entitlement_Message__c))
                continue;

            if (activitySubIdMap == null || subMasterMap == null) continue;

            String subId = activitySubIdMap.get(activity.Id);
            if (subId == null) continue;
            Subscription_Master__c sm = subMasterMap.get(subId);
            if (sm == null) continue;
            //List<Entitlement_Message__c> curMsgs = messageMap.get(subId);
            //if (curMsgs == null || curMsgs.size() == 0) continue;

            //throw new CustomException('Manual Stop: ' + sm.Is_Cancelled__c);

            //if (curMsgs != null && curMsgs[0].Status__c != 'Processing' && ! sm.Is_Cancelled__c) {
            //    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createOrUpdateSubscriptionMaster', 'Invalid operation: the state of subscription master record is not qualified for a new entitlement for the same product');
            //    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            //    continue;
            //}

            // only cancelled be qualified for repurchasing
            if (!sm.Is_Cancelled__c) continue;
            sm.Sage_API_Activity__c = activity.Id;
            sm.End_Date__c = Date.newInstance(2099, 12, 31);
            subMasterToUpdateActivity.add(sm);
            try {
                SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
                createEntitlementRequests.add(new EntitlementEngine.CreateEntitlementRequest( activity.SubscriptionMaster__c, req.subscription.products[0].isTrial ));
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createOrUpdateSubscriptionMaster', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Activity Payload', 'Payload is not valid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        if (subMasterToUpdateActivity.size() > 0)
            update subMasterToUpdateActivity;

        if (msgIdsToReset.size() > 0) {
            List<Entitlement_Message__c> msgs = [SELECT Id FROM Entitlement_Message__c WHERE Status__c='New' AND Id IN: msgIdsToReset];
            for (Entitlement_Message__c msg : msgs)
                msg.Status__c = null;
            update msgs;
            for (Entitlement_Message__c msg : msgs)
                msg.Status__c = 'New';
            update msgs;
        }

        if (createEntitlementRequests.size() > 0) {
            List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
            msgs.addAll(EntitlementEngine.createEntitlements( createEntitlementRequests ));
            linkMsgsToActivities(msgs, originalActivities);

            List<Subscription_Master__c> sms = new List<Subscription_Master__c>();
            for (Entitlement_Message__c msg : msgs)
                sms.add(new Subscription_Master__c(id = msg.Subscription_Master__c, Is_Blocked__c = false, Is_Cancelled__c = false));
            update sms;
        }

        //ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createOrUpdateSubscriptionMaster', new CustomException(JSON.serialize(createEntitlementRequests)));
        //throw new CustomException('Manual Stop');
        SageApiActivityUtils.updateActivities(originalActivities);
    }

    public static void updateSubscriptionMaster(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {
        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);
        List<SageApiActivity__c> activities = new List<SageApiActivity__c>();

        // List of Subscription Master Records to Upsert
        Map<Id, String> blockSmReasonMap = new Map<Id, String>();
        List<Id> unblockSms = new List<Id>();
        List<Id> cancelSms = new List<Id>();
        List<Id> reactivateSms = new List<Id>();
        List<Id> convertSms = new List<Id>();
        List<Id> upgradeSms = new List<Id>();
        List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
        Map<Id, Id> smActivityMap = new Map<Id, Id>();
        List<ID> msgIdsToReset = new List<Id>();

        for (SageApiActivity__c activity : originalActivities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            if (String.isBlank(activity.SubscriptionMaster__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'updateSubscriptionMaster', 'Subscription master record is not available');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            smActivityMap.put(activity.SubscriptionMaster__c, activity.Id);

            if (activity.Entitlement_Message__r.Status__c == 'Processed') {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            } else if (activity.Entitlement_Message__r.Status__c == 'Error') {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'updateSubscriptionMaster', 'Entitlement error: '+activity.Entitlement_Message__r.Error_Message__c);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            } else if (activity.Entitlement_Message__r.Status__c == 'New') {
                msgIdsToReset.add(activity.Entitlement_Message__c);
                continue;
            } else if (String.isNotBlank(activity.Entitlement_Message__c)) {
                continue;
            }

            try {
                SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
                if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Block.name()) {
                    String error = getCustomAttribute(req.subscription.customAttributes, SageApiActivityRequestObjects.CustomAttribute.BlockReason.name());
                    blockSmReasonMap.put(activity.SubscriptionMaster__c, String.isBlank(error) ? 'Not provided' : error);
                } else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Unblock.name())
                    unblockSms.add(activity.SubscriptionMaster__c);
                else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Cancel.name())
                    cancelSms.add(activity.SubscriptionMaster__c);
                else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Reactivate.name())
                    reactivateSms.add(activity.SubscriptionMaster__c);
                else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Reactivate.name())
                    convertSms.add(activity.SubscriptionMaster__c);
                else if (activity.ActivityAction__c == SageApiActivityRequestObjects.ActivityAction.Upgrade.name())
                    upgradeSms.add(activity.SubscriptionMaster__c);
                else {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Activity Action', 'Activity Action is not implemented: '+activity.ActivityAction__c);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                }
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'updateSubscriptionMaster', ex);
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Activity Payload', 'Payload is not valid');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            activities.add(activity);
        }

        if (msgIdsToReset.size() > 0) {
            List<Entitlement_Message__c> msgsToReset = [SELECT Id FROM Entitlement_Message__c WHERE Status__c='New' AND Id IN: msgIdsToReset];
            for (Entitlement_Message__c msg : msgsToReset)
                msg.Status__c = null;
            update msgsToReset;
            for (Entitlement_Message__c msg : msgsToReset)
                msg.Status__c = 'New';
            update msgsToReset;
        }

        List<Subscription_Master__c> smsWithNewActivityRef = new List<Subscription_Master__c>();
        for (Id smid : smActivityMap.keySet())
            if (smActivityMap.get(smid) != null)
                smsWithNewActivityRef.add(new Subscription_Master__c(Id = smid, Sage_API_Activity__c = smActivityMap.get(smid)));
        if (smsWithNewActivityRef.size() > 0)
            update smsWithNewActivityRef;

        if (blockSmReasonMap.size() > 0)
            msgs.addAll(EntitlementEngine.blockEntitlements( blockSmReasonMap ));

        if (unblockSms.size() > 0)
            msgs.addAll(EntitlementEngine.unblockEntitlements( unblockSms ));

        if (cancelSms.size() > 0) {
            List<Subscription_Master__c> cancellingSms = [SELECT id, Start_Date__c, End_Date__c FROM Subscription_Master__c WHERE id IN: cancelSms];
            for (Subscription_Master__c sms : cancellingSms)
                sms.End_Date__c = sms.Start_Date__c > Date.today() ? sms.Start_Date__c : Date.today();
            update cancellingSms;
            msgs.addAll(EntitlementEngine.cancelEntitlements( cancelSms ));
        }

        if (reactivateSms.size() > 0)
            msgs.addAll(EntitlementEngine.reactivateEntitlements( reactivateSms ));

        if (convertSms.size() > 0)
            msgs.addAll(EntitlementEngine.convertTrialEntitlements( convertSms ));

        if (upgradeSms.size() > 0)
            msgs.addAll(EntitlementEngine.upgradeEntitlements( upgradeSms ));

        linkMsgsToActivities(msgs, activities);

        SageApiActivityUtils.updateActivities(originalActivities);
    }

    public static void createEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> activitiesWithoutSM = new List<SageApiActivity__c>();
        List<Subscription_Master__c> subscriptionMasters = new List<Subscription_Master__c>();
        List<SageApiActivityRequestObjects.ProductRequest> productRequests = getProductRequests(activities);
        List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();
        Id recordTypeId = Schema.SObjectType.Subscription_Master__c.getRecordTypeInfosByName().get('SLCS').getRecordTypeId();

        // handles SM
        // then handles SM Product
        for (SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            if (activity == null || step == null) continue;
            SageApiActivityRequestObjects.SubscriptionResponse res = null;
            try {
                res = (SageApiActivityRequestObjects.SubscriptionResponse)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionResponse.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'createEntitlementDetail', ex);
                continue;
            }

            if (res == null || res.entitlement == null || String.isBlank(res.entitlement.entitlementId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'Entitlement', 'entitlement data is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            Subscription_Master__c newSM = new Subscription_Master__c(RecordTypeId=recordTypeId,
                    Account__c=activity.Account__c,Contact__c=activity.Contact__c,
                    ManagingAccount__c=activity.ManagingAccount__c,PartnerAccount__c=activity.PartnerAccount__c,
                    PartnerContact__c=activity.PartnerContact__c,EnableInsertTrigger__c=false,
                    Sage_API_Activity__c=activity.Id,CbcSubscriptionId__c=activity.SubscriptionId__c,
                    Entitlement_Id__c=activity.EntitlementId__c,SubscriptionGroupId__c=activity.SubscriptionGroupId__c,
				    ClientRef__c=activity.ClientRef__c,External_Id__c=activity.Account__c+':'+activity.SubscriptionId__c,
                    ChannelPartner__c=activity.ChannelPartner__c,
                    Status__c=res.isTrial?Constants.ASSET_STATUS_TRIAL:Constants.ASSET_STATUS_ACTIVE,
                    SubscriptionState__c=res.state,Start_Date__c=Date.valueOf(res.effectivePeriod.notBefore),
                    End_Date__c=Date.valueOf(res.effectivePeriod.notAfter),IsPending__c=false,
                    PendingEntitlementData__c=null,ETag__c=res.eTag);
            if (res.links != null)
                newSM.Links__c = JSON.serialize(res.links);

            //newSM.SalesChannelAuthUrl__c = getCustomAttribute(req.subscription.customAttributes, SageApiActivityRequestObjects.CustomAttribute.SalesChannelAuthUrl.name());
            if (String.isNotBlank(activity.ManagingAccount__c))
                newSM.ManagingAccount__c = activity.ManagingAccount__c;

            subscriptionMasters.add(newSM);
            activitiesWithoutSM.add(activity);
        }

        // new subscription master records
        if (subscriptionMasters.size() > 0) {
            List<ID> smsToCleanup = new List<ID>();
            List<EntitlementProduct__c> oldEntitledProducts = null;
            List<EntitlementProduct__c> entitledProducts = new List<EntitlementProduct__c>();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasters, Subscription_Master__c.Fields.External_Id__c, false);
            Integer index = 0;
            for (Database.UpsertResult result : upsertResults) {
                Subscription_Master__c currentSM = subscriptionMasters.get(index);
                SageApiActivity__c activity = activitiesWithoutSM[index];
                ID smId = currentSM.Id;
                activity.SubscriptionMaster__c = smId;
                //activity.Step_Serialised__c = JSON.serialize(step);
                index += 1;

                SageApiActivityLog__c log1 = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=activity.SubscriptionMaster__c, LogSource__c=step.stepName, LogMessage__c='Subscription component: '+JSON.serialize(currentSM, true), LogTime__c=Datetime.Now());
                logs.add(log1);

                if (result.isSuccess()) {
                    afterSubscriptionMasterCreated(step, activity, smId, entitledProducts, smsToCleanup, logs);
                    continue;
                }

                // when upsert failed with Database.Error[getFields=();getMessage=duplicate value found: Entitlement_Id__c duplicates value on record with id: a2C1o00000fgoj2;getStatusCode=DUPLICATE_VALUE;])
                // test whether the upsert method will return ID first before attempting to read the record
                smId = result.getId();
                if (String.isNotBlank(smId)) {
                    afterSubscriptionMasterCreated(step, activity, smId, entitledProducts, smsToCleanup, logs);
                    continue;
                }

                // if we get here, and if error is DUPLICATE_VALUE, read will be attempted before quitting
                Database.Error[] upsertErrors = result.getErrors();
                for (Database.Error error : upsertErrors) {
                    if (error.getStatusCode() != System.StatusCode.DUPLICATE_VALUE)
                        continue;

                    List<Subscription_Master__c> existingSms = [SELECT id FROM Subscription_Master__c WHERE Entitlement_Id__c =: currentSM.Entitlement_Id__c];
                    if (existingSms.isEmpty())
                        continue;

                    smId = existingSms[0].id;
                    break;
                }

                if (String.isNotBlank(smId)) {
                    afterSubscriptionMasterCreated(step, activity, smId, entitledProducts, smsToCleanup, logs);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createEntitlementDetail', 'SM creation failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }

            if (! smsToCleanup.isEmpty())
                oldEntitledProducts = [SELECT id, SubscriptionMaster__c FROM EntitlementProduct__c WHERE IsDeleted=false AND SubscriptionMaster__c IN: smsToCleanup];

            if (! entitledProducts.isEmpty()) {
                Database.UpsertResult [] upsertResults2 = Database.upsert(entitledProducts, false);
                index = -1;
                List<EntitlementProduct__c> oldEntitledProductsToBeDeleted = new List<EntitlementProduct__c>();
                for (Database.UpsertResult result : upsertResults2) {
                    index += 1;
                    if (result.isSuccess()) {
                        for (EntitlementProduct__c p : oldEntitledProducts)
                            if (p.SubscriptionMaster__c == entitledProducts[index].SubscriptionMaster__c) {
                                Boolean hasIt = false;
                                for (EntitlementProduct__c ep : oldEntitledProductsToBeDeleted)
                                    if (ep.Id == p.Id)
                                        hasIt = true;
                                if (! hasIt) oldEntitledProductsToBeDeleted.add(p);
                            }
                        continue;
                    }

                    for(SageApiActivity__c activity : activities)
                        if (activity.SubscriptionMaster__c == entitledProducts[index].SubscriptionMaster__c) {
                            List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createEntitlementDetail', 'SM Product creation failed. More detail: ' + result.getErrors());
                            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                            break;
                        }
                }

                if (! oldEntitledProductsToBeDeleted.isEmpty()) delete oldEntitledProductsToBeDeleted;
            }
        }

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.log(logs);
    }

    public static void deleteEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        List<Subscription_Master__c> subscriptionMasterToUpdate = new List<Subscription_Master__c>();

        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.SubscriptionMaster__c)) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'deleteEntitlementDetail', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            subActivityMap.put(activity.SubscriptionMaster__c, activity);
            subscriptionMasterToUpdate.add(new Subscription_Master__c(Id=activity.SubscriptionMaster__c,SubscriptionState__c=SageApiActivityRequestObjects.SubscriptionState.Deleted.name(),End_Date__c=Date.today(),IsPending__c=false,PendingEntitlementData__c=null,SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null));
        }

        if (subscriptionMasterToUpdate.size() > 0) {
            List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                ID smId = result.getId();
                SageApiActivity__c activity = subActivityMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'suspendEntitlementDetail', 'Enetitlement suspending failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void suspendEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        Map<ID, Subscription_Master__c> subscriptionMasterMap = new Map<ID, Subscription_Master__c>();

        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.SubscriptionMaster__c)) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'suspendEntitlementDetail', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiActivityRequestObjects.Reason reason = null;
            try {
                reason = (SageApiActivityRequestObjects.Reason)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.Reason.class);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'suspendEntitlementDetail', ex);
                continue;
            }

            subActivityMap.put(activity.SubscriptionMaster__c, activity);
            subscriptionMasterMap.put(activity.SubscriptionMaster__c, new Subscription_Master__c(Id = activity.SubscriptionMaster__c,SubscriptionState__c=SageApiActivityRequestObjects.SubscriptionState.Suspended.name(), SuspensionReasonCode__c=reason.reasonCode,SuspensionReasonDescription__c=reason.reasonDescription,IsPending__c=false,PendingEntitlementData__c=null));
        }

        if (subActivityMap.size() > 0) {
            List<Subscription_Master__c> subscriptionMasterToUpdate = subscriptionMasterMap.values();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                ID smId = result.getId();
                SageApiActivity__c activity = subActivityMap.get(smId);
                Subscription_Master__c sm = subscriptionMasterMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'suspendEntitlementDetail', 'Enetitlement suspending failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void reactivateEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        Map<ID, Subscription_Master__c> subscriptionMasterMap = new Map<ID, Subscription_Master__c>();

        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.SubscriptionMaster__c)) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'reactivateEntitlementDetail', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            subActivityMap.put(activity.SubscriptionMaster__c, activity);
            subscriptionMasterMap.put(activity.SubscriptionMaster__c, new Subscription_Master__c(Id=activity.SubscriptionMaster__c,SubscriptionState__c=SageApiActivityRequestObjects.SubscriptionState.Active.name(),SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null,IsPending__c=false,PendingEntitlementData__c=null));
        }

        if (subActivityMap.size() > 0) {
            List<Subscription_Master__c> subscriptionMasterToUpdate = subscriptionMasterMap.values();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                ID smId = result.getId();
                SageApiActivity__c activity = subActivityMap.get(smId);
                Subscription_Master__c sm = subscriptionMasterMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'reactivateEntitlementDetail', 'Enetitlement reactivating failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void convertEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        Map<ID, Subscription_Master__c> subscriptionMasterMap = new Map<ID, Subscription_Master__c>();

        for (SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            if (String.isBlank(activity.SubscriptionMaster__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'convertEntitlementDetail', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiActivityRequestObjects.SubscriptionRequest req = null;
            try {
                if (String.isNotBlank(activity.payload__c))
                    req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);

                subActivityMap.put(activity.SubscriptionMaster__c, activity);
                if (req == null)
                    subscriptionMasterMap.put(activity.SubscriptionMaster__c, new Subscription_Master__c(Id=activity.SubscriptionMaster__c,Status__c=Constants.ASSET_STATUS_ACTIVE,SubscriptionState__c=SageApiActivityRequestObjects.SubscriptionState.Active.name(),SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null,IsPending__c=false,PendingEntitlementData__c=null));
                else
                        subscriptionMasterMap.put(activity.SubscriptionMaster__c, new Subscription_Master__c(Id=activity.SubscriptionMaster__c,Status__c=Constants.ASSET_STATUS_ACTIVE,SubscriptionState__c=SageApiActivityRequestObjects.SubscriptionState.Active.name(),SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null,Start_Date__c=Date.valueOf(req.effectivePeriod.notBefore),End_Date__c=Date.valueOf(req.effectivePeriod.notAfter),IsPending__c=false,PendingEntitlementData__c=null));
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'convertEntitlementDetail', ex);
            }
        }

        if (subActivityMap.size() > 0) {
            List<Subscription_Master__c> subscriptionMasterToUpdate = subscriptionMasterMap.values();
            List<Opportunity> opps = new List<Opportunity>();
            List<ID> successSmIds = new List<ID>();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                ID smId = result.getId();
                successSmIds.add(smId);
                SageApiActivity__c activity = subActivityMap.get(smId);
                Subscription_Master__c sm = subscriptionMasterMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    if (String.isNotBlank(activity.Opportunity__c))
                        opps.add(new Opportunity(id=activity.Opportunity__c, CloseDate = Date.today(), StageName = SageApiActivityUtils.setting_OpportunityStageClosedWon));
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertEntitlementDetail', 'Enetitlement conversion failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }

            if (!opps.isEmpty()) update opps;

            if (!successSmIds.isEmpty()) {
                List<EntitlementProduct__c> entitledProducts = [SELECT id, ProductFeatures__c, SubscriptionMaster__c FROM EntitlementProduct__c WHERE SubscriptionMaster__c IN: successSmIds];
                for (EntitlementProduct__c p : entitledProducts) {
                    if (String.isBlank(p.ProductFeatures__c))
                        continue;

                    ID smId = p.SubscriptionMaster__c;
                    SageApiActivity__c activity = subActivityMap.get(smId);

                    try {
                        List<SageApiActivityRequestObjects.Feature> fs = (List<SageApiActivityRequestObjects.Feature>) JSON.deserialize(p.ProductFeatures__c, List<SageApiActivityRequestObjects.Feature>.class);
                        for (Integer i = (fs.size()-1); i>= 0; i--)
                            if(fs[i].name == 'trial')
                                fs.remove(i);

                        p.ProductFeatures__c = JSON.serialize(fs);
                    } catch (Exception ex) {
                        List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertEntitlementDetail', 'Error when updating product features. Detail' + ex);
                        SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                        ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'convertEntitlementDetail', ex);
                        continue;
                    }
                }

                if (! entitledProducts.isEmpty()) {
                    Database.UpsertResult [] upsertEpResults = Database.upsert(entitledProducts, false);
                    Integer index = -1;
                    for (Database.UpsertResult result : upsertEpResults) {
                        index++;
                        ID smId = entitledProducts[index].SubscriptionMaster__c;
                        SageApiActivity__c activity = subActivityMap.get(smId);

                        if (result.isSuccess()) {
                            SageApiActivityUtils.setSuccess(activity, step);
                            continue;
                        }

                        List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertEntitlementDetail', 'Error when saving updating product features. More detail: ' + result.getErrors());
                        SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    }
                }
            }
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void regradeEntitlementDetail(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        List<EntitlementProduct__c> entitledProducts = new List<EntitlementProduct__c>();
        List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();

        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.SubscriptionMaster__c)) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'regradeEntitlementDetail', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiActivityRequestObjects.SubscriptionAllData req = null;
            try {
                req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'regradeEntitlementDetail', ex);
                continue;
            }

            for (SageApiActivityRequestObjects.ProductResponse product : req.entitlement.products) {
                String pFeature = null;
                String launchUrl = null;
                for (SageApiActivityRequestObjects.ProductRequest pReq : req.products)
                    if (pReq.product == product.product) {
                        pFeature = JSON.serialize(pReq.features);
                        break;
                    }

                for (SageApiActivityRequestObjects.ProductResponse pRes : req.entitlement.products)
                    if (pRes.product == product.product) {
                        launchUrl = pRes.launchUrl;
                        break;
                    }

                EntitlementProduct__c entitledProduct = new EntitlementProduct__c(Name=product.product, SubscriptionMaster__c=activity.SubscriptionMaster__c, ProductFeatures__c=pFeature, LaunchUrl__c=launchUrl);
                entitledProducts.add(entitledProduct);
            }

            subActivityMap.put(activity.SubscriptionMaster__c, activity);
        }

        if (subActivityMap.size() > 0) {
            List<Subscription_Master__c> smsToUpdate = new List<Subscription_Master__c>();
            // reset pointer to activity since regraded
            for (ID smId : subActivityMap.keySet()) {
                SageApiActivity__c activity = subActivityMap.get(smId);
                SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
                smsToUpdate.add(new Subscription_Master__c(id=smId,Sage_API_Activity__c=activity.Id,Status__c=req.isTrial?Constants.ASSET_STATUS_TRIAL:Constants.ASSET_STATUS_ACTIVE,SubscriptionState__c=req.state,IsPending__c=false,PendingEntitlementData__c=null,SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null));
            }
            update smsToUpdate;

            List<EntitlementProduct__c> existingProducts = [SELECT ID, SubscriptionMaster__c FROM EntitlementProduct__c WHERE IsDeleted=false AND SubscriptionMaster__c IN: subActivityMap.keyset()];
            for (EntitlementProduct__c p : existingProducts) {
                SageApiActivity__c activity = subActivityMap.get(p.SubscriptionMaster__c);
                SageApiActivityLog__c log = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=p.SubscriptionMaster__c, LogSource__c=step.stepName, LogMessage__c='Product removed: '+JSON.serialize(p, true), LogTime__c=Datetime.Now());
                logs.add(log);
            }
            DELETE existingProducts;

            Integer index = -1;
            Database.UpsertResult [] upsertResults = Database.upsert(entitledProducts, false);
            for (Database.UpsertResult result : upsertResults) {
                index++;
                ID smId = entitledProducts[index].SubscriptionMaster__c;
                SageApiActivity__c activity = subActivityMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    SageApiActivityLog__c log = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=smId, LogSource__c=step.stepName, LogMessage__c='Product entitled: '+JSON.serialize(entitledProducts[index], true), LogTime__c=Datetime.Now());
                    logs.add(log);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'regradeEntitlementDetail', 'Enetitlement regrading failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.log(logs);
    }

    public static void updateSubscriptionEffectivePeriod(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        //activities = SageApiActivityUtils.refreshActivities(activities);
        Map<ID, SageApiActivity__c> subActivityMap = new Map<ID, SageApiActivity__c>();
        Map<ID, Subscription_Master__c> subscriptionMasterMap = new Map<ID, Subscription_Master__c>();

        for (SageApiActivity__c activity : activities) {
            List<SageApiActivityError> errors = new List<SageApiActivityError>();

            if (String.isBlank(activity.SubscriptionMaster__c)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'updateSubscriptionEffectivePeriod', 'SubscriptionMaster record not found');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            SageApiActivityRequestObjects.SubscriptionRequest req = null;
            try {
                req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionRequest.class);

                subActivityMap.put(activity.SubscriptionMaster__c, activity);
                subscriptionMasterMap.put(activity.SubscriptionMaster__c, new Subscription_Master__c(Id=activity.SubscriptionMaster__c,Start_Date__c=Date.valueOf(req.effectivePeriod.notBefore),End_Date__c=Date.valueOf(req.effectivePeriod.notAfter),IsPending__c=false,PendingEntitlementData__c=null,SuspensionReasonCode__c=null,SuspensionReasonDescription__c=null));
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'updateSubscriptionEffectivePeriod', ex);
            }
        }

        if (subActivityMap.size() > 0) {
            List<Subscription_Master__c> subscriptionMasterToUpdate = subscriptionMasterMap.values();
            List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
            for (Database.UpsertResult result : upsertResults) {
                ID smId = result.getId();
                SageApiActivity__c activity = subActivityMap.get(smId);
                Subscription_Master__c sm = subscriptionMasterMap.get(smId);

                if (result.isSuccess()) {
                    SageApiActivityUtils.setSuccess(activity, step);

                    SageApiActivityLog__c log = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=smId, LogSource__c=step.stepName, LogMessage__c='Effective period updated: '+JSON.serialize(sm, true), LogTime__c=Datetime.Now());
                    logs.add(log);
                    continue;
                }

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'updateSubscriptionEffectivePeriod', 'Updating effective period failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }

            //if (! logs.isEmpty()) insert logs;
        }

        SageApiActivityUtils.updateActivities(activities);
    }

    public static void abandon(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<Subscription_Master__c> subscriptionMasterToUpdate = new List<Subscription_Master__c>();
        List<SageApiActivityLog__c> logs = new List<SageApiActivityLog__c>();

        for (SageApiActivity__c activity : activities) {
            activity.ActivityStatus__c = SageApiStatus.Abandoned;
            if (String.isBlank(activity.SubscriptionMaster__c)) continue;
            subscriptionMasterToUpdate.add(new Subscription_Master__c(Id=activity.SubscriptionMaster__c));

            SageApiActivityLog__c log1 = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=activity.SubscriptionMaster__c, LogSource__c=step.stepName, LogMessage__c='Prepare to abandon activity', LogTime__c=Datetime.Now());
            logs.add(log1);
        }

        if (subscriptionMasterToUpdate.size() > 0) {
            subscriptionMasterToUpdate = [SELECT Id, IsPending__c, PendingEntitlementData__c, Sage_API_Activity__c, SubscriptionState__c FROM Subscription_Master__c WHERE IsPending__c=true AND Id IN: subscriptionMasterToUpdate];
            for (Subscription_Master__c sm : subscriptionMasterToUpdate) {
                sm.IsPending__c = false;
                sm.PendingEntitlementData__c = null;
            }

            if (subscriptionMasterToUpdate!=null && subscriptionMasterToUpdate.size()>0) {
                Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasterToUpdate, false);
                Integer index = -1;
                for (Database.UpsertResult result : upsertResults) {
                    index++;
                    Subscription_Master__c sm = subscriptionMasterToUpdate[index];

                    if (result.isSuccess()) {
                        continue;
                    }
                    SageApiActivityLog__c log2 = new SageApiActivityLog__c(SageApiActivity__c=sm.Sage_API_Activity__c, SubscriptionComponent__c=sm.Id, LogSource__c=step.stepName, LogMessage__c='Entitlement updates failed to be abandoned. Error detail: '+result.getErrors(), LogTime__c=Datetime.Now());
                    logs.add(log2);
                }
            }
        }

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.log(logs);
    }

    private static Map<String, SageApiActivity__c> getConvertibleLeadIds(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, SageApiActivity__c> leadMap = new Map<String, SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.Lead__c)) continue;
            leadMap.put(activity.Lead__c, activity);
        }
        SageApiActivityUtils.debug('leads to be converted: ' + leadMap.keySet());
        return leadMap;
    }

    @TestVisible
    private static string getOpportunityName(SageApiActivity__c activity) {
        if (activity == null || string.isBlank(activity.payload__c)) return null;

        SageApiSubscriptionActivityRequest req = null;
        try {
            req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getOpportunityName', ex);
            return null;
        }

        if (req == null) return null;

        string name = null;
        SageApiActivityRequestObjects.Account account = req.account;
        if (account != null && String.isNotBlank(account.name))
            name = account.name;

        if (string.isBlank(name)) {
            SageApiActivityRequestObjects.Contact contact = req.contact;
            if (contact != null)
                name = contact.firstName + ' ' + contact.lastName;
        }

        List<SageApiActivityRequestObjects.Product> products = req.subscription.products;
        if (products != null && products.size() > 0)
            name = (string.isBlank(name) ? '' : name + ' - ') + products[0].tierCode;

        return name;
    }

    private static Map<Id, String> getOpportunityNames(List<SageApiActivity__c> activities) {
        //get names from existing accounts and contacts
        if (activities == null || activities.size() == 0) return null;

        Map<Id, String> activityOppNameMap = new Map<Id, String>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for (SageApiActivity__c activity : activities) {
            if (activity.Contact__c != null) contactMap.put(activity.Contact__c, null);
            if (activity.Account__c != null) accountMap.put(activity.Account__c, null);
        }
        if (contactMap.size() > 0) contactMap.putAll([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN: contactMap.keySet()]);
        if (accountMap.size() > 0) accountMap.putAll([SELECT Id, Name FROM Account WHERE Id IN: accountMap.keySet()]);

        for (SageApiActivity__c activity : activities) {
            string name = null;
            Account account = accountMap.get(activity.Account__c);
            Contact contact = contactMap.get(activity.Contact__c);
            if (account != null) name = account.Name;
            if (string.isBlank(name) && contact != null) name = contact.FirstName + ' ' + contact.LastName;

            try {
                SageApiSubscriptionActivityRequest req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
                List<SageApiActivityRequestObjects.Product> products = req.subscription.products;
                if (products != null && products.size() > 0)
                    name = (string.isBlank(name) ? '' : name + ' - ') + products[0].tierCode;
            } catch (Exception e) {
                name += ' - Unknown Product';
            }
            activityOppNameMap.put(activity.Id, name);
        }

        return activityOppNameMap;
    }

    private static Map<String, Account> getValidRequestAccounts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, Account> accounts = new Map<String, Account>();
        Map<String, SageApiActivity__c> externalAcctActivityMap = new Map<String, SageApiActivity__c>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                if (req == null || req.account == null || string.isBlank(req.account.AccountId) || string.isBlank(req.account.accountType)) continue;

                if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == req.account.AccountType)
                    accounts.put(req.account.AccountId, null);
                else
                        externalAcctActivityMap.put(req.account.accountType+':'+req.account.accountId, activity);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestAccounts', ex);
            }
        }

        if (accounts.size() == 0 && externalAcctActivityMap.size() == 0) return null;

        try {
            List<AccountMapping__c> acctMappings = [SELECT Id, ExternalAccountKey__c, Account__c FROM AccountMapping__c WHERE ExternalAccountKey__c IN: externalAcctActivityMap.keyset()];
            for (AccountMapping__c am : acctMappings) {
                SageApiActivity__c activity = externalAcctActivityMap.get(am.ExternalAccountKey__c);
                if (activity == null) continue;
                activity.Account__c = am.Account__c;
                accounts.put(activity.Account__c, null);
            }

            accounts.putAll([SELECT Id, RecordTypeId FROM Account WHERE Id IN :accounts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestAccounts', ex);
        }

        return accounts;
    }

    private static Map<String, Contact> getValidRequestContacts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, Contact> contacts = new Map<String, Contact>();
        Map<String, SageApiActivity__c> externalContActivityMap = new Map<String, SageApiActivity__c>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                if (req == null || req.contact == null || string.isBlank(req.contact.ContactId) || string.isBlank(req.contact.contactType)) continue;

                if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == req.contact.ContactType)
                    contacts.put(req.contact.ContactId, null);
                else
                        externalContActivityMap.put(req.contact.contactType+':'+req.contact.contactId, activity);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestContacts', ex);
            }
        }

        if (contacts.size() == 0 && externalContActivityMap.size() == 0) return null;

        try {
            List<ContactMapping__c> acctMappings = [SELECT Id, ExternalContactKey__c, Contact__c FROM ContactMapping__c WHERE ExternalContactKey__c IN: externalContActivityMap.keyset()];
            for (ContactMapping__c am : acctMappings) {
                SageApiActivity__c activity = externalContActivityMap.get(am.ExternalContactKey__c);
                if (activity == null) continue;
                activity.Contact__c = am.Contact__c;
                contacts.put(activity.Contact__c, null);
            }

            contacts.putAll([SELECT Id, RecordTypeId, Email FROM Contact WHERE Id IN :contacts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestContacts', ex);
        }

        return contacts;
    }

    private static Map<string, SageUserIdentityProvider__c> getValidRequestIdentities(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();
        Map<String, SageApiActivity__c> externalAcctActivityMap = new Map<String, SageApiActivity__c>();
        Map<String, String> externalAcctContactKeyMap = new Map<String, String>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                if (req == null || req.account == null || string.isBlank(req.account.AccountId) || req.contact == null || string.isBlank(req.contact.identityId) || string.isBlank(req.contact.identityType)) continue;

                if (SageApiActivityRequestObjects.IdentifierType.Salesforce.name() == req.account.AccountType)
                    identities.put(ID.valueOf(req.account.AccountId)+':'+req.contact.identityType+':'+req.contact.identityId, null);
                else {
                    externalAcctActivityMap.put(req.account.accountType+':'+req.account.accountId, activity);
                    externalAcctContactKeyMap.put(req.account.accountType+':'+req.account.accountId, req.contact.identityType+':'+req.contact.identityId);
                }
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestIdentities', ex);
            }
        }

        if (identities.size() == 0 && externalAcctActivityMap.size() == 0) return null;

        try {
            List<AccountMapping__c> acctMappings = [SELECT Id, ExternalAccountKey__c, Account__c FROM AccountMapping__c WHERE ExternalAccountKey__c IN: externalAcctActivityMap.keyset()];
            for (AccountMapping__c am : acctMappings) {
                SageApiActivity__c activity = externalAcctActivityMap.get(am.ExternalAccountKey__c);
                String contactKey = externalAcctContactKeyMap.get(am.ExternalAccountKey__c);
                if (activity == null || String.isBlank(contactKey)) continue;
                activity.Account__c = am.Account__c;
                identities.put(ID.valueOf(activity.Account__c)+':'+contactKey, null);
            }

            identities.putAll([SELECT Id, SFBridgeID__c, Account__c, User__c, User__r.ContactId FROM SageUserIdentityProvider__c WHERE SFBridgeID__c != '' AND SFBridgeID__c IN :identities.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getValidRequestIdentities', ex);
        }

        return identities;
    }

    public static Map<String, Subscription_Master__c> getSubscriptionMasters(List<SageApiActivity__c> activities) {
        List<String> ids = new List<String>();
        for (SageApiActivity__c a : activities) {
            if (String.isNotBlank(a.SubscriptionId__c)) {
                ids.add(a.SubscriptionId__c);
                break;
            }
        }

        if (ids.size() == 0) return null;
        return getSubscriptionMasters(ids);
    }

    public static Map<String, Subscription_Master__c> getSubscriptionMasters(List<String> cbcSubscriptionIds){
        if (cbcSubscriptionIds == null || cbcSubscriptionIds.size() == 0) return null;
        Map<String, Subscription_Master__c> smMap = new  Map<String, Subscription_Master__c>();

        List<Subscription_Master__c> sms = [SELECT Account__c,CbcSubscriptionId__c,Id,Is_Blocked__c,Is_Cancelled__c,Name,Sage_API_Activity__r.Contact__c,Sage_API_Activity__r.AccountId__c,Sage_API_Activity__r.AccountIdType__c,Status__c,ChannelPartner__c,ChannelPartner__r.ChannelPartnerKey__c,Is_ZProduct_Upgradeable__c,Is_Upgraded__c,Product_Tier__r.UpgradeToProductTier__c FROM Subscription_Master__c WHERE CbcSubscriptionId__c IN :cbcSubscriptionIds];
        if (sms == null || sms.size() == null) return smMap;

        for (String subId : cbcSubscriptionIds) {
            for (Subscription_Master__c sm : sms)
                if (subId == sm.CbcSubscriptionId__c)
                    smMap.put(subId, sm);
        }
        return smMap;
    }

    public static Map<String, List<Entitlement_Message__c>> getEntitlementMessages(List<String> cbcSubscriptionIds) {
        if (cbcSubscriptionIds == null || cbcSubscriptionIds.size() == 0) return null;
        Map<String, List<Entitlement_Message__c>> msgMap = new Map<String, List<Entitlement_Message__c>>();

        List<Entitlement_Message__c> allMsgs = [SELECT CreatedDate,Id,Message_Definition_Name__c,Status__c,Subscription_Master__r.CbcSubscriptionId__c FROM Entitlement_Message__c WHERE Subscription_Master__r.CbcSubscriptionId__c IN :cbcSubscriptionIds ORDER BY Subscription_Master__c, CreatedDate DESC];
        if (allMsgs == null || allMsgs.size() == null) return msgMap;

        for (String subId : cbcSubscriptionIds) {
            List<Entitlement_Message__c> msgs = new List<Entitlement_Message__c>();
            for (Entitlement_Message__c msg : allMsgs)
                if (subId == msg.Subscription_Master__r.CbcSubscriptionId__c)
                    msgs.add(msg);
            msgMap.put(subId, msgs);
        }
        return msgMap;
    }

    public static Map<ID, String> getActivityCbcSubscriptionIds(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<ID, String> activitySubIdMap = new Map<ID, String>();

        for(SageApiActivity__c activity : activities) {
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getActivityCbcSubscriptionIds', ex);
                continue;
            }

            if (req == null || req.subscription == null || String.isBlank(req.subscription.cbcSubscriptionId)) continue;
            activitySubIdMap.put(activity.Id, req.subscription.cbcSubscriptionId);
        }
        return activitySubIdMap;
    }

    public static Map<ID, List<SageApiActivityRequestObjects.Product>> getActivityProducts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<ID, List<SageApiActivityRequestObjects.Product>> subMap = new Map<ID, List<SageApiActivityRequestObjects.Product>>();

        for(SageApiActivity__c activity : activities) {
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(activity.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getActivityProducts', ex);
                continue;
            }

            if (req == null || req.subscription == null || req.subscription.products == null || req.subscription.products.size() == 0) continue;
            subMap.put(activity.Id, req.subscription.products);
        }
        return subMap;
    }

    public static List<Account> getActivityAccounts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<Account> accounts = new List<Account>();

        for(SageApiActivity__c activity : activities) {
            try {
                SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
                if (req == null) continue;

                if (req.managingAccount != null && String.isNotBlank(req.managingAccount.id)) accounts.add(new Account(Id=req.managingAccount.id));
                if (req.entitledAccount != null && String.isNotBlank(req.entitledAccount.id)) accounts.add(new Account(Id=req.entitledAccount.id));
                if (req.partner != null && req.partner.account != null && String.isNotBlank(req.partner.account.id)) accounts.add(new Account(Id=req.partner.account.id));
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getActivityAccounts', ex);
            }
        }

        if (accounts.size() > 0) accounts = [SELECT Id FROM Account WHERE Id in: accounts];
        return accounts;
    }

    public static List<Contact> getActivityContacts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<Contact> contacts = new List<Contact>();

        for(SageApiActivity__c activity : activities) {
            try {
                SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
                if (req.customerContact != null && String.isNotBlank(req.customerContact.id)) contacts.add(new Contact(Id=req.customerContact.id));
                if (req.partner != null && req.partner.contact != null && String.isNotBlank(req.partner.contact.id)) contacts.add(new Contact(Id=req.partner.contact.id));
                if (req == null || req.customerCommunityUsers == null || req.customerCommunityUsers.size() == 0) continue;
                for (SageApiActivityRequestObjects.CommunityUser user : req.customerCommunityUsers)
                    if (String.isNotBlank(user.contactId)) contacts.add(new Contact(Id=user.contactId));
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getActivityContacts', ex);
            }
        }

        if (contacts.size() > 0) contacts = [SELECT Id, AccountId FROM Contact WHERE Id in: contacts];
        return contacts;
    }

    public static List<Subscription_Master__c> getActivitySubscriptionMasterFromGroupId(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<String> groupIds = new List<String>();

        for(SageApiActivity__c activity : activities) {
            try {
                SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(activity.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
                if (req == null || String.isBlank(req.subscriptionGroupId)) continue;
                groupIds.add(req.subscriptionGroupId);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getActivitySubscriptionMasterFromGroupId', ex);
            }
        }

        if (groupIds.isEmpty()) return null;
        return [SELECT Id, SubscriptionGroupId__c FROM Subscription_Master__c WHERE IsDeleted = false AND SubscriptionGroupId__c != null AND SubscriptionGroupId__c =: groupIds[0] ];
    }

    public static Boolean isValidAccount(List<Account> accounts, String accountId) {
        if (accounts == null || accounts.size() == 0) return false;

        try {
            ID theId = ID.valueOf(accountId);
            for (Account a : accounts)
                if (a.Id == theId) return true;
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'isValidAccount', ex);
        }
        return false;
    }

    public static Boolean isValidContact(List<Account> accounts, List<Contact> contacts, String contactId) {
        if (contacts == null || contacts.size() == 0) return false;

        try {
            ID theId = ID.valueOf(contactId);
            for (Contact c : contacts)
                if (c.Id == theId)
                    for (Account a : accounts)
                        if (c.AccountId == a.Id)
                            return true;
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'isValidContact', ex);
        }
        return false;
    }

    public static Map<String, ChannelPlatform__c> getActivityPlatforms(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, ChannelPlatform__c> platformKeyMap = new Map<String, ChannelPlatform__c>();

        for(SageApiActivity__c activity : activities) {
            if (activity == null || String.isBlank(activity.ChannelPlatformProvided__c)) continue;
            platformKeyMap.put(activity.ChannelPlatformProvided__c.toUpperCase(), null);
        }
        if (platformKeyMap.size() > 0) {
            List<ChannelPlatform__c> platforms = [SELECT Id, ChannelPlatformKey__c FROM ChannelPlatform__c WHERE ChannelPlatformKey__c IN: platformKeyMap.keyset()];
            for (ChannelPlatform__c p : platforms)
                platformKeyMap.put(p.ChannelPlatformKey__c.toUpperCase(), p);
        }

        return platformKeyMap;
    }

    public static Map<String, ChannelPartner__c> getActivityPartners(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, ChannelPlatform__c> platformKeyMap = new Map<String, ChannelPlatform__c>();
        Map<String, ChannelPartner__c> partnerKeyMap = new Map<String, ChannelPartner__c>();
        List<SageApiActivity__c> validActivities = new List<SageApiActivity__c>();

        for(SageApiActivity__c activity : activities) {
            if (activity == null || String.isBlank(activity.ChannelPlatformProvided__c) || String.isBlank(activity.ChannelPartnerProvided__c)) continue;
            platformKeyMap.put(activity.ChannelPlatformProvided__c.toUpperCase(), null);
            partnerKeyMap.put(activity.ChannelPlatformProvided__c.toUpperCase()+':'+activity.ChannelPartnerProvided__c.toUpperCase(), null);
            validActivities.add(activity);
        }
        if (platformKeyMap.size() > 0) {
            List<ChannelPlatform__c> platforms = [SELECT Id, ChannelPlatformKey__c FROM ChannelPlatform__c WHERE ChannelPlatformKey__c IN: platformKeyMap.keyset()];
            for (ChannelPlatform__c p : platforms)
                platformKeyMap.put(p.ChannelPlatformKey__c.toUpperCase(), p);
        }
        if (partnerKeyMap.size() > 0) {
            List<ChannelPartner__c> partners = [SELECT Id, ChannelPartnerKey__c, ChannelPlatform__c FROM ChannelPartner__c WHERE ChannelPartnerKey__c IN: partnerKeyMap.keyset()];
            for (ChannelPartner__c p : partners)
                partnerKeyMap.put(p.ChannelPartnerKey__c.toUpperCase(), p);
        }

        List<ChannelPartner__c> newPartners = new List<ChannelPartner__c>();
        for (String key : partnerKeyMap.keySet()) {
            ChannelPartner__c pt = partnerKeyMap.get(key);
            if (pt != null) continue;
            for (SageApiActivity__c activity : validActivities) {
                ChannelPlatform__c pl = platformKeyMap.get(activity.ChannelPlatformProvided__c.toUpperCase());
                if (pl != null && key == activity.ChannelPlatformProvided__c+':'+activity.ChannelPartnerProvided__c) {
                    pt = new ChannelPartner__c(name=activity.ChannelPartnerProvided__c, ChannelPartnerKey__c=key, ChannelPlatform__c=pl.Id);
                    newPartners.add(pt);
                    break;
                }
            }
        }

        if (newPartners.size() == 0) return partnerKeyMap;
        insert newPartners;

        for (ChannelPartner__c newPartner : newPartners)
            for (String key : partnerKeyMap.keySet())
                if (newPartner.ChannelPartnerKey__c.toUpperCase() == key.toUpperCase()) {
                    partnerKeyMap.put(key, newPartner);
                    break;
                }

        return partnerKeyMap;
    }

    private static List<SageApiActivityRequestObjects.Product> getRequestProducts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<SageApiActivityRequestObjects.Product> allProducts = new List<SageApiActivityRequestObjects.Product>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                if (req == null || req.subscription == null) continue;
                if (req.subscription.products == null || req.subscription.products.size() == 0) continue;

                for (SageApiActivityRequestObjects.Product product : req.subscription.products) {
                    Boolean canAdd = true;
                    for (SageApiActivityRequestObjects.Product existingProduct : allProducts) {
                        if (existingProduct.tierCode == product.tierCode && existingProduct.tierRatePlanCode == product.tierRatePlanCode) {
                            canAdd = false;
                            break;
                        }
                    }
                    if (canAdd)
                        allProducts.add(product);
                }
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getRequestProducts', ex);
                return null;
            }
        }
        return allProducts;
    }


    public static List<SageApiActivityRequestObjects.ProductRequest> getProductRequests(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<SageApiActivityRequestObjects.ProductRequest> prodReqs = new List<SageApiActivityRequestObjects.ProductRequest>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiActivityRequestObjects.SubscriptionRequest req = null;
            try {
                req = (SageApiActivityRequestObjects.SubscriptionRequest)JSON.deserialize(payload, SageApiActivityRequestObjects.SubscriptionRequest.class);
                if (req == null || req.products == null || req.products.size() == 0) continue;

                for (SageApiActivityRequestObjects.ProductRequest productReq : req.products) {
                    Boolean canAdd = true;
                    for (SageApiActivityRequestObjects.ProductRequest existingReq : prodReqs) {
                        if (existingReq.product == productReq.product) {
                            canAdd = false;
                            break;
                        }
                    }
                    if (canAdd)
                        prodReqs.add(productReq);
                }
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getProductRequests', ex);
                return null;
            }
        }
        return prodReqs;
    }

    @TestVisible
    private static Map<Id, Lead> getRequestLeads(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Lead> leads = new Map<Id, Lead>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(payload, SageApiSubscriptionActivityRequest.class);
                if (req == null) continue;

                SageApiActivityRequestObjects.Contact contact = req.contact;
                if (contact == null || string.isBlank(contact.leadId)) continue;

                leads.put(contact.leadId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getRequestLeads', ex);
            }
        }

        if (leads.size() == 0 ) return null;

        try {
            leads.putAll([SELECT Id, IsConverted FROM Lead WHERE Id IN :leads.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'getRequestLeads', ex);
        }

        return leads;
    }

    @TestVisible
    private static void saveAccountMappings(List<SageApiActivity__c> activities) {
        List<ID> sfAccountIds = new List<ID>();
        List<String> extAccountIds = new List<String>();
        List<String> extAccountTypes = new List<String>();
        List<String> extAccountKeys = new List<String>();
        for (SageApiActivity__c a : activities) {
            if (String.isBlank(a.Account__c) || String.isBlank(a.AccountId__c) || String.isBlank(a.AccountIdType__c) || a.AccountIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) continue;
            sfAccountIds.add(a.Account__c);
            extAccountIds.add(a.AccountId__c);
            extAccountTypes.add(a.AccountIdType__c);
            extAccountKeys.add(a.AccountIdType__c+':'+a.AccountId__c);
        }

        List<AccountMapping__c> existingAcctMappings = [SELECT ID, ExternalAccountKey__c FROM AccountMapping__c WHERE ExternalAccountKey__c IN: extAccountKeys];
        List<AccountMapping__c> acctMappings = new List<AccountMapping__c>();
        for (Integer i = 0; i < sfAccountIds.size(); i++) {
            Boolean hasRecord = false;
            for (AccountMapping__c a : existingAcctMappings)
                if (extAccountKeys[i] == a.ExternalAccountKey__c) {
                    hasRecord = true;
                    break;
                }
            if (hasRecord) continue;
            AccountMapping__c acctMapping = new AccountMapping__c(Name=extAccountKeys[i], ExternalAccountKey__c=extAccountKeys[i], Account__c=sfAccountIds[i], ExternalAccountId__c=extAccountIds[i], ExternalAccountType__c=extAccountTypes[i]);
            acctMappings.add(acctMapping);
        }
        INSERT acctMappings;
    }

    @TestVisible
    private static void saveContactMappings(List<SageApiActivity__c> activities) {
        List<ID> sfContactIds = new List<ID>();
        List<String> extContactIds = new List<String>();
        List<String> extContactTypes = new List<String>();
        List<String> extContactKeys = new List<String>();
        for (SageApiActivity__c a : activities) {
            if (String.isBlank(a.Contact__c) || String.isBlank(a.ContactId__c) || String.isBlank(a.ContactIdType__c) || a.ContactIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name()) continue;
            sfContactIds.add(a.Contact__c);
            extContactIds.add(a.ContactId__c);
            extContactTypes.add(a.ContactIdType__c);
            extContactKeys.add(a.ContactIdType__c+':'+a.ContactId__c);
        }

        List<ContactMapping__c> existingContMappings = [SELECT ID, ExternalContactKey__c FROM ContactMapping__c WHERE ExternalContactKey__c IN: extContactKeys];
        List<ContactMapping__c> contMappings = new List<ContactMapping__c>();
        for (Integer i = 0; i < sfContactIds.size(); i++) {
            Boolean hasRecord = false;
            for (ContactMapping__c a : existingContMappings)
                if (extContactKeys[i] == a.ExternalContactKey__c) {
                    hasRecord = true;
                    break;
                }
            if (hasRecord) continue;
            ContactMapping__c contMapping = new ContactMapping__c(Name=extContactKeys[i], ExternalContactKey__c=extContactKeys[i], Contact__c=sfContactIds[i], ExternalContactId__c=extContactIds[i], ExternalContactType__c=extContactTypes[i]);
            contMappings.add(contMapping);
        }
        INSERT contMappings;
    }

    private static List<SageApiActivity__c> validateAndMapToInternalAccounts(List<SageApiActivity__c> activities) {
        List<ID> sfAccountIds = new List<ID>();
        List<String> externalAccountKeys = new List<String>();
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c a : activities) {
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(a.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateAndMapToInternalAccounts', ex);
                continue;
            }

            SageApiActivityRequestObjects.Account account = req.account;
            if (account == null || String.isBlank(account.accountId) || String.isBlank(account.accountType) || ! SageApiActivityUtils.identifierTypeExists(account.accountType)) continue;

            a.AccountId__c = account.accountId;
            a.AccountIdType__c = account.accountType;
            if (a.AccountIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name())
                try {
                    a.Account__c = a.AccountId__c;
                } catch (Exception ex) {
                    ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateAndMapToInternalAccounts', ex);
                    continue;
                }
            externalAccountKeys.add(a.AccountIdType__c+':'+a.AccountId__c);
            candidateActivities.add(a);
        }

        if (externalAccountKeys.size() == 0) return activities;

        List<AccountMapping__c> existingAcctMappings = [SELECT ID, Account__c, ExternalAccountKey__c FROM AccountMapping__c WHERE ExternalAccountKey__c IN: externalAccountKeys];
        for (Integer i = 0; i < externalAccountKeys.size(); i++)
            for (AccountMapping__c a : existingAcctMappings) {
                if (externalAccountKeys[i] != a.ExternalAccountKey__c) continue;
                candidateActivities[i].Account__c = a.Account__c;
            }

        return activities;
    }

    private static List<SageApiActivity__c> validateAndMapToInternalContacts(List<SageApiActivity__c> activities) {
        List<ID> sfContactIds = new List<ID>();
        List<String> externalContactKeys = new List<String>();
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c a : activities) {
            SageApiSubscriptionActivityRequest req = null;
            try {
                req = (SageApiSubscriptionActivityRequest)JSON.deserialize(a.payload__c, SageApiSubscriptionActivityRequest.class);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateAndMapToInternalContacts', ex);
                continue;
            }

            SageApiActivityRequestObjects.Contact contact = req.contact;
            if (contact == null || String.isBlank(contact.contactId) || String.isBlank(contact.contactType) || ! SageApiActivityUtils.identifierTypeExists(contact.contactType)) continue;

            a.ContactId__c = contact.contactId;
            a.ContactIdType__c = contact.contactType;

            if (a.ContactIdType__c == SageApiActivityRequestObjects.IdentifierType.Salesforce.name())
                try {
                    a.Contact__c = a.ContactId__c;
                } catch (Exception ex) {
                    ExceptionHandler.CatchException('SageApiSubscriptionActivityUtils', 'validateAndMapToInternalAccounts', ex);
                    continue;
                }

            externalContactKeys.add(a.ContactIdType__c+':'+a.ContactId__c);
            candidateActivities.add(a);
        }

        if (externalContactKeys.size() == 0) return activities;

        List<ContactMapping__c> existingAcctMappings = [SELECT ID, Contact__c, ExternalContactKey__c FROM ContactMapping__c WHERE ExternalContactKey__c IN: externalContactKeys];
        for (Integer i = 0; i < externalContactKeys.size(); i++) {
            for (ContactMapping__c a : existingAcctMappings) {
                if (externalContactKeys[i] != a.ExternalContactKey__c) continue;
                candidateActivities[i].Contact__c = a.Contact__c;
            }
        }
        return activities;
    }

    private static void linkMsgsToActivities(List<Entitlement_Message__c> msgs, List<SageApiActivity__c> activities) {
        if (msgs == null || msgs.size() == 0 || activities == null || activities.size() == 0) return;
        for (SageApiActivity__c activity : activities)
            for (Entitlement_Message__c msg : msgs)
                if (activity.SubscriptionMaster__c == msg.Subscription_Master__c) {
                    activity.Entitlement_Message__c = msg.Id;
                    break;
                }
    }

    @TestVisible
    private static String getCustomAttribute(List<SageApiActivityRequestObjects.Attribute> attributes, String key) {
        if (attributes == null || String.isBlank(key)) return null;

        for (SageApiActivityRequestObjects.Attribute attr : attributes)
            if (attr.name == key)
                return attr.value;
        return null;
    }

    private static void copyActivityValues(SageApiActivity__c sourceActivity, SageApiActivity__c targetActivity) {
        if (sourceActivity.id == targetActivity.id) return;
        targetActivity.Account__c = sourceActivity.Account__c;
        targetActivity.Contact__c = sourceActivity.Contact__c;
        targetActivity.Lead__c = sourceActivity.Lead__c;
        targetActivity.Opportunity__c = sourceActivity.Opportunity__c;
        targetActivity.ManagingAccount__c = sourceActivity.ManagingAccount__c;
        targetActivity.PartnerAccount__c = sourceActivity.PartnerAccount__c;
        targetActivity.PartnerContact__c = sourceActivity.PartnerContact__c;
        targetActivity.SubscriptionId__c = sourceActivity.SubscriptionId__c;
        targetActivity.EntitlementId__c = sourceActivity.EntitlementId__c;
        //targetActivity.businessId__c = sourceActivity.businessId__c;
        targetActivity.SubscriptionMaster__c = sourceActivity.SubscriptionMaster__c;
        targetActivity.SubscriptionGroupId__c = sourceActivity.SubscriptionGroupId__c;
        targetActivity.ClientRef__c = sourceActivity.ClientRef__c;
        if (targetActivity.ActivityType__c != SageApiActivityTriggerHandler.RegradeSubscriptionActivityType) {
            targetActivity.ProductCountries__c = sourceActivity.ProductCountries__c;
            targetActivity.ProductNames__c = sourceActivity.ProductNames__c;
        }
    }

    private  static void afterSubscriptionMasterCreated(SageApiActivityStep step, SageApiActivity__c activity, ID smId, List<EntitlementProduct__c> entitledProducts, List<ID> smsToCleanup, List<SageApiActivityLog__c> logs) {
        smsToCleanup.add(smId);
        activity.SubscriptionMaster__c = smId;
        //SageApiActivityStep previousStep = SageApiActivityUtils.getLastCompletedStep(activity);
        //SageApiActivityRequestObjects.SubscriptionResponse res = (SageApiActivityRequestObjects.SubscriptionResponse) JSON.deserialize(previousStep.StepInput, SageApiActivityRequestObjects.SubscriptionResponse.class);
        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(activity.Payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        for (SageApiActivityRequestObjects.ProductResponse product : req.entitlement.products) {
            String pFeature = null;
            String launchUrl = null;
            for (SageApiActivityRequestObjects.ProductRequest pReq : req.products)
                if (pReq.product == product.product) {
                    pFeature = JSON.serialize(pReq.features);
                    break;
                }

            for (SageApiActivityRequestObjects.ProductResponse pRes : req.entitlement.products)
                if (pRes.product == product.product) {
                    launchUrl = pRes.launchUrl;
                    break;
                }

            EntitlementProduct__c entitledProduct = new EntitlementProduct__c(Name=product.product, SubscriptionMaster__c=smId, ProductFeatures__c=pFeature, LaunchUrl__c=launchUrl);
            entitledProducts.add(entitledProduct);

        }

        SageApiActivityLog__c log2 = new SageApiActivityLog__c(SageApiActivity__c=activity.Id, SubscriptionComponent__c=activity.SubscriptionMaster__c, LogSource__c=step.stepName, LogMessage__c='Products entitled: '+JSON.serialize(entitledProducts, true), LogTime__c=Datetime.Now());
        logs.add(log2);

        SageApiActivityUtils.setSuccess(activity, step);
    }
}