/**
 * @description
 * Generates exceptions for test purposes on request.
 * Usually used when there is no other simple way of generating an exception (like system exceptions).
 *
 * HOW-TO
 * In the code add the following line where you want the exception to be executed:
 *
 * if(Test.isRunningTest()) TestExc.subscribe($MY_CLASS.class, 'some_meaningful_identifier');
 * 
 * Then in the test class whenever you want this exception to be thrown, add:
 *
 * TestExc.fire($MY_CLASS.class, 'same_identifier_as_above');
 *
 * @author Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
 */
@IsTest
public class TestExc
{
    public class TestException extends Exception {}
    
    private static Set<String> requestedExceptions = new Set<String>();

    public static final String EXCEPTION_PREFIX = 'Generated Test Exception: ';

    /** Use in test classes to capture exception in the catch block. */
    public static Boolean isExcThrown = false;

    /**
     * @description Places in the code exception and waits until it is requested.
     *
     * @author Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     *
     * @param classOrObjectIdentifier is unique identifier for class or object used to avoid exception name clash.
     * @param exceptionIdentifier is unique exception identifier within the same object or class.
     */
    public static void subscribe(String classOrObjectIdentifier, String exceptionIdentifier)
    {
        String completeIdentifier = classOrObjectIdentifier + '.' + exceptionIdentifier;
        if(requestedExceptions.contains(completeIdentifier))
        {
            throw new TestException(EXCEPTION_PREFIX + completeIdentifier);
        }
    }

    /**
     * @description Places in the code exception and waits until it is requested.
     *
     * @author Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     *
     * @param classIdentifier is unique identifier for class used to avoid exception name clash.
     * @param exceptionIdentifier is unique exception identifier within the same object or class.
     */
    public static void subscribe(Type classIdentifier, String exceptionIdentifier)
    {
        subscribe(classIdentifier.getName(), exceptionIdentifier);
    }

    /**
     * @description Requests exception to be invoked for specified exception identifier.
     *
     * @author Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     *
     * @param classIdentifier is unique identifier for class used to avoid exception name clash.
     * @param exceptionIdentifier is unique exception identifier within the same object or class.
     */
    public static void fire(String classOrObjectIdentifier, String exceptionIdentifier)
    {
        requestedExceptions.add(classOrObjectIdentifier + '.' + exceptionIdentifier);
    }

    /**
     * @description Requests exception to be invoked for specified exception identifier.
     *
     * @author Arturs Gusjko <arturs.gusjko@bettercloudsolutions.co.uk>
     *
     * @param classIdentifier is unique identifier for class used to avoid exception name clash.
     * @param exceptionIdentifier is unique exception identifier within the same object or class.
     */
    public static void fire(Type classIdentifier, String exceptionIdentifier)
    {
        fire(classIdentifier.getName(), exceptionIdentifier);
    }
}