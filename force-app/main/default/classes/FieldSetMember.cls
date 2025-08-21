/**
 @author Veni Korapaty (Veni.Korapaty@sage.com)
 @date 21-March-2019
 @description  Contains methods for accessing the metadata for field set member fields.
 */

//https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_class_Schema_FieldSetMember.htm
public class FieldSetMember {
    
    public FieldSetMember(Schema.FieldSetMember f) {
        this.DBRequired = f.DBRequired;
        this.fieldPath = f.fieldPath;
        this.label = f.label;
        this.required = f.required;
        this.type = '' + f.getType();
    }
    
    public FieldSetMember(Boolean DBRequired) {
        this.DBRequired = DBRequired;
    }
    
    @AuraEnabled
    public Boolean DBRequired { get;set; }
    
    @AuraEnabled
    public String fieldPath { get;set; }
    
    @AuraEnabled
    public String label { get;set; }
    
    @AuraEnabled
    public Boolean required { get;set; }
    
    @AuraEnabled
    public String type { get; set; }
}