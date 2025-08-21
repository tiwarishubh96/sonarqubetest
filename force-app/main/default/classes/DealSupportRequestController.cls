/*
* Class Name :- DealSupportRequestController
* Author :- Shubham Kimothi
* Created Date :- 15-04-2019
* Description : This class is use to create Deal Support Request.
* 
// ********************Change Logs *****************************************************************************************************************************
*/

public class DealSupportRequestController {
    private final Opportunity opp;
    public string DSRReason{get; set;}
    public string RequestType{get; set;}
    static string CLASSNAME = 'DealSupportRequestController';
    
    public DealSupportRequestController(ApexPages.StandardController stdController) {
        this.opp = (Opportunity)stdController.getRecord();
    }
    
    //function is creating Deal Support Request
    public PageReference CreateDealSupportRequest() {
        Boolean exceptionOccur = false;
        DealSupportRequest__c dsr;
        try {
            LogControl.push('CreateDealSupportRequest', CLASSNAME);
            string QueueName = System.Label.DealSupportRequestforDealDesk; 
            string OwnerId =[SELECT Id, QueueId FROM QueuesObject WHERE Queue.Name=:QueueName].QueueId;
            dsr = new DealSupportRequest__c();
            dsr.Opportunity__c = opp.Id;
            dsr.DSRStatus__c = 'New';
            dsr.DealSupportRequestType__c = RequestType;
            dsr.DealSupportRequestDetail__c = DSRReason;
            dsr.OwnerId = OwnerId;
            insert dsr;
        } catch (Exception e) {
            LogControl.debugException(e);
            exceptionOccur = true;
            ApexPages.addMessages(e);
        } finally {
            LogControl.pop();
        }
        if(!exceptionOccur){
            PageReference pageRef = new PageReference('/'+dsr.Id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else{
            return null;
        }
    }
}