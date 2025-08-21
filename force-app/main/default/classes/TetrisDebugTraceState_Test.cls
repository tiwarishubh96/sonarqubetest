@IsTest ( SeeAllData=false )
public class TetrisDebugTraceState_Test {
	
	static testMethod void testTetrisDebugTraceStateConstructor() {
		new TetrisDebugTraceState();
	}
	
	static testMethod void testGetErrorDetailMessage() {
		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		
		tetrisDTS.encryptedCartId = '122423434345';
		tetrisDTS.accountId = 'ACCT12345667';

		String result = tetrisDTS.getErrorDetailMessage();
	} 

	static testMethod void testAddTraceHistoryMessage() {

		List<String> strings = new List<String>();
		strings.add('string 1');

		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		tetrisDTS.debugTraceHistory = strings;

		tetrisDTS.addTraceHistoryMessage('message');
	}
	
	static testMethod void testGetLastTraceEntry() {

		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		String result = tetrisDTS.getLastTraceEntry();
		/*
		String result = '';
		if(debugTraceHistory != null && debugTraceHistory.size() > 0) {
			result = debugTraceHistory[debugTraceHistory.size()-1];
		}
		
		return result;
		*/
	}	

	static testMethod void testGetDebugTraceHistory() {
		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		tetrisDTS.getDebugTraceHistory();

		//return getDebugTraceHistory(defaultErrorDetailMaxLength, null);
	}		

	static testMethod void testGetDebugTraceHistoryOverloaded() {
		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		tetrisDTS.getDebugTraceHistory('last message');
		//return getDebugTraceHistory(defaultErrorDetailMaxLength, lastMessageToAdd);
	}		
	
	static testMethod void getDebugTraceHistory() {
		
		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		tetrisDTS.getDebugTraceHistory(1, 'last message');

		/*
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
		*/
		
	}
	
	static testMethod void testGetClone() {

		TetrisDebugTraceState tetrisDTS = new TetrisDebugTraceState();
		TetrisDebugTraceState tetrisDTS_clone = tetrisDTS.getClone();
		/*
		TetrisDebugTraceState result = new TetrisDebugTraceState();
		
		result.currentMethod = this.currentMethod;
		result.currentClass = this.currentClass;
		result.encryptedCartId = this.encryptedCartId;
		result.accountId = this.accountId;
		result.debugTraceHistory = this.debugTraceHistory.clone();	
		
		return result;
		*/
	}
}