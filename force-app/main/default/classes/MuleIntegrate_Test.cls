/**
 * Created by mike.jutzin on 4/26/2017.
 */

@IsTest
public class MuleIntegrate_Test {

	static testMethod void testConstructorAndPublicProperties() {
		MuleIntegrate mi = new MuleIntegrate();
		mi.resp = 'val';
		mi.ProdName = 'val';
		mi.NCA = true;
		mi.MultiYear = true;
		mi.ContLength = 42;
		mi.Price = 108;
	}

	static testMethod void testMakeAPICall() {
		Test.setMock(HttpCalloutMock.class, new GenericHttpResponseGenerator());
		MuleIntegrate mi = new MuleIntegrate();
		mi.makeAPICall();
	}

	static testMethod void testMakeAPICallout() {
		Test.setMock(HttpCalloutMock.class, new GenericHttpResponseGenerator());
		MuleIntegrate mi = new MuleIntegrate();
		mi.makeAPICallout();
	}
}