public inherited sharing class OrgServiceProxyV1_businessAddress extends BaseAuthenticatedService implements IService_Implementation,IService_Implementation_Audit_Override {

  static String CLASSNAME = 'OrgServiceProxyV1_businessAddress';

  private final String AUTH_INVOCATION_ID = 'CloudID_OrgData_ClientGrant';
  private final String SERVICE_INVOCATION_ID = 'OrgDataBrokerInvocationV1_send';
  private final String AUTH_CREDENTIALS_NAME = 'CloudIDOrgDataAPI';
  


  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    orgdata_IBusinessRequest request = (orgdata_IBusinessRequest)inputData;
    return implementationBody(request);
  }

  orgdata_IGetBusAddressResponse implementationBody(orgdata_IBusinessRequest isi) {
    orgdata_IGetBusAddressResponse response = new orgdata_GetBusAddressResponse();
    
    OrgDataServiceAPI.GetBusinessAddressRequest request = new OrgDataServiceAPI.GetBusinessAddressRequest(isi.getBusinessId());
    String functionName = request.getFunctionName();
    
    try{  
      IHTTPResponse calloutResponse = processRequest(request, isi.getCorrelationId(), AUTH_CREDENTIALS_NAME, AUTH_INVOCATION_ID, SERVICE_INVOCATION_ID);
      
      if(!calloutResponse.hasError()){
        List<OrgDataServiceAPI.BusinessAddressObject> businessAddressList = (List<OrgDataServiceAPI.BusinessAddressObject>)JSON.deserialize(calloutResponse.getResponseBody(), List<OrgDataServiceAPI.BusinessAddressObject>.class);
        List<orgdata_GetBusAddressResponse.orgdata_BusinessAddress> addressList = new List<orgdata_GetBusAddressResponse.orgdata_BusinessAddress>();
        for(OrgDataServiceAPI.BusinessAddressObject busAddress:businessAddressList){
          addressList.add(new orgdata_GetBusAddressResponse.orgdata_BusinessAddress(isi.getBusinessId(),busAddress));
        }
        
        response = new orgdata_GetBusAddressResponse(isi.getBusinessId(),addressList);
        response.setState('SUCCESS');
      }else{
          response.setState('FAIL');
          String errMessage = functionName + ' Remote system retuned an error : ';
          errMessage += 'statusCode = ' + calloutResponse.getStatusCode();
          errMessage += ', responseBody = ' + calloutResponse.getResponseBody();
          System.debug(LoggingLevel.DEBUG, functionName + ' Failed  = ' + errMessage);
          response.setErrorMessage(errMessage);
      }      
    }catch(AuthenticatedServiceException e){
      ExceptionLogger.logException(CLASSNAME,getCorrelationId(),e,functionName + ' Failed.',true);
      response.setState('FAIL');
      response.setErrorMessage(e.getMessage());
    }catch(Exception e){
      String error = 'Unexpected Error occured calling ' + functionName;
      ExceptionLogger.logException(CLASSNAME,getCorrelationId(),e,error,true);
      response.setState('FAIL');
      response.setErrorMessage(error + ' ' + e.getMessage());          
    } 
    return response;
  }

  public IService_Output_Master overrideAuditOutput (IService_Output_Master isom) {
    return isom;
}


}