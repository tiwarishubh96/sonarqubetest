public with sharing class SageCommunitySuccessPlanPostComment {
    
         public static void changeSuccessPlanOnCommunityUserPostComment(List<FeedComment> insertedComments){
        system.debug('*** SageCommunityCasePost.changeSuccessPlanOnCommunityUserPost callout with parameter @insertedComments: '+JSON.serialize(insertedComments));
        if(SageCommunityUserUtil.isSageCommunityUser()){
            Schema.DescribeSObjectResult successPlanDescribe = Success_Plan__c.sObjectType.getDescribe();
      String succesPlanKeyPrefix = successPlanDescribe.getKeyPrefix();
            //gather all feedComments for Success Plans
            Set<Id> planIds = new Set<Id>();
            //filter only Success Plan feedComments
            for(FeedComment comment : insertedComments){
                String parentId = comment.ParentId;
                if(comment.ParentId != null && parentId.subString(0,3) == succesPlanKeyPrefix){
                    planIds.add(comment.ParentId);
                }
            }
            //Retrieve the Success Plan List
            if(!planIds.isEmpty()){
                List<Success_Plan__c> plansToUpdate = new List<Success_Plan__c>();
                Community_Settings__c commSetting = Community_Settings__c.getOrgDefaults();
                for(Success_Plan__c planComment : [SELECT Sub_Status__c,Id FROM Success_Plan__c where id in : planIds]){
                    planComment.Sub_Status__c = commSetting.SuccessPlanSubStatusUpdate__c == null ? commSetting.SuccessPlanSubStatusUpdate__c: commSetting.SuccessPlanSubStatusUpdate__c.trim();
                    plansToUpdate.add(planComment);
                }
                
                Database.SaveResult [] srLst = Database.update(plansToUpdate,false);
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