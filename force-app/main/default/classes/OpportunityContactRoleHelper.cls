/**
 * @author 	    	Pete Wilson
 * @date 	        10 July 2020
 * @description 	Maintain Primary Contact lookup on Opportunity based on the Opportunity Contact Roles.
 *                  The field is used in sending out (RnR) surveys.
 */
public class OpportunityContactRoleHelper {
    
    static string CLASSNAME = 'OpportunityContactRoleHelper';
    
    public static void updateOpportunityPrimaryContact(List<OpportunityContactRole> ocrs) {
        LogControl.push('setPrimaryContact',CLASSNAME);
        System.debug('Entered setPrimaryContact in ' + CLASSNAME);

        Set<Id> oppIds = new Set<Id>();
       // Map<Id,Id> mapOppIdsToContactsOld = new Map<Id,Id>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
        for (OpportunityContactRole ocr : ocrs) {
            oppIds.add(ocr.OpportunityId);
        }
        
        List<Opportunity> opportunities = 
            new List<Opportunity>([SELECT Id, Primary_Contact__c, Email__c,
                                          (SELECT ContactId,Contact.Email, OpportunityId, IsPrimary 
                                           FROM OpportunityContactRoles
                                           WHERE IsPrimary = true 
                                           LIMIT 1)
                                   FROM Opportunity
                                   WHERE Id IN :oppIds]);
        
        // get original values of Primary_Contact__c for all opps
       /** for (Opportunity o : opportunities) {
            mapOppIdsToContactsOld.put(o.Id,o.Primary_Contact__c);
        } **/
        
        for (Opportunity o : opportunities) {
            Id conId = null;
            String primaryContactEmail=null;
            
            for (OpportunityContactRole ocr : o.OpportunityContactRoles) {
            	conId = ocr.ContactId;
                primaryContactEmail=ocr.Contact.Email;
            }
            
 			 Opportunity uOpp = new Opportunity();
			 uOpp.Id = o.Id;
			 uOpp.Primary_Contact__c = conId;
			 uOpp.Email__c=primaryContactEmail;
 			 opportunitiesToUpdate.add(uOpp);
            
        }
		
        try {
            if (!opportunitiesToUpdate.isEmpty()) {
                Database.update(opportunitiesToUpdate, false);
            } 
        } catch (Exception e) {
            System.debug('Exception updating Opportunity from Opportunity Contact Roles ' + e);
            LogControl.debugException(e);
        } finally {
            LogControl.pop();
        }
    }
}