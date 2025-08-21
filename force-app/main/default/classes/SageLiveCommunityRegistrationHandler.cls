// This Registration Handler class demonstrates social sign on using Salesforce as the Auth Provider
// It is based on the example class provided as part of the following article and as such is not 
// intended to be used for production purposes:
// https://developer.salesforce.com/page/Salesforce_as_an_Identity_Provider_for_Customer_Portal
//
// As per the terms of use in the example class, the following copyright notice, list of conditions 
// and disclaimer are included from the example class:
/**
 * Copyright (c) 2012, Stephen Willcock
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

global with sharing class SageLiveCommunityRegistrationHandler implements Auth.RegistrationHandler
{
    
    //final static String SageCommunityProflieName = 'Sage: CBC Customer Community User';
    
    /**
     Returns a User object using the specified portal ID and user information from the third party, 
     such as the username and email address. The User object corresponds to the third party’s user 
     information and may be a new user that hasn’t been inserted in the database or may 
     represent an existing user record in the database.
    */  
    global User createUser(Id portalId, Auth.UserData data)
    {
        system.debug('*** SageLiveCommunityRegistrationHandler createUser called with param @prtalId:'+portalId + ' @data'+JSON.serialize(data));
        system.debug('Org Id:'+UserInfo.getOrganizationId());
        
        Community_SSO_Settings__c communitySetting = Community_SSO_Settings__c.getOrgDefaults();
        String SageCommunityProflieName = trimSetting(communitySetting.SageCommunityProflieName__c);
        
        //check if there is aligned account to license record
        String subsriberOrgId15Digit = data.attributeMap.containsKey('organization_id')? data.attributeMap.get('organization_id').substring(0,15):null;
        String subsriberOrgId18Digit = data.attributeMap.containsKey('organization_id')? data.attributeMap.get('organization_id'):null;
        Id subscriberAccountId = null;
        Boolean shouldThrowAnError = false;
        String errorMsg = '';
        String packageName = License_Management_Settings__c.getOrgDefaults().Package_Name__c;
        List<sfLma__License__c> licenseLst = [Select Id,sfLma__Account__c,sfLma__Contact__c,sfLma__Subscriber_Org_ID__c,sfLma__Account__r.BillingCity,
                                              sfLma__Account__r.BillingCountry,sfLma__Account__r.BillingStreet,sfLma__Account__r.BillingPostalCode,
                                              sfLma__Instance__c,sfLma__Package__r.Name, sfLma__Account__r.BillingState
                                              FROM sfLma__License__c 
                                              WHERE sfLma__Subscriber_Org_ID__c =: subsriberOrgId15Digit 
                                              AND (sfLma__Expiration__c >= TODAY OR sfLma__Expiration__c = 1970-01-01 OR sfLma__Expiration__c =null)
                                              AND sfLma__Package__r.Name =: packageName 
                                              Limit 2];
        
        system.debug('check found licenses:'+licenseLst);
        
        if(licenseLst.isEmpty()){
            //*Scenario 4 - Sage Live Administrator CBC Communities login - New User - License does not exist* 
            //(NB - this scenario is never expected to happen but is included to ensure that if it does the customer experience is managed appropriately)*
            shouldThrowAnError = true;
            errorMsg = Label.SageLiveRegistrationLicenseNotExistError;
            //create case for this error using web-to-case callout
            makeRestCallout(data,null,Label.SageLiveRegistrationNoLicenseBody,Label.SageLiveRegistrationNoLicenseSubject);    
           
            
        }else{
            if(licenseLst.size()>1){
                //check this scenario potentially would never happen
                shouldThrowAnError = true;
                errorMsg = Label.SageLiveRegistrationMultipleLicenseError;
                //create case for this error using web-to-case callout
                makeRestCallout(data,null,Label.SageLiveRegistrationMultipleLicenseCaseBody,Label.SageLiveRegistrationMultipleLicenseCaseSubject);
                
                
            }else if(licenseLst.get(0).sfLma__Account__c == null){
                //*Scenario 3 - Sage Live Administrator CBC Communities login - New User - License exists, but not associated to an Account*
                shouldThrowAnError = true;
                errorMsg = Label.SageLiveRegistrationAccountNotAssignedError.replace('{0}',licenseLst.get(0).id);
                
                //create case for this error using web-to-case callout
                makeRestCallout(data,licenseLst.get(0).sfLma__Instance__c,Label.SageLiveRegistrationCaseAccountBody,Label.SageLiveRegistrationCaseAccountSubject);
                
            }else{
            
                List<Contact> contacts =new List<Contact>();
                //check if contact exists related with Account
                contacts = [SELECT Id FROM Contact WHERE Email = :data.Email AND AccountId =: licenseLst.get(0).sfLma__Account__c  ORDER BY CreatedDate DESC];
                if(contacts.isEmpty() && data.lastName != null && data.lastName != '' && data.firstName != null && data.firstName != '' ){
                    //if empty try to find contact by first and las name
                    contacts = [SELECT Id FROM Contact WHERE FirstName = :data.firstName AND LastName =: data.lastName  AND AccountId =: licenseLst.get(0).sfLma__Account__c  ORDER BY CreatedDate DESC];
                }
                
                Contact contact = contacts.isEmpty() ? null : contacts[0];
                system.debug('contact information: '+contact);
                
                if (contact==null)    
                {
                    
                    /*Scenario 3 - Sage Live Administrator CBC Communities login - New User - Accepted T&Cs - License exists - Contact does not exist*/
                    //need to create new contact
                    Contact customerContact = new Contact();
                    customerContact.LastName = data.lastName;
                    customerContact.FirstName = data.firstName;
                    customerContact.AccountId = licenseLst.get(0).sfLma__Account__c;
                    customerContact.Email = data.email;
                    customerContact.MailingCity = licenseLst.get(0).sfLma__Account__r.BillingCity;
                    customerContact.MailingCountry = licenseLst.get(0).sfLma__Account__r.BillingCountry;
                    customerContact.MailingStreet = licenseLst.get(0).sfLma__Account__r.BillingStreet;
                    customerContact.MailingPostalCode = licenseLst.get(0).sfLma__Account__r.BillingPostalCode;
                    customerContact.MailingState = licenseLst.get(0).sfLma__Account__r.BillingState;
                    
                    insert customerContact;
                    contact = customerContact;
                    
                }else{
                    /*Scenario 2 - Sage Live Administrator CBC Communities login - New User - Accepted T&Cs - License exists - Contact exists*/
                    updateContactSobject(new List<Contact>{contact}, data);
                }
                      
                List<User> users = [SELECT Id,Email,Username,FirstName,LastName,Alias,CommunityNickname,ProfileId,
                                    ContactId,LocaleSidKey,LanguageLocaleKey,TimeZoneSidKey,EmailEncodingKey 
                                    FROM User WHERE ContactId = :contact.Id];
                
                User user = users.isEmpty() ? null : users[0];
                        
                if(user==null)
                {
                    List<Profile> profiles = [SELECT Id FROM Profile WHERE Name =: SageCommunityProflieName];
                    Profile profile = profiles.isEmpty() ? null : profiles[0];
                    
                    String alias = data.email.replace('@', '');
                    if(alias.length()>8){
                        alias = alias.substring(0, 8);
                    }
                    
                    String nickname = data.attributeMap.get('nick_name');
                    system.debug('check nickName:'+nickname);
                    
                    user = new User(
                        Email = data.email,
                        Username = data.attributeMap.get('username'),
                        Alias = alias,
                        CommunityNickname = nickname,
                        ProfileId = profile.Id,
                        ContactId = contact.Id,
                        LastName = data.lastName,
                        FirstName = data.firstName
                    );
                    
                    //check duplicated users
                    Map<String,Boolean> userFieldUniq = checkUserFieldsDuplication(new List<User>{user});
                    if(checkIfUserFiledsDuplicated(userFieldUniq)){
                        for(Integer i=0;i<10;i++){
                            preventDuplicatedFields(user,i,userFieldUniq);
                            //check if user fields are uniqu now
                            userFieldUniq = checkUserFieldsDuplication(new List<User>{user});
                            if(!checkIfUserFiledsDuplicated(userFieldUniq)){
                                //user record is uniq break checking 
                                break;
                            }
                        }
                    }
                            
                }else{
                    // Finds a valid User and Updates the User fields from the Source Org
                    system.debug('User exists - update Name and Email'); 
                    user.LastName = data.lastName;
                    user.FirstName = data.firstName;
                    user.Email = data.email;
                    /*
                    Map<String,Boolean> userFieldUniq = checkUserFieldsDuplication(new List<User>{user});
                    if(checkIfUserFiledsDuplicated(userFieldUniq)){
                        for(Integer i=0;i<10;i++){
                            preventDuplicatedFields(user,i,userFieldUniq);
                            //check if user fields are unique now
                            userFieldUniq = checkUserFieldsDuplication(new List<User>{user});
                            if(!checkIfUserFiledsDuplicated(userFieldUniq)){
                                //user record is uniq break checking 
                                break;
                            }
                        }
                    }
                    */                    
                }
                
                updateUserSobject(user,data);
        
                return user;
            }
        }
        if(shouldThrowAnError){
            throw new CommunityRegistrationHandlerException(errorMsg);
        }
        return null;
    }
    
    /*
     Updates the specified user’s information. This method is called if the user has logged in before with the authorization provider and then logs in again, 
     or if your application is using the Existing User Linking URL. 
     This URL is generated when you define your authentication provider.
    */
    global void updateUser(Id userId, Id portalId, Auth.UserData data)
    {
        system.debug('*** SageLiveCommunityRegistrationHandler updateUser called with param @prtalId:'+portalId + ' @data'+JSON.serialize(data));
        User user = [SELECT Id,Email,FirstName,LastName,ContactId,isActive FROM User WHERE  id =: userId LIMIT 1];
        
        if(!user.IsActive){
            //user is inactive display error message for user
            throw new CommunityRegistrationHandlerException(Label.SageLiveRegistrationAccountDisabled);
        }
        
        updateUserSobject(user,data);
        update user;
        
        List<Contact> contactLst = [SELECT Email,FirstName,LastName,Id FROM Contact where id =: user.ContactId Limit 1];
        if(!contactLst.isEmpty()){
            updateContactSobject(contactLst,data);
        }
        system.debug('*** SageLiveCommunityRegistrationHandler updateUser exit');
    }
    
    /*
     * Method used to change nickname,alias,or userName if is Duplicated
    */
    void preventDuplicatedFields(User user, Integer i,Map<String,Boolean> duplicatedUserFieldValues){
        system.debug('*** SageLiveCommunityRegistrationHandler preventDuplicatedFields called');
        //change user alias only if such user with alias exists
        if(duplicatedUserFieldValues.get('alias')){
            if(user.Alias.length()<8){
            user.Alias = user.Alias.substring(0, user.Alias.length())+i;
            }else{
                user.Alias = user.Alias.substring(0, 7)+i;    
            }
        }
        
        //change user nick name only if such user with nickname exists
        if(duplicatedUserFieldValues.get('nickName')){
            user.CommunityNickname = user.CommunityNickname.substring(0, user.CommunityNickname.length())+i;
        }
        
        //change user user name only if such user with username exists
        if(duplicatedUserFieldValues.get('userName')){
            user.Username = user.Username.substring(0, user.Username.length())+i;
        }
        system.debug('*** SageLiveCommunityRegistrationHandler preventDuplicatedFields exit'+user);
        
        
    }
    
    /*
     Method check if user with the same alias,nickname or username exist
    */
    Boolean checkIfUserFiledsDuplicated(Map<String,Boolean> fieldsDuplication){
        system.debug('*** SageLiveCommunityRegistrationHandler checkIfUserFiledsDuplicated called with param: @fieldsDuplication:'+fieldsDuplication);
        if(fieldsDuplication.get('alias') || fieldsDuplication.get('nickName') || fieldsDuplication.get('userName')){
            return true;
        }
        return false;
    }
    
    Map<String,Boolean> checkUserFieldsDuplication(List<User> uList){
        system.debug('*** SageLiveCommunityRegistrationHandler checkUserFieldsDuplication called with param: @u:'+uList);
        
        Map<String,Boolean> userFieldsUnixnes = new Map<String,Boolean>();
        if(!uList.isEmpty()){
            User u = uList.get(0);
            List<User> duplicatedUsersByAlias = [Select id from User where Alias =: u.Alias Limit 10 ];
            userFieldsUnixnes.put('alias',!duplicatedUsersByAlias.isEmpty());
            List<User> duplicatedUsersByNickName = [Select id from User where CommunityNickname =: u.CommunityNickname Limit 10 ];
            userFieldsUnixnes.put('nickName',!duplicatedUsersByNickName.isEmpty());
            List<User> duplicatedUsersByUserName = [Select id from User where Username =: u.Username Limit 10 ];
            userFieldsUnixnes.put('userName',!duplicatedUsersByUserName.isEmpty());    
        }
        
        system.debug('*** SageLiveCommunityRegistrationHandler checkUserFieldsDuplication returned following map:'+userFieldsUnixnes);
        return userFieldsUnixnes;
    }
    
    
    
    /*
     Method updating existing contact data: Email,FirstName and Last Name
    */
    void updateContactSobject(List<Contact> cList,Auth.UserData data){
        system.debug('*** SageLiveCommunityRegistrationHandler updateContactSobject called with param @c :'+cList);
        if(!cList.isEmpty()){
            Contact c = cList.get(0);
            c.Email =  data.email;
            c.FirstName = data.firstName;
            c.LastName = data.lastName;
            update cList;    
        }
        
        system.debug('*** SageLiveCommunityRegistrationHandler updateContactSobject exit contact was updated:'+cList);
    }
    
    /*
     Method updating user data 
    */
    void updateUserSobject(User user, Auth.UserData data)
    {
        system.debug('updateUserSobject called');
        user.FirstName = data.firstName;
        user.LastName = data.lastName;
        user.Email = data.email;
        user.LocaleSidKey = data.locale;
        user.LanguageLocaleKey = data.attributeMap.get('language');
        user.TimeZoneSidKey = data.attributeMap.get('timezone');
        user.EmailEncodingKey  = 'ISO-8859-1';
        
    }
    
    /*
     * Web-ToCase callout to create case once SSO Error is thrown
    */
    
    void makeRestCallout(Auth.UserData data,String userInstanceUrl, String errorStr,String caseSubject){
        
        system.debug('makeRestCallout called @userInstanceUrl:'+userInstanceUrl+'@errorStr:'+errorStr+'@caseSubject'+caseSubject);
        HttpRequest req = new HttpRequest();
        Community_SSO_Settings__c errorCustomSetting = Community_SSO_Settings__c.getOrgDefaults();
        req.setEndpoint(trimSetting(errorCustomSetting.Web_To_Case_Service_Url__c));
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        String requestBody = 'orgid='+UserInfo.getOrganizationId();
        
        requestBody += '&subject='+caseSubject ;
        requestBody += '&email='+data.email;
        requestBody += '&description='+errorStr;
        //make final instance url change to apply already existing case assigment rules
        String finalInstanceUrl = userInstanceUrl == null ? 'Not Known' : 's2cor.'+userInstanceUrl.toLowerCase()+'.visual.force.com';
        requestBody += '&'+trimSetting(errorCustomSetting.CaseCustomerInstanceUrlFieldId__c)+'='+finalInstanceUrl;
        requestBody += '&'+trimSetting(errorCustomSetting.CaseCustomerInstancefieldId__c)+'='+data.attributeMap.get('organization_id');
        
        //case category
        requestBody += '&'+trimSetting(errorCustomSetting.Case_Category_Field_Id__c)+'='+trimSetting(errorCustomSetting.Case_Category__c);
        //case subcategory
        requestBody += '&'+trimSetting(errorCustomSetting.CaseSubCategoryFieldId__c)+'='+trimSetting(errorCustomSetting.Case_SubCategory__c);
        
        requestBody += '&priority='+trimSetting(errorCustomSetting.Case_Prority__c);
        requestBody += '&status='+trimSetting(errorCustomSetting.Case_Status__c);
        requestBody += '&type='+trimSetting(errorCustomSetting.Case_Type__c);
        requestBody += '&name='+data.fullName;
        requestBody += '&name='+data.attributeMap.get('user_id');
        requestBody += '&'+trimSetting(errorCustomSetting.CaseConsumerUserNameId__c)+'='+data.username;
        requestBody += '&origin='+trimSetting(errorCustomSetting.Case_Origin__c);
        
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res);
        System.debug(res.getBody());
        
    }
    
    //method trim all custom setting to avoid empty signs
    String trimSetting(String setting){
        if(setting != null){
            setting = setting.trim();
        }
        
        return setting;
    }

    class CommunityRegistrationHandlerException extends Exception{}
    
}