public class TetrisTrailExtensionVO {
    
    public class EntitledAccount {
		public String id;
	}

	public class Products {
		public String product;
		public List<Features> features;
		public String launchUrl;
	}

	public String subscriptionId;
	public String subscriptionGroupId;
	public String channelPlatform;
	public String channelPartner;
	public Boolean isTrial;
	public EntitledAccount entitledAccount;
	public EntitledAccount customerContact;
	public EntitledAccount managingAccount;
	public String state;
	public EffectivePeriod effectivePeriod;
	public Entitlement entitlement;
	public List<Links> links;
    public List<Errors> errors;

	public class EffectivePeriod {
		public String notBefore;
		public String notAfter;
	}

	public class Links {
		public String service;
		public String url;
	}

	public class Features {
		public String name;
		public List<Properties> properties;
	}

	public class Properties {
	}

	public class Entitlement {
		public String entitlementId;
		public List<Products> products;
	}
    
    public class Errors {
		public String code;
		public String source;
		public String data;
	}
    
	public static TetrisTrailExtensionVO parse(String json) {
		return (TetrisTrailExtensionVO) System.JSON.deserialize(json, TetrisTrailExtensionVO.class);
	}
}