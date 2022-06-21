public without sharing class CaseTriggerHandler_Finance {

	public static Boolean isFirstExecution = true;
	public static Boolean isFirstInsert = true;
	public static Boolean isFirstUpdate = true;

	public static final Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
	public static final Id regionChangeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
	public static final Id usmleTranscriptRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
	public static final Id nonUsmleTranscriptRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NON_USMLE_TRANSCRIPT).getRecordTypeId();
		
	// public static void OnBeforeInsert(List<Case> newRecords) {
	// 	// Logic
	// }
	
	public static void OnAfterInsert(Map<Id,Case> newCasesMap) {
		// Map to organizing the Cases by Service
		Map<String, List<Case>> casesWithServices = new Map<String, List<Case>>();
		// Map to store the Cases that had a status change
		Map<Id, Case> casesWithStatusChange = new Map<Id, Case>();

		// Checking the different requirements for each case.
		for (Case caseRecord : newCasesMap.values()) {
			// This check is to get only the cases that are inserted with a service.
			String serviceName = caseRecord.Case_Service__c;

			Boolean examRegistrationException = caseRecord.RecordTypeId == examRegRTId && String.isBlank(caseRecord.Exam_Type__c);
			Boolean regionChangeException = caseRecord.RecordTypeId == regionChangeRTId && String.isBlank(caseRecord.Parent.Exam_Type__c);
			Boolean usmleException = !((caseRecord.RecordTypeId == usmleTranscriptRTId || caseRecord.RecordTypeId == nonUsmleTranscriptRTId) && String.isNotBlank(caseRecord.ParentId));

			if (String.isNotBlank(serviceName) && caseRecord.Count_of_Case_Lines__c <= 0 && usmleException && !examRegistrationException && !regionChangeException) {
				if (casesWithServices.containsKey(serviceName)) {
					casesWithServices.get(serviceName).add(caseRecord);
				} else {
					casesWithServices.put(serviceName, new List<Case> {caseRecord});
				}
			}
		}

		// Call the different methods if there are cases that meet the requirements.
		if (casesWithServices.size() > 0) {            
			createCaseLineItems(casesWithServices, newCasesMap.keySet());
		}
	}
	
	// @future public static void OnAfterInsertAsync(Set<Id> newRecordIDs) {
	// 	// Future Logic
	// }
		
	// public static void OnBeforeUpdate(List<Case> newRecords, List<Case> oldRecords, Map<ID, Case> newRecordMap, Map<ID, Case> oldRecordMap) {
	// 	// Logic
	// }
	
	public static void OnAfterUpdate(Map<Id,Case> newCasesMap, Map<Id,Case> oldCasesMap) {
		// --------------------------------------------------------------------------
		// Getting the account records with the Invoiceable_Client__c flag
		// --------------------------------------------------------------------------
		Set<Id> accountIds = new Set<Id>();
		Set<Id>	clientAccountIds = new Set<Id>();
		for (Case caseRecord : newCasesMap.values()) {
			accountIds.add(caseRecord.AccountId);
			if (caseRecord.Client_Account_Name__c != null) {
				clientAccountIds.add(caseRecord.Client_Account_Name__c);
			}
		}
		Map<Id, Account> accountsMap = new Map<Id, Account> ([SELECT Id, Name, Invoiceable_Client__c FROM Account WHERE Id IN :accountIds OR Id IN :clientAccountIds]);
		// Map to organizing the Cases by Service
		Map<String, List<Case>> casesWithServices = new Map<String, List<Case>>();
		// Map to store the Cases that had a status change
		Map<Id, Case> casesWithStatusChange = new Map<Id, Case>();
		// Map with the case Id as key and the corresponding Account record as value
		Map<Id, Account> case2AccountMap = new Map<Id, Account>();
		// Map with the case Id as key and the corresponding Client Account record as value
		Map<Id, Account> case2ClientAccountMap = new Map<Id, Account>();
		// Map with the cases from a query to get aditional values from record.
		Map<Id, Case> queriedCases = new Map<Id, Case> ([SELECT Id, Parent.Exam_Type__c FROM Case WHERE Id IN :newCasesMap.keySet()]);

		// Checking the different requirements for each case.
		for (Case caseRecord : newCasesMap.values()) {
			String caseId = caseRecord.Id;
			String accountId = caseRecord.AccountId;
			String clientAccountId = caseRecord.Client_Account_Name__c;

			if (accountsMap.containsKey(accountId)) {
				case2AccountMap.put(caseId, accountsMap.get(accountId));
			}
			if (clientAccountId != null && accountsMap.containsKey(clientAccountId)) {
				case2ClientAccountMap.put(caseId, accountsMap.get(clientAccountId));
			}

			if (oldCasesMap.containsKey(caseId)) {
				Case oldRecord = oldCasesMap.get(caseRecord.Id);
				// This check is to get only the cases that are inserted with a service.
				String serviceName = caseRecord.Case_Service__c;

				Boolean examRegistrationException = caseRecord.RecordTypeId == examRegRTId && String.isBlank(caseRecord.Exam_Type__c);
				Boolean regionChangeException = caseRecord.RecordTypeId == regionChangeRTId && String.isBlank(queriedCases.get(caseRecord.Id).Parent.Exam_Type__c);
				Boolean usmleException = !((caseRecord.RecordTypeId == usmleTranscriptRTId || caseRecord.RecordTypeId == nonUsmleTranscriptRTId) && String.isNotBlank(caseRecord.ParentId));

				if (String.isNotBlank(serviceName) && caseRecord.Count_of_Case_Lines__c <= 0 && usmleException && !examRegistrationException && !regionChangeException) {
					if (casesWithServices.containsKey(serviceName)) {
						casesWithServices.get(serviceName).add(caseRecord);
					} else {
						casesWithServices.put(serviceName, new List<Case> {caseRecord});
					}
				}

				// This check is to get only the cases that changed their internal status.
				if (caseRecord.Internal_Status__c != oldRecord.Internal_Status__c) {
					casesWithStatusChange.put(caseRecord.Id, caseRecord);
				}
			}
		}

		// Call the different methods if there are cases that meet the requirements.
		if (casesWithServices.size() > 0) {            
			createCaseLineItems(casesWithServices, newCasesMap.keySet());
		}
		if (casesWithStatusChange.size() > 0) {
			updateCaseLinesStatuses(casesWithStatusChange, case2AccountMap, case2ClientAccountMap);
		}
	}
		
	// @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs) {
	// 	// Future Logic
	// }

	// public static void OnBeforeDelete(List<Case> recordsToDelete, Map<ID, Case> recordMap) {
	// 	// Logic
	// }

	// public static void OnAfterDelete(List<Case> deletedRecords, Map<ID, Case> recordMap) {
	// 	// Logic
	// }

	// @future public static void OnAfterDeleteAsync(Set<Id> deletedRecordIDs) {
	// 	// Future Logic
	// }

	// public static void OnUndelete(List<Case> restoredRecords) {
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

	// ==================================================================================================
	// This method receives a Map<String, List<Case>> with the different Services as key and a list of
	// the cases as values. The list of cases received must by only the ones that need new Case_Line__c 
	// items.
	// ==================================================================================================
	private static void createCaseLineItems(Map<String, List<Case>> casesWithServices, Set<Id> caseIds) {
		try {
			// Getting all the default Product2Service__c records related to the services found in the 
			// previous step. Organize those Product2Service records by service, on a Map. Also,
			// create a list of product Ids for the next step.
			Map<String, List<Product2Service__c>> p2sMap = new Map<String, List<Product2Service__c>>();
			List<String> productIds = new List<String>();
			for (Product2Service__c p2s : [SELECT Id, Name, Case_Service__c, Quantity__c, Exam_Type_List__c, Product__c, Product__r.Name, Product__r.Requires_Region__c, Product__r.Requires_Institution__c, Product__r.P2S_Requires_Record_Type__c, Record_Type_Name__c FROM Product2Service__c WHERE Default__c = true AND Case_Service__c IN :casesWithServices.keySet()]) {
				String serviceName = p2s.Case_Service__c;
				if (p2sMap.containsKey(serviceName)) {
					p2sMap.get(serviceName).add(p2s);
				} else {
					p2sMap.put(serviceName, new List<Product2Service__c> {p2s});
				}
				productIds.add(p2s.Product__c);
			}

			// Validation to exit if no product records are found.
			// The rest of the logic depends on having products.
			if (productIds.size() < 1) {
					return;
			}

			// Getting all the Product_Detail__c records related to the Product2Service records found 
			// in the previous step. Organize those Product_Detail__c records by service, on a Map.
			Map<String, Product_Detail__c> productDetailMap = new Map<String, Product_Detail__c>();
			Map<String, List<Product_Detail__c>> product2ProductDetailsMap = new Map<String, List<Product_Detail__c>>();
			for (Product_Detail__c productDetail : [SELECT Id, Name, Start_Date__c, End_Date__c, Product__c, Service_Fee__c, Unique_Key__c FROM Product_Detail__c 
			WHERE Product__c IN :productIds AND Start_Date__c <= TODAY AND End_Date__c >= TODAY]) {
				// Creating a map to get the Product Details base on their Unique_Key__c.
				String key = productDetail.Unique_Key__c;
				productDetailMap.put(key, productDetail);

				// Creating a map to get all the Product Details for a given product Id.
				String productId = productDetail.Product__c;
				if (product2ProductDetailsMap.containsKey(productId)) {
					product2ProductDetailsMap.get(productId).add(productDetail);
				} else {
					product2ProductDetailsMap.put(productId, new List<Product_Detail__c> {productDetail});
				}
			}

			// Getting all the products that didn't find a product detail.
			List<String> productIdsWithoutPrice = new List<String>();
			for (String productId : productIds) {
				if (!product2ProductDetailsMap.containsKey(productId)) {
					productIdsWithoutPrice.add(productId);
				}
			}
			// Getting product details for every product that doesn't have one.
			for (Product_Detail__c productDetail : [SELECT Id, Name, Start_Date__c, End_Date__c, Product__c, Service_Fee__c, Unique_Key__c FROM Product_Detail__c 
			WHERE Product__c IN :productIdsWithoutPrice AND Start_Date__c <= TODAY ORDER BY Start_Date__c DESC]) {
				String key = productDetail.Unique_Key__c;
				if (!productDetailMap.containsKey(key)) {
					productDetailMap.put(key, productDetail);
				}
			}

			Map<Id, Case> casesMap = new Map<Id, Case> ([SELECT Id, Exam_Region__r.Name, Entity__r.Name, Parent.Exam_Type__c, RecordType.Name, RecordTypeId FROM Case WHERE Id IN :caseIds]);

			// Creating all the new Case_Line__c items, for each service and for each case.
			List<Case_Line__c> caseLinesToInsert = new List<Case_Line__c>();
			for (String serviceName : casesWithServices.keySet()) {
				// Validating if this particular service has products.
				if (p2sMap.containsKey(serviceName)) {
					for (Case caseRecord : casesWithServices.get(serviceName)) {
						Case caseFromQuery = casesMap.get(caseRecord.Id);
						String caseExamType = caseRecord.Exam_Type__c;
						String caseRecordTypeName = caseFromQuery.RecordType.Name;
						if (caseRecord.RecordTypeId == regionChangeRTId) {
							caseExamType = caseFromQuery.Parent.Exam_Type__c;
						}
						// Create a new Case_Line__c for each Product on the selected service on the current case.
						for (Product2Service__c p2s : p2sMap.get(serviceName)) {
							if (String.isNotBlank(caseExamType) && String.isNotBlank(p2s.Exam_Type_List__c) && caseExamType != p2s.Exam_Type_List__c) {
								continue;
							}
							if (p2s.Product__r.P2S_Requires_Record_Type__c && p2s.Record_Type_Name__c != caseRecordTypeName) {
								continue;
							}
							String productDetailUniqueKey = p2s.Product__r.Name;
							if (p2s.Product__r.Requires_Region__c) {
								productDetailUniqueKey += ' - ' + caseFromQuery.Exam_Region__r.Name;
							}
							if (p2s.Product__r.Requires_Institution__c) {
								productDetailUniqueKey += ' - ' + caseFromQuery.Entity__r.Name;
							}
							Case_Line__c newCaseLine = new Case_Line__c();
							newCaseLine.Case__c = caseRecord.Id;
							newCaseLine.Accounting_Status__c = 'New';
							Product_Detail__c pdRecord = productDetailMap.get(productDetailUniqueKey);
							newCaseLine.Product_Detail__c  = pdRecord?.Id;
							newCaseLine.Quantity__c  = p2s?.Quantity__c;
							newCaseLine.Price__c = pdRecord?.Service_Fee__c;
							newCaseLine.Date__c  = Date.today();
							newCaseLine.Product2Service__c = p2s.Id;
							caseLinesToInsert.add(newCaseLine);
						}
					}
				}
			}
			insert caseLinesToInsert;
			
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseTriggerHandler_Finance.createCaseLineItems: ' + e.getMessage());
		}
	}

	// ==================================================================================================
	// This method will update the Case Lines of each case depending on their corresponding 
	// Product2Service records.
	// ==================================================================================================
	private static void updateCaseLinesStatuses(Map<Id, Case> casesWithServiceChange, Map<Id, Account> case2AccountMap, Map<Id, Account> case2ClientAccountMap) {
		try {
			// Getting the Case Lines related to the cases received.
			List<Case_Line__c> caseLines = [SELECT Id, Product2Service__c, Secondary_P2S__c, Accounting_Status__c, Case__c, Case__r.Internal_Status__c, Secondary_Case__c, Secondary_Case__r.Internal_Status__c FROM Case_Line__c WHERE Case__c IN :casesWithServiceChange.keySet() OR Secondary_Case__c IN :casesWithServiceChange.keySet()];
			// List<Case_Line__c> secondaryCaseLines = [SELECT Id, Product2Service__c, Secondary_P2S__c, Accounting_Status__c, Case__c, Secondary_Case__c FROM Case_Line__c WHERE Secondary_Case__c IN :casesWithServiceChange.keySet()];

			// Getting the list of the Product2Service records related to each Case Line.
			Set<Id> product2serviceIds = new Set<Id>();
			for (Case_Line__c caseLine : caseLines) {
				product2serviceIds.add(caseLine.Product2Service__c);
				if (caseLine.Secondary_P2S__c != null) {
					product2serviceIds.add(caseLine.Secondary_P2S__c);
				}
			}
			List<Product2Service__c> product2ServiceList = [SELECT Id, Case_Service__c, Billing_Statuses__c, Fulfillment_Statuses__c, Rejected_Statuses__c, Cancelled_Statuses__c, Invoiceable_Service__c FROM Product2Service__c WHERE Id IN :product2serviceIds];
			Map<Id, Product2Service__c> product2ServiceMap = new Map<Id, Product2Service__c> (product2ServiceList);

			// For each Case Line, verify if the Accounting status needs updating based on the corresponding Product2Servcie statuses mappings.
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();
			for (Case_Line__c caseLine : caseLines) {
				Boolean secondaryPath = false;

				String caseId = caseLine.Case__c;
				String caseStatus = caseLine.Case__r.Internal_Status__c;
				String p2sId = caseLine.Product2Service__c;

				if (caseLine.Secondary_Case__c != null && caseLine.Secondary_P2S__c != null && casesWithServiceChange.containsKey(caseLine.Secondary_Case__c)) {
					secondaryPath = true;
					caseId = caseLine.Secondary_Case__c;
					caseStatus = caseLine.Secondary_Case__r.Internal_Status__c;
					p2sId = caseLine.Secondary_P2S__c;
				}

				// Logic for normal Product2Service logic	
				if (String.isNotBlank(caseStatus) && product2ServiceMap.containsKey(p2sId)) {
					Product2Service__c p2s = product2ServiceMap.get(p2sId);
					if (p2s.Billing_Statuses__c != null && p2s.Billing_Statuses__c.contains(caseStatus) && caseLine.Accounting_Status__c == 'New') {
						if (case2ClientAccountMap.containsKey(caseId) && case2ClientAccountMap.get(caseId).Invoiceable_Client__c && p2s.Invoiceable_Service__c) {
							caseLine.Accounting_Status__c = 'To Invoice';
							caseLine.To_Invoice_Date__c = Date.today();
						} else {
							caseLine.Accounting_Status__c = 'To Bill';
						}
						caseLinesToUpdate.add(caseLine);
					} else if (p2s.Fulfillment_Statuses__c != null && p2s.Fulfillment_Statuses__c.contains(caseStatus) && caseLine.Accounting_Status__c == 'Billed') {
						caseLine.Accounting_Status__c = 'To Fulfill';
						caseLinesToUpdate.add(caseLine);
					} else if (p2s.Rejected_Statuses__c != null && p2s.Rejected_Statuses__c.contains(caseStatus) && caseLine.Accounting_Status__c == 'Billed') {
						caseLine.Accounting_Status__c = 'To Reject';
						caseLinesToUpdate.add(caseLine);
					} else if (p2s.Cancelled_Statuses__c != null && p2s.Cancelled_Statuses__c.contains(caseStatus) && caseLine.Accounting_Status__c == 'Fulfilled') {
						caseLine.Accounting_Status__c = 'To Cancel';
						caseLinesToUpdate.add(caseLine);
					}
				}
			}

			// Validate if there are any Case Lines that need updating.
			if (caseLinesToUpdate.size() > 0) {
				update caseLinesToUpdate;
			}
		} catch (Exception e) {
			System.debug('Something went wrong on the CaseTriggerHandler_Finance.updateCaseLinesStatuses: ' + e.getMessage());
		}
	}
}