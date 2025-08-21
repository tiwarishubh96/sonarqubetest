global class TetrisPaymentModel extends TetrisBaseModel {
        
    global List<PaymentMethod> paymentMethods;

    global class PaymentMethod {
	    global String zTenantID;
	    global String zSignature;
	    	global String zToken;
	    	global String zKey;
	    	global String zURL;
	    	global String paymentType;
	    
        global String paymentPageId; 
        global Boolean isDefault;
        global String paymentGateway;
        global String countryLanguage;
        global String countryCurrency;
        global String countryCode;
    }
    

}