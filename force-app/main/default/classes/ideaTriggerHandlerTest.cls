/*
	Test class for ideaTriggerhandler including the business logic
	EAD-438

*/
@isTest
public class ideaTriggerHandlerTest {
    
    static testMethod void testValidateCategoriesSelection(){
        
        //communityid is id of Internal Community
        Community community = [ SELECT Id FROM Community WHERE Name = 'INTERNAL COMMUNITY'];
        
        Profile sysProfile = [ select Id from Profile where Name = 'System Administrator'];
        
        User sysadmin = new User(alias = 'testuser',
                        email = 'testsysadmin@myexample.com', emailencodingkey = 'UTF-8', lastname = 'sysadmin',
                        languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = sysprofile.Id, 
                        timezonesidkey = 'America/New_York',username = 'testsysadmin@myexample.com');
        insert sysadmin;
        
        Idea objIdea = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,
                                categories = 'Product > Sage Payroll (IE);Product > Sage Pay');
        
        runAsUser(sysadmin,objIdea);
        
        Idea objIdeaWithManager = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,
                                categories = 'Product > Sage Payroll (IE);Product > Sage Pay');
        
		runAsUser(sysadmin,objIdeaWithManager);
        
        Idea objIdeaWithManagerAndDept = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,Dept__c='Brand',
                                categories = 'Product > Sage Payroll (IE);Product > Sage Pay');
        
        runAsUser(sysadmin,objIdeaWithManagerAndDept);
        
        Idea objIdeaWithManagerAndDeptAndBenefit = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,Dept__c='Brand',
                                Benefit__c ='Revenue Generating',categories = 'Product > Sage Payroll (IE);Product > Sage Pay');
        
        runAsUser(sysadmin,objIdeaWithManagerAndDeptAndBenefit);
        
        Idea objIdeaWithManagerAndDeptAndBenefitAndST = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,Dept__c='Brand',
                                Benefit__c ='Revenue Generating',categories = 'Product > Sage Payroll (IE)');
        
        runAsUser(sysadmin,objIdeaWithManagerAndDeptAndBenefitAndST);
        
        Idea objIdeaWithManagerNoCategories = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,Dept__c='Brand',
                                Benefit__c ='Revenue Generating');
        
        runAsUser(sysadmin,objIdeaWithManagerNoCategories);
        
        Idea objIdeaWithManagerNoStatus = new Idea (Title='New idea', Body ='Hi!', Location__c = 'Newcastle', Category__c ='Customers For Life',
                                Impact__c = 'Occassionally',Impacted_Users__c='A few',communityId = community.id,Manager_Name1__c=sysadmin.id,Dept__c='Brand',
                                Benefit__c ='Revenue Generating',categories = 'Product > Sage Payroll (IE)', status='');
        
        runAsUser(sysadmin,objIdeaWithManagerNoStatus);
    }
    
    private static Boolean containsErrorMSG(Exception e){
        
       Boolean expectedExceptionThrown =  e.getMessage().contains('Please select only one Category!') ? true : 
                									e.getMessage().contains('Please fill out Manager Name!')?true:
                									e.getMessage().contains('Please fill out Dept!')?true:
                									e.getMessage().contains('Please fill out Benefit!')?true:
                									e.getMessage().contains('Please fill out Strategic Theme!')?true:
        											e.getMessage().contains('Please select from Categories!')?true:
        											e.getMessage().contains('Please select from Status!')?true:false;
        return expectedExceptionThrown;
    }
    
    private static void runAsUser(User sysadmin, Idea ideaObj){
        
		System.runAs(sysadmin){
            
            try{
        	
            	insert ideaObj; 
                
            }catch(Exception e){
                
                system.assertEquals(containsErrorMSG(e),true);    
            } 
        }        
    }

}