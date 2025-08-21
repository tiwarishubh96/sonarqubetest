/*
* Class Name :- CustomerStoryTriggerTest
* Author :- Shubham Kimothi
* Created Date :- 27-05-2019
* Description : This test class is covering the code of CustomerStoryTrigger.
* 
// ********************Change Logs *****************************************************************************************************************************
*/

@isTest 
private class CustomerStoryTriggerTest {
     public static testMethod void CustomerStoryTriggerTest1(){
         Account acc = new Account();
         acc.Name = 'test account';
         acc.Type = 'analyst';
         insert acc;

         Customer_Story__c cs = new Customer_Story__c();
         cs.Name = 'Test Story';
         cs.CompanySize__c = 'Small';
         cs.Name ='Test Story';
         cs.Account__c = acc.Id;
         cs.CompanySize__c = 'Small';
         cs.Name__c = 'test user';
         cs.Telephone__c = '000123';
         cs.JobRole__c = 'developer';
         cs.Country__c = 'IN - India';
         cs.Industry__c = 'Mining';
         cs.ProductSolution__c = 'GL - Accounting';
         cs.Location__c = 'IN';
         cs.Theirpositionjobtitle__c = 'Manager';
         cs.CustEmailAddress__c = 'testu@sage.com';
         cs.EmailAddress__c = 'testu1@sage.com';
         cs.TelephoneNumber__c = '+9111111';
         cs.Salesandmarketingneedsobjectives__c = 'Yes';
         cs.Whichcampaignswillthisbefeatured__c = 'Yes';
         cs.Furtherrelevantinfoaboutthisstory__c = 'Test';
         cs.Reasonsalesandmarketingobjective__c = 'test';
         cs.Whatotheruseswillthisstoryhave__c = 'test';
         //cs.Languagesrequiredforthisstory__c = 'Eng';
         cs.Whatnextstepshaveyouagreed__c = 'test';
         cs.HaveyoudiscussedSpotlightprocesses__c = 'test';
         cs.Otherstakeholderstobeincluded__c = 'test';
         cs.Whoshouldbeintheapprovalprocess__c = 'test';
         cs.Whatarethemainbenefitsofthestory__c = 'test';
         insert cs;
         update cs;
         delete cs;
     }
}