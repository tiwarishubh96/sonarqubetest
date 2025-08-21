/*-------------------------------------------------------------
    Author:         Raja Patnaik
    Date :          05/15/2017
    Company:       
    Description:   SPPInvoiceHandler to create Invoice 
    Inputs:        None
    History
    <Date>            <Authors Name>                <Brief Description of Change>
  
  ------------------------------------------------------------*/
trigger SPPInvoiceHandler on Zuora__ZInvoice__c (after insert) 
{ 
    set<string> setZuoraInvID = new set<string>();
  
    if(Trigger.isAfter && Trigger.isInsert) 
        {
           for(Zuora__ZInvoice__c objZuoraInvID:Trigger.new)
           {
             setZuoraInvID.add(objZuoraInvID.Id);
           }
           
           SPPZuoraInvoiceHelperClass.CreateSPPInvoice(setZuoraInvID);
        }   
      
    
}