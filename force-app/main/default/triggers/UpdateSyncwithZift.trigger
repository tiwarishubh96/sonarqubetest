/**
 * Created by Manjusha G on 07/10/2019.
 * @description To update Contentversion Description when a file is attached to Partner cases with accounts synching to Zift
 */
trigger UpdateSyncwithZift on ContentVersion (after insert) {
    
    Set<Id> contentDocumentIdSet = new Set<Id>();
    Set<Id> linkentityIdSet = new Set<Id>();
    boolean casecheck;
    boolean Goinside;
    
    for(ContentVersion cv:trigger.new)
    {
        if(cv.ContentDocumentId != null && cv.CreatedBy.Profile.Name != 'Sage: ES Integration User')
        {
            contentDocumentIdSet.add(cv.ContentDocumentId);
        }
    }
    
    
    List<ContentDocumentLink > cdlinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet];
    for(ContentDocumentLink cdl: cdlinks){
       linkentityIdSet.add(cdl.LinkedEntityId);
    }
    
    for(String value:linkentityIdSet){
        if(value.startsWith('500')){
           Goinside = true; 
        }
    }
    
    if(Goinside == true){
        List<Case> Clist= [SELECT Id, recordtypeid,Account.Synch_with_Zift__c FROM Case where Id in :linkentityIdSet AND recordtypeid = '01224000000gKMrAAM']; 
      
        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId,Description  FROM ContentVersion where Id IN: Trigger.newMap.keySet() AND CreatedBy.Profile.Name != 'Sage: ES Integration User']; 
            if(Clist.size() > 0){
            for(Case c : Clist){
               if(c.Account.Synch_with_Zift__c == true){              
                   casecheck = true;
               }
            }
        }
    
        for(ContentVersion cv:cvList)
        {
            if(casecheck == true )
            {
                 cv.Description = 'SyncwithZift';
                
            }
            else{
                cv.Description = '';
            }           
        }
        update cvList;
  
    }      
}