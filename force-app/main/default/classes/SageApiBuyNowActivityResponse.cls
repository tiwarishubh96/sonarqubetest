public class SageApiBuyNowActivityResponse extends SageApiActivityResponseBase {
    public ResponseData data;
    
    public class ResponseData {
        public String leadId;
        public String opportunityId;
        public String accountId;
        public String contactId;
        public String userId;
        public String communityMembershipId;
        public String bridgeServiceId;
        public String quoteId;
        //public String paymentUrl;
        public String subscriptionId;
        public String assetId;
        public String cbcTrialId;
        public String cbcSubscriptionId;
        public Boolean hasCommunityAccess;
    }
}