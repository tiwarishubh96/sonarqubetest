public class ExceptionLogUtility{   

    public static void insertErrorLog(Exception e, String origin, 
    									String objName, String triggerName,
											String className, String method, String severity){
      
        Error_Log__c errorLog = new Error_Log__c();

        errorLog.Origin__c = origin;
        errorLog.SObject_Name__c = objName;
        if(e != null){
            if(e.getStackTraceString() != null){
           errorLog.Error_Message__c = e.getStackTraceString();
            }

            If((e.getMessage() != null || 
                    e.getCause() != null) && 
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

            if(method != null){
                errorLog.Method__c = method;
            } 

            if(errorLog != null){
                List<Error_Log__c> errorLogs = new List<Error_Log__c>();
                errorLogs.add(errorLog);
                Database.SaveResult[] res = Database.insert(errorLogs, false);
            } 
        }                  
    }

	//Overload which does not use a debugTrace object to provide additional context
	public static void insertErrorLogs(List<Exception> exceptions, String origin, 
                                        String objName, String triggerName,
                                            String className, String method, String severity){
                                            	
		insertErrorLogs(exceptions, null, origin, objName, triggerName, className, method, severity);
    }

    public static void insertErrorLogs(List<Exception> exceptions, TetrisDebugTraceState debugTrace, 
     									String origin, String objName, String triggerName,
                                            String className, String method, String severity){
      
        Error_Log__c errorLog;

        if(exceptions != null){
        	
            for(Exception e: exceptions){

	        	String sourceMethod = method;
	        	String sourceClass = className;
	        	String errorDetail = '';
	        	String errorMessage = e.getMessage();	//default to basic exception message
	        	
	        	//if(debugTrace != null) {
	        	//	sourceMethod = debugTrace.currentMethod;
	        	//	sourceClass = debugTrace.currentClass;
	        	//	errorDetail = debugTrace.getErrorDetailMessage();
	        	//}
	        	
	        	//If we have a custom TetrisException, then process additional values
	        	if(e instanceof ExceptionLogUtility.TetrisException) {
	        		
	        		ExceptionLogUtility.TetrisException te = (ExceptionLogUtility.TetrisException)e;
	        		if(te.traceState != null) {
			        	sourceMethod = te.traceState.currentMethod;
			        	sourceClass = te.traceState.currentClass;
			        	errorDetail = te.traceState.getErrorDetailMessage();
			        	errorMessage = te.traceState.getDebugTraceHistory(te.getMessage());
	        		}
	        			        		
	        	}
	        	

                errorLog = new Error_Log__c();

                errorLog.Origin__c = origin;
                errorLog.SObject_Name__c = objName;

				errorLog.Error_Detail__c = errorDetail;
				
                //if(e.getStackTraceString() != null){
                //   errorLog.Error_Message__c = e.getStackTraceString();
                //}

                //If((e.getMessage() != null || 
                //        e.getCause() != null) && 
                //            (errorLog.Error_Message__c != null || 
                //                    errorLog.Error_Message__c != '' )){
                //    errorLog.Error_Message__c = 'Error Message: ' + e.getMessage() + 'Caused By: ' + e.getCause();
                //}
                
                errorLog.Error_Message__c = errorMessage;

                if(e.getLineNumber() != null){
                    errorLog.Line_Number__c = 'Error Line: ' + e.getLineNumber();
                } else {
                    errorLog.Line_Number__c = '';
                }

                if(severity != null){
                    errorLog.Error_Severity__c = severity;
                }

                if(method != null){
                    errorLog.Method__c = sourceClass + '.' + sourceMethod;
                } 

                if(errorLog != null){
                    List<Error_Log__c> errorLogs = new List<Error_Log__c>();
                    errorLogs.add(errorLog);
                    Database.SaveResult[] res = Database.insert(errorLogs, false);
                }        
            }           
        }
    }
    
    public class TetrisException extends Exception {
    
    	public TetrisDebugTraceState traceState {get;set;}
    }    
}