/*********************************************************************
Name    : SPPDocuSignBulkRest
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This class is used to make rest call to docusign for Bulk envelops.
**********************************************************************/

public with sharing class SPPDocuSignBulkRest {

    public static SPPWrapperDocuSign CreateEnvelopDraftWithTemplate(String templateID)
    {
        //String templateID = 'de0b1d2c-886a-40d3-baa7-bc5ae1248f6e';
        String SPPSigner = System.Label.DocuSign_SPP_Signer;
        String json = '{'+' '+
          // ' "emailSubject": "DocuSign API - Test Template to Multiple Contacts", '+
          //  ' "emailBlurb": "Bulk Templates test new ", '+
            ' "status": "Created", '+   
            '   "templateId": "'+templateId+'",'+
            '"templateRoles":['+
            '{'+
                '"roleName":"'+SPPSigner+'"'+
            '}]'+
        '} ';

        System.debug('json  : '+json);

        HttpRequest req;
        SPPDocuSignCompositeJson.RestAPIServices com;

        //Rest Call to DocuSing 
        
        com =new SPPDocuSignCompositeJson.RestAPIServices();
        req = SPPDocuSignUtils.getConfig('' , 'POST' , 'Application/json');
        
        
        req.setBody(json); 

        Http http = new Http(); 
        HTTPResponse res; 
        system.debug('Anydatatype_msg');
        res = http.send(req);
        
        system.debug('res.getBody()' + res.getBody());
        SPPWrapperDocuSign wrapInst = SPPWrapperDocuSign.parseJson(res.getBody());
        system.debug('wrapInst : '+wrapInst);
        return wrapInst;

    }


    public static SPPWrapperDocuSign createBulkRecipientsFromCSV(String envId , String csvFile)
    {

        //Soql to get DocuSign Accoutn User details from there custom Object 
       
        String endPoint =   '/'+envId+'/recipients/'+1+'/bulk_recipients';
        //Apex HTTP Method Initialization.
        SPPDocuSignCompositeJson.RestAPIServices com ;
        HttpRequest req;

        
        com =new SPPDocuSignCompositeJson.RestAPIServices();
        req = SPPDocuSignUtils.getConfig(endPoint , 'PUT' , 'text/csv');
        
        

        system.debug(csvFile);
        req.setBody(csvFile); 
        system.debug(req);
        Http http = new Http(); 
        HTTPResponse res; 
        system.debug('Anydatatype_msg');
        res = http.send(req);
        system.debug('req : '+req);
        system.debug('req : '+res.getBody());

        SPPWrapperDocuSign wrapInst = SPPWrapperDocuSign.parseJson(res.getBody());
        system.debug('wrapInst : '+wrapInst);
        return wrapInst;

    }

    public static SPPWrapperDocuSign updateEnvelope(String envId)
    {

        String endPoint =    '/'+envId;

        SPPDocuSignCompositeJson.RestAPIServices com ;
        HttpRequest req;

        
        com =new SPPDocuSignCompositeJson.RestAPIServices();
        req = SPPDocuSignUtils.getConfig(endPoint , 'PUT' , 'application/json');
        
       
        String json = '{'+' '+
            ' "status": "sent"'+ 
          '} ';
        System.debug('json  : '+json);
        
        req.setBody(json); 

        Http http = new Http(); 
        HTTPResponse res; 
        
        res = http.send(req);

        system.debug('res :: '+res);
        system.debug('res :: '+res.getBody());

        SPPWrapperDocuSign wrapInst = SPPWrapperDocuSign.parseJson(res.getBody());
        system.debug('wrapInst : '+wrapInst);

        return wrapInst;
    }

    public static SPPBulkEnvelops getBulkList(String batchId)
    {
        dsfs__DocuSignAccountConfiguration__c accConFig;
        String accountID;
        String userName ; 
        String passWord ;
        String integratorKey ;
        try{
                accConFig = [select id,name,  dsfs__AccountId__c,dsfs__DocuSignBaseURL__c,dsfs__DocuSignEnvironment__c, dsfs__DSProSFPassword__c,dsfs__DSProSFUsername__c from dsfs__DocuSignAccountConfiguration__c];
                
        }catch(Exception ex)
        {
            system.debug('Ex : '+ex.getMessage());
            accConFig = new dsfs__DocuSignAccountConfiguration__c();
            accConFig.dsfs__DSProSFPassword__c = '';
            accConFig.dsfs__DSProSFUsername__c = '';
             accConFig.dsfs__AccountId__c = ''; 

        }

        accountID = accConFig.dsfs__AccountId__c; 
        userName = accConFig.dsfs__DSProSFUsername__c; 
        passWord = accConFig.dsfs__DSProSFPassword__c;
        integratorKey = System.Label.DocuSign_Integrator_Key;
       
        //Soql to get DocuSign Accoutn User details from there custom Object 
        
        HttpRequest req = new HttpRequest();
        
        
        //Creating end point url
        String endPointBase = accConFig.dsfs__DocuSignBaseURL__c+'restapi/v2/accounts/'+accountID+'/bulk_envelopes/'+batchId+'?include=all';
        //;
        //Apex HTTP Method Initialization.
        system.debug('endPointBase:: '+endPointBase);
        req.setEndpoint(endPointBase);
        req.setMethod('GET'); 
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>';
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);

        //Authorization header generating using DocuSign credentials. 
        
        Http http = new Http(); 
        HTTPResponse res; 
        system.debug('Anydatatype_msg');
        res = http.send(req);
        system.debug('res : '+res.getBody());
        SPPBulkEnvelops wrapInst = SPPBulkEnvelops.parse(res.getBody());
        system.debug('wrapInst : '+wrapInst);

        return wrapInst;

    }

}