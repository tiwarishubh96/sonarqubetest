//@author: Ravi Yalamati
//@date: 22-02-2019
//@descrption: Common controller for OpenAndClosedCases VF page and lightning component
public class OpenAndClosedCasesController {
    public static string accountRecId {get;set;}
    public static Integer openCaseCount{get;set;}
    public static Integer closeCaseCount{get;set;}
    //standard controller to be used by VF page
    public OpenAndClosedCasesController(ApexPages.StandardController controller) {
    accountRecId = ((Account)controller.getRecord()).id;
        openCaseCount = 0;
        closeCaseCount=0;
  }
  //method for vf page to calculate case records on load of account page
    public void doAction() {
        Map<String,Integer> mapCountResult = new Map<String,Integer>();
        mapCountResult = getCaseCount(accountRecId);
        openCaseCount = mapCountResult.get('Open');
        closeCaseCount = mapCountResult.get('Closed');
    }
    //Aura method to be called by lightning component
    @auraEnabled
    public static Map<String,Integer> getCaseCount(String accountId) {
        Map<String,Integer> mapCaseCount = new Map<String,Integer>{'Open' => 0, 'Closed' => 0};
        AggregateResult [] accountResults = [Select count(Id) countCase from Case where AccountId=:accountId and recordtype.name = 'Global Case' and Status != 'Closed'];
        //fetch the account related case grouped by closed status
        for(AggregateResult accountResult : accountResults) {
            /*If((Boolean)accountResult.get('closedOrNot')) {
                //populate the map for closed and open statuses
                mapCaseCount.put('Closed', Integer.valueOf(accountResult.get('countCase')));
            } else {*/
                mapCaseCount.put('Open', Integer.valueOf(accountResult.get('countCase')));
            //}
        }
        return mapCaseCount;
    }
    
  @auraEnabled
    public static Integer getRemoteSupport(String accountId) {
       List<Case> CaseList =[Select id from Case where AccountId=:accountId and Remote_Support__c ='Remote PC connected' and (CreatedDate = LAst_N_Months:12 or CreatedDate = THIS_MONTH)]; 
        Integer CaseCount = CaseList.size();
        return CaseCount;
    }
    @auraEnabled
    public static Integer getOpenComplaints(String accountId) {
       List<Case> CaseCompList =[Select id from Case where AccountId=:accountId and recordtype.name = 'Global Complaint' and Status != 'Closed']; 
        Integer openComplaintsCount = CaseCompList.size();
        return openComplaintsCount;
    }
}