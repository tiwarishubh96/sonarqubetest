/*-------------------------------------------------------------
    Author:         Lu
    Date :          12/26/2017
    Company:        Docmation LLC
    Description:    Generic class for calling MuleSoft
    Inputs:         
    History:        
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/

public class MuleSoftUtils {
    
     public class deserializeResponse
    {
        public String access_token;
    } 
    
    //This function is to make a call to MuleSoft with request String, Metadata name, authenticantion type
    public static String CalltoMuleSoft(String jsonData, String strMuleSoftCall, String authType){

        System.debug('<<<<I am in the Utils>>');
        
        //If the response contains 'oauth_token is either invalid or expired', call the getOAuthToken method again but no more than 5 times
        Integer MAXCALLTIMES = 5;
        
        //Fetching callout config metadata
        List<Callout_Configuration__mdt> lstcallout =[Select DeveloperName,MasterLabel,Client_Id__c,Client_Secret__c,Endpoint_URL__c,HTTP_Method__c,Content_Type__c,
        OAuth_Endpoint_URL__c, Username__c, Password__c,OAuth_HTTP_Method__c
        from Callout_Configuration__mdt where DeveloperName =: strMuleSoftCall];

        String resultresponse;  
        
        
        //Append this error message with response message
        String errorMsg = Test.isRunningTest()?'':'We have tried 5 times to get the token but failed ';
    
        if(!lstcallout.isEmpty()){
            try{
                Http httpcall = new Http();
            
                HttpRequest request = new HttpRequest();
                
                system.debug('>>>>'+lstcallout[0].Endpoint_URL__c);

                String endpoint = lstcallout[0].Endpoint_URL__c;
                
                request.setEndPoint(endpoint);
        
                request.setMethod(lstcallout[0].HTTP_Method__c);
                
                request.setBody(jsonData);
        
                request.setHeader('Accept',lstcallout[0].Content_Type__c);
                    
                request.setHeader('Content-Type',lstcallout[0].Content_Type__c);
                
                //Adding maximum time out to prevent ReadTimeout error @RY 
                request.setTimeout(120000);
        
                if(authType.equals('Basic')){
                    Blob headerValue = Blob.valueOf(lstcallout[0].Client_Id__c+ ':' + lstcallout[0].Client_Secret__c);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    request.setHeader('Authorization', authorizationHeader);
                }
                else if(authType.equals('OAuth')){
                    string accessToken = getOauthAccessToken(jsonData,strMuleSoftCall, lstcallout[0]);
                    if(accessToken != null){
                        request.setHeader('oauth_token',accessToken);    
                    }
                }
        
                HttpResponse response = httpcall.send(request); 
                
                system.debug('>>>>>>>>>'+response.getBody());
                
                resultresponse=response.getBody();
                
                
                Integer counter = 0;
                
                //If the response contains 'oauth_token is either invalid or expired', 
                //call the getOAuthToken method again but no more than 5 times
                while (resultresponse.contains('oauth_token is either invalid or expired') && counter < MAXCALLTIMES ){
                    
                    System.debug('<<<<oauth_token is invalid>>>');
                    
                    string accessToken = getOauthAccessToken(jsonData,strMuleSoftCall, lstcallout[0]);
                    
                    if(accessToken != null){
                        request.setHeader('oauth_token',accessToken);    
                    }
                    
                    response = httpcall.send(request); 
                
                    system.debug('>>>>>>>>>'+response.getBody());
                    
                    resultresponse=response.getBody();
                    
                    errorMsg += resultresponse;
                    
                    resultresponse = errorMsg;
                    
                    counter++;
                }
                
            }catch(Exception e){

                ExceptionHandler.CatchException('SPPUtils', 'CalltoMuleSoft', e);

            }
            
        }

        return resultresponse;
    }

    //This is function is to get access token if the Authentication type is OAuth
    public static String getOauthAccessToken(String jsonData,String strMuleSoftCall, Callout_Configuration__mdt callout)
    {
        try{
            //Lu 10/06/17
            
            Http httpcall = new Http();
            HttpRequest request = new HttpRequest();
         
            request.setEndPoint(callout.OAuth_Endpoint_URL__c);
            request.setHeader('username',callout.Username__c);
            request.setHeader('password',callout.Password__c);
            request.setHeader('granttype','password');
           
            request.setHeader('clientsecret',callout.Client_Secret__c);
            request.setHeader('clientid',callout.Client_Id__c);
            request.setMethod(callout.OAuth_HTTP_Method__c);
            
            //Adding maximum time out to prevent ReadTimeout error @RY 
            request.setTimeout(120000);
            
            HttpResponse response = httpcall.send(request); 
            system.debug('>>>>>>'+response.getBody());

            deserializeResponse tokenresponse = (deserializeResponse)JSON.deserialize(response.getbody(),deserializeResponse.class);
            system.debug('>>>>>>'+tokenresponse);
           
            return tokenresponse.access_token; 
            
        }
        catch(Exception e)
        {
            ExceptionHandler.CatchException('SPPUtils', 'getOauthAccessToken', e);
        }
        return 'Something went wrong. No Tokens'; 
    }
}