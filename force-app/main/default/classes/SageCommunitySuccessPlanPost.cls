public with sharing class SageCommunitySuccessPlanPost {
    
        public static void changeSuccessPlanOnCommunityUserPost(List<FeedItem> insertedItems){
        system.debug('*** SageCommunityCasePost.changeSuccessPlanOnCommunityUserPost callout with parameter @insertedItems: '+JSON.serialize(insertedItems));
        if(SageCommunityUserUtil.isSageCommunityUser()){
            Schema.DescribeSObjectResult successPlanDescribe = Success_Plan__c.sObjectType.getDescribe();
            String succesPlanKeyPrefix = successPlanDescribe.getKeyPrefix();
            //gather all feedItems for Success Plans
            Set<Id> planIds = new Set<Id>();
            //filter only Success Plan feeditems
            for(FeedItem item : insertedItems){
                String parentId = item.ParentId;
                if(item.ParentId != null && parentId.subString(0,3) == succesPlanKeyPrefix){
                    planIds.add(item.ParentId);
                }
            }
            //Retrieve the Success Plan List
            if(!planIds.isEmpty()){
                List<Success_Plan__c> plansToUpdate = new List<Success_Plan__c>();
                Community_Settings__c commSetting = Community_Settings__c.getOrgDefaults();
                for(Success_Plan__c planItem : [SELECT Sub_Status__c,Id FROM Success_Plan__c where id in : planIds]){
                    planItem.Sub_Status__c = commSetting.SuccessPlanSubStatusUpdate__c == null ? commSetting.SuccessPlanSubStatusUpdate__c: commSetting.SuccessPlanSubStatusUpdate__c.trim();
                    plansToUpdate.add(planItem);
                }
                
                Database.SaveResult [] srLst = Database.update(plansToUpdate,false);
                String outputError = '';
                for(Database.SaveResult srItem : srLst){
                    if(!srItem.isSuccess()){
                        outputError += srItem.getErrors()+'\n';
                    }
                }
                system.debug('Following errors were reported for case status update:'+outputError);
               
            }
            
            
        }
    }
 

}