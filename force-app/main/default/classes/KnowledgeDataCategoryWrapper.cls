global class KnowledgeDataCategoryWrapper implements Comparable {
    public DataCategoryWrapper kdc;
    // Constructor
    public KnowledgeDataCategoryWrapper(DataCategoryWrapper dc) {
        kdc = dc;
    }
    // Compare Data Categories based on the Data Category Group Name
    global Integer compareTo(Object compareTo) {
        KnowledgeDataCategoryWrapper compareToKdc = (KnowledgeDataCategoryWrapper)compareTo;         
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (kdc.DataCategoryGroupName.compareTo(compareToKdc.kdc.DataCategoryGroupName) > 0) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (kdc.DataCategoryGroupName.compareTo(compareToKdc.kdc.DataCategoryGroupName) < 0) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        return returnValue;      
    }
}