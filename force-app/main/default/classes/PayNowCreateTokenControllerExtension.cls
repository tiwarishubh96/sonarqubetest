public class PayNowCreateTokenControllerExtension {
    private final zqu__Quote__c quote;
    public List<zqu__Quote__c> listQuote{get; set;}
    public List<Attachment> listOfAttachments{ get; set;}
    public String quoteId {get; set;}
    public String opportunityId {get; set;}
    public String selectedPDF {get; set;}
    public boolean hasPdfAttachments { get; set;}
    public boolean hasValidPaymentMethod { get; set; }
    public String message { get; set;}
    private string status;
    public boolean isInConsole {get; set;}
    public boolean quoteHasReceivedPaymentMethod { get; set;}
    
    
    public payNowCreateTokenControllerExtension(ApexPages.StandardController stdController) {
        this.quote = (zqu__Quote__c)stdController.getRecord();
        quoteId = this.quote.Id;
        listQuote = [SELECT ID, Name, zqu__PaymentMethod__c, Zuora_Country_Code__c, zqu__Number__c, zqu__Status__c, zqu__InitialTerm__c, zqu__RenewalTerm__c, zqu__ValidUntil__c, zqu__BillToContact__c, zqu__Previewed_Total__c, zqu__Opportunity__c FROM zqu__Quote__c WHERE ID = :this.quote.Id ];
        
        opportunityId = listQuote[0].zqu__Opportunity__c;
        
        listOfAttachments = [select Id, Name, Body, ContentType, CreatedDate from attachment where name like '%pdf' and ParentId =: opportunityId order by CreatedDate desc];
        
        Contact billingContact = [select id, MailingCountry, MailingCountryCode from Contact where Id IN
                (select zqu__BillToContact__c
                from zqu__Quote__c
                where id =: quoteId)];
        
        hasValidPaymentMethod = checkHasValidPaymentMethod(billingContact.MailingCountry, billingContact.MailingCountryCode, listQuote[0].zqu__PaymentMethod__c);
        
        List<PayNowToken__c> currentTokens = [Select Id, PayNowRedirectUrl__c, Status__c, Quote_Payment_Method_ID__c From PayNowToken__c Where Quote__c =: this.quote.Id Order By SystemModStamp Desc];

        System.debug('currentTokens.isEmpty()='+currentTokens.isEmpty());
        
		if(currentTokens.isEmpty()){
            quoteHasReceivedPaymentMethod = false;
	        System.debug('quoteHasReceivedPaymentMethod='+quoteHasReceivedPaymentMethod);
            return;
        }
        
        string paymentMethodId = currentTokens.get(0).Quote_Payment_Method_ID__c;
        System.debug('paymentMethodId='+paymentMethodId);
        
        quoteHasReceivedPaymentMethod = String.isNotBlank(paymentMethodId);
        System.debug('quoteHasReceivedPaymentMethod='+quoteHasReceivedPaymentMethod);
    }
    
    public boolean checkHasValidPaymentMethod(string countryName, string countryCode, string paymentType)
    {
        boolean result = true;
        
        //If credit card return true.  All countries can use credit cards.
        IF(paymentType == 'Credit Card')
        {
            return result;
        }
        
        //Ireland Test
        //Ireland can have credit card or SEPA
        IF(countryCode == 'IE' && paymentType != 'Bank Transfer')
        {
            result = false;
        }
        
        //US Test
        //US can have credit card or ACH
        IF(countryCode == 'US' && paymentType != 'ACH')
        {
            result = false;
        }
        
        //UK Test
        //UK can have credit card or DD
        IF(countryCode == 'GB' && paymentType != 'Bank Transfer')
        {
            result = false;
        }
        
        IF(!result)
        {
            string errorMessage = 'Payment method ' +  paymentType + ' is not vaild for country ' + countryName;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
        }
        
        return result;
    }
    
    public pageReference createPayNowToken() {
        System.debug('Test createPayNowToken');
        try{
            string jsonPayload = PayNowTokenRetriever.getPayNowPurchaseRequest(quoteId, selectedPDF, null);
            
            //Derive the emailTemplate name from the Json.
            //Modified 2016-08-14 Docmation
            JSONParser parser = JSON.createParser(jsonPayload);
        	String emailTemplate;

            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                    (parser.getText() == 'emailTemplateName')) {
                    // Get the value.
                    parser.nextToken();
                    // assign the value
                    emailTemplate = parser.getText();
                    break;
                }
            }
            system.debug('emailTemplate =' + emailTemplate);
                
            
            PayNowToken__c paynowResponse = PayNowTokenRetriever.createPayNowPurchaseToken(quoteId, jsonPayload);            
            
            System.debug('Preparing to send email.');
            status = 'Sent';
            
            Contact newContact = [select id, email from Contact where Id IN
                (select zqu__BillToContact__c
                from zqu__Quote__c
                where id =: quoteId)];
            
            zqu__Quote__c quote = [select External_Application__c
                from zqu__Quote__c
                where id =: quoteId];
             
             boolean isTetris = false;
            
              if (quote.External_Application__c == 'Tetris'){
                  isTetris = true;
              }
            
            //paynowResponse.Products__c = 'Accounting';
            //update(paynowResponse);
            
            //Contact billToContact = [select id from Contact where id =: quote.zqu__BillToContact__c];
            string emailRecipient = newContact.Email;            
            //message = 'Email sent to: ' + emailRecipient;
            
            PayNowEmailer.sendPayNowEmail(paynowResponse.Id, newContact.Id, emailTemplate,isTetris,paynowResponse.Email_Template_Variable__c);
            System.debug('Email sent to: ' + emailRecipient);
            
            paynowResponse.Status__c = 'Sent';
            update(paynowResponse);
                        
            
        }
        catch(Exception ex)
        {
            message = 'Error: ' + ex;
            System.debug('Error getting PayNow Token: ' + ex);

            string errorMessage = 'Error sending email. Please try again later or contact your administrator.';
            
            if(ex.getMessage().contains('INVALID_EMAIL_ADDRESS'))
                errorMessage = 'Error sending email. Invalid email address.';
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            return null;
        }
        
        PageReference pageRef;
        if(isInConsole)
        {
            pageRef = new PageReference('/' + quoteId + '?isdtp=vw');
        }
        else
        {
            pageRef = new PageReference('/' + quoteId);
        }
        
        
        return pageRef;
    }

}