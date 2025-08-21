public interface ICustomMetadataTypeDAO {


	//// Mule Base URL that the other configs can reference
	Callout_Configuration__mdt getMuleBaseEndpoint();


	//// Mule Tax calculations
	//		/tax
	Callout_Configuration__mdt getMuleToAvalaraTaxCalc();


	//// Mule Zuora operations
	// 		/zuora/account
	Callout_Configuration__mdt getMuleToZouraAccountCreate();
	Callout_Configuration__mdt getMuleToZouraAccountUpdate();
	// 		/zuora/contact
	Callout_Configuration__mdt getMuleToZouraContactCreate();
	//2017-04-01: old subscribe call 
	//		/zuora/subscribe
	Callout_Configuration__mdt getMuleToZouraSubscribe(); 
	//2017-04-01: new dynamic subscription call 
	//		/zuora/subscribe-integrate
	Callout_Configuration__mdt getMuleToZouraDynamicSubscribe();


	//// Mule Address Validation operations
	//		/address-autocompletion
	Callout_Configuration__mdt getMuleToInformaticaAddressValidation();

	//// Mule Sage One email address check
	//2017-04-01: Used for calling 
	//		/validate-email
	Callout_Configuration__mdt getMuleToSageOneEmailValidation();


	//// Mule Product Provisioning
	//2017-04-01: Used for calling 
	//		/api/subscription
	Callout_Configuration__mdt getMuleToProductProvisioning();



	//// Zuora Hosted Payment Page URLs
	//2017-04-02
	Callout_Configuration__mdt getZuoraSignatureEndpoint();
	Callout_Configuration__mdt getZuoraHostedPaymentPage();

	//// Sage One Sign On URL
	//2017-04-02
	Callout_Configuration__mdt getSageOneSignOnUrl();

	//// Tokenized Conversion URL (for conversion operation)
	//2017-04-02
	Callout_Configuration__mdt getTokenizedPaymentUrl();

	//// Google reCAPTCHA settings
	//2017-04-02
	Callout_Configuration__mdt getGoogleReCAPTCHASettings();


	//// Sage One convert re-entry endpoints
	//2017-04-11
	Callout_Configuration__mdt getSageOneConvertSuccessUrl();
	Callout_Configuration__mdt getSageOneConvertFailureUrl();

	List<Zuora_Payment_Page_Setting__mdt> getZuoraPaymentPageSettings();

	Analytics_Configuration__mdt getTealiumSettings();
}