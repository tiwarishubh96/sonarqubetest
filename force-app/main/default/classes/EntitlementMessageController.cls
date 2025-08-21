global with sharing class EntitlementMessageController implements Database.AllowsCallouts
{
    /*
    webService static String getEntitlement(String entitlementId) {
    	//if (String.isBlank(entitlementId)) 
    	//	return 'entitlementId is required';

    	HttpResponse httpRes = get(entitlementId);
    	System.debug(httpRes.getBody());
    	//EntitlementResponse res = (EntitlementResponse) JSON.deserialize(httpRes.getBody(), EntitlementResponse.class);
    	return httpRes.getBody();
    }
    */
   
    @InvocableMethod(label='Get entitlement detail of a subscription' description='Returns entitlement detail from entitlement service.')
    public static List<Response> getEntitlement(List<String> entitlementIds) {
        List<Response> res = new List<Response>();

        HttpResponse httpRes = get(entitlementIds[0]);
    	Integer statusCode = httpRes.getStatusCode();
    	String body = httpRes.getBody();
        system.debug('httpRes.getBody(): '+body);
        Response outRes = new Response();
    	if (statusCode == 200) {
	    	EntitlementResponse inRes = (EntitlementResponse) JSON.deserialize(body, EntitlementResponse.class);
	    	outRes.effectivePeriodFrom = String.valueOf(inRes.effectivePeriod.notBefore);
	    	outRes.effectivePeriodTo = String.valueOf(inRes.effectivePeriod.notAfter);
	    	outRes.isCancelled = inRes.isTerminated;
	    	outRes.isBlocked = false;
	    	outRes.isTrial = false;
	    	for (Product p : inRes.products) {
	    		if (String.isBlank(outRes.products))
	    			outRes.products = p.name;
	    		else
	    			outRes.products = outRes.products + '<br/>' + p.name;

	    		if (p.features == null || outRes.isTrial) continue;
	    		for (Feature f : p.features) {
	    			if (f.name != 'trial') continue;
	    			outRes.isTrial = true;
	    		}
	    	}
	    	if (inRes.blockInfo != null) {
	    		outRes.isBlocked = inRes.blockInfo.isBlocked;
	    		outRes.blockReason = inRes.blockInfo.blockedReason;
	    		outRes.blockMessage = inRes.blockInfo.blockedMessage;
	    	}
	    	system.debug('outRes: ' + JSON.serialize(outRes));
	    	res.add(outRes);
	        return res;
    	}

    	outRes.errorMsg = body.containsIgnoreCase('The state of the object') ? 'Entitlement has been updated already' : body;
        res.add(outRes);
        return res;
    }

    global class Response {
    	@InvocableVariable
    	global string id;
    	@InvocableVariable
    	global string principalID;
    	@InvocableVariable
		global String effectivePeriodFrom;
    	@InvocableVariable
		global String effectivePeriodTo;
    	@InvocableVariable
		global String products;
    	@InvocableVariable
    	global Boolean isTrial;
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

    class EntitlementResponse {
    	string id;
    	string principalID;
    	Boolean isTerminated;
		EffectivePeriod effectivePeriod;
		List<Product> products;
		BlockInfo blockInfo;
    }

    class EffectivePeriod {
    	Date notBefore;
    	Date notAfter;
    }

    class Product {
    	String name;
    	List<Feature> features;
    }

    class BlockInfo {
    	Boolean isBlocked;
    	String blockedReason;
    	String blockedMessage;
    }

    class Feature {
    	String name;
    }

    private static HttpResponse get(String cbcSubscriptionId) {
        String url = System.Label.ENT_API_LOCATION;
        System.debug('apiUrl: ' + url + ' X-cbcSubscriptionId: ' + cbcSubscriptionId);
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setHeader('Accept', 'application/json; charset=utf-8');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(url+'/entitlements/'+cbcSubscriptionId);
        req.setMethod('GET');
		if(entitlementSetting!=null && entitlementSetting.Username__c!=null) {
			Blob headerValue = Blob.valueOf(entitlementSetting.Username__c+':'+entitlementSetting.Key__c);
			String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
			system.debug(authorizationHeader);
			req.setHeader('Authorization', authorizationHeader);
		}

        try {
            if (Test.isRunningTest()) {
                Http h = new Http();
                return h.send(req);
            }

            return GenericUtilities.httpSend(req, 2*SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
        } catch(Exception e) {
            System.debug('slcsCallout error: '+ e);
            ExceptionHandler.CatchException('SlcsSalesAjaxController', 'createSubscription', e);
            throw e;
        }
    }

    // taken from EntitlementProcessorAsync.cls
    private static EntitlementSetting__c entitlementSetting {
        get {
			if (entitlementSetting != null)
				return entitlementSetting;

			string env = Test.isRunningTest() ? 'Preprod' : SageApiActivitySetting__c.getInstance('Environment_Entitlement').Value__c;
			for (EntitlementSetting__c entSetting : EntitlementSetting__c.getAll().values()) {
				if (Test.IsRunningTest()) {
					entitlementSetting = entSetting;
					break;
				}

				if (entSetting.Name == env) {
					entitlementSetting = entSetting;
					break;
				}
			}
			System.debug('-----entitlementSetting: '+entitlementSetting);
			return entitlementSetting;
        }set;
    }
}