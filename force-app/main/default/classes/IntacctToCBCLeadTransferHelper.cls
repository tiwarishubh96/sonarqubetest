/*	
 *  Author : Rani Thumma
 * 	Company : Docmation
 * 	Description : Class is devleoped to handle Lead transfer from Intacct to NA CBC(Sage) and vice versa
 * 
 */
public class IntacctToCBCLeadTransferHelper {
    
    public void lockSageLead(List<Lead> leads, Map<Id, Lead> newLeadsMap){
        Application_Control__c ac = Application_Control__c.getInstance(userinfo.getuserid());
        Map<Id,Group> grOwners ;
        
        if(RecursiveTriggerHandler.isFirstTime){ 
            //Custom metadata to save some default values
            Intacct_to_NA_CBC_Lead_Transfer__mdt  intCBCDetails = [SELECT ID, Outbound_Queue__c, User_Name__c FROM Intacct_to_NA_CBC_Lead_Transfer__mdt 
                                                                   WHERE developerName = 'Lead_Transfer' LIMIT 1];
            RecursiveTriggerHandler.isFirstTime = false;
        	
            List<CampaignMember> campMembers = new List<CampaignMember>();
            Set<String> ownerIds = new Set<String>();
            Set<String> leadIds = new Set<String>();
            Map<String, List<CampaignMember>> leadToCampMemMap = new Map<String, List<CampaignMember>>();
            for(Lead l :leads){
                //collect all Lead IDs which are created in Sage 
                if(l.Intacct_Lead_Id__c == null){
                    leadIds.add(l.Id);
                }
                //Collect all OwnerIDs where Owner is a Queue
                if(l.OwnerId != null && String.valueOf(l.OwnerId).startsWith('00G')){
                    ownerIds.add(l.OwnerId);
                }
            }
            System.debug('leadIds >>> '+leadIds);
            System.debug('ownerIds >>> '+ownerIds);
            if(leadIds.size() > 0){
                campMembers = [SELECT Id, LeadID, CampaignID, Campaign.Name FROM CampaignMember 
                               WHERE LeadID IN :leadIds LIMIT 40000];
            }
            if(campMembers.size() > 0){
                for(CampaignMember cm :campMembers){
                    if(leadToCampMemMap.containsKey(cm.LeadId)){
                        leadToCampMemMap.get(cm.LeadId).add(cm);
                    } else {
                        leadToCampMemMap.put(cm.LeadId, new List<CampaignMember>{cm});
                    }
            	}
            }
            if(ownerIds.size() > 0){
                grOwners = new Map<Id, Group>([SELECT Id, Name, developerName FROM Group WHERE Id IN :ownerIds AND DeveloperName = :intCBCDetails.Outbound_Queue__c AND type = 'Queue']);
            }
            System.debug('grOwners>>. '+grOwners);
            for(Lead l :leads){
                Boolean isIntacctOwner = grOwners!=null?grOwners.containsKey(l.OwnerId):false;
                if(ac.Run_Validation_Rules__c && l.Lock_Record__c == true){
                	l.addError('Lead can not be updated');
        		}
                // c1:Source Lead - getting pushed to Target
                else if((l.Product__c == 'Sage Intacct' || l.Product__c == 'Non Product Line Specific') && isIntacctOwner && 
                        userinfo.getName()!= (intCBCDetails!=null?intCBCDetails.User_Name__c:null)){
                    l.Intacct_Lead_Transfer_Status__c = 'To be sent';
					l.CurrencyIsoCode = 'USD';
					l.Lock_Record__c = true;
                    l.Status = 'Archived';
                    l.Status_Reason__c = 'Transfer';
                    l.Description = campaignNames(leadToCampMemMap.get(l.Id));
          		}
				//c2:Lead from Target getting pushed back to Source
				//Process/trigger - LeadTriggerHandler Class identifiying the lead as duplicate should(Status Archived AND Status reason to Duplicate (Non Customer)) set  Owner to Intacct Queue
                else if((l.Product__c == 'Sage Intacct' || l.Product__c == 'Non Product Line Specific') && 
                        isIntacctOwner && userinfo.getName()!=(intCBCDetails!=null?intCBCDetails.User_Name__c:null) && 
                      (l.Status == 'Archived' && (l.Status_Reason__c == 'Transfer' || l.Status_Reason__c == 'Duplicate (Non Customer)'))){
                        l.Intacct_Lead_Transfer_Status__c = 'To be sent';
            			l.CurrencyIsoCode = 'USD';
                		l.Lock_Record__c = true;
            	}
            }
        }
    }
    
    public String campaignNames(List<CampaignMember> campMems){
        String campaigNames = null;
        if(campMems != null){
            campaigNames = 'Campaign Name : ';
            for(CampaignMember cm :campMems){
                campaigNames+=cm.Campaign.Name+', ';
            }
        }
        if (campaigNames != null && campaigNames.endsWith(', ')) {
    		campaigNames = campaigNames.substring(0, campaigNames.length()-2);
		}
        return campaigNames;
    }
}