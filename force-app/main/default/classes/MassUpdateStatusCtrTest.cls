@isTest
public class MassUpdateStatusCtrTest{
    public static testMethod void testMethod1(){
        Lead Ld = new Lead();
        Ld.LastName = 'Ld.LastName';
        Ld.Company = 'Ld.Company';
        insert Ld;
        
        Lead Ld2 = new Lead();
        Ld2.LastName = 'Ld.LastName';
        Ld2.Company = 'Ld.Company';
        insert Ld2;
        
        PageReference pageRef = Page.MassUpdateStatus;
        Test.setCurrentPage(pageRef);

        ApexPages.CurrentPage().getparameters().put('id', Ld.id);
        ApexPages.CurrentPage().getparameters().put('r', (String)Ld.Id + ',' + (String)Ld2.Id);

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController([select Id from Lead]);
        MassUpdateStatusCtr MassUpdateStatsCtr = new MassUpdateStatusCtr(sc);
        MassUpdateStatsCtr.updateStat();
        
    }
}