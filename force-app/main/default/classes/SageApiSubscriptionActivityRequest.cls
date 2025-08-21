public class SageApiSubscriptionActivityRequest extends SageApiActivityRequestBase {
	//// existing cbcSubscriptionId
    //public String cbcSubscriptionId;

    //// for new subscription
    //public String startDate;
    //public String endDate;
    public SageApiActivityRequestObjects.Account account;
    public SageApiActivityRequestObjects.Contact contact;
    public SageApiActivityRequestObjects.Subscription subscription;
    //public List<SageApiActivityRequestObjects.Product> products;
    public String paymentUrl;

    //// for amend subscription (Zuora integration - Tetris)
    //public String externalSubscriptionId;
    //public String externalSubscriptionType;
    //public List<SageApiActivityRequestObjects.Product> fromProducts;
    //public List<SageApiActivityRequestObjects.Product> toProducts;
}