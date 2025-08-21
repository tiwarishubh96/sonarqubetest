public class SageOpenIDConnectRegHandler implements Auth.RegistrationHandler {

	public User createUser(Id portalId, Auth.UserData data) {

		// Read data attributes.
		Map<String, String> attributeMap = data.attributeMap;
		String invitationId = attributeMap.get('contact_id');
		String sub =  attributeMap.get('sub');


		// Check if there is entry already for a given provider identity id..
		List<SageUserIdentityProvider__c>  sipList = [SELECT Id, User__c
		        FROM SageUserIdentityProvider__c WHERE  SFBridgeID__c = :sub];
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

	public void updateUser(Id userId, Id portalId, Auth.UserData data) {
	}
}