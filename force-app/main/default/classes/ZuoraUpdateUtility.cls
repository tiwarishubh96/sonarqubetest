public with sharing class ZuoraUpdateUtility implements Callable {

    /**
     * Expects a the Map to be 
     * callerInfo -> {exectingclass=>Name,corrleationId=>id}
     * fieldValues -> {field=>value}
     * 
     * 
     */
    public Object call(String sObjectName, Map<String, Object> parameters) {
        Boolean response = true;
        ZuoraUpdateHelper updateHelper = new ZuoraUpdateHelper(parameters);
        
        //default to generic commerce update
        String executingClass = updateHelper.getExecutingClass();
        System.debug(LoggingLevel.DEBUG,'executingClass = ' + executingClass);
        String correlationId = updateHelper.getCorrelationId();
        System.debug(LoggingLevel.DEBUG,'correlationId = ' + correlationId);
        Map<String,String> fieldValueMap = updateHelper.getFieldValueMap();
        System.debug(LoggingLevel.DEBUG,'fieldValueMap = ' + fieldValueMap);
        if(fieldValueMap == null){
            ExceptionLogger.logInfo('ZuoraUpdateUtility',correlationId,null,'Unable to call zAPI update, fieldMap empty',ExceptionLogger.ERROR_TYPE.ERROR);
            response = false;
            return response;
        }
        callUpdate(executingClass,sObjectName,fieldValueMap);

        return response;
    }    

    @Future(Callout=true)
    public static void callUpdate(String executingClass,String objectname, Map<String,String> fieldValueMap){
        Zuora.zApi instance = loginToZuora(executingClass);
        Map<String,Object> valueMap = (Map<String,Object>)fieldValueMap;
        updateZuoraObject(instance,objectname,valueMap);
    }

    /**
     * [loginToZuora logins to the zuora account]
     * @return [instance for using the zuora api]
    */
    public static Zuora.zApi loginToZuora(){
    	return loginToZuora(null);
    } 
    
    /**
     * [loginToZuora logins to the zuora account]
     * @param executedFromClass [class name from which method was called] 
     * @return [instance for using the zuora api]
    */ 
    public static Zuora.zApi loginToZuora(String executedFromClass){
        Zuora.zApi zApiInstance = new Zuora.zApi();     
        try {
            zApiInstance.zLogin();  
        } catch (Exception e){  
        	if(executedFromClass == null){
        		ExceptionHandler.CatchException('ZuoraUpdateUtility', 'loginToZuora', e);
        	} else {
				ExceptionHandler.CatchException(executedFromClass + '.ZuoraUpdateUtility', 'loginToZuora', e);
        	}
        }
        return zApiInstance;
    }

	/**
     * [updateZuoraObject updates in the zuora object all the fields with their new values from the 'fieldValueByNameMap']
     * @param  zApiInstance                    [instance for using the zuora api]
     * @param  objName                         [Zuora object name]
     * @param  id                              [id in Zuora]
     * @param  Map<String,fieldValueByNameMap> [new field value by zuora api map]
     * @return [true for success, false for fail]
     */
	public static Boolean updateZuoraObject(Zuora.zApi zApiInstance, String objName, Map<String,Object> fieldValueByNameMap){
		return updateZuoraObject(zApiInstance, objName, fieldValueByNameMap, null);
	}

	/**
     * [updateZuoraObject updates in the zuora object all the fields with their new values from the 'fieldValueByNameMap']
     * @param  zApiInstance                    [instance for using the zuora api]
     * @param  objName                         [Zuora object name]
     * @param  id                              [id in Zuora]
     * @param  Map<String,fieldValueByNameMap> [new field value by zuora api map]
     * @param executedFromClass [class name from which method was called] 
     * @return [true for success, false for fail]
     */
    public static Boolean updateZuoraObject(Zuora.zApi zApiInstance, String objName, Map<String,Object> fieldValueByNameMap, String executedFromClass){
        System.debug('**** updateZuoraObject: ' + objName + '.' + fieldValueByNameMap);
        Zuora.zObject obj;
        try{
            obj = new Zuora.zObject(objName);
            for (String field : fieldValueByNameMap.keySet()){             
            	obj.setValue(field,fieldValueByNameMap.get(field));             
            }
        	List<Zuora.zObject> objs = new List<Zuora.zObject> {obj};
            List<Zuora.zApi.SaveResult> results = zApiInstance.zupdate(objs);
            if(results.get(0).Success){
            	return true;
            } else {
            	Map<String, String> errorMessageMap = new Map<String, String>();
            	for(Zuora.zObject error : results.get(0).errors){	
            		errorMessageMap.put(results.get(0).Id, (String)error.getValue('Message'));
            	}
            	if(executedFromClass == null){
            		ExceptionHandler.logZuoraRecordProcessingErrors('ZuoraUpdateUtility', 'updateZuoraObject', errorMessageMap);	
            	} else {
            		ExceptionHandler.logZuoraRecordProcessingErrors(executedFromClass + '.ZuoraUpdateUtility', 'updateZuoraObject', errorMessageMap);	
            	}
            	
            	return false;
            }
        } catch(Exception e){     
			ExceptionHandler.CatchException('ZuoraUpdateUtility', 'updateZuoraObject', e);
			return false;      
        }
    }
}