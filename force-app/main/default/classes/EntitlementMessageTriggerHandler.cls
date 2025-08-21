/**
 * Trigger handler for Entitlement Messages. 
 *
 * Functions:-
 * 1. Entitlement system request and response processing. US-45889
 *
 * @author		Arturs Gusjko, Richard Wintle
 */
public class EntitlementMessageTriggerHandler {
    
    public class EntitlementException extends Exception {}
    
    
    public static Map<String, String> errorMessageMap; // error message store
    
    public static void beforeInsert(List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> newMap) {	
    }
    
    public static void afterInsert(List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> newMap) {  
    	errorMessageMap = new Map<String, String>();
    	//
        // entitlement request processing
        entitlementRequestProcessing(newList, null);
    }
    
    public static void beforeUpdate(List<Entitlement_Message__c> oldList, Map<Id, Entitlement_Message__c> oldMap, List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> newMap) {
    	errorMessageMap = new Map<String, String>();
        //
    	// entitlement response processing
    	entitlementResponseProcessing(newList, oldMap);
    }
    
    public static void afterUpdate(List<Entitlement_Message__c> oldList, Map<Id, Entitlement_Message__c> oldMap, List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> newMap) {
        errorMessageMap = new Map<String, String>();
    	//
        // entitlement request processing
        entitlementRequestProcessing(newList, oldMap);
    }
    
    public static void afterDelete(List<Entitlement_Message__c> oldList, Map<Id, Entitlement_Message__c> oldMap) {
    }
    
    /**
    * Entitlement response processing.
    * @param newList from trigger
    * @param oldMap from trigger
    **/
    public static void entitlementResponseProcessing(List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> oldMap) {
    	List<Entitlement_Message__c> entMsgResponseList=new List<Entitlement_Message__c>();
    	//
        // process if status was updated to Processed
        for(Entitlement_Message__c newMsg :newList) {
            Entitlement_Message__c oldMsg = oldMap.get(newMsg.Id);
            if(newMsg.Status__c=='Processed' && oldMsg.Status__c!='Processed' && newMsg.Message_Response__c!=null) {
                entMsgResponseList.add(newMsg);
            }
        }
        if(entMsgResponseList.size()>0)
            responseEntitlementMessages(entMsgResponseList);
    }
    
