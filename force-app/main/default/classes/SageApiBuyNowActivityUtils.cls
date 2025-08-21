public class SageApiBuyNowActivityUtils {
    public static Boolean validatePayload(SageApiActivity__c activity, SageApiActivityStep step, List<Product_Tier__c> productTiers, List<Product_Tier_Rate_Plan__c> productTierRatePlans, List<PayNowToken__c> tokens, Map<string, List<PricingCodeCharge__c>> pricingChargeMap, Map<Id, Account> accounts, Map<Id, Contact> contacts, Map<string, SageUserIdentityProvider__c> identities, Map<ID, Community_Membership__c> contactCommunitiesMap, Map<ID, ID> activitySubMasterMap, Map<ID, ID> activitySubMap) {
        List<SageApiActivityError> errors = new List<SageApiActivityError>();

        if (activity == null || step == null)
            return false;

        SageApiBuyNowActivityRequest req = null;
        try {
            req = (SageApiBuyNowActivityRequest)JSON.deserialize(activity.payload__c, SageApiBuyNowActivityRequest.class);
        } catch (Exception ex) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'Payload', 'Activity Payload is not valid. Detail' + ex);
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        System.debug('validatePayload req: ['+ req + ']');

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

        // validate root-level attributes
        if (String.isBlank(req.startDate)) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'startDate', 'Start Date is required');
        }

        Date startDate = Date.newInstance(2000, 1, 1);
        Date endDate = Date.newInstance(2000, 1, 1);

        if (!String.isBlank(req.startDate)) {
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
            }
        }

        if (!String.isBlank(req.endDate)) {
            try {
                endDate= Date.valueOf(req.endDate);

                if (endDate < startDate) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date must be later than Start Date');
                }
            } catch (Exception ex) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'endDate', 'End Date not in valid format');
            }
        }

        SageApiActivityRequestObjects.Account account = req.account;
        if (account == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'account', 'account is required');
        }

        if (account != null && String.isBlank(account.accountId)) {
            //if (String.isBlank(account.currencyCode)) {
            //     SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'currencyCode', 'Currency Code is required');
            //}

            if (String.isBlank(account.name)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'name', 'Account Name is required');
            }
            if (String.isBlank(req.payNowToken) && String.isBlank(account.paymentMethodId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'paymentMethodId', 'Zuora Payment Method ID is required');
            }
            if (String.isBlank(req.payNowToken) && String.isBlank(account.paymentMethodType)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'paymentMethodType', 'Zuora Payment Method Type is required (ACH, BankTransfer, and CreditCard)');
            }
        }

        SageApiActivityRequestObjects.Contact contact = req.contact;
        if (contact == null) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'contact', 'Contact is required');
        }

        if (contact != null) {
            if (String.isBlank(contact.identityType)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityType', 'Identity Type is required');
            }

            if (String.isBlank(contact.identityId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'identityId', 'Identity ID is required');
            }

            if (String.isBlank(contact.contactId)) {
                if (String.isBlank(contact.firstName)) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'firstName', 'First Name is required');
                }

                if (String.isBlank(contact.lastName)) {
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'lastName', 'Last Name is required');
                }

                if (String.isBlank(contact.email))
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'email', 'Email is required');
                else
                        activity.ContactEmail__c = contact.email;
            }
        }

        if (tokens != null && tokens.size() > 0)
            for (PayNowToken__c token : tokens) {
                if (token.Name != req.payNowToken && token.PaymentMethodId__c != req.account.paymentMethodId) continue;

                if (String.isBlank(req.account.paymentMethodId))
                    req.account.paymentMethodId = String.isBlank(token.Quote_Payment_Method_ID__c) ? token.PaymentMethodId__c : token.Quote_Payment_Method_ID__c;
                if (String.isBlank(req.account.paymentMethodType))
                    req.account.paymentMethodType = token.PaymentMethodType__c;

                List<SageApiActivityRequestObjects.ProductConfig> pcs = (List<SageApiActivityRequestObjects.ProductConfig>)JSON.deserialize(token.Products__c, List<SageApiActivityRequestObjects.ProductConfig>.class);
                if (pcs != null && pcs.size() > 0) {
                    List<SageApiActivityRequestObjects.Product> ps = new List<SageApiActivityRequestObjects.Product>();
                    for (SageApiActivityRequestObjects.ProductConfig pc : pcs) {
                        SageApiActivityRequestObjects.Product p = new SageApiActivityRequestObjects.Product();
                        p.tierCode = pc.tierCode;
                        if (pc.tierRatePlanCodes!=null && pc.tierRatePlanCodes.size()>0)
                            p.tierRatePlanCode = pc.tierRatePlanCodes[0].tierRatePlanCode;
                        p.pricingCode = pc.pricingCode;
                        if (String.isNotBlank(token.ReferrerPromotion__r.PricingCode__r.Name))
                            p.pricingCode = token.ReferrerPromotion__r.PricingCode__r.Name;

                        ps.add(p);
                    }

                    req.products = ps;
                }

                if (String.isNotBlank(token.ReferrerPromotion__c))
                    activity.ReferrerPromotion__c = token.ReferrerPromotion__c;
                activity.Payload__c = JSON.serializePretty(req);
                activity.PayNowToken__c = token.Id;
                break;
            }

        if (String.isNotBlank(req.referrerPromotion)) {
            Boolean found = false;
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

            if (! found) {
                activity.ChannelPlatformProvided__c = null;
                activity.ChannelPartnerProvided__c = null;
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

        if (identities != null && identities.size() > 0 && req.account != null && String.isNotBlank(req.account.AccountId) && req.contact != null && String.isNotBlank(req.contact.identityType) && String.isNotBlank(req.contact.identityId)) {
            try {
                String sfBrdigeId = ID.valueOf(activity.Account__c) + ':' + req.contact.identityType + ':' + req.contact.identityId;
                SageApiActivityUtils.debug('sfBrdigeId: '+sfBrdigeId);
                ////Boolean hasMatchingContact = false;
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
        if (products == null || products.size() == 0) {
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'products', 'Products is required');
        }

        if (products != null) {
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
                if (pt.Product_Tier_Code__c == products[0].tierCode) {
                    hasMatchingPt = true;
                    break;
                }
            }

            if (!hasMatchingPt)
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierCode', 'Product Tier Code not found');

            if (products.size() > 0 && String.IsNotBlank(products[0].tierRatePlanCode)) {
                Boolean hasMatchingPtrp = false;
                for (Product_Tier_Rate_Plan__c ptrp : productTierRatePlans) {
                    if (ptrp == null) continue;
                    if (ptrp.Product_Tier__r.Product_Tier_Code__c == products[0].tierCode && ptrp.name == products[0].tierRatePlanCode) {
                        hasMatchingPtrp = true;
                        activity.ProductTierRatePlan__c = ptrp.Id;
                        break;
                    }
                }

                if (!hasMatchingPtrp)
                    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'tierRatePlanCode', 'Product Tier Rate Plan Code not found');
            }
        }

        if (activity.ActivityType__c == SageApiActivityTriggerHandler.TetrisStartPaidActivityType) {
            if (String.isBlank(req.zuoraSubscriptionId)) {
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'zuoraSubscriptionId', 'zuoraSubscriptionId is required');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            } //else {
            // Tetris created Zuora Sub, but not synched down to SF yet, so disable the validation for now
            //if (activitySubMap == null || activitySubMap.size() == 0) {
            //    SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'subscription', 'No matching Zuora subscription found');
            //} else  {
            //    ID subId = activitySubMap.get(activity.Id);
            //    if (String.isBlank(subId))
            //        SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.RequiredItemMissing, 'subscription', 'No matching Zuora subscription found.');
            //    else
            //        activity.Subscription__c = subId;
            //}
            //}
        }

        if (String.isNotBlank(req.zuoraSubscriptionId))
            activity.zuoraSubscriptionId__c = req.zuoraSubscriptionId;

        if (activitySubMasterMap != null && activitySubMasterMap.size() > 0) {
            ID subMasterId = activitySubMasterMap.get(activity.Id);
            if (String.isNotBlank(subMasterId)) {
                activity.SubscriptionMaster__c = subMasterId;
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'subscriptionMaster', 'The account has already subscribed to this product');
            }
        }

        if (errors.size() > 0) {
            System.debug('Errors: '+JSON.serialize(errors));
            SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
            return false;
        }

        activity.ActivityStatus__c = SageApiStatus.InProgress;
        activity.ZuoraSubscriptionId__c = req.zuoraSubscriptionId;
        SageApiActivityUtils.setSuccess(activity, step);
        System.debug('Success: '+JSON.serialize(activity));
        return true;
    }

    public static void createSubscription(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        System.debug('enter createSubscription');
        activities = SageApiActivityUtils.refreshActivities(activities);
        List<SageApiActivity__c> candidateActivities = new List<SageApiActivity__c>();
        List<SageApiActivity__c> processedActivities = new List<SageApiActivity__c>();

        // SendToZBilling is not bulkified so we have to call it iteratively for this MVP!!!
        for (SageApiActivity__c activity : activities) {
            // started already
            if (activity.LockedForProcess__c == SageApiProcessLocks.Subscription)
                continue;

            if (String.isNotBlank(activity.ZuoraSubscriptionId__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                processedActivities.add(activity);
                continue;
            }

            // set being processed for idempotency check
            activity.LockedForProcess__c = SageApiProcessLocks.Subscription;
            candidateActivities.add(activity);
        }

        //if (processedActivities.size()>0)
        SageApiActivityUtils.updateActivities(activities);

        if (candidateActivities.size()==0) {
            System.debug('SageApiBuyNowActivityUtils.createSubscription: nothing to process');
            return;
        }

        for (SageApiActivity__c activity : candidateActivities) {
            List<SageApiActivity__c> container = new List<SageApiActivity__c>();
            container.add(activity);
            System.debug('begin making future call ###: '+step);
            createSubscription(JSON.serialize(step), JSON.serialize(container), sessionId);
            System.debug('end making future call ###');
        }
    }

    @future(callout=true)
    public static void createSubscription(string stepStr, string activitiesStr, string sessionId) {
        SageApiActivityStep step = (SageApiActivityStep)JSON.deserialize(stepStr, SageApiActivityStep.class);
        List<SageApiActivity__c> originalActivities = (List<SageApiActivity__c>)JSON.deserialize(activitiesStr, List<SageApiActivity__c>.class);
        //
        //The logic is following SendToZBillingAJAXController
        //
        System.debug('createSubscription: '+JSON.serialize(originalActivities));
        if (originalActivities == null || originalActivities.size() == 0) return;
        Map<String, SageApiActivity__c> quoteActivityMap = new Map<String, SageApiActivity__c>();
        Set<ID> candidateQuoteIds = new Set<ID>();
        originalActivities = SageApiActivityUtils.refreshActivities(originalActivities);

        //get activities not processed before
        for (SageApiActivity__c activity : originalActivities) {
            // processed successfully before
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID) || String.isNotBlank(activity.ZuoraSubscriptionId__c)) {
                SageApiActivityUtils.setSuccess(activity, step);
                continue;
            }
            // started already
            //if (activity.LockedForProcess__c == SageApiProcessLocks.Subscription) continue;
            // set being processed for idempotency check
            //activity.LockedForProcess__c = SageApiProcessLocks.Subscription;

            if (SageApiActivityUtils.activityTerminated(activity) || String.isBlank(activity.Quote__c)) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.InvalidValue, 'createSubscription', 'The Zuora service call may have timed out. Please go to account page to verify if Zuora Billing Account and Subscription have been created. If not created, you may try to resume the activity, otherwise, manual handling may be required.');
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                continue;
            }
            // will not happen synchronously due to async Zuora synching back to SF
            //if (String.isNotBlank(activity.Subscription__c))
            //    continue;

            String quoteId = activity.Quote__c;
            if (quoteActivityMap.containsKey(quoteId)) continue;
            candidateQuoteIds.add(quoteId);
            quoteActivityMap.put(quoteId, activity);
        }

        // nothing to process
        if (candidateQuoteIds.size()==0) {
            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }
        System.debug('candidateQuoteIds: '+JSON.serialize(candidateQuoteIds));

        List<zqu__quote__c> quotes = null;
        try {
            //only handle ones with payment method ids and without subscription id
            quotes = [SELECT zqu__Status__c,zqu__Currency__c,zqu__Account__r.Sales_Office__c,zqu__Account__r.VAT_Number__c,zqu__SubscriptionTermStartDate__c,zqu__ExistSubscriptionID__c,zqu__SubscriptionType__c, zqu__Account__c,zqu__Account__r.Zuora_Country_Code__c,zqu__CancellationDate__c,zqu__Previewed_SubTotal__c,zqu__Previewed_Total__c, zqu__StartDate__c,zqu__TermStartDate__c,zqu__SubscriptionTermEndDate__c,Id,zqu__ZuoraAccountID__c,zqu__ElectronicPaymentMethodId__c,zqu__PaymentMethod__c,zqu__Previewed_Delta_TCV__c,zqu__Previewed_Delta_MRR__c FROM zqu__quote__c WHERE zqu__ElectronicPaymentMethodId__c != null AND zqu__ElectronicPaymentMethodId__c != ''  AND (zqu__ZuoraSubscriptionID__c = null OR zqu__ZuoraSubscriptionID__c = '') AND Id in: candidateQuoteIds];
        } catch (Exception ex){
            System.Debug('Error retrieving quotes with SOQL: '+ex);
            ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'createSubscription', ex);
        }
        if (quotes == null || quotes.size() == 0) {
            System.debug('Quotes empty from SOQL for the quote IDs: '+candidateQuoteIds);
            List<SageApiActivityError> errors = new List<SageApiActivityError>();
            SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'createSubscription', 'No valid quotes to process (with Payment Method ID and no prior conversion)');
            for ( SageApiActivity__c activity : quoteActivityMap.values())
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);

            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }

        Map<ID, string> successQuoteMap = new Map<ID, string>();
        for (zqu__quote__c quote : quotes) {
            SageApiActivity__c activity = quoteActivityMap.get(quote.Id);
            if (activity == null) continue;

            try {
                String msg = SendToZBillingUtils.callZQuoteGlobal(quote.Id, 'PayNow-SageOne');
                if (msg == Label.lbl_successful_send) {
                    successQuoteMap.put(quote.Id, msg);
                    activity.LockedForProcess__c = SageApiProcessLocks.None;
                    continue;
                }

                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                msg = 'Failed with possible data issue: '+msg;
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'SendToZBilling', msg);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                System.Debug(msg);
                ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'SendToZBilling', new CustomException(msg));
            } catch (Exception e) {
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                String msg = 'Failed with possible service issue: '+e;
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'SendToZBilling', msg);
                SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                System.Debug(msg);
                ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'SendToZBilling', new CustomException(msg));
            }
        }

        List<zqu__quote__c> successQuotes = null;
        try {
            successQuotes = [SELECT Id,zqu__ZuoraSubscriptionID__c,zqu__Opportunity__c FROM zqu__Quote__c WHERE Id in: successQuoteMap.keySet()];
        } catch (Exception ex){
            System.Debug('Error retrieving successQuotes with SOQL: '+ex);
            ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'createSubscription', ex);
        }
        if (successQuotes == null || successQuotes.size() == 0) {
            System.debug('Quotes empty from SOQL for the quote IDs');
            SageApiActivityUtils.updateActivities(originalActivities);
            return;
        }

        Map<string, Zuora__Subscription__c> successZuoraIDSubscriptionMap = new Map<string, Zuora__Subscription__c>();
        for (zqu__quote__c quote : successQuotes)
            successZuoraIDSubscriptionMap.put(quote.zqu__ZuoraSubscriptionID__c, null);
        successZuoraIDSubscriptionMap.putAll([SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN :successZuoraIDSubscriptionMap.keySet()]);
        System.debug('successQuotes: '+successQuotes);
        System.debug('successZuoraIDSubscriptionMap: '+successZuoraIDSubscriptionMap);

        List<ID> successOppIds = new List<ID>();
        for (zqu__quote__c quote : successQuotes) {
            SageApiActivity__c activity = quoteActivityMap.get(quote.Id);
            if (activity == null) continue;
            activity.Opportunity__c = quote.zqu__Opportunity__c;
            activity.ZuoraSubscriptionId__c = quote.zqu__ZuoraSubscriptionID__c;
            Zuora__Subscription__c sub = successZuoraIDSubscriptionMap.get(quote.zqu__ZuoraSubscriptionID__c);
            if (sub != null) activity.Subscription__c = sub.Id;
            SageApiActivityUtils.setSuccess(activity, step);
            successOppIds.add(quote.zqu__Opportunity__c);
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
        SageApiActivityUtils.updateActivities(originalActivities);
    }

    /**
     * Upserts assets based on Account and Product details provided.
     * @param step details
     * @param originalActivities set to update
     **/
    public static List<PayNowToken__c> getPayNowTokens(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<String> tokens = new List<String>();
        List<String> paymentMethodIds = new List<String>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiBuyNowActivityRequest req = null;
            try {
                req = (SageApiBuyNowActivityRequest)JSON.deserialize(payload, SageApiBuyNowActivityRequest.class);
                if (req != null && String.isNotBlank(req.payNowToken)) {
                    tokens.add(req.PayNowToken);
                    continue;
                }

                if (req.account != null && String.isNotEmpty(req.account.paymentMethodId))
                    paymentMethodIds.add(req.account.paymentMethodId);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'getPayNowTokens', ex);
                return null;
            }
        }

        if (tokens.isEmpty() && paymentMethodIds.isEmpty()) return null;
        return [SELECT ID, Name, Products__c, Quote_Payment_Method_ID__c, PaymentMethodId__c, PaymentMethodType__c, ReferrerPromotion__c, ReferrerPromotion__r.Id, ReferrerPromotion__r.StartDate__c, ReferrerPromotion__r.EndDate__c, ReferrerPromotion__r.ReferrerId__c , ReferrerPromotion__r.ReferrerName__c, ReferrerPromotion__r.PricingCode__r.Name FROM PayNowToken__c WHERE Name IN: tokens OR PaymentMethodId__c IN: paymentMethodIds];
    }
