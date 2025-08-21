public class SageApiTryNowActivityUtils {
    public static Boolean validatePayload(SageApiActivity__c activity, SageApiActivityStep step, List<Product_Tier__c> productTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans, Map<Id, Lead> leadMap, Map<string, List<PricingCodeCharge__c>> pricingChargeMap, Map<Id, Account> accounts, Map<Id, Contact> contacts, Map<string, SageUserIdentityProvider__c> identities, Map<ID, Community_Membership__c> contactCommunitiesMap, Map<ID, ID> activitySubMasterMap, Map<string, SageApiActivityReferrerPromotion__c> promotions ) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();
        System.debug('pricingChargeMap='+JSON.serialize(pricingChargeMap));

        if (activity == null || step == null)
            return false;

        SageApiTryNowActivityRequest req = null;
        try {
            req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'validatePayload', ex);
            return false;
        }

        if (req == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid: null value resulted from deserialization');
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        SageApiActivityUtils.debug('validatePayload req: ['+ req + ']');

        if (String.isNotBlank(req.legacyUpgradeFrom)) {
            String[] values = SageApiActivityUtils.getPicklistValues('Subscription_Master__c', 'LegacyUpgradeFrom__c');
            Boolean found = false;
            for (String val : values)
                if (val == req.legacyUpgradeFrom) {
                    found = true;
                    break;
                }

            if (! found)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'legacyUpgradeFrom', 'legacyUpgradeFrom is not valid: ' + req.legacyUpgradeFrom);
        }

        Boolean productValidated = false;
        if (String.isNotBlank(req.referrerPromotion)) {
            Boolean found = false;
            for (String key : promotions.keySet())
                if (key == req.referrerPromotion) {
                    SageApiActivityReferrerPromotion__c prom = promotions.get(key);
                    if (prom == null) {
                        SageApiActivityUtils.debug('---No referrelpromotion matched');
                        continue;
                    }
                    found = true;
                    req.products.clear();
                    SageApiActivityRequestObjects.Product product = new SageApiActivityRequestObjects.Product();
                    product.pricingCode = prom.PricingCode__r.Name;
                    product.tierCode = prom.PricingCode__r.Product_Tier__r.Product_Tier_Code__c;
                    product.tierRatePlanCode = prom.PricingCode__r.ProductTierRatePlanCode__r.Name;
                    req.products.add(product);
                    activity.Payload__c = JSON.serializePretty(req);
                    activity.ReferrerPromotion__c = prom.Id;
                    productValidated = true;
                    break;
                }

            SageApiActivityUtils.debug('---found='+found);
            if (! found) {
                activity.ChannelPlatformProvided__c = req.referrerPromotion;
                activity.ChannelPartnerProvided__c = req.referrerPromotion;
                List<SageApiActivity__c> activities = new List<SageApiActivity__c> {activity};

                // no bulkification use case, so it is ok to violate here for now
                SageApiActivityUtils.debug('---Now Looking for channel platform');
                Map<String, ChannelPlatform__c> platforms = SageApiSubscriptionActivityUtils.getActivityPlatforms(activities);
                SageApiActivityUtils.debug('---platforms='+platforms);
                if (platforms != null) {
                    ChannelPlatform__c platform = platforms.get(req.referrerPromotion.toUpperCase());
                    SageApiActivityUtils.debug('---platform='+platform);
                    if (platform != null) {
                        SageApiActivityUtils.debug('---platform found');
                        Map<String, ChannelPartner__c> partners = SageApiSubscriptionActivityUtils.getActivityPartners(activities);
                        SageApiActivityUtils.debug('---partners='+partners);
                        if (partners != null) {
                            SageApiActivityUtils.debug('---partners found');
                            ChannelPartner__c partner = partners.get((req.referrerPromotion+':'+req.referrerPromotion).toUpperCase());
                            SageApiActivityUtils.debug('---partner='+partner);
                            if (partner != null) {
                                activity.ChannelPartner__c = partner.Id;
                                found = true;
                                SageApiActivityUtils.debug('---Set channel partner');
                            }
                        }
                    }
                }
            }

            SageApiActivityUtils.debug('---found='+found);
            if (! found) {
                activity.ChannelPlatformProvided__c = null;
                activity.ChannelPartnerProvided__c = null;
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'referrerPromotion', 'referrerPromotion is not valid: ' + req.referrerPromotion);
            }
        }

        // validate root-level attributes
        if (String.isBlank(req.startDate)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'startDate', 'Start Date is required');
        }

        Date startDate = Date.newInstance(2000, 1, 1);
        Date endDate = Date.newInstance(2000, 1, 1);

        if (String.isNotBlank(req.startDate)) {
            try {
                // Zuora is using PDT time zone, so we have to compare quoteEffectiveStartDate against current date/time in PDT time zone.
                String pdtDateNowString = DateTime.now().format('yyyy-MM-dd', 'America/Los_Angeles');
                Date pdtNowDate = Date.valueOf(pdtDateNowString);
                startDate = Date.valueOf(req.startDate);

                // allow 1 day to offset timezone difference
                if (startDate.addDays(1) < pdtNowDate) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'startDate', 'Start Date cannot be a past date');
                }
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'startDate', 'Start Date not in valid format');
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'validatePayload', ex);
            }
        }

        if (String.isNotBlank(req.endDate)) {
            try {
                endDate= Date.valueOf(req.endDate);

                if (endDate < startDate) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date must be later than Start Date');
                }
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date not in valid format');
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'validatePayload', ex);
            }
        }

        SageApiActivityRequestObjects.Account account = req.account;
        if (account == null)
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'account', 'account is required');

        if (account != null && String.isBlank(account.accountId) && String.isBlank(account.name))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'name', 'Account Name is required');

        // TODO: add VAT number validation

        SageApiActivityRequestObjects.Contact contact = req.contact;
        if (contact == null)
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contact', 'Contact is required');

        if (contact != null) {
            if (String.isBlank(contact.identityType)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityType', 'Identity Type is required');
            }

            if (String.isBlank(contact.identityId))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityId', 'Identity ID is required');

            if (String.isNotBlank(contact.leadId)) {
                Boolean matched = false;
                if (leadMap != null && leadMap.size() > 0)
                    for(Lead l : leadMap.values()) {
                        if (l.Id != contact.leadId) continue;
                        matched = true;

                        if (l.IsConverted)
                            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'leadId', 'Lead has already been converted');

                        break;
                    }

                if (leadMap == null || leadMap.size() == 0 || ! matched)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'leadId', 'Lead ID does not exist');
            }

            if (String.isBlank(contact.contactId) && String.isBlank(contact.leadId)) {
                if (String.isBlank(contact.firstName))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required when Lead id is not provided');

                if (String.isBlank(contact.lastName))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required when Lead id is not provided');

                if (String.isBlank(contact.email))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'email', 'Email is required when Lead id is not provided');
                else
                        activity.ContactEmail__c = contact.email;
            }
        }

        if (req.account != null && String.isNotBlank(req.account.AccountId)) {
            Boolean matched = false;
            if (accounts != null && accounts.size() > 0) {
                for(Account a : accounts.values()) {
                    if (a == null || a.Id != req.account.AccountId) continue;
                    matched = true;
                    activity.Account__c = a.Id;
                    break;
                }
            }

            if (accounts == null || accounts.size() == 0 || ! matched)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'AccountId', 'Account ID does not exist');
        }

        if (req.contact != null && String.isNotBlank(req.contact.ContactId)) {
            Boolean matched = false;
            if (contacts != null && contacts.size() > 0) {
                for(Contact c : contacts.values()) {
                    if (c == null || c.Id != req.contact.ContactId) continue;
                    matched = true;
                    activity.Contact__c = c.Id;
                    break;
                }
            }

            if (contacts == null || contacts.size() == 0 || ! matched)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ContactId', 'Contact ID does not exist');
        }

        if (identities != null && identities.size() > 0 && String.isNotBlank(activity.Account__c) && String.isNotBlank(activity.Contact__c) && req.contact != null && String.isNotBlank(req.contact.identityType) && String.isNotBlank(req.contact.identityId)) {
            try {
                ////Boolean hasMatchingContact = false;
                String sfBrdigeId = ID.valueOf(activity.Account__c) + ':' + req.contact.identityType + ':' + req.contact.identityId;
                SageApiActivityUtils.debug('sfBrdigeId: '+sfBrdigeId);
                for (SageUserIdentityProvider__c identity : identities.values()) {
                    ////if (identity != null && identity.User__r.ContactId == activity.Contact__c) hasMatchingContact = true;
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
                    ////SageApiActivityUtils.debug('Set activity artifact fields: '+activity);
                    ////SageApiActivityUtils.setSuccess(activity, step);
                    ////return true;
                }

                ////if (hasMatchingContact)
                ////    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'ContactId', 'A user has been created under the contact already');
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Locating existing user', 'Error detail: '+ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                return false;
            }
        }

        // validate products
        List<SageApiActivityRequestObjects.Product> products = req.products;
        if (String.isBlank(req.purchasingTicket) && (products == null || products.size() == 0))
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'purchasingTicket or products', 'Provides either Purchasing Ticket or Products');

        // TODO: validate purchasing ticket

        if (! productValidated && products != null) {
            System.debug('charge map key='+products[0].tierCode+':'+products[0].tierRatePlanCode+':'+products[0].pricingCode);
            if (products.size() > 1)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.ValueOutOfRange, 'tierCode', 'Only one Product Tier Code is supported');

            if (products.size() > 0 && String.IsBlank(products[0].tierCode))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code is required');

            if ((activity.ActivityType__c == SageApiActivityTriggerHandler.TryNowActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TryNow2ActivityType) && products.size() > 0 && String.IsBlank(products[0].tierRatePlanCode))
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code is required');

            if (products.size() > 0 && String.IsNotBlank(products[0].pricingCode)) {
                List<PricingCodeCharge__c> pricingCharges = pricingChargeMap.get(products[0].tierCode+':'+products[0].tierRatePlanCode+':'+products[0].pricingCode);
                if (products[0].pricingCode != '_LIST' && (pricingCharges == null || pricingCharges.size() == 0))
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

            if (products.size() > 0 && String.IsNotBlank(products[0].tierRatePlanCode)) {
                Boolean hasMatchingPtrp = false;
                SageApiActivityUtils.debug('productTierRatePlans: ' + productTierRatePlans);
                SageApiActivityUtils.debug('products[0]: ' + products[0]);
                for (Product_Tier_Rate_Plan__c ptrp : productTierRatePlans) {
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

        if (activitySubMasterMap != null && activitySubMasterMap.size() > 0) {
            ID subMasterId = activitySubMasterMap.get(activity.Id);
            if (String.isNotBlank(subMasterId)) {
                activity.SubscriptionMaster__c = subMasterId;
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'subscriptionMaster', 'The account has already subscribed to this product');
            }
        }

        if (errors.size() > 0) {
            SageApiActivityUtils.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        if (String.isNotBlank(account.accountId))
            activity.Account__c = account.accountId;
        if (String.isNotBlank(contact.contactId))
            activity.Contact__c = contact.contactId;
        if (String.isNotBlank(req.paymentUrl))
            activity.paymentUrl__c = req.paymentUrl;
        activity.ActivityStatus__c = SageApiStatus.InProgress;
        SageApiActivityUtils.setSuccess(activity, step);
        SageApiActivityUtils.debug('Success: '+JSON.serialize(activity));
        return true;
    }

    public static void createOrUpdateLead(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.IsNotBlank(activity.Lead__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            candidateActivities.add(activity);
        }

        List<String> leadIds = getRequestLeadIds(candidateActivities);
        List<Lead> leads = null;
        List<SageApiActivity__c> activitiesForTryNow = new List<SageApiActivity__c>();
        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();

        if (leadIds != null && leadIds.size() > 0) {
            leads = [SELECT company, firstName, lastName, email, phone, status, street, city, state, postalCode, country, currencyIsoCode, Product__c FROM Lead WHERE id in: leadIds];
        }

        if (leads == null) leads = new List<Lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Standard Lead').getRecordTypeId();
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c, SalesOffice__c FROM Locale__c WHERE Default_Locale__c = 'Yes' AND IsDeleted = false];

        for (SageApiActivity__c activity : candidateActivities) {
            SageApiActivityUtils.debug('');
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead upsert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createOrUpdateLead', ex);
                continue;
            }

            SageApiActivityRequestObjects.Account account = req.account;
            if (account == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'account', 'account is required');
                continue;
            }

            SageApiActivityRequestObjects.Contact contact = req.contact;
            if (contact == null) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'contact', 'Contact is required');
                continue;
            }

            if (req.products != null && req.products.size() > 0)
                products.add(req.products[0]);
            else
                    products.add(null);

            string countryCode = null;
            string salesOffice = 'Atlanta CBC';
            string currencyIsoCode = null;
            if (req.contact != null && string.isNotBlank(req.contact.countryCode))
                countryCode = req.contact.countryCode;
            else if (req.account != null && string.isNotBlank(req.account.countryCode))
                countryCode = req.account.countryCode;
            if (string.isNotBlank(countryCode)) {
                Locale__c locale = null;
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

            Boolean hasLead = false;
            for (Lead lead : leads) {
                if (String.IsBlank(contact.leadId) || lead.id != contact.leadId) continue;

                hasLead = true;

                if (String.isNotBlank(contact.firstName))
                    lead.firstName = contact.firstName;
                if (String.isNotBlank(contact.lastName))
                    lead.lastName = contact.lastName;
                if (String.isNotBlank(account.name))
                    lead.company = account.name;
                //if (String.isNotBlank(account.currencyCode))
                //    lead.currencyIsoCode = account.currencyCode;
                if (String.isNotBlank(contact.email))
                    lead.email = contact.email;
                if (String.isNotBlank(account.phone))
                    lead.phone = account.phone;
                else if (String.isNotBlank(contact.phone))
                    lead.phone = contact.phone;
                if (String.isNotBlank(account.address1))
                    lead.street = account.address1+(String.isBlank(account.address2) ? '' : '\n'+account.address2);
                else if (String.isNotBlank(contact.address1))
                    lead.street = contact.address1+(String.isBlank(contact.address2) ? '' : '\n'+contact.address2);
                if (String.isNotBlank(account.city))
                    lead.city= account.city;
                else if (String.isNotBlank(contact.city))
                    lead.city = contact.city;
                if (String.isNotBlank(account.state))
                    lead.stateCode= account.state;
                else if (String.isNotBlank(contact.state))
                    lead.stateCode= contact.state;
                if (String.isNotBlank(account.postalCode))
                    lead.postalCode= account.postalCode;
                else if (String.isNotBlank(contact.postalCode))
                    lead.postalCode= contact.postalCode;
                if (String.isNotBlank(account.countryCode))
                    lead.countryCode = account.countryCode;
                else if (String.isNotBlank(contact.countryCode))
                    lead.countryCode= contact.countryCode;
                lead.Sales_Office__c = salesOffice;
                if (string.isNotBlank(currencyIsoCode))
                    lead.CurrencyIsoCode = currencyIsoCode;

                break;
            }
            SageApiActivityUtils.debug('activity: ' + activity.ActivityID__c + ', hasLead:' + hasLead);
            activitiesForTryNow.add(activity);

            if (hasLead) continue;

            // no lead created before
            Lead lead = new Lead(
                    firstName = contact.firstName,
                    lastName = contact.lastName,
                    company = account.name,
                    email = contact.email,
                    phone = String.IsBlank(account.phone) ? contact.phone: account.phone,
                    //status = 'New', leadSource = 'Other', Product__c = 'GL - Sage One',
                    Street = String.IsBlank(account.address1) ? (contact.address1+(String.isBlank(contact.address2) ? '' : '\n'+contact.address2)) : (account.address1+(String.isBlank(account.address2) ? '' : '\n'+account.address2)),
                    City = String.IsBlank(account.address1) ? contact.city : account.city,
                    StateCode = String.IsBlank(account.address1) ? contact.state : account.state,
                    PostalCode = String.IsBlank(account.address1) ? contact.postalCode : account.postalCode ,
                    CountryCode = String.IsBlank(account.address1) ? contact.countryCode : account.countryCode,
                    Sales_Office__c = salesOffice,
                    RecordTypeId = recordTypeId
            );
            if (string.isNotBlank(currencyIsoCode))
                lead.CurrencyIsoCode = currencyIsoCode;

            SageApiActivityUtils.ensureRecordOwner(lead);
            leads.add(lead);
            SageApiActivityUtils.debug('activity no lead, so create one: ' + activity.ActivityID__c + ', lead:' + lead);
        }

        List<Product_Tier__c> listTierData = SageApiActivityUtils.getProductTiers(products);
        Integer leadIndex = -1;
        for (Lead l : leads) {
            leadIndex++;
            SageApiActivityRequestObjects.Product product = products[leadIndex];
            for (Product_Tier__c tierData : listTierData) {
                if (product != null && product.tierCode == tierData.Product_Tier_Code__c) {
                    l.Product__c = tierData.SageProduct__c;
                    continue;
                }
            }
        }
        SageApiActivityUtils.debug('all leads to upsert: ' + leads);
        SageApiActivityUtils.debug('activitiesForTryNow: ' + activitiesForTryNow);

        upsertLeads(step, activitiesForTryNow, leads);

        SageApiActivityUtils.updateActivities(activities);
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

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead upsert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createOrUpdateLead', ex);
                continue;
            }

            if (req.products == null || req.products.size() == 0) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Product', 'Product info missing in payload');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            contactMap.put(activity.Contact__c, null);
            accountMap.put(activity.Account__c, null);
            products.add(req.products[0]);
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
            SageApiActivityUtils.ensureRecordOwner(lead);
            leads.add(lead);
            SageApiActivityUtils.debug('new lead: ' + activity.ActivityID__c + ', lead:' + lead);
        }

        upsertLeads(step, candidateActivities, leads);
        SageApiActivityUtils.updateActivities(activities);
    }

    public static void convertLead(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, SageApiActivity__c> leadActivityMap = getConvertibleLeadIds(activities);
        List<Lead> leads = null;
        List<SageApiActivity__c> activitiesForTryNow = new List<SageApiActivity__c>();
        Map<ID, SageApiActivityRequestObjects.Product> leadProductMap = new Map<ID, SageApiActivityRequestObjects.Product>();
        Map<ID, Product_Tier_Rate_Plan__c> oppProductRatePlanTierMap = new Map<ID, Product_Tier_Rate_Plan__c>();
        Map<ID, Date> leadStartDateMap = new Map<ID, Date>();
        Map<ID, Date> oppStartDateMap = new Map<ID, Date>();
        //List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();

        if (leadActivityMap == null || leadActivityMap.size() == 0) return;

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
            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
            } catch (Exception ex) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'Payload', 'Activity Payload is not valid during lead convert. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createOrUpdateLead', ex);
                continue;
            }

            String opportunityName = activityOppNameMap.get(activity.Id);
            //if (string.isBlank(opportunityName)) opportunityName = getOpportunityName(activity);
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

            leadStartDateMap.put(lead.Id, (String.IsBlank(req.startDate) ? Date.valueOf(Date.today()) : Date.valueOf(req.startDate)));
            if (req.products != null && req.products.size() > 0)
                leadProductMap.put(lead.Id, req.products[0]);
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
                    activity.Opportunity__c = result.opportunityId;
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
            List<Account> accts = [SELECT id, Sales_Office__c, BillingCountryCode FROM Account WHERE id in:acctIDs];
            ////Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
            SageApiActivityUtils.debug('update accts after lead convert: '+JSON.serialize(accts));
            if (accts == null || accts.size() == 0 ) return;

            for (Account acct : accts) {
                String payload = accountPayloadMap.get(acct.Id);
                if (payload != null) {
                    try {
                        SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
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
                //acct.RecordTypeId = recordTypeId;
                acct.Type = 'Customer';
            }

            update accts;
        }
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
                SageApiTryNowActivityRequest request = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                reqIdentityIds.add(request.contact.identityId);
                reqIdentityTypes.add(request.contact.identityType);
                reqCommunityRoles.add(SageApiActivityUtils.setting_CustomerCommunityAdminRoleName);
                reqCommunityNames.add(SageApiActivityUtils.setting_CustomerCommunityName);

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
                SageApiActivityUtils.ensureRecordOwner(member);
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
            string bridgeId = c.AccountId + ':' + reqIdentityType + ':' + reqIdentityId;
            userIdentity.SFBridgeID__c = bridgeId;
            // name field is limited to 80 characters
            userIdentity.Name = bridgeId.length() > 80 ? bridgeId.substring(0, 80) : bridgeId;

            if (locale != null && string.isNotBlank(locale.currencyIsoCode))
                userIdentity.CurrencyIsoCode = locale.currencyIsoCode;
            SageApiActivityUtils.ensureRecordOwner(userIdentity);
            userIdentities.add(userIdentity);
            identityActivities.add(activity);
        }

        SageApiActivityUtils.debug('users to create: '+JSON.serialize(users));
        SageApiAddCommUserActivityUtils.saveCommunityUsers(step, candidateActivities, members, memberActivities, users, userActivities, userIdentities, identityActivities, contactToAccountMap);
    }
