@isTest
public class CampaignInfluenceHelperTest {    
    public static testMethod void createCampaignInflunce(){
        Campaign cmp = new Campaign();
        cmp.Activity_Sub_Type__c = 'BR - Advertising Out of Home';
        cmp.Campaign_Manager__c = 'Manager' ;
        cmp.Name = 'ACS_21Q1_NCA_AU_test' ;
        cmp.Initiative__c = 'New';
        cmp.Partner_Involvement__c = 'Partner';
        cmp.Product__c = 'Sage 50 US';
        cmp.Region__c = 'North America';
        cmp.Country__c = 'US - United States'; 
        cmp.Objective__c = 'NCA';
        cmp.IsActive = true;
        insert cmp;
        Account acc = new Account(Name = 'TestAccount');
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for(Integer i=0 ; i<5; i++){
            Contact c = new Contact(Salutation='Mr',LastName = 'Test Contact'+i,
                                    Email='Test'+i+'@test123'+i+'.com', 
                                    AccountId=acc.Id);
            contacts.add(c);
        }
        insert contacts;
        List<CampaignMember> listCampaignMember = new List<CampaignMember>();        
        for(Integer i = 0; i < 3; i++){
            CampaignMember campaignMembr = new CampaignMember();
            campaignMembr.CampaignId = cmp.Id;
            campaignMembr.ContactId = contacts[i].Id;
            campaignMembr.Status = 'Not Called';  
            listCampaignMember.add(campaignMembr);
        }
        insert listCampaignMember;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=0;i<3;i++) {
            
            Opportunity Opp = new Opportunity(AccountId = acc.Id, name = 'OppPushCounter'+i, 
                                              StageName = Label.Opportunity_Sales_Stages_Stage1,
                                              Why_We_Lost__c = 'COVID-19',
                                              CloseDate = Date.today(),Lead_Source__c = 'Marketing');
            oppList.add(opp);
        }
        insert oppList; 
        
        Test.startTest();
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppList[0].id;
        ocr.ContactId = contacts[0].id;
        insert ocr;
       
        CampaignInfluence newCI = new CampaignInfluence(); 
        newCI.modelId = Label.CampaignInfluenceprimaryModel; 
        newCI.campaignId = cmp.Id; 
        newCI.opportunityId = oppList[0].id;
        newCI.Influence = Decimal.valueOf(Label.CampaignInfluencepercent); 
        newCI.contactId = contacts[0].id; 
        RecursiveTriggerHandler.isFirstTime = true;
        insert newCI;

        List<CampaignInfluence> campInfs = [SELECT Id, OpportunityId, ContactId FROM CampaignInfluence];
        system.assert(campInfs.size() > 1);
        
        RecursiveTriggerHandler.isFirstTime = true;
        newCI.Influence = 77;
        update newCI;
        CampaignInfluence_TriggerHandler ct = new CampaignInfluence_TriggerHandler();
		ct.BeforeDelete(new Map<Id, SObject>());
        ct.AfterDelete(new Map<Id, SObject>());
        ct.AfterUndelete(new Map<Id, SObject>());
        Test.stopTest();
    }
}