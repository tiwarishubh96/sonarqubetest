/*
* Class Name :- DSRRelatedListController
* Author :- Shubham Kimothi
* Created Date :- 15-04-2019
* Description : This class is use to show the related list of dsr of associated opportunity.
* 
// ********************Change Logs *****************************************************************************************************************************
*/
public class DSRRelatedListController {    
    
    public List<DealSupportRequest__c> DSRs{get;set;} 
    public DealSupportRequest__c DSR {get;set;} 
    
    //Constructor 
    public DSRRelatedListController(ApexPages.StandardController stdcontroller) { 
        if(!Test.isrunningTest()){
            stdController.addFields(new List<String>{'Opportunity__c'});
        }
        
        DSR = (DealSupportRequest__c)stdController.getRecord();      
        DSRs = [SELECT Id, Name, DealSupportRequestType__c, DealSupportRequestDetail__c, CreatedById, CreatedDate FROM DealSupportRequest__c WHERE Opportunity__c =:DSR.Opportunity__c AND Id !=:DSR.Id ORDER BY Name];     
        if(DSRs == null || DSRs.isEmpty()){
            DSRs= null;
        }
    }  
}