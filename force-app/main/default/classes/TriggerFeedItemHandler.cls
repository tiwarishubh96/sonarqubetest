/**
* @author John Assheton
* @date 30 November 2015
* @description FeedItem Trigger Handler
*/

public with sharing class TriggerFeedItemHandler{ 

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on before insert event
    * @return void
    * @param newObjects: trigger.new - list of all records to insert
    */
    /*public void onBeforeInsert(final List<FeedItem> newObjects) {            
    
    }*/

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on after insert event
    * @return void
    * @param newObjects: trigger.new - list of all records that were inserted
    * @param newObjectsMap: trigger.new - map of all records that were inserted
    */
    public void onAfterInsert(final List<FeedItem> newObjects, final Map<Id, FeedItem> newObjectsMap)
    {
        system.debug('Method for updating case status should be triggered');
        SageCommunityCasePost.changeCaseStatusOnCommunityUserPost(Trigger.New);
        system.debug('Method for updating success plan status should be triggered');        
        SageCommunitySuccessPlanPost.changeSuccessPlanOnCommunityUserPost(Trigger.New);
    }

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on before update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    /*public void onBeforeUpdate(final List<FeedItem> oldObjects, final Map<Id, FeedItem> oldObjectsMap,
                               final List<FeedItem> newObjects, final Map<Id, FeedItem> newObjectsMap) {                                
        
    }*/

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on after update event
    * @return void
    * @param oldObjects: trigger.old - list of all records before the change to update
    * @param oldObjectsMap: trigger.oldMap - map of all records before the change to update
    * @param newObjects: trigger.new - list of all changed records to update
    * @param newObjectsMap: trigger.newMap - map of all changed records to update
    */
    /*public void onAfterUpdate(final List<FeedItem> oldObjects, final Map<Id, FeedItem> oldObjectsMap,
                              final List<FeedItem> newObjects, final Map<Id, FeedItem> newObjectsMap)
    {

    }*/
  
    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on before delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records before tdelete
    * @param oldObjectsMap: trigger.oldMap - map of all records before delete
    */
    /*public void onBeforeDelete(final List<FeedItem> oldObjects, final Map<Id, FeedItem> oldObjectsMap) {
      
    }*/

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on after delete event
    * @return void
    * @param oldObjects: trigger.old - list of all records after delete
    * @param oldObjectsMap: trigger.oldMap - map of all records after delete
    */
    /*public void onAfterDelete(final List<FeedItem> oldObjects, final Map<Id, FeedItem> oldObjectsMap) {
        
    }*/

    /**
    * @author John Assheton
    * @date 30 November 2015
    * @description fired on after undelete event
    * @return void
    * @param newObjects: trigger.new - list of all records that are undeleted
    * @param newObjectsMap: trigger.new - map of all records that are undeleted
    */
    /*public void onAfterUndelete(final List<FeedItem> newObjects, final Map<Id, FeedItem> newObjectsMap) {
    
    }*/

}