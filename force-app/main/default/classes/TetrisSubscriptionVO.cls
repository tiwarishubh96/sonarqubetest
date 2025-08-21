public class TetrisSubscriptionVO {

    public class Request{
        public String subscriptionId{set;get;}
        public String subscriptionItemId{set;get;}
        public Date reactivationDate{set;get;}
        public Date cancellationEffectiveDate{set;get;}
        public String notes{set;get;}
        public String actionType{set;get;}
        public String promotionType{set;get;}
        public String bundleName{set;get;}
        public String bundleDesc{set;get;}
        public String bundleInstance{set;get;}
        public String zuoraSubscriptionId {set;get;}
        public String zuoraSubscriptionName {set;get;}
        public String billingFrequency{set;get;}
        public String couponCode{set;get;}
        public String couponId{set;get;}
        public String length{set;get;}
        public String period{set;get;}
        public List<TetrisCartItemModel> products{set;get;}
    }

    public class Response{
        public String success{set;get;}
        public Result result{set;get;}
        public List<Errors> errors{set;get;}
    }

    public class Errors{
        public String message{set;get;}
        public String errorCode{set;get;}
    }

    public class Result {
    }
}