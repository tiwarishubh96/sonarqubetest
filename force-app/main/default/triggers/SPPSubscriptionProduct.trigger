/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/02/2017
    Company:       
    Description:   Trigger to create a Create/Update Subscription Product Details with Current/Original Licenses
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
trigger SPPSubscriptionProduct on Zuora__SubscriptionProductCharge__c (after insert) 
{ 
    set<string> setZuoraSubProdID = new set<string>();
    
    Map<String,Zuora__SubscriptionProductCharge__c> mapZuoraSubProd = new  Map<String,Zuora__SubscriptionProductCharge__c>();
    
    List<Subscription_Product_Detail__c> lstsubProdInsert = new List<Subscription_Product_Detail__c>();
  
    if(Trigger.isAfter && Trigger.isInsert) 
        {
           for(Zuora__SubscriptionProductCharge__c objZuoraSubProdID:Trigger.new)
           {
             //Creating a Unq Key to find Subscriptions records and Update the values
             //mapZuoraSubProd.put(objZuoraSubProdID.Zuora__Account__c+objZuoraSubProdID.Name+objZuoraSubProdID.Zuora__ProductName__c,objZuoraSubProdID);
             if(objZuoraSubProdID.Zuora__ChargeNumber__c != null)
             mapZuoraSubProd.put(objZuoraSubProdID.Zuora__ChargeNumber__c,objZuoraSubProdID);
           }
           
           system.debug('>>>>>>>>>>>'+mapZuoraSubProd);
           
           List<Subscription_Product_Detail__c> lstsubprod = [Select Id,Name,Original_Licenses__c,Licenses__c,Account__c,Product_Name__c
           ,Subscription__c,Charge_Number__c from Subscription_Product_Detail__c
           where Charge_Number__c in : mapZuoraSubProd.Keyset()];
           
           system.debug('>>>>>>>>>>>'+lstsubprod);
           
           for(Subscription_Product_Detail__c objSubprod : lstsubprod)
           {
                //Zuora__SubscriptionProductCharge__c obj = mapZuoraSubProd.get(objSubprod.Account__c+objSubprod.Name+objSubprod.Product_Name__c );
                Zuora__SubscriptionProductCharge__c obj = mapZuoraSubProd.get(objSubprod.Charge_Number__c);
                system.debug('>>>>>>>>>>>'+obj);
                  
                if(null != obj)//Data already exits
                {
                   objSubprod.Licenses__c  = obj.Zuora__Quantity__c;
                   objSubprod.Subscription__c=obj.Zuora__Subscription__c;
                }
                
           }
           
           if(lstsubprod.isEmpty())
           {   
           // It will create SPP subscription product and Charge record
               for(Zuora__SubscriptionProductCharge__c obj: Trigger.new)
               {
                   if(obj.Zuora__ChargeNumber__c!= null)
                   {
                   system.debug('obj.Zuora__Subscription__c'+obj.Zuora__Subscription__c);
                   
                   lstsubProdInsert.add(new Subscription_Product_Detail__c(Name=obj.Name,Account__c=obj.Zuora__Account__c,Price__c=obj.Zuora__Price__c,
                   Product_Name__c=obj.Zuora__ProductName__c,Rate_Plan_Name__c=obj.Zuora__RatePlanName__c,UOM__c=obj.Zuora__UOM__c,
                   Licenses__c=obj.Zuora__Quantity__c,Original_Licenses__c=obj.Zuora__Quantity__c,Subscription__c=obj.Zuora__Subscription__c,Charge_Number__c=obj.Zuora__ChargeNumber__c));
                   }
               }
           }
           if(!lstsubProdInsert.isempty())
           {
              insert lstsubProdInsert;
           }
           
           update lstsubprod;
         
        }   
          

}