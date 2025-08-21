global class CaseSharingRulesBatch  implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){

       String query = 'Select Id, Account.Name, ContactId from Case where Account.RecordType.Name = \'Partner Account\'';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){

        Map<Id, Case> caseMap = new Map<Id, Case>();
        List<Case> cases = (List<Case>)scope;
        for(Case c : cases) {
            caseMap.put(c.Id, c);
        }
        createPartnerCommunitySharingRules(caseMap, cases);


    }

    global void finish(Database.BatchableContext BC){
    }

    public static void createPartnerCommunitySharingRules(Map<Id, Case> caseMap, List<Case> caseList) {

        List<CaseShare> sharesToCreate = new List<CaseShare>();
        Set<Id> caseAccounts = new Set<Id>();
        Map<Id, Id> mapCaseAccount = new Map<Id, Id>();
        Map<Id, Id> mapAccountRole = new Map<Id, Id>();


        //Fetching all the cases
        Set<Id> contactIds = new Set<Id>();
        for (Case c : CaseList) {
            contactIds.add(c.ContactId);
        }

        Set<Id> filteredContactIds = new Set<Id>();
        List<User> users = [Select ContactId from User where UserType = 'PowerPartner' and ContactId in :contactIds];
        for (User u : users) {
            filteredContactIds.add(u.ContactId);
        }
        List<Case> cases = [Select Id, AccountId from Case where ContactId in :filteredContactIds and Id in :caseMap.keyset()];

        for (Case c : cases) {
           mapCaseAccount.put(c.Id, c.AccountId);//Map of Case Id and Account Id
            caseAccounts.add(c.AccountId);

        }

        //Map of Partner User Role details it will always 1-1 based on community role setting
        Map<Id, UserRole> mapPartnerRole = new Map<Id, UserRole>([
                SELECT RollupDescription, Id, Name, ParentRoleId, DeveloperName, PortalAccountId,
                        PortalType, PortalRole,PortalAccountOwnerId
                FROM UserRole
                where PortalAccountId IN :caseAccounts
        ]);

        for (UserRole usrRole : mapPartnerRole.values()) {

            mapAccountRole.put(usrRole.PortalAccountId, usrRole.Id);//Map of Account ID and User Role Id
        }


        Map<Id, Id> mapUserRoleandGroup = new Map<Id, Id>();

        //Fetch group Id based on User Role
        List<Group> lstGroup = [Select RelatedId, Id, Type FROM Group where RelatedId IN :mapPartnerRole.keyset()];

        for (Group grp : lstGroup) {
            if (grp.Type == 'RoleAndSubordinates') {
                 mapUserRoleandGroup.put(grp.RelatedId, grp.Id);
            }
        }


        createCaseShares(mapAccountRole, mapCaseAccount, mapUserRoleandGroup);
    }

    public static void createCaseShares(Map<Id, Id> mapAccountRole, Map<Id, Id> mapCaseAccount, Map<Id,Id> mapUserRoleAndGroup) {

        List<CaseShare> sharesToCreate = new List<CaseShare>();

        for (Id caseId : mapCaseAccount.keySet()) {

            string strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapCaseAccount.get(caseId)));

            CaseShare share = new CaseShare();
            share.CaseAccessLevel = 'Edit';
            share.UserOrGroupId = strgroupId;
            share.CaseId = caseId;

            //adding to the sharing list to insert into lead sharing table
            sharesToCreate.add(share);
        }


        if (!sharesToCreate.isEmpty()) {
            //insert sharesToCreate;
            Database.SaveResult[] result = Database.insert(sharesToCreate, false);//Inserting Sharing List

        }


    }

}