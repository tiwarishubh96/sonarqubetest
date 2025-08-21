//Simple object to track state for exceptions for easier log handling
public class TetrisDebugTraceState {
	
	private Integer defaultErrorDetailMaxLength = 131072;
	private Integer maxTraceMessagesToReturn = 10;
	private String truncatedTraceEllipsis = '...';
	
	public String currentMethod {get;set;}
	public String currentClass {get;set;}
	public String encryptedCartId {get;set;}
	public String accountId {get;set;}
	public List<String> debugTraceHistory {get;set;}		

	//Constructor	
	public TetrisDebugTraceState() {
		currentMethod = '';
		currentClass = '';
		encryptedCartId = '-unknown-';
		accountId = '-unknown-';
		debugTraceHistory = new List<String>();
	}
	
	
	//Get's the ErrorDetail (short) message
	public String getErrorDetailMessage() {
		String result = '';
		if(encryptedCartId != null && encryptedCartId.Length() > 0) {
			result = result + encryptedCartId + ' | ';
		}			
		
		if(accountId != null && accountId.Length() > 0) {
			result = result + accountId + ' | ';
		}
		
		return result;
	} 
	
	//Adds another trace message to the history list for debugging purposes
	public void addTraceHistoryMessage(String messageToAdd) {
		if(debugTraceHistory != null) {
			debugTraceHistory.add(messageToAdd);
		}
	}
	
	//Retrieve the last trace entry that was added
	public String getLastTraceEntry() {
		String result = '';
		if(debugTraceHistory != null && debugTraceHistory.size() > 0) {
			result = debugTraceHistory[debugTraceHistory.size()-1];
		}
		
		return result;
	}	
	
	//Serializes the trace history and caps it at the provided max
	// length to ensure the SF field length where the exception will 
	// be logged is not exceeded
	public String getDebugTraceHistory() {
		return getDebugTraceHistory(defaultErrorDetailMaxLength, null);
	}		

	public String getDebugTraceHistory(String lastMessageToAdd) {
		return getDebugTraceHistory(defaultErrorDetailMaxLength, lastMessageToAdd);
	}		
	
	public String getDebugTraceHistory(Integer maxLength, String lastMessageToAdd) {
		
		String result = '';
		Integer maxLengthWithoutTruncationChars = maxLength;
		Boolean limitReached = false;
		
		try {
			
			//push in the last message if one is supplied prior to processing
			if(debugTraceHistory != null && lastMessageToAdd != null) {
				debugTraceHistory.add(lastMessageToAdd);
			}
			
			//only use ellipsis if desired max length is greater than the ellipsis string length
			if(maxLength > truncatedTraceEllipsis.length()) {
				maxLengthWithoutTruncationChars = maxLength - truncatedTraceEllipsis.length();
			}
			
			//ensure we have some something to log
			if(debugTraceHistory != null && debugTraceHistory.size() > 0) {
				
				Integer messageCounter = 1;

				for(Integer i=(debugTraceHistory.size()-1); !limitReached; i--) {
					
					//Add the current debug message to the trace
					result = result + debugTraceHistory[i] + '\n';
					
					//if we reached the max number of statements to output or we've exceeded our output string length
					// then stop
					if( (messageCounter >= maxTraceMessagesToReturn) || (result.length() >= maxLengthWithoutTruncationChars) || (i <= 0) ) {
						limitReached = true;
					}
					
					messageCounter++;
				}
				
				//truncate if we are too long and we have enough space to do so
				if((result.length() >= maxLengthWithoutTruncationChars || messageCounter >= maxTraceMessagesToReturn) && 
						maxLengthWithoutTruncationChars > (truncatedTraceEllipsis.length() + 1)) {

					result = result.substring(0, maxLengthWithoutTruncationChars - 1 );

					//add ellipsis to indicate the state does not include everything
					result = result + truncatedTraceEllipsis;
				}
			}
			
		} catch (Exception ex) {
			//swallow exception here since it's logging code
		}
		
		return result;
		
	}
	
	
	//Performs a deep copy cloning operation
	public TetrisDebugTraceState getClone() {
		TetrisDebugTraceState result = new TetrisDebugTraceState();
		
		result.currentMethod = this.currentMethod;
		result.currentClass = this.currentClass;
		result.encryptedCartId = this.encryptedCartId;
		result.accountId = this.accountId;
		result.debugTraceHistory = this.debugTraceHistory.clone();	
		
		return result;
	}
	
}