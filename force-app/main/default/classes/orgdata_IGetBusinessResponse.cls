public interface orgdata_IGetBusinessResponse extends IService_Output_Master{
    
    String getBusinessId();
    String getName();
    String getCountryCode();
    String getAccountExtId();
    Datetime getCreatedDate();
    Datetime getLastModifiedDate();


}