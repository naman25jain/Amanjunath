public class BillingInvoiceMonthlyBatch implements Database.Batchable<SObject>, Database.Stateful {
	
	public Map<Id, Map<String, List<Case_Line__c>>> caseLinesByAccountByService {get;set;}
	public List<BillingInvoice.ServiceInvoice> serviceInvoices {get;set;}
	public Map<Id, Product2> productsMap {get;set;}
	public Map<Id, Id> account2BillingContactMap {get;set;}

	public BillingInvoiceMonthlyBatch() {
		caseLinesByAccountByService = new Map<Id, Map<String, List<Case_Line__c>>>();
		serviceInvoices = new List<BillingInvoice.ServiceInvoice>();
		productsMap = new Map<Id, Product2>();
		account2BillingContactMap = new Map<Id, Id>();
	}
	
	public Database.QueryLocator start(Database.BatchableContext batchableContext) {
		Date endOfPreviousMonth = Date.today().toStartOfMonth().addDays(-1);
		Date startOfPreviousMonth = Date.today().toStartOfMonth().addDays(-1).toStartOfMonth();
		return Database.getQueryLocator([SELECT Id, Name, Accounting_Status__c, Product_ID__c, Quantity__c, Price__c, Company__c, Department__c, Case__c, 
		Case__r.AccountId, Case__r.Client_Account_Name__c, Case__r.Client_Account_Name__r.AcctSeed__Billing_Contact__c, Product2Service__r.Case_Service__c, 
		Product_Detail__r.Product__r.Recognized_Revenue_GL_Account__c, To_Invoice_Date__c 
		FROM Case_Line__c WHERE Accounting_Status__c = 'To Invoice' AND Case__r.Client_Account_Name__c != null 
		AND To_Invoice_Date__c >= :startOfPreviousMonth AND To_Invoice_Date__c <= :endOfPreviousMonth]);
	}
	
	public void execute(Database.BatchableContext batchableContext, List<Case_Line__c> scope) {

		Set<Id> productIds = new Set<Id>();
		for(Case_Line__c caseLine : scope) {
			Id accountId = caseLine.Case__r.Client_Account_Name__c;
			account2BillingContactMap.put(accountId, caseLine.Case__r.Client_Account_Name__r.AcctSeed__Billing_Contact__c);
			String service = caseLine.Product2Service__r.Case_Service__c;
			if (caseLinesByAccountByService.containsKey(accountId)) {
				Map<String, List<Case_Line__c>> servicesMap = caseLinesByAccountByService.get(accountId);
				if (servicesMap.containsKey(service)) {
					servicesMap.get(service).add(caseLine);
				} else {
					servicesMap.put(service, new List<Case_Line__c> { caseLine });
				}
			} else {
				Map<String, List<Case_Line__c>> servicesMap = new Map<String, List<Case_Line__c>> ();
				servicesMap.put(service, new List<Case_Line__c> { caseLine });
				caseLinesByAccountByService.put(accountId, servicesMap);
			}

			productIds.add(caseLine.Product_ID__c);
		}

		for (Product2 product : [SELECT Id, AcctSeed__Revenue_GL_Account__c FROM Product2 WHERE Id IN :productIds]) {
			productsMap.put(product.Id, product);
		}
	}
	
	public void finish(Database.BatchableContext batchableContext){
		if (caseLinesByAccountByService.size() > 0) {
			List<BillingInvoice.ServiceInvoice> serviceInvoices = new List<BillingInvoice.ServiceInvoice>();
			for (Id accountId : caseLinesByAccountByService.keySet()) {
				System.debug('AccountId: ' + accountId);
				Id billingContactId = account2BillingContactMap.get(accountId);
				for (String service : caseLinesByAccountByService.get(accountId).keySet()) {
					System.debug('Service: ' + service);
					List<Case_Line__c> caseLinesList = caseLinesByAccountByService.get(accountId).get(service);
					System.debug('CaseLines size: ' + caseLinesList.size());
					serviceInvoices.add(new BillingInvoice.ServiceInvoice(accountId, billingContactId, service, caseLinesList));
				}
			}
			Id jobId = Database.executeBatch(new BillingInvoiceBatch(serviceInvoices, productsMap));
		}
	}
}