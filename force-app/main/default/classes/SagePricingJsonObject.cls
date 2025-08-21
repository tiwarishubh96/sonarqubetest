public class SagePricingJsonObject {
    public class PricingCode {
        public String id;
        public String pricingCode;
        public Boolean isCustomerPromo;
        public String tierCode;
        public String tierRatePlanCode;
        public String startDate;
        public String endDate;
        public String description;
        public String currencyCode;
        public String originalPriceTotal;
        public String promotionalPriceTotal;
        public String promotionalPriceDiscount;
        public Integer promotionalDiscountMonths;
        public Boolean includesTax;
        public Decimal revision;
        public String syncId;
        public Boolean isDeleted;
        public List<String> validFor;
        public List<PricingCodeCharge> pricingCodeCharges;
    }

    public class PricingCodeCharge {
        public String pricingCodeChargeName;
        public String productRatePlanCharge;
        public String discountPrice;
        public String chargeModel;
        public String billingPeriod;
        public String discountPercent;
        public String numberOfPeriods;
    }
}