public class caseTriggerHandler {
    public static void setCaseProductField(map<id, case> caseMap) {
        List<Case> casesList = new List<Case>(); // Cases to upate later
        Set<Id> caseIds = new Set<Id>(); // To help query EmailMessages

        // Loop through CaseMap to get ID and add to Set
        for (Case c : caseMap.values()) {
            caseIds.add(c.Id);
        }

        // Find emailmessage and update Case if required
        if(!Test.isRunningTest()){
            for (EmailMessage em : [SELECT Id, ParentId, ToAddress, Incoming, CreatedBy.Name FROM EmailMessage WHERE ParentId In :caseIds]) {
                if (em.toAddress.contains('sagepeoplesupport') && em.Incoming) {
                    Case caseToUpdate = caseMap.get(em.ParentId);
                    caseToUpdate.Product__c = 'Sage People';
                    casesList.add(caseToUpdate);
                }
            } // End For Loop
    
            update casesList;
        }
    }


    public void createPartnerCommunitySharingRules(Map<Id, Case> caseMap, List<Case> caseList) {

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

            mapAccountRole.put(usrRole.PortalAccountId, usrRole.Id);
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

    @future
    public static void createCaseShares(Map<Id, Id> mapAccountRole, Map<Id, Id> mapCaseAccount, Map<Id,Id> mapUserRoleAndGroup) {

        List<CaseShare> sharesToCreate = new List<CaseShare>();

        for (Id caseId : mapCaseAccount.keySet()) {

            string strgroupId = mapUserRoleandGroup.get(mapAccountRole.get(mapCaseAccount.get(caseId)));

            CaseShare share = new CaseShare();
            share.CaseAccessLevel = 'Edit';
            share.UserOrGroupId = strgroupId;
            share.CaseId = caseId;

            sharesToCreate.add(share);
        }


        if (!sharesToCreate.isEmpty()) {
            Database.SaveResult[] result = Database.insert(sharesToCreate, false);//Inserting Sharing List
        }


    }
    
    //Raja Patnaik 08/110/2017
    public static void populateCaseContact(list<Case> caseList, list<User> uList)
    {
       
        //Raja Patnaik 08/110/2017
        if(uList!=null && uList.size()>0)
        {
            system.debug('-----uList-----'+uList);
            for(Case objCase : caseList)
            {
                    objCase.ContactId = uList[0].ContactID;
                   
            }
        }

    }
    
}