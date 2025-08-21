/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:    This Classs is used to make a callout to Mulesoft to get the commision 
    Inputs:        None
    History:		Lu, 10/06/2017, SPP-762 Update Mulesoft Authentication to oAuth
					Added a third param (string) when calling MuleSoftUtils.CalltoMuleSoft
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
global with sharing class SPPReferralConnectionMulesoftController 
{
    public static MuleResponse strMuleResp{get;set;}
    
    public static transient List<Messaging.SingleEmailMessage> allMails { get; private set; }
     
    public class Orders 
    {
        public String RefId;
        public String Commission;
        
    }

    public class MuleResponse 
    {
        public String Id;
        public List<Orders> Orders;
        public List<Error> Error;
        
    }
    public class Error {
        
        public String ReferenceId;
    }
    
    @future (callout=true)
    public static void ReferralOrderDetailList(String jsonData)
    {

        try
        {
            allMails = new List<Messaging.SingleEmailMessage>();
            System.debug('Request JSON :'+ jsonData);
        
            //Test authType Lu 10/06/2017
            String authType = 'OAuth';
            
 			Datetime requestTime = System.now();
            
            String JSONString=MulesoftUtils.CalltoMuleSoft(jsonData,'MuleSoft_Commission_Endpoint', authType);//response.getBody();
            
            SPPUtils.sendDebugEmail(allMails,'Commission','Start Time: '+requestTime
                                    +' '+jsonData,'End Time: '+system.now()+' '+JSONString);
            
            List<MuleResponse> lorders=new List<MuleResponse>();
            
            system.debug('String: ' + JSONString);

            if(Test.isRunningTest()){
                
                JSONString = '';
            }
            
			JSONParser parser = JSON.createParser(JSONString);
            
            system.debug('String: ' + parser );

            while (parser.nextToken() != null ) 
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
            
            System.debug('Updated Order List'+lorders);
            /*
            if(Test.isRunningTest()){
                

            }
            */
            updateReferralOrderDetail(lorders, jsonData+'\n\r\n\r'+JSONString);
        }
        catch(Exception e)
        {
            System.debug('Error :'+e.getMessage());
            ExceptionHandler.CatchException('SPPReferralConnectionMulesoftController', 'ReferralOrderDetailList', e);
        }
    }
    
    public static void updateReferralOrderDetail(List<MuleResponse> lorderlist, String JSONString)
    {
            System.debug('Entered Order Detail'+lorderlist);   
            
            List<Id> ids=new List<ID>();
            
            for(MuleResponse con : lorderlist)
            {
                for(Orders custom : con.Orders)
                {
                    ids.add(custom.RefId);
                }
                
                for(Error custom : con.Error)
                {
                    ids.add(custom.ReferenceId);
                }
            }
           
            System.debug('Ids of response :'+ids);
            
            List<SPP_RR_Order_Detail__c> lstOrderDetails=[Select ID,Commission__c from SPP_RR_Order_Detail__c where ID IN:ids];
            
            Map<Id,SPP_RR_Order_Detail__c> mapUpdatefinalVal = new Map<Id,SPP_RR_Order_Detail__c>();
            
            for(SPP_RR_Order_Detail__c objSPPOrderDetail : lstOrderDetails) 
            {
                mapUpdatefinalVal.put(objSPPOrderDetail.Id,objSPPOrderDetail);
            }
            
            try
            {
                for(MuleResponse con : lorderlist)
                {
                    for(Orders custom : con.Orders)
                    {
                        SPP_RR_Order_Detail__c obj = mapUpdatefinalVal.get(custom.RefId);
                        obj.Commission__c = Decimal.valueOf(String.ValueOf(custom.Commission).replace('%',''));     
                        obj.Id = custom.RefId;
                        //obj.MuleSoft_JSON__c = JSONString;
                    }
                    
                    for(Error custom : con.Error)
                    {
                        SPP_RR_Order_Detail__c obj = mapUpdatefinalVal.get(custom.ReferenceId);     
                        
                        obj.Id = custom.ReferenceId;
                    }
                }
                
                update lstOrderDetails; 
            }
            catch(Exception e)
            {
                ExceptionHandler.CatchException('SPPReferralConnectionMulesoftController', 'updateReferralOrderDetail', e);
            }
    }

}