/**
 * @author Veni Korapaty (veni.Korapaty@sage.com)
 * @date    26-March-2019
 * @description     DAC class for Contact object and permission sets
 *
 */

public class Contact_DAC {

    /**
     * @description retrieving contact details based on the given Zift Person id.
     * Note: This query is a single-row assignment query so the query should always return a record to avoid
     * query exception.
     *
     * @param userId
     *
     * @return  matching user record with related account details
     */
    public static List<Contact> getContactDetails(set<String>  ziftPersonID) {

        return [
                SELECT Id,
                        Name,
                        AccountId,
            			Relayware_ID__c 
     
                FROM Contact
                WHERE Relayware_ID__c  = :ziftPersonID
        ];
    }
    
   

    
}