/*
    public static Map<PayNowToken__c, SageApiActivity__c> getPayNowTokens(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        List<String> tokens = new List<String>();
        List<String> paymentMethodIds = new List<String>();
        Map<String, SageApiActivity__c> tokenOrPaymentActivityMap = new Map<String, SageApiActivity__c>();
        Map<PayNowToken__c, SageApiActivity__c> tokenActivityMap = new Map<PayNowToken__c, SageApiActivity__c>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiBuyNowActivityRequest req = null;
            try {
                req = (SageApiBuyNowActivityRequest)JSON.deserialize(payload, SageApiBuyNowActivityRequest.class);
                if (req != null && String.isNotBlank(req.payNowToken)) {
                    tokens.add(req.PayNowToken);
                    tokenOrPaymentActivityMap.put(req.PayNowToken, activity);
                    continue;
                }

                if (req.account != null && String.isNotEmpty(req.account.paymentMethodId)) {
                    paymentMethodIds.add(req.account.paymentMethodId);
                    tokenOrPaymentActivityMap.put(req.account.paymentMethodId, activity);
                }
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'getPayNowTokens', ex);
                return null;
            }
        }

        if (tokens.isEmpty() && paymentMethodIds.isEmpty()) return null;
        for (PayNowToken__c token : [SELECT ID, Name, Products__c, Quote_Payment_Method_ID__c, PaymentMethodId__c, PaymentMethodType__c, ReferrerPromotion__c, ReferrerPromotion__r.Id, ReferrerPromotion__r.ReferrerId__c , ReferrerPromotion__r.ReferrerName__c, ReferrerPromotion__r.StartDate__c, ReferrerPromotion__r.EndDate__c, ReferrerPromotion__r.PricingCode__r.Name FROM PayNowToken__c WHERE Name IN: tokens OR PaymentMethodId__c IN: paymentMethodIds]) {
            SageApiActivity__c activity = tokenOrPaymentActivityMap.get(token.Name);
            if (activity != null) {
                tokenActivityMap.put(token, activity);
                continue;
            }

            activity = tokenOrPaymentActivityMap.get(token.Quote_Payment_Method_ID__c);
            if (activity != null) {
                tokenActivityMap.put(token, activity);
                continue;
            }
        }
        return tokenActivityMap;
    }
*/
    public static Map<ID, ID> getZuoraSubscriptions(List<SageApiActivity__c> activities) {
        if (activities == null || activities.size() == 0) return null;
        Map<String, ID> zSubIdMap = new Map<String, ID>();
        Map<ID, ID> subIdMap = new Map<ID, ID>();

        for(SageApiActivity__c activity : activities) {
            string payload = activity.Payload__c;
            if (string.isBlank(payload)) continue;

            SageApiBuyNowActivityRequest req = null;
            try {
                req = (SageApiBuyNowActivityRequest)JSON.deserialize(payload, SageApiBuyNowActivityRequest.class);
                if (req == null || String.isBlank(req.zuoraSubscriptionId)) continue;

                zSubIdMap.put(req.zuoraSubscriptionId, activity.Id);
            } catch (Exception ex) {
                ExceptionHandler.CatchException('SageApiBuyNowActivityUtils', 'getZuoraSubscriptions', ex);
                return null;
            }
        }

        if (zSubIdMap.size() == 0) return null;
        List<Zuora__Subscription__c> subs = [SELECT ID, Zuora__Zuora_Id__c FROM Zuora__Subscription__c WHERE Zuora__Zuora_Id__c IN: zSubIdMap.keySet()];
        if (subs == null || subs.size() == 0) return subIdMap;

        for (Zuora__Subscription__c sub : subs) {
            ID activityId = zSubIdMap.get(sub.Zuora__Zuora_Id__c);
            if (String.isBlank(activityId)) continue;
            subIdMap.put(activityId, sub.Id);
        }
        return subIdMap;
    }

