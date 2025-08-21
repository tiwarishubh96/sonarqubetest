public with sharing class orgdata_GetBusinessResponse extends ServiceOutputMaster implements orgdata_IGetBusinessResponse {

    
    private String businessId;
    private String businessName;
    private String countryCode;
    private String accountExternalId;
    private Datetime createdDate;
    private Datetime modifiedDate;


    public orgdata_GetBusinessResponse(){}
    
    public orgdata_GetBusinessResponse(String businessId, OrgDataServiceAPI.BusinessObject businessObject){
        this.businessId = businessId;
        this.businessName = businessObject.Name;
        this.accountExternalId = businessObject.AccountId;
        this.createdDate = businessObject.CreatedAt;
        this.modifiedDate = businessObject.UpdatedAt;
        
    }

    public String getBusinessId(){
        return this.businessId;
    }
    
    public String getName(){
        return this.businessName;
    }
    public String getCountryCode(){
        return this.countryCode;
    }
    public String getAccountExtId(){
        return this.accountExternalId;
    }

    public Datetime getCreatedDate(){
        return this.createdDate;
    }

    public Datetime getLastModifiedDate(){
        return this.modifiedDate;
    }

}