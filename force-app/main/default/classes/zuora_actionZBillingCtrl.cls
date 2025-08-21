public with sharing class zuora_actionZBillingCtrl {

    @AuraEnabled
    public static List<zqu__QuoteChargeSummary__c> fetchQuoteChargeSummary(String recordId){
        List<zqu__QuoteChargeSummary__c> qChSum = [SELECT Id,TranslatedProductName__c,Name FROM zqu__QuoteChargeSummary__c WHERE zqu__QuoteChargeSummary__c.zqu__QuoteRatePlan__r.zqu__Quote__c = :recordId];
        System.debug(LoggingLevel.DEBUG, 'QuoteChargeSummary ->' + qChSum);
        return qChSum;
    }

    @AuraEnabled
    public static zqu__Quote__c getQuote(String recordId){
        zqu__Quote__c quote = [select Id, RecordType.DeveloperName from zqu__Quote__c where id = :recordId];
        System.debug(LoggingLevel.DEBUG, 'getQuote ->' + quote);
        return quote;
    }

    @TestVisible
    private static Billing_m processResponse(String message){
        Billing_m result;
        if(message.containsIgnoreCase('exception')){
            result = new Billing_m('Failed to complete Z Quote : ' + message);
            result.status = 'FAILURE';
        }else if(message.containsIgnoreCase('unsuccessful')){
            result = new Billing_m(message);
            result.status = 'FAILURE';
        }
        else{
            result = new Billing_m(message);
            result.status = 'SUCCESS';                
        }
        return result;     

    }

    @AuraEnabled
    public static Billing_m callZQuoteGlobal(String recordId){
        System.debug(LoggingLevel.DEBUG, 'recordId ->' + recordId);
        Billing_m result;
        try{
            String message = (SendToZBillingUtils.callZQuoteGlobal(recordId,null));
            System.debug(LoggingLevel.DEBUG, 'Response => ' + message);
            //this call doesn't seem to throw exceptions!
            result = processResponse(message);
        }catch(Exception e){
            result = new Billing_m('Failed to send Z Quote : ' + e.getMessage());
        }
        return result;
    } 

    public class Billing_m{
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public String status{get;set;}

        public Billing_m(String message){
            this.message = message;
            this.status = 'ERROR';
        }
    }    

}