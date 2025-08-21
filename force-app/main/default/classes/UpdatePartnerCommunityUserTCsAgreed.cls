public class UpdatePartnerCommunityUserTCsAgreed {

    /*
     *Method executed under Partner CommunityLogin flow to mark T&C license agreement 
    */
    @InvocableMethod(label='Update Partner Community User TCs Agreed' description='Updates the Partner Community User record for the supplied Id to set the T&C Agreed and T&C Acknowledges fields.')
    public static List<String> getUserRecord(List<ID> ids) {
        system.debug('****UpdatePartnerCommunityUserTCsAgreed.getUserRecord callout with param @ids:'+ids);
        
        User userToUpdate = [SELECT Id FROM User WHERE Id in :ids LIMIT 1];
    
        userToUpdate.Partner_Community_T_C_Agreed__c = true;
        userToUpdate.Partner_Community_T_C_Agree_Date__c = System.today();
    
        try {
            update userToUpdate;
        } catch(DmlException e) {
            throw new UpdatePartnerCommunityUserTCsAgreedHandlerException('An unexpected error has occurred: ' + e.getMessage());
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        system.debug('****UpdateCommunityUserTCsAgreed.getUserRecord updated user to following state:'+userToUpdate);
        return null;
    }
    
    public class UpdatePartnerCommunityUserTCsAgreedHandlerException extends Exception{}
    
}