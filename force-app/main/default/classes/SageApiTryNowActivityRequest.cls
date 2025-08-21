public class SageApiTryNowActivityRequest extends SageApiActivityRequestBase {
    public String startDate;
    public String endDate;
    public String legacyUpgradeFrom;
    public String referrerPromotion;
    public SageApiActivityRequestObjects.Account account;
    public SageApiActivityRequestObjects.Contact contact;
    public List<SageApiActivityRequestObjects.Product> products;
    public String purchasingTicket;
    public String tryNowCompletionNotifyUrl;
    public String payNowCompletionNotifyUrl;
    public String payNowSuccessRedirectUrl;
    public String payNowErrorRedirectUrl;
    public String paymentUrl;
    public String channelPlatform;
    public String channelPartner;
}