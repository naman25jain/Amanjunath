public class BillingInvoiceBatch implements Database.Batchable<BillingInvoice.ServiceInvoice>, Database.Stateful {
	// The Database.Stateful makes the variables bellow maintain their values throughout the different chunks.
    public final List<BillingInvoice.ServiceInvoice> serviceInvoices;
		public Map<Id, Product2> productsMap {get;set;}
	
	public BillingInvoiceBatch(List<BillingInvoice.ServiceInvoice> serviceInvoices, Map<Id, Product2> productsMap){
		this.serviceInvoices = serviceInvoices;
		this.productsMap = productsMap;
	}
	
	public Iterable<BillingInvoice.ServiceInvoice> start(Database.BatchableContext batchableContext){
		return this.serviceInvoices;
	}
	
	public void execute(Database.BatchableContext batchableContext, List<BillingInvoice.ServiceInvoice> scope){
		List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();
		for (BillingInvoice.ServiceInvoice serviceInvoice : serviceInvoices) {
			caseLinesToUpdate.addAll(BillingInvoice.processInvoice(serviceInvoice, productsMap));
		}
		update caseLinesToUpdate;
	}
	
	public void finish(Database.BatchableContext batchableContext){
		// finish logic
	}
}