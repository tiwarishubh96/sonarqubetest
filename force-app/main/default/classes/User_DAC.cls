/**
 * @author Bhushan Sukumar (bhushan.sukumar@sage.com)
 * @date    27-Jul-2018
 * @description     DAC class for user object and permission sets
 *
 */

public class User_DAC {

    /**
     * @description retrieving user details based on the given user id.
     * Note: This query is a single-row assignment query so the query should always return a record to avoid
     * query exception.
     *
     * @param userId
     *
     * @return  matching user record with related account details
     */
    public static User getPartnerUser(Id userId) {

        return [
                SELECT Id,
                        Name,
                        AccountId,
                        Contact.Account.Partner_ISV__c,
                        Contact.Account.Partner_Alliance__c,
                        Contact.Account.Partner_Accountant__c,
                        Contact.Account.Partner_Implementation__c,
                        Contact.Account.Accountant_Partner_Tier__c,
                        Contact.Account.SI_Partner_Tier__c,
                        Contact.Account.Reseller_Partner_Tier__c,
                        Contact.Account.Partner_Reseller__c,
                        ContactId,
                        Contact.Account.Locale__r.Name
                FROM User
                WHERE Id = :userId
        ];
    }

    public static Group getIntacctQueue() {
        return [
                SELECT Id,
                        Name,
                        DeveloperName
                FROM Group
                WHERE Type = 'Queue'
                AND DeveloperName = 'Sage_Intacct'
                LIMIT 1
        ];
    }
}