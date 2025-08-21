/**
 * Entitlement message processor 
 * - Entitlement message record requests sent to Entitlement and responses stored on message. US-45889
 *
 * @author		Arturs Gusjko, Richard Wintle
 */
public with sharing class EntitlementProcessorAsync implements Queueable, Database.AllowsCallouts
{
	// Messages remaining to process
    private List<String> entMsgIdList { get; set; }
    // 
    // Entitlement REST API endpoint e.g. 'https://entitlement-preview.sso.sagessdp.co.uk/v1'
    private static final String ENTITLEMENT_PATH=System.Label.ENT_API_LOCATION;
    //
    // maximum messages to be processed per queue
    public static final Integer ENT_MESSAGE_MAX_PER_QUEUE=4;	
    
	/**
     * Entitlement asynchronous queued processor of messages
     * @param list of message Ids to process
    **/
	public EntitlementProcessorAsync(List<String> entMsgIdList)
	{
		this.entMsgIdList = entMsgIdList;
	}
	/**
     * Execute queued job
     * @param job context
    **/
    public void execute(QueueableContext context)
    {
        List<String> itemsForNextJob = process();
        if( !itemsForNextJob.isEmpty() ) enqueueNewJob(itemsForNextJob);
    }
	/**
     * Queue next set of messages
     * @param list of remaining message Ids to process
    **/
    @future(callout=true)
    static public void enqueueNewJob(List<String> items)
    {   
        List<String> itemsForNextJob = new EntitlementProcessorAsync(items).process();
        if( !itemsForNextJob.isEmpty() ) System.enqueueJob(new EntitlementProcessorAsync(itemsForNextJob));
    }
	/**
     * Entitlement callout request of messages. Number per queue determined by defined by ENT_MESSAGE_MAX_PER_QUEUE
     * @return list of message Ids still to process
    **/
    public List<String> process()
    {
    	Map<String, String> errorMessageMap = new Map<String, String>();	// error message store
    	List<Entitlement_Message__c> updateMessageList=new List<Entitlement_Message__c>();	// messages to update after processing
    	//
    	// Fetch messages required for processing
    	system.debug('***entMsgIdList:'+entMsgIdList);
    	Set<String> entMsgIdSet=new Set<String>(entMsgIdList);
    	List<Entitlement_Message__c> entMsgList=[select Id, URL__c, Message__c, Message_Response__c, Error_Message__c, 
    					Entitlement_Message_Definition__r.URL__c,Entitlement_Message_Definition__r.Method__c, 
                        Subscription_Master__r.Sage_API_Activity__c, Subscription_Master__r.Sage_API_Activity__r.ActivityId__c
            		from Entitlement_Message__c where id IN: entMsgIdSet];
        system.debug('***entMsgList:'+entMsgList);
        
        // Shekhar: added for TryNow/BuyNow Replay
        Map<Id, ActivityStatus> statusOfActivities = new Map<Id, ActivityStatus>();
        
        for(Integer i = 0; i < Math.min(entMsgList.size(), ENT_MESSAGE_MAX_PER_QUEUE); i++)
        {
            String httpMethod;
            
        	try {
	        	// set request endpoint
	        	String reqEndpoint=ENTITLEMENT_PATH;
	        	if(entMsgList[i].URL__c!=null) {
	        		reqEndpoint=reqEndpoint+entMsgList[i].URL__c;
	        	}
	        	// set request method - GET, POST, PUT, DELETE etc.
	        	httpMethod=entMsgList[i].Entitlement_Message_Definition__r.Method__c;
	        	httpMethod=httpMethod.toUppercase().trim();
	        	system.debug('***httpMethod:['+httpMethod+']');
	        	//
	        	// Build http request
	            HttpRequest req = new HttpRequest();
	            req.setHeader('Accept', 'application/json; charset=utf-8');
                req.setHeader('Content-Type','application/json');
                
                // Shekhar: Added for Idempotency
                if (httpMethod == 'POST' || httpMethod == 'PUT') {
                    if (entMsgList[i].Subscription_Master__r != null) {
                        if (entMsgList[i].Subscription_Master__r.Sage_API_Activity__r != null) {
                            //System.debug('******Setting header X-Idempotency-Token' + entMsgList[i].Subscription_Master__r.Sage_API_Activity__r.ActivityId__c);
                        	req.setHeader('X-Idempotency-Token', entMsgList[i].Subscription_Master__r.Sage_API_Activity__r.ActivityId__c);    
                        }
                    }
                }
                
	            req.setEndpoint(reqEndpoint);
	            req.setMethod(httpMethod);
				//
				// set message in request body
	            if (entMsgList[i].Message__c != null) {
	            	String contentMessage=entMsgList[i].Message__c;
					req.setBody(contentMessage);
				}
	            //
				// set login credentials using Basic auth
				if(entitlementSetting!=null && entitlementSetting.Username__c!=null) {
					Blob headerValue = Blob.valueOf(entitlementSetting.Username__c+':'+entitlementSetting.Key__c);
					String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
					system.debug(authorizationHeader);
					req.setHeader('Authorization', authorizationHeader);
				}
	        	//
	        	// Callout to Entitlment engine with API REST request
	        	system.debug(LoggingLevel.INFO,'**http request:'+req);

                HttpResponse res = null;
                if (Test.isRunningTest()) {
                    Http h = new Http();
                    res = h.send(req);
                } else {
                    res = GenericUtilities.httpSend(req, SageApiActivityUtils.setting_HttpCalloutDefaultTimeoutInSeconds, SageApiActivityUtils.setting_HttpCalloutDefaultMaxRetries);
                }

	            system.debug(LoggingLevel.INFO,entMsgList[i].Id + ': ' + res.getBody());
	            //
	            // parse header information
	            String hdrMsgs=httpHeaders(res);
	            system.debug(LoggingLevel.INFO,'hdrMsgs: ' + hdrMsgs);
	            //
	            // Process acceptable status codes
	            if(res.getStatusCode()==200 || res.getStatusCode()==201) {
	            	//
	            	// Success
	            	system.debug(LoggingLevel.INFO,'Success. Response body: ' + res.getBody());
	                entMsgList[i].Message_Response__c=res.getBody();
	                entMsgList[i].Status__c='Processed';
	                entMsgList[i].Error_Message__c='';
                    // Shekhar: Added for TryNow/BuyNow Replay
                    if (httpMethod == 'POST' || httpMethod == 'PUT') {
                        if (entMsgList[i].Subscription_Master__r != null) {
                            if (entMsgList[i].Subscription_Master__r.Sage_API_Activity__c != null) {
                            	statusOfActivities.put(entMsgList[i].Subscription_Master__r.Sage_API_Activity__c, new ActivityStatus(entMsgList[i].Id, 'Success', null));
                            }
                        }
                    }
	            } else if(res.getStatusCode()==204) {
	            	//
	            	// Success 204. e.g. DELETE has no response
	            	system.debug(LoggingLevel.INFO, 'Success 204. hdrMsgs: ' + hdrMsgs);
	            	entMsgList[i].Status__c='Processed';
	            	entMsgList[i].Error_Message__c='';
                    // Shekhar: Added for TryNow/BuyNow Replay
                    if (httpMethod == 'POST' || httpMethod == 'PUT') {
                        if (entMsgList[i].Subscription_Master__r != null) {
                            if (entMsgList[i].Subscription_Master__r.Sage_API_Activity__c != null) {
                            	statusOfActivities.put(entMsgList[i].Subscription_Master__r.Sage_API_Activity__c, new ActivityStatus(entMsgList[i].Id, 'Success', ''));
                            }
                        }
                    }
	            }else{
	            	// HTTP Error
	            	system.debug(LoggingLevel.ERROR, 'ERROR: hdrMsgs: ' + hdrMsgs);
	                entMsgList[i].Error_Message__c='HTTP request failed:'+res.getStatusCode()+' | ResponseHeaders:'+hdrMsgs;
	                entMsgList[i].Status__c='Error';
                    // Shekhar: Added for TryNow/BuyNow Replay
                    if (httpMethod == 'POST' || httpMethod == 'PUT') {
                        if (entMsgList[i].Subscription_Master__r != null) {
                            if (entMsgList[i].Subscription_Master__r.Sage_API_Activity__c != null) {
                            	statusOfActivities.put(entMsgList[i].Subscription_Master__r.Sage_API_Activity__c, new ActivityStatus(entMsgList[i].Id, 'Error', entMsgList[i].Error_Message__c));    
                            }
                        }
                    }
	            }
            }catch(exception e) {
            	//
            	// catch message error for message record update and logging
	            System.debug( LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString() );
	            errorMessageMap.put(entMsgList[i].Id, e.getMessage() + '|StackTrace:' + e.getStackTraceString());
	            entMsgList[i].Error_Message__c=e.getMessage() + '|StackTrace:' + e.getStackTraceString();
	            entMsgList[i].Status__c='Error';
                if (httpMethod == 'POST' || httpMethod == 'PUT') {
                    if (entMsgList[i].Subscription_Master__r != null) {
                        if (entMsgList[i].Subscription_Master__r.Sage_API_Activity__c != null) {
                        	statusOfActivities.put(entMsgList[i].Subscription_Master__r.Sage_API_Activity__c, new ActivityStatus(entMsgList[i].Id, 'Error', entMsgList[i].Error_Message__c));
                        }
                    }
                }
	        }
	        //
	        // add to update list
	        entMsgList[i].Error_Message__c = JSON.serialize(statusOfActivities);
        	updateMessageList.add(entMsgList[i]);
        }
        //
        // update message records (trigger to process responses as required)
		if(updateMessageList.size()>0) {
			update updateMessageList;
		}
        
        System.debug('****** statusOfActivities ' + statusOfActivities);
                     
        // Shekhar: Added for TryNow/BuyNow replay
        if (statusOfActivities.keySet().size() > 0) {
            List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
            List<SageApiActivity__c> activitiesToUpdate = new List<SageApiActivity__c>();
            for (ID id : statusOfActivities.KeySet())
                activities.add(new SageApiActivity__c(Id = id));

            activities = SageApiActivityUtils.refreshActivities(activities);
            System.debug('****** statusOfActivities activities ' + activities);
            for (SageApiActivity__c activity : activities) {
                if (activity.ActivityStatus__c!=SageApiStatus.Success && activity.SubscriptionMaster__r.EnableInsertTrigger__c && statusOfActivities.containsKey(activity.Id)) {
                    System.debug('****** Setting Entitlement Message Id ' + activities);
                    activity.Entitlement_Message__c = statusOfActivities.get(activity.Id).entitlementMessageId;
                    SageApiActivityStep step = (SageApiActivityStep) JSON.deserialize(activity.Step_Serialised__c, SageApiActivityStep.class);
                    if (statusOfActivities.get(activity.Id).status == 'Success') {
                        SageApiActivityUtils.setSuccess(activity, step);
                    } else {
                        List<SageApiActivityError> errors = SageApiActivityUtils.updateActivityWithException(activity, step, false, 'SageApiTryNowActivityStepUpsertSM', 'Entitlement Sending failed. More detail: ' + statusOfActivities.get(activity.Id).errorMessage);
                    	SageApiActivityUtils.setError(activity, step, SageApiStatus.ManualInterventionRequired, errors);
                    }
                    activitiesToUpdate.add(activity);
                }
            }
            
            SageApiActivityUtils.updateActivities(activitiesToUpdate);
        }
        
		// log any error messages
		if(errorMessageMap.keySet().size() > 0) {
            ExceptionHandler.logZuoraRecordProcessingErrors('EntitlementProcessorAsync', 'process', errorMessageMap);
        }
        //
        // return any further messages for next job processing
        List<String> itemsForNextJob = new List<String>();
        if(entMsgIdList.size() > ENT_MESSAGE_MAX_PER_QUEUE) {
            for(Integer i = ENT_MESSAGE_MAX_PER_QUEUE; i < entMsgIdList.size(); i++) {
                itemsForNextJob.add(entMsgIdList[i]);
            }
        }
        
        return itemsForNextJob;
    }
    /**
     * Helper method to format response headers into a message
     * @param pRes response from http callout
     * @return message string of name:value comma separated items
    **/
    public String httpHeaders(HTTPResponse pRes) {
        String msg = '';
        for(String key : pRes.getHeaderKeys()) {
            if(key!=null && key!='') {
                msg += key + ': '+ pRes.getHeader(key)+', ';
            }
        }
        msg += pRes.getBody();
        System.Debug('*** response headers::'+msg);
        return msg;
    }
    /** 
    * Entitlement custom setting for the required Entitlement location
    **/
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
    
    public class ActivityStatus {
        public String status;
        public String errorMessage;
        public Id entitlementMessageId;
        
        public ActivityStatus(Id entitlementMessageId, String status, String errorMessage) {
            this.entitlementMessageId = entitlementMessageId;
            this.status = status;
            this.errorMessage = errorMessage;
        }
    }
}