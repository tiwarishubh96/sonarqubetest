/*
	Desciption : Schedule class to execute a batch job which will update Invoice number
	on Zuora invoices and its status to Posted.
 */
global class ScheduleZuoraInvoiceUpdate implements Schedulable {
	
	global void execute(SchedulableContext sc) {		
		Database.executeBatch(new ZuoraInvoiceUpdateBatch(), 50);
	}
}