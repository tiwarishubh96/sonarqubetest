@isTest
public class IntacctToCBCLeadTransferHelperTest {
    
    public Static testmethod void createLead(){
        
        Profile profile = [select Id from Profile where Name = 'System Administrator'];
        USer testUser = new User(alias = 'testuser',
                        email = 'testuser@myexample.com', emailencodingkey = 'UTF-8', lastname = 'Testing',
                        languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = profile.Id, 
                        timezonesidkey = 'America/New_York',username = 'testuser@myexample.com');
        insert testUser;
        Group grp = new Group(Name = 'Sage_Intacct',type='Queue');
        insert grp;
        QueuesObject q1 = new QueueSObject(QueueID = grp.id, SobjectType = 'Lead');
        insert q1;
        
        System.runAs(testUser) {
            insert new Application_Control__c(SetupOwnerId=UserInfo.getOrganizationId(), Run_Validation_Rules__c=true);
            Group grup = [SELECT Id, Name FROM Group WHERE DeveloperName = 'Sage_Intacct' AND type='Queue' LIMIT 1];
            List<Lead> leads = new List<Lead>();
            Lead lead1 = new Lead(FirstName='Test Firstname',LastName='Test LastName',Email='test1@tes.com',
                             Status = 'New', Street='test Street', City='Bridgewater', State='New Jersey',
                             Country='United States', PostalCode='08807', 
                             company='Test Company1', Product__C = 'Sage Intacct', Passed_Reason__C = 'Testing');
            leads.add(lead1);
            Lead lead2 = new Lead(FirstName='Test Firstname',LastName='Test LastName2',Email='test2@tes.com',
                             Street='test Street', City='Bridgewater', State='New Jersey',Country='United States', PostalCode='08807',
                             company='Test Company2', Product__C = 'Sage Intacct',
                             Status ='Archived', Status_Reason__c = 'Duplicate (Non Customer)', Passed_Reason__C = 'Testing');
            leads.add(lead2);
            Test.startTest();
            insert leads;
            Test.stopTest();
            Set<String> lids = new Set<String>{lead1.id,lead2.id};
            List<Campaign> campaigns = new List<Campaign>();
            for(Integer i = 0; i < 2; i++){
                Campaign cmpaign = new Campaign();
                cmpaign.Activity_Sub_Type__c = 'BR - Advertising Out of Home';
                cmpaign.Campaign_Manager__c = 'Campaign_Manager__c' + i;
                cmpaign.Name = 'ACS_21Q1_NCA_AU_test1' + i;
                cmpaign.Initiative__c = 'New';
                cmpaign.Partner_Involvement__c = 'Partner';
                cmpaign.Product__c = 'Sage 50 US';
                cmpaign.Region__c = 'North America';
                cmpaign.Activity_Objective__c = 'Acquisition';
                cmpaign.Country__c = 'US - United States'; 
                cmpaign.Objective__c = 'NCA';
                cmpaign.Expected_MQL__c = i;
                cmpaign.Cost_per_MQL__c = i;
                campaigns.add(cmpaign);
            }
            insert campaigns;
            List<CampaignMember> campaignMembs = new List<CampaignMember>();
            for(Integer i = 0; i < 2; i++){
                CampaignMember campaignMembr = new CampaignMember();
                campaignMembr.CampaignId = campaigns[i].Id;
                campaignMembr.LeadId = leads[i].Id;
                campaignMembs.add(campaignMembr);
            }
            insert campaignMembs;
            List<Campaign> camps = [SELECT ID, Name, Product__c, Region__c FROM Campaign];
            List<CampaignMember> campMembers = [SELECT Id, LeadID, CampaignID, Campaign.Name FROM CampaignMember WHERE LeadId IN : lIds];
            system.debug('campMembers in test>>'+campMembers);
            RecursiveTriggerHandler.isFirstTime = true;
            for(Lead l :leads){
                l.OwnerId = grup.Id;
            }
            update leads;

        }

    } 
}