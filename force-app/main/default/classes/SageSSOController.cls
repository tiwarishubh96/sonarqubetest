public without sharing class SageSSOController {

    public static final String VIEW_WELCOME = 'WELCOME';
    public static final String VIEW_REGISTER = 'REGISTER';
    CommunityAuthSettings__c authSettings = CommunityAuthSettings__c.getInstance();

    public String invitationId {
        public get {
            if (invitationId == null) {
                invitationId = ApexPages.currentPage().getParameters().get('invite');
            }
            return invitationId;
        }
        public set;
    }

    public String resultId {
        public get {return ApexPages.currentPage().getParameters().get('resultId');}
        public set;
    }

    public String regFailureReason {get; set;}

    public Community_Membership__c membershipInfo {
        public get{
            if (membershipInfo == null) {
                queryMembershipInfo();
            }
            return membershipInfo;
        }
        public set;
    }

    public SageUserIdentity sageIdentity {get; set;}

    public String currentView {get; set;}

    public Boolean isValidSageUser {get; set;}

    /*
     * Method to query Membership info based on Invitation Id (Name Field);
     */
    private void queryMembershipInfo() {
        System.debug('Querying Membership');
        if (invitationId != null && invitationId != '') {
            List<Community_Membership__c> membershipList =
                [SELECT Id, Name, Sage_SSO_Post_Register_Success_URL__c, Invite_Code__c, Sage_SSO_Post_Register_Failure_URL__c, Community__r.Name, Community__r.Community_Base_Url__c,Community__r.Invite_Page_Path__c, Contact__r.Name, Contact__r.Email, Contact__r.Account.Id FROM Community_Membership__c WHERE Invite_Code__c = :invitationId AND Status__c = 'Invited' and Expiration_Date__c >= Today];
            if (membershipList != null && membershipList.size() > 0) {
                membershipInfo = membershipList[0];
            }
        }
    }

    /*
    *  Init the invitation process.
    */
    public PageReference initInvite() {
        currentView = VIEW_WELCOME;
        if (invitationid != null && membershipInfo ==null) {
            queryMembershipInfo();
        }
        return null;
    }

    /*
    *  Handles Registration Success - Called on load of Successful registration by Sage ID
    */
    public PageReference handleSageIDRegSuccess() {
        return new PageReference(getSSOStartUrl(authSettings.SageIDAuthProviderName__c));
    }

    /*
    *   Action method to handle Registration failure.
    */
    public PageReference handleSageIDRegFailure() {
        if (resultId != null) {
            regFailureReason = SageSSOUtil.getExistingUserRegFailureReason(resultId);
            if (regFailureReason == 'AccountAlreadyRegistered') {
                return new PageReference(getSSOStartUrl(authSettings.SageIDAuthProviderName__c));
            } else if(regFailureReason == 'REGISTRATIONCANCELLED'){
                queryMembershipInfo();
                PageReference pg = new PageReference('/' + membershipInfo.Community__r.Invite_Page_Path__c);
                pg.getParameters().put('invite', invitationId);
                return pg;
            }
        }
        return null;
    }


    /*
    *  Handles Registration Success - Called on load of Successful registration by Sage ID
    */
    public PageReference handleFacebookConnect() {
        return new PageReference(getSSOStartUrl(authSettings.FacebookAuthProviderName__c));
    }

    /*
    *  Handles Registration Success - Called on load of Successful registration by Sage ID
    */
    public PageReference handleGoogleConnect() {
        return new PageReference(getSSOStartUrl(authSettings.GoogleAuthProviderName__c));
    }

    /*
    *  Get SSO Start URL for Auth Provider
    */
    private String getSSOStartUrl(String providerDevName) {
        String communityUrl = membershipInfo.Community__r.Community_Base_Url__c;
        String ssoUrl = Auth.AuthConfiguration.getAuthProviderSsoUrl(communityUrl, '', providerDevName);
        return ssoUrl + '&scope=openid accountID:' + membershipInfo.Contact__r.Account.Id + ' contactID:' + membershipInfo.Invite_Code__c;
    }


    /*
    * Action method to switch to register section
    */
    public PageReference navToRegister() {
        if (membershipInfo != null) {
            System.debug('Setting Register');
            currentView = VIEW_REGISTER;
            List<SageUserIdentity> sageIdentities = SageSSOUtil.getSageIdentities(membershipInfo.Contact__r.Email);
            if (sageIdentities != null && sageIdentities.size() == 1) {
                sageIdentity =  sageIdentities[0];
                isValidSageUser = true;
            } else {
                isValidSageUser = false;
            }
            System.debug(isValidSageUser);
        }
        return null;
    }

    public PageReference startExistingSageUserReg() {
        if (sageIdentity != null) {
            // Check for prev registration!
            System.debug(sageIdentity.getIdentityId());
            List<SageUserIdentityProvider__c>  sipList = [SELECT Id, User__c
                    FROM SageUserIdentityProvider__c WHERE IdentityID__c = :sageIdentity.getIdentityId()
                            AND IdentityProvider__c = :authSettings.SageIDAuthProviderKey__c];

            // If application already registered, take the user to login screen instead of calling register api
            if (sipList != null && sipList.size() > 0) {
                return new PageReference(getSSOStartUrl(authSettings.SageIDAuthProviderName__c));
            }

            String startUrl = SageSSOUtil.getStartUrlForExistingUserReg(sageIdentity.getIdentityId(),
                              membershipInfo.Sage_SSO_Post_Register_Success_URL__c,
                              membershipInfo.Sage_SSO_Post_Register_Failure_URL__c);
            PageReference pg = new PageReference(startUrl);
            pg.setRedirect(false);
            return pg;
        }
        return null;
    }

    public PageReference startNewSageUserReg() {
        String startUrl = SageSSOUtil.getStartUrlForNewUserReg(membershipInfo.Contact__r.Name,
                          membershipInfo.Contact__r.Email,
                          membershipInfo.Sage_SSO_Post_Register_Success_URL__c,
                          membershipInfo.Sage_SSO_Post_Register_Failure_URL__c);
        System.debug(startUrl);
        PageReference pg = new PageReference(startUrl);
        pg.setRedirect(false);
        return pg;
    }

}