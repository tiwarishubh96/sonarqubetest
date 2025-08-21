public without sharing class CampaignInfluence_TriggerHandler implements TriggerHandlerInterface{
    public void BeforeInsert(List<SObject> newItems){}
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    public void AfterInsert(Map<Id, SObject> newItems){
        CampaignInfluence_Helper.updateCampaignModelonInsert((List<CampaignInfluence>)newItems.values());
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
         CampaignInfluence_Helper.updateCampaignModelonUpdate((List<CampaignInfluence>)newItems.values(), (Map<Id, CampaignInfluence>)oldItems);
    }
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUndelete(Map<Id, SObject> oldItems){}
}