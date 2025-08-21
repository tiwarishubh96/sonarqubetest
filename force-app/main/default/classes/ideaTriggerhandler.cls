/*
	Handler class for ideaTrigger including the business logic
	EAD-438

*/

public class ideaTriggerhandler {
    
    public static void validateCategoriesSelection(List<Idea> lstIdea){
        
        Boolean isIdeasAdmin = isIdeasAdmin();
		
        system.debug('isIdeasAdmin>>>'+isIdeasAdmin);
        
        for(Idea objIdea: lstIdea){
            
            system.debug('objIdea.categories::'+objIdea.categories);
            // check if category is more than one
            if(objIdea.categories != Null){
                
                List<String> lstString = objIdea.categories.split(';');
                
                system.debug('lstString::'+lstString);
                
                if (lstString.size()>1){
                    
                    objIdea.addError('Please select only one Category!');
                }
            }  
            // check if the user has Ideas Admin permission set
            if(!isIdeasAdmin){
                
                system.debug('objIdea.Manager_Name1__c>>>'+objIdea.Manager_Name1__c);
                
                if(objIdea.Manager_Name1__c == Null){
                    
                    objIdea.addError('Please fill out Manager Name!');
                    
                }else if(objIdea.Dept__c == Null){
                    
                    objIdea.addError('Please fill out Dept!');
                    
                }else if(objIdea.Benefit__c ==Null){
                    
                    objIdea.addError('Please fill out Benefit!');
                    
                }else if(objIdea.Category__c == Null){
                    
                    objIdea.addError('Please fill out Strategic Theme!');
                }else if(objIdea.categories == Null){
                    
                    objIdea.addError('Please select from Categories!');
                    
                }else if(objIdea.Status == Null){
                    
                    objIdea.addError('Please select from Status!');
                }
                
            }

    	}
    }
    
    private static Boolean isIdeasAdmin(){
        
        Boolean isIdeasAdmin = false;
        
        List<PermissionSetAssignment> permission = [select PermissionSet.Name, Assignee.Name from PermissionSetAssignment where 
            Assignee.Id = :UserInfo.getUserId() AND PermissionSet.Name = 'Ideas_Admin' LIMIT 1];
        
        if(permission != null && permission.size() > 0){
            
            isIdeasAdmin = true;
        }
        
        Return isIdeasAdmin;
    }
}