public with sharing class SageCommunityCasePost {
    
    public static void changeCaseStatusOnCommunityUserPost(List<FeedItem> insertedItems){
        system.debug('*** SageCommunityCasePost.changeCaseStatusOnCommunityUserPost callout with parameter @insertedItems: '+JSON.serialize(insertedItems));
        Schema.DescribeSObjectResult caseDescribe = Case.sObjectType.getDescribe();
        String caseKeyPrefix = caseDescribe.getKeyPrefix();
        //gather all feeItems for cases
        Set<Id> caseIds = new Set<Id>();
        //filter only Case feeds
        for(FeedItem item : insertedItems){
            String parentId = item.ParentId;
            if(item.ParentId != null && parentId.subString(0,3) == caseKeyPrefix){
                caseIds.add(item.ParentId);
                
            }
        }
        if(!caseIds.isEmpty()){
            //get case status from custom settings
            List<Case> casesToUpdate = new List<Case>();
            
            List<Case> caselist = [SELECT Status,Id,Business_Days_Closed__c FROM Case where id in : caseIds];
            
            if(SageCommunityUserUtil.isSageCommunityUser()){
                Community_Settings__c commSetting = Community_Settings__c.getOrgDefaults();
                //Retrieve the Case List
                for(Case caseItem : caselist ){
                    if(caseItem.Business_Days_Closed__c <= 6){
                        caseItem.Status = commSetting.CaseStatusUpdate__c == null ? commSetting.CaseStatusUpdate__c: commSetting.CaseStatusUpdate__c.trim();
                        casesToUpdate.add(caseItem);
                    }
                    
                }
                
                Database.SaveResult [] srLst = Database.update(casesToUpdate,false);
                
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