/*
    public static void createUser(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        SageApiActivityUtils.debug('SageApiTryNowActivityUtils.createUser starts: '+JSON.serialize(activities));

        if (activities == null || activities.size() == 0) return;
        List<SageApiActivity__c> candidateActivities = null;
        List<Contact> candidateContacts = null;

        Set<ID> contactIds = new Set<ID>();
        if (candidateActivities == null) candidateActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.Contact__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'CreateUser', 'A contact is required to create a user');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.IsNotBlank(activity.User__c) && String.isNotBlank(activity.CommunityMembership__c) && String.isNotBlank(activity.SageUserIdentityProvider__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            contactIds.add(activity.Contact__c);
            candidateActivities.add(activity);
        }

        SageApiActivityUtils.debug('contactIds: ' + contactIds);
        candidateContacts = [SELECT ID,Account.Id,Account.name,Account.BillingCountryCode,Email,FirstName,LastName,MailingCity,MailingCountry,MailingCountryCode,MailingPostalCode,MailingState,MailingStreet,Phone FROM Contact WHERE ID in: contactIds];
        SageApiActivityUtils.debug('contacts to be processed: ' + candidateContacts);

        if (candidateContacts == null || candidateContacts.size() == 0)
            return;

        // Shekhar : Added to associate contacts with community membership
        List<CommunityX__c> communities = [SELECT Id, Default_User_Profile__c FROM CommunityX__c WHERE Name = :SageApiActivityUtils.setting_CustomerCommunityName];
        List<Community_Membership__c> members = null;
        Community_Role__c role = null;
        CommunityX__c community = null;
        Profile profile = null;

        if (communities.size() > 0) {
            community = communities[0];

            List<Community_Role__c> roles = [SELECT Id FROM Community_Role__c WHERE Community__c = :community.Id AND Name = :SageApiActivityUtils.setting_CustomerCommunityAdminRoleName];

            if (roles.size() > 0) {
                role = roles[0];

                members = [SELECT Id, Community_Role__c, Contact__c, Community__c FROM Community_Membership__c WHERE Community__c =: community.Id AND Community_Role__c =: role.Id AND Contact__c IN: candidateContacts ];
                if (members == null) members = new List<Community_Membership__c>();
                for (Contact c : candidateContacts) {
                    Boolean hasMember = false;
                    for (Community_Membership__c cm : members) {
                        if (cm.Community__c == community.Id && cm.Community_Role__c == role.Id && cm.Contact__c == c.Id) {
                            hasMember = true;
                            break;
                        }
                    }
                    if (hasMember) continue;

                    Community_Membership__c member = new Community_Membership__c(Community_Role__c = role.Id, Contact__c = c.Id, Community__c = community.Id);
                    members.add(member);
                }
            }

            List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = :community.Default_User_Profile__c];

            if (profiles.size() > 0)
                profile = profiles[0];
        }

        //Required fields: LastName, Email, Alias, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey
        List<User> users = [SELECT ContactId,Id FROM User WHERE ContactId IN: candidateContacts];
        if (users == null) users = new List<User>();
        List<SageUserIdentityProvider__c> userIdentities = new List<SageUserIdentityProvider__c>();
        Map<ID, ID> contactToAccountMap = new Map<ID, ID>();
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, LanguageLocaleKey__c FROM Locale__c WHERE IsDeleted = false];
        Integer index = -1;
        for (Contact contact : candidateContacts) {
            index++;
            Boolean hasUser = false;
            for (User u : users) {
                if (u.ContactId == contact.Id) {
                    hasUser = true;
                    break;
                }
            }
            if (hasUser) continue;

            Locale__c locale = null;
            Locale__c firstLocale = null;
            Integer localeIndex = -1;
            for (Locale__c l : locales) {
                localeIndex++;
                if (l.Country_Code__c != contact.Account.BillingCountryCode) continue;
                firstLocale = l;
                if (l.Default_Locale__c != 'Yes') continue;
                locale = l;
            }
            if (locale == null) locale = firstLocale;

            User user = SageApiAddCommUserActivityUtils.setUpUserRecord(contact, profile, locale);
            SageApiActivityUtils.debug('user: ' + user);
            users.add(user);

            SageApiTryNowActivityRequest req = null;
            SageUserIdentityProvider__c userIdentity = new SageUserIdentityProvider__c();
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(candidateActivities[index].payload__c, SageApiTryNowActivityRequest.class);
                if (string.isBlank(req.contact.identityType) || string.isBlank(req.contact.identityId)) {
                    userIdentities.add(userIdentity);
                    continue;
                }

                SageApiBuyNowActivityResponse response = (SageApiBuyNowActivityResponse)JSON.deserialize(candidateActivities[index].Artifacts__c, SageApiBuyNowActivityResponse.class);
                SageApiBuyNowActivityResponse.ResponseData data = response.data;
                if (String.isNotBlank(data.bridgeServiceId)) userIdentity.Id = data.bridgeServiceId;
                userIdentity.Account__c = contact.AccountId;
                userIdentity.IdentityID__c = req.contact.identityId;
                userIdentity.IdentityProvider__c = req.contact.identityType;
                userIdentity.SFBridgeID__c = contact.AccountId + ':' + req.contact.identityType + ':' + req.contact.identityId;
                userIdentity.Name = userIdentity.SFBridgeID__c;
                if (locale != null && string.isNotBlank(locale.currencyIsoCode))
                    userIdentity.CurrencyIsoCode = locale.currencyIsoCode;

                userIdentities.add(userIdentity);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'provisionUsers', ex);
            }

            contactToAccountMap.put(contact.ID, contact.AccountId);
        }

        SageApiActivityUtils.debug('users to create: '+JSON.serialize(users));
        saveCommunityUsers(step, candidateActivities, users, userIdentities, contactToAccountMap, members);

        SageApiActivityUtils.updateActivities(activities);
        SageApiActivityUtils.debug('SageApiTryNowActivityUtils.createUser ends: '+JSON.serialize(activities));
    }
*/
    public static void createQuote(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        SageApiActivityUtils.debug('SageApiTryNowActivityUtils.createQuote starts: '+JSON.serialize(activities));

        if (activities == null || activities.size() == 0) return;
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        List<zqu__Quote__c> quotesToDelete = new List<zqu__Quote__c>();
        List<zqu__QuoteRatePlanCharge__c> QuoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c>();
        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
        Map<ID, Account> accountMap = new Map<ID, Account>();
        Map<ID, SageApiTryNowActivityRequest> activityPayloadMap = new Map<ID, SageApiTryNowActivityRequest>();
        Map<Id, String> activityOppNameMap = getOpportunityNames(activities);

        //(Product_Tier__r.Product_Tier_Code__c ='SageOne-Start-US' and Product_Tier_Rate_Plan__c.name = 'Monthly')
        for (SageApiActivity__c activity : activities) {
            if (String.IsNotBlank(activity.ZuoraSubscriptionId__c) || String.IsNotBlank(activity.Quote__c) && activity.QuoteMetricsCalculated__c) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            try {
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                if (req == null) continue;

                if (String.isBlank(activity.Contact__c) || String.isBlank(activity.Account__c)) continue;

                SageApiActivityRequestObjects.Product product = req.products[0];
                if (product == null) continue;

                if (String.isBlank(product.pricingCode))
                    product.pricingCode = '_LIST';
                products.add(product);
                if (String.isNotBlank(activity.Quote__c)) quotesToDelete.add(new zqu__Quote__c(ID=activity.Quote__c)); //quote.ID = activity.Quote__c;

                zqu__Quote__c quote = new zqu__Quote__c();
                quote.Name = activityOppNameMap.get(activity.Id);
                quote.zqu__Opportunity__c = activity.Opportunity__c;
                quote.zqu__Account__c = activity.Account__c;
                quote.zqu__BillToContact__c = activity.Contact__c;
                quote.zqu__SoldToContact__c = activity.Contact__c;
                quote.zqu__Is_Charge_Expired__c = false;
                quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
                //quote.zqu__BillingBatch__c = 'Batch1';

                // more logic moved down
                quote.zqu__StartDate__c = String.IsBlank(req.startDate) ? Date.valueOf(Date.today()) : Date.valueOf(req.startDate);
                quote.zqu__ValidUntil__c = quote.zqu__StartDate__c;

                //TODO: since we don't know what payment method user will be opt to, probably create one for CC and one for DD???
                quote.zqu__PaymentMethod__c = String.isBlank(req.account.paymentMethodType) ? 'Credit Card' : req.account.paymentMethodType; //'ACH', 'Bank Transfer'
                if (String.isNotBlank(req.account.paymentMethodId))
                    quote.zqu__ElectronicPaymentMethodId__c = req.account.paymentMethodId;

                SageApiActivityUtils.ensureRecordOwner(quote);
                quotes.add(quote);
                accountMap.put(activity.Account__c, null);
                activityPayloadMap.put(activity.ID, req);
                candidateActivities.add(activity);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createQuotes', ex);
                continue;
            }
        }

        SageApiActivityUtils.debug('quotes to be processed: ' + quotes);

        if (quotes == null || quotes.size() == 0) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createQuotes', new CustomException('no quotes to create'));
            return;
        }

        if (quotesToDelete.size() > 0) {
            delete quotesToDelete;
            SageApiActivityUtils.debug('quotesToDelete: '+quotesToDelete);
        }

        // get associated quote templates, locales
        accountMap.putAll([SELECT ID, BillingCountryCode, Locale__r.Language__c FROM Account WHERE ID IN: accountMap.keyset()]);
        List<zqu__Quote_Template__c> quoteTemplateSettings = getQuoteTemplateSettings('New Subscription', accountMap);
        List<Locale__c> locales = [SELECT id, Name, Country_Code__c, CurrencyIsoCode, Default_Locale__c, Language__c, TimeZone__c, BillingBatch__c FROM Locale__c WHERE IsDeleted = false];
        Map<ID, Locale__c> accountLocaleMap = new Map<ID, Locale__c>();
        for (Account account : accountMap.values()) {
            Locale__c locale = null;
            Locale__c firstLocale = null;
            Integer localeIndex = -1;
            for (Locale__c l : locales) {
                if (l.Country_Code__c != account.BillingCountryCode) continue;
                firstLocale = l;
                if (l.Default_Locale__c != 'Yes') continue;
                locale = l;
            }
            if (locale == null) locale = firstLocale;
            accountLocaleMap.put(account.ID, locale);
        }

        Integer index = 0;
        if (quoteTemplateSettings != null) {
            for (zqu__Quote_Template__c setting : quoteTemplateSettings) {
                zqu__Quote__c quote = quotes[index];

                if (setting == null) {
                    SageApiActivityUtils.updateActivityWithException(candidateActivities[index], step, false, 'zqu__QuoteTemplate__c', 'No valid setting found for account: ' + quote.zqu__Account__c + ' (based on billingCountryCode and language)');
                    candidateActivities.remove(index);
                    quotes.remove(index);
                    products.remove(index);
                    continue;
                }

                Locale__c locale = accountLocaleMap.get(quote.zqu__Account__c);
                if (locale == null) {
                    SageApiActivityUtils.updateActivityWithException(candidateActivities[index], step, false, 'locale__c', 'No valid locale found for account: ' + quote.zqu__Account__c);
                    candidateActivities.remove(index);
                    quotes.remove(index);
                    products.remove(index);
                    continue;
                }
                quote.zqu__QuoteTemplate__c = setting.ID;
                quote.zqu__BillingBatch__c = locale.BillingBatch__c;
                index++;
            }
        }

        Map<string, Product_Tier_Rate_Plan__c> listTierMap = SageApiActivityUtils.getProductTierRatePlans(products);
        index = 0;
        for (SageApiActivity__c a : candidateActivities) {
            SageApiActivityRequestObjects.Product product = products[index];

            Product_Tier_Rate_Plan__c tierData = listTierMap.get(product.tierCode+':'+product.tierRatePlanCode);
            zqu__Quote__c quote = quotes[index];
            quote.zqu__Currency__c = tierData.CurrencyIsoCode;
            Date startDate = quote.zqu__StartDate__c;
            Date validUntilDate = startDate;
            Date quoteStartDate = startDate;
            if (candidateActivities[index].ActivityType__c == SageApiActivityTriggerHandler.TryNowActivityType) {
                Decimal trialDays = tierData.Trial_Period__c;
                Decimal trialPlusGraceDays = trialDays + tierData.Payment_Grace_Period__c;
                Integer validDays = trialDays.intValue() + 180;
                //validUntilDate = startDate.addDays(trialPlusGraceDays.intValue());
                validUntilDate = startDate.addDays(validDays);
                quoteStartDate = startDate.addDays(trialDays.intValue());
                quote.zqu__ValidUntil__c = validUntilDate;
                quote.zqu__StartDate__c = quoteStartDate;
            }
            quote.zqu__SubscriptionType__c = 'New Subscription';
            quote.zqu__Subscription_Term_Type__c = tierData.Term_Type__c;
            if (tierData.Term_Type__c == 'Termed') {
                quote.zqu__InitialTerm__c = tierData.InitialTerm__c;
                quote.zqu__RenewalTerm__c = tierData.RenewalTerm__c;
                quote.zqu__TermStartDate__c = quoteStartDate;
            }
            /*
            zqu__QuoteRatePlanCharge__c QuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
            QuoteRatePlanCharge.CurrencyIsoCode = quote.CurrencyIsoCode;
            QuoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__Quote__c = quote.Id;
            QuoteRatePlanCharge.zqu__Quantity__c = 1;
            QuoteRatePlanCharge.zqu__ProductRatePlanCharge__c = tierData.Product_Rate_Plan__c;
            QuoteRatePlanCharges.add(QuoteRatePlanCharge);
            */
            index++;
        }

        SageApiActivityUtils.debug('quotes to create: ' + JSON.serialize(quotes));
        SageApiActivityUtils.debug('QuoteRatePlanCharges to create: ' + JSON.serialize(QuoteRatePlanCharges));

        //process batch save results
        Database.UpsertResult [] quoteResults = Database.upsert(quotes, false);
        SageApiActivityUtils.debug('quotes created: '+quotes);
        List<SageApiActivity__c> QuoteRatePlanChargeActivities = new List<SageApiActivity__c>();
        List<ID> priceableQuoteIds = new List<ID>();
        List<zqu__Quote__c> priceableQuotes = new List<zqu__Quote__c>();
        List<SageApiActivity__c> priceableActivities = new List<SageApiActivity__c>();
        Map<string, List<PricingCodeCharge__c>> pricingChargeMap = SageApiActivityUtils.getPricingCodeCharges(products);
        SageApiActivityUtils.debug('pricingChargeMap: '+pricingChargeMap);
        index = 0;
        for(Database.UpsertResult result : quoteResults){
            SageApiActivity__c activity = candidateActivities[index];
            //zqu__QuoteRatePlanCharge__c QuoteRatePlanCharge = QuoteRatePlanCharges[index];
            SageApiActivityRequestObjects.Product product = products[index];
            //zqu__Quote__c createdQuote = quotes[index];
            index++;

            if (result.isSuccess()) {
                ID quoteId = result.getId();
                activity.Quote__c = quoteId;
                SageApiActivityUtils.debug('quote created: '+quoteId);
                //QuoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__Quote__c = quoteId;

                //may need to handle more complex scenario in the future when quote is updated
                if (activity.QuoteMetricsCalculated__c) continue;

                //this should be done on seprate unit to be idemopotent
                zqu.zChargeGroup chargeGroup = null;
                try {
                    Product_Tier_Rate_Plan__c tierData = listTierMap.get(product.tierCode+':'+product.tierRatePlanCode);

                    SageApiActivityUtils.debug( 'tierData.Product_Rate_Plan__c:'+ tierData.Product_Rate_Plan__c);

                    chargeGroup = zqu.zQuoteUtil.getChargeGroup(quoteId, tierData.Product_Rate_Plan__c);
                    List<PricingCodeCharge__c> pricingCharges = pricingChargeMap.get(product.tierCode+':'+product.tierRatePlanCode+':'+product.pricingCode);
                    if (pricingCharges != null && pricingCharges.size()>0) {
                        Boolean hasEffectivePriceChange = false;
                        //Boolean hasDiscountChange = false;
                        for (zqu.zCharge charge : chargeGroup.zCharges) {
                            SageApiActivityUtils.debug( 'charge before:'+ charge);
                            if (charge.CHARGE_TYPE != 'Recurring')
                                continue;
                            SageApiActivityUtils.debug( 'charge.MODEL:'+ charge.MODEL);

                            for (PricingCodeCharge__c pricingCharge : pricingCharges) {
                                SageApiActivityUtils.debug( 'charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID:'+ charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                                if (charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID != pricingCharge.Product_Rate_Plan_Charge__c)
                                    continue;
                                SageApiActivityUtils.debug( 'charge.EFFECTIVE_PRICE:'+ charge.EFFECTIVE_PRICE);
                                SageApiActivityUtils.debug( 'pricingCharge.PublishedDiscountPrice__c:'+ pricingCharge.PublishedDiscountPrice__c);
                                SageApiActivityUtils.debug( 'charge.discount:'+ charge.discount);
                                SageApiActivityUtils.debug( 'pricingCharge.PublishedDiscountPercent__c:'+ pricingCharge.PublishedDiscountPercent__c);
                                SageApiActivityUtils.debug( 'pricingCharge.PublishedNumberOfPeriods__c:'+ pricingCharge.PublishedNumberOfPeriods__c);

                                if (charge.isUpToPeriodsEditable) {
                                    SageApiActivityUtils.debug( 'charge.isUpToPeriodsEditable:'+ charge.isUpToPeriodsEditable);
                                    SageApiActivityUtils.debug( 'charge.isEndDateConditionEditable:'+ charge.isEndDateConditionEditable);
                                    SageApiActivityUtils.debug( 'charge.isUpToPeriodsTypeEditable:'+ charge.isUpToPeriodsTypeEditable);

                                    if (pricingCharge.PublishedNumberOfPeriods__c > 0) {
                                        if (charge.isEndDateConditionEditable)
                                            charge.END_DATE_CONDITION = 'Fixed Period';
                                        if (charge.isUpToPeriodsTypeEditable)
                                            charge.UPTO_PERIODS_TYPE = 'Billing Periods';
                                        if (charge.isUpToPeriodsEditable)
                                            charge.UPTO_PERIODS = String.valueOf(pricingCharge.PublishedNumberOfPeriods__c);
                                    } else if (charge.isEndDateConditionEditable){
                                        charge.END_DATE_CONDITION = 'Subscription End Date';
                                    }
                                }
                                SageApiActivityUtils.debug( 'charge after UpToPeriodsEditable:'+ charge);

                                if (charge.MODEL == 'Discount-Fixed Amount' || charge.MODEL == 'Flat Fee Pricing') {
                                    if (pricingCharge.PublishedDiscountPrice__c == null) {
                                        SageApiActivityUtils.debug( charge.MODEL + ': published discount price does not need to be updated');
                                        continue;
                                    }
                                    charge.EFFECTIVE_PRICE = String.valueOf(pricingCharge.PublishedDiscountPrice__c);
                                    hasEffectivePriceChange = true;
                                    if (charge.isListPriceEditable())
                                        charge.overrideListPrice(pricingCharge.PublishedDiscountPrice__c);
                                } else if (charge.MODEL == 'Discount-Percentage') {
                                    if (pricingCharge.PublishedDiscountPercent__c == null) {
                                        SageApiActivityUtils.debug( charge.MODEL + ': published discount price does not need to be updated');
                                        continue;
                                    }
                                    charge.EFFECTIVE_PRICE = String.valueOf(pricingCharge.PublishedDiscountPercent__c);
                                    hasEffectivePriceChange = true;
                                }
                                SageApiActivityUtils.debug( 'charge after EffectiveDateUpdate:'+ charge);
                            }
                        }
                        SageApiActivityUtils.debug( 'hasEffectivePriceChange:'+ hasEffectivePriceChange);
                        //SageApiActivityUtils.debug( 'hasDiscountChange:'+ hasDiscountChange);

                        if (hasEffectivePriceChange)
                            zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);
                        //if (hasDiscountChange)
                        //    zqu.zQuoteUtil.calculateChargesOnDiscountChange(chargeGroup.zCharges);
                    }
                } catch(Exception ex) {
                    SageApiActivityUtils.debug('Error when getChargeGroup: '+ex);
                    ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createQuotes', ex);
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createQuotes', 'Quote getChargeGroup failed. More detail: ' + ex);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    continue;
                }

                try {
                    chargeGroup = zqu.ZQuoteUtil.addChargeGroup(chargeGroup);

                    if (String.isBlank(product.pricingCode)) {
                        priceableQuoteIds.add(quoteId);
                        zqu__Quote__c quote = new zqu__Quote__c();
                        quote.id = quoteId;
                        priceableQuotes.add(quote);
                        priceableActivities.add(activity);
                    } else {
                        activity.QuoteMetricsCalculated__c = true;
                        SageApiActivityUtils.setSuccess(activity, step);
                    }

                    SageApiActivityUtils.debug('chargeGroup after zqu.zQuoteUtil.addChargeGroup: ' + chargeGroup);
                } catch(Exception ex) {
                    SageApiActivityUtils.debug('Error when addChargeGroup: '+ex);
                    ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createQuotes', ex);
                    activity.QuoteMetricsCalculated__c = false;
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createQuotes', 'Quote addChargeGroup failed. More detail: ' + ex);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                }

                SageApiActivityUtils.debug('SageApiTryNowActivityUtils.createQuotes: pricing preview preparation completed');
                continue;
            }
            //if (!result.isSuccess() && errStr.contains('The Quote metrics value is the latest'))
            //    continue;
            Boolean retryable = true;
            String detailMsg = '';
            for (Database.Error err : result.getErrors()) {
                SageApiActivityUtils.debug('err: ' + err);
                if (err.getStatusCode() != StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY)
                    continue;
                detailMsg = 'Please verify Zuora Quote Template ID (Salesforce ID) is correct for this org.';
                retryable = false;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createQuotes', 'Quote creation failed. ' + detailMsg + ' More detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }

        SageApiActivityUtils.updateActivities(activities);

        if (priceableActivities.size() > 0) {
            string quoteListStr = JSON.serialize(priceableQuotes);
            string quoteIdListStr = JSON.serialize(priceableQuoteIds);
            string stepStr = JSON.serialize(step);
            string activitiesStr = JSON.serialize(priceableActivities);
            getPricing(stepStr, activitiesStr, quoteListStr, quoteIdListStr);
        }
        SageApiActivityUtils.debug('SageApiTryNowActivityUtils.createQuote: '+JSON.serialize(activities));
    }

    public static void getPaymentUrl(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        SageApiActivityUtils.debug('enter getPaymentUrl');
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> processedActivities = new List<SageApiActivity__c>();

        for (SageApiActivity__c activity : activities) {
            // started already
            if (activity.LockedForProcess__c == SageApiProcessLocks.PayNow)
                continue;

            if (String.isNotBlank(activity.PayNowToken__r.PayNowRedirectUrl__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                processedActivities.add(activity);
                continue;
            }

            // set being processed for idempotency check
            activity.LockedForProcess__c = SageApiProcessLocks.PayNow;
            candidateActivities.add(activity);
        }

        SageApiActivityUtils.debug(JSON.serialize(activities));

        SageApiActivityUtils.updateActivities(activities);

        if (candidateActivities.size()==0) {
            SageApiActivityUtils.debug('SageApiTryNowActivityUtils.getPaymentUrl: nothing to process');
            return;
        }

        List<SageApiActivity__c> paynowActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> paymentActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : candidateActivities)
            if (activity.ActivityType__c == SageApiActivityTriggerHandler.TryNowActivityType)
                paynowActivities.add(activity);
            else
                    paymentActivities.add(activity);

        if (paynowActivities.size() > 0)
            getPayNowToken(JSON.serialize(step), JSON.serialize(paynowActivities), sessionId);

        if (paymentActivities.size() > 0)
            getPaymentUrl(JSON.serialize(step), JSON.serialize(paymentActivities), sessionId);

        SageApiActivityUtils.debug('SageApiTryNowActivityUtils.getPaymentUrl ends');
    }

    @future(callout=true)
    public static void getPayNowToken(string stepStr, string activitiesStr, string sessionId) {
        SageApiActivityStep step = (SageApiActivityStep)JSON.deserialize(stepStr, SageApiActivityStep.class);
        List<SageApiActivity__c> originalActivities = (List<SageApiActivity__c>)JSON.deserialize(activitiesStr, List<SageApiActivity__c>.class);

        SageApiActivityUtils.debug('getPayNowToken: '+JSON.serialize(originalActivities));
        if (originalActivities == null || originalActivities.size() == 0) return;
        Map<String, SageApiActivity__c> quoteActivityMap = new Map<String, SageApiActivity__c>();
        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);

        //get activities not processed before
        for (SageApiActivity__c activity : originalActivities) {
            // processed successfully before
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID) || String.isNotBlank(activity.PayNowToken__r.PayNowRedirectUrl__c)) {
                activity.PaymentUrl__c = activity.PayNowToken__r.PayNowRedirectUrl__c;
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            if (SageApiActivityUtils.activityTerminated(activity)) {
                //List<SageApiActivityError> errors = new List<SageApiActivityError>();
                //SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'getPayNowToken', 'Two possible reasons: activity has been completed or no quote to get token for');
                //SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            if (String.isBlank(activity.Quote__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'getPayNowToken', 'Activity has no quote to get token for');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            String quoteId = activity.Quote__c;
            if (quoteActivityMap.containsKey(quoteId)) continue;
            quoteActivityMap.put(quoteId, activity);
        }

        // nothing to process
        if (quoteActivityMap.size()==0) {
            for (SageApiActivity__c activity : originalActivities) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'getPayNowToken', 'No quote to get token for');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }
        SageApiActivityUtils.debug('quoteActivityMap: '+JSON.serialize(quoteActivityMap.keySet()));

        try {
            //only handle ones with payment method ids and without subscription id
            List<PayNowToken__c> createdTokens = [SELECT ID, Name, Quote__c, PayNowRedirectUrl__c FROM PayNowToken__c WHERE Quote__c in: quoteActivityMap.keySet()];
            if (createdTokens != null) {
                for (PayNowToken__c t : createdTokens) {
                    SageApiActivity__c activity = quoteActivityMap.get(t.Quote__c);
                    if (activity != null) {
                        activity.PaymentUrl__c = t.PayNowRedirectUrl__c;
                        activity.PayNowToken__c = t.ID;
                        SageApiActivityUtils.setSuccess(activity, step);
                        quoteActivityMap.remove(t.Quote__c);
                    }
                }
            }
        } catch (Exception ex){
            SageApiActivityUtils.debug('Error retrieving tokens with SOQL: '+ex);
            ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'getPayNowToken', ex);
        }

        if (quoteActivityMap.size() == 0) return;

        List<zqu__Quote__c> quotes = [SELECT ID, zqu__QuoteTemplate__r.zqu__Template_Id__c FROM zqu__Quote__c WHERE ID IN: quoteActivityMap.keySet()];
        Map<ID, string> quoteRequestMap = new Map<ID, string>();

        for (zqu__Quote__c quote : quotes) {
            SageApiActivity__c activity = quoteActivityMap.get(quote.Id);
            if (activity == null) continue;

            try {
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                Map<string, string> params = new Map<string, string>();
                params.put('paymentCompleteNotificationUrl', req.payNowCompletionNotifyUrl);
                params.put('paymentCompleteRedirectUrl', req.payNowSuccessRedirectUrl);
                params.put('paymentCompleteCancelUrl', req.payNowErrorRedirectUrl);
                params.put('showCcPayment', 'true');
                params.put('showDdPayment', 'true');
                quoteRequestMap.put(quote.ID, PayNowTokenRetriever.getPayNowPurchaseRequest(quote.Id, null, params));
            } catch (Exception ex) {
                SageApiActivityUtils.debug('create getPayNowPurchaseRequest failed: '+ex);
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'create getPayNowPurchaseRequest', 'create getPayNowPurchaseRequest failed. Detail: ' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'create getPayNowPurchaseRequest', ex);
                continue;
            }
        }

        if (quoteRequestMap.size() == 0) return;

        try {
            SageApiActivityUtils.debug('quoteRequestMap: ' + JSON.serialize(quoteRequestMap));
            Map<ID, PayNowToken__c> quoteTokenMap = PayNowTokenRetriever.createPayNowPurchaseToken(quoteRequestMap);
            SageApiActivityUtils.debug('quoteTokenMap created: ' + JSON.serialize(quoteTokenMap));
            List<SageApiActivity__c> processedActivities = new List<SageApiActivity__c>();
            for (ID quoteId : quoteTokenMap.keySet()) {
                SageApiActivity__c activity = quoteActivityMap.get(quoteId);
                if (activity == null) continue;
                processedActivities.add(activity);
                PayNowToken__c token = quoteTokenMap.get(quoteId);

                if (token != null && token.Name != 'null' && string.isNotBlank(token.ID) && string.isNotBlank(token.PayNowRedirectUrl__c)) {
                    activity.PayNowToken__c = token.ID;
                    activity.PaymentUrl__c = token.PayNowRedirectUrl__c;
                    SageApiActivityUtils.setSuccess(activity, step);
                } else {
                    List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createPayNowToken', 'No token created, check PayNow Purchase Request API. ' + token.ErrorMessage__c);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createPayNowToken', new CustomException('No token created, check PayNow Purchase Request API'));
                }
                SageApiActivityUtils.debug('SageApiTryNowActivityUtils.getPayNowToken: '+JSON.serialize(activity));
            }

            for (SageApiActivity__c activity : quoteActivityMap.values()) {
                Boolean isProcssed = false;
                for (SageApiActivity__c processed : processedActivities)
                    if (processed.Id == activity.Id) {
                        isProcssed = true;
                        break;
                    }

                if (isProcssed) continue;
                if (String.isNotBlank(activity.PaymentUrl__c) && String.isNotBlank(activity.PayNowToken__c)) {
                    SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'createPayNowToken', 'No token created, please check PayNow Purchase Request API for non-timeout issue');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createPayNowToken', new CustomException('No token created, please check PayNow Purchase Request API for non-timeout issue'));
            }
        } catch (Exception e) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createPayNowToken', e);
        }

        SageApiActivityUtils.updateActivities(originalActivities);
    }

    @Future(callout=true)
    public static void getPaymentUrl(string strStep, string strActivities, string sessionId) {
        SageApiActivityUtils.debug('strStep: '+ strStep);
        SageApiActivityUtils.debug('strActivities: '+strActivities);
        SageApiActivityStep step = null;
        List<SageApiActivity__c> originalActivities = null;
        try {
            step = (SageApiActivityStep)JSON.deserialize(strStep, SageApiActivityStep.class);
            originalActivities = (List<SageApiActivity__c>)JSON.deserialize(strActivities, List<SageApiActivity__c>.class);
        } catch (Exception ex) {
            SageApiActivityUtils.debug('Deserialziation failed: '+ex);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getPaymentUrl', ex);
            return;
        }

        if (originalActivities == null || originalActivities.size() == 0) return;
        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);

        List<SageApiActivity__c> candidateActivities = null;
        Boolean activityUpdated = false;
        Set<ID> quoteIds = new Set<ID>();
        if (candidateActivities == null) candidateActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> processedActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : originalActivities) {
            if (String.isNotBlank(activity.PaymentUrl__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                processedActivities.add(activity);
                continue;
            }
            candidateActivities.add(activity);
        }
        if (processedActivities.size() > 0) SageApiActivityUtils.updateActivities(processedActivities);
        if (candidateActivities.size()==0) return;

        for (SageApiActivity__c activity : candidateActivities) {
            try {
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                SageApiActivityRequestObjects.PaymentRequest paymentRequest = new SageApiActivityRequestObjects.PaymentRequest();
                paymentRequest.completionNotifyUrl = req.payNowCompletionNotifyUrl;
                paymentRequest.successRedirectUrl = req.payNowSuccessRedirectUrl;
                paymentRequest.errorRedirectUrl = req.payNowErrorRedirectUrl;
                paymentRequest.products = new List<SageApiActivityRequestObjects.Product>();
                for (SageApiActivityRequestObjects.Product p : req.products)
                    paymentRequest.products.add(p);

                SageApiActivityRequestObjects.PaymentResponse paymentResponse = createPaymentUrl(paymentRequest);

                SageApiActivityUtils.debug('paymentResponse: ' + paymentResponse);

                if (paymentResponse != null && paymentResponse.success) {
                    activity.PaymentUrl__c = paymentResponse.paymentUrl;
                    SageApiActivityUtils.setSuccess(activity, step);
                } else {
                    List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'getPaymentUrl', paymentResponse == null ? 'Failed without detail' : 'Failed: '+paymentResponse.error);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getPaymentUrl', new CustomException(paymentResponse == null ? 'Failed without detail' : 'Failed: '+paymentResponse.error));
                }
            } catch (Exception ex) {
                SageApiActivityUtils.debug('getPaymentUrl failed: '+ex);

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'getPaymentUrl', 'getPaymentUrl failed. Detail: ' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);

                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getPaymentUrl', ex);
            }
        }

        SageApiActivityUtils.updateActivities(candidateActivities);
    }

    /**
     * Upserts the Subscription Master records and assets (in the future) based on Account and Product details provided.
     * @param step details
     * @param originalActivities set to update
     **/
    public static void createOrUpdateSubscriptionMaster(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {

        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);

        // List of Subscription Master Records to Upsert
        List<Subscription_Master__c> subscriptionMasters = new List<Subscription_Master__c>();

        // List of product tier rate plan filters to retrieve
        List<SageApiActivityUtils.ProductTierSearchFilter> filters = new List<SageApiActivityUtils.ProductTierSearchFilter>();

        // Map of Product Tier Filter to Assets
        Map<String, List<Subscription_Master__c>> mapOfProductTierFiltersToSM = new Map<String, List<Subscription_Master__c>>();

        // Map of Assets External Id to Activites
        Map<String, SageApiActivity__c> mapOfAssetExternalIdToActivities = new Map<String, SageApiActivity__c>();

        List<SageApiActivityRequestObjects.Product> products = new List<SageApiActivityRequestObjects.Product>();
        List<Id> listOfEMAlreadyCreated = new List<Id>();

        // If no activities are passed then return
        if (originalActivities == null || originalActivities.size() == 0) return;

        // Map of Zuora Subscription Id to Asset
        Map<String, Subscription_Master__c> mapOfZuoraSubscriptionIdToAsset = new Map<String, Subscription_Master__c>();

        SageApiActivityUtils.debug('********originalActivities' + originalActivities);

        // Iterate through the list of activities
        List<SageApiActivity__c> failedActivities = new List<SageApiActivity__c>();
        for (SageApiActivity__c activity : originalActivities) {

            SageApiActivityUtils.debug('********In Loop' + originalActivities);

            if (String.IsNotBlank(activity.SubscriptionMaster__c)) {
                if (String.IsNotBlank(activity.Entitlement_Message__c)) {
                    listOfEMAlreadyCreated.add(activity.Entitlement_Message__c);
                }

                //SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }

            // De-serialize request
            SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
            SageApiActivityUtils.debug('req: ' + req);
            if (req == null || req.products == null || req.products[0] == null) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'createOrUpdateSubscriptionMaster', 'Invalid payload data');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                failedActivities.add(activity);
                continue;
            }

            if (String.isBlank(activity.Account__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'createOrUpdateSubscriptionMaster', 'An account is required to create entitlements');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                failedActivities.add(activity);
                continue;
            }

            SageApiActivityRequestObjects.Product product = req.products[0];
            SageApiActivityUtils.debug('******* Product is ' + product + ' the payload is ' + activity.Payload__c);
            products.add(product);

            // Create a new asset record and vary the status depending on whether this is TryNow or BuyNow
            Subscription_Master__c newSM = new Subscription_Master__c();
            newSM.Account__c = activity.Account__c;
            // Shekhar: Added for TryNow/BuyNow replay
            newSM.Sage_API_Activity__c = activity.Id;
            newSM.ChannelPartner__c = activity.ChannelPartner__c;
            newSM.CbcSubscriptionId__c = GenericUtilities.getRandomUUIDv4();
            newSM.LegacyUpgradeFrom__c = req.legacyUpgradeFrom;
            if (String.isNotBlank(activity.ReferrerPromotion__c))
                newSM.ReferrerPromotion__c = activity.ReferrerPromotion__c;

            if (activity.ActivityType__c == SageApiActivityTriggerHandler.BuyNowActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.BuyNow2ActivityType) {
                newSM.Status__c = Constants.ASSET_STATUS_ACTIVE;
            } else {
                newSM.Status__c = Constants.ASSET_STATUS_TRIAL;
                newSM.Quote__c = activity.Quote__c;
            }

            // Add the external Id to the asset for upserting
            newSM.External_Id__c = activity.Account__c + '-' + product.tierCode + (String.isBlank(product.tierRatePlanCode) ? '' : '-' + product.tierRatePlanCode);
            SageApiActivityUtils.ensureRecordOwner(newSM);

            // If the activity is not Try Now and Subscription Id is present then add to map
            if (String.isNotBlank(activity.ZuoraSubscriptionId__c) && (activity.ActivityType__c == SageApiActivityTriggerHandler.BuyNowActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType || activity.ActivityType__c == SageApiActivityTriggerHandler.BuyNow2ActivityType))
                mapOfZuoraSubscriptionIdToAsset.put(activity.ZuoraSubscriptionId__c, newSM);

            // Add activity to map for easy lookup for later step in order to mark the activity as successfull or failed
            mapOfAssetExternalIdToActivities.put(newSM.External_Id__c, activity);

            // Store Product filters in a map in order to be able to retrieve asset
            String productFiltersMapKey = product.tierCode + '$' + (String.isBlank(product.tierRatePlanCode) ? '' : product.tierRatePlanCode);
            if (mapOfProductTierFiltersToSM.containsKey(productFiltersMapKey))
                mapOfProductTierFiltersToSM.get(productFiltersMapKey).add(newSM);
            else
                    mapOfProductTierFiltersToSM.put(productFiltersMapKey, new List<Subscription_Master__c> { newSM });
        }

        if (failedActivities.size() > 0) SageApiActivityUtils.updateActivities(failedActivities);

        // Run a query on Product Tier Plan to get a list of Ids to populate on the asset.
        List<Product_Tier__c> listTier = SageApiActivityUtils.getProductTiers(products);

        if (listTier != null) {
            // Populate the prduct tier rate plan id on the asset
            for (Product_Tier__c tier : listTier) {
                String productFiltersMapKey = tier.Product_Tier_Code__c + '$';
                if (mapOfProductTierFiltersToSM.containsKey(productFiltersMapKey)) {
                    List<Subscription_Master__c> newSMs = mapOfProductTierFiltersToSM.get(productFiltersMapKey);
                    for (Subscription_Master__c s : newSMs) {
                        s.Product__c = tier.Product__c;
                        s.Product_Tier__c = tier.Id;
                        s.Start_Date__c = System.now();

                        if (s.Status__c == Constants.ASSET_STATUS_TRIAL) {
                            s.End_Date__c = System.now().addDays(Integer.valueOf(tier.Trial_Period__c));
                        } else {
                            s.End_Date__c = Date.newInstance(2099, 12, 31);
                        }

                        //a.Name = tierRatePlan.Product_Rate_Plan__r.zqu__ZProduct__r.Name;
                        subscriptionMasters.add(s);
                    }
                }
            }
        }

        // Overriding if any - Run a query on Product Tier Rate Plan to get a list of Ids to populate on the asset.
        Map<string, Product_Tier_Rate_Plan__c> listTierRatePlanMap = SageApiActivityUtils.getProductTierRatePlans(products);

        if (listTierRatePlanMap != null) {
            // Populate the prduct tier rate plan id on the asset
            for (Product_Tier_Rate_Plan__c tierRatePlan : listTierRatePlanMap.values()) {
                String productFiltersMapKey = tierRatePlan.Product_Tier__r.Product_Tier_Code__c + '$' + tierRatePlan.Name;
                if (mapOfProductTierFiltersToSM.containsKey(productFiltersMapKey)) {
                    List<Subscription_Master__c> newSMs = mapOfProductTierFiltersToSM.get(productFiltersMapKey);
                    for (Subscription_Master__c s : newSMs) {
                        s.Product__c = tierRatePlan.Product_Rate_Plan__r.zqu__Product__r.Id;
                        s.Product_Tier__c = tierRatePlan.Product_Tier__c;
                        s.Product_Tier_Rate_Plan__c = tierRatePlan.Id;
                        s.Start_Date__c = System.now();

                        if (s.Status__c == Constants.ASSET_STATUS_TRIAL) {
                            s.End_Date__c = System.now().addDays(Integer.valueOf(tierRatePlan.Trial_Period__c));
                        } else {
                            s.End_Date__c = Date.newInstance(2099, 12, 31);
                        }

                        //a.Name = tierRatePlan.Product_Rate_Plan__r.zqu__ZProduct__r.Name;
                        subscriptionMasters.add(s);
                    }
                }
            }
        }

        // Populate the zuora subscription Id for
        if (mapOfZuoraSubscriptionIdToAsset.size() > 0) {
            List<Zuora__Subscription__c> subscriptions = [SELECT Id, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :mapOfZuoraSubscriptionIdToAsset.keySet()];

            for (Zuora__Subscription__c subscription : subscriptions) {
                if (mapOfZuoraSubscriptionIdToAsset.containsKey(subscription.Zuora__Zuora_Id__c)) {
                    Subscription_Master__c sm = mapOfZuoraSubscriptionIdToAsset.get(subscription.Zuora__Zuora_Id__c);
                    sm.Subscription__c = subscription.Id;
                }

            }
        }

        SageApiActivityUtils.debug('******** listOfEMAlreadyCreated' + listOfEMAlreadyCreated);
        if (listOfEMAlreadyCreated.size() > 0) {
            List<SageApiActivity__c> activitiesToUpdate = new List<SageApiActivity__c>();
            List<Entitlement_Message__c> messagesToUpdate = new List<Entitlement_Message__c>();
            List<Entitlement_Message__c> messages = [SELECT Id, Status__c, Subscription_Master__c, Subscription_Master__r.Sage_Api_Activity__c From Entitlement_Message__c WHERE Id IN :listOfEMAlreadyCreated];
            for (Entitlement_Message__c message : messages) {
                if (message.Status__c == 'Error') {
                    message.Status__c  = 'New';
                    messagesToUpdate.add(message);
                } else {
                    activitiesToUpdate.add(new SageApiActivity__c(Id = message.Subscription_Master__r.Sage_Api_Activity__c));
                }
            }

            if (messagesToUpdate.size() > 0) update messagesToUpdate;

            SageApiActivityUtils.debug('********activitiesToUpdate =' + activitiesToUpdate);

            if (activitiesToUpdate.size() > 0) {
                activitiesToUpdate = SageApiActivityUtils.refreshActivities(activitiesToUpdate);
                for (SageApiActivity__c activity : activitiesToUpdate)
                    SageApiActivityUtils.setSuccess(activity, step);

                SageApiActivityUtils.updateActivities(activitiesToUpdate);
                SageApiActivityUtils.debug('********activitiesToUpdate updating =' + activitiesToUpdate);
            }
        }

        if (subscriptionMasters.size() > 0) {

            // Upsert the completed asset records and check results
            Integer index = 0;
            List<SageApiActivity__c> activitiesToUpdate = new List<SageApiActivity__c>();

            Database.UpsertResult [] upsertResults = Database.upsert(subscriptionMasters, Subscription_Master__c.Fields.External_Id__c, false);

            for(Database.UpsertResult result : upsertResults) {

                Subscription_Master__c currentSM = subscriptionMasters.get(index);
                SageApiActivity__c activity = mapOfAssetExternalIdToActivities.get(currentSM.External_Id__c);
                activity.SubscriptionMaster__c = currentSM.Id;
                activity.Subscription__c = currentSM.Subscription__c;
                // Shekhar: Added for TryNow/BuyNow replay
                activity.Step_Serialised__c = JSON.serialize(step);
                activitiesToUpdate.add(activity);

                index += 1;

                if (result.isSuccess()) continue;

                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'SageApiTryNowActivityStepUpsertSM', 'SM creation failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }

            if (activitiesToUpdate.size() > 0)
                SageApiActivityUtils.updateActivities(activitiesToUpdate);
        }
    }

    /**
     * Converts the Subscription Master record (in the future) based on Account and Product details provided.
     * @param step details
     * @param originalActivities set to update
     **/
    public static void convertSubscriptionMaster(SageApiActivityStep step, List<SageApiActivity__c> originalActivities) {

        // List of Quote Ids
        List<Id> quoteIds = new List<Id>();

        // Map of Zuora Subscription Id to Quote Id
        Map<String, Id> mapOfSubscriptionIdsToQuoteIds = new Map<String, Id>();

        // Map of Quote Id to Subscription Id
        Map<Id, Id> mapOfQuoteIdToSubscriptionId = new Map<Id, Id>();

        // Map of Quote Ids to Activity
        Map<Id, SageApiActivity__c> mapOfQuoteIdsToActivities = new Map<Id, SageApiActivity__c>();

        // If no activities are passed then return
        if (originalActivities == null || originalActivities.size() == 0) return;
        List<Id> listOfEMSAlreadyCreated = new List<Id>();

        // Iterate through the list of activities
        for (SageApiActivity__c activity : originalActivities) {
            try {

                // De-serialize request
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                if (req == null) continue;

                if (String.isNotBlank(activity.Quote__c)) {
                    quoteIds.add(activity.Quote__c);
                    mapOfSubscriptionIdsToQuoteIds.put(activity.ZuoraSubscriptionId__c, activity.Quote__c);
                    mapOfQuoteIdsToActivities.put(activity.Quote__c, activity);
                    //activity.Quote__c = data.quoteId;
                    //activity.Subscription__c = data.subscriptionId;
                }
            } catch (Exception e) {
                // Log exception
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertAsset', 'SM creation failed. More detail: ' + e.getMessage());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'convertSubscriptionMaster', e);
            }
        }

        if (quoteIds.size() > 0) {
            // Populate the zuora subscription Id for

            if (mapOfSubscriptionIdsToQuoteIds.size() > 0) {
                List<Zuora__Subscription__c> subscriptions = [SELECT Id, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :mapOfSubscriptionIdsToQuoteIds.keySet()];

                for (Zuora__Subscription__c subscription : subscriptions) {
                    if (mapOfSubscriptionIdsToQuoteIds.containsKey(subscription.Zuora__Zuora_Id__c)) {
                        Id quoteId = mapOfSubscriptionIdsToQuoteIds.get(subscription.Zuora__Zuora_Id__c);
                        mapOfQuoteIdToSubscriptionId.put(quoteId, subscription.Id);
                    }
                }
            }
            // Find assets associated to corresponding quotes

            List<Subscription_Master__c> subscriptionMasters = [Select Id, Status__c, Subscription__c, Quote__c FROM Subscription_Master__c WHERE Quote__c IN :quoteIds];
            for (Subscription_Master__c sm : subscriptionMasters) {
                if (sm.Status__c != Constants.ASSET_STATUS_ACTIVE) {
                    sm.Status__c = Constants.ASSET_STATUS_ACTIVE;
                    sm.End_Date__c = Date.newInstance(2099, 12, 31);

                    if (mapOfQuoteIdToSubscriptionId.containsKey(sm.Quote__c)) {
                        sm.Subscription__c = mapOfQuoteIdToSubscriptionId.get(sm.Quote__c);
                    }
                }
                if (mapOfQuoteIdsToActivities.containsKey(sm.Quote__c)) {
                    SageApiActivity__c activity = mapOfQuoteIdsToActivities.get(sm.Quote__c);
                    sm.Sage_API_Activity__c = activity.Id;
                    if (activity.Entitlement_Message__c != null) {
                        listOfEMSAlreadyCreated.add(activity.Entitlement_Message__c);
                    }
                }
            }

            Integer index = 0;

            Database.SaveResult [] assetResults = Database.update(subscriptionMasters, false);

            for(Database.SaveResult result : assetResults) {

                Subscription_Master__c currentSM = subscriptionMasters.get(index);
                SageApiActivity__c activity = mapOfQuoteIdsToActivities.get(currentSM.Quote__c);
                activity.SubscriptionMaster__c = currentSM.Id;
                activity.Subscription__c = currentSM.Subscription__c;
                activity.Step_Serialised__c = JSON.serialize(step);
                index += 1;

                if (result.isSuccess()) {
                    // Mark activity as successful
                    //SageApiActivityUtils.setSuccess(activity, step);
                    continue;
                }

                /*
                Boolean retryable = true;
                String detailMsg = '';
                for (Database.Error err : result.getErrors()) {
                    if (err.getStatusCode() != StatusCode.INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY)
                        continue;
                    retryable = false;
                }
                */
                // Mark activity as failed
                // always NotRetryable for MVP
                List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'SageApiTryNowConvertStepConvertSM', 'SM creation failed. More detail: ' + result.getErrors());
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            }
        }

        SageApiActivityUtils.updateActivities(originalActivities);

        if (listOfEMSAlreadyCreated.size() > 0) {
            List<SageApiActivity__c> activitiesToUpdate = new List<SageApiActivity__c>();
            List<Entitlement_Message__c> messages = [SELECT Id, Status__c, Subscription_Master__c, Subscription_Master__r.Sage_Api_Activity__c From Entitlement_Message__c WHERE Id IN :listOfEMSAlreadyCreated];
            for (Entitlement_Message__c message : messages) {
                if (message.Status__c == 'Error') {
                    message.Status__c  = 'New';
                } else {
                    activitiesToUpdate.add(new SageApiActivity__c(Id = message.Subscription_Master__r.Sage_Api_Activity__c));
                }
            }

            SageApiActivityUtils.debug('********activitiesToUpdate =' + activitiesToUpdate);

            if (activitiesToUpdate.size() > 0) {
                activitiesToUpdate = SageApiActivityUtils.refreshActivities(activitiesToUpdate);
                for (SageApiActivity__c activity : activitiesToUpdate) {
                    SageApiActivityUtils.setSuccess(activity, step);
                }
                SageApiActivityUtils.debug('********activitiesToUpdate updating =' + activitiesToUpdate);
                update activitiesToUpdate;
            }

            update messages;
        }
    }

    /**
     * Converts the Subscription Master record (in the future) based on Account and Product details provided.
     * @param step details
     * @param originalActivities set to update
     **/
    public static void convertTrialToPaid(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        Map<String, SageApiActivity__c> smSubIdActivityMap = new Map<String, SageApiActivity__c>();
        Map<String, String> smSubIdZuoraSubIdMap = new Map<String, String>();
        Map<String, Zuora__Subscription__c> zuoraSubIdZuoraSubMap = new Map<String, Zuora__Subscription__c>();
        List<Id> listOfEMSAlreadyCreated = new List<Id>();

        for (SageApiActivity__c activity : activities) {
            SageApiTryNowConvertActivityRequest req = null;
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            try {
                req = (SageApiTryNowConvertActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowConvertActivityRequest.class);
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            //if (req == null) {
            //    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid: null value resulted from deserialization');
            //    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            //    continue;
            //}

            if (String.isBlank(activity.ZuoraSubscriptionId__c) || String.isBlank(req.cbcTrialId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'RequiredItemMissing', 'Subscription Master ID and Zuora Subscription ID are both required.');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }

            smSubIdActivityMap.put(req.cbcTrialId, activity);
            smSubIdZuoraSubIdMap.put(req.cbcTrialId, activity.ZuoraSubscriptionId__c);
            zuoraSubIdZuoraSubMap.put(activity.ZuoraSubscriptionId__c, null);
        }

        if (smSubIdActivityMap.size() == 0) {
            SageApiActivityUtils.updateActivities(activities);
            return;
        }

        for (Zuora__Subscription__c sub : [SELECT Id, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :zuoraSubIdZuoraSubMap.keySet()])
            if (zuoraSubIdZuoraSubMap.containsKey(sub.Zuora__Zuora_Id__c))
                zuoraSubIdZuoraSubMap.put(sub.Zuora__Zuora_Id__c, sub);

        List<Subscription_Master__c> subscriptionMasters = [Select Id, Status__c, Subscription__c, CbcSubscriptionId__c, Entitlement_Id__c FROM Subscription_Master__c WHERE CbcSubscriptionId__c IN :smSubIdActivityMap.keySet()];
        for (Subscription_Master__c sm : subscriptionMasters) {
            SageApiActivity__c activity = smSubIdActivityMap.get(sm.CbcSubscriptionId__c);
            if (sm.Status__c == Constants.ASSET_STATUS_ACTIVE && activity.Entitlement_Message__c != null) {
                listOfEMSAlreadyCreated.add(activity.Entitlement_Message__c);
                continue;
            }

            sm.Status__c = Constants.ASSET_STATUS_ACTIVE;
            sm.End_Date__c = Date.newInstance(2099, 12, 31);
            sm.Sage_API_Activity__c = activity.Id;

            String zuoraSubId = smSubIdZuoraSubIdMap.get(sm.CbcSubscriptionId__c);
            Zuora__Subscription__c sub = zuoraSubIdZuoraSubMap.get(zuoraSubId);
            if (sub == null) continue;

            sm.Subscription__c = sub.Id;
            activity.Subscription__c = sub.Id;
        }

        Integer index = 0;
        List<ID> successOppIds = new List<ID>();
        Database.SaveResult [] assetResults = Database.update(subscriptionMasters, false);
        for(Database.SaveResult result : assetResults) {
            Subscription_Master__c currentSM = subscriptionMasters.get(index);
            SageApiActivity__c activity = smSubIdActivityMap.get(currentSM.CbcSubscriptionId__c);
            activity.SubscriptionMaster__c = currentSM.Id;
            activity.Subscription__c = currentSM.Subscription__c;
            activity.Step_Serialised__c = JSON.serialize(step);
            index++;

            if (result.isSuccess()) {
                // Mark activity as successful
                //SageApiActivityUtils.setSuccess(activity, step);
                successOppIds.add(activity.Opportunity__c);
                continue;
            }
            List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'convertTrialToPaid', 'SM creation failed. More detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }

        if (successOppIds.size() > 0) {
            Boolean hasUpdates = false;
            List<Opportunity> successOpps = [SELECT ID, StageName FROM Opportunity WHERE ID IN: successOppIds];
            for (Opportunity opp : successOpps) {
                if (opp.StageName == SageApiActivityUtils.setting_OpportunityStageClosedWon) continue;
                opp.StageName = SageApiActivityUtils.setting_OpportunityStageClosedWon;
                opp.Why_We_Lost__c = SageApiActivityUtils.setting_OpportunityClosedWonReason;
                hasUpdates = true;
            }
            if (hasUpdates) upsert successOpps;
        }

        SageApiActivityUtils.updateActivities(activities);

        if (listOfEMSAlreadyCreated.size() > 0) {
            List<SageApiActivity__c> activitiesToUpdate = new List<SageApiActivity__c>();
            List<Entitlement_Message__c> retryMessages = new List<Entitlement_Message__c>();
            List<Entitlement_Message__c> messages = [SELECT Id, Status__c, Subscription_Master__c, Subscription_Master__r.Sage_Api_Activity__c From Entitlement_Message__c WHERE Id IN :listOfEMSAlreadyCreated];
            for (Entitlement_Message__c message : messages) {
                if (message.Status__c == 'Error') {
                    message.Status__c  = 'New';
                    retryMessages.add(message);
                    continue;
                }
                activitiesToUpdate.add(new SageApiActivity__c(Id = message.Subscription_Master__r.Sage_Api_Activity__c));
            }

            SageApiActivityUtils.debug('********activitiesToUpdate =' + activitiesToUpdate);

            if (activitiesToUpdate.size() > 0) {
                activitiesToUpdate = SageApiActivityUtils.refreshActivities(activitiesToUpdate);
                for (SageApiActivity__c activity : activitiesToUpdate)
                    SageApiActivityUtils.setSuccess(activity, step);

                SageApiActivityUtils.debug('********activitiesToUpdate updating =' + activitiesToUpdate);
                SageApiActivityUtils.updateActivities(activitiesToUpdate);
            }

            if (retryMessages.size() > 0)
                update messages;
        }
    }

    public static Map<ID, ID> getActivitySubscriptionMasters(List<SageApiActivity__c> activities){
        if (activities == null || activities.size() == 0) return null;
        Map<ID, String> activitySMExternalIdMap = new  Map<ID, String>();
        Map<ID, ID> activitySMMap = new  Map<ID, ID>();

        for (SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null || req.account == null || String.isBlank(req.account.accountId) || req.products == null || req.products.size() == 0) continue;

                ID accountId = req.account.accountId;
                for (SageApiActivityRequestObjects.Product product : req.products) {
                    string externalId = accountId + '-' + product.tierCode + (String.isBlank(product.tierRatePlanCode) ? '' : '-' + product.tierRatePlanCode);
                    activitySMExternalIdMap.put(activity.Id, externalId);
                }

                SageApiActivityUtils.debug('activitySMExternalIdMap: ' + JSON.serialize(activitySMExternalIdMap));
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getSubscriptionMasters', ex);
                continue;
            }
        }

        if (activitySMExternalIdMap.size() == 0) return activitySMMap;

        List<Subscription_Master__c> sms = [SELECT Id, External_ID__c FROM Subscription_Master__c WHERE External_Id__c IN :activitySMExternalIdMap.values()];
        if (sms == null || sms.size() == null) return activitySMMap;

        for (ID activityId : activitySMExternalIdMap.keySet()) {
            String externalId = activitySMExternalIdMap.get(activityId);
            for (Subscription_Master__c sm : sms)
                if (externalId == sm.External_ID__c)
                    activitySMMap.put(activityId, sm.Id);
        }
        return activitySMMap;
    }

    public static List<SageApiActivityRequestObjects.Product> getRequestProducts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<SageApiActivityRequestObjects.Product> allProducts = new List<SageApiActivityRequestObjects.Product>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null) continue;
                if (req.products == null || req.products.size() == 0) continue;

                for (SageApiActivityRequestObjects.Product product : req.products) {
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
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getRequestProducts', ex);
                return null;
            }
        }
        return allProducts;
    }

    public static Map<Id, Lead> getRequestLeads(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Lead> leads = new Map<Id, Lead>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null) continue;

                SageApiActivityRequestObjects.Contact contact = req.contact;
                if (contact == null || string.isBlank(contact.leadId)) continue;

                leads.put(contact.leadId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getRequestLeads', ex);
            }
        }

        if (leads.size() == 0 ) return null;

        try {
            leads.putAll([SELECT Id, IsConverted FROM Lead WHERE Id IN :leads.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getRequestLeads', ex);
        }

        return leads;
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
                SageApiActivityUtils.debug('SageApiTryNowActivityUtils.updateArtifactWithLead: '+JSON.serialize(activity));
                continue;
            }

            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'upsertLead', 'upsertLead failed. Detail: ' + result.getErrors());
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
        }
    }

    @Future(callout=true)
    @TestVisible
    private static void getPricing(string stepStr, string activitiesStr, string quoteListStr, string quoteIdListStr) {
        SageApiActivityStep step = null;
        List<SageApiActivity__c> activities = null;
        try {
            step = (SageApiActivityStep)JSON.deserialize(stepStr, SageApiActivityStep.class);
            activities = (List<SageApiActivity__c>)JSON.deserialize(activitiesStr, List<SageApiActivity__c>.class);
            List<zqu__Quote__c> priceableQuotes = (List<zqu__Quote__c>)JSON.deserialize(quoteListStr, List<zqu__Quote__c>.class);
            List<ID> priceableQuoteIds = (List<ID>)JSON.deserialize(quoteIdListStr, List<ID>.class);

            Integer numberOfPeriods = 1; //-2147483647;
            List<zqu.zQuoteUtil.zBillingResult> results = null;
            if(TestUtils.isRunningTest()) {
                results = new List<zqu.zQuoteUtil.zBillingResult>();
                zqu.zQuoteUtil.zBillingResult result = new zqu.zQuoteUtil.zBillingResult();
                result.success=true;
                result.totalMrr=100;
                result.totalTcv=100;
                result.totalInfo = new zqu.zQuoteUtil.TotalInfo();
                result.totalInfo.discount = 0;
                result.totalInfo.subTotal = 100;
                result.totalInfo.total = 100;
                result.totalInfo.tax = 0;
                results.add(result);
            } else {
                Try {
                    results = zqu.zQuoteUtil.previewQuotes(priceableQuoteIds, numberOfPeriods);
                } catch (Exception e) {}
            }
            SageApiActivityUtils.debug('zQuoteUtil.previewQuotes should be processed: '+results);

            Integer index = -1;
            for (zqu.ZQuoteUtil.ZBillingResult result : results) {
                index++;
                SageApiActivity__c activity = activities[index];
                if (result.success) {
                    zqu__Quote__c quote = priceableQuotes[index];
                    quote.zqu__Previewed_Discount__c = result.totalInfo.discount;
                    quote.zqu__Previewed_SubTotal__c = result.totalInfo.subTotal;
                    quote.zqu__Previewed_Total__c = result.totalInfo.total;
                    quote.zqu__Previewed_Tax__c = result.totalInfo.tax;
                    quote.zqu__Previewed_MRR__c = result.totalMrr;
                    quote.zqu__Previewed_TCV__c = result.totalTcv;
                    quote.zqu__Previewed_Tax__c = 0;
                    activity.QuoteMetricsCalculated__c = true;
                    SageApiActivityUtils.setSuccess(activity, step);
                } else {
                    if (result.message.contains('The Quote metrics value is the latest, no need to preview')) {
                        activity.QuoteMetricsCalculated__c = true;
                        continue;
                    }
                    List<SageApiActivityError> errors = new List<SageApiActivityError>();
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'zQuoteUtil.previewQuotes', 'Failed: '+result.message);
                    SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                }
            }

            update priceableQuotes;
            SageApiActivityUtils.updateActivities(activities);
        } catch (Exception ex) {
            SageApiActivityUtils.debug('Calculate metrics has error: '+ex);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getQuotePricing', ex);
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'zQuoteUtil.previewQuotes', 'Failed: '+ex);
            for (SageApiActivity__c activity : activities)
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            SageApiActivityUtils.updateActivities(activities);
        }
    }

    @TestVisible
    private static List<zqu__Quote_Template__c> getQuoteTemplateSettings(string quoteType, Map<ID, Account> accountMap) {
        //SELECT Country_Code__c,Country__c,Language__c,zqu__IsDefault__c,zqu__Quote_Type__c,zqu__Template_Id__c FROM zqu__Quote_Template__c WHERE Country_Code__c = \'' + countryCode + '\' AND language__c = \'' + language + '\''
        if (string.isBlank(quoteType)) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getQuoteTemplateSettings', new CustomException('No quoteType provided'));
            return null;
        }
        SageApiActivityUtils.debug('quoteType: '+quoteType);

        if (accountMap == null || accountMap.size() == 0) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getQuoteTemplateSettings', new CustomException('No account info provided'));
            return null;
        }
        SageApiActivityUtils.debug('accountMap: '+accountMap);

        String queryFilter = '';
        for (Account account : accountMap.values())
            if (string.isNotBlank(account.BillingCountryCode) && string.isNotBlank(account.locale__r.language__c)) {
                string subQuery = '(Country_Code__c = \'' + String.escapeSingleQuotes(account.BillingCountryCode) + '\' and language__c = \'' + String.escapeSingleQuotes(account.locale__r.language__c) + '\')';
                if (queryFilter.indexOf(subQuery) == -1)
                    queryFilter += (String.IsBlank(queryFilter) ? '' : ' or ') + subQuery;
            }

        SageApiActivityUtils.debug('queryFilter: '+queryFilter);
        if (string.isBlank(queryFilter)) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getQuoteTemplateSettings', new CustomException('No valid account BillingCountryCode or language info provided'));
            return null;
        }

        string query = 'SELECT Country_Code__c,Country__c,Language__c,zqu__IsDefault__c,zqu__Quote_Type__c,zqu__Template_Id__c FROM zqu__Quote_Template__c WHERE zqu__Quote_Type__c = \'' + quoteType + '\' AND (' + queryFilter + ')';
        SageApiActivityUtils.debug('getQuoteTemplateSettings query: ' + query);
        List<zqu__Quote_Template__c> settings = Database.query(query);

        if (settings == null || settings.size() == 0) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getQuoteTemplateSettings', new CustomException('No zqu__Quote_Template__c entry found for query filter: ' + queryFilter));
            return null;
        }

        List<zqu__Quote_Template__c> returnSettings = new List<zqu__Quote_Template__c>();
        for (Account account : accountMap.values()) {
            zqu__Quote_Template__c returnSetting = null;
            for (zqu__Quote_Template__c setting : settings) {
                if (account.BillingCountryCode != setting.Country_Code__c || account.locale__r.language__c != setting.language__c ) continue;
                returnSetting = setting;
                break;
            }
            returnSettings.add(returnSetting);
        }

        return returnSettings;
    }
