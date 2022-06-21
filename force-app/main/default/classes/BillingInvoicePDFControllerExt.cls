public with sharing class BillingInvoicePDFControllerExt {
	
	public final AcctSeed__Billing__c parentBilling {get;set;}
	public List<AcctSeed__Billing_Line__c> billingLines {get;set;}
	public Boolean isCurrencyFormat {get;set;}
	public String CurrencyFormat {get;set;}
	public Decimal subTotal {get;set;}
	public Decimal total {get;set;}
  
	public BillingInvoicePDFControllerExt(ApexPages.StandardController stdController) {

		this.parentBilling = (AcctSeed__Billing__c) stdController.getRecord();

		this.subTotal = 0.0;
		this.total = 0.0;

		Set<Id> billingIds = new Set<Id>();
		for (AcctSeed__Billing__c billing : [SELECT Id, AcctSeed__Sub_Total__c, AcctSeed__Total__c FROM AcctSeed__Billing__c WHERE Id = :parentBilling.Id OR Parent_Billing__c = :parentBilling.Id]) {
			billingIds.add(billing.Id);
			subTotal += billing.AcctSeed__Sub_Total__c;
			total += billing.AcctSeed__Total__c;
		}
		this.billingLines = [SELECT 
			Id,
			Name,
			AcctSeed__Product__r.Name,
			AcctSeed__Hours_Units__c,
			AcctSeed__Rate__c,
			AcctSeed__Total__c,
			Case__r.Account.Name,
			Invoiceable_Description__c
			FROM AcctSeed__Billing_Line__c 
			WHERE AcctSeed__Billing__c IN :billingIds
			ORDER BY AcctSeed__Product__r.Name];

		this.CurrencyFormat = '$#,###,###.00';
	}

	// public BillingInvoicePDFControllerExt(ApexPages.StandardController stdController) {
	// 	if(!Test.isRunningTest())
	// 	{
	// 		stdController.addFields(new List<String>{'AcctSeed__Credit_Memo_Applied_Amount__c','AcctSeed__Received_Amount__c','AcctSeed__Cash_Application_Adjustment_Amount__c'});
	// 	}
	// 	this.billing = (AcctSeed__Billing__c) stdController.getRecord();
	// 	this.billingLines = [SELECT 
	// 		id,
	// 		Name,
	// 		// Part_Number__c,
	// 		// Description__c,
	// 		// Description2__c,
	// 		AcctSeed__Hours_Units__c,
	// 		AcctSeed__Rate__c,
	// 		AcctSeed__Total__c
	// 		// Hide__c,
	// 		// CLIN__c
	// 		FROM AcctSeed__Billing_Line__c 
	// 		WHERE AcctSeed__Billing__c = :billing.id
	// 		// WHERE (AcctSeed__Billing__c = :billing.id OR AcctSeed__Billing__r.Master_Billing__c = :billing.Id)
	// 		// AND Hide__c = False
	// 		// ORDER BY CLIN__c ASC
	// 		];

	// 	this.CurrencyFormat = '$#,###,###.00';
	// 	this.NumericFormat = '#,###,###.00';
	// }
}