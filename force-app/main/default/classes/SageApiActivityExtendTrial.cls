global with sharing class SageApiActivityExtendTrial {

    @InvocableMethod(label='Extend Trial' description='Extend trials created through Activity APIs')
    global static List<ExtendTrialResult> extendTrials(List<ExtendTrialRequest> requests) {
        List<ExtendTrialResult> results = new List<ExtendTrialResult>();
        if (requests== null || requests.isEmpty()) {
            ExtendTrialResult result = new ExtendTrialResult();
            result.success = false;
            result.message = 'Extend trial request is null';
            results.add(result);
            return results;
        }
        
        List<ID> subscriptionMasterIds = new List<ID>();
        Map<ID, Date> smDateMap = new Map<ID, Date>();
        for (ExtendTrialRequest r : requests)
            subscriptionMasterIds.add(r.subscriptionMasterId);
        List<Subscription_Master__c> sms = [SELECT id,name,Status__c,Entitlement_Id__c,End_Date__c,Start_Date__c,IsDeleted,Is_Blocked__c,Is_Cancelled__c,Product_Tier__r.Product_Tier_Code__c,Sage_API_Activity__r.ActivityType__c,Sage_API_Activity__r.PayNowToken__r.Name FROM Subscription_Master__c WHERE Id IN: subscriptionMasterIds];
        if (sms.isEmpty()) {
            ExtendTrialResult result = new ExtendTrialResult();
            result.success = false;
            result.message = 'Extend trial request does not contain valid subscription master id';
            results.add(result);
            return results;
        }
        for (ExtendTrialRequest r : requests) {
            Boolean found = false;
            for (Subscription_Master__c sm : sms)
                if (r.subscriptionMasterId == sm.Id) {
                    found = true;
                    break;
                }
            if (!found) {
                ExtendTrialResult result = new ExtendTrialResult();
                result.success = false;
                result.message = 'The requested subscription master ('+r.subscriptionMasterId+') cannot be found to extend trial';
                results.add(result);
            }
            if (r.expiryDate < date.today()) {
                ExtendTrialResult result = new ExtendTrialResult();
                result.success = false;
                result.message = 'The requested new expiry date ('+r.expiryDate+') for subscription master ('+r.subscriptionMasterId+') should be after today';
                results.add(result);
            }
            smDateMap.put(r.subscriptionMasterId, r.expiryDate);
        }
        if (!results.isEmpty())
            return results;
            
        updatePayNowPurchaseRequestCallout(JSON.serialize(sms), JSON.serialize(smDateMap));
        return results;
    }

    @Future(callout=true)
    private static void updatePayNowPurchaseRequestCallout(String smsString, String smsDateString) {
        List<Subscription_Master__c> sms = (List<Subscription_Master__c>)JSON.deserialize(smsString, List<Subscription_Master__c>.class);
        Map<ID, Date> smsDateMap = (Map<ID, Date>)JSON.deserialize(smsDateString, Map<ID, Date>.class);
        PayNowSetting__c pnBaseUrl = PayNowSetting__c.getInstance('payNowBaseUrl');
        PayNowSetting__c pnUserName = PayNowSetting__c.getInstance('payNowServiceUserName');
        PayNowSetting__c pnPassword = PayNowSetting__c.getInstance('payNowServicePassword');
        string payNowBaseUrl = pnBaseUrl.Value__c;
        string userName = pnUserName.Value__c;
        string password = pnPassword.Value__c;
        Blob headerValue = Blob.valueOf(userName + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        for (Subscription_Master__c sm : sms) {
            if (sm.Sage_API_Activity__r.ActivityType__c != SageApiActivityTriggerHandler.TryNowActivityType) continue;
    
            PurchaseRequestUpdatePayload payload = new PurchaseRequestUpdatePayload();
            payload.id = sm.Sage_API_Activity__r.PayNowToken__r.Name;
            payload.tierCode = sm.Product_Tier__r.Product_Tier_Code__c;
            payload.quoteExpirationUtcDatetime = String.valueOf(smsDateMap.get(sm.Id));
            if (string.isBlank(payload.id) || string.isBlank(payload.tierCode)) continue;
    
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(payNowBaseUrl + '/api/PurchaseRequest/Update');
            req.setMethod('POST');
            req.setBody(JSON.serialize(payload));
            
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            System.debug('payLoad ' + payload);
            System.debug('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
            Boolean success = false;
            Integer attempts = 0;
            Integer maxAttempts = 3;
            while (success == false && attempts < maxAttempts) {
                attempts++;
                try {
                    HttpResponse res = null;
                    if (Test.isRunningTest()) {
                        Http h = new Http();
                        res = h.send(req);
                    } else {
                        res = GenericUtilities.httpSend(req, SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
                    }
    
                    if (res.getStatusCode() == 200) success = true;
                    if (success == false && attempts == maxAttempts - 1) ExceptionHandler.CatchException('SageApiActivityExtendTrial', 'updatePayNowPurchaseRequestCallout', new CustomException('Callout failed with status: ' + res.getStatusCode() + ', message: ' + res.getStatus()));
                } catch(Exception e) {
                    System.debug('~~~~Exception: ' + e);
                    ExceptionHandler.CatchException('SageApiActivityExtendTrial', 'updatePayNowPurchaseRequestCallout', e);
                }
            }
        }
    }

    global class ExtendTrialRequest {
        @InvocableVariable
        global ID subscriptionMasterId;
        
        @InvocableVariable
        global Date expiryDate;
    }
    
    global class ExtendTrialResult {
        @InvocableVariable
        global Boolean success;
        
        @InvocableVariable
        global String message;
    }
    
    public class PurchaseRequestUpdatePayload {
        public string id;
        public string tierCode;
        public String quoteExpirationUtcDatetime;
    }
}