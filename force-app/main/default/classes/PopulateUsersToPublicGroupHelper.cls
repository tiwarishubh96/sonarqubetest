public class PopulateUsersToPublicGroupHelper {
  /*
 * 02/21/2019 EAD_896 BPHAN Populate users to Marketing Groups
 * based on Country and Profiles
 */  
    @future
    public static void AddToGroups(Set<Id> userIds)
    {     
       Set<String> marketingProfiles = new Set<String>
                                    {   'Sage: Marketing',
										'Sage: Marketing Operations User',
										'Sage: Sales Operations',
									    'Sage: Sales User',
						                'Sage: Sales User with Lightning' };
                                            
   		Set<String> marketingGroupsAU = new Set<String>
                                    {   'AU_Leads_Representatives' };                                            
                                    
   		Set<String> marketingGroupsAsia = new Set<String>
                                    {  'Asia_Leads_Representatives' };    

   		Set<String>  asiaCountries = new Set<String>                                        
                                    { 'Singapore', 'Malaysia' };

   		Set<String>  AUCountries = new Set<String>                                        
                                    { 'Australia' };                                        
   
   		List<Group> grpAU = [select ID from Group where DeveloperName = :marketingGroupsAU];   
   		List<Group> grpAsia = [select ID from Group where DeveloperName = :marketingGroupsAsia];
        List<User> userListAsia = [Select ID, Country from User as u where u.Id IN :userIds and u.isActive = true and u.Profile.Name IN :marketingProfiles and u.Country IN :asiaCountries] ;
   		List<User> userListAU = [Select ID, Country from User as u where u.Id IN :userIDs and u.isActive = true and u.Profile.Name IN :marketingProfiles and u.Country IN :AUCountries] ;
        
   		List<groupMember> groupMemberList = new List<groupMember>(); 
   		// Populate AU 
   		for ( User u:userListAU )
   		{
       		for ( Group gp:grpAU)
       		{    
                System.Debug('Populating AU user=' + u);
         		GroupMember gm = new groupMember();
            	gm.GroupId = gp.Id;               
            	gm.UserOrGroupId = u.Id;
           		groupMemberList.add(gm);
       		}
   		}

   		// Populate Asia
   		for ( User u:userListAsia )
   		{
       		for ( Group gp:grpAsia)
       		{    
                System.Debug('Populating Asia user=' + u);
         		GroupMember gm = new groupMember();
            	gm.GroupId = gp.Id;               
            	gm.UserOrGroupId = u.Id;
           		groupMemberList.add(gm);
       		}
   		}
   		// save to database 
		if(groupMemberList.size() > 0)
    	{    
	  		database.upsert(groupMemberList,false);
            System.Debug('GroupMemberList=' + groupMemberList);
    	}                
  
    }    
}