/***
* @author P-E GROS
* @date   Dec. 2020
* @description Flow controller class to check duplicates of a new record from a Flow.
**
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegGetFieldsetData_CTL {

/***
* @description	Invocable method to easily fetch data corresponding to a given
*               fieldset for a series of records based on their IDs.
* @param		dataRequests	List of 'DataRequest' records containing the 
*                               records for which data should be fetched and the FieldSet
*                               name (as 'Object.Fieldset', i.e. Object API & FS Developer
*                               names). Each record should have an ID !
* @return		List<List<SObject>>		List of matching records (of same sobject type with
*                                       proper authorized fieldset fields returned).
* @exception   	dmlExceptions in case of processing issue.
***/    
    @InvocableMethod(label='Get Records Data' description='Get data of a given fieldset for a list of records.' category='SF PEG')
	public static List<List<SObject>> getData(List<DataRequest> dataRequests) {
		System.debug('getData: START');
		//System.debug('getData: newRecords received ' + newRecords);
        
        if ((dataRequests == null) || (dataRequests.size() == 0)) {
			System.debug('getData: END KO / missing input dataRequests');
            throw new dmlException('Missing input');
        }
        
        String fieldsetName =  dataRequests[0].fieldset;
		System.debug('getData: fieldsetName extracted ' + fieldsetName);        
        if (String.isBlank(fieldsetName)) {
            System.debug('getData: END KO / missing fieldSet Name ');
            throw new dmlException('Missing fieldset name');
        }
      
        // init record ID list
        Set<String> recordIDs = new Set<String>();
        for (DataRequest iter : dataRequests) {
			System.debug('getData: registering iter ' + iter);
            for (SObject iterRcd : iter.records) {
				System.debug('getData: registering record ' + iterRcd);
            	recordIDs.add(iterRcd.Id);
            }
        }                                
		System.debug('getData: recordIDs extracted ' + recordIDs);
        
        // init field api name list
        Map<String,Object> fieldSetDesc =   sfpegGetFieldSet_CTL.getFieldSetDesc(fieldsetName);
        System.debug('getData: fieldSetDesc fetched ' + fieldSetDesc);
        List<Map<String,Object>> fieldDescs = (List<Map<String,Object>>) (fieldSetDesc.get('fields'));
        System.debug('getData: fieldDescs extracted ' + fieldDescs);
        Set<String> fieldSet = new Set<String>();
        if (fieldDescs != null) {
            System.debug('getData: adding fields from fieldSet');
            for (Map<String,Object> iterField : fieldDescs) {
                System.debug('getData: processing iterField ' + iterField);
                fieldSet.add((String)(iterField.get('name')));
            }
            System.debug('getData: set of field names init ' + fieldSet);
        }
        if (!String.isBlank(dataRequests[0].fieldNames)) {
			System.debug('getData: adding special fields ' + dataRequests[0].fieldNames);
            fieldSet.addAll(dataRequests[0].fieldNames.split(','));            
        }
		System.debug('getData: set of field names finalised ' + fieldSet);
        
        // init and execute SOQL query
        String soqlQuery = 'SELECT ' + String.join(new list<String>(fieldSet),',')
            			+ ' FROM ' + fieldsetName.left(fieldsetName.indexOf('.'))
            			+ ' WHERE ID in (\'' + String.join(new List<String>(recordIDs),'\',\'') + '\')';
		System.debug('getData: soqlQuery init ' + soqlQuery);    
        
        Map<ID,SObject> resultMap = new Map<ID,SObject>(database.query(soqlQuery));
		System.debug('getData: data fetched init ' + resultMap);    
        
        // format record result list
        List<List<SObject>> resultList = new List<List<SObject>>();
        for (DataRequest iter : dataRequests) {
			System.debug('getData: finalising iter ' + iter);
            
            List<SObject> newData = new List<SObject>();    
            resultList.add(newData);
            for (SObject iterRcd : iter.records) {
                System.debug('getData: processing record ' + iterRcd);
                Sobject iterData = resultMap.get(iterRcd.Id);
                System.debug('getData: iter data fetcched ' + iterData);
            	newData.add(iterData);                
            }
        }
        
		System.debug('getData: END OK with ' + resultList);        
        return resultList;
	}   
    
/***
* @description	Subclass required to pass input parameters into the 'getData' invocable action
*               (especially to provide the fieldset name).
***/
    public class DataRequest {
  		@InvocableVariable(label='Records to Match' description='Records to match' required=true)
  		public List<SObject> records;
        @InvocableVariable(label='Fieldset' description='Fieldset to return' required=true)
  		public String fieldset;
        @InvocableVariable(label='Fields' description='Individual fields to return' required=false)
  		public String fieldNames;
  	}  
}