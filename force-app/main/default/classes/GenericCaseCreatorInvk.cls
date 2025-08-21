/**
 * @description Sends the final response email to customers.
 *
 * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 * @date        2016-05-24
 */
public without sharing class GenericCaseCreatorInvk
{

    /**
     * A wrapper for the request parameters.
     */
    public class Request
    {
        @InvocableVariable(label='Case SObject' description='Case to upsert.' required=true)
        public Case sobj;

        @InvocableVariable(label='Is Field Trancation Allowed?' description='Specifies the truncation behavior of large strings.' required=false)
        public Boolean isAllowFieldTruncation;

        @InvocableVariable(label='Assignment Rule - Id' 
            description='Specifies the ID of a specific assignment rule to run for the case or lead. The assignment rule can be active or inactive.' required=false)
        public String assignmentRuleID;
        @InvocableVariable(label='Assignment Rule - Use Default?' 
            description='If specified as true for a case or lead, the system uses the default (active) assignment rule for the case or lead. If specified, do not specify an assignmentRuleId.' required=false)
        public Boolean isAssignmentRuleUseDefault;

        @InvocableVariable(label='Duplicate Rule - Allow Save' 
            description='Indicates whether a record that’s identified as a duplicate can be saved.' required=false)
        public Boolean isDuplicateAllowSave;

        @InvocableVariable(label='Email - Trigger Auto Response?' 
            description='Indicates whether to trigger auto-response rules (true) or not (false), for leads and cases.' required=false)
        public Boolean isEmailTriggerAutoResponse;
        @InvocableVariable(label='Email - Trigger Other Email?' 
            description='Indicates whether to trigger email outside the organization (true) or not (false).' required=false)
        public Boolean isEmailTriggerOther;
        @InvocableVariable(label='Email - Trigger User Email?' 
            description='Indicates whether to trigger email that is sent to users in the organization (true) or not (false).' required=false)
        public Boolean isEmailTriggerUser;
    }

    /**
     * @description Inserts or updates provided sobject with enforced DML options.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-24
     * @param       requests is a wrapped collection of given sobject with dml options.
     */    @InvocableMethod(label='Upsert SObject' 
        description='Inserts of updates provided sobjects using DML flags.')
    static public void upsertSobject(List<Request> requests)
    {   
        List<Case> casesToUpsert = new List<Case>();
        for(Request req : requests)
        {
            reassignSObjectPicklistFiels(req);

            setRequestDefaults(req);

            casesToUpsert.add(applyDMLOptions(req));
        }
        upsert casesToUpsert;
    }

    /**
     * @description Visual workflow passes sobjects with incorrect field
     *              value types for picklists. This method attempts to reassign string values.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-24
     * @param       req is current request.
     */
    static private void reassignSObjectPicklistFiels(Request req)
    {
        SObject sobj = req.sobj;
        Map<String, Schema.SObjectField> mapFields = sobj.getSObjectType().getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : mapFields.values())
        {
            Schema.DescribeFieldResult f = sfield.getDescribe();
            // include other types as necessary
            if( new Set<Schema.DisplayType>{ Schema.DisplayType.PICKLIST }.contains(f.getType()) )
            {
                Object val = sobj.get(sfield);
                if( val != null ) sobj.put(sfield, String.valueOf(val));
            }
        }
    }

    /**
     * @description Sets defaults for user input.   
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-24
     * @param       req is currently processed request.
     */
    static private void setRequestDefaults(Request req)
    {
        if(req.isAllowFieldTruncation == null) req.isAllowFieldTruncation = false;

        if(req.isAssignmentRuleUseDefault == null) req.isAssignmentRuleUseDefault = false;

        if(req.isDuplicateAllowSave == null) req.isDuplicateAllowSave = false;

        if(req.isEmailTriggerAutoResponse == null) req.isEmailTriggerAutoResponse = false;
        if(req.isEmailTriggerOther == null) req.isEmailTriggerOther = false;
        if(req.isEmailTriggerUser == null) req.isEmailTriggerUser = false;
    }

    /**
     * @description Creates DMLOptions object based on selected options in request.
     * @author      Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     * @date        2016-05-24
     * @param       req is currently processed request.
     * @return      currently processed case with applied dml options.
     */
    static private Case applyDMLOptions(Request req)
    {
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = req.isAllowFieldTruncation;

        if( String.isNotBlank(req.assignmentRuleID) )
        {
            dmo.assignmentRuleHeader.assignmentRuleId = req.assignmentRuleID;
        }
        else
        {
            dmo.assignmentRuleHeader.useDefaultRule = req.isAssignmentRuleUseDefault;
        }

        dmo.duplicateRuleHeader.allowSave = req.isDuplicateAllowSave;

        dmo.EmailHeader.triggerAutoResponseEmail = req.isEmailTriggerAutoResponse;
        dmo.EmailHeader.triggerOtherEmail = req.isEmailTriggerOther;
        dmo.EmailHeader.triggerUserEmail = req.isEmailTriggerUser;

        req.sobj.setOptions(dmo);

        return req.sobj;
    }
}