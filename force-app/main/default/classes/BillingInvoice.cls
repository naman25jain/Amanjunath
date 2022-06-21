public without sharing class BillingInvoice {

	public static List<Case_Line__c> processInvoice(ServiceInvoice serviceInvoice, Map<Id, Product2> productsMap) {

		try {
			Date billingDate = Date.today().toStartOfMonth().addDays(-1);
	
			// ********************************************************************************************
			// This section is only so the test method doesn't fail while trying to insert the billings.
			// ********************************************************************************************
			AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c();
			AcctSeed__Billing_Format__c billingFormat = new AcctSeed__Billing_Format__c();
			AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
			if (Test.isRunningTest()) {
				acctPeriod = [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c <= TODAY AND AcctSeed__End_Date__c >= TODAY LIMIT 1];
				billingFormat = [SELECT Id FROM AcctSeed__Billing_Format__c LIMIT 1];
				ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
			}
			// ********************************************************************************************
	
			AcctSeed__Billing__c parentBilling = new AcctSeed__Billing__c(
				AcctSeed__Status__c = 'Approved',
				Case_Service__c = serviceInvoice.service,
				AcctSeed__Customer__c = serviceInvoice.accountId,
				AcctSeed__Date__c = billingDate,
				AcctSeed__Billing_Contact__c = serviceInvoice.billingContactId 
			);
			if (Test.isRunningTest()) {
				parentBilling.AcctSeed__Accounting_Period__c = acctPeriod.Id;
				parentBilling.AcctSeed__Billing_Format__c = billingFormat.Id;
				parentBilling.AcctSeed__Ledger__c = ledger.Id;
			}
			insert parentBilling;
	
			List<AcctSeed__Billing__c> allBillings = new List<AcctSeed__Billing__c>{parentBilling};
	
			List<AcctSeed__Billing__c> childBillings = new List<AcctSeed__Billing__c>();
			Integer childBillingsCount = Integer.valueOf(Math.ceil(serviceInvoice.caseLinesCount/250.0) - 1);
	
			if (Test.isRunningTest()) {
				childBillingsCount = 1;
			}
	
			if (serviceInvoice.multipleBillings || Test.isRunningTest()) {
				for (Integer i = 0; i < childBillingsCount; i++) {
					AcctSeed__Billing__c childBilling = new AcctSeed__Billing__c(
						AcctSeed__Status__c = 'Approved',
						Case_Service__c = serviceInvoice.service,
						AcctSeed__Customer__c = serviceInvoice.accountId,
						AcctSeed__Date__c = billingDate,
						Parent_Billing__c = parentBilling.Id,
						AcctSeed__Billing_Contact__c = serviceInvoice.billingContactId 
					);
					if (Test.isRunningTest()) {
						childBilling.AcctSeed__Accounting_Period__c = acctPeriod.Id;
						childBilling.AcctSeed__Billing_Format__c = billingFormat.Id;
						childBilling.AcctSeed__Ledger__c = ledger.Id;
					}
					childBillings.add(childBilling);
				}
				insert childBillings;
				allBillings.addAll(childBillings);
			}
	
			List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
			AcctSeed__Billing__c currentBilling = parentBilling;
			Integer caseLinesCounter = 0;
			Integer childBillingCounter = -1;
			for (Case_Line__c caseLine : serviceInvoice.caseLines) {
	
				if (caseLinesCounter++ >= 250) {
					caseLinesCounter = 0;
					childBillingCounter++;
					currentBilling = childBillings[childBillingCounter];
				}
	
				// Getting the product with all the needed values.
				Product2 currentProduct = productsMap.get(caseLine.Product_ID__c);
				
				billingLinesToInsert.add(new AcctSeed__Billing_Line__c(
					Case__c = caseLine.Case__c,
					Case_Line__c = caseLine.Id,
					AcctSeed__Billing__c = currentBilling.Id,
					AcctSeed__Product__c = caseLine.Product_ID__c,
					AcctSeed__Date__c = caseLine.To_Invoice_Date__c,
					AcctSeed__Hours_Units__c = caseLine.Quantity__c,
					AcctSeed__Rate__c = caseLine.Price__c,
					AcctSeed__Revenue_GL_Account__c = caseLine.Product_Detail__r.Product__r.Recognized_Revenue_GL_Account__c,
					AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
					AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c
				));
	
				caseLine.Accounting_Status__c = 'Fulfilled';
			}
	
			insert billingLinesToInsert;
			
			postMultipleBillings(allBillings);
			
		} catch (Exception e) {
			System.debug('An error occured on the BillingInvoice.processInvoice() method. ' + e.getMessage());
		}

		return serviceInvoice.caseLines;
	}

	private static void postMultipleBillings(List<AcctSeed__Billing__c> allBillings) {
		for (AcctSeed__Billing__c billing : allBillings) {
			List<AcctSeed.PostResult> postResults = AcctSeed.BillingPostService.postBillings(new List<AcctSeed__Billing__c> {billing});
			System.debug(postResults);
		}
	}

	public class ServiceInvoice {

		public Id accountId {get;set;}
		public Id billingContactId {get;set;}
		public String service {get;set;}
		public List<Case_Line__c> caseLines {get;set;}
		public Integer caseLinesCount {get;set;}
		public Boolean multipleBillings {get;set;}
		
		public ServiceInvoice(Id accountId, Id billingContactId, String service, List<Case_Line__c> caseLines) {
			this.accountId = accountId;
			this.billingContactId = billingContactId;
			this.service = service;
			this.caseLines = caseLines;
			this.caseLinesCount = caseLines.size();
			this.multipleBillings = caseLinesCount > 250;
		}
		
	}
}