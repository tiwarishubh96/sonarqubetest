@isTest
public class FlowButtonController_Test {

    @IsTest
    public static void markRecent() {
        Lead l = new Lead(firstname='Test', lastname='Lead', company='Acme');
        insert l;
        FlowButtonController.markRecent(l.id);
    }    
    
}