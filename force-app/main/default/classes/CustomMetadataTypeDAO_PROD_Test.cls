/**
 * Created by mike.jutzin on 4/11/2017.
 */

@IsTest ( SeeAllData=true )
private class CustomMetadataTypeDAO_PROD_Test {
	static testMethod void testBehavior() {
		ICustomMetadataTypeDAO cmtdao = new CustomMetadataTypeDAO_PROD();

		try {
			cmtdao.getMuleBaseEndpoint();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToAvalaraTaxCalc();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraAccountCreate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraAccountUpdate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraContactCreate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraSubscribe();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraDynamicSubscribe();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToInformaticaAddressValidation();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToSageOneEmailValidation();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToProductProvisioning();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getZuoraSignatureEndpoint();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getZuoraHostedPaymentPage();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneSignOnUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getTokenizedPaymentUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getGoogleReCAPTCHASettings();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneConvertSuccessUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneConvertFailureUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getZuoraPaymentPageSettings();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getTealiumSettings();
		} catch ( QueryException e ) {
		}

		cmtdao = new CustomMetadataTypeDAO_DEV();

		try {
			cmtdao.getMuleBaseEndpoint();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToAvalaraTaxCalc();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraAccountCreate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraAccountUpdate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraContactCreate();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraSubscribe();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToZouraDynamicSubscribe();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToInformaticaAddressValidation();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToSageOneEmailValidation();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getMuleToProductProvisioning();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getZuoraSignatureEndpoint();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getZuoraHostedPaymentPage();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneSignOnUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getTokenizedPaymentUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getGoogleReCAPTCHASettings();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneConvertSuccessUrl();
		} catch ( QueryException e ) {
		}
		try {
			cmtdao.getSageOneConvertFailureUrl();
		} catch ( QueryException e ) {
		}
	}
}