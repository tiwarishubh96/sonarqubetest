public class SageApiBuyNowActivityRequest extends SageApiActivityRequestBase {
    public String startDate;
    public String endDate;
    public String legacyUpgradeFrom;
    public String referrerPromotion;
    public SageApiActivityRequestObjects.Account account;
    public SageApiActivityRequestObjects.Contact contact;
    public List<SageApiActivityRequestObjects.Product> products;
    public String payNowToken;
    public String completionNotifyUrl;
    public String zuoraSubscriptionId;
    public String channelPlatform;
    public String channelPartner;
}