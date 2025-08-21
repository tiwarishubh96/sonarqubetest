public class SageApiTryNowLeadActivityRequest extends SageApiActivityRequestBase {
    public String companyName;
    public String firstName;
    public String lastName;
    public String email;
    public String phone;
    public String address1;
    public String address2;
    public String city;
    public String state;
    public String countryCode;
    public String postalCode;
    public List<SageApiActivityRequestObjects.Product> products;
    public Boolean isFoundationRequest;
    public String completionNotifyUrl;
}