global  with sharing class SPPscheduleBulkVoid implements Schedulable
{

    
	global void execute(SchedulableContext sc)
	{
		String id = SC.getTriggerId();
		restCall(id);
	}
	
	@future(callout=true)
	global static void restCall(String jobId)
	{
		List<String> statusList = new List<String>();
        statusList.add('Sent');
        statusList.add('Pending');

        List<Partner_Terms_and_Condition__c> partList = [Select id,DocuSign_EnvelopeId__c from Partner_Terms_and_Condition__c where Voided__c = true and DocuSign_Status__c In :statusList limit 99];
        set<String> enveIds = new set<String>();

        for(Partner_Terms_and_Condition__c par : partList)
	    {
	    	enveIds.add(par.DocuSign_EnvelopeId__c);
	    }
    
		for(String envId : enveIds)
	    {
     		SPPDocuSignRest rest = new SPPDocuSignRest();
        	rest.voidEnvelop(envId);
        	System.debug('Rest Call Made and voided');
	    }

	     system.abortJob(jobId);

	}

}