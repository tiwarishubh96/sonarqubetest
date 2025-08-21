public class SageApiTryNowActivityResponse extends SageApiActivityResponseBase {
    public ResponseData data;
    
    public class ResponseData {
        public String leadId;
        public String opportunityId;
        public String accountId;
        public String contactId;
        public String communityMembershipId;
        public String userId;
        public String bridgeServiceId;
        public String quoteId;
        public String paymentUrl;
        public String assetId;
        public String cbcTrialId;
        public Boolean hasCommunityAccess;
    }
}