/**
 * @description Allows community users to access to the selected community using Sage Bridge.
 */
global class SageCommunityRegHandler implements Auth.RegistrationHandler
{

    /**
     * @description Uses Sage Bridge user id to log a user in. 
     *              The process assumes that the user record with a correct profile is created but is inactive.
     * @date        2016-06-06
     * @param       portalId is a salesforce community Id.
     * @param       data is the data of the user that is logging in.
     * @return      a newly logged in user.
     */
    global User createUser(Id portalId, Auth.UserData data)
    {
        User resultUser;

        try {
            resultUser = createPartnerUser( data );
            if( resultUser == null ) {
                resultUser = createCustomerUser( data );
            }
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.Error, ex.getMessage() + '\n' + ex.getStackTraceString());
            if( Test.isRunningTest() ) throw ex;
        }
        
        return resultUser;
    }

    /**
     * @description Handles creation of partner community user.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     * @param       data is data provided by the IDP
     * @return      partner community user or null if not found.
     */
    public User createPartnerUser(Auth.UserData data)
    {
        // Read data attributes.
        Map<String, String> attributeMap = data.attributeMap;
        String invitationId = attributeMap.get('contact_id');
        String sub =  attributeMap.get('sub');
        
        // Check if there is entry already for a given provider identity id..
        List<SageUserIdentityProvider__c>  sipList = [SELECT Id, User__c
                FROM SageUserIdentityProvider__c WHERE  SFBridgeID__c = :sub AND User__r.isActive = true];
        
        if (sipList != null && sipList.size() > 0) {
            return new User(Id = sipList[0].User__c);
        }
        
        // Provision user based on invitation id in scope. In use for Partner Community user Onboarding.
        if (invitationId != null) {
            User u = SageSSOUtil.createUserFromInvitation(invitationId);
            if(u!=null){
                SageSSOUtil.insertSageUserIdentityMap(u.Id, sub);
            }
            return u;
        }

        return null;
    }

    /**
     * @description Handles creation of customer community user.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-08
     * @param       data is data provided by the IDP
     * @return      customer community user or null if not found
     */
    public User createCustomerUser(Auth.UserData data)
    {
        User resultUser;
        // Id consists of 3 parts: 1) salesforce account Id, 2) Original IDP, 3) User Global Id
        // The parts are delimited by a column (:) symbol
        String[] sageIdParts = data.identifier.split(':');

        // id validation
        if( sageIdParts.size() != 3 ) throw new GenericUtilities.GenericException('No matching user for SSO ID ' + data.identifier + '.');
        
        String originalBridgeId = data.identifier;
        // Salesforce account might be 15 chars instead of original 18 chars,
        // so we try to match by both Ids
        sageIdParts[0] = sageIdParts[0].substring(0, 15);
        String convertedSageId = String.join(sageIdParts, ':');
        
        SageUserIdentityProvider__c provider =  [   SELECT  Id
                                                            , User__r.Id
                                                            , User__r.Username
                                                            , User__r.Email
                                                            , SFBridgeID__c
                                                    FROM SageUserIdentityProvider__c
                                                    WHERE SFBridgeID__c IN :(new Set<String>{ convertedSageId, originalBridgeId })
                                                    LIMIT 1
                                                ];
        
        System.debug('Found user: ' + provider.User__r.Username + ' ' + provider.User__r.email + ' ' + provider.SFBridgeID__c);
        resultUser = new User(Id = provider.User__c, IsActive = true, Email = data.email);
        update resultUser;
        
        
        // Shekhar: Added to update Membership
        User u = [SELECT Id, isActive, ContactId FROM User WHERE Id = :resultUser.id];
        
        if (u.ContactId != null) {
            List<Community_Membership__c> memberships = [SELECT Id, Contact__c FROM Community_Membership__c WHERE Contact__c = :u.ContactId];
            
            if (memberships.size() > 0) {
                CommunityMembershipTriggerHandler.updateUserPermissionSets(memberships);
            }    
        }
        
        return u;
    }
    
    /**
     * @description Updates user information received from Sage Bridge.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-06-06
     * @param       userId is an Id for the salesforce user record.
     * @param       portalId is a Salesforce community id.
     * @param       data is the most recent user information.
     */
    global void updateUser(Id userId, Id portalId, Auth.UserData data)
    {
        try {
            User curUser = new User( Id = userId );
            curUser.Email = data.email;
            curUser.IsActive = true;
            update curUser;
            TestExc.subscribe( SageCommunityRegHandler.class, 'coverage' );
        }
        catch(Exception ex)
        {
            System.debug(LoggingLevel.Error, ex.getMessage() + '\n' + ex.getStackTraceString());
            if( Test.isRunningTest() ) throw ex;
        }
    }
}