/**
 * Created by Shanmuk Hanumanthu on 12/12/2019.
 * @description User Helper is a helper class that performs a operations and manipulations based on user data
 */

public without sharing class User_Helper {
 static String CLASSNAME = 'User_Helper';

 /**
  * @description:  the user performing populating users to public groups via PopulateUsersToPublicGroupHelper
  * (invokePopulateUsersToPublicGroupHelper)
  * @param: List of trigger new Contacts
  **/

 public static void invokePopulateUsersToPublicGroupHelper(Set < ID > userIdSet) {
  try {
   LogControl.push('invokePopulateUsersToPublicGroupHelper', CLASSNAME);
    PopulateUsersToPublicGroupHelper.AddToGroups(userIdSet);
  } catch (Exception e) {
  system.debug('@@ inside catch block');
   LogControl.debugException(e);
  } finally {
  system.debug('@@ inside finally block');
   LogControl.pop();
  }
 }

 /**
  * @description: t * Filter UserStatus updates for blacklisted words it was earlier implemented by Quinton Wall (qwall@salesforce.com)
  * (invokeBlacklistWordFilterOnUserStatus)
  * @param: List of trigger new Contacts
  * @param: map of trigger old Contact
  **/
 public static void invokeBlacklistWordFilterOnUserStatus(List < User > Users, Map < Id, User > oldUserMap) {
  try {
   LogControl.push('invokeBlacklistWordFilterOnUserStatus', CLASSNAME);
   if (TestUtils.isRunningTest() || Application_Control__c.getOrgDefaults().Run_Blacklist_Word_Filter__c) {

    List < User > usersWithStatusChanges = new List < User > ();

    //only test for blacklist filtering if the trigger was executed
    //because of a status change
    for (User u: Users) {
     if (u.CurrentStatus != oldUserMap.get(u.Id).currentStatus)
      usersWithStatusChanges.add(u);
    }

    if (!usersWithStatusChanges.isEmpty())
     new BlacklistFilterDelegate().filterUserStatus(usersWithStatusChanges);

   }
  } catch (Exception e) {
   LogControl.debugException(e);
  } finally {
   LogControl.pop();
  }
 }


 /**
  * @description: Map users associated countries to Regions
  * (invokeUserInsertCountriesToRegionMappingUtils)
  * @param: List of trigger new Contacts
  **/
 public static void invokeUserInsertCountriesToRegionMappingUtils(List < User > users) {
  try {
   LogControl.push('invokeUserInsertCountriesToRegionMappingUtils', CLASSNAME);
   Set < String > userconIds = new Set < String > ();
   if (RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
    RecursiveTriggerHandler.isFirstTime = false;
    Set < string > countrySet = new Set < String > ();
    for (user u: users) {
     userconIds.add(u.contactId);
     if (u.country != null) {
      countrySet.add(u.country);
     }
    }
    if (countrySet != null) {
     Map < String, String > conToRe = CountriesTORegionMappingUtils.mapCountriestoRegions(countrySet);
     for (user u: users) {
      if (conToRe.containsKey(u.country)) {
       u.Sage_Region__c = conToRe.get(u.country);
      }
     }
    }

    Map < Id, Contact > mapContact = new Map < Id, contact > ([select account.Locale__c, account.Locale_Billing_CC__c, accountId from contact where id IN: userconIds and account.Type = 'partner']);
    if (!mapContact.isEmpty()) {
     for (user u: users) {
      if (u.contactId != null) {
       contact acc = mapContact.get(u.contactId);
       String Locale = getLocalevaluefromMapping.getlocalefromMapping(acc.account.Locale__c, acc.account.Locale_Billing_CC__c);
       u.LocaleSidKey = Locale;
       List < Partner_Locale_Language_Matrix__c > matrix = Partner_Locale_Language_Matrix__c.getAll().values();
       for (Partner_Locale_Language_Matrix__c p: matrix) {
        if (p.Locale__c == Locale) {
         u.LanguageLocaleKey = p.Language__c;
        }
       }
      }
     }
    }
   }
  } catch (Exception e) {
   LogControl.debugException(e);
  } finally {
   LogControl.pop();
  }
 }


 /**
  * @description: Map users associated countries to Regions
  * (invokeUserUpdateCountriesToRegionMappingUtils)
  * @param: List of trigger new Contacts
  * @param: Map of trigger old Contacts
  **/
 public static void invokeUserUpdateCountriesToRegionMappingUtils(List < User > users, Map < Id, User > oldUserMap) {
  try {
   LogControl.push('invokeUserUpdateCountriesToRegionMappingUtils', CLASSNAME);
   if (RecursiveTriggerHandler.isFirstTime || Test.isRunningTest()) {
    RecursiveTriggerHandler.isFirstTime = false;
    Boolean flag = false;
    Id id1 = UserInfo.getProfileId();
    List < Profile > PROFILE = [Select Name from Profile where Id =: id1];
    String ProflieName = PROFILE[0].Name;
    Set < string > countrySet = new Set < String > ();
    for (user u: users) {
     if (u.country != null) {
      countrySet.add(u.country);
     }
    }
    List < Partner_Community_Profiles__c > listB = Partner_Community_Profiles__c.getAll().values();
    for (Integer i = 0; i < listB.size(); i++) {
     if (ProflieName == listB[i].Profile__c) {
      flag = true;
     }
    }

    if (countrySet != null) {
     Map < String, String > conToRe = CountriesTORegionMappingUtils.mapCountriestoRegions(countrySet);
     for (user u: users) {
      if (conToRe.containsKey(u.country)) {
       u.Sage_Region__c = conToRe.get(u.country);
      }
     }
    }
   }
  } catch (Exception e) {
   LogControl.debugException(e);
  } finally {
   LogControl.pop();
  }
 }
    
    /**
    * @description: Ensure RnR Manager matches Standard Manager value
    * (alignRnRManager)
    * @param: List of new Users
    * @param: Map of Ids to old Users
    **/
	public static void alignRnRManager(List<User> newUsers, Map<Id, User> oldUsers) {
		LogControl.push('alignRnRManager', CLASSNAME);
		for (User u : newUsers) {
            if (oldUsers.isEmpty() || u.ManagerId != oldUsers.get(u.Id).ManagerId) {
                System.debug('MANAGER ID ' + u.ManagerId); // TODO REMOVE
                System.debug('RNR MANAGER ID ' + u.RRFrontline__Rant_and_Rave_Manager__c); // TODO REMOVE
                u.RRFrontline__Rant_and_Rave_Manager__c = u.ManagerId;
                System.debug('SETTING RNR MANAGER, now ' + u.RRFrontline__Rant_and_Rave_Manager__c); // TODO REMOVE
            }
		}
	}
    
    /**
    * @description: Ensure Closed Loop Manager Email reflects Manager change on User
    * (updateClosedLoopManagerEmail)
    * @param: List of new Users
    * @param: Map of Ids to old Users
    **/
    public static void updateClosedLoopManagerEmail(List<User> newUsers, Map<Id, User> oldUsers) {
    	LogControl.push('updateClosedLoopManagerEmail', CLASSNAME);
        Map<Id,Id> mapUserToManager = new Map<Id,Id>();
        Map<Id,User> mapManagerIdToManager;
        List<Closed_Loop__c> closedLoopsForUpdate = new List<Closed_Loop__c>();
        
        for (User u : newUsers) {
            if (u.ManagerId != oldUsers.get(u.Id).ManagerId) {
                mapUserToManager.put(u.Id,u.ManagerId);
            }
        }
        
        if (!mapUserToManager.isEmpty()) {
            mapManagerIdToManager = new Map<Id,User>([SELECT Id, Email 
                                                      FROM User
                                                      WHERE Id IN :mapUserToManager.values()]);

            closedLoopsForUpdate = [SELECT Id, Is_Closed__c, Agent__c, Agent_Manager_Email__c 
                                    FROM Closed_Loop__c 
                                    WHERE Agent__c IN :mapUserToManager.keySet()
                                    AND Is_Closed__c = 'OPEN'];

            for (Closed_Loop__c cl : closedLoopsForUpdate) {
                Id managerId = mapUserToManager.get(cl.Agent__c);
                cl.Agent_Manager_Email__c = mapManagerIdToManager.get(managerId).Email;
            }

            if (!closedLoopsForUpdate.isEmpty()) {
                try {
                    // update affected Closed Loops
                    Database.update(closedLoopsForUpdate, false);
                } catch (Exception e) {
                    LogControl.debugException(e);
                } finally {
                    LogControl.pop();
                }
            }
        }
	}
}