public with sharing class DefaultPaymentMethodCreationController{

    private Zuora__CustomerAccount__c billingAccount {get; set;}
    public boolean displayPaymentMethodForm {get; set;}
    public String chosenPaymentMethodId {get; set;}
    public List<SelectOption> paymentMethods {get; set;}
    public String zuoraCountryCode {get;set;}
    public String pageId { 
        get { 
            if(pageId == null) pageId = ''; 
            return pageId; 
        } 
        set; 
    } 

    public DefaultPaymentMethodCreationController(ApexPages.StandardController ctrl){
        
        billingAccount = (Zuora__CustomerAccount__c)ctrl.getRecord(); 
        //Get zuora country code from account 
        zuoraCountryCode = [select Zuora__Account__r.Zuora_Country_Code__c from Zuora__CustomerAccount__c where Id=:billingAccount.Id ].Zuora__Account__r.Zuora_Country_Code__c;
        displayPaymentMethodForm = false;

        paymentMethods = new List<SelectOption>();
        paymentMethods.add(new SelectOption('Credit Card', 'Credit Card'));
        paymentMethods.add(new SelectOption('ACH', 'ACH'));
        paymentMethods.add(new SelectOption('Bank Transfer', 'Bank Transfer'));
    }
    
    public PageReference next(){
       
        // Setup the query string to retrieve the Payment Page Id
        String paymentPageName;
        
        // If running in test mode we won't have the Payment Method from the page so default it to 'Credit Card'
        if(Test.isRunningTest()) chosenPaymentMethodId = 'Credit Card';
        
        paymentPageName = 'CBC '+zuoraCountryCode +' '+ chosenPaymentMethodId+'%';
                    
        // Query for the Payment Page Id and Gateway Name  
        List < zqu__HostedPageLiteSetting__c > settingList = [SELECT zqu__PageId__c, Payment_Gateway_Name__c FROM zqu__HostedPageLiteSetting__c WHERE  Name LIKE :paymentPageName];
        
        // Check that we only find one Payment Page for the query string
        if(settingList != null && !settingList.isEmpty() && settingList.size()==1) 
        { 
            if(settingList[0].Payment_Gateway_Name__c != null) // Check that the Gateway Name is populated.  (This is required in order to set the correct Payment Gateway on the Account in Zuora.)
            { 
                pageId = settingList[0].zqu__PageId__c;                 
            } else // No Gateway name on the Payment Page record - display an error message
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_payment_page_gateway_is_blank));
                return null;
            }
        } 
        else if(settingList != null && !settingList.isEmpty() && settingList.size()>1)  // Many matching payment page were found - display an error message
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_many_payment_page_found));
          return null;    
        }         
        else  // No matching payment page was found - display an error message
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_no_payment_page_found));
          return null;    
        }         
        // All checks completed successfully so display the form
        displayPaymentMethodForm = true;
        return null;
    }
    
    public PageReference cancel(){
        return (new ApexPages.StandardController(billingAccount)).view();
    }
}