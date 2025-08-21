public with sharing class zuora_newQuoteCTrl {
  
  @AuraEnabled
  public static Opportunity getOpportunity(String recordId){
      if(recordId !=null){
          return [select Account.Locale__c,Referral_Date__c,Referring_Partner_Account__c,Referring_Partner_Contact__c,Type,Sales_Office__c from Opportunity where id = :recordId limit 1];
      }else{
          throw new AuraHandledException('Unable to fetch Opportunity data');
      }
  }
  
}