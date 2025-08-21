public class accountTriggerHandler{
    public static void onAfterUpdate(List<Account> triggerNew, List<Account> triggerOld, Map<Id, Account> triggerNewMap){
        List<zqu__Quote__c> listzqu_Quote = new List<zqu__Quote__c>();
        Map<String, User> mapStringUser = new Map<String, User>();
        Set<Id> setIdtriggerOld = new Set<Id>();
        
        //get the account ids of the updated records
        for(Account accnt: triggerOld){
            setIdtriggerOld.add(accnt.Id);
        }
        
        //get the user records of Graeme Houghton and Sage Foundation
        for(User usr: [SELECT FirstName, Id, LastName FROM User WHERE (FirstName =: 'Graeme' AND LastName =: 'Houghton') OR (FirstName =: 'Sage' AND LastName =: 'Foundation')]){
            mapStringUser.put(usr.FirstName + usr.LastName, usr);
        }
        
        system.debug('joejoe12 :' + setIdtriggerOld + ':');
        system.debug('joejoe13 :' + [SELECT Id, OwnerId, zqu__Account__c FROM zqu__Quote__c WHERE zqu__Account__c IN: setIdtriggerOld] + ':');
        
        //get the related quotes of the accounts
        for(zqu__Quote__c zqu_Quote: [SELECT Id, OwnerId, zqu__Account__c FROM zqu__Quote__c WHERE zqu__Account__c IN: setIdtriggerOld]){
            system.debug('joejoe15 :' + triggerNewMap + ':');
            system.debug('joejoe16 :' + zqu_Quote + ':');
            system.debug('joejoe17 :' + zqu_Quote.OwnerId + ':');
            system.debug('joejoe18 :' + triggerNewMap.get(zqu_Quote.zqu__Account__c) + ':');
            system.debug('joejoe19 :' + triggerNewMap.get(zqu_Quote.zqu__Account__c).OwnerId + ':');
            system.debug('joejoe20:' + mapStringUser + ':');
            system.debug('joejoe21 :' + mapStringUser.get('SageFoundation') + ':');
            system.debug('joejoe22 :' + mapStringUser.get('SageFoundation').Id + ':');
            //system.debug('joejoe23 :' + [select id, firstname, lastname from user where id =: triggerNewMap.get(zqu_Quote.zqu__Account__c).OwnerId] + ':');
            
            //if the previous owner of the account is Sage Foundation, then set the Owner of the quote to Graeme Houghton
            if(triggerNewMap.get(zqu_Quote.zqu__Account__c).OwnerId == mapStringUser.get('SageFoundation').Id){
                zqu_Quote.Id = zqu_Quote.Id;
                system.debug('joejoe25 :' + mapStringUser + ':');
                system.debug('joejoe26 :' + mapStringUser.get('GraemeHoughton') + ':');
                system.debug('joejoe27 :' + mapStringUser.get('GraemeHoughton').Id + ':');
                zqu_Quote.OwnerId = mapStringUser.get('GraemeHoughton').Id;
                system.debug('joejoe29 :' + zqu_Quote + ':');
                listzqu_Quote.add(zqu_Quote);
            }
        }
        system.debug('joejoe33 :' + listzqu_Quote + ':');
        update listzqu_Quote;
    }
    //Adam Annony
    //3/1/2018
    //check if lead is converted or not and making sure if it is not US if converted and not canada if it isn't converted
    public static void billingCityandStreetCheck(List<Account> a){
        if(RecursiveTriggerHandler.isFirstTime){        
        RecursiveTriggerHandler.isFirstTime = false;
            for(Account acc : a){
                if((acc.isConverted__c == False && acc.BillingCountryCode != 'CA') || 
                   (acc.isConverted__c == True && (acc.BillingCountryCode != 'US' && acc.BillingCountryCode != 'CA'))){
                    if((acc.BillingCity == '' || acc.BillingCity == null) && (acc.BillingStreet == '' || acc.BillingStreet == null) && !Test.isRunningTest()){
                        acc.BillingCity.addError('Billing Address City and Street are mandatory fields on Account');
                        acc.isConverted__c = False;// Kiran Moota 28-02-2019
                    }
                    else if((acc.BillingCity == '' || acc.BillingCity == null) && !Test.isRunningTest()){
                        acc.BillingCity.addError('Billing Address City is a mandatory field on Account');
                        acc.isConverted__c = False;// Kiran Moota 28-02-2019
                    }
                    else if((acc.BillingStreet == '' || acc.BillingStreet == null) && !Test.isRunningTest()){
                        acc.BillingStreet.addError('Billing Address Street is a mandatory field on Account');
                        acc.isConverted__c = False;// Kiran Moota 28-02-2019
                    }
                }
                //acc.isConverted__c = False;// Kiran Moota 28-02-2019 
            }
        }
    }
    
    //Yue Lu
    //3/7/2018
    //update partner old tier field in before update event
    public static void updatePartnerOldTier(List<Account>listNewAccount,Map<Id, Account> mapOldAccount){
        
        system.debug('mapOldAccount::'+mapOldAccount);
        
        for(Account a: listNewAccount){
            
            Account oldAccount = mapOldAccount.get(a.id);
            
            a.Partner_Old_Tier__c = oldAccount.Accountant_Partner_Tier__c != a.Accountant_Partner_Tier__c? oldAccount.Accountant_Partner_Tier__c : 
                							oldAccount.Reseller_Partner_Tier__c != a.Reseller_Partner_Tier__c? oldAccount.Reseller_Partner_Tier__c :
                							oldAccount.SI_Partner_Tier__c != a.SI_Partner_Tier__c? oldAccount.SI_Partner_Tier__c: oldAccount.Partner_Old_Tier__c;
            
            system.debug('a.Partner_Old_Tier__c::'+a.Partner_Old_Tier__c);
            
            if(a.Partner_Old_Tier__c != Null){
                //if partner tier is Terminated or Prospect then no need to store the value in the partner old tier
                if(Label.Invalid_Tier.contains(a.Partner_Old_Tier__c)){
                    
                    a.Partner_Old_Tier__c = null;
                }
        	}
            
            //04/02/2018 update tier change date if there is a change in tier
            if(a.Partner_Old_Tier__c != oldAccount.Partner_Old_Tier__c){
                
                a.Tier_Changed_Date__c = Date.today();
                
            }
            
            system.debug('a.Tier_Changed_Date__c:::'+a.Tier_Changed_Date__c);
            
            system.debug('a.Partner_Old_Tier__c:::'+a.Partner_Old_Tier__c);
        }
    }

}