    public static boolean EntitlementRequestFirstRun=true;
    /**
    * Entitlement request processing.
    * @param newList from trigger
    * @param oldMap from trigger, null for insert trigger
    **/
    public static void entitlementRequestProcessing(List<Entitlement_Message__c> newList, Map<Id, Entitlement_Message__c> oldMap) {
    	// ensure just runs once
        if (!EntitlementRequestFirstRun)
        	return;
        
    	List<Entitlement_Message__c> entMsgProcessList=new List<Entitlement_Message__c>();
    	//
    	// process if status was updated to New
        for(Entitlement_Message__c newMsg :newList) {
        	if(oldMap==null) {
        		// inserts
        		if(newMsg.Status__c=='New') {// && newMsg.Entitlement_Message_Definition__c!=null) {
	                entMsgProcessList.add(newMsg); 
	            }
        	} else {
        		// updates
        		Entitlement_Message__c oldMsg = oldMap.get(newMsg.Id);
        		if(newMsg.Status__c=='New' && oldMsg.Status__c!='New') {// && newMsg.Entitlement_Message_Definition__c!=null) {
	                entMsgProcessList.add(newMsg);
	            }
        	} 
        }
        if(entMsgProcessList.size()>0)
            processEntitlementMessages(entMsgProcessList);     
    }
    /**
    * Entitlement response processing. 
    * @param entMsgProcessList - messages to process
    **/ 
    public static void responseEntitlementMessages(List<Entitlement_Message__c> entMsgResponseList) {
    	//
    	List<Subscription_Master__c> subscriptionMasterUpdateList=new List<Subscription_Master__c>(); // subscriptionMasters to update
    	Map<Id, List<Entitlement_Message__c>> subscriptionMasterToMessageMap = new Map<Id, List<Entitlement_Message__c>>();
    	//
    	for(Entitlement_Message__c msg : entMsgResponseList) {
    		try {
    			// parse response to map
	    		Map<String, Object> respParsed;
	    		String response=msg.Message_Response__c;
            	respParsed= (Map<String, Object>) JSON.deserializeUntyped(response); 
            	//
            	// process entitlementId   
            	String entId=(String)respParsed.get('id');  
            	if(entId!=null && entId!='') {
            		if(msg.Subscription_Master__c==null) 
            			throw new EntitlementException('Subscription Master record not found for message:'+msg.Id);
            		//
            		// store Subscription Master-to-message item for reference
            		List<Entitlement_Message__c> msgList=subscriptionMasterToMessageMap.get(msg.Subscription_Master__c);
            		if(msgList==null) msgList=new List<Entitlement_Message__c>();
            		msgList.add(msg);
            		subscriptionMasterToMessageMap.put(msg.Subscription_Master__c, msgList);
            		//
            		// set Subscription Master update record
            		subscriptionMasterUpdateList.add(new Subscription_Master__c(Id=msg.Subscription_Master__c, Entitlement_Id__c=entId));
            	}        
	        } catch(Exception e) {                  
	            System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString() );
	            msg.Status__c='Error';
                msg.Error_Message__c=e.getMessage() + '|StackTrace:' + e.getStackTraceString();
	            errorMessageMap.put(msg.Id, e.getMessage() + '|StackTrace:' + e.getStackTraceString() );
	        }
    	}
    	//
    	// update entitlements
    	if(subscriptionMasterUpdateList.size()>0) {
    		Database.SaveResult[] srs = Database.update (subscriptionMasterUpdateList, false);
            for (Integer i = 0; i < subscriptionMasterUpdateList.size(); i++) {
            	//
                // check for errors
                Database.SaveResult sr = srs[i];
                if (!sr.isSuccess()) {
					String errorMsg=sr.getErrors()[0].getMessage();
					//
					// set messages for this entitlement to errored
                    for(Entitlement_Message__c msg : subscriptionMasterToMessageMap.get(subscriptionMasterUpdateList.get(i).Id)) {
                    	System.debug(LoggingLevel.ERROR, errorMsg );
                    	msg.Status__c='Error';
                    	msg.Error_Message__c=errorMsg;
			            errorMessageMap.put(msg.Id, errorMsg);
                    }
                }
            }
        }
        //
    	// log any error messages and fail the message record
    	flushErrorMessages('responseEntitlementMessages');
    }
    
    /**
    * Entitlement request processing. Sets message status to Processing when request made to Entitlement system.
    * @param entMsgProcessList - messages to process
    **/
    public static void processEntitlementMessages(List<Entitlement_Message__c> entMsgProcessList) {	
        // These messages are now considered valid for Entitlement processing, so at this point 
        // ensure they are not processed again in this context.
        EntitlementRequestFirstRun = false;	
    	//
    	// message to update after processing
    	List<Entitlement_Message__c> updateMessageList=new List<Entitlement_Message__c>();
    	Map<Id, Entitlement_Message__c> definitionToMessageMap = new Map<Id, Entitlement_Message__c>();
        //
        // build SOQL fields to query from all referenced message parameters
        Set<String> queryFieldSet=new Set<String>();
        //
        // obtain message formats from all messages to process
        Set<Id> entMsgDefIdSet=new Set<Id>();
        for(Entitlement_Message__c entMsg : entMsgProcessList) {
        	try {
        		if(entMsg.Entitlement_Message_Definition__c==null)
	        		throw new EntitlementException('Entitlement Defintion record not found for message:'+entMsg.Id);
	        	//
				entMsgDefIdSet.add(entMsg.Entitlement_Message_Definition__c);
				//
	    		// store entitlement definition ref to message map
	    		definitionToMessageMap.put(entMsg.Entitlement_Message_Definition__c, entMsg);
	    		updateMessageList.add(entMsg);
    		} catch(Exception e) {                  
	            System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString() );
	            errorMessageMap.put(entMsg.Id, e.getMessage()+ '|StackTrace:' + e.getStackTraceString());
	        }
        }
        //
        try {
	        //
	        // Load definition record and collect all paramter fields, if any.
	        for(Entitlement_Message_Definition__c msgDefn : [select Id, Message_Format__c, URL__c from Entitlement_Message_Definition__c
	                                                         where Id IN:entMsgDefIdSet]) {
				// parse each message format into field set of all required fields
				queryFieldSet.addAll(parseForMessageFields(msgDefn.Message_Format__c));
				queryFieldSet.addAll(parseForMessageFields(msgDefn.URL__c)); 
	        }
	        //
	        // query for all parameter values of all messages.
	        Set<Id> msgIdSet=(new Map<Id,SObject>(updateMessageList)).keySet();	// all Id from message list
	        String fieldQuery='';
	        if(queryFieldSet.size()>0) fieldQuery=buildFieldSOQL(queryFieldSet);
	        //
	        String msgQuery='select Id, Message__c, URL__c, Entitlement_Message_Definition__r.Message_Format__c, Entitlement_Message_Definition__r.URL__c'+fieldQuery+
	            		' from Entitlement_Message__c where id IN: msgIdSet';
	        system.debug('***msgQuery:'+msgQuery);
	        List<Entitlement_Message__c>  messageValueList=(List<Entitlement_Message__c>)Database.query(msgQuery);
			//
	        // process the message definitions to replace parameters with values
	        List<Entitlement_Message__c> msgProcessingList=new List<Entitlement_Message__c>();
	        for(Entitlement_Message__c msg : messageValueList) {
	        	try {
		        	//
		        	// Compile message - replacing paramters with record values
					String expandedMessage=expandMessage(msg.Entitlement_Message_Definition__r.Message_Format__c, msg, false);
					String expandedURL=expandMessage(msg.Entitlement_Message_Definition__r.URL__c, msg, true);
					//
					// set message with results
		            msg.Message__c=expandedMessage;
		            msg.URL__c=expandedURL;
		            msg.Status__c='Processing';
		            msg.Error_Message__c='';
		            msgProcessingList.add(msg);
		            //
	            } catch(Exception e) {                  
		            System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString() );
		            errorMessageMap.put(msg.Id, e.getMessage()+ '|StackTrace:' + e.getStackTraceString());
		        }
	        }
	        flushErrorMessages('processEntitlementMessages');
	        if(msgProcessingList.size()>0) {
	        	//
	        	// Update compiled messages to Processing status
	        	List<String> messagesIdList=updateCompiledMessages(msgProcessingList);
	        	//
	        	// If updated - send messages to Entitlement Engine
	            if(messagesIdList.size()>0) {
	            	sendEntitlementProcessor(messagesIdList);
	            }
	        }
        }catch(Exception e) {
        	// whole batch fail - mark every message as failed
        	System.debug(LoggingLevel.ERROR, e.getMessage() + '\n' + e.getStackTraceString() );
        	for(Entitlement_Message__c msg : updateMessageList) {
        		errorMessageMap.put(msg.Id, e.getMessage()+ '|StackTrace:' + e.getStackTraceString());
        	}
        }
        //
    	// log any error messages and fail the message record
    	flushErrorMessages('processEntitlementMessages');
    }
    /**
    * Update message to Salesforce
    * @param msgProcessingList - messages to update
    * @return message IDs
    **/
    public static List<String> updateCompiledMessages(List<Entitlement_Message__c> msgProcessingList) {
        //
        // Update compiled messages to Processing status
        List<String> messagesIdList=new List<String>();		// list for async processing
        Database.SaveResult[] srs = Database.update(msgProcessingList, false);
        for (Integer i = 0; i < msgProcessingList.size(); i++) {
            // check for errors
            Database.SaveResult sr = srs[i];
            if (!sr.isSuccess()) {
				String errorMsg=sr.getErrors()[0].getMessage();
            	System.debug(LoggingLevel.ERROR, errorMsg );
	            errorMessageMap.put(msgProcessingList.get(i).Id, errorMsg);
            } else {
            	messagesIdList.add(msgProcessingList.get(i).Id);
            }
        }
        return messagesIdList;
    }
    /**
    * Send message IDs for Entitlement Engine processing
    * @param messageIdList - message IDs
    **/
    public static void sendEntitlementProcessor(List<String> messagesIdList) {
    	if(System.isQueueable()) {
        	// already in queueable process so call the future method
        	EntitlementProcessorAsync.enqueueNewJob(messagesIdList); 
        }else{
        	// update via async queueable job
        	System.enqueueJob(new EntitlementProcessorAsync(messagesIdList));
        }
    }
    /**
    * Process all error reported - log and update Entitlement Message records
    * @param methodName - name of method to record in Logger record
    **/
    public static void flushErrorMessages(String methodName) {
    	if(errorMessageMap.keySet().size() > 0) {
    		List<Entitlement_Message__c> updateErrorMessageList=new List<Entitlement_Message__c>();
    		//
    		if(!Trigger.isBefore) {	// cannot do recursive update in before trigger
				for(String msgId : errorMessageMap.keySet()) {
					String errorMsg=errorMessageMap.get(msgId);
					updateErrorMessageList.add(new Entitlement_Message__c(Id=msgId, Status__c='Error', Error_Message__c=errorMsg));
				}
    		}
            ExceptionHandler.logZuoraRecordProcessingErrors('EntitlementMessageTriggerHandler', methodName, errorMessageMap);
            //
            if(updateErrorMessageList.size()>0)
				update updateErrorMessageList;
			//
			// reset the error map
			errorMessageMap = new Map<String, String>();
        } 
    }
    /**
    * Parse a message to set of field parameters
    * @param msgFormat - message format to be parsed.
    * @return field names to be queried.
    **/
    private static Set<String> parseForMessageFields(String msgFormat) {
        // init return set
        Set<String> fieldNameSet=new Set<String>();
        //
        if(msgFormat!=null) {
	        //
	        // set pattern match to find tokens
	        Pattern MyPattern = Pattern.compile('\\{!.*?\\}');
			Matcher myMatcher = MyPattern.matcher(msgFormat);
			//
			// process tokens found
			while (myMatcher.find())
			{
				// token string
			    String tokenPlaceholder = myMatcher.group();
			    // obtain field
			    String fieldName=tokenPlaceholder.removeStart('{!').removeEnd('}').trim();
			    system.debug('***'+fieldName+'***');
			    //
			    // add to set
			    fieldNameSet.add(fieldName);
			}
        }
		System.debug( LoggingLevel.DEBUG, '**fieldNameSet:' + fieldNameSet);
        return fieldNameSet; 
    }
    /**
    * Build comma separated fields ready for SOQL
    * @param queryFieldSet - field names to be queried
    * @return comma separated fields
    **/
    private static String buildFieldSOQL(Set<String> queryFieldSet) {
        // process field set and build comma separated string
        String queryFlds='';
        for(String fld : queryFieldSet) {
        	queryFlds+=', '+fld;
        }
        //queryFlds=queryFlds.removeEnd(',');
        return queryFlds;
    }
    /**
    * Compile message format to message by replacing tokens with field values
    * @param msgFormat - message format from definition
    * @param messageRecord - message record holding parameter values, e.g. Param_Account_Principal_Id__c
    * @param encodeFields - url encode fields, if output is required for a URL.
    * @return compiled message for message record.
    **/
    private static String expandMessage(String msgFormat, Entitlement_Message__c messageRecord, boolean urlEncodeFields) {
        // 
        String compiledMessage='';
        if(msgFormat!=null) {
        	compiledMessage=msgFormat;	// copy message definition
	        //
	        // pattern match to obtain all tokens
	        Pattern MyPattern = Pattern.compile('\\{!.*?\\}');
			Matcher myMatcher = MyPattern.matcher(msgFormat);
			Map<String, String> replacementMap=new Map<String,String>();
			//
			// process all tokens in message definition
			while (myMatcher.find())
			{
                system.debug('***compiledMessage:'+compiledMessage+'***');
				// get token to replace
			    String tokenPlaceholder = myMatcher.group();
                system.debug('***tokenPlaceholder:'+tokenPlaceholder+'***');
			    // 
			    // obtain field from token
			    String fieldName=tokenPlaceholder.removeStart('{!').removeEnd('}').toLowercase().trim();
			    system.debug('***fieldName:'+fieldName+'***');
			    //
			    // get field value from message record
			    String fieldValue=(String)messageRecord.get(fieldName);
			    system.debug('***fieldValue:'+fieldValue+'***');
			    if(fieldValue==null && !compiledMessage.containsIgnoreCase(tokenPlaceholder+'|nullable'))
			    	throw new EntitlementException('Parameter field is blank:'+fieldName+' fieldValue:'+fieldValue);
			    if(urlEncodeFields) {
			    	fieldValue=EncodingUtil.urlEncode(fieldValue, 'UTF-8');
			    	fieldValue=fieldValue.replaceAll('\\+','%20');
			    }
			    //
			    // replace token with value
			    system.debug('***compiledMessage.containsIgnoreCase("tokenPlaceholder|nullable"):'+compiledMessage.containsIgnoreCase(tokenPlaceholder+'|nullable')+'***');
                if (compiledMessage.containsIgnoreCase(tokenPlaceholder+'|nullable'))
                    compiledMessage=compiledMessage.replace(fieldValue == null ? '"'+tokenPlaceholder+'|nullable"' : tokenPlaceholder+'|nullable', fieldValue == null ? 'null' : fieldValue);
				else 
                	compiledMessage=compiledMessage.replace(tokenPlaceholder,fieldValue);
			    system.debug('***compiledMessage:'+fieldValue+'***');
			}
        }
		// return compiled message
		System.debug( LoggingLevel.INFO, '**compiledMessage**' + compiledMessage);
        return compiledMessage;
    }
}