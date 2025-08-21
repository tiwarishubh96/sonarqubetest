/**
* @author Salesforce Cloud Services
* @date 2016
*
* @description Sage SSO API Wrapper for SageID , Facebook & Google Authentication Providers
*
*/
public without sharing class SageSSOUtil {
    
    public class SageAuthException extends Exception {}
    
    /*******************************************************************************************************
* @description Method to check if there is an existing sageID user for a given email.
* @param email Email Address to check SageID against
* @return List of UserIdentities from Sage
*/    
    public static List<SageUserIdentity> getSageIdentities(String email) {
        String url = 'IdentityManagementService/web/WebListUserIdentities';
        String body = '<ListUserIdentitiesRequest><Filter xmlns="http://sso.sage.com">' + email + '</Filter><FilterField xmlns="http://sso.sage.com">EmailAddress</FilterField><Offset xmlns="http://sso.sage.com">0</Offset><Count xmlns="http://sso.sage.com">1</Count></ListUserIdentitiesRequest>';
          System.debug('$$$ sagessocontroller sending url :'+url);
          System.debug('$$$ sagessocontroller sending body :'+body);
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', body);
        System.debug('$$$ sagessocontroller sending url :'+ responseBody.toXMLString());
        Integer totalUserEntities = Integer.valueOf(responseBody.getRootElement().getChildElement('Total', 'http://sso.sage.com').getText());
        if (totalUserEntities <= 0) {
            return null;
        }
        Dom.XmlNode[] identityElemList = responseBody.getRootElement().getChildElement('UserIdentities', 'http://sso.sage.com').getChildElements();
        List<SageUserIdentity> identityList = new List<SageUserIdentity>();
        for (Dom.XmlNode identityElem : identityElemList) {
            System.debug(identityElem.getName());
            identityList.add(new SageUserIdentity(identityElem));
        }
        return identityList;
    }

    public static string unregisterUser(String identityId) {
        String url = 'UserAccountManagementService/web/WebUnregisterFromWebApplication';
        String body = '<UnregisterFromWebApplicationRequest><IdentityId xmlns="http://sso.sage.com">' + identityId + '</IdentityId></UnregisterFromWebApplicationRequest>';
        System.debug('$$$ sagessocontroller sending url :'+url);
        System.debug('$$$ sagessocontroller sending body :'+body);
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', body);
        System.debug('$$$ sagessocontroller sending url :'+ responseBody.toXMLString());
        return responseBody.toXMLString();
    }
    
    /*******************************************************************************************************
* @description Method to get start URL in case of existing user registration flow
* @param userEntityId Sage Identity ID for existing user
* @param successUri Uri to handle success reponse post registration.
* @param failureUri Uri to handle failure response post registration.
* @return Start URL for existing user registration..
*/     
    public static String getStartUrlForExistingUserReg(String userEntityId, String successUri, String failureUri) {
        String url = 'WebSSOService/web/WebStartExistingUserRegistrationAttempt';
        String requestBody = '<StartExistingUserRegistrationAttemptRequest><SuccessUri xmlns="http://sso.sage.com">' + successUri.escapeXml() + '</SuccessUri><FailureUri xmlns="http://sso.sage.com">' + failureUri.escapeXml() + '</FailureUri><CancelAllowed xmlns="http://sso.sage.com">true</CancelAllowed><ExpectedUserIdentity xmlns="http://sso.sage.com">' + userEntityId + '</ExpectedUserIdentity></StartExistingUserRegistrationAttemptRequest>';
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', requestBody);
        String redirectUri = responseBody.getRootElement().getChildElement('RedirectUri', 'http://sso.sage.com').getText();
        System.debug(redirectUri);
        return redirectUri;
    }
    
    
    /*******************************************************************************************************
* @description Method to get failure reason in case of failure response from registration flow.
* @param resultId Result Id that is passed as param to failureURI from registration flow
* @return Failure Reason
*/ 
    public static String getExistingUserRegFailureReason(String resultId) {
        String url = 'WebSSOService/web/WebEndExistingUserRegistrationAttempt';
        String requestBody = '<EndRegistrationAttemptRequest><ResultId xmlns="http://sso.sage.com">' + resultId + '</ResultId></EndRegistrationAttemptRequest>';
        System.debug('xxreq' + requestBody);
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', requestBody);
        System.debug('xxresponsebody' + responseBody);
        return parseFailureReason(responseBody);
    }
    
    
    /*******************************************************************************************************
* @description Method to get start URL in case of new user registration flow
* @param displayName Display Name for New User
* @param emailAddress email Address to prefill in register form.
* @param failureUri Uri to handle failure response post registration.
* @return Start URL for existing user registration..
*/  
    public static String getStartUrlForNewUserReg(String displayName,  String emailAddress, String successUri, String failureUri) {
        String url = 'WebSSOService/web/WebStartNewUserRegistrationAttempt';
        String requestBody = '<StartNewUserRegistrationAttemptRequest><SuccessUri xmlns="http://sso.sage.com">' + successUri.escapeXml() + '</SuccessUri><FailureUri xmlns="http://sso.sage.com">'+ failureUri.escapeXml() +'</FailureUri><CancelAllowed xmlns="http://sso.sage.com">true</CancelAllowed><SignOnAfterSuccess xmlns="http://sso.sage.com">true</SignOnAfterSuccess><ActivateAfterSuccess xmlns="http://sso.sage.com">true</ActivateAfterSuccess></StartNewUserRegistrationAttemptRequest>';
        System.debug(requestBody);
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', requestBody);
        String redirectUri = responseBody.getRootElement().getChildElement('RedirectUri', 'http://sso.sage.com').getText();
        System.debug(redirectUri);
        return redirectUri;
    }
    
    
    
    /*******************************************************************************************************
* @description Method to get failure reason in case of failure response from New User registration flow.
* @param resultId Result Id that is passed as param to failureURI from registration flow
* @return Failure Reason
*/ 
    public static String getNewUserRegFailureReason(String resultId) {
        String url = 'WebSSOService/web/WebEndNewUserRegistrationAttempt';
        String requestBody = '<EndRegistrationAttemptRequest><ResultId xmlns="http://sso.sage.com">' + resultId + '</ResultId></EndRegistrationAttemptRequest>';
        Dom.Document responseBody = callSageSSOAPI(url, 'POST', requestBody);
        return parseFailureReason(responseBody);
    }
    
    /*******************************************************************************************************
* @description Method to insert Sage User Identity Map for a given user id and openid subject.
* @param userId Salesforce User Id
* @param subject OpenId Subject of format bridgeId:<provider>:identityId
*/ 
    public static void insertSageUserIdentityMap(Id userId, String subject){
        // Insert Bridge Service Mapping Entry for the account to user to Provider Mapping.
        String[] idSplit = subject.split(':');
        SageUserIdentityProvider__c sip = new SageUserIdentityProvider__c();
        sip.Account__c = idSplit[0];
        sip.IdentityID__c =  idSplit[2];
        sip.SFBridgeID__c =  subject;
        sip.Name =  subject;
        sip.User__c = userId;
        sip.IdentityProvider__c =  idSplit[1];
        insert sip;
    }

    /*******************************************************************************************************
* @description Method to user from Invitation
* @param invitationid Invitation Code (Invite_Code__c from Community_Membership__c)
* @return created user.
*/    
    public static User createUserFromInvitation(String invitationId){
        // Query Membership Details
        List<Community_Membership__c> membershipList =
            [SELECT Id, Contact__r.Name, Status__c, Contact__r.Account.Id, Contact__r.Email, Contact__r.Lastname, Contact__r.Firstname, Community__r.Default_User_Profile__c FROM Community_Membership__c WHERE Invite_Code__c = : invitationId and Expiration_Date__c >= Today];
        
        // If not a valid invitation, do not provision..
        if (membershipList == null || membershipList.size() <= 0) {
            return null;
        }
        
        Contact c = membershipList[0].Contact__r;
        
        // Check if contact already has a portal user.
        List<User> userList = [SELECT Id FROM User WHERE contactId = : c.Id];
        if (userLIst != null && userList.size() > 0) {
            return userList[0];
        }
        
        
        // Create User for the contact id.
        User u = new User();
        u.Username = c.email + '-' + c.Id;
        u.Email = c.email;
        u.Lastname = c.LastName;
        u.Firstname = c.Firstname;
        u.Alias = c.Lastname.substring(0, 3) + (c.FirstName != null ? c.Firstname.substring(0, 1) : '');
        if (u.Alias.length() > 8) {
            u.Alias = u.Alias.substring(0, 8);
        }
        u.CommunityNickname = c.Lastname + '+' + c.Id;
        if ( u.CommunityNickname.length() > 40) {
            u.CommunityNickname = u.CommunityNickname.substring(0, 40);
        }
        SObject prof = [ select Id from profile where name = :membershipList[0].Community__r.Default_User_Profile__c];
        u.ProfileId = (Id) prof.get('Id');
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.contactId = c.Id;
        insert u;
        
        membershipList[0].Status__c = 'Provisioned';
        update membershipList[0];
        
        return u;
    } 
    
    /*
* Method to end existing user Registration attempt.
*/
    /*	public static SageUserIdentity endExistingUserRegAttempt(String resultId) {
String url = 'WebSSOService/web/WebEndExistingUserRegistrationAttempt';
String requestBody = '<EndRegistrationAttemptRequest><ResultId xmlns="http://sso.sage.com">' + resultId + '</ResultId></EndRegistrationAttemptRequest>';
Dom.Document responseBody = callSageSSOAPI(url, 'POST', requestBody);
Dom.XmlNode successElement = responseBody.getRootElement().getChildElement('RegistrationSuccessResult', 'http://sso.sage.com');
if (successElement == null) {
Dom.XmlNode errorElement = responseBody.getRootElement().getChildElement('RegistrationFailedResult', 'http://sso.sage.com');
if (errorElement != null) {
throw new SageAuthException('Error Finishing Registration: ' + errorElement.getChildElement('Reason', 'http://sso.sage.com').getText());
} else {
throw new SageAuthException('Unknown Error Finishing Registration');
}
}
return new SageUserIdentity(successElement);
}*/
    
    // Utility Methods
    
    /*******************************************************************************************************
* @description Method to call Sage SSO API with XML Body.
* @param url Api URL relative to base url in Named Credential definition. e.g. IdentityManagementService/web/WebListUserIdentities
* @param method Http Method get/post
* @param xmlBodyString XML Body String
* @return XML Response as Dom.Document
*/
    private static Dom.Document callSageSSOAPI(String url, String method, String xmlBodyString) {
          System.debug('$$$ sagessocontroller In callSageSSOAPI:');
        Dom.Document xmlBody = new Dom.Document();
        xmlBody.load(xmlBodyString);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:SageSSOAPI/' + url);
        request.setMethod(method);
        request.setHeader('Content-Type', 'application/xml');
        request.setBodyDocument(xmlBody);
          System.debug('$$$ sagessocontroller In callSageSSOAPI request:'+ request);
        Http h = new Http();
        HttpResponse response = h.send(request);
             System.debug('$$$ sagessocontroller In callSageSSOAPI request:'+response.getBodyDocument());
        if (response.getStatusCode() > 299) {
                 System.debug('$$$ sagessocontroller In callSageSSOAPI request failed:');
            throw new SageAuthException('Failed to recieve a success code from remote. Code was: ' + response.getStatusCode() + ' request was ' + request + ' Response Body is: ' + response.getBody());
        }
      
        
     System.debug('$$$ sagessocontroller In callSageSSOAPI request:'+ response.getBodyDocument());
        return response.getBodyDocument();
    }
    
    /**
* Utility Method to parse failure reason for registration attempt failure response.
**/
    private static String parseFailureReason(Dom.Document regAttemptResponseBody){
        Dom.XmlNode errorElement = regAttemptResponseBody.getRootElement().getChildElement('RegistrationFailedResult', 'http://sso.sage.com');
        if (errorElement != null) {
            return errorElement.getChildElement('Reason', 'http://sso.sage.com').getText();
        } else {
        	errorElement = regAttemptResponseBody.getRootElement().getChildElement('RegistrationSuccessResult', 'http://sso.sage.com');
           	if (errorElement != null) {
        		Dom.XmlNode errorSubElement =  errorElement.getChildElement('FailedResult', 'http://sso.sage.com');
        		if (errorSubElement != null) {
        			return errorSubElement.getChildElement('Reason', 'http://sso.sage.com').getText();
        		}
        	}
        }
        return null;
    }
    
    
    
}