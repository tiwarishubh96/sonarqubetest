public interface IAccount{
    String getId();
    String getName();
    String getCountryCode();
    String getCurrencyCode();
    String getSalesOffice();
    String getLocale();
    String getBillingAccountId();
    void setBillingAccountId(String billingAccountId);
    IAddress getAddress();
    String getVatRegistrationNumber();
    void setVatRegistrationNumber(String vatRegistrationNumber);
    
}