/*
    @TestVisible
    private static List<zqu__InvoiceTemplate__c> getInvoiceTemplateSettings(Map<ID, Account> accountMap) {
        //SELECT zqu__ZuoraId__c FROM zqu__InvoiceTemplate__c WHERE Country__c = \'' + countryCode + '\' AND language__c = \'' + language + '\''
        if (accountMap == null || accountMap.size() == 0) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getInvoiceTemplateSettings', new CustomException('No account info provided'));
            return null;
        }
        
        SageApiActivityUtils.debug('accountMap:'+accountMap);
        String queryFilter = '';
        for (Account account : accountMap.values())
            if (string.isNotBlank(account.BillingCountryCode) && string.isNotBlank(account.locale__r.language__c))
                queryFilter += (String.IsBlank(queryFilter) ? '' : ' or ') + '(Country__c = \'' + String.escapeSingleQuotes(account.BillingCountryCode) + '\' and language__c = \'' + String.escapeSingleQuotes(account.locale__r.language__c) + '\')';

        if (string.isBlank(queryFilter)) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getInvoiceTemplateSettings', new CustomException('No valid account BillingCountryCode or language info provided'));
            return null;
        }
        
        string query = 'SELECT ID, zqu__ZuoraId__c, Country__c, language__c FROM zqu__InvoiceTemplate__c WHERE ' + queryFilter;
        SageApiActivityUtils.debug('query:'+query);
        List<zqu__InvoiceTemplate__c> settings = Database.query(query);

        if (settings == null || settings.size() == 0) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getInvoiceTemplateSettings', new CustomException('No zqu__InvoiceTemplate__c entry found for query filter: ' + queryFilter));
            return null;
        }

        List<zqu__InvoiceTemplate__c> returnSettings = new List<zqu__InvoiceTemplate__c>();
        for (Account account : accountMap.values()) {
            zqu__InvoiceTemplate__c returnSetting = null;
            for (zqu__InvoiceTemplate__c setting : settings) {
                if (account.BillingCountryCode != setting.Country_Code__c || account.locale__r.language__c != setting.language__c ) continue;
                returnSetting = setting;
                break;
            }
            returnSettings.add(returnSetting);
        }
        
        return returnSettings;        
    }
*/
/*    
    private static string generateQuotePdf(Id quoteId, string quoteTemplateId, string sessionId, string locale) {
        // Generate Quote and attach to Opportunity
        Map<String,Object> zuoraConfigInfo = zqu.zQuoteUtil.getZuoraConfigInformation();
        SageApiActivityUtils.debug('zuoraConfigInfo: ' + zuoraConfigInfo);

        Zuora.ZApi zApi = new Zuora.ZApi();
        Zuora.ZApi.LoginResult loginResult = new Zuora.ZApi.LoginResult();
        SageApiActivityUtils.debug('loginResult: ' + loginResult);
        
        if(TestUtils.isRunningTest()){
            loginResult.serverUrl = 'apisandbox';
        } else {
            loginResult = zApi.zLogin();
            SageApiActivityUtils.debug(loginResult.serverUrl);
        }
        
        //TODO: double check production URL
        String quoteServletUrl = loginResult.serverUrl.contains('apisandbox') ? SageApiActivityUtils.setting_ZuoraGenerateQuoteUrl_sandbox : SageApiActivityUtils.setting_ZuoraGenerateQuoteUrl;

        String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm() + SageApiActivityUtils.setting_SalesforceSoapServiceUrl + UserInfo.getOrganizationId();

        PageReference generatePage = new PageReference(quoteServletUrl);
        generatePage.getParameters().put('templateId', quoteTemplateId);
        generatePage.getParameters().put('serverUrl', sfdcUrl);
        generatePage.getParameters().put('sessionId', sessionId);
        generatePage.getParameters().put('quoteId', quoteId);
        generatePage.getParameters().put('attachToOpportunity', 'true');
        generatePage.getParameters().put('format', 'pdf');
        generatePage.getParameters().put('ZSession', loginResult.session);
        generatePage.getParameters().put('useSFDCLocale', '1');
        generatePage.getParameters().put('locale', locale);

        Http h = new Http();

        SageApiActivityUtils.debug('Quote PDF URL = ' + generatePage.getUrl());

        HttpRequest req = new HttpRequest();
        req.setEndpoint(generatePage.getUrl());
        req.setMethod('GET');
        req.setTimeout(2 * 60 * 1000);

        HttpResponse res = new HttpResponse();
        if(TestUtils.isRunningTest()){
            res.setStatusCode(200);
        } else {
            res = h.send(req);
        }
        SageApiActivityUtils.debug('Response status: '+res.getStatusCode());
        SageApiActivityUtils.debug('Response body: '+res.getBody());
        
        if (res.getStatusCode() != 200) {
            return null;
        }

        // * Zuora handles the attaching it to the
        // * opportunity through the https callout. We just check for success
        // * here
        String zuoraResponse = res.getBody();
        if(TestUtils.isRunningTest()){
            zuoraResponse = 'Quote PDF document has been successfully AttachmentID: 10101';
        }

        String successMessage = 'Quote PDF document has been successfully';
        if (zuoraResponse.contains(successMessage)) {
            string attachmentId = zuoraResponse.split('AttachmentID:', 0)[1];
            SageApiActivityUtils.debug('Attachment ID Post Regex: ' + attachmentId);

            // We know the index of the the attachment id.
            if (attachmentId.length() > 19) {
                attachmentId = attachmentId.substring(1,19);
            }
       
            return attachmentId;
        }
        return null;
    }
*/

    private static SageApiTryNowActivityResponse createResponse() {
        SageApiTryNowActivityResponse response = new SageApiTryNowActivityResponse();
        response.data = new SageApiTryNowActivityResponse.ResponseData();
        SageApiActivityUtils.debug('createResponse: '+JSON.serialize(response));
        return response;
    }

    public static void updateArtifact(SageApiActivity__c activity, List<SageApiActivityError> errors) {
        SageApiTryNowActivityResponse response = null;
        if (String.isNotBlank(activity.Artifacts__c))
            response = (SageApiTryNowActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiTryNowActivityResponse.class);
        if (response == null)
            response = createResponse();

        response.activityId = activity.ActivityID__c;
        response.status = activity.ActivityStatus__c;
        response.errors = errors;
        response.data.leadId = String.ValueOf(activity.Lead__c);
        response.data.opportunityId = String.ValueOf(activity.Opportunity__c);
        response.data.accountId = String.ValueOf(activity.Account__c);
        response.data.contactId = String.ValueOf(activity.Contact__c);
        response.data.communityMembershipId = activity.CommunityMembership__c;
        response.data.userId = String.ValueOf(activity.User__c);
        response.data.bridgeServiceId = String.ValueOf(activity.SageUserIdentityProvider__c);
        response.data.quoteId = String.ValueOf(activity.Quote__c);
        response.data.assetId = activity.SubscriptionMaster__c;
        response.data.paymentUrl = activity.PaymentUrl__c;
        //if (activity.SubscriptionMaster__c != null)
        response.data.cbcTrialId = activity.SubscriptionMaster__r.CbcSubscriptionId__c;
        if (String.isNotBlank(activity.CommunityMembership__c))
            response.data.hasCommunityAccess = true;

        string artifact = JSON.serialize(response);
        if (artifact.length() > 131072)
            artifact = artifact.substring(0, 131060) + '.TRUNCATED.';
        activity.Artifacts__c = artifact;
        SageApiActivityUtils.debug('activity.Artifacts__c: '+activity.Artifacts__c);
    }

    public static void updateArtifactWithErrorString(SageApiActivity__c activity, string serializedErrors) {
        if (String.isBlank(serializedErrors)) return;
        try {
            List<SageApiActivityError> errors = (List<SageApiActivityError>)JSON.deserialize(serializedErrors, List<SageApiActivityError>.class);
            updateArtifact(activity, errors);
        } catch (Exception ex) {
            SageApiActivityUtils.debug('Error deserializing errors: '+serializedErrors);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'updateArtifactWithErrorString', ex);
        }
    }

    private static List<String> getRequestLeadIds(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<String> leadIds = new List<String>();
        for (SageApiActivity__c activity : activities) {
            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);

                if (req == null || req.contact == null || String.isBlank(req.contact.leadId)) continue;
                leadIds.add(req.contact.leadId);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getRequestLeadIds', ex);
                continue;
            }
        }
        return leadIds;
    }

    private static Map<String, SageApiActivity__c> getConvertibleLeadIds(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, SageApiActivity__c> leadMap = new Map<String, SageApiActivity__c>();
        for (SageApiActivity__c activity : activities) {
            if (String.isBlank(activity.Artifacts__c)) continue;

            SageApiTryNowActivityResponse response = null;
            try {
                response = (SageApiTryNowActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiTryNowActivityResponse.class);

                if (response == null || response.data == null || String.isBlank(response.data.leadId) || !String.isBlank(response.data.opportunityId)) continue;
                leadMap.put(response.data.leadId, activity);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getConvertibleLeadIds', ex);
                continue;
            }
        }
        SageApiActivityUtils.debug('leads to be converted: ' + leadMap.keySet());
        return leadMap;
    }

    private static string getOpportunityName(SageApiActivity__c activity) {
        if (activity == null || string.isBlank(activity.payload__c)) return null;

        SageApiTryNowActivityRequest req = null;
        try {
            req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getOpportunityName', ex);
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

        List<SageApiActivityRequestObjects.Product> products = req.products;
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
        Map<String, String> tierCodeMap = new Map<String, String>();

        for (SageApiActivity__c activity : activities) {
            if (activity.Contact__c != null) contactMap.put(activity.Contact__c, null);
            if (activity.Account__c != null) accountMap.put(activity.Account__c, null);
            try {
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                List<SageApiActivityRequestObjects.Product> products = req.products;
                if (products != null && products.size() > 0)
                    tierCodeMap.put(products[0].tierCode, products[0].tierCode);
            } catch (Exception e) {}
        }
        if (contactMap.size() > 0) contactMap.putAll([SELECT Id, FirstName, LastName FROM Contact WHERE Id IN: contactMap.keySet()]);
        if (accountMap.size() > 0) accountMap.putAll([SELECT Id, Name FROM Account WHERE Id IN: accountMap.keySet()]);
        if (tierCodeMap.size() > 0)
            for (Product_Tier__c tierCode : [SELECT Id, Product_Tier_Code__c, Product__r.Name FROM Product_Tier__c WHERE Product_Tier_Code__c IN: tierCodeMap.keyset()])
                tierCodeMap.put(tierCode.Product_Tier_Code__c, tierCode.Product__r.Name);

        for (SageApiActivity__c activity : activities) {
            string name = null;
            Account account = accountMap.get(activity.Account__c);
            Contact contact = contactMap.get(activity.Contact__c);
            if (account != null) name = account.Name;
            if (string.isBlank(name) && contact != null) name = contact.FirstName + ' ' + contact.LastName;

            try {
                SageApiTryNowActivityRequest req = (SageApiTryNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiTryNowActivityRequest.class);
                if (string.isBlank(name)) {
                    SageApiActivityRequestObjects.Account ra = req.account;
                    if (ra != null)
                        name = ra.name;

                    if (string.isBlank(name)) {
                        SageApiActivityRequestObjects.Contact rc = req.contact;
                        if (rc != null)
                            name = rc.firstName + ' ' + rc.lastName;
                    }
                }

                List<SageApiActivityRequestObjects.Product> products = req.products;
                if (products != null && products.size() > 0) {
                    string productName = tierCodeMap.get(products[0].tierCode);
                    if ((name.length() + productName.length()) > 77) // excluding ' - '
                        productName = productName.replace('Sage Business Cloud ', '');
                    if ((name.length() + productName.length()) > 77)
                        name = name.substring(0, 77 - productName.length());
                    name = string.isBlank(productName) ? name : name + ' - ' + productName;
                }
            } catch (Exception e) {
                name += ' - Unknown Product';
            }
            activityOppNameMap.put(activity.Id, name);
        }

        return activityOppNameMap;
    }

    public static SageApiActivityRequestObjects.PaymentResponse createPaymentUrl(SageApiActivityRequestObjects.PaymentRequest request){
        SageApiActivityRequestObjects.PaymentResponse response = new SageApiActivityRequestObjects.PaymentResponse();
        SageApiActivityRequestObjects.Product product = request.Products[0];
        //if (String.isBlank(product.pricingCode))
        //    product.pricingCode = '_LIST';
        //String today = Date.today().format();
        //PricingCode__c pricingCode = [SELECT ID, Name,Product_Tier__r.Product_Tier_Code__c,ProductTierRatePlanCode__r.Name,ProductTierRatePlanCode__r.Trial_Period__c FROM PricingCode__c WHERE IsDeleted=false AND Start_Date__c <= :today AND End_Date__c >= :today AND Name=:product.pricingCode AND Product_Tier__r.Product_Tier_Code__c=:product.tierCode AND ProductTierRatePlanCode__r.Name=:product.tierRatePlanCode LIMIT 1];
        Product_Tier_Rate_Plan__c tierRatePlan = [SELECT Id,Trial_Period__c FROM Product_Tier_Rate_Plan__c WHERE IsDeleted = false AND Name =:product.tierRatePlanCode AND Product_Tier__r.Product_Tier_Code__c =:product.tierCode LIMIT 1];

        if (String.isBlank(request.endDate))
            if (tierRatePlan != null && tierRatePlan.Trial_Period__c > 0)
                request.endDate = DateTime.now().addDays(Integer.valueOf(tierRatePlan.Trial_Period__c)).format('yyyy-MM-dd');
            else
                    request.endDate = DateTime.now().addDays(90).format('yyyy-MM-dd');

        string baseUrl = SageApiActivityUtils.setting_PayNowBaseUrl;
        string userName = PayNowSetting__c.getInstance('payNowServiceUserName').Value__c;
        string password = PayNowSetting__c.getInstance('payNowServicePassword').Value__c;
        string paymentUrl = '/api/PaymentMethods';

        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');

        req.setEndpoint(baseUrl + paymentUrl);
        req.setMethod('POST');
        req.setBody(JSON.serialize(request));
        SageApiActivityUtils.debug('payload: ' + JSON.serialize(request));
        //req.setCompressed(true); // otherwise we hit a limit of 32000

        try {
            String jsonValue = null;
            if (Test.isRunningTest()) {
                jsonValue = '{"paymentUrl": "http://test.com"}';
            } else {
                res = http.send(req);
                jsonValue = res.getBody();
            }
            SageApiActivityUtils.debug(jsonValue);
            JSONParser parser = JSON.createParser(jsonValue);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'paymentUrl') {
                        response.paymentUrl = parser.getText();
                        response.success = true;
                        break;
                    }
                }
            }
        } catch(Exception e) {
            SageApiActivityUtils.debug('Callout error: '+ e);
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'createPaymentUrl', e);
            response.success = false;
            response.error = 'Error when creating Payment URL: ' + e;
        }

        //TODO: create record in PayNowToken

        return response;
    }

    public static Map<Id, Account> getValidRequestAccounts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Account> accounts = new Map<Id, Account>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null || req.account == null || string.isBlank(req.account.AccountId)) continue;

                accounts.put(req.account.AccountId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestAccounts', ex);
            }
        }

        if (accounts.size() == 0 ) return null;

        try {
            accounts.putAll([SELECT Id, RecordTypeId FROM Account WHERE Id IN :accounts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestAccounts', ex);
        }

        return accounts;
    }

    public static Map<Id, Contact> getValidRequestContacts(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<Id, Contact> contacts = new Map<Id, Contact>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null || req.contact == null || string.isBlank(req.contact.ContactId)) continue;

                contacts.put(req.contact.ContactId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestContacts', ex);
            }
        }

        if (contacts.size() == 0 ) return null;

        try {
            contacts.putAll([SELECT Id, RecordTypeId, Email FROM Contact WHERE Id IN :contacts.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestContacts', ex);
        }

        return contacts;
    }

    public static Map<string, SageUserIdentityProvider__c> getValidRequestIdentities(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<string, SageUserIdentityProvider__c> identities = new Map<string, SageUserIdentityProvider__c>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiTryNowActivityRequest req = null;
            try {
                req = (SageApiTryNowActivityRequest)JSON.deserialize(payload, SageApiTryNowActivityRequest.class);
                if (req == null || req.account == null || string.isBlank(req.account.AccountId) || req.contact == null || string.isBlank(req.contact.identityId) || string.isBlank(req.contact.identityType)) continue;

                identities.put(ID.valueOf(req.account.AccountId)+':'+req.contact.identityType+':'+req.contact.identityId, null);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestIdentities', ex);
            }
        }

        if (identities.size() == 0 ) return null;

        try {
            identities.putAll([SELECT Id, SFBridgeID__c, Account__c, User__c, User__r.ContactId FROM SageUserIdentityProvider__c WHERE SFBridgeID__c != '' AND SFBridgeID__c IN :identities.keyset()]);
        } catch (Exception ex) {
            ExceptionHandler.CatchException('SageApiTryNowActivityUtils', 'getValidRequestIdentities', ex);
        }

        return identities;
    }
}