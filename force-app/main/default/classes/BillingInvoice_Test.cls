@isTest
public class BillingInvoice_Test {
	@TestSetup
	static void makeData() {

		BillingTestFactory.testCreateBilling();

		AcctSeed__GL_Account__c revenueGLAccount = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Type__c = 'Revenue' LIMIT 1];

		Product2 IFOMProduct1 = new Product2(Name = 'IFOM', IsActive = true, Recognized_Revenue_GL_Account__c = revenueGLAccount.Id);
		insert IFOMProduct1;
		System.assert(IFOMProduct1.Id != null, 'IFOMProduct1 not created');
		
		Product2Service__c p2s1 = new Product2Service__c(
			Case_Service__c = 'IFOM',  
			Product__c = IFOMProduct1.Id, 
			Default__c = true, 
			Quantity__c = 1,
			Billing_Statuses__c = 'Enrollment Verification Complete',
			Fulfillment_Statuses__c = 'Submitted',
			Rejected_Statuses__c = 'Rejected',
			Cancelled_Statuses__c = 'Resent',
			Invoiceable_Service__c = true
		);
		insert p2s1;
		System.assert(p2s1.Id != null, 'Product2Service 1 not created');
		
		Product_Detail__c pd1 = new Product_Detail__c(
			Product__c = IFOMProduct1.Id,
			Start_Date__c = Date.today().addDays(-1),
			End_Date__c = Date.today().addDays(1),
			Service_Fee__c = 1.0
		);
		insert pd1;
		System.assert(pd1.Id != null, 'Product Detail 1 not created');
		
		Product2 IFOMProduct2 = new Product2(Name = 'IFOM Fee', IsActive = true, Recognized_Revenue_GL_Account__c = revenueGLAccount.Id);
		insert IFOMProduct2;
		System.assert(IFOMProduct2.Id != null, 'IFOMProduct2 not created');
		
		Product2Service__c p2s2 = new Product2Service__c(
		Case_Service__c = 'IFOM', 
		Product__c = IFOMProduct2.Id, 
		Default__c = true, 
		Quantity__c = 1,
		Billing_Statuses__c = 'Enrollment Verification Complete',
		Fulfillment_Statuses__c = 'Submitted',
		Rejected_Statuses__c = 'Rejected',
		Cancelled_Statuses__c = 'Resent',
		Invoiceable_Service__c = true
		);
		insert p2s2;
		System.assert(p2s2.Id != null, 'Product2Service 2 not created');
		
		Product_Detail__c pd2 = new Product_Detail__c(
		Product__c = IFOMProduct2.Id,
		Start_Date__c = Date.today().addDays(-1),
		End_Date__c = Date.today().addDays(1),
		Service_Fee__c = 1.0
		);
		insert pd2;
		System.assert(pd2.Id != null, 'Product Detail 2 not created');
		
		BillingTestFactory.createIFOMCaseWithCaseLines('Entity 1', 1);
		// BillingTestFactory.createIFOMCaseWithCaseLines('Entity 2', 1);
		
		List<Case> caseList = [SELECT Id, Internal_Status__c FROM Case WHERE Case_Service__c = 'IFOM' AND Subject LIKE 'IFOM Case%'];
		List<Case_Line__c> caseLineList = [SELECT Id, Accounting_Status__c FROM Case_Line__c];
		System.assert(caseLineList != null);
		System.debug(caseLineList);
		for (Case_Line__c caseLine : caseLineList) {
			caseLine.Accounting_Status__c = 'To Invoice';
			caseLine.To_Invoice_Date__c = Date.today().toStartOfMonth().addDays(-1);
		}
		update caseLineList;
	}
	
	@IsTest
	static void testBillingInvoiceMonthlyBatch() {
		
		List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c, Case__r.Client_Account_Name__c FROM Case_Line__c WHERE Accounting_Status__c = 'To Invoice'];
		System.assert(caseLines != null);
		for (Case_Line__c caseLine : caseLines) {
			System.debug(caseLine.Case__r.Client_Account_Name__c);
		}
		Test.startTest();
		
		// ApexPages.StandardController stdCont = new ApexPages.StandardController(caseLine);
		// BillingInvoiceBatchForceStart_Extension controller = new BillingInvoiceBatchForceStart_Extension(stdCont);
		// BillingInvoiceBatchForceStart_Extension.forceStartBatch();
		
		Id jobId = Database.executeBatch(new BillingInvoiceMonthlyBatch());
		System.debug(jobId);
		Test.stopTest();
	}

	@IsTest
	static void testPDFController() {
		
		Test.startTest();
		AcctSeed__Billing__c billing = [SELECT Id FROM AcctSeed__Billing__c LIMIT 1];
		System.assert(billing != null);
		ApexPages.StandardController sc = new ApexPages.StandardController(billing);
		BillingInvoicePDFControllerExt controller = new BillingInvoicePDFControllerExt(sc);
		Test.stopTest();
		
	}

	@IsTest
	static void testBatchForceStart() {
		
		Test.startTest();
		Case_Line__c caseLine = [SELECT Id FROM Case_Line__c LIMIT 1];
		System.assert(caseLine != null);
		ApexPages.StandardController sc = new ApexPages.StandardController(caseLine);
		BillingInvoiceBatchForceStart_Extension controller = new BillingInvoiceBatchForceStart_Extension(sc);
		BillingInvoiceBatchForceStart_Extension.forceStartBatch();
		Test.stopTest();
		
	}
}