/**
 * Created by craig.bradshaw on 2019-03-29.
 * Description: Contains any REGIONAL related rules
 * Use Account_Helper for any GLOBAL related rules
 */

public without sharing class Account_ValidationRules {

    // Constants
    static String CLASSNAME = 'Account_ValidationRules';

    public static final String[] COUNTRYCODE_CA = new String[]{'CA'};
    public static final String[] COUNTRYCODE_US = new String[]{'US'};
        
    public static Boolean isRunTestCaseCheck = true;
        
    // Messages
    //     

  /**
   * @description: check if Account is converted or not and making sure if it is not US if converted and not canada if it isn't converted
   * 3/1/2018 Adam Annony (accountTriggerHandler)
   * @param: list of trigger new account
   * @param
   **/    
  public static void validateBillingCityandStreet(List<Account> a){
  try{
    LogControl.push('validateBillingCityandStreet',CLASSNAME);                        
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();
    //Map<Id,Account> accountIds = new Map<Id, Account>();
    if(controlSwitch.RunValidationRules__c || TestUtils.isRunningTest()){  // switch           
      if(RecursiveTriggerHandler.isFirstTime){        // recursive
        RecursiveTriggerHandler.isFirstTime = false;
        for(Account acc : a){
          if ((acc.isConverted__c == false && !COUNTRYCODE_CA.contains(acc.BillingCountryCode))  || 
            (acc.isConverted__c == true && (!COUNTRYCODE_US.contains(acc.BillingCountryCode) && !COUNTRYCODE_CA.contains(acc.BillingCountryCode)))){
            if (Test.isRunningTest() && isRunTestCaseCheck){
               acc.isConverted__c = false;
            } else {      
               if ( String.isBlank(acc.BillingCity) && String.isBlank(acc.BillingStreet)  ){
                 acc.BillingCity.addError(Label.ACCOUNT_BILLING_CITY_STREET_REQUIRED);
                  acc.isConverted__c = false;// Kiran Moota 28-02-2019
             }else if (String.isBlank(acc.BillingCity) ){
               acc.BillingCity.addError(Label.ACCOUNT_BILLING_CITY_REQUIRED);
               acc.isConverted__c = false;// Kiran Moota 28-02-2019
             }else if (String.isBlank(acc.BillingStreet)){
               acc.BillingStreet.addError(Label.ACCOUNT_BILLING_STREET_REQUIRED);
               acc.isConverted__c = false;// Kiran Moota 28-02-2019
             }
            }  
           }
          }
        } // recursive
      } // switch
    } catch (Exception e) { 
        LogControl.debugException(e); 
    } finally { 
        LogControl.pop(); 
    }
  }   
    
  // 2021/04/21 bphan EAD-2227
  // The ExCo Sponsorship checkbox can only be unchecked 
  // if there are no Visit records created eg. once a Visit is created, the ExCo Sponsorship checkbox becomes read-only  
  public static void validateExCoSponsorship(List<Account> newAccounts, List<Account> oldAccounts ){
  try{
    LogControl.push('validateExCoSponsorship',CLASSNAME);	
    AccountControlSwitch__c controlSwitch = AccountControlSwitch__c.getInstance();     
    if(controlSwitch.RunValidationRules__c || TestUtils.isRunningTest()){  // switch           
      RecursiveTriggerHandler.isFirstTime = false;
      Map<Id,Account> accIds = new Map<Id,Account>();   
      For( Integer i = 0; i < newAccounts.size(); i++){    
        	Account newAcc = (Account)newAccounts[i];
        	Account oldAcc = (Account)oldAccounts[i];
            // Uncheck ExCo Sponsorship
        	if (( newAcc.ExCo_Sponsorship__c != oldAcc.ExCo_Sponsorship__c) &&
               ( oldAcc.ExCo_Sponsorship__c == true) ){   
            	accIds.put(newAcc.Id, newAcc);
            }           
       }    
      // can't uncheck sponsorship if there are Visits          
      if ((accIds != null) && (!(accIds.isEmpty()))){  
        // fetch Visits
         List <ExCo_Sponsorship_Visit__c> visits = new List<ExCo_Sponsorship_Visit__c>();
  	     visits = [SELECT Name, Start_time_of_sponsorship_visit__c, End_time_of_sponsorship_visit__c, ExCo_Account__c FROM ExCo_Sponsorship_Visit__c WHERE ExCo_Account__c IN:accIds.keySet() LIMIT 1];
         if (!visits.isEmpty()){               
           for (ExCo_Sponsorship_Visit__c visit: visits){                  
             Account acc=accIds.get(visit.ExCo_Account__c);
             acc.ExCo_Sponsorship__c.addError(Label.EXCO_SPONSORSHIP_VISITS);
           }
       }
    }    
  } // switch
} catch (Exception e) { 
  LogControl.debugException(e); 
} finally { 
  LogControl.pop(); }
}    


}