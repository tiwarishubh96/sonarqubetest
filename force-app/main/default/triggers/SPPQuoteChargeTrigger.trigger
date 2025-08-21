/**********************************************************************
 Name:  SPPQuoteChargeTrigger

======================================================
======================================================
Purpose: Trigger to populate the OPP Id on Quote Charge
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
0.1         Raja Patnaik     06/02/2017          Initial Development
***********************************************************************/
trigger SPPQuoteChargeTrigger on zqu__QuoteCharge__c (before insert, before update) 
{
    Set<Id> quoteIds = new Set<Id>();
    
    for(Integer i=0; i<Trigger.new.size(); i++)
    {
        quoteIds.add(Trigger.new[i].zqu__Quote__c);
    }
    
    Map<Id,zqu__Quote__c> quoteMap = new Map<Id,zqu__Quote__c>([Select Id, zqu__Opportunity__c 
                                                                from zqu__Quote__c
                                                                where Id in:quoteIds]);
    
   
     
    for(Integer i=0; i<Trigger.new.size(); i++)
    {
        if(quoteMap.get(Trigger.new[i].zqu__Quote__c)!=null)
        {
            Trigger.new[i].Opp_Id__c = quoteMap.get(Trigger.new[i].zqu__Quote__c).zqu__Opportunity__c;
        }
        
        system.debug('>>>>>>>>>>>>>>> Trigger.new[i].zqu__ProductRatePlanName__c'+Trigger.new[i].zqu__ProductRatePlanName__c);
        
        
        if(Trigger.new[i].zqu__ProductRatePlanName__c == 'Partner Margin')
        {
           //Trigger.new[i].zqu__EffectivePrice__c = 15.0;
           
        }
        //Trigger.new[i].zqu__Discount__c = 5 ;
    }
    
                  
    
}