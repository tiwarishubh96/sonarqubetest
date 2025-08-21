public class SageApiActivityError {
    @InvocableVariable
    public String code;
    @InvocableVariable
    public String target;
    @InvocableVariable
    public String message;

    public SageApiActivityError() {
	}
    
    public SageApiActivityError(string code, string target, string message) {
        this.code = code;
        this.target = target;
        this.message = message;
	}
}