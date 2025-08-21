/**
 * @description Tests associated class.
 *
 * @author		Arturs Gusjko
 */
@IsTest
public with sharing class LiveChatTranscriptTriggerTest
{
	static void setup() {
        Application_Control__c set1 = Application_Control__c.getOrgDefaults();
        set1.Run_Triggers__c = true;
        set1.Run_Validation_Rules__c = false;
        try { upsert set1; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }

        CBC_Application_Control__c set2 = CBC_Application_Control__c.getOrgDefaults();
        set2.Run_Triggers__c = true;
        set2.Run_Validation_Rules__c = false;
        try { upsert set2; } catch(Exception ex) { System.debug(LoggingLevel.Error, ex); }
    }

    @IsTest(SeeAllData=false) static void testAssignAccounts()
    {
        setup();
    
        Account acc = new Account(Name='Test');
        insert acc;

        Account otherAcc = new Account(Name='OtherTest');
        insert otherAcc;

        Contact c = new Contact(Lastname='Test', AccountId = acc.Id);
        insert c;

        Test.startTest();

            LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
        
            LiveChatTranscript[] ts = new List<LiveChatTranscript>();
            ts.add(new LiveChatTranscript(ContactId = c.Id, LiveChatVisitorId = visitor.Id));
            ts.add(new LiveChatTranscript(ContactId = c.Id, AccountId = otherAcc.Id, LiveChatVisitorId = visitor.Id));
            ts.add(new LiveChatTranscript(LiveChatVisitorId = visitor.Id));
    
            insert ts;

            Map<Id, LiveChatTranscript> mapTranscripts = new Map<Id, LiveChatTranscript>((List<LiveChatTranscript>)GenericUtilities.resetSObjects(ts));

            System.assertEquals(acc.Id, mapTranscripts.get(ts[0].Id).AccountId);
            System.assertEquals(otherAcc.Id, mapTranscripts.get(ts[1].Id).AccountId);
            System.assertEquals(null, mapTranscripts.get(ts[2].Id).AccountId);

        Test.stopTest();
    }
}