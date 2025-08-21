public class HttpUtil {

    public String invokeExternalService(String endpoint, String contentType, String requestMethod, String requestBody, Integer timeout) {
            HttpRequest request = new HttpRequest();
    		Http http = new Http();
    		request.setMethod(requestMethod);
    		request.setEndpoint(endpoint);
    		request.setHeader('Content-Type', contentType);
    		request.setTimeout(timeout);
    		request.setBody(requestBody);
    		HttpResponse response = http.send(request);
    		return response.getBody();
    }
    
    public String getElementValueFromJSON(JSONParser parser, String fieldName) {
        String elementValue = '';
    	while (parser.nextToken() != null) {
    		if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == fieldName)) {
    			String tokenName = parser.getText();
    			parser.nextToken();
    			String tokenValue = parser.getText();
    			System.debug('Token name ' + tokenName + ', Value ' + tokenValue);
                elementValue = tokenValue;
				break;
    		}
    	}
        return elementValue;
     }

    
}