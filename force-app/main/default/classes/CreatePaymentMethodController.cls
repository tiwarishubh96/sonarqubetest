public with sharing class CreatePaymentMethodController { 
    // The Zuora id of the payment page 
    //Modified 2016-07-28 Docmation LLC
    // - Replaced the page id retrieval based on the sobject fields rather than the harcoded payment page name.
    // - Added Payment_Method__c formula and Client_Code__c which are used in SOQL.
    //
    public String pageId { 
        get { 
            if(pageId == null) pageId = ''; 
            return pageId;   
        } 
        set; 
    } 
    public Boolean displayPage {get;set;} // if true display payment page else display error message
    
    // Constructor, determines the Zuora page Id based on payment method of the quote 
    public CreatePaymentMethodController(ApexPages.StandardController standardController) { 
            
        // Ensure the payment method & zuora country code fields are populated on the Quote sObject
        // (Can only add fields to the standardController if not running in test mode) 
        if(!Test.isRunningTest()) standardController.addFields(new List < String > {'zqu__PaymentMethod__c','Zuora_Country_Code__c', 'zqu__PaymentMethod__c', 'External_Application__c'});
           
        // Retrieve the quote 
        zqu__Quote__c quote = (zqu__Quote__c)standardController.getRecord(); 

        // Default displayPage to false
        displayPage = false;
        
        // Setup the query string to retrieve the Payment Page Id

        String paymentPageName; // Payment Page Name
        String zuoraCountryCode;
        String paymentMethod;
        String clientCode = 'CBC'; //Is there a way to derive this rather than hardcoding?
        
        if(quote != null) {
             
            if(String.isNotBlank(quote.External_Application__c) && quote.External_Application__c.Equals(Global_Constants.TETRIS) && quote.zqu__PaymentMethod__c.equals(Global_Constants.CREDIT_CARD)) {
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot collect Credit Card details. Please use the \'Email Payment Link\' option.'));
          		return;    
                
                //clientCode = quote.External_Application__c;
            }
            zuoraCountryCode = quote.Zuora_Country_Code__c; // Setup the Zuora Country Code query string
            paymentMethod = quote.zqu__PaymentMethod__c; // Setup the Payment Method query string
        
            // If running in test mode we won't have the Zuora Country Code or the Payment Method from the page so default them to 'US' and 'Credit Card'
            if(Test.isRunningTest()) {
                zuoraCountryCode = 'US';
                paymentMethod =  Global_Constants.CREDIT_CARD;
            }
            
            // Build the query string    
            //paymentPageName = 'CBC ' + zuoraCountryCode +' '+ paymentMethod +'%'; 
        }
        // Query for the Payment Page Id and Gateway Name
        List < zqu__HostedPageLiteSetting__c > settingList = [SELECT zqu__PageId__c, Payment_Gateway_Name__c 
                                                                FROM zqu__HostedPageLiteSetting__c 
                                                                WHERE Client_Code__c = :clientCode
                                                                  AND Country_Code__c = :zuoraCountryCode
                                                                  AND zqu__PaymentMethodType__c = :paymentMethod];
        
        system.debug('**** Payment Page: '+settingList);
        
        // Check that we only find one Payment Page for the 
        if(settingList != null && !settingList.isEmpty() && settingList.size()==1) 
        {
            if(settingList[0].Payment_Gateway_Name__c != null) // Check that the Gateway Name is populated.  (This is required in order to set the correct Payment Gateway on the Account in Zuora.)
            { 
                // All checks completed successfully so display the page
                displayPage = true;
                pageId = settingList[0].zqu__PageId__c; 
                
            } else // No Gateway name on the Payment Page record - display an error message
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_payment_page_gateway_is_blank));
                return; 
            }
        }
        else if(settingList != null && !settingList.isEmpty() && settingList.size()>1)  // Many matching payment page were found - display an error message
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_many_payment_page_found));
          return;    
        }         
        else  // No matching payment page was found - display an error message
        {
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,label.lbl_error_no_payment_page_found));
          return;    
        } 
        
       
  } 
}