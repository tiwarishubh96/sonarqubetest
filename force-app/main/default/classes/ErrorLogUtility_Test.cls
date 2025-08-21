@IsTest (SeeAllData=false)
public class ErrorLogUtility_Test {

	@isTest static void testInsertErrorLogWithMessage(){

		String origin = 'Tetris';
		String objName = 'Cart';
		String triggerName = 'None';
		String className = 'TetrisRegistration';
		String severity = 'High';
		String exceptionMessage = 'List out of bounds exception.';
		TetrisRegistrationException customException = new TetrisRegistrationException(exceptionMessage);

		List<Error_Log__c> errorLogRec;

        Test.startTest();
            ErrorLogUtility.insertErrorLog(customException, origin, 
									 			objName, triggerName,
											 			className,  severity);
            errorLogRec = [SELECT Id FROM Error_Log__c WHERE Apex_Class__c = 'TetrisRegistration'];
        	customException = new TetrisRegistrationException(exceptionMessage);
        Test.stopTest();

        System.assert(!errorLogRec.isEmpty());
    }

    @isTest static void testInsertErrorLogNoMessage(){

    	String origin = 'Tetris';
		String objName = 'Cart';
		String triggerName = 'None';
		String className = 'TetrisRegistration';
		String severity = 'High';
		String exceptionMessage = 'List out of bounds exception.';
		TetrisRegistrationException customException = new TetrisRegistrationException();

		List<Error_Log__c> errorLogRec;

        customException = new TetrisRegistrationException();
        Test.startTest();
            ErrorLogUtility.insertErrorLog(customException, origin, 
									 			objName, triggerName,
											 			className,  severity);
            errorLogRec = [SELECT Id FROM Error_Log__c WHERE Apex_Class__c = 'TetrisRegistration'];
        Test.stopTest();

        System.assert(!errorLogRec.isEmpty());
    }

    public class TetrisRegistrationException extends Exception {}

}