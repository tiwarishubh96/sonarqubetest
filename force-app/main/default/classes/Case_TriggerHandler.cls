/**
 * Part of EAD-2431 to refactor Case trigger to new Framework.
 * The RnR logic lives in it's own hanlder (see survey package)
 */
public without sharing class Case_TriggerHandler extends TriggerService {
    
    /*public override void onBeforeInsert() {
        CaseWaitingForPartnerHandler obj = new CaseWaitingForPartnerHandler();
        obj.forInsert((List<Case>) this.listNewSObject);
    }
 
    public override void onBeforeUpdate() {
        CaseWaitingForPartnerHandler obj = new CaseWaitingForPartnerHandler();
        obj.forUpdate((List<Case>) this.mapOldSObject.values(), (List<Case>) this.listNewSObject);  
    }*/

    //RNR handled in own handler
    public override void onAfterUpdate() {
        Case_Helper.caseclosetask((List<Case>) this.listNewSObject, (Map<Id, Case>) this.mapOldSObject);
    }


}