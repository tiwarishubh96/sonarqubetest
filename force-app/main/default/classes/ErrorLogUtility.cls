public class ErrorLogUtility{   

    public static void insertErrorLog(Exception e, String origin, 
    									String objName,String triggerName,
											String className, String severity){
      
         
        Error_Log__c errorLog = new Error_Log__c();

        errorLog.Origin__c = origin;
        errorLog.SObject_Name__c = objName;

        if(e.getStackTraceString() != null){
           errorLog.Error_Message__c = e.getStackTraceString();
        }

        If(( e.getCause() != null || 
        		e.getMessage() != null) && 
        			(errorLog.Error_Message__c != null || 
        					errorLog.Error_Message__c != '' )){
            errorLog.Error_Message__c = 'Error Message: ' + e.getMessage() + 'Caused By: ' + e.getCause();
        }

        if(e.getLineNumber() != null){
            errorLog.Line_Number__c = 'Error Line: ' + e.getLineNumber();
        } else {
            errorLog.Line_Number__c = '';
        }

        if(severity != null){
            errorLog.Error_Severity__c = severity;
        }

        if(className != null){
            errorLog.Apex_Class__c = className;
        } 

        if(errorLog != null){
            List<Error_Log__c> errorLogs = new List<Error_Log__c>();
            errorLogs.add(errorLog);
            Database.SaveResult[] res = Database.insert(errorLogs, false);
        }                       
    }
}