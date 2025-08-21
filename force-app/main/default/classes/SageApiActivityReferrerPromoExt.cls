public class SageApiActivityReferrerPromoExt {
    private final SageApiActivityReferrerPromotion__c promotion;
    private Integer countOfPayNowToken;
    private Integer countOfActivity;
    private Integer countOfSubscriptionMaster;
        
    public SageApiActivityReferrerPromoExt(ApexPages.StandardController stdController) {
        this.promotion= (SageApiActivityReferrerPromotion__c)stdController.getRecord();
        
        getUsages();        
                
    }
       
    private void getUsages() {
        try{
            AggregateResult[] arp = [SELECT count(Id) c FROM PayNowToken__c WHERE ReferrerPromotion__c=:this.promotion.Id ];
            AggregateResult[] ara = [SELECT count(Id) c FROM SageApiActivity__c WHERE ReferrerPromotion__c=:this.promotion.Id ];
            AggregateResult[] ars = [SELECT count(Id) c FROM Subscription_Master__c WHERE ReferrerPromotion__c=:this.promotion.Id ];
      
            if (arp != null && ! arp.isEmpty())
                countOfPayNowToken = (integer) arp[0].get('c');
            if (ara != null && ! ara .isEmpty())
                countOfActivity = (integer) ara[0].get('c');
            if (ars != null && ! ars .isEmpty())
                countOfSubscriptionMaster = (integer) ars[0].get('c');
        } catch(Exception ex) {
            ExceptionHandler.CatchException('SageApiActivityReferrerPromoExt', 'getUsages', ex);            
        }
    }
    
    public integer getCountOfPayNowTokens() {
        return countOfPayNowToken;
    }
    
    public integer getCountOfActivities (){
        return countOfActivity;
    }  
    
    public integer getCountOfSubscriptionMasters()
    {
        return countOfSubscriptionMaster;
    }
}