@isTest
public class successPlanAndOppAutomationTest{
    public static testMethod void testMethod1(){
        Integer integr = 0;
        Integer max = 10;
        
        List<Account> listAccount = new List<Account>();
        for(integr = 0; integr < max; integr++){
            Account Accnt = new Account();
            Accnt.Name = 'Accnt.Name';
            Accnt.OwnerId = userinfo.getUserId();
            listAccount.add(Accnt);
        }
        insert listAccount;
        
        List<Zuora__Subscription__c> listZuora_Subscription = new List<Zuora__Subscription__c>();
        for(integr = 0; integr < max; integr++){
            Zuora__Subscription__c Zuora_Subscriptn = new Zuora__Subscription__c();
            Zuora_Subscriptn.Zuora__SubscriptionEndDate__c = system.today() + 90;
            Zuora_Subscriptn.Zuora__Status__c = 'Active';
            Zuora_Subscriptn.Zuora__Account__c = listAccount[integr].Id;
            listZuora_Subscription.add(Zuora_Subscriptn);
        }
        insert listZuora_Subscription;
        
        List<Zuora__SubscriptionProductCharge__c> listZuora_SubscriptionProductCharge = new List<Zuora__SubscriptionProductCharge__c>();
        for(Zuora__Subscription__c Zuora_Subscriptn: [select Id from Zuora__Subscription__c]){
            Zuora__SubscriptionProductCharge__c Zuora_SubscriptionProductChrge1 = new Zuora__SubscriptionProductCharge__c();
            Zuora_SubscriptionProductChrge1.Zuora__Subscription__c = Zuora_Subscriptn.Id;
            Zuora_SubscriptionProductChrge1.Zuora__ProductName__c = 'Sage Business Cloud Financials';
            listZuora_SubscriptionProductCharge.add(Zuora_SubscriptionProductChrge1);
            
            Zuora__SubscriptionProductCharge__c Zuora_SubscriptionProductChrge2 = new Zuora__SubscriptionProductCharge__c();
            Zuora_SubscriptionProductChrge2.Zuora__Subscription__c = Zuora_Subscriptn.Id;
            Zuora_SubscriptionProductChrge2.Zuora__ProductName__c = 'Sage Business Cloud Financials';
            listZuora_SubscriptionProductCharge.add(Zuora_SubscriptionProductChrge2);
        }
        insert listZuora_SubscriptionProductCharge;
        
        Test.StartTest();
        successPlanAndOppAutomation successPlanAndOppAutomatn = new successPlanAndOppAutomation();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, successPlanAndOppAutomatn); 
        Test.StopTest();
        
        for(Account AccountAccount: [select Id, (select Id from Opportunities) from Account]){
            system.assertEquals(1, AccountAccount.Opportunities.size());
        }
    }
}