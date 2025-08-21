global with sharing class SlcsEntitlementController implements Database.AllowsCallouts
{
    @InvocableMethod(label='Get SLCS entitlement detail of a subscription' description='Returns SLCS entitlement detail from SLCS service.')
    public static List<Response> getSlcsEntitlement(List<String> subscriptionIds) {
        if (subscriptionIds == null || subscriptionIds.isEmpty())
            return null;

        List<Response> res = new List<Response>();
        SageApiActivitySetting__c subscriptionPath = SageApiActivitySetting__c.getInstance(SageApiSubscriptionEventUtils.SUBSCRIPTION_PATH_KEY);
        HttpResponse subDetailsResp = SageApiSubscriptionEventUtils.doHttpCallout(subscriptionPath.Value__c +subscriptionIds[0], null);
        Integer statusCode = subDetailsResp.getStatusCode();
        SageApiActivityUtils.debug('~~~~~~~~~~~~~~~~~~~~~subDetailsResp status code: '+statusCode);

        //////TESTING//////
        //////String latestPayload = '{"subscriptionId": "7cd10dcd-d127-41ad-9b46-ff4061654184","subscriptionGroupId": "7cd10dcd-d127-41ad-9b46-ff4061654184","clientRef": "Ryan Ref","channelPlatform": "Tetris","channelPartner": "Bank of America","isTrial": true,"entitledAccount": {"id": "0011x00000TujWW"},"customerContact": {"id": "0031x00000Ndytn"},"managingAccount": {"id": "0011x00000TujWW"},"state": "Active","effectivePeriod": {"notBefore": "2019-08-16","notAfter": "2019-12-31"},"entitlement": {"entitlementId": "be26575e-d3f8-45ff-9652-ba6f667ef32e","products": [{"product": "SageOneStartGB","features": [{"name": "trial","properties": []}],"launchUrl": "some_launch_url"}]},"links": [{"service": "SubscriptionManagement","url": "https://website.co.uk/admin"}]}';

        Response outRes = new Response();
        if(statusCode != 200)
        {
            SageApiActivityUtils.debug('~~~~~~~~~~~~~~~~~~~~~Bad Response from SLCS2 subscriptions Endpoint: '+subDetailsResp);
            outRes.errorMsg = subDetailsResp.getStatus() + ': ' + subDetailsResp.getBody();
            res.add(outRes);
            return res;
        }

        String payloadString = subDetailsResp.getBody();
        SageApiActivityUtils.debug('~~~~~~~~~~~~~~~~~~~~~payloadString: '+ payloadString);

        SageApiActivityRequestObjects.SubscriptionAllData sub = (SageApiActivityRequestObjects.SubscriptionAllData) JSON.deserialize(payloadString, SageApiActivityRequestObjects.SubscriptionAllData.class);
        outRes.effectivePeriodFrom = String.valueOf(sub.effectivePeriod.notBefore);
        outRes.effectivePeriodTo = String.valueOf(sub.effectivePeriod.notAfter);
        outRes.isCancelled = sub.state != null && sub.state.equalsIgnoreCase(SageApiActivityRequestObjects.SubscriptionState.Deleted.name());
        outRes.isBlocked = sub.state != null && sub.state.equalsIgnoreCase(SageApiActivityRequestObjects.SubscriptionState.Suspended.name());
        outRes.isTrial = false;
        outRes.state = sub.state;
        if (sub.entitlement == null && sub.entitlement.products == null) {
            outRes.products = 'N/A';
            system.debug('outRes: ' + JSON.serialize(outRes));
            res.add(outRes);
            return res;
        }

        for (SageApiActivityRequestObjects.ProductResponse p : sub.entitlement.products) {
            if (String.isBlank(outRes.products))
                outRes.products = p.product;
            else
                outRes.products = outRes.products + '<br/>' + p.product;

            if (p.features == null) continue;
            for (SageApiActivityRequestObjects.Feature f : p.features) {
                if (f.name != 'trial') continue;
                outRes.products = outRes.products + ' (trial)';
                outRes.isTrial = true;
            }
        }

        if (outRes.isBlocked) {
            Map<String, Object> subDetailResults = (Map<String, Object>)JSON.deserializeUntyped(payloadString);
            List<Object> histories = (List<Object>) subDetailResults.get('history');
            String latestReasonPayload = null;
            Datetime latestCreatedUtc = Datetime.newInstance(2000, 1, 1);
            for (Object history : histories) {
                SageApiActivityUtils.debug('~~~~~~~~~~~~~~~~history: '+history);
                Map<String, Object> activity = (Map<String, Object>) history;
                String activityId = (String) activity.get('activityId');
                SageApiActivityUtils.debug('~~~~~~~~~~~~~~~~~~~~~activityId: '+activityId);

                String event = (String) activity.get('activityType');
                event = event.replace('.', '_');
                SageApiActivityUtils.debug('~~~~~~~~~~~~~~~event: '+event);
                if (!event.equalsIgnoreCase(SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Suspended.name()) && !event.equalsIgnoreCase(SageApiActivityRequestObjects.SubcriptionEvent.Subscription_Suspend.name()))
                    continue;

                String dt = (String) activity.get('createdUtc');
                dt = dt.replace('T',' ');
                Datetime createdUtc = Datetime.valueOfGMT(dt);
                System.debug('~~~~~~~~~~~~~~~~~~~~~createdUtc: '+createdUtc);
                if (createdUtc < latestCreatedUtc)
                    continue;

                latestCreatedUtc = createdUtc;
                latestReasonPayload = (String) activity.get('payload');
            }

            try {
                SageApiActivityRequestObjects.Reason reason = (SageApiActivityRequestObjects.Reason)JSON.deserialize(latestReasonPayload, SageApiActivityRequestObjects.Reason.class);
                outRes.blockReason = reason.reasonCode;
                outRes.blockMessage = reason.reasonDescription;
            } catch (Exception ex) {
                outRes.blockReason = 'N/A';
                outRes.blockMessage = latestReasonPayload;
            }
        }
        system.debug('outRes: ' + JSON.serialize(outRes));
        res.add(outRes);
        return res;
    }

    global class Response {
        @InvocableVariable
        global string id;
        @InvocableVariable
        global String effectivePeriodFrom;
        @InvocableVariable
        global String effectivePeriodTo;
        @InvocableVariable
        global String products;
        @InvocableVariable
        global Boolean isTrial;
        @InvocableVariable
        global String state;
        @InvocableVariable
        global Boolean isCancelled;
        @InvocableVariable
        global Boolean isBlocked;
        @InvocableVariable
        global String blockReason;
        @InvocableVariable
        global String blockMessage;
        @InvocableVariable
        global String errorMsg;
    }

}