public inherited sharing class OpportunitySurveyHelper {
    private final String CLASSNAME = 'OpportunitySurveyHelper';

    private ServiceInvoker invoker;

    @TestVisible
    private Map<Id,Account> mapAccountIdToAccount;
    @TestVisible
    private Map<Id, Contact> mapIdToContact;
    @TestVisible
    private Map<Id,Id> mapOppIdsToContactIds;

    public OpportunitySurveyHelper() {}

    @TestVisible
    private ServiceInvoker getInvoker(){
        if (invoker == null) {
            invoker = new ServiceInvoker();
        }

        return invoker;
    }

    private Map<Id,Contact> getMapIdToContact(List<Opportunity> opportunities){
        if (mapIdToContact == null) {
            mapOppIdsToContactIds = new Map<Id,Id>();
            for (Opportunity o : opportunities) {
                if (o.Primary_Contact__c != null) {
                    mapOppIdsToContactIds.put(o.Id,o.Primary_Contact__c);
                }
            }
            mapIdToContact =
                    new Map<Id,Contact>([SELECT Id, Email,Language__c, Allow_Experience_Feedback__c, Last_Survey_Date__c
                    FROM Contact
                    WHERE Id IN :mapOppIdsToContactIds.values()]);
        }

        return mapIdToContact;
    }

    private Map<Id,Account> getMapAccountIdToAccount(List<Opportunity> opportunities){
        if (mapAccountIdToAccount == null) {
            Set<Id> accountIds = new Set<Id>();

            for (Opportunity o : opportunities) {
                if (o.AccountId != null) {
                    accountIds.add(o.AccountId);
                }
            }

            mapAccountIdToAccount = new Map<Id,Account>([SELECT Id, BillingCountry FROM Account WHERE Id IN :accountIds]);
        }

        return mapAccountIdToAccount;
    }

    public ICustomerRequest prepareSurveyRequest(Opportunity inputOpportunity) {
        Boolean customerOk = false;
        Boolean contactAllowed = false;

        Contact con;
        // check we have a Contact and Account
        if (mapOppIdsToContactIds.containsKey(inputOpportunity.Id) &&
                mapAccountIdToAccount.containsKey(inputOpportunity.AccountId)) {
            // we have a customer contact
            Id contactId = mapOppIdsToContactIds.get(inputOpportunity.Id);
            con = mapIdToContact.get(contactId);

            if (con.Email != null) {
                customerOk = true;
            }

            if (con.Allow_Experience_Feedback__c != 'No') {
                // All Opportunity Sources currently allowed
                // All Opportunity record types currently allowed
                contactAllowed = true;
                // Check last survey date
            }

        } // else no customer contact, no survey
        ICustomerRequest surveyReq = SurveyRequestFactory.getCustomerRequest(SurveyTypes.RNR_Async);
        surveyReq.setCustomer(mapOppIdsToContactIds.get(inputOpportunity.Id));
        surveyReq.setContactType('Email');
        surveyReq.setDelay(0);
        surveyReq.setEvent(System.now());
        surveyReq.setSurveyType('Opportunity');
        surveyReq.setCanContactCustomer(contactAllowed);
        surveyReq.setCustomerHasEmail(customerOk);
        surveyReq.setOwnerId(inputOpportunity.OwnerId);
        surveyReq.setContactOrLeadId(mapOppIdsToContactIds.get(inputOpportunity.Id));
        if (con != null) {
            surveyReq.setLastSurveyDate(con.Last_Survey_Date__c);
            surveyReq.setLanguage(con.Language__c);
        }
        surveyReq.setTransactionStatus(inputOpportunity.StageName);
        String country = mapAccountIdToAccount.get(inputOpportunity.AccountId).BillingCountry;
        surveyReq.setCountry(country);
        surveyReq.setTransactionId(inputOpportunity.Id);

        return surveyReq;
    }

    public ISurveyRequest solicitSurvey(List<Opportunity> listNewOpportunities) {
        final String METHOD_NAME = 'solicitSurvey';
        LogControl.push(METHOD_NAME, this.CLASSNAME);

        ISurveyRequest surveyRequest = SurveyRequestFactory.getSurveyRequest(SurveyTypes.RNR_Async);
        try {
            // init some of the helper collections
            getMapAccountIdToAccount(listNewOpportunities);
            getMapIdToContact(listNewOpportunities);

            for (Opportunity eachOpportunity :listNewOpportunities) {
                if (eachOpportunity.Primary_Contact__c != null
                        && Global_Constants.OPP_STAGE_CW.equals(eachOpportunity.StageName)
                            || (Global_Constants.OPP_STAGE_CL.equals(eachOpportunity.StageName) && (eachOpportunity.Why_We_Lost__c==null||
                                                                                                 eachOpportunity.Why_We_Lost__c!='Customer Unresponsive'))) {
                    surveyRequest.getRequests().add((this.prepareSurveyRequest(eachOpportunity)));
                }
            }

            if (surveyRequest.getRequests() != null && surveyRequest.getRequests().size() > 0) {
                ServiceInvoker invoker = getInvoker();
                invoker.call(SurveyTypes.RNR_Async, surveyRequest);
            }
        } catch (Exception caughtException) {
            System.debug('Exception in ' + METHOD_NAME + ' ' + caughtException);
            System.debug('Line : ' + caughtException.getLineNumber());
            System.debug('Trace : ' + caughtException.getStackTraceString());
            LogControl.debugException(caughtException);
        } finally {
            LogControl.pop();
        }

        return surveyRequest;
    }

    /**
     * @description EAD-1572 method to determine whether a RnR Survey is required and send one if so
     * @param leads list of new trigger leads
     * @param oldLeads map of old trigger leads
     */
    public ISurveyRequest solicitSurvey(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities) {
        LogControl.push('solicitSurvey', this.CLASSNAME);

        Set<Id> oppIds = (new Map<Id,SObject>(opportunities)).keySet();
        // init some of the helper collections
        getMapAccountIdToAccount(opportunities);
        getMapIdToContact(opportunities);

        List<Opportunity> oppsToSurvey = new List<Opportunity>();
        ISurveyRequest request = SurveyRequestFactory.getSurveyRequest(SurveyTypes.RNR_Async);
        try {
            for (Opportunity opp : opportunities) {
                // Check for survey trigger conditions
                if (oldOpportunities.containsKey(opp.id)) {
                    // this is an update
                    if (!(
                            // Closed Lost or Closed Won
                            ((Global_Constants.OPP_STAGE_CW.equals(opp.StageName) || (Global_Constants.OPP_STAGE_CL.equals(opp.StageName) &&
                                                                                      (opp.Why_We_Lost__c==null||
                                                                                      opp.Why_We_Lost__c!='Customer Unresponsive'))) &&
                                    (opp.StageName != oldOpportunities.get(opp.Id).StageName)) ||
                                    // Converted from Lead, Qualified.
                                    // Existing Opp can now be used in Lead Conversion but requirement is to send survey for a new one
                                    ((Global_Constants.OPP_STAGE_Q.equals(opp.StageName)) &&
                                            (opp.Is_Converted__c == true) &&
                                            (opp.Primary_Contact__c != null) &&
                                            (oldOpportunities.get(opp.Id).Primary_Contact__c == null))
                    )) {
                        // trigger criteria not met - try next Opportunity
                        continue;
                    }
                }

                request.getRequests().add((this.prepareSurveyRequest(opp)));
            }

            if (request.getRequests() != null && request.getRequests().size() > 0) {
                ServiceInvoker invoker = getInvoker();
                invoker.call(SurveyTypes.RNR_Async, request);
            }

        } catch (Exception e) {
            System.debug('Exception in solicitSurvey ' + e);
            System.debug('Line : ' + e.getLineNumber());
            System.debug('Trace : ' + e.getStackTraceString());
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        }
        return request;
    }
}