/*
* Class Name :- CustomerStoryHelper
* Author :- Shubham Kimothi
* Created Date :- 22-05-2019
* Description : This class is called from CustomStoryTriggerHandler

// ********************Change Logs *****************************************************************************************************************************
*/

public without sharing class CustomerStoryHelper {
    static string CLASSNAME = 'CustomerStoryHelper';
    public static void insertRegionsAccordingtoCountries(List<Customer_Story__c> newCustomerStory) {
        try {
            string QueueName = System.Label.CustomerStoryQueue;
            string OwnerId =[SELECT Id, QueueId FROM QueuesObject WHERE Queue.Name=:QueueName].QueueId;
            LogControl.push('CustomerStoryHelper', CLASSNAME);
            Set<String> countrySet = new Set<String>();
            for(Customer_Story__c custStory :newCustomerStory){
                custStory.OwnerId = OwnerId;
                if(custStory.Country__c !=null && !String.isBlank(custStory.Country__c)){
                    countrySet.add(custStory.Country__c.substring(custStory.Country__c.indexOf('-')+2,custStory.Country__c.length()));
                } 
            }
            if(!countrySet.isEmpty()){
                Map<String, String> conToRe = CountriesTORegionMappingUtils.mapCountriestoRegions(countrySet);
                for(Customer_Story__c custStory :newCustomerStory){
                    if(conToRe != null && conToRe.containsKey(custStory.Country__c.substring(custStory.Country__c.indexOf('-')+2,custStory.Country__c.length()))){
                       custStory.Region__c = conToRe.get(custStory.Country__c.substring(custStory.Country__c.indexOf('-')+2,custStory.Country__c.length()));
                    }
                }
            }
        } catch (Exception e) {
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        }
    }
}