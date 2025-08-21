/**
 * @description  Server side action for Sync Salesforce contacts name, phone and email to Zuora Billto and Soldto Contacts
 * @author Bob Lin
 * @date July 2019
 */
global with sharing class ZuoraSyncContactDetails {
    
    @AuraEnabled(cacheable=true)
    webService static string checkZuoraSync(string recId){
		try{
      		LogControl.push('checkZuoraSync', 'ZuoraSyncContactDetails'); 
            
            List<PermissionSetAssignment> permission = [select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where 
                Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'Sync_to_Zuora_Account_and_Contact' LIMIT 1];
            if(permission == null || permission.size() == 0){
                return 'The current user does not have the proper permission set to sync contact details to Zuora.';
            }
            
      		Contact c = [select accountid, Sync_to_Zuora_Bill_to__c,Sync_to_Zuora_Sold_to__c, Phone, FirstName, LastName, Email from contact where id = :recId limit 1];

            if(c.Sync_to_Zuora_Bill_to__c == false && c.Sync_to_Zuora_Sold_to__c == false){
                return 'This contact is not set to be sync to neither Bill to nor Sold to contact. Please update this contact.';
            }
            Account accountinfo = [SELECT Id,( SELECT Id,Zuora__BillToId__c, Zuora__SoldToId__c FROM R00N40000001kyLcEAI ) FROM Account WHERE Id = :c.accountid];
            string Zuora_Billto_id;
            string Zuora_Soldto_id;

            for (Zuora__CustomerAccount__c zuoraAccount : accountinfo.R00N40000001kyLcEAI){
				Zuora_Billto_id = zuoraAccount.Zuora__BillToId__c;  
                Zuora_Soldto_id = zuoraAccount.Zuora__SoldToId__c;               
            }

            if(Zuora_Billto_id == null || Zuora_Soldto_id == null){
                return 'This contact\'s account does not have the correct billing account info stored in salesforce. Please ensure that the account of this contact is up to date with Zuora.';
            }

      		updateContactinZuora(c.Sync_to_Zuora_Bill_to__c, c.Sync_to_Zuora_Sold_to__c, Zuora_Billto_id, Zuora_Soldto_id, c.FirstName,c.LastName, c.Phone, c.Email);
      		LogControl.pop();        
      		return 'success';
		} catch (Exception e) { 
        	LogControl.debugException(e); 
			LogControl.pop(); 
            return 'Something has gone wrong. Please contact your System Administrator.';
        }
     }
   
    
   @Future(Callout=true)
   public static void updateContactinZuora(boolean Billto, boolean Soldto, string Zuora_Billto_id, string Zuora_Soldto_id, String FirstName, String LastName, String phone, String email){
       try {
         LogControl.push('updateContactinZuora', 'ZuoraSyncContactDetails'); 
         
         Zuora.zApi zApiInstance = ZuoraUpdateUtility.loginToZuora('ZuoraUpdatePhoneandorBillingAddressTriggerHandler');
           if(Billto == true){
               ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Contact', new Map<String,Object> {'Id'=>Zuora_Billto_id,'WorkPhone'=>Phone,'FirstName'=>FirstName,'LastName'=>LastName, 'WorkEmail'=>email});
           }
           if(Soldto == true){
               ZuoraUpdateUtility.updateZuoraObject(zApiInstance,'Contact', new Map<String,Object> {'Id'=>Zuora_Soldto_id,'WorkPhone'=>Phone,'FirstName'=>FirstName,'LastName'=>LastName, 'WorkEmail'=>email});
           }           
                
        } catch (Exception e) { 
            LogControl.debugException(e); 
        } finally { 
            LogControl.pop(); 
        }
 	} 
    
}