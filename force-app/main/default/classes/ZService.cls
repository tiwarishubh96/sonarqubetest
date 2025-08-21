public class ZService {
    
    public class ZHPMAuthDetails {
        public Boolean success { get; set; }
        public String token { get; set; }
        public String signature { get; set; }
        public String key { get; set; }
        public String tenantId { get; set; }
    }
    
    public static void retrieveRESTAuthDetails() {
        //String domain = 'https://apisandbox-zforsf.zuora.com';
        String domain = 'https://apisandbox.zuora.com';
        String endpoint = '/apps/PublicHostedPageLite.do';
        String CORSRESTDomain = 'https://apisandbox-api.zuora.com';
        String CORSRESTAuthEndpoint = '/rest/v1/rsa-signatures';
        String userName = 'api.sf@sage.com.ws';
        String password = 'Test2007@1234@';
        
        ZClient.HPMAuthBody authBody = new ZClient.HPMAuthBody();
		authBody.uri = domain+endpoint;
		authBody.method = 'POST';         
        authBody.pageId = '2c92c0f94cffa04f014d23fcbd4f3f66';
        ZClient.RESTCalloutResult result = ZClient.restCallout(CORSRESTDomain+CORSRESTAuthEndpoint, 'POST', authBody, userName, password);
        System.debug('Rest auth creds...');
		ZService.ZHPMAuthDetails authDetails = (ZService.ZHPMAuthDetails) JSON.deserialize(result.responseBody, ZService.ZHPMAuthDetails.class);
        System.debug(authDetails);
        
    }
    
    
}