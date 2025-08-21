/**
 author Shanmuk Hanumanthu
 date 12-Dec-2019
 description trigger handler class for User trigger. This class should be responsible for invoking all business logic
 involved on User.
 */

public without sharing class User_TriggerHandler implements TriggerHandlerInterface {

 public void BeforeInsert(List < SObject > newItems) {
  User_Helper.invokeUserInsertCountriesToRegionMappingUtils((List < User > ) newItems);
  User_Helper.alignRnRManager((List<User>) newItems, new Map<Id,User>());
 }

 public void BeforeUpdate(Map < Id, SObject > newItems, Map < Id, SObject > oldItems) {
  User_Helper.invokeBlacklistWordFilterOnUserStatus((List < User > ) newItems.values(), (Map < Id, User > ) oldItems);
  User_Helper.invokeUserUpdateCountriesToRegionMappingUtils((List < User > ) newItems.values(), (Map < Id, User > ) oldItems);
  User_Helper.alignRnRManager((List<User>) newItems.values(), (Map <Id,User>) oldItems);
 }

 public void AfterDelete(Map < Id, SObject > oldItems) {}

 public void AfterInsert(Map < Id, SObject > newItems) {
  User_Helper.invokePopulateUsersToPublicGroupHelper((Set < ID > ) newItems.keySet());
 }

 public void AfterUndelete(Map < Id, SObject > oldItems) {}

 public void AfterUpdate(Map < Id, SObject > newItems, Map < Id, SObject > oldItems) {
  User_Helper.invokePopulateUsersToPublicGroupHelper((Set < ID > ) newItems.keySet());
  User_Helper.updateClosedLoopManagerEmail((List<User>) newItems.values(), (Map <Id,User>) oldItems);
 }

 public void BeforeDelete(Map < Id, SObject > oldItems) {}
}