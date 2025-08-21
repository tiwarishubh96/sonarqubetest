public class CampaignInfluence_Helper {
    static string CLASSNAME = 'CampaignInfluence_Helper';
    public static void updateCampaignModelonInsert(List<CampaignInfluence> campInfluence){
        if(RecursiveTriggerHandler.isFirstTime == true){
            RecursiveTriggerHandler.isFirstTime = false;
            try {
                LogControl.push('updateCampaignModelonInsert', CLASSNAME);
                List<CampaignInfluence> campInfs = new List<CampaignInfluence>(); 
                for(CampaignInfluence ci: campInfluence){ 
                    //Create new CampaignInfluence records and add them to the List for 
                    //insert since the original Salesforce Model Records are not editable for modelId. 
                    
                    if (ci.modelId == Label.CampaignInfluenceCustomModel) 
                        return; 
                    CampaignInfluence newCI = new CampaignInfluence(); 
                    newCI.modelId = Label.CampaignInfluenceCustomModel; 
                    newCI.campaignId = ci.campaignId; 
                    newCI.opportunityId = ci.opportunityId; 
                    newCI.Influence = Decimal.valueOf(Label.CampaignInfluencepercent); 
                    //Only insert contactId if there is one. 
                    if(!String.isBlank(ci.contactId)) { 
                        newCI.contactId = ci.contactId; 
                    }
                    campInfs.add(newCI);   
                } 
                if(!campInfs.isEmpty()){ 
                    System.debug('Inside upsert === '+campInfs);
                    upsert campInfs;
                }  
            } catch (Exception e) {
                LogControl.debugException(e);
            } finally {
                LogControl.pop();
            }  
        }
    }
    public static void updateCampaignModelonUpdate(List<CampaignInfluence> campInfluence, Map<Id,CampaignInfluence> oldMap){
        if(RecursiveTriggerHandler.isFirstTime == true){
            RecursiveTriggerHandler.isFirstTime = false;
            try {
                LogControl.push('updateCampaignModelonUpdate', CLASSNAME);
                List<CampaignInfluence> campInfs = new List<CampaignInfluence>(); 
                for(CampaignInfluence ci: campInfluence){ 
                    //Create new CampaignInfluence records and add them to the List for 
                    //insert since the original Salesforce Model Records are not editable for modelId. 
                    
                    if (ci.modelId == Label.CampaignInfluenceCustomModel) 
                        return; 
                    CampaignInfluence newCI = new CampaignInfluence(); 
                    newCI.modelId = Label.CampaignInfluenceCustomModel; 
                    newCI.campaignId = ci.campaignId; 
                    newCI.opportunityId = ci.opportunityId; 
                    newCI.Influence = Decimal.valueOf(Label.CampaignInfluencepercent); 
                    //Only insert contactId if there is one. 
                    if(!String.isBlank(ci.contactId)) { 
                        newCI.contactId = ci.contactId; 
                    }
                    campInfs.add(newCI);   
                } 
                if(!campInfs.isEmpty()){ 
                    upsert campInfs;
                }  
            } catch (Exception e) {
                LogControl.debugException(e);
            } finally {
                LogControl.pop();
            } 
        }
    }
}