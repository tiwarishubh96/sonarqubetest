/**
 * @description Tests associated class.
 *
 * @author		Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest
public with sharing class GenericCaseCreatorInvkTest
{

    /**
     * @description Coverage test only as real logic heavily relies on salesforce configuration.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-24
     */
    @IsTest(SeeAllData=false) static void testCaseUpsert()
    {
        List<AssignmentRule> aRules = [Select Id,Name,SobjectType,Active from AssignmentRule Limit 1];
        Id aRuleId = aRules.isEmpty() ? null : aRules[0].Id;
		RecordType partnerCaseRT = [Select Id from RecordType where SObjectType = 'Case' and Name = 'Partner Case'];
        GenericCaseCreatorInvk.Request req1 = new GenericCaseCreatorInvk.Request();
        req1.sobj = new Case(Subject = 'Test', Description = 'Test', RecordTypeId = partnerCaseRT.Id);
        req1.assignmentRuleID = aRuleId;

        GenericCaseCreatorInvk.Request req2 = new GenericCaseCreatorInvk.Request();
        req2.sobj = new Case(Subject = 'Test', Description = 'Test', RecordTypeId = partnerCaseRT.Id);

        GenericCaseCreatorInvk.Request req3 = new GenericCaseCreatorInvk.Request();
        req3.sobj = new Case(Subject = 'Test', Description = 'Test', RecordTypeId = partnerCaseRT.Id);
    
        Test.startTest();
        User testUser = [Select Id from user where Name = 'Zift Integration' Limit 1];
        system.runas(testUser){
            GenericCaseCreatorInvk.upsertSobject(new List<GenericCaseCreatorInvk.Request>{ req1, req2, req3 });
            
        }
        Test.stopTest();
    }
}