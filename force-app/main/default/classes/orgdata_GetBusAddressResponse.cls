public with sharing class orgdata_GetBusAddressResponse extends ServiceOutputMaster implements orgdata_IGetBusAddressResponse {

    private String businessId;
    private List<orgdata_IBusinessAddress> addresses;

    public orgdata_GetBusAddressResponse(){ }


    public orgdata_GetBusAddressResponse(String businessId, List<orgdata_BusinessAddress> addresses){
        this.businessId = businessId;
        this.addresses = addresses;        
    }

    public String getBusinessId(){
        return this.businessId;
    }

    public List<orgdata_IBusinessAddress> getAddresses(){
        return this.addresses;
    }

    public class orgdata_BusinessAddress implements orgdata_IBusinessAddress{
            
        private String businessId;
        private String addressLine1;
        private String addressLine2;
        private String county;
        private String state;
        private String city;
        private String country;
        private String postCode;
        private Datetime createdDate;
        private Datetime lastModifiedDate;      

        public orgdata_BusinessAddress(String businessId, OrgDataServiceAPI.BusinessAddressObject addressObject){
            this.businessId = businessId;
            this.addressLine1 = addressObject.Line1;
            this.addressLine2 = addressObject.Line2;
            this.county = addressObject.County;
            this.state = addressObject.State;
            this.city = addressObject.City;
            this.country = addressObject.Country;
            this.createdDate = addressObject.CreatedAt;
            this.lastModifiedDate = addressObject.UpdatedAt;            
        }

        public String getBusinessId(){
            return this.businessId;

        }
        public String getAddressLine1(){
            return this.addressLine1;
        }
        public String getAddressLine2(){
            return this.addressLine2;
        }
        public String getCounty(){
            return this.county;
        }
        public String getState(){
            return this.state;
        }
        public String getCity(){
            return this.city;
        }
        public String getCountry(){
            return this.country;
        }
        public String getPostCode(){
            return this.postCode;
        }
        public Datetime getCreatedDate(){
            return this.createdDate;
        }
        public Datetime getLastModifiedDate(){
            return this.lastModifiedDate;
        }
    

    }
    



}