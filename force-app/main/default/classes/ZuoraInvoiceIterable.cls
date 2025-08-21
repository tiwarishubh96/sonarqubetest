global with sharing class ZuoraInvoiceIterable implements Iterator < Zuora.zObject >{
    
    List < Zuora.zObject > zList {get;set;}

    public ZuoraInvoiceIterable(){
    	i=0;
    }

    public ZuoraInvoiceIterable(List <Zuora.zObject> zList) {
    	i=0;
    	this.zList = zList;
    }

    Integer i {get; set; }

    global boolean hasNext() {

        if (i >= zList.size()) {
            return false;
        } else {
            return true;
        }
    }

    global Zuora.zObject next() {
        
        i++;
        //system.debug('##accs[i - 1]##' + accs[i - 1]);
        return zList[i - 1];
    }


}