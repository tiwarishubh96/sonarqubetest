/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          06/15/2017
    Company:       
    Description:   Class to generte Invoice pdf by Parnter 
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
public class SPPCommissionInvoiceController 
{  
    //Move to Production
    public Map<String,Sage_Sales_Office__mdt> mapSageSalesAdd {get;set;}
    
    public Map<String, Decimal> mapCodeAndRate {get;set;}
    
    public List<SPP_RR_Order__c> listOrder {get;set;}
    
    public Decimal invoiceCurrencyRate {get;set;}
    
    public Decimal partnerCurrencyRate {get;set;}
    
    public Decimal newCurrencyRate {get;set;}
    
    public String partnerLang {get;set;}
    
    public Date dtInvoiceStartDate {get;set;}
    
    public Date dtInvoiceEndDate {get;set;}
    
    public SPP_Commission_Invoice__c currentSPPInvoice {get;set;}
    
    public SPPCommissionInvoiceController(){}
    
    public SPPCommissionInvoiceController(ApexPages.StandardController controller) 
    {
        mapSageSalesAdd =new Map<String,Sage_Sales_Office__mdt>();
        
        mapCodeAndRate = new Map<String, Decimal>();
        
        listOrder = new List<SPP_RR_Order__c>();
        
        Map<ID,Sage_Sales_Office__mdt> allSalesOffLoc = new Map<ID,Sage_Sales_Office__mdt>([SELECT ID,Payment_Entity__c,DeveloperName,MasterLabel,Address__c,Payment__c
        ,Support_Phone__c,Support_Email__c FROM Sage_Sales_Office__mdt]);
        
        for(Sage_Sales_Office__mdt obj : allSalesOffLoc.values())
        {
          
            mapSageSalesAdd.put(obj.MasterLabel,obj);
        
        }
        
        this.currentSPPInvoice = (SPP_Commission_Invoice__c)controller.getRecord();
        
        this.currentSPPInvoice = [Select Id,AP_Comission__c,Total_Amount__c, currencyISOCode, Partner_Account__r.Locale__r.Name from SPP_Commission_Invoice__c where Id =: this.currentSPPInvoice.Id];
        
        getlanguage();
        
        findCommisionInvoicePeriod(system.today());

    }
    
     public list<SPP_RR_Order__c> getRROrderByInvoice()
     {
         listOrder = [SELECT Name,Id,Commission_Amount__c,Commission_Payable__c,Invoiced__c,Opportunity__c,Opportunity__r.Account.Name,Opportunity__r.Referring_Partner_Account__r.Locale__r.CurrencyIsoCode,
                      Opportunity__r.Referring_Partner_Account__r.Locale__c,Sale_Type__c,SPP_AP_Commission__c,Invoice__c,Order_Amount__c 
                      FROM SPP_RR_Order__c WHERE SPP_AP_Commission__c= :ApexPages.currentPage().getParameters().get('id')]; 
        
         system.debug('listOrder::'+listOrder);
         
         getCurrencyRate();
         
         return listOrder;
     }
    //Lu 02/28/2018 
    public void getCurrencyRate(){
        
        system.debug('listOrder::**'+listOrder);
        
        mapCodeAndRate = SPPUtils.mapCountryCodeAndRate();
        
        System.debug('mapCodeAndRate:::'+mapCodeAndRate);
        
        if(mapCodeAndRate.containsKey(this.currentSPPInvoice.CurrencyIsoCode)){
                
            invoiceCurrencyRate = mapCodeAndRate.get(this.currentSPPInvoice.CurrencyIsoCode);
            
            System.debug('invoiceCurrencyRate::'+invoiceCurrencyRate);
            
        }
        
        for(SPP_RR_Order__c so: listOrder){

            if(mapCodeAndRate.containsKey(so.Opportunity__r.Referring_Partner_Account__r.Locale__r.CurrencyIsoCode)){
                
                partnerCurrencyRate = mapCodeAndRate.get(so.Opportunity__r.Referring_Partner_Account__r.Locale__r.CurrencyIsoCode);
                
                System.debug('partnerCurrencyRate::'+partnerCurrencyRate);
                
                break;
                
            }
        }
        
        //New Currency rate based on org currency rate calculation
        if(partnerCurrencyRate != Null && partnerCurrencyRate !=0){
            
        	newCurrencyRate =  invoiceCurrencyRate/partnerCurrencyRate;
        }
    
    }
    //Lu 03/23/2018
    public void getlanguage(){ 
        
        //Set the PDF language based on referring partner locale. If the locale is empty, set it to en_US
        partnerLang = this.currentSPPInvoice.Partner_Account__r.Locale__r.Name == Null? 'en_US': this.currentSPPInvoice.Partner_Account__r.Locale__r.Name;
        
        system.debug('partnerLang::'+partnerLang);
        
    }
     
     //find the invoice period based on the Invoice Billing Date
     public void findCommisionInvoicePeriod(Date dtInvoice)
     {
           Integer intYear = Date.Today().Year() ;
           
           if(dtInvoice > Date.newInstance(intYear,01,01) && dtInvoice < Date.newInstance(intYear,03,31))
           {  
              dtInvoiceStartDate = Date.newInstance(intYear,01,01);
              dtInvoiceEndDate =   Date.newInstance(intYear,03,31);
           }
           else if(dtInvoice > Date.newInstance(intYear,04,01) && dtInvoice < Date.newInstance(intYear,06,30))
           {  
              dtInvoiceStartDate = Date.newInstance(intYear,04,01);
              dtInvoiceEndDate =   Date.newInstance(intYear,06,30);
           }
           else if(dtInvoice > Date.newInstance(intYear,07,01) && dtInvoice < Date.newInstance(intYear,09,30))
           {  
              dtInvoiceStartDate = Date.newInstance(intYear,07,01);
              dtInvoiceEndDate = Date.newInstance(intYear,09,30);
           }
           else if(dtInvoice > Date.newInstance(intYear,10,01) && dtInvoice < Date.newInstance(intYear,12,31))
           {  
              dtInvoiceStartDate = Date.newInstance(intYear,10,01);
              dtInvoiceEndDate = Date.newInstance(intYear,12,31);
           }
           
     } 
    
}