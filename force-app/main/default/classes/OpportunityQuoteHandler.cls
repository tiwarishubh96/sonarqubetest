public inherited sharing class OpportunityQuoteHandler extends TriggerService {
    private MapAccountCountryToOppCountry mapCountryHelper;

    public OpportunityQuoteHandler() {
        this.mapCountryHelper = new MapAccountCountryToOppCountry();
    }

    public void setOverride(MapAccountCountryToOppCountry mapCountryHelper) {
        this.mapCountryHelper = mapCountryHelper;
    }

    public override void onBeforeUpdate() {
        this.mapCountryHelper.oppsWithQuotes((Map<Id, Opportunity>) this.mapOldSObject, (List<Opportunity>) this.listNewSObject, (Map<Id, Opportunity>) this.mapNewSObject);
    }
}