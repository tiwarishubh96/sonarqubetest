public class SageUserIdentity {
	public SageUserIdentity(Dom.XmlNode userIdentityElem) {
		if(userIdentityElem !=null){
			if(userIdentityElem.getChildElement('IdentityId', 'http://sso.sage.com') !=null){
				identityId = userIdentityElem.getChildElement('IdentityId', 'http://sso.sage.com').getText();
			} else if(userIdentityElem.getChildElement('Id', 'http://sso.sage.com') !=null){
				identityId = userIdentityElem.getChildElement('Id', 'http://sso.sage.com').getText();
			}
			emailAddress = userIdentityElem.getChildElement('EmailAddress', 'http://sso.sage.com').getText();
			name = userIdentityElem.getChildElement('Name', 'http://sso.sage.com').getText();
		}
	}

	public String getIdentityId(){
		return identityId;
	}

	private String identityId;
	private String emailAddress;
	private String name;
}