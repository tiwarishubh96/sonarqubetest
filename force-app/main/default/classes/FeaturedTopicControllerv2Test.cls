@isTest
public class FeaturedTopicControllerv2Test {
    
    static testmethod void getCountryListTest(){
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        String CommunityConfigName = 'Sage Partner Community';
        Community_Config__c communityConfig = new Community_Config__c();
        communityConfig.Name = CommunityConfigName;
        communityConfig.Country_Code__c = 'ca; de; es; fr; gb; us';
        communityConfig.Language_Code__c = 'de; en; es; fr';
        communityConfig.Community_Name__c='Sage Partner Community';
        insert communityConfig;
        system.runAs(u){
            test.startTest();
            FeaturedTopicController_v2.getCountriesList();
            FeaturedTopicController_v2.getCountriesListWithLanguage();
            test.stopTest();
        }
    }
    
    static testmethod void deleteimage(){
        Document document;
        document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = [select id, DeveloperName from folder where DeveloperName = 'Partner_Community_Resources'].id;
        insert document;
        List<ID> ids=new List<ID>();
        ids.add(document.Id);
        FeaturedTopicController_v2.deleteDocumentImages(ids);
    }
    
    
    static testMethod void saveSettingsTest(){
        
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c(); 
 
        communityComponentConfig.Name = 'sample Test';
        communityComponentConfig.Permission_Name__c = 'Sage: Customer CC Admin';
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communitycomponentConfig.Community_Id__c = System.Label.PartnerCommunityId;
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;
        system.runAs(u){
            test.startTest();
            FeaturedTopicController_v2.saveSettings(null, communityComponentConfig.Component_Name__c,
                                                 communityComponentConfig.Component_Type__c, communityComponentConfig.Permission_Name__c, communityComponentConfig.Settings__c);
            FeaturedTopicController_v2.saveSettings(communityComponentConfig.Id, communityComponentConfig.Component_Name__c,
                                                 communityComponentConfig.Component_Type__c, communityComponentConfig.Permission_Name__c, communityComponentConfig.Settings__c);
            test.stopTest();
        }
    }
    
    static testMethod void getComponentConfigTest1(){
    
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        Id AccountRecordtypeId = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where SobjectType = 'Account' and IsActive = true and DeveloperName = 'Partner_Account'].id;
        Account objAccount = New Account();
        objAccount.id = c.AccountId;
        objAccount.Company_Registration_Number__c = '11';
        objAccount.Partner_Accountant__c = true;
        objAccount.Partner_Accountant_TnC__c = true;
        objAccount.recordTypeId = AccountRecordtypeId;
        objAccount.Accountant_Partner_Tier__c = 'Platinum';
        objAccount.Partner_Alliance_TnC__c = true;
        objAccount.Partner_Alliance__c = true;
        objAccount.Alliance_Partner_Tier__c = 'Global Sage';
        objAccount.Partner_ISV__c = true;
        objAccount.Partner_ISV_TnC__c = true;
        objAccount.ISV_Partner_Tier__c = 'RockStar';
        objAccount.Partner_Reseller__c = true;
        objAccount.Partner_Reseller_TnC__c = true;
        objAccount.Reseller_Partner_Tier__c = 'Platinum';
        objAccount.Partner_Implementation__c = true;
        objAccount.Partner_Implementation_TnC__c = true;
        objAccount.SI_Partner_Tier__c = 'Platinum';
        update objAccount;
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();

        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = '0DB2400000083TUGAY';
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;  
        
        List<CommunitiesUIConfig__mdt> listCommunitiesUIConfig =  [select id,Partner_Tier__c,Partner_Type__c,CommunityId__c from CommunitiesUIConfig__mdt];
        system.debug('listCommunitiesUIConfig::>>' + listCommunitiesUIConfig);
              
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController_v2.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
    
    static testMethod void getComponentConfigTest2(){
    
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        Id AccountRecordtypeId = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where SobjectType = 'Account' and IsActive = true and DeveloperName = 'Partner_Account'].id;
        Account objAccount = New Account();
        objAccount.id = c.AccountId;
        objAccount.Company_Registration_Number__c = '11';
        objAccount.Partner_Accountant__c = true;
        objAccount.Partner_Accountant_TnC__c = true;
        objAccount.recordTypeId = AccountRecordtypeId;
        objAccount.Accountant_Partner_Tier__c = 'Silver';
        objAccount.Partner_Alliance_TnC__c = true;
        objAccount.Partner_Alliance__c = true;
        objAccount.Alliance_Partner_Tier__c = 'Corporate';
        objAccount.Partner_ISV__c = true;
        objAccount.Partner_ISV_TnC__c = true;
        objAccount.ISV_Partner_Tier__c = 'Champion';
        objAccount.Partner_Reseller__c = true;
        objAccount.Partner_Reseller_TnC__c = true;
        objAccount.Reseller_Partner_Tier__c = 'Gold';
        objAccount.Partner_Implementation__c = true;
        objAccount.Partner_Implementation_TnC__c = true;
        objAccount.SI_Partner_Tier__c = 'Gold';
        update objAccount;
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        
        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = System.Label.PartnerCommunityId;
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;        
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController_v2.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
    
