public with sharing class redirectToCommunityController {
	
	private enum IdentityProviderEnum {SAGEID,CLOUDID,FACEBOOK,GOOGLE,SALESFORCE, APPDIRECT, UNKNOWN}
	private Map<string,string> pageParams = ApexPages.currentPage().getParameters();
	private final CommunityRedirectorSettings__c  COMMUNUTY_REDIRECT_SETTINGS =  CommunityRedirectorSettings__c.getOrgDefaults();
	private final Organization orgDetails = [select Id, IsSandbox FROM Organization LIMIT 1];
	private string  REDIRECT_URL;
	private IdentityProviderEnum identityProvider = setIdentityProvider(pageParams.get('idProvider'));
	
	public PageReference AuthenticateUserForCommunity() {
	/*	https://ecomm2dev-sagegroup.cs100.force.com/community/apex/redirectToCommunity?
	 * accountContext=Rbzlo1ZS0FBlJ99PCLyx7Y1hRDo%3D
	 * &culture=en-US
	 * &idProvider=cloudid
	 * &isHelpPage=false
	 * &previousAccountContext=Z4cWotYSIPRO6%2FpdjccrpdRnze4%3D
	 * &previousIdProvider=sageid
	 * &startURL=%2Fs%2Fmy-subscription
/* https://ecomm2dev-sagegroup.cs100.force.com/community/apex/redirectToCommunity
  ?accountContext=VhW2LV6BpeL640BQcTbvPtPZLak%3D
  &culture=en-US
  &idProvider=sageId
  &isHelpPage=false
  &previousAccountContext=LK4dMBXlQe%2F21EzmziE%2BLa6vYzs%3D
  &startURL=%2Fs%2Fmy-subscription
*/
		PageReference pageRef = new PageReference(COMMUNUTY_REDIRECT_SETTINGS.DefaultErrorURL__c);		
		System.debug('*** AuthenticateUserForCommunity Entered ***');				
		if(pageParams.size() > 0) {
			System.debug('*** AuthenticateUserForCommunity: pageParams = ' + pageParams);
            System.debug('*** AuthenticateUserForCommunity: validateRequestParams = ' + validateRequestParams(pageParams));

			if(validateRequestParams(pageParams)) {
				
				System.debug('*** AuthenticateUserForCommunity: validateRequestParams was true.');				
				
				if(pageParams.get('isHelpPage') != null && pageParams.get('isHelpPage').toUpperCase() == 'TRUE') {
					pageRef = new PageReference(COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c + EncodingUtil.urlDecode(pageParams.get('startURL'),'UTF-8')); 						
					System.debug('*** isHelpPage was TRUE - AuthenticateUserForCommunity: pageRef URL = ' + pageRef.getUrl());					
					return pageRef;
				} 

				TokenResult result = this.ProcessToken(EncodingUtil.urlDecode(pageParams.get('accountContext'),'UTF-8'), pageParams.get('idProvider'));						
				
				System.debug('*** AuthenticateUserForCommunity: result: ' + result);
				System.debug('*** AuthenticateUserForCommunity: pageParams.get(accountContext): ' + pageParams.get('accountContext'));
				if(result.Success == true && (pageParams.get('accountContext') == result.Token || pageParams.get('accountContext') == result.TokenNewFormat)) {															
					pageRef = new PageReference(COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c + EncodingUtil.urlDecode(pageParams.get('startURL'),'UTF-8')); 						
					System.debug('*** AuthenticateUserForCommunity: pageRef URL = ' + pageRef.getUrl());
				} else {
                  	System.debug('*** REDIRECT_URL = ' + REDIRECT_URL);
                    System.debug('*** BaseURL__c = ' + COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c);
					pageRef = new PageReference(COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c+'/services/auth/sso/'+COMMUNUTY_REDIRECT_SETTINGS.SageIdSSOURL__c); 
					pageRef.getParameters().put('community',COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c);	
					pageRef.getParameters().put('startURL',pageParams.get('startURL'));		
                   // pageRef.getParameters().put('redirect_uri','https://sagegroup--ecomm2dev.my.salesforce.com/community/services/authcallback/Cloud_ID');
                    
					string scopeString = 'openid';
					if(identityProvider != IdentityProviderEnum.SALESFORCE) {
                        pageRef.getParameters().put('scope',scopeString);
						//scopeString += '&accountcontext=' +  pageParams.get('accountContext');
                        pageRef.getParameters().put('accountcontext',pageParams.get('accountContext'));
                        
						if(pageParams.get('previousAccountContext') != null) {
							//scopeString += '&previousAccountContext=' + pageParams.get('previousAccountContext');
                            pageRef.getParameters().put('previousAccountContext',pageParams.get('previousAccountContext'));
						}
                        
						if(pageParams.get('sageIdRegion') != null) {
							//scopeString += '&sageidregion=' + pageParams.get('sageIdRegion');
                            pageRef.getParameters().put('sageIdRegion',pageParams.get('sageIdRegion'));
						}
						if(pageParams.get('culture') != null) {
							string cultureValue = pageParams.get('culture');
							cultureValue =  cultureValue.replace('_','-');		
							//scopeString += '&culture=' + pageParams.get('culture');
                             pageRef.getParameters().put('culture',pageParams.get('culture'));
						}
						if(pageParams.get('appDirectAccID') != null) {
							//scopeString += '&appdirectaccid=' + pageParams.get('appDirectAccID');
                               pageRef.getParameters().put('appDirectAccID',pageParams.get('appDirectAccID'));
                            
						}
						
						//scopeString = EncodingUtil.urlEncode(scopeString,'UTF-8');					
						//pageRef.getParameters().put('scope',scopeString);		
						System.debug('*** scopeString: ' + scopeString);
					}
					
					System.debug('This user is authenticated.' + pageRef.getUrl());
					scopeString = scopeString.replace('+','%20'); 
				}
			}
		}
		return pageRef;
	}
	

	private TokenResult ProcessToken(string accountContextId, string pIdentityProvider) {		
		IdentityProviderEnum identityProvider = setIdentityProvider(pIdentityProvider);
		
//0011x000018eblyAAA:SageID:auth0|cd28a42d355a6c6fd76cac88a160bf917a955a25468deb40
        System.debug('*** ProcessToken: The accountContextId value is: ' + accountContextId);
		System.debug('*** ProcessToken: The identityProvider value is: ' + identityProvider);
		
		TokenResult tokenResult = new TokenResult();
		ID userId = UserInfo.getUserId();
        system.debug('%%%%%%%'+userinfo.getusername()+'%%'+ userinfo.getusertype());		User currentUserRecord = [select Id, AccountId, ContactId FROM User where Id = : userId];
		
		if(UserInfo.getUserType() == 'Guest') {			
		
			System.debug('*** ProcessToken: This user is a guest user so exiting method and sending error page request.');
		
			tokenResult.ErrorDescription = 'This user has no context and is required to login.';
			return tokenResult;
		}
		System.debug('*** currentUserRecord: ' + currentUserRecord);
		System.debug('*** currentUserRecord.AccountId : ' + currentUserRecord.AccountId );
		List<Account> accountRecords = [select Id,Name from Account where Id = : currentUserRecord.AccountId LIMIT 1];
		Account accountRecord;
		if(accountRecords.isEmpty())
		{
				tokenResult.ErrorDescription = 'No associated account was found.';
				return tokenResult;
		} else {
				accountRecord = accountRecords[0];
		}		
		
		System.debug('*** ProcessToken: accountRecord: ' + accountRecord);
		
		SageUserIdentityProvider__c sageUserIdentityProvider; //using single assignment from collection to avoid "has no rows error at runtime"
		List<SageUserIdentityProvider__c> sageUserIdentityProviders = [select Id,IdentityID__c, User__c,Account__c,IdentityProvider__c from SageUserIdentityProvider__c where User__c = : userId AND IdentityProvider__c = : pIdentityProvider];		
		
		System.debug('*** ProcessToken: sageUserIdentityProviders: ' + sageUserIdentityProviders);
		
		if(sageUserIdentityProviders.size() > 0)
		{
			sageUserIdentityProvider = sageUserIdentityProviders[0];
		
			System.debug('*** ProcessToken: sageUserIdentityProvider: ' + sageUserIdentityProvider);
		
			//we have a SageUserIdentityProvider__c record that matches the userId. 
			if(sageUserIdentityProvider.IdentityID__c != null) {
				tokenResult.IdentityProviderId = sageUserIdentityProvider.IdentityID__c;
				string token;
				Blob signature;
				//using the enum identityProvider we can now decide which processing to do.
                if(identityProvider == IdentityProviderEnum.SAGEID ||identityProvider == IdentityProviderEnum.CLOUDID){
                    System.debug('***CLOUDID V2 ProcessToken: Processing the token using Facebook, Google or SageId as the provider.');
                    System.debug('***CLOUDID V2 ProcessToken: Passing in sageUserIdentityProvider.IdentityID__c:' +sageUserIdentityProvider.Account__c + sageUserIdentityProvider.IdentityProvider__c + sageUserIdentityProvider.IdentityID__c);
                    //0011x000018eblyAAA:SageID:auth0|cd28a42d355a6c6fd76cac88a160bf917a955a25468deb40
                    //tokenResult.Token = redirectToCommunityController.generateToken(sageUserIdentityProvider.IdentityID__c + accountRecord.Id);
                    tokenResult.TokenNewFormat = redirectToCommunityController.generateToken(sageUserIdentityProvider.Account__c + ':' + sageUserIdentityProvider.IdentityProvider__c + ':' +  sageUserIdentityProvider.IdentityID__c);
                    tokenResult.Token = redirectToCommunityController.generateToken(sageUserIdentityProvider.IdentityID__c + accountRecord.Id);
                    tokenResult.Success = true;					
                }else if(identityProvider != IdentityProviderEnum.SALESFORCE && identityProvider != IdentityProviderEnum.UNKNOWN) {
                    //is Facebook, Google or SageId
                    
					System.debug('*** ProcessToken: Processing the token using Facebook, Google or SageId as the provider.');
					System.debug('*** ProcessToken: Passing in sageUserIdentityProvider.IdentityID__c:' + sageUserIdentityProvider.IdentityID__c + ' &  accountRecord.Id: ' + accountRecord.Id);
		
					tokenResult.Token = redirectToCommunityController.generateToken(sageUserIdentityProvider.IdentityID__c + accountRecord.Id);
					tokenResult.Success = true;					
				} else if(identityProvider == IdentityProviderEnum.SALESFORCE){		
		
					System.debug('*** ProcessToken: Processing the token using Salesforce.');					
					System.debug('*** ProcessToken: Passing in sageUserIdentityProvider.IdentityID__c: ' + sageUserIdentityProvider.IdentityID__c + ' &  UserInfo.getOrganizationId(): ' + UserInfo.getOrganizationId());		
		
					tokenResult.Token = redirectToCommunityController.generateToken(sageUserIdentityProvider.IdentityID__c);
					tokenResult.Success = true;
				} else {										
					tokenResult.ErrorDescription = 'The request provided an unknown identity provider.';
				}
			} else { 
				tokenResult.ErrorDescription = 'A SageUserIdentityProvider record was found but the IdentityID__c field was null.';
			}
		} else {			
			tokenResult.ErrorDescription = 'No matching SageUserIdentityProvider record was found for this user.';			
		}
		return tokenResult;
	}

	public static string generateToken(string value1) {		
		string token = value1;
		token = token.toLowerCase();				
		Blob signature = Crypto.generateDigest('SHA1',Blob.valueof(token));            
		token = EncodingUtil.base64Encode(signature);
		return token;			
	}	

	private IdentityProviderEnum setIdentityProvider(string pIdentityProvider) {
		if(pIdentityProvider == null) { return IdentityProviderEnum.UNKNOWN;}
		if(pIdentityProvider.toUpperCase() == 'FACEBOOK'){ REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.FacebookSSOURL__c); return IdentityProviderEnum.FACEBOOK; }
		else if(pIdentityProvider.toUpperCase() == 'GOOGLE'){REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.GoogleSSOURL__c);return IdentityProviderEnum.GOOGLE; }
        else if(pIdentityProvider.toUpperCase() == 'SAGEID' || pIdentityProvider.toUpperCase() == 'CLOUDID'){REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.SageIdSSOURL__c);return IdentityProviderEnum.SAGEID; }
		//else if(pIdentityProvider.toUpperCase() == 'CLOUDID'){REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.SageIDv2SSOURL__c);return IdentityProviderEnum.SageIDv2; }
        else if(pIdentityProvider.toUpperCase() == 'SALESFORCE'){REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.SalesforceSSOURL__c);return IdentityProviderEnum.SALESFORCE; }
		else if(pIdentityProvider.toUpperCase() == 'APPDIRECT'){REDIRECT_URL = returnFullSSOURL(COMMUNUTY_REDIRECT_SETTINGS.AppDirectSSOURL__c);return IdentityProviderEnum.APPDIRECT; }
		else{REDIRECT_URL = COMMUNUTY_REDIRECT_SETTINGS.DefaultErrorURL__c; return IdentityProviderEnum.UNKNOWN; }
		
	}

    private boolean validateRequestParams(Map<string,string> pQueryParams) {
    	
    
		//Manadetory Field
		if(pQueryParams.get('startURL') == null) {
			System.debug('startURL idProvider and accountContext params were not found.');
		
			return false;
		}

		
		if(Pattern.matches('^\\w+:\\/\\/.*', pQueryParams.get('startURL'))) {
			System.debug('startURL is not a relative URL.');			
			return false;
		}


		
		if(pQueryParams.get('isHelpPage') != null && pQueryParams.get('isHelpPage').toUpperCase() == 'TRUE') {
			system.debug('isHelpPage: true');
			return true;
		}	
	
		if(pQueryParams.get('idProvider').toUpperCase() != 'cloudid' && pQueryParams.get('idProvider').toUpperCase() != 'APPDIRECT' && pQueryParams.get('idProvider').toUpperCase() != 'FACEBOOK' && pQueryParams.get('idProvider').toUpperCase() != 'GOOGLE' && pQueryParams.get('idProvider').toUpperCase() != 'SAGEID' && pQueryParams.get('idProvider').toUpperCase() != 'SALESFORCE') {
			System.debug('pQueryParams.get(idProvider): ' + pQueryParams.get('idProvider'));
			System.debug('Facebook Google SageId Salesforce AppDirect idProvider value not found.');
			return false;
		}

		// AppDirect specific
		if(pQueryParams.get('idProvider').toUpperCase() == 'APPDIRECT' && String.isBlank(pQueryParams.get('appDirectAccID'))) {
			System.debug('pQueryParams.get(appDirectAccID): ' + pQueryParams.get('appDirectAccID'));
			System.debug('appDirectAccID is not found.');
			return false;
		}

		if(pQueryParams.get('accountContext').length() != 28) {			
			System.debug('accountContext length was not correct.');
			return false;
		}
        
        if(pQueryParams.get('previousAccountContext').length() != 28) {			
			System.debug('previousAccountContext length was not correct.');
			return false;
		}

		//Optional Fields
		if(pQueryParams.get('culture') != null) {			
			if(!COMMUNUTY_REDIRECT_SETTINGS.Cultures__c.contains(pQueryParams.get('culture'))) {
				System.debug('Unsupported culture value found.');
				return false;	
			}			
		}
	
		return true;
    }

    private string returnFullSSOURL(string pSSOProviderRelativePath) {
    	if(orgDetails.IsSandbox) {
            //return 'https://test.salesforce.com/services/auth/sso/' + UserInfo.getOrganizationId() + '/'  +  pSSOProviderRelativePath;
            return COMMUNUTY_REDIRECT_SETTINGS.BaseURL__c + '/services/auth/sso/' +  UserInfo.getOrganizationId() + '/'  +pSSOProviderRelativePath;
            //return 'https://sagegroup--ecomm2dev.my.salesforce.com/services/auth/sso/' + UserInfo.getOrganizationId() + '/'  +  pSSOProviderRelativePath;
    		//return 'https://test.salesforce.com/community/services/authcallback/Cloudid';
    		//return 'https://sagegroup--ecomm2dev.my.salesforce.com/services/authcallback/00D1x0000000WZmEAM/Cloud_ID';
    	} else {
    		return 'https://login.salesforce.com/services/auth/sso/' + UserInfo.getOrganizationId() + '/'  +  pSSOProviderRelativePath;
    	}


    	
    }
	public class TokenResult {
		public TokenResult() {
			Success = false;	
		}		
        public Boolean Success {get;set;}                
		public string Token {get;set;}	
        public string TokenNewFormat {get;set;}	 
		public string IdentityProviderId {get;set;}		
		public String ErrorDescription {get;set;}			
    }

}