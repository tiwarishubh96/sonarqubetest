public class RegistrationForm_JSON2Apex {

    public String firstName;
    public Boolean monthly;
    public String subscriptionType;
    public String businessName;
    public String businessStreet;
    public String businessCity;
    public String businessState;
    public String businessZip;
    public String billingName;
    public String billingStreet;
    public String billingCity;
    public String billingState;
    public String billingZip;
    public String name;
    public String sku;
    public String taxCode;
    public String storeFront;

    public static RegistrationForm_JSON2Apex parse(String json) {
        return (RegistrationForm_JSON2Apex) System.JSON.deserialize(json, RegistrationForm_JSON2Apex.class);
    }
}