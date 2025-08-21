@IsTest ( SeeAllData=false )
public class ExceptionLogUtility_Test {

	static testMethod void testInsertErrorLog() {

    	ExceptionLogUtility.TetrisException e = new ExceptionLogUtility.TetrisException('Test Exception');

    	String origin = 'Tetris Unit Test';
    	String objName = 'Cart';
    	String triggerName = 'Before Insert';
    	String className = 'ExceptionLogUtility_Test';
    	String method = 'testInsertErrorLog';
    	String severity = 'Low';

    	ExceptionLogUtility.insertErrorLog(e, origin, objName, triggerName,
											className, method, severity);
    }

    static testMethod void testInsertErrorLogsOverload_v1() {

    	List<ExceptionLogUtility.TetrisException> exceptions = new List<ExceptionLogUtility.TetrisException>();

    	ExceptionLogUtility.TetrisException e_1 = new ExceptionLogUtility.TetrisException('Test Exception 1');
    	ExceptionLogUtility.TetrisException e_2 = new ExceptionLogUtility.TetrisException('Test Exception 2');

    	exceptions.add(e_1);
    	exceptions.add(e_2);

    	String origin = 'Tetris Unit Test';
    	String objName = 'Cart';
    	String triggerName = 'Before Insert';
    	String className = 'ExceptionLogUtility_Test';
    	String method = 'testInsertErrorLog';
    	String severity = 'Low';

    	ExceptionLogUtility.insertErrorLogs(exceptions, origin, objName, triggerName,
											className, method, severity);
    }

    static testMethod void testInsertErrorLogsOverload_v2() {

    	List<ExceptionLogUtility.TetrisException> exceptions = new List<ExceptionLogUtility.TetrisException>();
    	

    	ExceptionLogUtility.TetrisException e_1 = new ExceptionLogUtility.TetrisException('Test Exception 1');
    	ExceptionLogUtility.TetrisException e_2 = new ExceptionLogUtility.TetrisException('Test Exception 2');

    	TetrisDebugTraceState ts = new TetrisDebugTraceState();
    	ts.currentMethod = 'testInsertErrorLogsOverload_v2';
    	ts.currentClass = 'ExceptionLogUtility_Test';

    	e_1.traceState = ts;

    	TetrisDebugTraceState debugTrace = new TetrisDebugTraceState();
        debugTrace.currentClass = 'ExceptionLogUtility_Test';

    	exceptions.add(e_1);
    	exceptions.add(e_2);

    	String origin = 'Tetris Unit Test';
    	String objName = 'Cart';
    	String triggerName = 'Before Insert';
    	String className = 'ExceptionLogUtility_Test';
    	String method = 'testInsertErrorLog';
    	String severity = 'Low';

    	ExceptionLogUtility.insertErrorLogs(exceptions, debugTrace, origin, objName, triggerName,
											className, method, severity);
    }
}