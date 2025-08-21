/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          08/03/2017
    Company:       
    Description:   Partner terms and condition trigger 
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  


  ------------------------------------------------------------*/
trigger SPPPartnerTnCTrigger on Partner_Terms_and_Condition__c (before update) 
{
   if(Trigger.isBefore && Trigger.isUpdate)
   {
        
        for(Partner_Terms_and_Condition__c ptcObj : Trigger.new)
        {
          
        //  SPPUtils.createpartnerRoleSharingDocusignStatus(Trigger.new);
        
        }
        
   }

}