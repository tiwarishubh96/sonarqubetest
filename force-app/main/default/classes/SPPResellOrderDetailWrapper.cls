/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/3/2017
    Company:       
    Description:   Wrapper Class to create a Json object to send it to MuleSoft to process Commission/Margin
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

public with sharing class SPPResellOrderDetailWrapper 
{
    //public String SaleType {get;set;}
    //public String Partner {get;set;}
    
    public String PartnerTier {get;set;}
    //public String CloudCline {get;set;}
    //public String ContractYear {get;set;}
    //public String NCA {get;set;}
    //public String MultiYear{get;set;}
    //public String Subscription {get;set;}
    public id RefId {get;set;}
    public String Partnerlegalagreement {get;set;}
   
    public SPPResellOrderDetailWrapper()
    {
        
    }
    
    //add Partnerlegalagreement to the parameter list.
    public SPPResellOrderDetailWrapper(String SaleType,String Partner,
    String CloudCLine,String ContractYear,String NCA,String Multiyear,String Subscription,ID RefId)
     {
         /*
        this.SaleType =SaleType;
        this.Partner = Partner;
        this.CloudCLine=CloudCLine;
        this.ContractYear=ContractYear;
        this.NCA=NCA;
        this.Multiyear=Multiyear;
        this.Subscription=Subscription;
        this.RefId=RefId;
*/
    }
    
    public SPPResellOrderDetailWrapper(String PartnerTier, ID refId, String Partnerlegalagreement){
        
        this.PartnerTier = PartnerTier;
        
        this.RefId = RefId;
        
        this.Partnerlegalagreement = Partnerlegalagreement;
        
    }
   
}