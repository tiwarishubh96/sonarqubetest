public class SPPMQEventWrapper {
    
    public class SPPMQEventReqWrapper{
        public String eventID { get; set; }
    	public String messageType { get; set; }
        public String region { get; set; }
    }
    
    public class SPPMQEventResWrapper{
        public String eventID { get; set; }
    	public String messageType { get; set; }
        public Boolean exists { get; set; }
    }
    public class SPPMQEventReqPutWrapper{
        public String eventID { get; set; }
    	public String messageType { get; set; }
	  	public String eventSource { get; set; }
	  	public String region { get; set; }
	  	public DateTime eventDate { get; set; }
	  	public String recordType { get; set; }
	
    }
    
    /*public class SPPMQEventResPutWrapper{
        public String eventID { get; set; }
    	public String messageType { get; set; }
        public Boolean exists { get; set; }
    }*/
}