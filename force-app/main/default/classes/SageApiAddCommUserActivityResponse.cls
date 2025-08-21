public class SageApiAddCommUserActivityResponse extends SageApiActivityResponseBase {
    public ResponseData data;
    
    public class ResponseData {
        public String accountId;
        public String contactId;
        public String communityMembershipId;
        public String userId;
        public String bridgeServiceId;
    }
}