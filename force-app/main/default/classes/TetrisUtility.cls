public class TetrisUtility {
    private static final String DEV_TETRIS_LOGIN = 'DEV_Tetris_R2_Mulesoft';
    private static final String PROD_TETRIS_LOGIN = 'PROD_Tetris_R2_Mulesoft';
    private static final String DEV_SLCS_LOGIN = 'DEV_SLCS_Endpoint';
    private static final String PROD_SLCS_LOGIN = 'PROD_SLCS_Endpoint';
    
    private static final String CANCEL = 'Cancel';
    private static final String REACTIVATE = 'Reactivate';
    private static final String SUSPEND = 'Suspend';
    private static final String RESUME = 'Resume';
    private static final String CANCEL_SLCS_SUBSCRIPTION = 'Cancel SLCS Subscription';
    private static final String CANCEL_ZUORA_SUBSCRIPTION = 'Cancel Zuora Subscription';
    private static Tetris_Login_Details__mdt tetrisLoginDetailsObj;
    
    private static Zuora.zApi zapi;


	// TODO factor this out to TetrisAuthentication
    public static MuleLoginVO oauthLogin() {
        tetrisLoginDetailsObj = fetchTetrisLoginDetails();

        HttpRequest req = new HttpRequest(); 
        String loginUri = String.valueOf(tetrisLoginDetailsObj.Login_URL__c);
        String clientId = tetrisLoginDetailsObj.Client_Id__c;
        String clientSecret = tetrisLoginDetailsObj.Client_Secret__c;
        String username = tetrisLoginDetailsObj.Username__c; 
		String password = tetrisLoginDetailsObj.Password__c;
        String granttype = tetrisLoginDetailsObj.Grant_Type__c;

        req.setMethod('GET');
        req.setEndpoint(loginUri);
        req.setHeader('granttype' , granttype);
        req.setHeader('clientid' , clientId);
        req.setHeader('clientsecret' , clientSecret);
        req.setHeader('username' , username);
        req.setHeader('password' , password);
        
        Http http = new Http();
        MuleLoginVO muleLoginVOObj = null;
        if(Test.isRunningTest())
        {
			muleLoginVOObj = new MuleLoginVO();
			muleLoginVOObj.access_token = 'sample_access_token';          
        }else
        {
            HTTPResponse res = http.send(req);
        
        	muleLoginVOObj = (MuleLoginVO)JSON.deserialize(res.getBody() , MuleLoginVO.class);
        }
        return muleLoginVOObj;
    }
    
    public static TetrisSubscriptionVO.Response callSLSCSubscriptionsAction(TetrisSubscriptionVO.Request tetrisSubscriptionRequest) {
	
        MuleLoginVO muleLoginVOObj = oauthLogin();
        system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
        if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
        {
            muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
        }
        String accessToken  = muleLoginVOObj.access_token;
        String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
        system.debug('---------instanceUrl-------------'+instanceUrl);
		String jsonBody = json.serialize(tetrisSubscriptionRequest); 
                  
        HttpRequest req = new HttpRequest(); 
 		req.setTimeout(120000 );
        req.setMethod('POST');
        if(CANCEL.equalsIgnoreCase(tetrisSubscriptionRequest.actionType))
      	{
            req.setEndpoint(instanceUrl+'/subscription/actions/cancel');
        }else if(REACTIVATE.equalsIgnoreCase(tetrisSubscriptionRequest.actionType))
        {
            req.setEndpoint(instanceUrl+'/subscription/actions/reactivate');
        }else if(SUSPEND.equalsIgnoreCase(tetrisSubscriptionRequest.actionType))
        {
            req.setEndpoint(instanceUrl+'/subscription/actions/suspend');
        }
        else if(RESUME.equalsIgnoreCase(tetrisSubscriptionRequest.actionType))
        {
            req.setEndpoint(instanceUrl+'/subscription/actions/resume');
        }        
        else if(CANCEL_SLCS_SUBSCRIPTION.equalsIgnoreCase(tetrisSubscriptionRequest.actionType))
        {
            req.setEndpoint(instanceUrl+'/subscription/actions/slcs/cancel');
        }

        req.setHeader('oauth_token', accessToken);
        req.setHeader('Content-Type' , 'application/json');
        
		req.setBody(jsonBody);
        system.debug('---------req-------------'+req);
        Http http = new Http();
        TetrisSubscriptionVO.Response response = null;
		if(Test.isRunningTest())
        {
            response = new TetrisSubscriptionVO.Response();
            response.success = 'true';
      	}else{
            HTTPResponse res = http.send(req);
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            response = (TetrisSubscriptionVO.Response)JSON.deserialize(res.getBody() , TetrisSubscriptionVO.Response.class);
        }
        return response;
    }
    
    public static TetrisSubscriptionVO.Response callZquotesOrderToQueue(ZQuotesCallout zQuotesCalloutParam) {

        TetrisSubscriptionVO.Response response = null;

        try {
            Map<String, String> errorMessageMap = new Map<String, String>();
            MuleLoginVO muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj-------------' + muleLoginVOObj);
            if (muleLoginVOObj == null || (muleLoginVOObj != null && muleLoginVOObj.access_token == null)) {
                muleLoginVOObj = oauthLogin();
                system.debug('---------muleLoginVOObj tried second time-------------' + muleLoginVOObj);
            }
            String accessToken = muleLoginVOObj.access_token;
            String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
            system.debug('---------instanceUrl-------------' + instanceUrl);


            String jsonBody = json.serialize(zQuotesCalloutParam);

            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setMethod('POST');

            req.setEndpoint(instanceUrl + '/zquotes-order');


            req.setHeader('oauth_token', accessToken);
            req.setHeader('Content-Type', 'application/json');

            req.setBody(jsonBody);
            system.debug('---------req-------------' + req);
            Http http = new Http();

            if (Test.isRunningTest()) {
                response = new TetrisSubscriptionVO.Response();
                response.success = 'true';
            } else {
                HTTPResponse res = http.send(req);
                System.debug('BODY: ' + res.getBody());
                System.debug('STATUS:' + res.getStatus());
                System.debug('STATUS_CODE:' + res.getStatusCode());

                if (res.getStatusCode() != 200) {
                    errorMessageMap.put(String.valueOf(res.getStatusCode()), res.getBody());
                    ExceptionHandler.logZuoraRecordProcessingErrors('TetrisUtility', 'callZquotesOrderToQueue', errorMessageMap);
                }
                response = (TetrisSubscriptionVO.Response) JSON.deserialize(res.getBody(), TetrisSubscriptionVO.Response.class);


            }
            return response;
        } catch(Exception e){
            ExceptionHandler.CatchException('TetrisUtility', 'callZquotesOrderToQueue', e);
            return response;
        }
    }


    public static TetrisValidateResult.Response callZquotesValidateOrderToQueue(ZQuotesValidateCallout zCalloutValidateParams) {

        TetrisValidateResult.Response response = null;

        try {
            Map<String, String> errorMessageMap = new Map<String, String>();
            MuleLoginVO muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj-------------' + muleLoginVOObj);
            if (muleLoginVOObj == null || (muleLoginVOObj != null && muleLoginVOObj.access_token == null)) {
                muleLoginVOObj = oauthLogin();
                system.debug('---------muleLoginVOObj tried second time-------------' + muleLoginVOObj);
            }
            String accessToken = muleLoginVOObj.access_token;
            String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
            system.debug('---------instanceUrl-------------' + instanceUrl);


            String jsonBody = json.serialize(zCalloutValidateParams);


            System.debug('jsonBody'+jsonBody);
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            req.setMethod('POST');

            req.setEndpoint(instanceUrl + '/zquotes-order/actions/validate');


            req.setHeader('oauth_token', accessToken);
            req.setHeader('Content-Type', 'application/json');

            req.setBody(jsonBody);
            system.debug('---------req-------------' + req);
            Http http = new Http();

            if (Test.isRunningTest()) {
                response = new TetrisValidateResult.Response();
                response.success = 'true';
            } else {
                HTTPResponse res = http.send(req);
                System.debug('BODY: ' + res.getBody());
                System.debug('STATUS:' + res.getStatus());
                System.debug('STATUS_CODE:' + res.getStatusCode());

                if (res.getStatusCode() != 200) {
                    errorMessageMap.put(String.valueOf(res.getStatusCode()), res.getBody());
                    ExceptionHandler.logZuoraRecordProcessingErrors('TetrisUtility', 'callZquotesValidateOrderToQueue', errorMessageMap);
                }
                response = (TetrisValidateResult.Response) JSON.deserialize(res.getBody(), TetrisValidateResult.Response.class);


            }
            system.debug('---------response-------------' + response);
            return response;
        } catch(Exception e){
            ExceptionHandler.CatchException('TetrisUtility', 'callZquotesValidateOrderToQueue', e);
            return response;
        }
    }
    
    public static TetrisSubscriptionVO.Response callMidTermPromotionAction(TetrisSubscriptionVO.Request tetrisSubscriptionRequest) {
	
        MuleLoginVO muleLoginVOObj = oauthLogin();
        system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
        if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
        {
            muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
        }
        String accessToken  = muleLoginVOObj.access_token;
        String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
        system.debug('---------instanceUrl-------------'+instanceUrl);
		String jsonBody = json.serialize(tetrisSubscriptionRequest); 
                  
        HttpRequest req = new HttpRequest(); 
 		req.setTimeout(120000 );
        req.setMethod('POST');
        req.setEndpoint(instanceUrl+'/subscription/actions/apply/promotion');
        req.setHeader('oauth_token', accessToken);
        req.setHeader('Content-Type' , 'application/json');
        
		req.setBody(jsonBody);
        system.debug('---------req-------------'+req);
        Http http = new Http();
        TetrisSubscriptionVO.Response response = null;
		if(Test.isRunningTest())
        {
            response = new TetrisSubscriptionVO.Response();
            response.success = 'true';
      	}else{
            HTTPResponse res = http.send(req);
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            response = (TetrisSubscriptionVO.Response)JSON.deserialize(res.getBody() , TetrisSubscriptionVO.Response.class);
        }
        return response;
    }
    
    public static TetrisAddressVerificationResponseVO validateAddress(TetrisAddressModel tetrisAddressModelObj ) {
        MuleLoginVO muleLoginVOObj = oauthLogin();
        system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
        if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
        {
            muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
        }
        String accessToken  = muleLoginVOObj.access_token;
        String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
        system.debug('---------instanceUrl-------------'+instanceUrl);
		String jsonBody = json.serialize(tetrisAddressModelObj); 
                  
        HttpRequest req = new HttpRequest(); 
 		req.setTimeout(120000 );
        req.setMethod('POST');
        req.setEndpoint(instanceUrl+'/address/actions/validate');
        req.setHeader('oauth_token', accessToken);
        req.setHeader('Content-Type' , 'application/json');
        
		req.setBody(jsonBody);
        system.debug('---------req-------------'+req);
        Http http = new Http();
        TetrisAddressVerificationResponseVO response = null;
		if(Test.isRunningTest())
        {
            response = new TetrisAddressVerificationResponseVO();
      	}else{
            HTTPResponse res = http.send(req);
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            response = (TetrisAddressVerificationResponseVO)JSON.deserialize(res.getBody() , TetrisAddressVerificationResponseVO.class);
        }
        return response;
    }
    
    public static TetrisAccountRequestVO.Response createZuoraAccount(TetrisAccountRequestVO.Request tetrisAccountRequestVO){
        TetrisAccountRequestVO.Response response = null;
        try
        {
            MuleLoginVO muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
            if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
            {
                muleLoginVOObj = oauthLogin();
                system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
            }
            String accessToken  = muleLoginVOObj.access_token;
            String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
            system.debug('---------instanceUrl-------------'+instanceUrl);
            String jsonBody = json.serialize(tetrisAccountRequestVO); 
                      
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000 );
            req.setMethod('POST');
            //req.setHeader('X-HTTP-Method-Override','PATCH');
            //req.setMethod('PATCH');
            req.setEndpoint(instanceUrl+'/account');
            req.setHeader('oauth_token', accessToken);
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(jsonBody);
            system.debug('---------req-------------'+req);
            Http http = new Http();
            
            if(Test.isRunningTest())
            {
                response = new TetrisAccountRequestVO.Response();
            }else{
                HTTPResponse res = http.send(req);
                System.debug('BODY: '+res.getBody());
                System.debug('STATUS:'+res.getStatus());
                System.debug('STATUS_CODE:'+res.getStatusCode());
                response = (TetrisAccountRequestVO.Response)JSON.deserialize(res.getBody() , 
                                TetrisAccountRequestVO.Response.class);
            }
        }catch(Exception expObj)
        {
            system.debug('----expObj----------'+expObj);
            system.debug('----expObj Stack Trace----------'+expObj.getStackTraceString());
            system.debug('----expObj line number----------'+expObj.getLineNumber());
			ExceptionHandler.CatchException('TetrisUtility', 'createZuoraAccount', expObj);
        }
        return response;
    }
    
    public static Object callCanfullfill(CanFullfillRequest tetrisCanfullfillObj ) {
        MuleLoginVO muleLoginVOObj = oauthLogin();
        Object returnObject = null;
        system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
        if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
        {
            muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
        }
        String accessToken  = muleLoginVOObj.access_token;
        String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
        system.debug('---------instanceUrl-------------'+instanceUrl);
		String jsonBody = json.serialize(tetrisCanfullfillObj); 
                  
        HttpRequest req = new HttpRequest(); 
 		req.setTimeout(120000 );
        req.setMethod('POST');
        req.setEndpoint(instanceUrl+'/product/actions/canfulfil');
        req.setHeader('oauth_token', accessToken);
        req.setHeader('Content-Type' , 'application/json');
        
		req.setBody(jsonBody);
        system.debug('---------req-------------'+req);
        Http http = new Http();

		if(Test.isRunningTest())
        {
            //returnObject = new Object();
      	}else{
            HTTPResponse res = http.send(req);
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            returnObject = JSON.deserializeUntyped(res.getBody());
            //response = JSON.deserialize(res.getBody();
        }
        return returnObject;
    }
    
    public static TetrisTrailExtensionVO callSLCSTrialExtension(String jsonBody, String slcsGroupId) {
        TetrisTrailExtensionVO response = null;
        Callout_Configuration__mdt callSLCSConfig = fetchSLCSLoginDetails();
		if(callSLCSConfig!=null)
        {
            String instanceUrl = callSLCSConfig.Endpoint_URL__c;
            system.debug('---------instanceUrl-------------'+instanceUrl);
            system.debug('---------jsonBody-------------'+jsonBody);
            HttpRequest req = new HttpRequest(); 
            req.setTimeout(120000 );
            req.setMethod('PUT');
            req.setEndpoint(instanceUrl+'/api/v1/subscriptions/'+slcsGroupId+'/updateeffectiveperiod');
            //TODO update cred
            String strOAuthToken = 'Basic '+callSLCSConfig.Authorization__c;
            system.debug('-----strOAuthToken-------------'+strOAuthToken);
            req.setHeader('Authorization', strOAuthToken);
            req.setHeader('Content-Type' , 'application/json');
            req.setBody(jsonBody);
            system.debug('---------req-------------'+req);
            system.debug('-----req header-------------'+req.getHeader('Authorization'));
            Http http = new Http();
            if(Test.isRunningTest())
            {
                response = new TetrisTrailExtensionVO();
     
            }else
            {
                HTTPResponse res = http.send(req);
                System.debug('BODY: '+res.getBody());
                System.debug('STATUS:'+res.getStatus());
                System.debug('STATUS_CODE:'+res.getStatusCode());
                response = (TetrisTrailExtensionVO)JSON.deserialize(res.getBody(),TetrisTrailExtensionVO.class);
            }
        }
        return response;
    }
    	public static String callSLCSReactivate(String slcsSubscriptionId) {
            String response = '';
	        Callout_Configuration__mdt callSLCSConfig = fetchSLCSLoginDetails();
			if(callSLCSConfig!=null)
	        {
	            String instanceUrl = callSLCSConfig.Endpoint_URL__c;
	            system.debug('---------instanceUrl-------------'+instanceUrl);
	            HttpRequest req = new HttpRequest(); 
	            req.setTimeout(120000 );
	            req.setMethod('PUT');
	            req.setEndpoint(instanceUrl+'/api/v1/subscriptions/'+slcsSubscriptionId+'/reactivate');
	            
	            String strOAuthToken = 'Basic '+callSLCSConfig.Authorization__c;
	            system.debug('-----strOAuthToken-------------'+strOAuthToken);
	            req.setHeader('Authorization', strOAuthToken);
	            req.setHeader('Content-Type' , 'application/json');
	            req.setHeader('Content-Length' , '0');
	            //req.setHeader('X-ActivityId' , GuidUtil.NewGuid());
	            system.debug('---------Request-------------'+req);
	            system.debug('-----Authorization-------------'+req.getHeader('Authorization'));
	            //system.debug('-----X-ActivityId-------------'+req.getHeader('X-ActivityId'));
	            Http http = new Http();
	            if(Test.isRunningTest())
	            {
	                response = 'Test Success';
	     
	            }else
	            {
	                HTTPResponse res = http.send(req);
                    //System.debug('STATUS_CODE:'+res.getStatusCode());
	                System.debug('---------res-------------'+res);
	                
                    //if(res.getStatusCode() > 299)
                    //{
                        response = res.getStatus();
                    //}
	            }
	        }
	        return response;
	    }    

    public static Callout_Configuration__mdt fetchSLCSLoginDetails(){
        Callout_Configuration__mdt tetrisSLCSObj = null;
        String strInstanceDetails = '';
        OrganizationDAO organizationDAOObj = new OrganizationDAO();
        if(organizationDAOObj.isRunningInSandbox()){
            strInstanceDetails = DEV_SLCS_LOGIN;
        }else
        {
            strInstanceDetails = PROD_SLCS_LOGIN;
        }
        system.debug('---strInstanceDetails----'+strInstanceDetails);
        List<Callout_Configuration__mdt> lstTetrisSLCSObj = [SELECT DeveloperName, Endpoint_URL__c,Username__c,
                                                             Password__c,Authorization__c FROM Callout_Configuration__mdt 
                                                             WHERE DeveloperName =: strInstanceDetails];
        if(lstTetrisSLCSObj!= null && lstTetrisSLCSObj.size()>0)
        {
            tetrisSLCSObj = lstTetrisSLCSObj[0];
        }
        return tetrisSLCSObj;
    }
    
	// TODO factor this out to TetrisAuthentication
    public static Tetris_Login_Details__mdt fetchTetrisLoginDetails(){
        Tetris_Login_Details__mdt tetrisLoginDetailsObj = null;
        String strURL = '';
        OrganizationDAO organizationDAOObj = new OrganizationDAO();
        if(organizationDAOObj.isRunningInSandbox()){
            strURL = DEV_TETRIS_LOGIN;
        }else
        {
            strURL = PROD_TETRIS_LOGIN;
        }
        system.debug('---strURL----'+strURL);
        List<Tetris_Login_Details__mdt> lstTetrisLoginDetailsObj = [SELECT DeveloperName, Client_Id__c, Tetris_API__c,
                                            Client_Secret__c, Grant_Type__c, Login_URL__c,Password__c,Username__c FROM 
                                            Tetris_Login_Details__mdt WHERE DeveloperName =: strURL];
        if(lstTetrisLoginDetailsObj!= null && lstTetrisLoginDetailsObj.size()>0)
        {
            tetrisLoginDetailsObj = lstTetrisLoginDetailsObj[0];
        }
        return tetrisLoginDetailsObj;
    }
    
    public class MuleLoginVO{
        public String access_token;
        public String refresh_token;
        public String token_type;
        public String expires_in1;
    }
    
    
    public class CanFullfillRequest{
        public String email{set;get;}
        public String sfUserLoginId {set;get;}
        public String identityProvider{set;get;}
        public String sku{set;get;}
        public List<TetrisCartItemTierModel> tier{set;get;}
        //public String tier{set;get;}
        public String source{set;get;}
    }
	
    //class to be used in the SBC sales process
    //where it will be need to do a callout
	public class ZQuotesCallout{
        public String quoteId {set;get;}
        public String contactId {set;get;}
        public String emailAddress {set;get;}
		public String opportunityId {set;get;}
        public String accountId {set;get;}
        public String userLocale {set;get;}
        public String zuoraSubscriptionNumber {set;get;}
		
    }

    //class to be used in the SBC sales process
    //where a callout to the validate the API will be done
    public class ZQuotesValidateCallout{
        public String contactId {set;get;}
        public String emailAddress {set;get;}
        public String opportunityId {set;get;}
        public String accountId {set;get;}
        public String userLocale {set;get;}
        public String contractEffectiveDate {set;get;}
        public List<ZQuotesValidateProducts> products {set;get;}
    }

    public class ZQuotesValidateProducts{
        public string sku {set;get;}
        public Decimal quantity {set;get;}
        public List<ZQuotesValidateProductTier> tier {set;get;}
    }

    public class ZQuotesValidateProductTier{
        public string tierAttribute {set;get;}
        public string tierQuantity {set;get;}
    }
	
	public static boolean isExecuting = false;

   public static TetrisSubscriptionVO.Response cancelZuoraSubscriptionsAction(TetrisSubscriptionVO.Request tetrisSubscriptionRequest) {
	
        MuleLoginVO muleLoginVOObj = oauthLogin();
        system.debug('---------muleLoginVOObj-------------'+muleLoginVOObj);
        if(muleLoginVOObj==null || (muleLoginVOObj!=null && muleLoginVOObj.access_token==null))
        {
            muleLoginVOObj = oauthLogin();
            system.debug('---------muleLoginVOObj tried second time-------------'+muleLoginVOObj);
        }
        String accessToken  = muleLoginVOObj.access_token;
        String instanceUrl = tetrisLoginDetailsObj.Tetris_API__c;
        system.debug('---------instanceUrl-------------'+instanceUrl);
		String jsonBody = json.serialize(tetrisSubscriptionRequest); 
                  
        HttpRequest req = new HttpRequest(); 
 		req.setTimeout(120000 );
        req.setMethod('POST');
        req.setEndpoint(instanceUrl+'/subscription/actions/cancelZuoraSubscription');
        req.setHeader('oauth_token', accessToken);
        req.setHeader('Content-Type' , 'application/json');
        
		req.setBody(jsonBody);
        system.debug('---------req-------------'+req);
        Http http = new Http();
        TetrisSubscriptionVO.Response response = null;
		if(Test.isRunningTest())
        {
            response = new TetrisSubscriptionVO.Response();
            response.success = 'true';
      	}else{
            HTTPResponse res = http.send(req);
            System.debug('BODY: '+res.getBody());
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            response = (TetrisSubscriptionVO.Response)JSON.deserialize(res.getBody() , TetrisSubscriptionVO.Response.class);
        }
        return response;
    }
    
    
    public static Boolean validateEmail(String email) {
		Boolean res = true;

        if(email == null || String.isEmpty(email)) { return false; }

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
		Pattern MyPattern = Pattern.compile(emailRegex);
		Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches())
        {
             res = false;
        }
        return res;	
	}
    
    @future(Callout=true)
	public static void callSendQuoteToTetrisQueue(Set<ID> quoteIds){
		string jsonStr;
		TetrisSubscriptionVO.Response calloutResponse;
        string subscriptionNumber;
        TetrisUtility.ZQuotesCallout zqCallout; 
        
        List<zqu__Quote__c> zQuotesNew = [Select Id, zqu__BillToContact__r.ID, zqu__BillToContact__r.Email, zqu__Opportunity__r.ID, 
                                          zqu__Account__r.ID, Account_Locale__c ,zqu__ZuoraSubscriptionID__c,zqu__Status__c,
                                          External_Application__c
                                               FROM zqu__Quote__c
                                               WHERE Id IN: quoteIds];
        
        
         for (zqu__Quote__c zQuoteNew : zQuotesNew) {

            System.debug('Subscription Number::'+zQuoteNew.zqu__ZuoraSubscriptionID__c);
            System.debug('Bill to Contact::'+zQuoteNew.zqu__BillToContact__c);
            System.debug('Bill to Contact Email::'+ zQuoteNew.zqu__BillToContact__r.Email);
            System.debug('Opportunity::'+ zQuoteNew.zqu__Opportunity__c);
            System.debug('Account::'+ zQuoteNew.zqu__Account__c);
            System.debug('Account Locale::'+ zQuoteNew.Account_Locale__c);
             
             System.Debug('**** Zuora API before request set ');
             Zuora.zApi.QueryRequest qr = new Zuora.zApi.QueryRequest();
             qr.zoql = 'SELECT name FROM subscription WHERE Id=\'' + zQuoteNew.zqu__ZuoraSubscriptionID__c + '\'';
             
             System.Debug('**** Zuora API after query set ');
             if(!Test.isRunningTest()) // Only call Zuora if not in test mode
             {
                 getApiStub();
                 //Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('SPPQuoteTriggerHandler');
                  System.debug('::getApiStub'+zapi);
                  System.Debug('**** Zuora API before zquery ');
                 Zuora.zApi.QueryResult queryResult = zapi.zquery(qr);
                 System.Debug('**** Zuora Subscription Number Method Query Result: ' + queryResult);
                 
                 if(queryResult.records.size() > 0){
                     System.Debug((String)queryResult.records.get(0).getValue('Name'));
                     subscriptionNumber = (String)queryResult.records.get(0).getValue('Name');
                     
                 }
             }

             zqCallout = new TetrisUtility.ZQuotesCallout();
             zqCallout.accountId = zQuoteNew.zqu__Account__c;
             zqCallout.userLocale = zQuoteNew.Account_Locale__c;
             zqCallout.emailAddress = zQuoteNew.zqu__BillToContact__r.Email;
         	 zqCallout.contactId = zQuoteNew.zqu__BillToContact__c;
             zqCallout.opportunityId = zQuoteNew.zqu__Opportunity__c;
             zqCallout.quoteId = zQuoteNew.Id;
             zqCallout.zuoraSubscriptionNumber = subscriptionNumber;
             
             calloutResponse = TetrisUtility.callZquotesOrderToQueue(zqCallout);
             System.Debug(calloutResponse);
             
         }
	}
    
    public static Zuora.zApi getApiStub() {
        if (zapi == null && !Test.isRunningTest()) {
            zapi = ZuoraUpdateUtility.loginToZuora('TetrisUtility');
        }
       
        return zapi;
    }
}