/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:   Wrapper Class to create a Json object to send it to MuleSoft to process Commission/Margin
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

public with sharing class SPPReferralOrderDetailWrapper 
{
    //public String SaleType {get;set;}
    //public String PartnerType {get;set;}
    public String PartnerTier {get;set;}
    public String CloudCLine {get;set;}
    public String ContractYear {get;set;}
    public String ReferredProductLine {get;set;}
    public String SoldProductLine {get;set;}
    public Integer SoldProductReferralThreshold {get;set;}
    public String OrderDate {get;set;}
    public String ReferralDate {get;set;}
    public id RefId {get;set;}
    public String Partnerlegalagreement {get;set;}
    
   
    public SPPReferralOrderDetailWrapper()
    {
        
    }
    public SPPReferralOrderDetailWrapper(String PartnerTier,
    String CloudCLine,String ContractYear,String ReferredProductLine,String SoldProductLine,Integer SoldProductReferralThreshold,String OrderDate,
    String ReferralDate,ID RefId, String Partnerlegalagreement)
     {
        this.PartnerTier =PartnerTier;
        this.CloudCLine=CloudCLine;
        this.ContractYear=ContractYear;
        this.ReferredProductLine=ReferredProductLine;
        this.SoldProductLine=SoldProductLine;
        this.SoldProductReferralThreshold=SoldProductReferralThreshold;
        this.OrderDate=OrderDate;
        this.ReferralDate=ReferralDate;
        this.RefId=RefId;
        this.Partnerlegalagreement = Partnerlegalagreement;
    }
   
}