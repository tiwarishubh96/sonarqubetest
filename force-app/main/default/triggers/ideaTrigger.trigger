/*
	Trigger on idea object to make sure user can only select one category from 
	categories picklist values.
	EAD-438

*/

trigger ideaTrigger on Idea (before insert,before update) {

    if(Trigger.isBefore){
        
        if(Trigger.isInsert || Trigger.isUpdate){
        	//when inserting or updating the idea record, validation logic
        	//should be triggered.
        	ideaTriggerhandler.validateCategoriesSelection(Trigger.New);
        }
    }
}