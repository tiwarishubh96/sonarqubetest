public with sharing class LiveAgentGlobalSearchController {
    public PageReference goGS() {
        PageReference pr = new PageReference('/_ui/search/ui/UnifiedSearchResults?searchType=2&sen1=500&sen2=003&str='+criteria);
        return pr;
    }
    
    public String criteria {get; set;}
}