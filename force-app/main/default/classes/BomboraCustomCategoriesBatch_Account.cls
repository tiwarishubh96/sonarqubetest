/**
 * @author Bob Lin
 * @description batch apex to calculate bombora categories count and average for Account
 * @date    07-04-2020
 */

global class BomboraCustomCategoriesBatch_Account implements Database.Batchable<sobject>, Database.Stateful {

    global final Datetime dateLimit;
	global string query;
        
    global BomboraCustomCategoriesBatch_Account(String query, Datetime dateLimit) {
        this.query = query;
        this.dateLimit = dateLimit;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('Start query: ' + this.query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accounts) {
        try {
            if (!accounts.isEmpty()) {
                system.debug('in batch class');
                
                //accountToBomboraSurges is a map with Account id as the key and list of bombora surges as value
                Map<id, List<bombora_app__BomboraCustomObject__c>> accountToBomboraSurges = new Map<id, List<bombora_app__BomboraCustomObject__c>>(); 
                
                //contains lead ids of the batch
                Set<id> accountIds = new Set<id>();
                for(Account account:accounts){
                    accountIds.add(account.id);
                }

                for(bombora_app__BomboraCustomObject__c surge : [
                                                    SELECT
                                                        Id, Financials_Accounting_ERP_Checkbox__c,  People_HR_Checkbox__c, Accountants_Checkbox__c,
                                                        bombora_app__CompositeScore__c, bombora_app__Account__r.id
                                                        //bombora_app__inactive__c
                                                    FROM bombora_app__BomboraCustomObject__c
                                                    WHERE bombora_app__Account__r.id in :accountIds 
                                                    AND (Financials_Accounting_ERP_Checkbox__c = true OR People_HR_Checkbox__c = true OR Accountants_Checkbox__c = true) 
                                                    AND bombora_app__inactive__c = False                                                 
                ]){
                    if(accountToBomboraSurges.containsKey(surge.bombora_app__Account__r.id)){
                        accountToBomboraSurges.get(surge.bombora_app__Account__r.id).add(surge);
                    }else{
                        List<bombora_app__BomboraCustomObject__c> newSurgeList = new List<bombora_app__BomboraCustomObject__c>();
                        newSurgeList.add(surge);
                        accountToBomboraSurges.put(surge.bombora_app__Account__r.id, newSurgeList);
                    }
                }

                List<Account> accountsToBeUpdated = new List<Account>();
                for(Account account:accounts){
                    if(accountToBomboraSurges.containsKey(account.id)){
                        Integer financialCount = 0;
                        double financialTotal = 0;
                        Integer hrCount = 0;
                        double hrTotal = 0;
                        Integer accountantsCount = 0;
                        double accountantsTotal = 0;
                        for(bombora_app__BomboraCustomObject__c surge: accountToBomboraSurges.get(account.id)){
                            if(surge.Financials_Accounting_ERP_Checkbox__c == true){
                                financialCount++;
                                financialTotal += surge.bombora_app__CompositeScore__c;
                            } 
                            if (surge.People_HR_Checkbox__c == true){
                                hrCount++;
                                hrTotal += surge.bombora_app__CompositeScore__c;
                            }
                            if (surge.Accountants_Checkbox__c == true){
                                accountantsCount++;
                                accountantsTotal += surge.bombora_app__CompositeScore__c;
                            }
                        }
                        if(financialCount > 0){
                            account.Bombora_Financial_Accounting_ERP_Count__c = financialCount;
                            account.Bombora_Financial_Accounting_ERP_Average__c = financialTotal/financialCount;                            
                        }
                        if(hrCount > 0){
                            account.Bombora_People_HR_Count__c = hrCount;
                            account.Bombora_People_HR_Average__c = hrTotal/hrCount;                            
                        }
                        if(accountantsCount > 0){
                            account.Bombora_Accountants_Count__c = accountantsCount;
                            account.Bombora_Accountants_Average__c = accountantsTotal/accountantsCount;                            
                        }


                       	accountsToBeUpdated.add(account);                        
                    }
                }
                system.debug('accountsToBeUpdated is '+accountsToBeUpdated);
                if (accountsToBeUpdated != null && !accountsToBeUpdated.isEmpty()) {
                     try {
                         system.debug('trying to update leads now');
                         LogControl.push('Execute', 'BomboraCustomCategoriesBatch_Account');
                         update accountsToBeUpdated;
                     }
                     catch(DmlException ex){
                         system.debug(ex.getMessage());
            			 system.debug(ex.getStackTraceString());
                         LogControl.debugException(ex);
                     }
                     finally {
                         LogControl.pop();
                     }
                    
                }
                

            }
        } catch (Exception ex) {
            system.debug(ex.getMessage());
            system.debug(ex.getStackTraceString());
            LogControl.debugException(ex);
            LogControl.pop();
        }
    }

    global void finish(Database.BatchableContext bc) {
        
    }
}