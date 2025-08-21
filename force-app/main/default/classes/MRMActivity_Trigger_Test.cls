@isTest
public class MRMActivity_Trigger_Test {
    @isTest
    public static void MRMActivityTriggerTest(){ 
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            MRM_Activity__c mrmActivity=new MRM_Activity__c();
            mrmActivity.Name='test';
            mrmActivity.Campaign_Name__c='testcampaign';
            mrmActivity.Activity_SubType__c='CN - Case Study';
            mrmActivity.Product_Category__c='CRE';
            mrmActivity.Product_Segment__c='Medium';
            mrmActivity.Objective__c='Both';
            mrmActivity.Activity_Objective__c='Cross Sell';
            mrmActivity.Partner_Involvement__c='Accountant';
            mrmActivity.Priority__c='Green';
            mrmActivity.Owner__c='testowner';
            mrmActivity.StartDate__c=DateTime.newInstance(2020, 11, 18, 3, 3, 3);
            mrmActivity.EndDate__c=DateTime.newInstance(2099, 11, 18, 3, 3, 3);
            mrmActivity.Expected_MQL__c=10.00;
            mrmActivity.ExpectedRevenue__c=10;
            mrmActivity.Country__c='AU - Australia';
            //mrmActivity.Region__c='Australia';
            
             Test.startTest();
            try
            {
                insert mrmActivity;
                List<MRM_Activity__c> mrm=[select id,Name,Region__c from MRM_Activity__c where id=:mrmActivity.Id];
                System.assertEquals('Australia', mrm[0].Region__c);
            }
            catch(Exception e)
            {
                System.debug('Exception '+ e.getMessage());
            }
        
        Test.stopTest();
           
            mrmActivity.Country__c='AT - Austria';
            update mrmActivity;
            
        }
    }
}