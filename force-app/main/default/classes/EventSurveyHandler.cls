/*
* Class Name : EventSurveyHandler
* Author : Pete Wilson
* Created Date : 05 November 2020
* Description : This class is called by EventTriggerHandler
* and is used to determine whether events meet criteria requiring surveys before requesting one
*/ 
public inherited sharing class EventSurveyHandler {
    private final String CLASSNAME = 'EventSurveyHandler';    
    private ServiceInvoker invoker;

    @TestVisible
    private ServiceInvoker getInvoker(){
        
        if (invoker == null) {
            invoker = new ServiceInvoker();
        }
        
        return invoker;
    }

    /**
     * @description EAD-1920 method to determine whether a RnR Survey is required and send one if so
     * @param events list of new trigger Events
     * @param oldEvents map of old trigger Events
     */
    public ISurveyRequest solicitSurvey(List<Event> events, Map<Id, Event> oldEvents) {
        LogControl.push('solicitSurvey', this.CLASSNAME);
        System.debug(LoggingLevel.DEBUG,'Event solicitSurvey');

        Set<Id> eventIds = oldEvents.keySet();
        Set<Id> accIds = new Set<Id>(); // Related Account is required for Country field for RnR Workflow - using the mandatory BillingCountry field
        Set<Id> conIds = new Set<Id>(); // Related Contact is required to provide customer info to RnR for survey
        Set<Id> leadIds = new Set<Id>(); // Related Lead is required to provide customer info to RnR for survey
        Set<Id> callItemIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> mapEventIdToTransactionId = new Map<Id,Id>();
        Map<Id,Id> mapTransactionIdToAccountId = new Map<Id,Id>();
        List<Lead> leads;
        List<Call_Item__c> callItems;
        List<Opportunity> opportunities;
        List<Account> accounts;
        Map<Id,Contact> mapContactIdToContact;
        Map<Id,Lead> mapLeadIdToLead;

        List<Event> eventsToSurvey = getEventsOfInterest(events, oldEvents);
        
        // start Event Loop
        for (Event e : eventsToSurvey) {
            mapEventIdToTransactionId.put(e.Id,e.WhatId);
            
            if (e.WhoId != null) {
                if (e.WhoId.getSObjectType() == Contact.sObjectType) {
                    conIds.add(e.WhoId);
                } else if (e.WhoId.getSObjectType() == Lead.sObjectType) {
                    leadIds.add(e.WhoId);
            	}
            } 
                
            if (e.WhatId != null) {
                
                if (e.WhatId.getSObjectType() == Account.sObjectType) {
                    accIds.add(e.WhatId);
                } else if (e.WhatId.getSObjectType() == Call_Item__c.sObjectType) {
                	callItemIds.add(e.WhatId);
                } else if (e.WhatId.getSObjectType() == Opportunity.sObjectType) {
                    oppIds.add(e.WhatId);
                } 
            }
        } // Event loop end
        
        if (callItemIds != null && !callItemIds.isEmpty()) {
            callItems = [SELECT Id, Account__c FROM Call_Item__c WHERE Id IN :callItemIds];
            for (Call_Item__c c : callItems) {
                mapTransactionIdToAccountId.put(c.Id,c.Account__c);
                accIds.add(c.Account__c);
            }
        }
        
        if (oppIds != null && !oppIds.isEmpty()) {
            opportunities = [SELECT Id, AccountId FROM Opportunity WHERE Id IN :oppIds];
            for (Opportunity o : opportunities) {
                mapTransactionIdToAccountId.put(o.Id,o.AccountId);
                accIds.add(o.AccountId);
            }
        }
        
        Map<Id,Account> mapAccountIdToAccount = new Map<Id,Account> 
            ([SELECT Id, BillingCountry FROM Account WHERE Id IN :accIds]);
        
        if (conIds != null && !conIds.isEmpty()) {
            mapContactIdToContact = new Map<Id,Contact>([SELECT Id, Email, Allow_Experience_Feedback__c,Language__c, Last_Survey_Date__c, MailingCountry FROM Contact WHERE Id IN :conIds]);
        }
        
        if (leadIds != null && !leadIds.isEmpty()) {
            mapLeadIdToLead = new Map<Id,Lead>([SELECT Id, Email, Last_Survey_Date__c, Language__c, Country FROM Lead WHERE Id IN :leadIds]);
        }
        
        ISurveyRequest request = SurveyRequestFactory.getSurveyRequest(SurveyTypes.RNR_Async);

        try {
            // Event loop 2
            for (Event e : eventsToSurvey) {
                // Check the Event relates to a Contact or a Lead (with an email address)
                // Determine country either from the Lead, a related Account, or the Contact itself - it's used to determine the RnR Workflow form 
                Boolean customerOk = false;
                Boolean contactAllowed = true;
                DateTime lastSurveyDate;
                Id customerId;
                
                // look for a related Account to pick up country value
                String country;
                String language;
                Id transactionId = mapEventIdToTransactionId.get(e.Id);
                if (transactionId != null) {
                    Id accountId = mapTransactionIdToAccountId.get(transactionId);
                    if (accountId != null) {
                        Account acc = mapAccountIdToAccount.get(accountId);
                        if (acc != null) {
                            country = acc.BillingCountry;
                        }
					}
                } // If no country picked up yet we will attempt to use Contact or Lead fields
                
				// Is our Event related to a Contact or a Lead
                if (e.WhoId !=null && conIds.contains(e.WhoId) && mapContactIdToContact != null) {
                    Contact c = mapContactIdToContact.get(e.WhoId);
                    
                    if (c != null) {
                        lastSurveyDate = c.Last_Survey_Date__c;
                        language=c.language__c;
                        customerId = c.Id;
                        
                        if (c.Email != null) {
                        	customerOk = true;
                    	}
                        
                        if (c.Allow_Experience_Feedback__c == 'No') {
                        	contactAllowed = false;
                    	}
                        
                        if (country == null) {
                            country = c.MailingCountry;
                        }
                    } 
                } else if (e.WhoId !=null && leadIds.contains(e.WhoId) && mapLeadIdToLead != null) {
                    Lead l = mapLeadIdToLead.get(e.WhoId);
                    
                    if (l != null) {
                        lastSurveyDate = l.Last_Survey_Date__c;
                        language=l.Language__c;
                        customerId = l.Id;
                        
                        if (l.Email != null) {
                        	customerOk = true;
                    	}
                        
                        if (country == null) {
                            country = l.Country;
                        }
                    } 
                } // else no customer contact, no survey

                // Build the survey request
                ICustomerRequest surveyReq = SurveyRequestFactory.getCustomerRequest(SurveyTypes.RNR_Async);
                surveyReq.setCustomer(e.WhoId);
                surveyReq.setContactType('Email');
                surveyReq.setDelay(0);
                surveyReq.setEvent(System.now());
                surveyReq.setSurveyType('Event');
                surveyReq.setCanContactCustomer(contactAllowed);
                surveyReq.setCustomerHasEmail(customerOk);
                surveyReq.setOwnerId(e.OwnerId);
                surveyReq.setContactOrLeadId(customerId);
                surveyReq.setLastSurveyDate(lastSurveyDate); 
                surveyReq.setTransactionStatus(e.Status__c);
                surveyReq.setTransactionType(e.Support_Type__c);
                surveyReq.setCountry(country);
                surveyReq.setLanguage(language);
                surveyReq.setTransactionId(e.Id);
                System.debug(LoggingLevel.DEBUG, 'Adding request : ' + surveyReq);
                request.getRequests().add((surveyReq));
            } // end of 2nd event loop

            if (request.getRequests() != null && request.getRequests().size() > 0) {
                ServiceInvoker invoker = getInvoker();
                invoker.call(SurveyTypes.RNR_Async, request);
            }
            
        } catch (Exception e) {
            System.debug('Exception in Event.solicitSurvey ' + e);
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        } 
        
        return request;
    } 
    
    public List<Event> getEventsOfInterest(List<Event> events, Map<Id, Event> oldEvents) {
        LogControl.push('getEventsOfInterest', this.CLASSNAME);
        System.debug(LoggingLevel.DEBUG,this.CLASSNAME + '.getEventsOfInterest()'); 
        List<Event> eventsOfInterest = new List<Event>();
        
        // Apply Event criteria for Survey
        // Update not insertion, newly Completed, Welcome Call or Demo       
        // EAD-2453, New Survey when "Support Type" = 'Migration' - Event Migration Complete
        for (Event e : events) {
            if ((oldEvents.containsKey(e.id) &&
                (Global_Constants.EVENT_STATUS_COMPLETED.equals(e.Status__c)) && 
                (e.Status__c != oldEvents.get(e.Id).Status__c)) &&
                (e.Support_Type__c == 'Welcome Call' || e.Support_Type__c == 'Demo'  || e.Support_Type__c == 'Migration') || 
                (oldEvents.isEmpty() && Global_Constants.EVENT_STATUS_COMPLETED.equals(e.Status__c) && 
                (e.Support_Type__c == 'Welcome Call' || e.Support_Type__c == 'Demo'  || e.Support_Type__c == 'Migration'))) { 
                // trigger criteria met  
				eventsOfInterest.add(e);    
             } 
        }
        
        return eventsOfInterest;
    }
}