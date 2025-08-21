public with sharing class SageCommunityCasePostComment {
    
    public static void changeCaseStatusOnCommunityUserPostComment(List<FeedComment> insertedComments){
        system.debug('*** SageCommunityCasePostComment.changeCaseStatusOnCommunityUserPostComment callout with parameter @insertedComments: '+JSON.serialize(insertedComments));
        Schema.DescribeSObjectResult caseDescribe = Case.sObjectType.getDescribe();
        String caseKeyPrefix = caseDescribe.getKeyPrefix();
        //gather all feedComments for cases
        Set<Id> caseIds = new Set<Id>();
        //filter only Case feeds
        for(FeedComment comment : insertedComments){
            String parentId = comment.ParentId;
            if(comment.ParentId != null && parentId.subString(0,3) == caseKeyPrefix){
                caseIds.add(comment.ParentId);
            }
        }
        if(!caseIds.isEmpty()){
            //get case status from custom settings
            List<Case> casesToUpdate = new List<Case>(); 
           List<Case> caselist = [SELECT Status,Id,Business_Days_Closed__c FROM Case where id in : caseIds];
               
            if(SageCommunityUserUtil.isSageCommunityUser()){
                Community_Settings__c commSetting = Community_Settings__c.getOrgDefaults();
                for(Case caseComment : caselist ){
                    if(caseComment.Business_Days_Closed__c <= 6 ){
                        caseComment.Status = commSetting.CaseStatusUpdate__c == null ? commSetting.CaseStatusUpdate__c: commSetting.CaseStatusUpdate__c.trim(); 
                        casesToUpdate.add(caseComment);
                    }
                    
                }   
                
                Database.SaveResult [] srLst = Database.update(casesToUpdate,false);
                String outputError = '';
                for(Database.SaveResult srComment : srLst){
                    if(!srComment.isSuccess()){
                        outputError += srComment.getErrors()+'\n';
                    }
                }
                system.debug('Following errors were reported for case status update:'+outputError);
            }                      
            
        }
        
        
    }
    
}