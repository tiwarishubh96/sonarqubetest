public class SageApiAddCommUserActivityStepValidate extends SageApiActivityStepActionBase {
    public override void process(SageApiActivityStep step, List<SageApiActivity__c> activities, string sessionId) {
        Map<Id, Account> accounts = SageApiAddCommUserActivityUtils.getValidRequestAccounts(activities);
        SageApiActivityUtils.debug('accounts: '+accounts);
        Map<Id, Contact> contacts = SageApiAddCommUserActivityUtils.getValidRequestContacts(activities);
        SageApiActivityUtils.debug('contacts: '+contacts);
        Map<string, SageUserIdentityProvider__c> identities = SageApiAddCommUserActivityUtils.getValidRequestIdentities(activities);
        SageApiActivityUtils.debug('identities: '+identities);
        List<Community_Role__c> roles = SageApiAddCommUserActivityUtils.getValidRequestCommunityRoles();
        SageApiActivityUtils.debug('roles: '+roles);
        Map<ID, Community_Membership__c> contactCommunitiesMap = null;
        if (identities != null && identities.size() > 0) {
            List<ID> ids = new List<ID>();
            for (SageUserIdentityProvider__c identity : identities.values())
                if (identity != null && String.isNotBlank(identity.User__r.ContactId))
                    ids.add(identity.User__r.ContactId);
            SageApiActivityUtils.debug('ids: '+ids);
            if (ids.size() > 0)
                contactCommunitiesMap = SageApiAddCommUserActivityUtils.getValidRequestContactUserCommunity(ids);
            SageApiActivityUtils.debug('contactCommunitiesMap: '+contactCommunitiesMap);
        }

        for(SageApiActivity__c activity : activities) {
            if (SageApiActivityUtils.completedWithSuccess(activity, step.StepID))
                continue;

            SageApiActivityStep runningStep = step.deepClone();
            SageApiAddCommUserActivityUtils.validatePayload(activity, runningStep, accounts, contacts, identities, roles, contactCommunitiesMap);
        }
        SageApiActivityUtils.updateActivities(step, activities);
        system.debug('SageApiAddCommUserActivityStepValidate: '+JSON.serialize(activities));
    }
}