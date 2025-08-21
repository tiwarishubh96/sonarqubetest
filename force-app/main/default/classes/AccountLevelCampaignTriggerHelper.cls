public class AccountLevelCampaignTriggerHelper {
 public static void getErrorAccCmp(List<Account_Level_Campaign__c> TriggerNew){

    List<Id> AccCmp= new List<Id>();
    
    //Map<Id,Id> mapAccCamp= new Map<Id,Id>();
    for(Account_Level_Campaign__c  AccCmpJunction: TriggerNew){
        AccCmp.add(AccCmpJunction.Account__c);
        // mapAccCamp.put(AccCmpJunction.Account__c,AccCmpJunction.Campaign__c );
    }
    
    
    if(AccCmp != null && AccCmp.size()>0){
        
        List<Account_Level_Campaign__c> AccCampJunction= [Select id,Account__c,Campaign__c from Account_Level_Campaign__c
                                                          where Account__c in :AccCmp];
        system.debug('*******'+AccCampJunction);
        
        if(AccCampJunction!= null && AccCampJunction.size()>0){    
            
            //Integer i = 0;
            for(Account_Level_Campaign__c  AccCmpJunction: TriggerNew){
                system.debug('List'+AccCmpJunction);
                for(Account_Level_Campaign__c locationJunction:AccCampJunction){
                    //system.debug('AccCmp:'+AccCmpJunction.Account__c + ' ' +  locationJunction.Account__c + ' ' + AccCmpJunction.Campaign__c+ ' ' + locationJunction.Campaign__c );
                    //system.debug('outside if');
                    AccCmp.add(AccCmpJunction.Account__c);
                    if(AccCmpJunction.Account__c == locationJunction.Account__c && AccCmpJunction.Campaign__c == locationJunction.Campaign__c ){
                        //system.debug('Inside if');
                        AccCmpJunction.addError('This Campaign is already associated with the Account record');
					//Trigger.new[i].addError('This Campaign is already associated with the Account record');
                    }
                }
               // i++;
                
            }   
        }
        
    } 
    
}
}