@IsTest
public class PartnerObjRelatedListControllerTest {


   public static void factory() {
        Account a1 = new Account(name = 'A1', AnnualRevenue = 10000);
        insert a1;
        Account a2 = new Account(name = 'A2', AnnualRevenue = 1, parentid = a1.id);
        insert a2;
       //1084 Included Why We Lost for Validation
        Opportunity o1 = new Opportunity(name = 'O1'  , AccountId = a1.id, StageName = 'Closed Won',
                                        Why_We_Lost__c = 'No Reason Specified');
        o1.CloseDate = Date.today();
        insert o1;

        Partner op = new Partner();
        op.IsPrimary = true;
        op.AccountToId = a2.id;
        op.OpportunityId = o1.id;
        op.Role = 'Developer';
        insert op;
        
    }
    
    public static Account getAccount(Integer i) {
        String recordName = 'A' + i;
        return [select id, name from Account where name = :recordName][0];
    }

    public static Opportunity getOpportunity(Integer i) {
        String recordName = 'O' + i;
        return [select id, name from Opportunity where name = :recordName][0];
    }

    public static Partner getPartner() {
        return [select id from Partner][0];
    }
    
    @IsTest
    public static void getSObjectType() {
        factory();
        String sObjectType = PartnerObjRelatedListController.getSObjectType(getOpportunity(1).id);
        System.assertEquals('Opportunity', sObjectType);
    }        
    
    @IsTest
    public static void getPartners_Opportunity() {
        factory();
      String s = PartnerObjRelatedListController.getPartners(getOpportunity(1).id);


    }

    @IsTest
    public static void getPartners_Account() {
        factory();
      String s = PartnerObjRelatedListController.getPartners(getAccount(2).id);

    }

    @IsTest
    public static void invalidDeletePartner() {
        Test.startTest();
        factory();
        //Invalid partner ID - 00690000002BoMV
        ID partnerId =Id.valueOf('00690000002BoMV');
        try {

            String s = PartnerObjRelatedListController.deletePartner(partnerId);

        }
        Catch(Exception e){
            System.debug('No Partner with '+partnerId);
        }
        Test.stopTest();
    }

    @IsTest
    public static void deletePartner() {
        factory();
      PartnerObjRelatedListController.deletePartner(getPartner().id);
        Integer counter = [select count() from Partner];
        System.assertEquals(0, counter);        
    }

    @IsTest
    public static void getParentRecordId() {
        factory();
        Opportunity o1 = getOpportunity(1);
        Account a1 = getAccount(1);
      String a1Derived = PartnerObjRelatedListController.getParentRecordId(o1.id);
        System.assertEquals(a1Derived, a1.id);        
    }

    @IsTest
    public static void getParentRecordId_Null() {
        factory();
        Account a1 = getAccount(1);
      String a1Derived = PartnerObjRelatedListController.getParentRecordId(a1.id);
        System.assert(a1Derived == null);        
    }
    


}