/*
    public static void updateActivities(SageApiActivityStep step, List<SageApiActivity__c> activities) {
        if (activities == null || activities.isEmpty() || step == null) return;
        for (SageApiActivity__c a : activities) {
            if (string.isBlank(a.ActivitySteps__c))
                continue;

            try {
                List<SageApiActivityStep> steps = (List<SageApiActivityStep>)JSON.deserialize(a.ActivitySteps__c, List<SageApiActivityStep>.class);
                if (Steps == null || steps.size() == 0)
                    continue;

                // get current processing stepStatus
                string stepStatus = null;
                string stepMessage = null;
                for (SageApiActivityStep s : steps)
                    if (s.StepID == step.StepID && s.ActionID == step.ActionID) {
                        stepStatus = s.StepStatus;
                        stepMessage = s.StepMessage;
                    }

                // no next action and current step status is processed
                if ((step.OnSuccessGotoSteps == null || step.OnSuccessGotoSteps.isEmpty()) && step.NextActionID == 0 &&  (stepStatus == SageApiStatus.Success || stepStatus == SageApiStatus.ManualInterventionRequired || stepStatus == SageApiStatus.Abandoned))
                    if (stepStatus == SageApiStatus.Success)
                        SageApiActivityUtils.setSuccess(a, step);
                    else if (stepStatus == SageApiStatus.ManualInterventionRequired || stepStatus == SageApiStatus.Abandoned) {
                        List<SageApiActivityError> errors = null;
                        if (String.isNotBlank(stepMessage))
                            errors = (List<SageApiActivityError>)JSON.deserialize(stepMessage, List<SageApiActivityError>.class);
                        SageApiActivityUtils.setError(a, step, stepStatus, errors);
                    }
            } catch (Exception e) {
                ExceptionHandler.CatchException('SageApiActivityUtils', 'getCompletedStep', e);
                List<SageApiActivityError> errors = new List<SageApiActivityError>();
                SageApiActivityUtils.addErrors(errors, SageApiActivityErrorCodes.UnhandledException, 'TryNowUpdateActivities', 'Error encountered when updating activity: ' + e);
                SageApiActivityUtils.setError(a, step, SageApiStatus.ManualInterventionRequired, errors);
            }

        }
        SageApiActivityUtils.updateActivities(activities);
    }
*/
    public static SageApiBuyNowActivityResponse createResponse() {
        SageApiBuyNowActivityResponse response = new SageApiBuyNowActivityResponse();
        response.data = new SageApiBuyNowActivityResponse.ResponseData();
        System.debug('createResponse: '+JSON.serialize(response));
        return response;
    }

    public static void updateArtifact(SageApiActivity__c activity, List<SageApiActivityError> errors) {
        SageApiBuyNowActivityResponse response = null;
        if (String.isNotBlank(activity.Artifacts__c))
            response = (SageApiBuyNowActivityResponse)JSON.deserialize(activity.Artifacts__c, SageApiBuyNowActivityResponse.class);
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
        response.data.subscriptionId = activity.ZuoraSubscriptionId__c;
        if (String.isNotBlank(activity.CommunityMembership__c))
            response.data.hasCommunityAccess = true;
        response.data.cbcSubscriptionId = activity.SubscriptionMaster__r.cbcSubscriptionId__c;
        if (activity.ActivityStatus__c == SageApiStatus.Success)
            response.errors = null;

        string artifact = JSON.serialize(response);
        if (artifact.length() > 131072)
            artifact = artifact.substring(0, 131060) + '.TRUNCATED.';
        activity.Artifacts__c = artifact;
        System.debug('activity.Artifacts__c: '+activity.Artifacts__c);
    }

    private class ProductTierSearchFilter {
        public String tierCode;
        public String tierRatePlanCode;
    }

}