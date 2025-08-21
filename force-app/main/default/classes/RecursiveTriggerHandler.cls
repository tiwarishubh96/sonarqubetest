/*
 * Purpose of this class is to stop recursive triggers
 * */
public class RecursiveTriggerHandler{
    public static Boolean isFirstTime = true;
    public static Boolean isLeadConversion = false;
    public static Boolean isNotRecursive = true;
    public static Set<Id> alreadyProcessedIDs = new Set<Id>();
    public static Boolean surveysFirstCall=false;
}