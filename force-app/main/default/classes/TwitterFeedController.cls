public with sharing class TwitterFeedController {


public String widgetId{get; set;}    
public String embedId{get; set;}
public String searchId{get; set;}    
public Boolean cuFlag{get; set;}    
public Boolean btFlag{get; set;}
public Boolean wdFlag{get; set;}
public Boolean createNew;
public String currentTab;
public String commType;

public Map<String, TwitterWidget__c> twittCustMap = new Map<String, TwitterWidget__c>(TwitterWidget__c.getAll());
    
public List<TwitterWidget__c> twitterList = TwitterWidget__c.getall().values();
    
    public TwitterFeedController(){   
    
        currentTab = '';
        createNew = false;
        cuFlag = false;
        
        String currentURL = ApexPages.currentPage().getHeaders().get('referer'); 
        if(currentURL.contains('community') || currentURL.contains('customers')){
            commType = 'community';  
        }else if(currentURL.contains('partner')){
            commType = 'partner';  
        }
        /*
        Set<Id> profId = new Set<Id>();
        for(Profile prof: [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Sage: System Administrator (Cloud Sherpas)', 'Sage: System Administrator')]){
            profId.add(prof.Id);
        }         
        if(profId.contains(UserInfo.getProfileId())){
            cuFlag = true;
        }*/
        
        for(PermissionSetAssignment pa: [SELECT  PermissionSet.Label, PermissionSet.Name, Assignee.Name, Assignee.Id FROM PermissionSetAssignment WHERE PermissionSet.Name IN ( 'Sage_Partner_CC_Admin' , 'Sage_Customer_CC_Admin')]){
            if(pa.Assignee.Id == UserInfo.getUserId()){
                cuFlag = true;
            }
        }
        
        getTwitterId(currentURL);
          
        wdFlag = true;

    }
    
    public void getTwitterId(String currentURL){ 
        String dummyURL1 = ''; 
        String dummyURL2 = '';
		String dummyURL3 = '';
		String dummyURL4 = '';        
        if(String.isNotBlank(currentURL)){
            dummyURL1 = currentURL.substringBetween('s/', '?');
            dummyURL2 = currentURL.substringAfter('s/');     
             if(commType == 'community' && dummyURL2 != null){
                    dummyURL3 = dummyURL2 + '-cs';         
                }else if(commType == 'partner' && dummyURL2 != null){
                    dummyURL3 = dummyURL2 + '-pt';                     
                }
            
              if(commType == 'community' && dummyURL1 != null){
                    dummyURL4 = dummyURL1 + '-cs';         
                }else if(commType == 'partner' && dummyURL1 != null){
                    dummyURL4 = dummyURL1 + '-pt';                     
                }
            
            
            System.debug('@@@@@@@@@@@ dummyURL1: ' + dummyURL1  + ' dummyURL2: ' + dummyURL2 );
            
            if((dummyURL1 == null && dummyURL2 == '') || dummyURL1 == '' && dummyURL2.contains('tabset')){
                System.debug('@@@@@@@@@@@ here 1');
                System.debug('current url '+currentURL);
                if(commType == 'community' ){
                    currentTab = 'Home-cs';         
                }else if(commType == 'partner'){
                    currentTab = 'Home-pt';                     
                }
             searchId = twittCustMap.get(currentTab ).Search_Id__c;
             embedId =  twittCustMap.get(currentTab ).Widget_Id__c;   
            }
            else if(twittCustMap.get(dummyURL4) != null || twittCustMap.get(dummyURL3) != null){
                System.debug('@@@@@@@@@@@ here 1');
                currentTab  = (dummyURL1 != null) ? dummyURL1 : dummyURL2;
                if(commType == 'community'){
                    currentTab = currentTab + '-cs';         
                }else if(commType == 'partner'){
                    currentTab = currentTab + '-pt';                        
                }
                searchId = twittCustMap.get(currentTab  ).Search_Id__c;
                embedId = twittCustMap.get(currentTab  ).Widget_Id__c;
            }
            else{
                System.debug('@@@@@@@@@@@ here 3');
                createNew = true;
                String def = 'Default';
                currentTab = (dummyURL1 != null) ? dummyURL1 : dummyURL2;
                if(commType == 'community'){
                   // currentTab = currentTab + '-cs';   
                    def += '-cs';
                }else if(commType == 'partner'){
                    //currentTab = currentTab + '-pt';
                    def += '-pt';                        
                }
                searchId = twittCustMap.get(def).Search_Id__c;
                embedId =  twittCustMap.get(def).Widget_Id__c;                
            }
            System.debug('@@@@@@@@@@@ searchId: ' + searchId  + ' embedId: ' + embedId + ' currentTab: ' + currentTab);
        }    
    }

    public PageReference Save(){
        if(String.isNotBlank(widgetId)){
            wdFlag = true;
            btFlag = false;
            cuFlag = true;    
            
            String dummysearchId = widgetId.substringBetween('href="', '"');
            String dummyembedId = widgetId.substringBetween('data-widget-id="' , '"'); 
            
            if(String.isNotBlank(dummysearchId) && String.isNotBlank(dummyembedId)){
                searchId = dummysearchId;
                embedId = dummyembedId;
                updateCustomSetting();
            }
        }                      
        return null;     
    }
    
    public void updateCustomSetting(){
        if(!createNew){
            TwitterWidget__c twitt = twittCustMap.get(currentTab);
            twitt.Widget_Id__c = embedId;
            twitt.Search_Id__c  = searchId;
            update twitt;
        }
        else{
            System.debug('@@@@@@@@@@@ currentTab: ' + currentTab);
            TwitterWidget__c twitt = new TwitterWidget__c();
            String name = '';
            If(commType == 'community'){
            	name = currentTab + '-cs';
                twitt.Community__c = 'Customer';
            }else if(commType == 'partner'){
            	name = currentTab + '-pt';
                twitt.Community__c = 'Partner';
            }
            twitt.Name = name;
            system.debug('name' + name);
            system.debug('twitter' + twitt.Name);
            twitt.Page_Name__c = currentTab;
            twitt.Widget_Id__c = embedId;
            twitt.Search_Id__c = searchId;
            insert twitt;
        }
    }
    
    public PageReference Cancel(){
        cuFlag = true;
        wdFlag = true;
        btFlag = false;
        return null;
    }
    
    public void Click(){       
        String http = 'http';
        String https = 'https';
        cuFlag = false;
        wdFlag = false;
        btFlag = true;
        widgetId = '<a class="twitter-timeline"  href="' + searchId + '" data-widget-id="' + embedId + '"></a><script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?' + http + ':' + https + ';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>';        
    }
}