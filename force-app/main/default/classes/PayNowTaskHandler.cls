public with sharing class PayNowTaskHandler {
    final static string StatusOfPaymentProvided = 'Payment Provided';
    
    public static void onAfterUpdate(final List<PayNowToken__c> oldObjects, final Map<Id, PayNowToken__c> oldObjectsMap,
                              final List<PayNowToken__c> newObjects, final Map<Id, PayNowToken__c> newObjectsMap) {

        List<PayNowToken__c> updatableTokens = new List<PayNowToken__c>();

        for(PayNowToken__c pt : newObjects){
            if (oldObjectsMap.get(pt.Id).Status__c == StatusOfPaymentProvided 
                || newObjectsMap.get(pt.Id).Status__c != StatusOfPaymentProvided 
                || String.isBlank(pt.PaymentMethodId__c))
                continue;
            
            updatableTokens.add(pt);
        }

        if(updatableTokens.size() == 0)
            return;

        processPostPayment(updatableTokens);
    }
    
    private static string processPostPayment(List<PayNowToken__c> tokens){
        //RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'PayNowRecord' AND SobjectType = 'PayNowToken__c'];
        if (tokens == null || tokens.IsEmpty())
            return 'No action - no qualified tokens updated';

        System.Debug('Token count: '+tokens.size());

        Map<Id,zqu__Quote__c> quoteMap = new Map<Id,zqu__Quote__c>();
        for(PayNowToken__c token: tokens) {
            if (token.Status__c != 'Payment Provided' || String.isBlank(token.PaymentMethodId__c))
                continue;
            
            quoteMap.put(token.quote__c, null);
        }
       
        quoteMap.remove(null);
        if (quoteMap.isEmpty()) return 'No action - no qualified related quotes in Token';

        System.Debug('Quote count: '+quoteMap.size());
        
        try {
            quoteMap.putAll([SELECT Id,zqu__Account__c,LastModifiedBy.Id,zqu__BillToContact__c,zqu__ZuoraSubscriptionID__c,zqu__PaymentMethod__c FROM zqu__Quote__c WHERE Id IN :quoteMap.keyset()]);
    
            if (quoteMap == null || quoteMap.isEmpty()) return 'No action - no qualified quotes found in Quote';
    
            List<Task> tasks = new List<Task>();
            List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
            
            for(PayNowToken__c token: tokens) {
                System.Debug('Token: '+token.Id);
                
                zqu__Quote__c quote = quoteMap.get(token.quote__c);
                if (quote == null) continue;
                
                // update payment info in Quote
                quote.zqu__ElectronicPaymentMethodId__c = token.PaymentMethodId__c;
                if (String.isNotBlank(token.PaymentMethodType__c) && token.PaymentMethodType__c != quote.zqu__PaymentMethod__c)
                    quote.zqu__PaymentMethod__c = token.PaymentMethodType__c;

                quotesToUpdate.add(quote);
                
                System.Debug('OwnerId: '+quote.LastModifiedBy.Id);
                System.Debug('WhoId: '+quote.zqu__BillToContact__c);

                // create task
                Task task = new Task(
                            OwnerId = quote.LastModifiedBy.Id, 
                            WhatId = quote.zqu__Account__c, 
                    		WhoId = quote.zqu__BillToContact__c,
                            Type = 'Notification',
                            Subject = 'Follow Up: PayNow payment received', 
                            Description = 'Customer provided payment method', 
                            Status = 'Not Started', 
                            priority = 'Normal', 
                            ActivityDate = Date.today().AddDays(1)
                        );

                tasks.Add(task);
            }

            System.Debug('Task count: '+tasks.size());
            insert tasks;

            Set<ID> quoteIdsToConvert = new Set<ID>();
            if (! quotesToUpdate.isEmpty()) {
                update quotesToUpdate;
                
                for (zqu__Quote__c q : quotesToUpdate)
                    if (string.isBlank(q.zqu__ZuoraSubscriptionID__c))
                    	quoteIdsToConvert.add(q.ID);
            }
            
            if (quoteIdsToConvert.size() > 0)
                createTryNowConvertActivities(quoteIdsToConvert);
            
            return 'Created tasks';
        } catch (Exception e) {
            //String errorMsg = 'Error creating task: ' + e;
            String errorMsg = 'Error creating task';
            return errorMsg;
        }
    }

    private static void createTryNowConvertActivities(Set<ID> candidateQuoteIds){
        if (candidateQuoteIds == null || candidateQuoteIds.IsEmpty())
            return;
        System.Debug('Quote count: '+candidateQuoteIds.size());
        List<SageApiActivity__c> tryNowActivities = [SELECT ID, Quote__c, PayNowToken__r.Name FROM SageApiActivity__c WHERE Quote__c IN: candidateQuoteIds];
        System.Debug('tryNowActivities count: '+tryNowActivities.size());
        if (tryNowActivities == null || tryNowActivities.size() == 0) return;

        Map<ID, zqu__Quote__c> convertableQuotesMap = new Map<ID, zqu__Quote__c>();
        Map<ID, String> quoteTokenMap = new Map<ID, String>();
        for (SageApiActivity__c activity : tryNowActivities) {
            convertableQuotesMap.put(activity.Quote__c, null);
            quoteTokenMap.put(activity.Quote__c, activity.PayNowToken__r.Name);
        }
        convertableQuotesMap.putAll([SELECT Id,zqu__Account__c,zqu__ElectronicPaymentMethodId__c FROM zqu__Quote__c WHERE Id IN :convertableQuotesMap.keyset()]);

        List<ID> quoteIds = new List<ID>();
        List<ID> accountIds = new List<ID>();

        for(ID quoteId : convertableQuotesMap.keySet()) {
            zqu__Quote__c quote = convertableQuotesMap.get(quoteId);
            if (quote == null || String.isBlank(quote.zqu__ElectronicPaymentMethodId__c)) continue;
            quoteIds.add(quote.id);
            accountIds.add(quote.zqu__Account__c);
        }
        
        if (quoteIds.size() == 0) return;

		List<SageApiActivity__c> activities = new List<SageApiActivity__c>();
        Integer index = 0;
        for (ID quoteId : quoteIds) {
            string guid = GenericUtilities.getRandomUUIDv4();
            SageApiTryNowConvertActivityRequest req = new SageApiTryNowConvertActivityRequest();
            req.activityId = SageApiActivityTriggerHandler.TryNowConvertActivityType + ':' + guid;
            req.quoteId = quoteId;
            req.payNowToken = quoteTokenMap.get(quoteId);
            req.accountId = accountIds[index];
            SageApiActivity__c activity = new SageApiActivity__c();
            activity.Name = guid;
            activity.ActivityType__c = SageApiActivityTriggerHandler.TryNowConvertActivityType;
            activity.ActivityID__c = req.activityId;
            activity.ActivityStatus__c = SageApiStatus.Unknown;
            activity.Payload__c = JSON.serialize(req);
            activities.add(activity);
            index++;
        }    
        
		insert activities;        
    }
}