public class PayNowQuoteControllerExtension {
    private final zqu__Quote__c quote;
    private string link;
    private string status;
    private string message;
	private string paymentMethodId;    
    public boolean quoteHasReceivedPaymentMethod { get; set;}
    public boolean hasToken {get; set;}    
        
    public payNowQuoteControllerExtension(ApexPages.StandardController stdController) {
        this.quote = (zqu__Quote__c)stdController.getRecord();
        
        message = '';
        updateValues();        
                
    }
       
    private void updateValues() {
        try{
            
            quoteHasReceivedPaymentMethod = false;
            
            List<PayNowToken__c> currentTokens = [Select Id, PayNowRedirectUrl__c, Status__c, Quote_Payment_Method_ID__c From PayNowToken__c Where Quote__c =: this.quote.Id Order By SystemModStamp Desc];
            if(currentTokens.isEmpty()){
                link = 'Not Created';
                status = 'Not Created';
                hasToken = false;
                return;
            }
            
            link = currentTokens.get(0).PayNowRedirectUrl__c;
            status = currentTokens.get(0).Status__c;
            hasToken = true;
            message = '';
            
            paymentMethodId = currentTokens.get(0).Quote_Payment_Method_ID__c;
            System.debug('paymentMethodId='+paymentMethodId);
                
            if(String.isNotBlank(paymentMethodId))
            {
                quoteHasReceivedPaymentMethod = true;
            }
            System.debug('quoteHasReceivedPaymentMethod='+quoteHasReceivedPaymentMethod);
        }
        catch(Exception ex){
            ExceptionHandler.CatchException('PayNowQuoteControllerExtension', 'updateValues', ex);            
        }
    }
    
    public string getPayNowLink() {
        return link;
    }
    
    public string getStatus(){
        return status;
    }  
    
    public string getMessage()
    {
        return message;
    }
       
    
}