    static testMethod void getComponentConfigTest3(){
    
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        Id AccountRecordtypeId = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where SobjectType = 'Account' and IsActive = true and DeveloperName = 'Partner_Account'].id;
        Account objAccount = New Account();
        objAccount.id = c.AccountId;
        objAccount.Company_Registration_Number__c = '11';
        objAccount.Partner_Accountant__c = true;
        objAccount.Partner_Accountant_TnC__c = true;
        objAccount.recordTypeId = AccountRecordtypeId;
        objAccount.Accountant_Partner_Tier__c = 'Gold';
        objAccount.Partner_ISV__c = true;
        objAccount.Partner_ISV_TnC__c = true;
        objAccount.ISV_Partner_Tier__c = 'Developer';
        objAccount.Partner_Reseller__c = true;
        objAccount.Partner_Reseller_TnC__c = true;
        objAccount.Reseller_Partner_Tier__c = 'Silver';
        objAccount.Partner_Implementation__c = true;
        objAccount.Partner_Implementation_TnC__c = true;
        objAccount.SI_Partner_Tier__c = 'Silver';
        update objAccount;
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = System.Label.PartnerCommunityId;
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;        
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController_v2.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
    
    static testMethod void getComponentConfigTest4(){
    
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        Id AccountRecordtypeId = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where SobjectType = 'Account' and IsActive = true and DeveloperName = 'Partner_Account'].id;
        Account objAccount = New Account();
        objAccount.id = c.AccountId;
        objAccount.Company_Registration_Number__c = '11';
        objAccount.Partner_Accountant__c = true;
        objAccount.Partner_Accountant_TnC__c = true;
        objAccount.recordTypeId = AccountRecordtypeId;
        objAccount.Accountant_Partner_Tier__c = 'Authorized';
        objAccount.Partner_Reseller__c = true;
        objAccount.Partner_Reseller_TnC__c = true;
        objAccount.Reseller_Partner_Tier__c = 'Authorized';
        objAccount.Partner_Implementation__c = true;
        objAccount.Partner_Implementation_TnC__c = true;
        objAccount.SI_Partner_Tier__c = 'Authorized';
        update objAccount;
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = System.Label.PartnerCommunityId;
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;        
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController_v2.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
    
    static testmethod void getComponentConfigTest5(){
    
        Contact c = CommunityUtilitiesTest.createAccountAndContact('Test', 'test', 'test', 'hasPermissionSet@sage.com');
        
        Id AccountRecordtypeId = [SELECT DeveloperName,Id,IsActive,Name,SobjectType FROM RecordType where SobjectType = 'Account' and IsActive = true and DeveloperName = 'Partner_Account'].id;
        Account objAccount = New Account();
        objAccount.id = c.AccountId;
        objAccount.Company_Registration_Number__c = '11';
        objAccount.recordTypeId = AccountRecordtypeId;
        objAccount.Partner_Accountant__c = true;
        objAccount.Partner_Accountant_TnC__c = true;
        objAccount.Partner_Alliance_TnC__c = true;
        objAccount.Partner_Alliance__c = true;
        objAccount.Partner_ISV__c = true;
        objAccount.Partner_ISV_TnC__c = true;
        objAccount.Partner_Reseller__c = true;
        objAccount.Partner_Reseller_TnC__c = true;
        objAccount.Partner_Implementation__c = true;
        objAccount.Partner_Implementation_TnC__c = true; 
        objAccount.Accountant_Partner_Tier__c = 'Silver';
        update objAccount;
        
        User u = CommunityUtilitiesTest.createPortalUser(c.Id, 'test', 'test', 'hasPermissionSet@sage.com', 'hasPermissionSet@sage.com');
        Community_Component_Config__c communityComponentConfig = new Community_Component_Config__c();
        communityComponentConfig.Name = 'sample Test';
        communitycomponentConfig.Community_Id__c = System.Label.PartnerCommunityId;
        communityComponentConfig.Component_Name__c = 'Customer SageOneStart Test';
        communityComponentConfig.Component_Type__c = 'Featured Articles Component';
        communityComponentConfig.Permission_Name__c = Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL;
        
        communityComponentConfig.Settings__c = '{"configName":"tilerv3ham07","imageAlignment":"horizontal","imagesPerRow":"4","imagePosition":"Left","imageCropWidth":"","imageCropHeight":"","images":[{"imageId":"1512672563383","imageLabel":"Overview !","imageMenuCss":"slds-item slds-is-selected","isPreviewAvailable":"true","previewImageUrl":"","previewImageId":"","isDisplay":true,"locales":[{"categoryCode":"en_US","languageCountryLabel":"English (United States)","categoryLabel":"United States","displayInNewWindow":true,"isSelected":false,"overLayText":"Sage Payments","targetUrl":""}],"tiers":[{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":true,"partnerTierName":"Silver"}],"partnerTypeName":"System Implementer"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Reseller"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Authorized"},{"isSelected":false,"partnerTierName":"Gold"},{"isSelected":false,"partnerTierName":"Platinum"},{"isSelected":false,"partnerTierName":"Silver"}],"partnerTypeName":"Accountant"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Champion"},{"isSelected":false,"partnerTierName":"Developer"},{"isSelected":false,"partnerTierName":"Rockstar"}],"partnerTypeName":"ISV"},{"partnerTierList":[{"isSelected":false,"partnerTierName":"Corporate Partner"},{"isSelected":false,"partnerTierName":"Strategic Alliance"}],"partnerTypeName":"Alliance"}],"message":""}]}';
        //communityComponentConfig.Settings__c = '{"maxRecords":10, "featuredtabCount":5, "featuredTabs" : [{"languageLabels": {"en": "Support","default": "Support"}, "dataCategories": {"Products": "Start"}}]}';
        insert communityComponentConfig;        
        system.runAs(u){
            test.startTest();
            CommunityUtilitiesTest.addPermissionSet(u.Id, Constants.MANAGE_SUBSCRIPTION_PERMISSION_SET_LABEL);
            FeaturedTopicController_v2.getComponentConfig(communityComponentConfig.Component_Name__c, communityComponentConfig.Component_Type__c, 
                                                       communityComponentConfig.Permission_Name__c);
            test.stopTest();
        }
    }
}