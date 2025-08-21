/**
 * @description Handles Account DML Events.
 *
 * @author    Veni Korapaty <korapaty.veni@sage.com>
 */
public with sharing class ZuoraUpdateVatNumberTriggerHandler
{
    ////////////
    // Events //
    ////////////

    static public void afterUpdate()
    {
        getVatUpdatedAccountIDs();
    }

    ///////////////
    // Processes //
    ///////////////

    /**
     * @description When vat number updated on the Accounts, should also be updated on the Zuora
     * @author      Veni Korapaty 
     * @date        2017-01-12
     */
    static public void getVatUpdatedAccountIDs()
    {
        Set<ID> vatChangedAccountIds = new Set<ID>();
        
        for( Integer i = 0; i < Trigger.new.size(); i++)
        {
            Account newZAcc = (Account)Trigger.new[i];
            Account oldZAcc = (Account)Trigger.old[i];

            if( newZAcc.VAT_Number__c!= oldZAcc.VAT_Number__c )
           
            {
                vatChangedAccountIds.add(newZAcc.id );
            }
        }
   
        // added empty check - Yong Kan@2017.03.09
        if(vatChangedAccountIds.size()>0) updateVatNumberInZuora(vatChangedAccountIds);
    }
    
   @future(Callout=true)
    static public void updateVatNumberInZuora( Set<ID> vatAccIds)
    {
   
    List<Account> vatUpdatedAccountIds = new List<Account>([SELECT Id,VAT_Number__c,TaxExemptStatus__c,(select id,Zuora__Zuora_Id__c from R00N40000001kyLcEAI) FROM Account WHERE id IN :vatAccIds] );
    Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraUpdateVatNumberTriggerHandler');
    Zuora.zObject zObject;
    if( !Test.isRunningTest()) zObject = new Zuora.zObject('Account'); 
      for (Account acc : vatUpdatedAccountIds )
     	{
        for (Zuora__CustomerAccount__c zAcc : acc.R00N40000001kyLcEAI)
                {
                system.debug('zAcc.Zuora__Zuora_Id__c,'+zAcc.Zuora__Zuora_Id__c);
                    system.debug('acc.VAT_Number__c '+acc.VAT_Number__c );
                    system.debug('Test.isRunningTest() '+ Test.isRunningTest() );
                    
                if(String.isBlank(acc.VAT_Number__c ) && !Test.isRunningTest())
                	{
                     
       				 zObject.setValue('fieldsToNull', acc.VAT_Number__c); 
                	 ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zAcc.Zuora__Zuora_Id__c,'VAT_Number__c'=>zObject,'TaxExemptCertificateID'=>zObject, 'TaxExemptStatus'=>acc.TaxExemptStatus__c});
                
                	}
               	 else
                	{
    				 ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Account', new Map<String,Object> {'Id'=>zAcc.Zuora__Zuora_Id__c,'VAT_Number__c'=>acc.VAT_Number__c,'TaxExemptCertificateID'=>acc.VAT_Number__c, 'TaxExemptStatus'=>acc.TaxExemptStatus__c});
                	} 
                }
                }
     }
    }