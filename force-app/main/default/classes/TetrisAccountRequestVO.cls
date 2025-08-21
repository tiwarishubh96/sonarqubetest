public class TetrisAccountRequestVO {
    
    public class Request{
        public String userLocale{set;get;}
		public String userCurrency{set;get;}
        public boolean leadCreation{set;get;}
        public boolean emailOptin {set;get;}
        public String accountName{set;get;}
        public String transactionType{set;get;}
        public String cartId{set;get;}
        public String salesOffice{set;get;}
        public TetrisContactModel contact{set;get;}
        public TetrisAddressModel billTo{set;get;}
        public boolean zuoraAccountCreation{set;get;}
        public String accountId{set;get;}
    }
    
    public class Response{
        public String success{set;get;}
        public Result result{set;get;}
        public List<Errors> errors{set;get;}
    }

    public class Errors{
        public String message{set;get;}
        public String errorCode{set;get;}
   	}    
    
    public class Result {
    	public String  accountId{set;get;}
	    public String contactId{set;get;}
    	public String leadId{set;get;}
	 	public String opportunityId{set;get;}
  		public String zuoraAccountId{set;get;}
	}
}