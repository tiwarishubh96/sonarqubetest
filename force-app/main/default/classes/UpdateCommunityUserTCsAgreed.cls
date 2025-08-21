public class UpdateCommunityUserTCsAgreed {
    /*
     *Method executed under CommunityLogin flow to mark T&C license agreement 
    */
    @InvocableMethod(label='Update Community User TCs Agreed' description='Updates the Community User record for the supplied Id to set the T&C Agreed and T&C Acknowledges fields.')
    public static List<String> getUserRecord(List<ID> ids) {
        system.debug('****UpdateCommunityUserTCsAgreed.getUserRecord callout with param @ids:'+ids);
        
        User userToUpdate = [SELECT Id FROM User WHERE Id in :ids LIMIT 1];
    
        userToUpdate.T_C_Agreed__c = true;
        userToUpdate.T_C_Acknowledged__c = System.today();
    
        try {
            update userToUpdate;
        } catch(DmlException e) {
            throw new UpdateCommunityUserTCsAgreedHandlerException('An unexpected error has occurred: ' + e.getMessage());
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        system.debug('****UpdateCommunityUserTCsAgreed.getUserRecord updated user to following state:'+userToUpdate);
        return null;
    }
    
    public class UpdateCommunityUserTCsAgreedHandlerException extends Exception{}
}