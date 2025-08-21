/*******************************************************************************************************
* @description to publish event on creating Righ answers record
* @author : Ravi Yalamati
* @return
*/   
public class RightAnswersHelper {
    
    
    /*******************************************************************************************************
* @description to publish event on creating Righ answers record
* @return
*/ public static void publishEventToCasOnCreatingRARecord(Map<Id, SObject> newItems){
    
    Set<Id> raIds = newItems.keyset(); 
    // Publish messages as notifications
    List<Notification__e> notifications = new List<Notification__e>();
    
    
    for(Id raId : raIds){
        
        RightAnswersAttached__c ra = (RightAnswersAttached__c) newItems.get(raId);
        String message = ra.CaseNumber__c;        
        notifications.add(new Notification__e(Message__c = message));
        
    }// end of for
    
    if(notifications.size() > 0){
        
        List<Database.SaveResult> results = EventBus.publish(notifications);
        
        // Inspect publishing results
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error returned: ' + error.getStatusCode() +' - '+ error.getMessage());
                }
            }else{
                System.debug('Successfully Notified');
            }
        }//end of for
        
    }//end of notfication size check
    
    
}//end of method
   
    public Static void updatehasRightAnswer(Map<Id, SObject> newItems){
        Set<Id> raIds = newItems.keyset(); 
        Set<Id> caseIds = new Set<Id>();
        for(Id raId : raIds){
            RightAnswersAttached__c ra = (RightAnswersAttached__c) newItems.get(raId);
            if(ra.CaseNumber__c != NULL){caseIds.add(ra.CaseNumber__c);}//cases.add(new Case(ID = ra.CaseNumber__c,hasRightAnswer__c=true));}
        }// end of for
        List<Case> cases = [select id,hasRightAnswer__c from case where ID  IN :caseIds and (hasRightAnswer__c= 0 OR hasRightAnswer__c=NULL)];
        for(Case c:cases){
            c.hasRightAnswer__c=1;
        }
        if(cases.size() > 0){
            Update cases;
        }//end of notfication size check
    }
    
    public static void updatehasRightAnswerto0(Map<Id, SObject> oldItems){
        Set<Id> raIds = oldItems.keyset(); 
        Set<Id> caseIds = new Set<Id>();
        for(Id raId : raIds){
            RightAnswersAttached__c ra = (RightAnswersAttached__c) oldItems.get(raId);
            if(ra.CaseNumber__c != NULL){caseIds.add(ra.CaseNumber__c);}//cases.add(new Case(ID = ra.CaseNumber__c,hasRightAnswer__c=true));}
        }
        system.debug('@@caseIds@@'+caseIds);
        //Map <ID,List<RightAnswersAttached__c>> RAmap = new Map <ID,List<RightAnswersAttached__c>>();
        Set<Id> caseIdnottoUpdate = new Set<Id>();
        for(RightAnswersAttached__c ra:[Select ID,CaseNumber__c from RightAnswersAttached__c where CaseNumber__c IN :caseIds]){
        	caseIdnottoUpdate.add(ra.CaseNumber__c);
            /*if(RAmap.containskey(ra.CaseNumber__c)){
                List<RightAnswersAttached__c> ralist = RAmap.get(ra.CaseNumber__c);
                ralist.add(ra);
                RAmap.put(ra.CaseNumber__c,ralist);
            }else{
                RAmap.put(ra.CaseNumber__c,new List<RightAnswersAttached__c>{ra});
            }*/
    	}
        system.debug('@@caseIdnottoUpdate@@'+caseIdnottoUpdate);
        Set<Id> caseIdtoUpdate = new Set<Id>();
        for(ID cid:caseIds){
            if(!caseIdnottoUpdate.contains(cid)){
                caseIdtoUpdate.add(cid);
            }
        }
        system.debug('@@caseIdtoUpdate@@'+caseIdtoUpdate);
        List<case> cases =[select id,hasRightAnswer__c from case where ID  IN :caseIdtoUpdate and hasRightAnswer__c= 1];
        for(Case c:cases){
            c.hasRightAnswer__c=0;
        }
        if(cases.size() > 0){
            Update cases;
        }
    }
}//end of class