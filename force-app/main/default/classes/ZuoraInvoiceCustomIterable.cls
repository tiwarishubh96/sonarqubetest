global class ZuoraInvoiceCustomIterable implements iterable<Zuora.zObject> {
	
	List<Zuora.zObject> zList {get;set;}

	public ZuoraInvoiceCustomIterable(){
		
	}

	public ZuoraInvoiceCustomIterable(List<Zuora.zObject> zList){
		this.zList = zList;
	}

	global Iterator<Zuora.zObject> Iterator(){
      return new ZuoraInvoiceIterable(zList);
   }

    

}