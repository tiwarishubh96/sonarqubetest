/*********************************************************************
Name    : SPPBulkScheduleDocuSign
Author  : Lakshman Jaasti
Date    : 04/14/2017
Description :  This class is used to Schedule the operation to update partner junction object.
**********************************************************************/

global class SPPBulkScheduleDocuSign implements Schedulable
{
    //Schedular class to schedule bulk templates to sign.
    //To get individual envelop Id of bulk and insert it in to junction object.
    //for bulk call DocuSign status object records taking bit time to update so that we scheduling this class. 

    global String sppScheduler;
    
    
    public SPPBulkScheduleDocuSign(String sppScheduler)
    {
        this.sppScheduler = sppScheduler;
        
    }

    global void execute(SchedulableContext SC) {
       
        String id = SC.getTriggerId();
        getBulkList(this.sppScheduler,id);

    }
    
    
    @future(callout=true)
    public static void getBulkList(String sppScheduler,String id)
    {
        SPPScheduleDocuSignBulkWrapper objWrapper = (SPPScheduleDocuSignBulkWrapper)JSON.deserializeStrict(sppScheduler, SPPScheduleDocuSignBulkWrapper.class);
        String batchId = objWrapper.batchId;
        String tempVerId = objWrapper.templateVersId;
        //Soql to get DocuSign Accoutn User details from there custom Object 
        String accountID ;
        String userName ;
        String passWord ;
        String integratorKey = System.Label.DocuSign_Integrator_Key;
        String endPointBase;
        HttpRequest req = new HttpRequest();
       
        dsfs__DocuSignAccountConfiguration__c accConFig = [select id,name,  dsfs__AccountId__c,dsfs__DocuSignBaseURL__c,dsfs__DocuSignEnvironment__c, dsfs__DSProSFPassword__c,dsfs__DSProSFUsername__c from dsfs__DocuSignAccountConfiguration__c];
        accountID = accConFig.dsfs__AccountId__c; 
        userName = accConFig.dsfs__DSProSFUsername__c; 
        passWord = accConFig.dsfs__DSProSFPassword__c;
        //Creating end point url
        endPointBase = accConFig.dsfs__DocuSignBaseURL__c+'restapi/v2/accounts/'+accountID+'/bulk_envelopes/'+batchId+'?include=all';
        
        
        system.debug('endPointBase:: '+endPointBase);
        req.setEndpoint(endPointBase);
        req.setMethod('GET'); 
        //Authorization header generating using DocuSign credentials. 
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>';
        req.setHeader('X-DocuSign-Authentication', authorizationHeader);
        Http http = new Http(); 
        HTTPResponse res; 
        res = http.send(req);
        SPPBulkEnvelops wrapInst = SPPBulkEnvelops.parse(res.getBody());
        if(wrapInst.bulkEnvelopes != null)
            insertBulkJunctionObj( wrapInst.BulkEnvelopes, objWrapper.accAndConMap , objWrapper.conMap ,tempVerId);
        else
            System.debug('There are no bulk envelopes...');

        system.abortJob(id);
        //return wrapInst;
    }

 public static void insertBulkJunctionObj(List<SPPBulkEnvelops.BulkEnvelopes> bulkEnvelopes , map<String , Account> conAccMap , Map<String , Contact> contactMap ,String tempVerId)
    {
            
        List<Partner_Terms_and_Condition__c> pTnCListUpdate = new List<Partner_Terms_and_Condition__c>();
        List<String> enveList = new List<String>();
        
        for(SPPBulkEnvelops.BulkEnvelopes obj : bulkEnvelopes )
        {
            enveList.add(obj.envelopeId);
        }
        List<dsfs__DocuSign_Status__c> pTnCList = [Select Id,dsfs__DocuSign_Envelope_ID__c,dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c where dsfs__DocuSign_Envelope_ID__c IN :enveList];
        Map<String , dsfs__DocuSign_Status__c> partMap = new Map<String , dsfs__DocuSign_Status__c>();
        for(dsfs__DocuSign_Status__c obj : pTnCList )
        {
            partMap.put(obj.dsfs__DocuSign_Envelope_ID__c.toLowerCase() , obj);
        }
        for(SPPBulkEnvelops.BulkEnvelopes obj : bulkEnvelopes )
        {
            Account acc = conAccMap.get(obj.email);
            Contact con = contactMap.get(obj.email);

            Partner_Terms_and_Condition__c pTnCObj = new Partner_Terms_and_Condition__c();
            dsfs__DocuSign_Status__c objPart = partMap.get( obj.envelopeId.toLowerCase() );

            pTnCObj.DocuSign_Status_Object__c = objPart.Id;
            pTnCObj.Terms_Conditions_Version__c = tempVerId;
            pTnCObj.Docusign_Status__c = objPart.dsfs__Envelope_Status__c;
            pTnCObj.Account__c = acc.Id;
            pTnCObj.Contact__c = con.id;
            pTnCObj.DocuSign_EnvelopeId__c = obj.envelopeId;
            pTnCListUpdate.add(pTnCObj);
        }

        insert pTnCListUpdate;
    }

}