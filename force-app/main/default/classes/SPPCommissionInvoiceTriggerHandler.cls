/**********************************************************************
 Name:  SPPCommissionInvoiceTriggerHandler

======================================================
======================================================
Purpose:    Handler class to contain the logic of 
            SPPCommissionTrigger
History:    Raja, 10/24/2017, Added a formula field 
            'Parent_Account_ID__c'on SPP Commission 
            Invoice so that parent accout can be 
            mapped to user role
            Lu, 10/26/2017, Removed the formula field
            'Parent_Account_ID__c'on SPP Commission 
            Invoice as it's no longer being used
======================================================
======================================================
History                                                            
-------                                                            
VERSION     AUTHOR              DATE                DETAIL                                 FEATURES/CSR/TTP
1.0         Lu                  10/20/2017          Initial Development
***********************************************************************/


public class SPPCommissionInvoiceTriggerHandler {
    
    public static void createCommissionSharing(List<SPP_Commission_Invoice__c> comList)
    {   
        List<SPP_Commission_Invoice__Share> sharesToCreate = new List<SPP_Commission_Invoice__Share>();
        Set<Id> setAccount = new Set<Id>();
        Map<string,Id> mapComAccount = new Map<string,Id>();
        Map<Id,Id> mapAccountRole = new Map<Id,Id>();
        Map<Id,Id> mapUserRoleandGroup = new Map<Id,Id>();
        
        //mapping commission invoice record with partner account id
        for(SPP_Commission_Invoice__c obj : comList)
        { 
            if(obj.Partner_Account__c!= null)
            { 
                setAccount.add(obj.Partner_Account__c);
                
                mapComAccount.put(obj.id,obj.Partner_Account__c);
            }
        }
        //Fetching the referring partner account from order object
        List<SPP_RR_Order__c> orderList = [SELECT Opportunity__r.Referring_Partner_Account__c,Opportunity__r.Referring_Partner_Account__r.ParentId,
                                           SPP_AP_Commission__c  FROM SPP_RR_Order__c 
                                          WHERE Opportunity__r.Referring_Partner_Account__r.ParentId IN: setAccount and SPP_AP_Commission__c in : mapComAccount.keyset()];

        Map<string,List<Id>> mapComReferringAccount = new Map<string,List<Id>>();
        
        //paring commission id with List of referring account ids
        for(SPP_RR_Order__c order:orderList)
        {       
            
            setAccount.add(order.Opportunity__r.Referring_Partner_Account__c);
            
            if(mapComReferringAccount.containskey(order.SPP_AP_Commission__c))
            {
                List<Id> tempcommList=mapComReferringAccount.get(order.SPP_AP_Commission__c);
                tempcommList.add(order.Opportunity__r.Referring_Partner_Account__c);
                mapComReferringAccount.remove(order.SPP_AP_Commission__c);
                mapComReferringAccount.put(order.SPP_AP_Commission__c,tempcommList);
            }
            else
            {
                List<Id> lstTempComm = new List<Id>();
                lstTempComm.add(order.Opportunity__r.Referring_Partner_Account__c);
                mapComReferringAccount.put(order.SPP_AP_Commission__c,lstTempComm);
            }
        }


        system.debug('>>>>'+mapComReferringAccount);
       
        SPPUtils.mapList ml = SPPUtils.getMapAccountRole(setAccount);
        
        mapAccountRole = ml.mapAccountRole;
        
        mapUserRoleandGroup = ml.mapUserRoleandGroup;

        for(Id comId : mapComAccount.keyset())//Creating Sharing Rule for Partner Account
        {
            //Get Group Id based on UserRole Id
            String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapComAccount.get(comId)));
            system.debug('strgroupId '+strgroupId);
            //Creating SPP Commission Share record
            SPP_Commission_Invoice__Share cs = new SPP_Commission_Invoice__Share();
            cs.AccessLevel = 'Read';
            cs.UserOrGroupId =  strgroupId;
            cs.parentId= comId;
            cs.RowCause = Schema.SPP_Commission_Invoice__Share.RowCause.Access_to_all_Contact_under_Same_Partner__c;
            
            sharesToCreate.add(cs);
        }
       
        for(Id comId : mapComReferringAccount.keyset())//Creating Sharing Rule for referring account
        {
        
            List<Id> lstIds = mapComReferringAccount.get(comId);
            //Get Group Id based on UserRole Id
            for(Id ids : lstIds)
            {
                String strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(ids));
                system.debug('strgroupId '+strgroupId);
                //Creating SPP Commission Share record
                SPP_Commission_Invoice__Share cs = new SPP_Commission_Invoice__Share();
                cs.AccessLevel = 'Read';
                cs.UserOrGroupId =  strgroupId;
                cs.parentId= comId;
                cs.RowCause = Schema.SPP_Commission_Invoice__Share.RowCause.Access_to_all_Contact_under_Same_Partner__c;
                //adding to the sharing list to insert into Opportunity sharing table
                sharesToCreate.add(cs);
            }
        }
        
        if (!sharesToCreate.isEmpty())
        {
            Database.insert(sharesToCreate,false);//Inserting Sharing List 
        }
        
    }
    
}