/**
 * @description Handles live chat transcript dml events.
 *
 * @author		Arturs Gusjko
 */
public with sharing class LiveChatTranscriptTriggerHandler
{
    ////////////////////
    // Trigger events //
    ////////////////////

	static public void beforeInsert()
    {
        assignAccounts();
    }

    ///////////////////////////
    // funcitonal components //
    ///////////////////////////
    
    /**
     * @description Assigns account ids to the transcript. When both account and contact are referenced in the live agent JS api,
     *              the search window is popping up in console instead of actual records.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-26
     */
    static private void assignAccounts()
    {
        LiveChatTranscript[] transcripts = (LiveChatTranscript[])Trigger.new;
        Set<Id> contactIds = GenericUtilities.convertToParentMap(transcripts, 'ContactId').keySet();
        if(contactIds.isEmpty()) return;

        Map<Id, Contact> mapContacts = new Map<Id, Contact>( [SELECT Id, AccountId FROM Contact WHERE Id IN :contactIds] );

        for(LiveChatTranscript t : transcripts)
        {
            if(t.AccountId == null && t.ContactId != null)
            {
                Contact c = mapContacts.get(t.ContactId);
                if(c != null) t.AccountId = c.AccountId;
            }
        }
    }
}