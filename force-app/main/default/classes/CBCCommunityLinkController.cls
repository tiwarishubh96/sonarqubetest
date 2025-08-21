public without sharing class CBCCommunityLinkController {
    
    public CBCCommunityLinkController(){}
    
    public PageReference redirectToCommunity(){
        String serverInstance = URL.getSalesforceBaseUrl().toExternalForm();
        
        String communityName = Community_Settings__c.getOrgDefaults().Sage_Live_Community_Name__c;
        if(communityName != null){
            communityName = communityName.trim();
        }
        serverInstance += '/servlet/networks/switch?networkId=';
        String communityId = '';
        ConnectApi.CommunityPage commPage = ConnectApi.Communities.getCommunities(); 
        for(ConnectApi.Community commItem : commPage.communities){
            if(commItem.name == communityName){
                communityId = commItem.id;
            }
        }
        //need to concatenate to 15 signs
        if(communityId != null && communityId !=''){
            serverInstance += communityId.substring(0,15);
        }
        
        
        PageReference pg = new PageReference(serverInstance);
        pg.setRedirect(false);
        return pg;
    }

}