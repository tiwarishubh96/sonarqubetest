@isTest
public class FieldSetControllerTest {
    public static String typeName = 'Opportunity';
    public static String fsName = 'OpportunityASBFields';
	
    
    /** As we can't create FieldSet using the Apex, calling methods directly **/
    @isTest
    public static void getFieldsAndFieldSets(){
        FieldSetController.getFields(typeName, fsName);
        FieldSetController.getFieldSetNames(typeName);
  	    FieldSetController.hasFieldSets(typeName);
    }
}