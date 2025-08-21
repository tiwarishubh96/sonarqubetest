public without sharing class Case_Helper {

    static string CLASSNAME = 'Case_Helper';

        //set partner sharing rules
        
        public static void createPartnerCommunitySharingRules(Map<Id, Case> caseMap, List<Case> caseList) {

        List<CaseShare> sharesToCreate = new List<CaseShare>();
        Set<Id> caseAccounts = new Set<Id>();
        Map<Id, Id> mapCaseAccount = new Map<Id, Id>();
        Map<Id, Id> mapAccountRole = new Map<Id, Id>();


        //Fetching all the cases
        Set<Id> contactIds = new Set<Id>();
        if(!caseList.isempty()){
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
    public static void populateCaseContact(list<Case> caseList, list<User> uList){
       
        //Raja Patnaik 08/110/2017
        if(uList!=null && uList.size()>0){
            system.debug('-----uList-----'+uList);
            for(Case objCase : caseList){
                    objCase.ContactId = uList[0].ContactID;
                   
            }
        }

    }
    
    // If there are any open tasks before closing a case first close the task and then close tha case

     public Static void PartnerHandler(List<Case> caseList) {
        //CaseWaitingForPartnerHandler obj = new CaseWaitingForPartnerHandler();

        List<User> pcommUser = [SELECT Name, AccountId,ContactId FROM User WHERE Id = :UserInfo.getUserId() and ProfileId =: Label.Sage_Partner_Community_Login_User];
        /*if(!caseList.isempty()){
            obj.forInsert(caseList);
        }*/
        if(!pcommUser.isEmpty() ||Test.isRunningTest()) 
        {
            populateCaseContact(caseList,pcommUser);
        }

     }
    public Static void RnRSurvey(List<Case> caseList, Map<Id, Case> oldItems) {//
          if(RecursiveTriggerHandler.isFirstTime){
            RecursiveTriggerHandler.isFirstTime = false;
            List<Id> caseId = new List<Id>();
            List<string> lstCaseOrigins = RnRSurveyCallOutHelper.getCaseOriginFromMD(); 
            Set<string>  setCaseOrigins =  new Set<String>(lstCaseOrigins); 
           /* List<string> lstCaseProducts = RnRSurveyCallOutHelper.getProductListFromMD(); 
              
            Set<string>  setCaseProducts =  new Set<String>(lstCaseProducts); 

              system.debug('setCaseProducts in Trigger   '+setCaseProducts);*/
            system.debug('setCaseOrigins in Trigger   '+setCaseOrigins);
            String caseOwnerId = '';
            //String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].Name;
                  //if(!caseList.isempty() && (userProfileName != 'System Administrator' || Test.isRunningTest())){
                   if(!caseList.isempty() || Test.isRunningTest()){
                    for(Case c: caseList){
                        if(setCaseOrigins.contains(c.Origin) && c.IsClosed == true)
                        {  
                            if(string.valueOf(c.OwnerId).startsWith('005')){
                                system.debug('checkBefore');
                                system.debug('OwnerId++'+c.OwnerId);
                               
                                system.debug('Product, Origin and Close check');
                                caseId.add(c.id);
                               
                            }
                        }
                    }
                
            }
            if(!caseId.isempty())
            {
                system.debug('if case Id List is not empty');
                RnRSurveyCallOutHelper.sendSurveyRnR(caseId, oldItems);
            }
        }
    }
    public Static void caseclosetask(List<Case> caselist, Map<ID, Case> oldCaseMap){
    system.debug('Entered Close Case check');
        Map<Id, Task> taskMap = new Map<Id, Task>();
            List<task> tlist = new list<task>();
            if(tlist.ISEMPTY()){
                tlist = [SELECT Id, WhatId FROM Task WHERE IsClosed=false AND WhatId IN :trigger.newMap.keySet()];
                system.debug('taskcatched'+ tlist);
            }
            if(!tlist.ISEMPTY()){
                for(Task t : tlist)
                {
                    taskMap.put(t.WhatId, t);    
                }
            }
            if(!caseList.isempty()){
                for(Case c : caselist)
                { 
                    if(taskMap.containsKey(c.Id) && c.IsClosed && c.IsClosed != oldCaseMap.get(c.Id).IsClosed && (System.label.Recordtypeglobalcase == c.RecordTypeId || system.Label.Recordtypecomplaint == c.RecordTypeId ) ) {
                    
                       c.addError('Close the open tasks before closing a case');
                    }
                }
            }
    }
     /************************************************************************
  * @description: Method to update the RightAnswers attachment to the case related List
  * @author: Ravi Yalamati
  *************************************************************************/
    public static void updateCaseRetriveSolution(List<Case> caseList) {
        // we only want to fire this trigger if this is a single case transaction. If this is a bulk transaction, we can skip this trigger
        // also - this is dependent on the assumption that the Analyst will retrieve solutions into and save the case 1 new case at a time.   
        if( caseList.size() == 1){
            // get the case
            Case c = caseList.get(0);
            // find any solutions that were created by this user and are not currently attached to a case
            for (List<RightAnswersAttached__c> sols : [select Id, CaseSubject__c, CaseNumber__c from RightAnswersAttached__c where OwnerId = :UserInfo.getUserId() and CaseNumber__c = null]) {
                if (!sols.isEmpty()) {
                    // attach all of the solutions to the case
                    for (RightAnswersAttached__c raa : sols) {
                        if (raa.CaseSubject__c == c.Subject)
                        {    
                            raa.CaseNumber__c = c.Id;
                            raa.Date_Time__c = DateTime.now();
                        }
                    }
                    
                    update sols;
                } 
            } 
            
        } 
    } 
}