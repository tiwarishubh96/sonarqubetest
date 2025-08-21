public class AccountMergerHelper {
  // Get Accounts with Billing Accounts and Subscription Master
    public void getBillingAccountsAndSubscriptionMaster(Map<ID,Account> oldAccMap)
    {
        List<Account> accwithBA  = [select id, (select id from R00N40000001kyLcEAI__r),
                                   (select id from Subscription_Master__r)
                                   from Account where id in : oldAccMap.keyset()];
 		for (Account a : accwithBA){
           // Do not delete accounts with billing accounts and subscription master
          
   		if((a.R00N40000001kyLcEAI__r!=null &&a.R00N40000001kyLcEAI__r.size() >0) || 
               (a.Subscription_Master__r!=null&&a.Subscription_Master__r.size() >0)){    
               	Account actualAcc = oldAccMap.get(a.Id); 
                actualAcc.addError(System.Label.CC360_Merge_Error);
                }
        }
    }
}