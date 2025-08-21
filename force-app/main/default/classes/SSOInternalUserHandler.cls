/**
Created by: zsinay@salesforce.com
Date: 14/01/2016
Last modified Date: 17/02/2016
Description: This class handles the JIT Provisioning using a template contact to copy all company profile fields
and attributes to fill in IDP fields
*/
global class SSOInternalUserHandler implements Auth.SamlJitHandler {
    
    private class JitException extends Exception{}

    private final static integer ZERO       = 0;
    private final static integer MAXCHARS   = 6;
    private final static string  UPDATEUSER = 'update';
    private final static string  INSERTUSER = 'insert';


    /**
        Description: Method implemented from the Auth.SamlJitHandler interface, all paramaters are generated via the Saml sent by the ADFS.
        Most important parameters are attributes which is the AD parameters being sent via SAML and federation Id which is the user's federation Id
    */
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        List<User> protoTypeUserList = [SELECT Id, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, ProfileId, LanguageLocaleKey FROM User WHERE alias = 'tuser' AND FirstName = 'Template' AND LastName = 'User' LIMIT 1];
        User protoTypeUser = new User();
        if(protoTypeUserList.size() >0){
            protoTypeUser = protoTypeUserList[0];
        }
        
        User userToInsert = protoTypeUser.clone(false, true, false, false);

        try{
            createAlias(userToInsert, attributes);
            handleUser(userToInsert, attributes, federationIdentifier, INSERTUSER);
        }catch(Exception e){
            throw new JitException(e.getMessage());
            return null;
        }

        return userToInsert;
    }

    /**
        Description: Method implemented from the Auth.SamlJitHandler interface, all paramaters are generated via the Saml sent by the ADFS.
        Most important parameters are attributes which is the AD parameters being sent via SAML and federation Id which is the user's federation Id as well as userId
    */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        list<User> userList = [SELECT Id, Username, CommunityNickname, Country, FederationIdentifier, External_Id__c
                                FROM User WHERE Id = :userId LIMIT 1];

        User userToUpdate;

        if(userList.size() > 0) {
            userToUpdate  = userList[0];
        }


        handleUser(userToUpdate, attributes, federationIdentifier, UPDATEUSER);

        

        try{
            update userToUpdate;
        }catch(Exception e){
            throw new JitException(e.getMessage());
        }
    }

    // Handles the user creation/update of fields from the AD FS using the attributes that were sent through the SAML
    private void handleUser(User u , Map<String, String> attributes, String federationIdentifier, String insertOrUpdateUser){
        // Add attributes here for new/updated users
        u.FirstName = attributes.get('First Name');
        u.LastName = attributes.get('Last Name');
        u.Email = attributes.get('Email');
        u.Country = attributes.get('Country');
        // u.Street = attributes.get('Street'); removed due to request from Jorge 01/03/2016
        u.Title = attributes.get('Title');
        
        if(insertOrUpdateUser == INSERTUSER){        
            u.Username = attributes.get('Username');
            u.CommunityNickname = attributes.get('Nickname');
        }

        u.FederationIdentifier = federationIdentifier;
        u.External_Id__c = federationIdentifier;
    }

    // Creates the alias for the created user, from the first letter of the first name up to 7 letters from the last name, 8 letters in total
    private void createAlias(User u, Map<String, String> attributes){
        string alias = '';
        string firstName = attributes.get('First Name');
        string lastName = attributes.get('Last Name');

        if(firstName.length() > ZERO){
            alias += firstName.substring(ZERO,1);
        }
        if(lastName.length() > ZERO){
            if(lastName.length() >= 7){
                alias += lastName.substring(ZERO,MAXCHARS);
        }
            else{
                alias += lastName.substring(ZERO,lastName.length()-1);
            }
        }


        u.Alias = alias;
    }


}