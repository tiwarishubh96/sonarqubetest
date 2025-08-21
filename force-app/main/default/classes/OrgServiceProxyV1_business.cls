public inherited sharing class OrgServiceProxyV1_business extends BaseAuthenticatedService implements IService_Implementation,IService_Implementation_Audit_Override {

  static String CLASSNAME = 'OrgServiceProxyV1_business';

  private final String AUTH_INVOCATION_ID = 'CloudID_OrgData_ClientGrant';
  private final String SERVICE_INVOCATION_ID = 'OrgDataBrokerInvocationV1_send';
  private final String AUTH_CREDENTIALS_NAME = 'CloudIDOrgDataAPI';
  


  public IService_Output_Master dispatch(IInvocation_Details invocationDetails, IService_Input_Master inputData) {
    orgdata_IBusinessRequest request = (orgdata_IBusinessRequest)inputData;
    return implementationBody(request);
  }

  orgdata_IGetBusinessResponse implementationBody(orgdata_IBusinessRequest isi) {
    orgdata_IGetBusinessResponse response = new orgdata_GetBusinessResponse();
    
    OrgDataServiceAPI.GetBusinessRequest userRequest = new OrgDataServiceAPI.GetBusinessRequest(isi.getBusinessId());
    String functionName = userRequest.getFunctionName();
    
    try{  
      IHTTPResponse calloutResponse = processRequest(userRequest, isi.getCorrelationId(), AUTH_CREDENTIALS_NAME, AUTH_INVOCATION_ID, SERVICE_INVOCATION_ID);
      
      if(!calloutResponse.hasError()){
        OrgDataServiceAPI.BusinessObject business = (OrgDataServiceAPI.BusinessObject)JSON.deserialize(calloutResponse.getResponseBody(), OrgDataServiceAPI.BusinessObject.class);
        
        response = new orgdata_GetBusinessResponse(isi.getBusinessId(),business);
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