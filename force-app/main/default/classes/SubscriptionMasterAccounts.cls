public with sharing class SubscriptionMasterAccounts {

        @AuraEnabled(cacheable=true)

    public static Subscription_Master__c getSingleContact(){
        String businessId;
                String soqlQuery = String.escapeSingleQuotes('SELECT Id,BusinessId__c FROM Business__c where id = :recordId LIMIT 1');
                SObject businessSObject = Database.query(soqlQuery);
                if(businessSObject != null){
                    businessId = (String)businessSObject.get('BusinessId__c');
                }
                if(String.isBlank(businessId)){
                    throw new AuraHandledException('Unable to find Business id');
                }
        return [SELECT Id, Account__c,Account__r.Name FROM Subscription_Master__c where BusinessId__c = :businessId];

    }
}