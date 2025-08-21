/*  Date Created: 6/28/2017
    Author: Joemark Medina
    Description:  ENHC0010903 - Success Plan and Opportunity - automation of renewal type creations
                  This Scheduled Class creates renewal opportunities 90 before renewal of active subscriptions.
                  Then, the process builder will create the renewal success plan.
*/  

global class successPlanAndOppAutomation implements Schedulable {
  
  global void execute(SchedulableContext ctx){
  
    //get the Subscription records where active subscriptions end date is 90 days ahead
    Date x90days = system.today() + 90;
    String qry = 'SELECT Zuora__Account__c, Name, Zuora__Account__r.Name, Zuora__Account__r.OwnerId, Zuora__Account__r.CurrencyIsoCode, Zuora__SubscriptionEndDate__c, Id FROM Zuora__Subscription__c WHERE Zuora__SubscriptionEndDate__c =: x90days and Zuora__Status__c = \'Active\'';
    List<Zuora__Subscription__c> scope = Database.query(qry);
    Map<Id, Zuora__Subscription__c> mapIdZuora_Subscriptn = new Map<Id, Zuora__Subscription__c>(scope);
    Map<Id, Opportunity> mapIdOpportunity = new Map<Id, Opportunity>();
          
    //check if the related Subscription Product Charges Product Name contains 'Sage Live' or 'Financials', then, create the opportunities.
    for(Zuora__SubscriptionProductCharge__c zuora_SubscriptionProductChrge: [select Zuora__Subscription__c, Zuora__ProductName__c, id from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__c in:mapIdZuora_Subscriptn.keySet()]){
        if((zuora_SubscriptionProductChrge.Zuora__ProductName__c.contains('Sage Live') || zuora_SubscriptionProductChrge.Zuora__ProductName__c.contains('Financials'))
         && !mapIdOpportunity.keySet().contains(zuora_SubscriptionProductChrge.Zuora__Subscription__c)){
            Opportunity opportunty = new Opportunity();
            opportunty.CloseDate = mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Zuora__SubscriptionEndDate__c;
            opportunty.Name = mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Zuora__Account__r.Name + ' - Renewal - ' + mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Name;
            // 02/08/2018 bphan EAD_364 1st Stage of Record Type = Sales Qualification
            //opportunty.StageName = 'Sales Qualification';
            opportunty.StageName = Label.Opportunity_Sales_Stages_Stage1;
            opportunty.CurrencyIsoCode = mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Zuora__Account__r.CurrencyIsoCode;
            opportunty.Lead_Source__c = 'SalesGenerated';
            opportunty.LeadSource = 'Other';
            opportunty.OwnerId = mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Zuora__Account__r.OwnerId;
            opportunty.Type = 'Renewal Business';
            opportunty.Create_Success_plan_after_opportunity_is__c = true;
            opportunty.AccountId = mapIdZuora_Subscriptn.get(zuora_SubscriptionProductChrge.Zuora__Subscription__c).Zuora__Account__c;
            mapIdOpportunity.put(zuora_SubscriptionProductChrge.Zuora__Subscription__c, opportunty);
        }
    }
    insert mapIdOpportunity.values();
  }
  
 }