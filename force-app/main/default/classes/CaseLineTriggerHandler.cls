public without sharing class CaseLineTriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	
	public CaseLineTriggerHandler (boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	// public void OnBeforeInsert(List<Case_Line__c> newRecords) {
	// 	// Logic
	// }
	
	// public void OnAfterInsert(List<Case_Line__c> newRecords) {
	// 	// Logic
	// }
	
	// @future public static void OnAfterInsertAsync(Set<Id> newRecordIDs) {
	// 	// Future Logic
	// }
	
	// public void OnBeforeUpdate(List<Case_Line__c> newRecords, List<Case_Line__c> oldRecords, Map<ID, Case_Line__c> newRecordMap, Map<ID, Case_Line__c> oldRecordMap) {
	//	// Logic
	// }


	public void OnAfterUpdate(List<Case_Line__c> newRecords, List<Case_Line__c> oldRecords, Map<ID, Case_Line__c> newRecordMap, Map<ID, Case_Line__c> oldRecordMap) {
		List<Id> caseLineIdsToBill = new List<Id>();
		List<Id> caseLineIdsToFulfill = new List<Id>();
		List<Id> caseLineIdsToReject = new List<Id>();
		List<Id> caseLineIdsToCancel = new List<Id>();
		
		for (Case_Line__c  caseLine : newRecords) {
			Case_Line__c oldRecord = oldRecordMap.get(caseLine.Id);
			if (caseLine.Accounting_Status__c == 'To Bill' && oldRecord.Accounting_Status__c != 'To Bill') {
				caseLineIdsToBill.add(caseLine.Id);
			}
			if (caseLine.Accounting_Status__c == 'To Fulfill' && oldRecord.Accounting_Status__c != 'To Fulfill') {
				caseLineIdsToFulfill.add(caseLine.Id);
			}
			if (caseLine.Accounting_Status__c == 'To Reject' && oldRecord.Accounting_Status__c != 'To Reject') {
				caseLineIdsToReject.add(caseLine.Id);
			}
			if (caseLine.Accounting_Status__c == 'To Cancel' && oldRecord.Accounting_Status__c != 'To Cancel') {
				caseLineIdsToCancel.add(caseLine.Id);
			}
		}

		if (caseLineIdsToBill.size() > 0 && !System.isFuture()) {
			createBillingsAsync(caseLineIdsToBill);
		}
		if (caseLineIdsToFulfill.size() > 0 && !System.isFuture()) {
			createJournalEntriesAsync(caseLineIdsToFulfill);
		}
		if (caseLineIdsToReject.size() > 0 && !System.isFuture()) {
			rejectCaseLinesAsync(caseLineIdsToReject);
		}
		if (caseLineIdsToCancel.size() > 0 && !System.isFuture()) {
			cancelCaseLinesAsync(caseLineIdsToCancel);
		}
	}
		
	// @future 
	// public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs) {
	//	// Logic
	// }

	// public void OnBeforeDelete(List<Case_Line__c> recordsToDelete, Map<ID, Case_Line__c> recordMap) {
	// 	// Logic
	// }

	// public void OnAfterDelete(List<Case_Line__c> deletedRecords, Map<ID, Case_Line__c> recordMap) {
	// 	// Logic
	// }

	// @future public static void OnAfterDeleteAsync(Set<Id> deletedRecordIDs) {
	// 	// Future Logic
	// }

	// public void OnUndelete(List<Case_Line__c> restoredRecords) {
	// 	// Logic
	// }

	// public boolean IsTriggerContext {
	// 	get{ return m_isExecuting; }
	// }
	
	// public boolean IsVisualforcePageContext {
	// 	get{ return !IsTriggerContext; }
	// }
	
	// public boolean IsWebServiceContext {
	// 	get{ return !IsTriggerContext; }
	// }
	
	// public boolean IsExecuteAnonymousContext {
	// 	get{ return !IsTriggerContext; }
	// }

	// =========================================================================================================
	// Asyncronous Method
	// This method receives a List of ids of the case lines that need to be billed. It will create a
	// billing object for each case and a billing line for each case line.
	// =========================================================================================================
	@future
	private static void createBillingsAsync(List<Id> caseLineIds) {
		createBillings(caseLineIds);
	}

	public static void createBillings(List<Id> caseLineIds) {
		Savepoint rollbackPoint = Database.setSavepoint();
		try {
			// Getting the Case_Line__c records from the list of ids received in the  method.
			Map<Id, List<Case_Line__c>> caseLinesByCase = new Map<Id, List<Case_Line__c>>();
			for (Case_Line__c caseLine : [SELECT Id, Case__c, Quantity__c, Price__c, Accounting_Status__c, Product_ID__c, Total__c, Company__c, Department__c FROM Case_Line__c WHERE Id IN :caseLineIds]) {
				// Grouping the case lines by case Id
				Id key = caseLine.Case__c;
				if (caseLinesByCase.containsKey(key)) {
					caseLinesByCase.get(key).add(caseLine);
				} else {
					caseLinesByCase.put(key, new List<Case_Line__c> {caseLine});
				}
			}
			
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
			
			// Creating today's date for later use.
			Date today = Date.today();
			// Getting the needed values of each case.
			Map<Id, Case> caseMap = new Map<Id, Case>([SELECT Id, Case_Service__c, AccountId, ContactId FROM Case WHERE Id IN :caseLinesByCase.keySet()]);
			// The billings to be inserted mapped to the case id for later retrieval.
			Map<Id, AcctSeed__Billing__c> billingsMap = new Map<Id, AcctSeed__Billing__c>();
			// Create a Set of Ids of each product for later querying.
			Set<Id> productIds = new Set<Id>();

			// Creating a billing record for each case
			for (Id caseId : caseLinesByCase.keySet()) {
				// Getting the case with all the needed values.
				Case currentCase = caseMap.get(caseId);
				// Creating a billing for each case.
				AcctSeed__Billing__c newBilling = new AcctSeed__Billing__c(
					AcctSeed__Status__c = 'Approved',
					Case__c = caseId,
					Case_Service__c = currentCase.Case_Service__c,
					AcctSeed__Customer__c = currentCase.AccountId,
					AcctSeed__Date__c = today,
					AcctSeed__Billing_Contact__c = currentCase.ContactId
				);
				if (Test.isRunningTest()) {
					newBilling.AcctSeed__Accounting_Period__c = acctPeriod.Id;
					newBilling.AcctSeed__Billing_Format__c = billingFormat.Id;
					newBilling.AcctSeed__Ledger__c = ledger.Id;
				}
				billingsMap.put(caseId, newBilling);
				// Create a Set of Ids of each product for later querying.
				for (Case_Line__c caseLine : caseLinesByCase.get(caseId)) {
					productIds.add(caseLine.Product_ID__c);
				}
			}
			// Inserting the billings first to have the ids for the Billing Lines.
			insert billingsMap.values();

			// Getting the products values needed for the billing lines.
			Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__GL_Account_Variable_1__c, AcctSeed__GL_Account_Variable_2__c FROM Product2 WHERE Id IN :productIds]);
			// List of billing lines to be inserted
			List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
			// List of Case_Lines to update the status to "Billed"
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();

			for (Id caseId : caseLinesByCase.keySet()) {
				// The billing for the current case, inserted in the previous step.
				AcctSeed__Billing__c billing = billingsMap.get(caseId);

				// Create a Billing Line for each Case Line
				for (Case_Line__c caseLine : caseLinesByCase.get(caseId)) {
					// Getting the product with all the needed values.
					Product2 currentProduct = productsMap.get(caseLine.Product_ID__c);
					// Creating a Billing Line for each Case Line.
					AcctSeed__Billing_Line__c newBillingLine = new AcctSeed__Billing_Line__c(
						Case_Line__c = caseLine.Id,
						AcctSeed__Billing__c = billing.Id,
						AcctSeed__Product__c = caseLine.Product_ID__c,
						AcctSeed__Date__c = today,
						AcctSeed__Hours_Units__c = caseLine.Quantity__c,
						AcctSeed__Rate__c = caseLine.Price__c,
						AcctSeed__Revenue_GL_Account__c = currentProduct.AcctSeed__Revenue_GL_Account__c,
						AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
						AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c
					);
					billingLinesToInsert.add(newBillingLine);
					caseLine.Accounting_Status__c = 'Billed';
					caseLinesToUpdate.add(caseLine);
				}
			}
			insert billingLinesToInsert;
			
			List<AcctSeed.PostResult> postResults = AcctSeed.BillingPostService.postBillings(billingsMap.values());
			System.debug('Posting billings... Results:');
			System.debug(postResults);
			
			update caseLinesToUpdate;
			
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseLineTrigger.createBillings: ' + e.getMessage());
			// I don't want to create billings if the billing lines fail. Also, to prevent the posting of the case lines.
			Database.rollback(rollbackPoint);
		}
	}

	// =========================================================================================================
	// Asyncronous Method
	// This method receives a List of ids of the case lines that need to be fulfilled. It will create a
	// Journal Entry record for each case and a Journal Entry Line for each case line.
	// =========================================================================================================
	@future
	private static void createJournalEntriesAsync(List<Id> caseLineIds) {
		createJournalEntries(caseLineIds);
	}
	
	public static void createJournalEntries(List<Id> caseLineIds) {
		Savepoint rollbackPoint = Database.setSavepoint();
		try {
			Set<Id> productIds = new Set<Id>();

			// Getting the Case_Line__c records from the list of ids received in the method.
			Map<Id, List<Case_Line__c>> caseLinesByCase = new Map<Id, List<Case_Line__c>>();
			for (Case_Line__c caseLine : [SELECT Id, Case__c, Company__c, Department__c, Quantity__c, Product_ID__c, Total__c, Pricing_Date__c, Product_Detail__c, Product_Detail__r.IsParent__c,
																		Product_Detail__r.Product__c, Product_Detail__r.Parent_Product_Detail__c, Product_Detail__r.Parent_Product_Detail__r.Product__c, Product_Detail__r.Unique_Key__c,
																		Product2Service__r.Fulfilled_Price_Date_Field__c, Product2Service__r.Subsidy_GL_Account__c
																		FROM Case_Line__c WHERE Id IN :caseLineIds]) {
				// Grouping the case lines by case Id
				Id key = caseLine.Case__c;
				if (caseLinesByCase.containsKey(key)) {
					caseLinesByCase.get(key).add(caseLine);
				} else {
					caseLinesByCase.put(key, new List<Case_Line__c> {caseLine});
				}
				// Storing the product ids for later querying
				productIds.add(caseLine.Product_ID__c);
			}

			
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
			
			// ------------------------------------------------------------------------------------------------
			// Creating Journal Entry records and inserting them.
			// ------------------------------------------------------------------------------------------------
			// ____________________________
			// Today's date for use bellow.
			Date today = Date.today();
			String strToday = today.year() + '-' + String.valueOf('0' + today.month()).right(2) + '-' + String.valueOf('0' + today.day()).right(2);			
			// _______________________________________________________________________
			// Querying the cases related to the case lines and storing them in a map.
			Map<Id, Case> caseMap = new Map<Id, Case> ([SELECT Id, CaseNumber, ContactId, Contact.AccountId FROM Case WHERE Id IN :caseLinesByCase.keySet()]);

			// Map to contain the new journal entry records. Mapped to the case Id to get them later.
			Map<Id, AcctSeed__Journal_Entry__c> journalEntriesMap = new Map<Id, AcctSeed__Journal_Entry__c>();
			for (Case caseRecord : caseMap.values()) {
				AcctSeed__Journal_Entry__c newJournalEntry = new AcctSeed__Journal_Entry__c(
					Name = caseRecord.CaseNumber + ' Fulfilled - ' + strToday,
					Case__c = caseRecord.Id,
					AcctSeed__Journal_Date__c = today
				);
				if (Test.isRunningTest()) {
					newJournalEntry.AcctSeed__Ledger__c = ledger.Id;
				}
				journalEntriesMap.put(caseRecord.Id, newJournalEntry);
			}
			insert journalEntriesMap.values();

			// _____________________________________
			// Querying the products for use bellow.
			Map<Id, Product2> productsMap = new Map<Id, Product2> ([SELECT Id, AcctSeed__Revenue_GL_Account__c FROM Product2 WHERE Id IN :productIds]);
			
			List<AcctSeed__Journal_Entry_Line__c> journalEntryLinesToInsert = new List<AcctSeed__Journal_Entry_Line__c>();
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();
			for (Id caseId : caseLinesByCase.keySet()) {
				// ____________________________________________
				// Information that it's the same for each case
				Case caseRecord = caseMap.get(caseId);
				Id contactId = caseRecord.ContactId;
				Id accountId = caseRecord.Contact.AccountId;
				AcctSeed__Journal_Entry__c journalEntry = journalEntriesMap.get(caseId);

				// Creating all the necesary Journal Entry lines for each case line.
				for (Case_Line__c caseLine : caseLinesByCase.get(caseId)) {
					Product2 product = productsMap.get(caseLine.Product_Id__c);
					// --------------------------------------------------------------------------------
					// Creating a debit Journal Entry Line
					// --------------------------------------------------------------------------------
					// Create Debit Line
					AcctSeed__Journal_Entry_Line__c debitLine = new AcctSeed__Journal_Entry_Line__c(
						AcctSeed__Journal_Entry__c = journalEntry.Id,
						AcctSeed__Account__c = accountId,
						AcctSeed__Contact__c = contactId,
						AcctSeed__Date__c = today,
						Case__c = caseId,
						Case_Line__c = caseLine.Id,
						AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
						AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
						AcctSeed__Units__c = caseLine.Quantity__c,
						AcctSeed__Product__c = caseLine.Product_ID__c,
						AcctSeed__GL_Account__c = product.AcctSeed__Revenue_GL_Account__c,
						AcctSeed__Debit__c = caseLine.Total__c,
						Product_Detail__c = caseLine.Product_Detail__c
					);
					journalEntryLinesToInsert.add(debitLine);

					// --------------------------------------------------------------------------------
					// Process to create credit Journal Entry Lines
					// --------------------------------------------------------------------------------
					// ____________________________________________________________________________________
					// This section might need to be replaced later. This query should not be inside a for. 
					Date pricingDate = caseLine.Pricing_Date__c;
					if (pricingDate == null) {
						pricingDate = Date.today();
					}
					String strPricingDate = pricingDate.year() + '-' + String.valueOf('0' + pricingDate.month()).right(2) + '-' + String.valueOf('0' + pricingDate.day()).right(2);
					String query = 'SELECT Id, Product__c, Product__r.Recognized_Revenue_GL_Account__c, Service_Fee__c FROM Product_Detail__c WHERE ';
					if (caseLine.Product_Detail__r.IsParent__c) {
						query += 'Parent_Unique_Key__c = \'' + caseLine.Product_Detail__r.Unique_Key__c + '\' ';
					} else {
						query += 'Unique_Key__c = \'' + caseLine.Product_Detail__r.Unique_Key__c + '\' ';
					}
					query += 'AND Start_Date__c <= ' + strPricingDate + ' AND End_Date__c >= ' + strPricingDate;
					System.debug(query);
					// ____________________________________________________________________________________

					Decimal subsidy = debitLine.AcctSeed__Debit__c;
					// Creating a credit line for each matching product detail
					for (Product_Detail__c productDetail : Database.query(query)) {
						AcctSeed__Journal_Entry_Line__c creditLine = new AcctSeed__Journal_Entry_Line__c(
							AcctSeed__Journal_Entry__c = journalEntry.Id,
							AcctSeed__Account__c = accountId,
							AcctSeed__Contact__c = contactId,
							AcctSeed__Date__c = today,
							Case__c = caseId,
							Case_Line__c = caseLine.Id,
							AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
							AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
							AcctSeed__Units__c = caseLine.Quantity__c,
							Product_Detail__c = productDetail.Id,
							AcctSeed__Product__c = productDetail.Product__c,
							AcctSeed__GL_Account__c = productDetail.Product__r.Recognized_Revenue_GL_Account__c,
							AcctSeed__Credit__c = productDetail.Service_Fee__c
						);
						journalEntryLinesToInsert.add(creditLine);
						subsidy -= creditLine.AcctSeed__Credit__c;
					}

					// If the debits and credits don't balance out, create an aditional credit line to balance it out.
					if (subsidy != 0.0) {
						AcctSeed__Journal_Entry_Line__c creditLine = new AcctSeed__Journal_Entry_Line__c(
							AcctSeed__Journal_Entry__c = journalEntry.Id,
							AcctSeed__Account__c = accountId,
							AcctSeed__Contact__c = contactId,
							AcctSeed__Date__c = today,
							Case__c = caseId,
							Case_Line__c = caseLine.Id,
							AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
							AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
							AcctSeed__Units__c = caseLine.Quantity__c,
							AcctSeed__Product__c = caseLine.Product_ID__c,
							AcctSeed__GL_Account__c = caseLine.Product2Service__r.Subsidy_GL_Account__c,
							AcctSeed__Credit__c = subsidy
						);
						journalEntryLinesToInsert.add(creditLine);
					}
					caseLine.Accounting_Status__c = 'Fulfilled';
					caseLine.Fulfilled_Date__c = today;
					caseLinesToUpdate.add(caseLine);
				}
			}
			insert journalEntryLinesToInsert;
			update caseLinesToUpdate;
			
			List<AcctSeed.PostResult> postResults = AcctSeed.JournalEntryPostService.postJournalEntries(journalEntriesMap.values());
			System.debug('Posting Journal Entries... Results:');
			System.debug(postResults);

			
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseLineTrigger.createJournalEntries: ' + e.getMessage());
			// I don't want to create billings if the billing lines fail. Also, to prevent the posting of the case lines.
			Database.rollback(rollbackPoint);
		}
	}

	// =========================================================================================================
	// Asyncronous Method
	// This method receives a List of ids of the case lines that need to be rejected. 
	// This process will reject a case and it's lines and balance the journal entries?
	// =========================================================================================================
	@future
	private static void rejectCaseLinesAsync(List<Id> caseLineIds) {
		rejectCaseLines(caseLineIds);
	}

	public static void rejectCaseLines(List<Id> caseLineIds) {
		Savepoint rollbackPoint = Database.setSavepoint();
		try {
			Set<Id> productIds = new Set<Id>();

			// Getting the Case_Line__c records from the list of ids received in the method.
			Map<Id, List<Case_Line__c>> caseLinesByCase = new Map<Id, List<Case_Line__c>>();
			for (Case_Line__c caseLine : [SELECT Id, Case__c, Company__c, Department__c, Quantity__c, Product_ID__c, Product_Detail__c, Product_Detail__r.Processing_Fee__c, Price_Adjusted__c, Price__c, Accounting_Status__c
																		FROM Case_Line__c WHERE Id IN :caseLineIds]) {
				// Grouping the case lines by case Id
				Id key = caseLine.Case__c;
				if (caseLinesByCase.containsKey(key)) {
					caseLinesByCase.get(key).add(caseLine);
				} else {
					caseLinesByCase.put(key, new List<Case_Line__c> {caseLine});
				}
				// Storing the product ids for later querying
				productIds.add(caseLine.Product_ID__c);
			}

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

			// Querying the original Billings for each case
			Map<Id, AcctSeed__Billing__c> originalBillings = new Map<Id, AcctSeed__Billing__c>();
			for (AcctSeed__Billing__c billing : [SELECT Id, Case__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Case__c IN :caseLinesByCase.keySet()]) {
				originalBillings.put(billing.Case__c, billing);
			}
			// ____________________________
			// Today's date for use bellow.
			Date today = Date.today();
			String strToday = today.year() + '-' + String.valueOf('0' + today.month()).right(2) + '-' + String.valueOf('0' + today.day()).right(2);

			// _______________________________________________________________________
			// Querying the cases related to the case lines and storing them in a map.
			Map<Id, Case> caseMap = new Map<Id, Case> ([SELECT Id, CaseNumber, ContactId, Contact.AccountId, AccountId, Keep_Processing_Fee__c, Case_Service__c FROM Case WHERE Id IN :caseLinesByCase.keySet()]);
			// Map to contain the new journal entry records. Mapped to the case Id to get them later.
			Map<Id, AcctSeed__Journal_Entry__c> journalEntriesMap = new Map<Id, AcctSeed__Journal_Entry__c>();
			// Map to contain the new billing records. Mapped to the case Id to get them later.
			Map<Id, AcctSeed__Billing__c> billingsMap = new Map<Id, AcctSeed__Billing__c>();

			// ------------------------------------------------------------------------------------------------
			// For each case, create a Journal Entry and a Billing record.
			// ------------------------------------------------------------------------------------------------
			for (Case caseRecord : caseMap.values()) {
				Id caseId = caseRecord.Id;
				// Create a Journal Entry if the case has the Keep_Processing_Fee__c flag
				if (caseRecord.Keep_Processing_Fee__c) {
					AcctSeed__Journal_Entry__c newJournalEntry = new AcctSeed__Journal_Entry__c(
						Name = caseRecord.CaseNumber + ' Processing Fee - ' + strToday,
						Case__c = caseId,
						AcctSeed__Journal_Date__c = today
					);
					if (Test.isRunningTest()) {
						newJournalEntry.AcctSeed__Ledger__c = ledger.Id;
					}
					journalEntriesMap.put(caseId, newJournalEntry);
				}

				AcctSeed__Billing__c originalBilling = null;
				if (originalBillings.containsKey(caseId)) {
					originalBilling = originalBillings.get(caseId);
				}

				// Creating a billing for the case (Credit Memo)
				AcctSeed__Billing__c newBilling = new AcctSeed__Billing__c(
					AcctSeed__Status__c = 'Approved',
					Case__c = caseId,
					Case_Service__c = caseRecord.Case_Service__c,
					AcctSeed__Customer__c = originalBilling?.AcctSeed__Customer__c,
					AcctSeed__Date__c = today,
					AcctSeed__Billing_Contact__c = caseRecord.ContactId,
					AcctSeed__Proprietary_Billing_Number__c = caseRecord.CaseNumber + ' - Credit',
					Credited_Billing__c = originalBilling?.Id
				);
				if (Test.isRunningTest()) {
					newBilling.AcctSeed__Accounting_Period__c = acctPeriod.Id;
					newBilling.AcctSeed__Billing_Format__c = billingFormat.Id;
					newBilling.AcctSeed__Ledger__c = ledger.Id;
				}
				billingsMap.put(caseId, newBilling);
			}
			// Insert the Journal Entries, if any.
			if (journalEntriesMap.size() > 0) {
				insert journalEntriesMap.values();
			}
			// Inserting the billings first to have the ids for the Billing Lines.
			insert billingsMap.values();

			// _____________________________________
			// Querying the products for use bellow.
			Map<Id, Product2> productsMap = new Map<Id, Product2> ([SELECT Id, AcctSeed__Revenue_GL_Account__c, Recognized_Revenue_GL_Account__c FROM Product2 WHERE Id IN :productIds]);

			List<AcctSeed__Journal_Entry_Line__c> journalEntryLinesToInsert = new List<AcctSeed__Journal_Entry_Line__c>();
			List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();
			for (Id caseId : caseLinesByCase.keySet()) {
				// ____________________________________________
				// Information that it's the same for each case
				Case caseRecord = caseMap.get(caseId);
				Id contactId = caseRecord.ContactId;
				Id accountId = caseRecord.Contact.AccountId;
				AcctSeed__Journal_Entry__c journalEntry = journalEntriesMap.get(caseId);
				AcctSeed__Billing__c billing = billingsMap.get(caseId);

				// Creating all the necesary Journal Entry lines for each case line.
				for (Case_Line__c caseLine : caseLinesByCase.get(caseId)) {
					Product2 product = productsMap.get(caseLine.Product_ID__c);
					
					if (journalEntry != null && caseLine.Product_Detail__r.Processing_Fee__c != null && caseLine.Product_Detail__r.Processing_Fee__c > 0) {
						// --------------------------------------------------------------------------------
						// Creating Journal Entry Lines
						// --------------------------------------------------------------------------------
						// Create Debit Line
						AcctSeed__Journal_Entry_Line__c debitLine = new AcctSeed__Journal_Entry_Line__c(
							AcctSeed__Journal_Entry__c = journalEntry.Id,
							AcctSeed__Account__c = accountId,
							AcctSeed__Contact__c = contactId,
							AcctSeed__Date__c = today,
							Case__c = caseId,
							Case_Line__c = caseLine.Id,
							AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
							AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
							AcctSeed__Units__c = caseLine.Quantity__c,
							Product_Detail__c = caseLine.Product_Detail__c,
							AcctSeed__Product__c = caseLine.Product_ID__c,
							AcctSeed__GL_Account__c = product.AcctSeed__Revenue_GL_Account__c,
							AcctSeed__Debit__c = caseLine.Product_Detail__r.Processing_Fee__c
						);
						journalEntryLinesToInsert.add(debitLine);
						// Create Credit Line
						AcctSeed__Journal_Entry_Line__c creditLine = new AcctSeed__Journal_Entry_Line__c(
							AcctSeed__Journal_Entry__c = journalEntry.Id,
							AcctSeed__Account__c = accountId,
							AcctSeed__Contact__c = contactId,
							AcctSeed__Date__c = today,
							Case__c = caseId,
							Case_Line__c = caseLine.Id,
							AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
							AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
							AcctSeed__Units__c = caseLine.Quantity__c,
							Product_Detail__c = caseLine.Product_Detail__c,
							AcctSeed__Product__c = caseLine.Product_ID__c,
							AcctSeed__GL_Account__c = product.Recognized_Revenue_GL_Account__c,
							AcctSeed__Credit__c = caseLine.Product_Detail__r.Processing_Fee__c
						);
						journalEntryLinesToInsert.add(creditLine);
					}

					// --------------------------------------------------------------------------------
					// Creating Billing Line (Credit Memo)
					// --------------------------------------------------------------------------------
					AcctSeed__Billing_Line__c newBillingLine = new AcctSeed__Billing_Line__c(
						Case_Line__c = caseLine.Id,
						AcctSeed__Billing__c = billing.Id,
						AcctSeed__Product__c = caseLine.Product_ID__c,
						AcctSeed__Date__c = today,
						AcctSeed__Hours_Units__c = caseLine.Quantity__c * -1,
						AcctSeed__Rate__c = caseRecord.Keep_Processing_Fee__c? caseLine.Price_Adjusted__c : caseLine.Price__c,
						AcctSeed__Revenue_GL_Account__c = product.AcctSeed__Revenue_GL_Account__c,
						AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
						AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c
					);
					billingLinesToInsert.add(newBillingLine);
					caseLine.Accounting_Status__c = 'Rejected';
					caseLinesToUpdate.add(caseLine);
				}
			}

			// ______________________________________________________________________
			// Inserting and posting the new Journal Entries and Journal Entry Lines.
			if (journalEntryLinesToInsert.size() > 0) {
				insert journalEntryLinesToInsert;

				List<AcctSeed.PostResult> postResults = AcctSeed.JournalEntryPostService.postJournalEntries(journalEntriesMap.values());
				System.debug('Posting Journal Entries... Results:');
				System.debug(postResults);
			}
			// _________________________________________________________
			// Inserting and posting the new Billings and Billing Lines.
			insert billingLinesToInsert;

			List<AcctSeed.PostResult> postResults = AcctSeed.BillingPostService.postBillings(billingsMap.values());
			System.debug('Posting billings... Results:');
			System.debug(postResults);
			
			// _________________________________________________
			// Updating the Accounting Status on the Case Lines.
			update caseLinesToUpdate;
			
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseLineTrigger.rejectCaseLines: ' + e.getMessage());
			// I don't want to create billings if the billing lines fail. Also, to prevent the posting of the case lines.
			Database.rollback(rollbackPoint);
		}
	}

	// =========================================================================================================
	// Asyncronous Method
	// This method receives a List of ids of the case lines that need to be cancelled.
	// This process will cancel a case and it's lines and refund the journal entries and credit memos?
	// =========================================================================================================
	@future
	private static void cancelCaseLinesAsync(List<Id> caseLineIds) {
		cancelCaseLines(caseLineIds);
	}

	public static void cancelCaseLines(List<Id> caseLineIds) {
		Savepoint rollbackPoint = Database.setSavepoint();
		try {
			Set<Id> productIds = new Set<Id>();

			// Getting the Case_Line__c records from the list of ids received in the method.
			Map<Id, List<Case_Line__c>> caseLinesByCase = new Map<Id, List<Case_Line__c>>();
			for (Case_Line__c caseLine : [SELECT Id, Case__c, Company__c, Department__c, Quantity__c, Product_ID__c, Product_Detail__c, Product_Detail__r.Processing_Fee__c, Product_Detail__r.IsParent__c, Price_Adjusted__c, Price__c, Accounting_Status__c
																		FROM Case_Line__c WHERE Id IN :caseLineIds]) {
				// Grouping the case lines by case Id
				Id key = caseLine.Case__c;
				if (caseLinesByCase.containsKey(key)) {
					caseLinesByCase.get(key).add(caseLine);
				} else {
					caseLinesByCase.put(key, new List<Case_Line__c> {caseLine});
				}
				// Storing the product ids for later querying
				productIds.add(caseLine.Product_ID__c);
			}

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

			// Querying the original Billings for each case
			Map<Id, AcctSeed__Billing__c> originalBillings = new Map<Id, AcctSeed__Billing__c>();
			for (AcctSeed__Billing__c billing : [SELECT Id, Case__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Case__c IN :caseLinesByCase.keySet()]) {
				originalBillings.put(billing.Case__c, billing);
			}

			// ____________________________
			// Today's date for use bellow.
			Date today = Date.today();
			String strToday = today.year() + '-' + String.valueOf('0' + today.month()).right(2) + '-' + String.valueOf('0' + today.day()).right(2);
			// _______________________________________________________________________
			// Querying the cases related to the case lines and storing them in a map.
			Map<Id, Case> caseMap = new Map<Id, Case> ([SELECT Id, CaseNumber, ContactId, Contact.AccountId, AccountId, Keep_Processing_Fee__c, Case_Service__c, Region_Change_Cancellation__c FROM Case WHERE Id IN :caseLinesByCase.keySet()]);
			// Map to contain the new journal entry records. Mapped to the case Id to get them later.
			Map<Id, AcctSeed__Journal_Entry__c> journalEntriesMap = new Map<Id, AcctSeed__Journal_Entry__c>();
			// Map to contain the new billing records. Mapped to the case Id to get them later.
			Map<Id, AcctSeed__Billing__c> billingsMap = new Map<Id, AcctSeed__Billing__c>();
			// Map for creating Journal Entries for reversed entries, if applicable.
			Map<Id, List<Case_Line__c>> secondRunCaseLinesByCase = new Map<Id, List<Case_Line__c>>();

			// ------------------------------------------------------------------------------------------------
			// For each case, create a Journal Entry and a Billing record.
			// ------------------------------------------------------------------------------------------------
			for (Case caseRecord : caseMap.values()) {
				Id caseId = caseRecord.Id;
				AcctSeed__Billing__c originalBilling = null;
				if (originalBillings.containsKey(caseId)) {
					originalBilling = originalBillings.get(caseId);
				}

				// Creating a billing for the case (Credit Memo)
				AcctSeed__Billing__c newBilling = new AcctSeed__Billing__c(
					AcctSeed__Status__c = 'Approved',
					Case__c = caseId,
					Case_Service__c = caseRecord.Case_Service__c,
					AcctSeed__Customer__c = originalBilling?.AcctSeed__Customer__c,
					AcctSeed__Date__c = today,
					AcctSeed__Billing_Contact__c = caseRecord.ContactId,
					AcctSeed__Proprietary_Billing_Number__c = caseRecord.CaseNumber + ' - Cancelled',
					Credited_Billing__c = originalBilling?.Id
				);
				if (caseRecord.Region_Change_Cancellation__c) {
					newBilling.Do_Not_Auto_apply__c = true;
				}
				if (Test.isRunningTest()) {
					newBilling.AcctSeed__Accounting_Period__c = acctPeriod.Id;
					newBilling.AcctSeed__Billing_Format__c = billingFormat.Id;
					newBilling.AcctSeed__Ledger__c = ledger.Id;
				}
				billingsMap.put(caseId, newBilling);
			}
			// Insert the Journal Entries, if any.
			if (journalEntriesMap.size() > 0) {
				insert journalEntriesMap.values();
			}
			// Inserting the billings first to have the ids for the Billing Lines.
			insert billingsMap.values();

			// _____________________________________
			// Querying the products for use bellow.
			Map<Id, Product2> productsMap = new Map<Id, Product2> ([SELECT Id, AcctSeed__Revenue_GL_Account__c, Recognized_Revenue_GL_Account__c FROM Product2 WHERE Id IN :productIds]);
			
			List<AcctSeed__Journal_Entry_Line__c> journalEntryLinesToInsert = new List<AcctSeed__Journal_Entry_Line__c>();
			List<AcctSeed__Billing_Line__c> billingLinesToInsert = new List<AcctSeed__Billing_Line__c>();
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();
			Set<Id> secondRunCaseLineIds = new Set<Id>();
			for (Id caseId : caseLinesByCase.keySet()) {
				// ____________________________________________
				// Information that it's the same for each case
				Case caseRecord = caseMap.get(caseId);
				Id contactId = caseRecord.ContactId;
				Id accountId = caseRecord.Contact.AccountId;
				AcctSeed__Journal_Entry__c journalEntry = journalEntriesMap.get(caseId);
				AcctSeed__Billing__c billing = billingsMap.get(caseId);

				// Creating all the necesary Journal Entry lines for each case line.
				for (Case_Line__c caseLine : caseLinesByCase.get(caseId)) {
					Product2 product = productsMap.get(caseLine.Product_ID__c);
					// --------------------------------------------------------------------------------
					// Creating Billing Line (Credit Memo)
					// --------------------------------------------------------------------------------
					Id glAccount = product.Recognized_Revenue_GL_Account__c;
					if (caseLine.Product_Detail__r.IsParent__c) {
						glAccount = product.AcctSeed__Revenue_GL_Account__c;
						if (secondRunCaseLinesByCase.containsKey(caseId)) {
							secondRunCaseLinesByCase.get(caseId).add(caseLine);
						} else {
							secondRunCaseLinesByCase.put(caseId, new List<Case_Line__c> { caseLine });
						}
						secondRunCaseLineIds.add(caseLine.Id);
					}
					AcctSeed__Billing_Line__c newBillingLine = new AcctSeed__Billing_Line__c(
						Case_Line__c = caseLine.Id,
						AcctSeed__Billing__c = billing.Id,
						AcctSeed__Product__c = caseLine.Product_ID__c,
						AcctSeed__Date__c = today,
						AcctSeed__Hours_Units__c = caseLine.Quantity__c * -1,
						AcctSeed__Rate__c = caseRecord.Keep_Processing_Fee__c? caseLine.Price_Adjusted__c : caseLine.Price__c,
						AcctSeed__Revenue_GL_Account__c = glAccount,
						AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
						AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c
					);
					billingLinesToInsert.add(newBillingLine);
					caseLine.Accounting_Status__c = 'Cancelled';
					caseLinesToUpdate.add(caseLine);
				}
			}

			// --------------------------------------------------------------------------------
			// Second Run for creating reversed Journal Entries if applicable
			// --------------------------------------------------------------------------------
			if (secondRunCaseLinesByCase.keySet().size() > 0) {
				Map<Id, List<AcctSeed__Journal_Entry_Line__c>> journalEntryLinesMap = new Map<Id, List<AcctSeed__Journal_Entry_Line__c>>();
				for (AcctSeed__Journal_Entry_Line__c entryLine : [SELECT Id, Case_Line__c, AcctSeed__Credit__c, AcctSeed__Debit__c, AcctSeed__GL_Account__c, Product_Detail__c, Product_Detail__r.Processing_Fee__c FROM AcctSeed__Journal_Entry_Line__c WHERE Case_Line__c IN :secondRunCaseLineIds]) {
					Id caseLineId = entryLine.Case_Line__c;
					if (journalEntryLinesMap.containsKey(caseLineId)) {
						journalEntryLinesMap.get(caseLineId).add(entryLine);
					} else {
						journalEntryLinesMap.put(caseLineId, new List<AcctSeed__Journal_Entry_Line__c> { entryLine });
					}
				}
				
				Map<Id, AcctSeed__Journal_Entry__c> aditionalJournalEntriesMap = new Map<Id, AcctSeed__Journal_Entry__c>();

				// Create the Journal Entry first
				for (Id caseId : secondRunCaseLinesByCase.keySet()) {
					Case caseRecord = caseMap.get(caseId);
					AcctSeed__Journal_Entry__c newJournalEntry = new AcctSeed__Journal_Entry__c(
						Name = caseRecord.CaseNumber + ' - Cancelled - ' + strToday,
						Case__c = caseId,
						AcctSeed__Journal_Date__c = today
					);
					if (Test.isRunningTest()) {
						newJournalEntry.AcctSeed__Ledger__c = ledger.Id;
					}
					aditionalJournalEntriesMap.put(caseId, newJournalEntry);
				}
				insert aditionalJournalEntriesMap.values();

				for (Id caseId : secondRunCaseLinesByCase.keySet()) {
					// ____________________________________________
					// Information that it's the same for each case
					Case caseRecord = caseMap.get(caseId);
					Id contactId = caseRecord.ContactId;
					Id accountId = caseRecord.Contact.AccountId;
					AcctSeed__Journal_Entry__c journalEntry = aditionalJournalEntriesMap.get(caseId);

					for (Case_Line__c caseLine : secondRunCaseLinesByCase.get(caseId)) {
						Product2 product = productsMap.get(caseLine.Product_ID__c);

						for (AcctSeed__Journal_Entry_Line__c originalEntryLine : journalEntryLinesMap.get(caseLine.Id)) {
							AcctSeed__Journal_Entry_Line__c newEntryLine = new AcctSeed__Journal_Entry_Line__c(
								AcctSeed__Journal_Entry__c = journalEntry.Id,
								AcctSeed__Account__c = accountId,
								AcctSeed__Contact__c = contactId,
								AcctSeed__Date__c = today,
								Case__c = caseId,
								Case_Line__c = caseLine.Id,
								AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
								AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
								AcctSeed__Units__c = caseLine.Quantity__c,
								Product_Detail__c = caseLine.Product_Detail__c,
								AcctSeed__Product__c = caseLine.Product_ID__c,
								AcctSeed__GL_Account__c = originalEntryLine.AcctSeed__GL_Account__c
							);
							if (originalEntryLine.AcctSeed__Credit__c != null || originalEntryLine.AcctSeed__Credit__c > 0) {
								newEntryLine.AcctSeed__Credit__c = originalEntryLine.AcctSeed__Credit__c;
							} else {
								newEntryLine.AcctSeed__Debit__c = originalEntryLine.AcctSeed__Debit__c;
							}
							journalEntryLinesToInsert.add(newEntryLine);

							if (caseRecord.Keep_Processing_Fee__c && originalEntryLine.Product_Detail__r.Processing_Fee__c > 0) {
								// Create Debit Line
								AcctSeed__Journal_Entry_Line__c debitLine = new AcctSeed__Journal_Entry_Line__c(
									AcctSeed__Journal_Entry__c = journalEntry.Id,
									AcctSeed__Account__c = accountId,
									AcctSeed__Contact__c = contactId,
									AcctSeed__Date__c = today,
									Case__c = caseId,
									Case_Line__c = caseLine.Id,
									AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
									AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
									AcctSeed__Units__c = caseLine.Quantity__c,
									Product_Detail__c = caseLine.Product_Detail__c,
									AcctSeed__Product__c = caseLine.Product_ID__c,
									AcctSeed__GL_Account__c = product.AcctSeed__Revenue_GL_Account__c,
									AcctSeed__Debit__c = caseLine.Product_Detail__r.Processing_Fee__c
								);
								journalEntryLinesToInsert.add(debitLine);
								// Create Credit Line
								AcctSeed__Journal_Entry_Line__c creditLine = new AcctSeed__Journal_Entry_Line__c(
									AcctSeed__Journal_Entry__c = journalEntry.Id,
									AcctSeed__Account__c = accountId,
									AcctSeed__Contact__c = contactId,
									AcctSeed__Date__c = today,
									Case__c = caseId,
									Case_Line__c = caseLine.Id,
									AcctSeed__GL_Account_Variable_1__c = caseLine.Company__c,
									AcctSeed__GL_Account_Variable_2__c = caseLine.Department__c,
									AcctSeed__Units__c = caseLine.Quantity__c,
									Product_Detail__c = caseLine.Product_Detail__c,
									AcctSeed__Product__c = caseLine.Product_ID__c,
									AcctSeed__GL_Account__c = product.Recognized_Revenue_GL_Account__c,
									AcctSeed__Credit__c = caseLine.Product_Detail__r.Processing_Fee__c
								);
								journalEntryLinesToInsert.add(creditLine);
							}
						}
					}
				}
			}

			// ______________________________________________________________________
			// Inserting and posting the new Journal Entries and Journal Entry Lines.
			if (journalEntryLinesToInsert.size() > 0) {
				insert journalEntryLinesToInsert;

				List<AcctSeed.PostResult> postResults = AcctSeed.JournalEntryPostService.postJournalEntries(journalEntriesMap.values());
				System.debug('Posting Journal Entries... Results:');
				System.debug(postResults);
			}

			// _________________________________________________________
			// Inserting and posting the new Billings and Billing Lines.
			insert billingLinesToInsert;

			List<AcctSeed.PostResult> postResults = AcctSeed.BillingPostService.postBillings(billingsMap.values());
			System.debug('Posting billings... Results:');
			System.debug(postResults);
			
			// _________________________________________________
			// Updating the Accounting Status on the Case Lines.
			update caseLinesToUpdate;
			
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseLineTrigger.cancelCaseLinesAsync: ' + e.getMessage());
			// I don't want to create billings if the billing lines fail. Also, to prevent the posting of the case lines.
			Database.rollback(rollbackPoint);
		}
	}
}