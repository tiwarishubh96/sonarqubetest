public with sharing class CommunityMyAccountController {

    public Contact con;
    public Id contactId {get;set;}   
    public Id loggedinUserId;
    public String userType;

    public Contact getCon() {
        return con;
    }
       
    public CommunityMyAccountController(ApexPages.StandardController controller) { 
    
    }
    
    public CommunityMyAccountController() {

        // Get the User Id of the currently logged in User
        loggedinUserId = UserInfo.getUserId();
        // Get User Type of loged in User      
        userType = userinfo.getUserType();     

        // Get a list of Contact Ids of the Current User only if they are a Community User
        List<User> userLst = [Select ContactId from User where Id =: loggedinUserId AND userType =: 'CspLitePortal' LIMIT 1];
        if(!userLst.isEmpty()){
            contactId = userLst.get(0).ContactId;    

            // Use the Contact Id to find the Account Record 
            List <Contact> conList =  [SELECT Id, AccountId From Contact Where Id = :contactId LIMIT 1];   
     
            if (conList != null && conList.size() > 0 ){
                   con = conList[0];
            }
        } else {
            con = null;
        }  
                 
    }

    public PageReference getMyAccount() {
    
        if (con != null && con.Id != null) {    
                PageReference pageRef = new PageReference('/' + con.accountid);                
                return pageRef;          
        }
        return null;
    }
          
}