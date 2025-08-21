/*********************************************************************
Name    : SPPDocuSignRest
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This class is used to Make Rest Call to DocuSign.
Send Envelops and Void the Envelops operations can be done.
**********************************************************************/

public class SPPDocuSignRest
{
    
    //Method to Make rest call to DocuSign to send Document
    public SPPWrapperDocuSign sendEnvelope(List<Contact> conList ,Map<Integer , String> tempOrderMap,Account acc ,String partnerType)
    {       

        SPPDocuSignCompositeJson.RestAPIServices com =new SPPDocuSignCompositeJson.RestAPIServices();
        
        List<SPPDocuSignCompositeJson.CompositeTemplates>  comList = com.builCompositTemplate( conList , tempOrderMap ,  acc ,partnerType);
        System.debug('1234: '+JSON.serialize(comList));
        SPPDocuSignCompositeJson compo = new SPPDocuSignCompositeJson();
        SPPWrapperDocuSign wrapInst;
        compo.compositeTemplates = comList;
        String loc = acc.Locale__r.Name;
        
        compo.status = 'Sent';
		//System.debug('1234: '+JSON.serialize(compo));
        String jsonString = JSON.serialize(compo);
        
        HttpRequest req ;
        
        if(!Test.isRunningTest()){
            req = SPPDocuSignUtils.getConfig('' , 'POST' , 'Application/json');
        }else{

            req = new HttpRequest();
            req.setEndpoint('https://demo.docusign.net/restapi/v2/accounts/');
            req.setMethod('POST'); 
            req.setHeader('Content-Type','Application/json');
        }
        
        req.setBody(jsonString); 
        Http http = new Http(); 
        HTTPResponse res; 
        try{ 
            //Docusign Request Callout. 
            res = http.send(req);
            
        } 
        catch(Exception e){ 

            ExceptionHandler.CatchException('SPPDocuSignRest', 'sendEnvelope Method', e);
            wrapInst = new SPPWrapperDocuSign();
            wrapInst.message = e.getMessage();
            wrapInst.errorCode = '400';
            return wrapInst;
        } 
        /********   The response from the Docusign is sent to wrapper class to deserialize.    *********/ 
         wrapInst = SPPWrapperDocuSign.parseJson(res.getBody());
        Return wrapInst; 

    } 
    
    //Method to use void the transaction based envelope Id.
    public void voidEnvelop(String envId)
    {
        
        String jsonString = ' {"status": "Voided", "voidedReason": "Updated Aggrement sent" } ';
        HttpRequest req ;
        SPPDocuSignCompositeJson.RestAPIServices com =new SPPDocuSignCompositeJson.RestAPIServices();
        
        if(!Test.isRunningTest()){

            req = SPPDocuSignUtils.getConfig('/'+envId , 'PUT' , 'Application/json');

        }else
        {

            req = new HttpRequest();
            req.setEndpoint('https://demo.docusign.net/restapi/v2/accounts/');
            req.setMethod('POST'); 
            req.setHeader('Content-Type','Application/json');
        }
        
        req.setBody(jsonString); 
        Http http = new Http(); 
        HTTPResponse res; 

        try{ 
            //Docusign Request Callout. 
            res = http.send(req);
            
        } 
        catch(Exception e){ 

            ExceptionHandler.CatchException('SPPDocuSignRest', 'sendEnvelope Method', e);
            
        } 

    }
   

   
}