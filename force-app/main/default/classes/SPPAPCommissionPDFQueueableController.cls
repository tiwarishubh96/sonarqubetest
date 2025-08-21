/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:   Queueable class is used to generate the PDF invoice beacause of salesforce issue
    // When you pass the ID to the PDF controller directly after the insert from the same controller method the record is not available. 
   //hence, we get visualforce exception : Unable to retrieve object
   //It's an error with sf it seems.this issue already raised as an IDEA
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
public class SPPAPCommissionPDFQueueableController implements Queueable, Database.AllowsCallouts 
{
    
    List<SPP_Commission_Invoice__c> commissionInvList ;
    
    public SPPAPCommissionPDFQueueableController(List<SPP_Commission_Invoice__c> commissionInvList) 
    {
       
        this.commissionInvList =commissionInvList ; 
        System.debug('commissionInvList'+commissionInvList);
    }
    
    public void execute(QueueableContext context)
    {
        
        try
        { 
            
            List<ContentVersion> listCont = new List<ContentVersion>();
            
            List<ContentDocumentLink> listContDocLink = new List<ContentDocumentLink>();
            
            AggregateResult[] aggCommByAP = [SELECT  SUM(Commission_Amount__c) commAmt ,SPP_AP_Commission__c FROM SPP_RR_Order__c 
                                             where SPP_AP_Commission__c != null and SPP_AP_Commission__c  in: commissionInvList  GROUP BY SPP_AP_Commission__c];
            
            Map<Id,SPP_Commission_Invoice__c> APcommMap = new Map<Id,SPP_Commission_Invoice__c>([Select Id,Name 
                                                                                                 from SPP_Commission_Invoice__c
                                                                                                 where Id in:commissionInvList]);
            system.debug('aggCommByAP::'+aggCommByAP);
            
            // a map of pathOnClient(name of the file) and SPP AP Commission record id
            Map<String,Id> mapObjCont = new Map<String,Id>();
            
            //Making 2 for loops, so that Commision Amt shoud reflect on the PDF after Data commit
            for (AggregateResult ar : aggCommByAP) 
            {   
                PageReference pdf = Page.PartnerCommissionInvoice;
                
                System.debug('Partner Commission id to generate PDF: ' + (Id)ar.get('SPP_AP_Commission__c'));
                
                String id = (Id)ar.get('SPP_AP_Commission__c');
                
                pdf.getParameters().put('id',(Id)ar.get('SPP_AP_Commission__c'));

                Blob body = null;
                
                System.debug('Generating PartnerCommissionInvoice');
                
                if (Test.IsRunningTest()) 
                {
                    body = Blob.valueOf('UNIT.TEST');
                } 
                else 
                {
                    // the contents of the attachment from the pdf
                    body = pdf.getContent();
                }

                //Creating contentversion object
                ContentVersion cont = new ContentVersion();
                cont.versionData = body;
                cont.title = APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Name+'_'+datetime.now().format('MMM-dd-yyyy_hh:mm:ss_a');
                cont.pathOnClient =APcommMap.get((Id)ar.get('SPP_AP_Commission__c')).Name+'_'+datetime.now().format('MMM-dd-yyyy_hh:mm:ss_a')+'.pdf';
                
                system.debug('cont::'+cont);
                
                //mapping contentversion pathOnClient(name of the file) with record id
                mapObjCont.put(cont.pathOnClient, id);
                
                listCont.add(cont);
			}
            
            
            system.debug('listCont::'+listCont);
            //insert lstattach;
            insert listCont;
            
            system.debug('mapObjCont::'+mapObjCont);
            
            List<ContentVersion> listConVersion = [Select Id, ContentDocumentId,versionData, title, pathOnClient From ContentVersion Where Id IN: listCont];
                        
            for (ContentVersion cv: listConVersion){
                
                //Create ContentDocumentLink to link the file to the record
                ContentDocumentLink cDe = new ContentDocumentLink();
                cDe.ContentDocumentId = cv.ContentDocumentId;
                system.debug('cv::'+cv);
                
                system.debug('mapObjCont::'+mapObjCont);
                // you can use objectId,GroupId etc
                cDe.LinkedEntityId = mapObjCont.get(cv.PathOnClient); 
                // Inferred permission, checkout description of ContentDocumentLink object for more details
                cDe.ShareType = 'I'; 
                //AllUsers—The file is available to all users who have permission to see the file.
                cDe.Visibility = 'AllUsers';
				listContDocLink.add(cDe);
            }
            
            // First get the content document Id from ContentVersion
            system.debug('listContDocLink::'+listContDocLink);
            insert listContDocLink;
	}
        catch(Exception e)
        {     
            ExceptionHandler.CatchException('SPPAPCommissionPDFQueueableController', 'Execute', e);
        }
    }
}