/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:   Queueable Apex allows you to submit jobs for asynchronous processing similar to future methods
    Create a JSON array of Order Details and send it to Mulesoft to process the request
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
public class SPPReferralOrderDetailQueueable implements Queueable, Database.AllowsCallouts 
{
    
    List<SPP_RR_Order_Detail__c> lstSPPOrderDetails;
    
    public Map<string,Sage_Cloud_Product__mdt> mapReferredProduct = new Map<string,Sage_Cloud_Product__mdt>();
    
    public Map<string,Sage_Cloud_Product__mdt> mapSoldProduct = new Map<string,Sage_Cloud_Product__mdt>();
      
    public SPPReferralOrderDetailQueueable(List<SPP_RR_Order_Detail__c> lstSPPOrderDetails) 
    {
        this.lstSPPOrderDetails = lstSPPOrderDetails;
    }
    
    public void execute(QueueableContext context)
    {
         
        
           Map<ID,Sage_Cloud_Product__mdt> allCloudProduct = new Map<ID,Sage_Cloud_Product__mdt>([SELECT ID, DeveloperName, Referred_Cloud_C_line_product__c 
           ,Referred_Product__c,Sold_Cloud_C_line_product__c,Sold_Product_Referral_Threshold__c,Sold_ZProduct__c FROM Sage_Cloud_Product__mdt]);
          
           system.debug('mapReferredProduct'+allCloudProduct);
           
          
          for(Sage_Cloud_Product__mdt cloudPrd: allCloudProduct.values())
          {
                 
                 if(!String.IsEmpty(cloudPrd.Referred_Product__c))
                 {
                  mapReferredProduct.put(cloudPrd.Referred_Product__c,cloudPrd);// Referred Cloud Products
                 }
                 
                 if(!String.IsEmpty(cloudPrd.Sold_ZProduct__c))
                 {
                   mapSoldProduct.put(cloudPrd.Sold_ZProduct__c,cloudPrd);// Sold Cloud Products
                 }
          }
             
         system.debug('mapReferredProduct'+mapReferredProduct);
        
         system.debug('mapSoldProduct'+mapSoldProduct);
         
         List<SPPReferralOrderDetailWrapper> orderDetailWr=new List<SPPReferralOrderDetailWrapper>();
         
        try
        { 
            //only call mulesoft when opp is referral not resell
            List<SPP_RR_Order_Detail__c> orderDetailJSON=[SELECT id,Product__c,Referral_Date__c,Order__r.Sale_Type__c, opportunity__r.Referring_Partner_Account__r.Partner_Agreement__c,
                                                          Partner_Tiers__c,Partner_Types__c,Cloud_C_Line__c,X1stLine_Support__c,Contract_Year__c,Product_Line__c,MultiYear__c,MDF_Eligible__c,
                                                          Invoice__r.Inv_Date__c,Referring_Product__c from SPP_RR_Order_Detail__c where Id in : lstSPPOrderDetails and Opportunity__r.type != 'Resell Business'];
            
            if(!orderDetailJSON.isEmpty())
            {                                        
                for(SPP_RR_Order_Detail__c oDC : orderDetailJSON)
                {
                    
                    Date refdt=oDC.Referral_Date__c;
                    Date Invdt=oDC.Invoice__r.Inv_Date__c;
                    Sage_Cloud_Product__mdt objCloud = new Sage_Cloud_Product__mdt();
                        
                    String strRefdt = refdt != null ?DateTime.newInstance(refdt.year(),refdt.month(),refdt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''):null;
                    
                    String strInvdt = Invdt != null ?DateTime.newInstance(Invdt.year(),Invdt.month(),Invdt.day()).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''):null;
                    
                    system.debug('oDC.Referring_Product__c>>>'+oDC.Referring_Product__c);
                    
                    system.debug('strRefdt>>>'+strRefdt);
                    
                    system.debug('oDC.Product__c>>>'+oDC.Product__c);
                    
                    system.debug('mapReferredProduct.ContainsKey(oDC.Referring_Product__c)>>>'+mapReferredProduct.ContainsKey(oDC.Referring_Product__c));
                    
                    system.debug('mapSoldProduct.ContainsKey(oDC.Product__c)>>>'+mapSoldProduct.ContainsKey(oDC.Product__c));
                    
                    for(String strSoldProd : mapSoldProduct.Keyset())
                        {
                              if(oDC.Product__c.Contains(strSoldProd))//Check for Financials, Accounting,Accounting Start
                              {
                                 //soldProdFound = true;
                                 objCloud = mapSoldProduct.get(strSoldProd);
                                 break;
                              
                              }
                        }
                        
                    orderDetailWr.add(new SPPReferralOrderDetailWrapper(oDC.Partner_Tiers__c,
                                                                        oDC.Cloud_C_Line__c,
                                                                        oDC.Contract_Year__c,
                                                                        mapReferredProduct.ContainsKey(oDC.Referring_Product__c)?mapReferredProduct.get(oDC.Referring_Product__c).Referred_Cloud_C_line_product__c:'',
                                                                        objCloud.Sold_Cloud_C_line_product__c,
                                                                        //Integer.valueOf(mapSoldProduct.get(oDC.Product__c).Sold_Product_Referral_Threshold__c),
                                                                        Integer.ValueOf(objCloud.Sold_Product_Referral_Threshold__c),
                                                                        strInvdt,
                                                                        strRefdt,
                                                                        oDC.id,
                                                                        oDC.opportunity__r.Referring_Partner_Account__r.Partner_Agreement__c));
                    
                }
                
                String JSONString = JSON.serialize(orderDetailWr);
                System.debug('JSON String :'+JSONString);
                String straddReqID='{"RequestId": "'+GUIDHelper.generateGUID()+'","Async": "false","CallbackUrl": "","Orders":'+JSONString+'}';
                System.debug('List of values passing to Mulesoft:'+straddReqID);
                SPPReferralConnectionMulesoftController.ReferralOrderDetailList(straddReqID);
            }
        }
        catch(Exception e)
        {     
            ExceptionHandler.CatchException('SPPReferralOrderDetailQueueable', 'Execute', e);
        }
	}
}