public interface orgdata_IGetBusAddressResponse extends IService_Output_Master{
    
    String getBusinessId();
    List<orgdata_IBusinessAddress> getAddresses();
}