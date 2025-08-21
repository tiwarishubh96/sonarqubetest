/***
* @author P-E GROS
* @date   Dec. 2020
* @description Flow Action controller class to execute a bypass of all "warn" duplicate rules
*              for simple insert / update DML operations.
**
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

public with sharing class sfpegForceDML_CTL {

/***
* @description	Invocable enabled method to force the execution of a DML, bypassing possible
*               'warn' duplicate rules.
* @param		operations		List of DmlRequests to process (each request containing a DML
*                               operation type (insert/update) and a record to process.
* @return		List<SObject>	List of records processed by the DML operation (with ID set
*                               for newly created records).
* @exception   	dmlExceptions in case of processing issue. An empty list is returned in case of
*               duplicate search issue (typically no matching rule defined on object).
***/    
        
    @InvocableMethod(label='Execute DML' description='Execute a DML while bypassing duplicate rules.' category='SF PEG')
    public static List<SObject> executeDML(List<DmlRequest> operations) {
        System.debug('executeDML: START');
        System.debug('executeDML: operations received ' + operations);
        if ((operations == null) || (operations.size() == 0)) {
			System.debug('executeDML: END KO / missing input operations');
            throw new dmlException('Missing input operations');
        }

        // Preparing the list of records per DML operation
        List<SObject> recordList = new List<SObject>();
        // map of records to process per DML operation
        Map<String,List<SObject>> operationMap = new Map<String,List<SObject>>();
        // map of indexes in the DML list per original operation index
        //Map<Integer,Integer> recordMap = new Map<Integer,Integer>();
        Integer index = 0;
        for (DmlRequest opeIter : operations) {
            System.debug('executeDML: processing operation ' + opeIter);
            System.debug('executeDML: corresponding index  ' + index);

            List<SObject> opeList = operationMap.get(opeIter.operation);
            if (opeList == null) {
                System.debug('executeDML: initializing sobject list for ' + opeIter.operation);
                opeList = new List<SObject>();
                operationMap.put(opeIter.operation, opeList);
            }

            opeList.add(opeIter.record);
            recordList.add(opeIter.record);
            //recordMap.put(index,opeList.size());
            index++;
        }
        System.debug('executeDML: operationMap init ' + operationMap);
        //System.debug('executeDML: recordMap init ' + recordMap);
        System.debug('executeDML: recordList init ' + recordList);


        // Executing the required DML operations
        Database.DMLOptions dmlHeader = new Database.DMLOptions(); 
        dmlHeader.DuplicateRuleHeader.allowSave = true;
        dmlHeader.DuplicateRuleHeader.runAsCurrentUser = true;
        System.debug('executeDML: DML header set to bypass alert duplicate rules ' + dmlHeader);

        // map of records updates/inserted per DML operation
        //Map<String,Database.SaveResult> resultMap = new Map<String,Database.SaveResult>();
        for (String dmlIter : operationMap.keySet()) {
            System.debug('executeDML: processing DML ' + dmlIter);
            List<SObject> dmlRecords = operationMap.get(dmlIter);
            System.debug('executeDML: records to processs fetched ' + dmlRecords);

            List<Database.SaveResult> saveResults;
            switch on  dmlIter {
                when 'insert' {
                    System.debug('executeDML: processing insert DML');
                    saveResults = Database.insert(dmlRecords, dmlHeader);
                }
                when 'update' {
                    System.debug('executeDML: processing update DML');
                    saveResults = Database.update(dmlRecords, dmlHeader);
                }
                when else {
                    System.debug('executeDML: unsupported DML ' + dmlIter);
                    throw new dmlException('Unsupported DML operation: ' + dmlIter); 
                }
            }
            System.debug('executeDML: DML operation executed ' + saveResults);
            for (Database.SaveResult resIter : saveResults) {
                if (resIter.isSuccess()) {
                    System.debug('executeDML: DML operation OK ' + resIter);
                }
                else {
                    System.debug('executeDML: DML operation KO ' + resIter);
                    throw new dmlException((resIter.getErrors())[0].getMessage());
                }
            }
            //System.debug('executeDML: records list ' + dmlRecords);
            //System.debug('executeDML: 1st records ID ' + saveResults[0].getId());
            //resultMap.put(dmlIter,saveResults);
        }
        //System.debug('executeDML: resultMap init ' + resultMap);

        System.debug('executeDML: END with ' + recordList);
        return recordList;
    }

    /***
    * @description	Subclass required to pass input parameters into the 'getData' invocable action
    *               (especially to provide the fieldset name).
    ***/
    public class DmlRequest {
        @InvocableVariable(label='Record' description='Record to process' required=true)
        public SObject record;
        @InvocableVariable(label='Operation' description='DML Operation to execute (insert, update)' required=true)
        public String operation;
    }
}