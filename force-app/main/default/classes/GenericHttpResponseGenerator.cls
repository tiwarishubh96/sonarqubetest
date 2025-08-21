/**
 * Created by mike.jutzin on 4/3/2017.
 */

@IsTest
public class GenericHttpResponseGenerator implements HttpCalloutMock {

	String body = '{ "key" : "value" }';

	public GenericHttpResponseGenerator( ) { }
	
	public GenericHttpResponseGenerator( String body ) {
		setBody( body );
	}

	public void setBody( String body ) {
		this.body = body;
	}
	public HTTPResponse respond( HttpRequest req ) {
		HttpResponse res = new HttpResponse();

		res.setHeader( 'Content-Type', 'application/json' );
		res.setBody( body );
		res.setStatusCode( 200 );

		return res;
	}
}