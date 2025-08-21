@isTest
private class PopulateUsersToPublicGroupTest {
/*
 * 02/21/2019 EAD_896 BPHAN Populate users to Marketing Groups
 * based on Country and Profiles
 */    
    @isTest static void AddToGroups() {       
        Set<String> marketingGroupsAU = new Set<String>
                                    {   'AU_Leads_Representatives' };                                            
                                    
   		Set<String> marketingGroupsAsia = new Set<String>
                                    {  'Asia_Leads_Representatives' };    
                                        
   
   		List<Group> grpAU = [select ID from Group where DeveloperName = :marketingGroupsAU];   
   		List<Group> grpAsia = [select ID from Group where DeveloperName = :marketingGroupsAsia];
        
        // Test user in Sage Marketing profile = 00e24000000S23rAAC
        List<User> userListAU = new List<User>();
        List<User> userListAsia = new List<User>();
        User userAU = new User(FirstName='TestUser', LastName='AU', Country='Australia', isActive = true, ProfileID='00e24000000S23rAAC',
                              Username='TestUserAU@test.org', Email='TestUserAU@test.org', Alias='UserAU', CommunityNickname='TestUserAU', 
                              TimeZoneSidKey ='GMT', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');       
        userListAU.add(userAU);
        User userAsia = new User(FirstName='TestUser', LastName='Asia', Country='Singapore', isActive = true, ProfileID ='00e24000000S23rAAC',
                               Username='TestUserAsia@test.org', Email='TestUserAsia@test.org', Alias='UserAsia', CommunityNickname='TestUserAsia', 
                              TimeZoneSidKey ='GMT', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');               
        userListAsia.add(userAsia); 
        
        
        insert userListAU;
        insert userListAsia;
                           
        // test insert    
        System.Debug('User AU=' + userListAU);
        System.Debug('User Asia=' + userListAsia);
              
        // test update
        List<User> userListUSA = new List<User>();
        User userUSA = new User(FirstName='TestUser', LastName='USA', Country='United States', isActive = true, ProfileID ='00e24000000S23rAAC',
                                 Username='TestUserUSA@test.org', Email='TestUserUSA@test.org', Alias='UserUSA', CommunityNickname='TestUserUSA', 
                              TimeZoneSidKey ='GMT', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');    
        userListUSA.add(userUSA);

        insert userListUSA;
        
        userListUSA[0].Country = 'Malaysia';   // Change USA user to Malaysia
        update userListUSA[0];
        System.Debug('User USA=' + UserListUSA);

        List<GroupMember> gmAU = [select ID, GroupID, UserOrGroupId from GroupMember where UserOrGroupID IN :userListAU] ;
        System.Debug('Group Member AU=' + gmAU);
        if ( gmAU.Size() > 0)
            System.assertEquals('AU_Leads_Representatives', gmAU[0].Group.DeveloperName);
        
        List<GroupMember> gmAsia = [select ID, GroupID, UserOrGroupId from GroupMember where UserOrGroupID IN :userListAsia];
        System.Debug('Group Member Asia=' + gmAsia);
        if ( gmAsia.Size() > 0)
            System.assertEquals('Asia_Leads_Representatives' , gmAsia[0].Group.DeveloperName);
        
        List<GroupMember> gmUSA2Asia = [select ID, GroupID, UserOrGroupId from GroupMember where UserOrGroupID IN :userListUSA];
        System.Debug('Group Member USA2Asia=' + gmUSA2Asia);
        if ( gmUSA2Asia.Size() > 0)
            System.assertEquals('Asia_Leads_Representatives', gmUSA2Asia[0].Group.DeveloperName);
     
    }
    
}