/**
 * Helper Class for passing calls to the zAPI via the Callable interface
 * expects the input map format as below
 */
public with sharing class ZuoraUpdateHelper {

    private Map<String, Object> parameters;
    private Map<String,String> callerInfo =  new Map<String,String>();
    private Map<String,String> fieldValueMap;

    public ZuoraUpdateHelper(Map<String, Object> parameters) {
        this.parameters = parameters;
        if(this.parameters != null){
            callerInfo = (Map<String,String>)parameters.get('CallerInfo');
            fieldValueMap = (Map<String,String>)parameters.get('FieldValues');    
        }
    }

    public String getExecutingClass(){
        String executingClass = callerInfo.get('exectingclass');
        if(String.isBlank(executingClass)){
            executingClass = 'CommerceZuoraUpdateCall';
        }
        return executingClass;
    }

    public String getCorrelationId(){
        return callerInfo.get('correlationId');
    }

    public Map<String,String> getFieldValueMap(){
        return fieldValueMap;
    }
}