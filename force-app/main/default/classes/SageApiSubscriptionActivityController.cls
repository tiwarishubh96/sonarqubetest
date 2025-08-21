@RestResource(urlMapping='/SubscriptionActivity/*')
global with sharing class SageApiSubscriptionActivityController
{
    @HttpPost
    global static ResponseData createSubscrptionActivity(String event, SageApiActivity__c activity, String newSubscriptionGroupId) {
        resetActivityNotRequiredFields(activity);
        SageApiActivity__c a = activity;
        SageApiActivityUtils.debug('event: '+event);
        SageApiActivityUtils.debug('a: '+a);
        ResponseData res = new ResponseData();
        Datetime utcTime = Datetime.now();

        try {
            if (a == null || String.isBlank(a.ActivityID__c) || String.isBlank(a.ActivityType__c)) {
                res.setValidationError('Activity is not provided or invalid ActivityID/ActivityType');
                return res;
            }

            List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
            activities.add(a);
            Subscription_Master__c sm = null;
            SageApiActivityHandler handler = new SageApiActivityHandler(2, a.ActivityType__c, null, null, null);
            SageApiActivityStep step = handler.ActivitySteps[0];
            SageApiActivityStep lastStep = handler.ActivitySteps[handler.ActivitySteps.size()-1];

            String evtName = event.replace('.', '_');
            if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanFulfil.name() || evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.CreateSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                a.ActivityTypeVersion__c = 2;
                // when a.SubscriptionGroupId__c is null, validation will be performed later to make sure it is existing
                a.SubscriptionGroupId__c = (String.isBlank(newSubscriptionGroupId) ? null : newSubscriptionGroupId);

                SageApiSubscriptionActivityUtils.validateCreateSubscriptionV2Payload(step, activities, evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanFulfil.name(), evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name());
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Commit.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.CreateSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                if (String.isBlank(a.Id)) {
                    activities = [SELECT Id FROM SageApiActivity__c WHERE ActivityID__c=:a.ActivityID__c];
                    if (activities == null || activities.isEmpty()) {
                        res.setValidationError('Activity ' + a.ActivityID__c + ' is not valid');
                        return res;
                    }
                    activities = SageApiActivityUtils.refreshActivities(activities);
                    a = activities[0];
                    SageApiActivityUtils.debug('refreshed a: '+a);
                }
                a.Payload__c = activity.Payload__c;

                SageApiSubscriptionActivityUtils.CreateEntitlementDetail(handler.getNextStep(step), activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
                System.debug('a.SubscriptionMaster__c: '+a.SubscriptionMaster__c);

                SageApiSubscriptionActivityUtils.provisionUserV2(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Rollback.name() || evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Rollback.name()) {
                if ((evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Rollback.name() && a.ActivityType__c != SageApiActivityTriggerHandler.CreateSubscriptionActivityType) || (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Rollback.name() && a.ActivityType__c != SageApiActivityTriggerHandler.RegradeSubscriptionActivityType)) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                if (String.isBlank(a.Id)) {
                    activities = [SELECT Id FROM SageApiActivity__c WHERE ActivityID__c=:a.ActivityID__c];
                    if (activities == null || activities.isEmpty()) {
                        res.setValidationError('Activity ' + a.ActivityID__c + ' is not valid');
                        return res;
                    }
                    activities = SageApiActivityUtils.refreshActivities(activities);
                    a = activities[0];
                    SageApiActivityUtils.debug('refreshed a: '+a);
                }

                if (a.ActivityStatus__c == SageApiStatus.Success) {
                    res.setValidationError('The current activity status is Success and cannot be abandoned');
                    return res;
                }
                SageApiSubscriptionActivityUtils.abandon(step, activities);
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanRegrade.name() || evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.RegradeSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(step, activities, evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name());
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name()) {
                    sm = new Subscription_Master__c(id=a.SubscriptionMaster__c, IsPending__c=true, PendingEntitlementData__c=a.Payload__c);
                    update sm;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Commit.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.RegradeSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                if (String.isBlank(a.Id)) {
                    activities = [SELECT Id FROM SageApiActivity__c WHERE ActivityID__c=:a.ActivityID__c];
                    if (activities == null || activities.isEmpty()) {
                        res.setValidationError('Activity ' + a.ActivityID__c + ' is not valid');
                        return res;
                    }
                    activities = SageApiActivityUtils.refreshActivities(activities);
                    a = activities[0];
                    SageApiActivityUtils.debug('refreshed a: '+a);
                }
                a.Payload__c = activity.Payload__c;

                SageApiSubscriptionActivityUtils.validateRegradeSubscriptionPayload(step, activities, evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Commit.name());
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.RegradeEntitlementDetail(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Converted.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.ConvertSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateConvertSubscriptionPayload(step, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.convertEntitlementDetail(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Deleted.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.DeleteSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateDeleteSubscriptionPayload(step, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.deleteEntitlementDetail(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Suspended.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.SuspendSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateSuspendSubscriptionPayload(step, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.suspendEntitlementDetail(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Reactivated.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.ReactivateSubscriptionActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateReactivateSubscriptionPayload(step, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.reactivateEntitlementDetail(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            } else if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_EffectivePeriodUpdated.name()) {
                if (a.ActivityType__c != SageApiActivityTriggerHandler.UpdateSubscriptionEffectivePeriodActivityType) {
                    res.setValidationError('Event ' + event + ' is not applicable for a type ' + a.ActivityType__c);
                    return res;
                }

                SageApiSubscriptionActivityUtils.validateUpdateSubscriptionEffectivePeriodPayload(step, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setValidationError(parseError(a.Artifacts__c));
                    return res;
                }

                SageApiSubscriptionActivityUtils.updateSubscriptionEffectivePeriod(lastStep, activities);
                a = activities[0];
                if (hasError(a.ActivityStatus__c)) {
                    res.setError(parseError(a.Artifacts__c));
                    return res;
                }
            }

            SageApiActivityUtils.debug('hydrateResponse starts');
            hydrateResponse(evtName, res, a);

        } catch (Exception ex) {
            res.setError('Errors during processing: '+ex);
            ExceptionHandler.CatchException('SageApiSubscriptionActivityController', 'createSubscrptionActivity', new CustomException('Errors during processing: '+ex));
        }

        return res;
    }

    private static void hydrateResponse(String evtName, ResponseData res, SageApiActivity__c a) {
        SageApiActivityUtils.debug('hydrateResponse evtName: '+evtName);
        if (a == null) return;
        res.status = SageApiStatus.Success;
        res.activity = a;
        Subscription_Master__c sm = new Subscription_Master__c(id=a.SubscriptionMaster__c,External_Id__c=a.Account__c+':'+a.SubscriptionId__c);
        if (String.isNotBlank(sm.Id)) {
            sm = [select id,name,CbcSubscriptionId__c,SubscriptionGroupId__c,ClientRef__c,ChannelPartner__r.Name,ChannelPartner__r.ChannelPlatform__r.Name,Links__c,Account__c,Account__r.Id,Account__r.Name,Account__r.Phone,Account__r.BillingStreet,Account__r.BillingCity,Account__r.BillingState,Account__r.BillingStateCode,Account__r.BillingPostalCode,Account__r.BillingCountryCode,Account__r.Locale__r.Name,ManagingAccount__c,ManagingAccount__r.Id,ManagingAccount__r.Name,ManagingAccount__r.Phone,ManagingAccount__r.BillingStreet,ManagingAccount__r.BillingCity,ManagingAccount__r.BillingState,ManagingAccount__r.BillingStateCode,ManagingAccount__r.BillingPostalCode,ManagingAccount__r.BillingCountryCode,ManagingAccount__r.Locale__r.Name,Contact__c,Contact__r.Id,Contact__r.FirstName,Contact__r.LastName,Contact__r.Email,Contact__r.HomePhone,Contact__r.Phone,Contact__r.MobilePhone,Contact__r.MailingStreet,Contact__r.MailingCity,Contact__r.MailingState,Contact__r.MailingStateCode,Contact__r.MailingPostalCode,Contact__r.MailingCountryCode,Contact__r.Locale__r.Name,PartnerAccount__c,PartnerAccount__r.Id,PartnerAccount__r.Name,PartnerAccount__r.Phone,PartnerAccount__r.BillingStreet,PartnerAccount__r.BillingCity,PartnerAccount__r.BillingState,PartnerAccount__r.BillingStateCode,PartnerAccount__r.BillingPostalCode,PartnerAccount__r.BillingCountryCode,PartnerAccount__r.Locale__r.Name,PartnerContact__c,PartnerContact__r.Id,PartnerContact__r.FirstName,PartnerContact__r.LastName,PartnerContact__r.Email,PartnerContact__r.HomePhone,PartnerContact__r.Phone,PartnerContact__r.MobilePhone,PartnerContact__r.MailingStreet,PartnerContact__r.MailingCity,PartnerContact__r.MailingState,PartnerContact__r.MailingStateCode,PartnerContact__r.MailingPostalCode,PartnerContact__r.MailingCountryCode,PartnerContact__r.Locale__r.Name,SubscriptionState__c,Status__c,Entitlement_Id__c,End_Date__c,Start_Date__c,IsDeleted,Is_Blocked__c,Is_Cancelled__c,(select Id,Name,ProductFeatures__c,LaunchUrl__C from Entitled_Products__r),IsPending__c,PendingEntitlementData__c from Subscription_Master__c WHERE id=:sm.Id];
            res.subscriptionMaster = sm;

            if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanRegrade.name() || evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Regrade_Prepare.name())
                res.entitlementProducts = createMockedProducts(a);

            SageApiActivityUtils.debug('res.subscriptionMaster: '+JSON.serialize(res.subscriptionMaster));
            return;
        }

        if (evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_CanFulfil.name() || evtName == SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Fulfil_Prepare.name()) {
            res.entitlementProducts = createMockedProducts(a);
            SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(a.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
            sm = new Subscription_Master__c(id=a.SubscriptionMaster__c,External_Id__c=a.Account__c+':'+a.SubscriptionId__c,Sage_API_Activity__c=a.Id,CbcSubscriptionId__c=a.SubscriptionId__c,Entitlement_Id__c=a.EntitlementId__c,SubscriptionGroupId__c=a.SubscriptionGroupId__c,ClientRef__c=a.ClientRef__c,ChannelPartner__c=a.ChannelPartner__c,Status__c=req.isTrial?Constants.ASSET_STATUS_TRIAL:Constants.ASSET_STATUS_ACTIVE,SubscriptionState__c=req.state,Start_Date__c=Date.valueOf(req.effectivePeriod.notBefore),End_Date__c=Date.valueOf(req.effectivePeriod.notAfter),Links__c=JSON.serialize(req.links),IsPending__c=true,PendingEntitlementData__c=a.Payload__c);
        }

        sm.ChannelPartner__r = [SELECT Id,Name,ChannelPlatform__r.Name FROM ChannelPartner__c WHERE id=:a.ChannelPartner__c LIMIT 1];

        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account ac : [SELECT Id,Name,Phone,BillingStreet,BillingCity,BillingState,BillingStateCode,BillingPostalCode,BillingCountryCode,Locale__r.Name FROM Account WHERE Id=:a.Account__c OR Id=:a.ManagingAccount__c OR Id=:a.PartnerAccount__c])
            accountMap.put(ac.Id, ac);
        if (String.isNotBlank(a.Account__c)) {
            sm.Account__c = a.Account__c;
            sm.Account__r = accountMap.get(a.Account__c);
        }
        if (String.isNotBlank(a.ManagingAccount__c)) {
            sm.ManagingAccount__c = a.ManagingAccount__c;
            sm.ManagingAccount__r = accountMap.get(a.ManagingAccount__c);
        }
        if (String.isNotBlank(a.PartnerAccount__c)) {
            sm.PartnerAccount__c = a.PartnerAccount__c;
            sm.PartnerAccount__r = accountMap.get(a.PartnerAccount__c);
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Contact co : [SELECT Id,FirstName,LastName,Email,HomePhone,Phone,MobilePhone,MailingStreet,MailingCity,MailingState,MailingStateCode,MailingPostalCode,MailingCountryCode,Locale__r.Name FROM Contact WHERE Id=:a.Contact__c OR Id=:a.PartnerContact__c])
            contactMap.put(co.Id, co);
        if (String.isNotBlank(a.Contact__c)) {
            sm.Contact__c = a.Contact__c;
            sm.Contact__r = contactMap.get(a.Contact__c);
        }
        if (String.isNotBlank(a.PartnerContact__c)) {
            sm.PartnerContact__c = a.PartnerContact__c;
            sm.PartnerContact__r = contactMap.get(a.PartnerContact__c);
        }

        res.subscriptionMaster = sm;
        //read-only
        //sm.Entitled_Products__r = res.entitlementProducts;
    }

    private static List<EntitlementProduct__c> createMockedProducts(SageApiActivity__c a) {
        if (String.isBlank(a.payload__c)) return null;

        SageApiActivityRequestObjects.SubscriptionAllData req = (SageApiActivityRequestObjects.SubscriptionAllData)JSON.deserialize(a.payload__c, SageApiActivityRequestObjects.SubscriptionAllData.class);
        List<EntitlementProduct__c> products = new List<EntitlementProduct__c>();
        for (SageApiActivityRequestObjects.ProductRequest prod: req.products)
            products.add(new EntitlementProduct__c(name=prod.product,ProductFeatures__c=JSON.serialize(prod.features)));
        return products;
    }

    private static String parseError(String serializedActivityResponse) {
        if (String.isBlank(serializedActivityResponse)) return 'No error detail';
        try {
            SageApiBuyNowActivityResponse response = (SageApiBuyNowActivityResponse)JSON.deserialize(serializedActivityResponse, SageApiBuyNowActivityResponse.class);
            return JSON.serialize(response.errors, true);
        } catch (Exception ex) {
            return serializedActivityResponse;
        }
    }

/*
    private static ResponseData validateActivity(List<SageApiActivity__c> activities) {
        SageApiActivity__c a = activities[0];
        ResponseData res = new ResponseData(a);
        if (String.isNotBlank(a.Id)) return res;

        activities = [SELECT Id FROM SageApiActivity__c WHERE ActivityID__c=:a.ActivityID__c];
        if (activities == null || activities.isEmpty()) {
            res.setValidationError('Activity ' + a.ActivityID__c + ' is not valid');
            return res;
        }
        activities = SageApiActivityUtils.refreshActivities(activities);
        res.activity = activities[0];
        SageApiActivityUtils.debug('refreshed activities: '+res.activity);
        return res;
    }
*/
    private static Boolean hasError(String status) {
        return (status == SageApiStatus.ManualInterventionRequired || status == SageApiStatus.ValidationErrors);
    }

    private static void resetActivityNotRequiredFields(SageApiActivity__c activity) {
        activity.Account__c = null;
        activity.ManagingAccount__c = null;
        activity.Contact__c = null;
        activity.PartnerAccount__c = null;
        activity.PartnerContact__c = null;
    }

    global class ResponseData {
        public String status;
        public String message;
        public SageApiActivity__c activity;
        public Subscription_Master__c subscriptionMaster;
        public List<EntitlementProduct__c> entitlementProducts;

        public ResponseData() {
            this.status = SageApiStatus.Success;
        }
/*
        public ResponseData(SageApiActivity__c activity) {
            this.status = SageApiStatus.Success;
            this.activity = activity;
        }
*/
        public void setValidationError(String msg) {
            setError(SageApiStatus.ValidationErrors, msg);
        }

        public void setError(String msg) {
            setError(SageApiStatus.ManualInterventionRequired, msg);
        }

        public void setError(String errorType, String msg) {
            this.status = errorType;
            this.message = msg;
        }
    }
}