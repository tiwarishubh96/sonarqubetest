@isTest
public class SageApiActivityReferrerPromoExtTest { 
  
    @IsTest(SeeAllData=false) static void testExtension(){
        SageApiActivityReferrerPromotion__c a = new SageApiActivityReferrerPromotion__c(ReferrerId__c = 'url');
        insert a;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
                
        //Call controller with token created.
        SageApiActivityReferrerPromoExt controller = new SageApiActivityReferrerPromoExt (sc);
        
        Integer c1 = controller.getCountOfPayNowTokens();
        Integer c2 = controller.getCountOfActivities();
        Integer c3 = controller.getCountOfSubscriptionMasters();
    }
    
}