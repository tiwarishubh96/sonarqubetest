/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:    This Classs is used to make a callout to Mulesoft to get the Margin
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
global with sharing class SPPResellConnectionMulesoftController 
{
    public static MuleResponse strMuleResp{get;set;}
    
    public static transient List<Messaging.SingleEmailMessage> allMails { get; private set; }
    
    public class Orders
    {
        public String RefId;
        public String NCASubAccel;
        public String CLineAccel;
        public String MultiYearAccel;
        public String FirstLineSupportAccel;
        public String MDF;
        public String Margin;
        public String TotalMargin;
        public String PartnerTier;
        public String PartnerType;
    }


    public class MuleResponse 
    {
        public String Id;
        public List<Orders> Orders;
        public List<Error> Error;
    }
    
    public class Error {
    
    }
    
    @future (callout=true)
    public static  void ResellOrderDetailListForPlugin(String jsonData)
    {
        SPPUtils.isCalledFromQuoteCharge = true;
        
        SPPUtils.isCalledFromQuoteRatePlanCharge = true;
        
        List<MuleResponse> lorders = new List<MuleResponse>();
            
        try
        {
            allMails = new List<Messaging.SingleEmailMessage>();
            
            System.debug('Request JSON :'+ jsonData);

            //Test authType Lu 10/06/2017
            String authType = 'OAuth';
            
            String JSONString = '';
                
			JSONString=MuleSoftUtils.CalltoMuleSoft(jsonData,'Mulesoft_Margin_Endpoint', authType);//response.getBody();

            system.debug('String: ' + JSONString);
            
            JSONParser parser = JSON.createParser(JSONString.replace('MDF%','MDF'));
            
            system.debug('String: ' + parser );

            /* @Rishu Garg (Docmation) Test case fix */
            //while (parser.nextToken() != null || Test.isRunningTest())
            while (parser.nextToken() != null)
            {
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
                {
                    // Read entire JSON object, including its array of items.
                    strMuleResp = (MuleResponse)parser.readValueAs(MuleResponse.class);  
                    lorders.add(strMuleResp);
                    system.debug( 'UserData' + strMuleResp);
                    system.debug( 'UserData lorders' + lorders);
                }
            }
            
           updateQuoteRatePlanChargeResellOrderDetail(lorders);
            
           SPPUtils.sendDebugEmail(allMails,'Margin',jsonData,JSONString);
                
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('SPPResellConnectionMulesoftController', 'ResellOrderDetailList', e);
        }
         
    }
        
    // Parse information from Mulesoft response and update Quote rate plan charge records
    public static void updateQuoteRatePlanChargeResellOrderDetail(List<MuleResponse> lorderlist)
    {
            System.debug('Entered Order Detail'+lorderlist);
        
            List<Id> ids=new List<ID>();
            
            Map<Id,zqu__QuoteRatePlanCharge__c> mapUpdatefinalVal = new Map<Id,zqu__QuoteRatePlanCharge__c>();
            
            Map<string,string> mapOppandTotalMargin = new Map<string,string>();
            
            for(MuleResponse con : lorderlist)
            {
                for(Orders custom : con.Orders)
                {
                    ids.add(custom.RefId);
                }
            }
           
            System.debug('Ids of response :'+ids);
            
        	List<zqu__QuoteRatePlanCharge__c> lstOrderDetails=[SELECT ID,Name,OPP_ID__c,Partner_Tier__c,zqu__Quantity__c,
                                                               			zqu__EffectivePrice__c,zqu__DiscountPercentage__c,Total_Margin__c
                                                               FROM zqu__QuoteRatePlanCharge__c 
                                                               WHERE ID IN:ids];
        	
        	system.debug('lstOrderDetails>>>'+lstOrderDetails);
        
            //Map of Quote Charge
            for(zqu__QuoteRatePlanCharge__c objSPPOrderDetail : lstOrderDetails) 
            {
              	mapUpdatefinalVal.put(objSPPOrderDetail.Id,objSPPOrderDetail);
            }
            
            try
            {
                for(MuleResponse con : lorderlist)
                {
                    for(Orders custom : con.Orders)
                    {
                        
                        system.debug('>>>>>>>>>>>>>'+ custom.RefId);
                        
                        zqu__QuoteRatePlanCharge__c obj = mapUpdatefinalVal.get(custom.RefId);
                        
                        system.debug('obj>>>>'+obj);
                        
                        system.debug('obj.zqu__Quantity__c>>>>'+obj.zqu__Quantity__c);
                        
                        //Mapping Mulesoft response with Quote charge record
                        obj.Total_Margin__c = Decimal.valueOf(String.ValueOf(custom.Margin).replace('%',''));
                        
                        system.debug('obj.Total_Margin__c>>>'+obj.Total_Margin__c);
                       
                        obj.Partner_Tier__c = custom.PartnerTier;
                        
                        system.debug('custom.RefId>>>'+custom.RefId);
                        
                        obj.Id = custom.RefId;
                        
                        system.debug('obj.name::'+obj.name);
                        
                        if(obj.name =='Partner Margin'){
                            
                            obj.zqu__EffectivePrice__c = Decimal.valueOf(String.ValueOf(custom.Margin).replace('%',''));
                            
                        }
                        
                         system.debug('obj.zqu__EffectivePrice__c::'+obj.zqu__EffectivePrice__c);
                    }
                }
                
                update lstOrderDetails;                 
            }
            catch(Exception e)
            {
                ExceptionHandler.CatchException('SPPResellConnectionMulesoftController', 'updateQuoteRatePlanChargeResellOrderDetail', e);
            }
    }
   

}