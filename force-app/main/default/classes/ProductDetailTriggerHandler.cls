public without sharing class ProductDetailTriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	
	public ProductDetailTriggerHandler (boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	public void OnBeforeInsert(List<Product_Detail__c> newRecords) {
		validateDuplicates(newRecords);
	}
	
	// public void OnAfterInsert(List<Product_Detail__c> newRecords) {
	// 	// Logic
	// }
	
	// @future public static void OnAfterInsertAsync(Set<Id> newRecordIDs) {
	// 	// Future Logic
	// }
		
	public void OnBeforeUpdate(List<Product_Detail__c> newRecords, List<Product_Detail__c> oldRecords, Map<ID, Product_Detail__c> newRecordMap, Map<ID, Product_Detail__c> oldRecordMap) {
		validateDuplicates(newRecords);
	}
	
	// public void OnAfterUpdate(List<Product_Detail__c> newRecords, List<Product_Detail__c> oldRecords, Map<ID, Product_Detail__c> newRecordMap, Map<ID, Product_Detail__c> oldRecordMap) {
	// 	// Logic
	// }
		
	// @future public static void OnAfterUpdateAsync(Set<ID> updatedRecordIDs) {
	// 	// Future Logic
	// }

	// public void OnBeforeDelete(List<Product_Detail__c> recordsToDelete, Map<ID, Product_Detail__c> recordMap) {
	// 	// Logic
	// }

	// public void OnAfterDelete(List<Product_Detail__c> deletedRecords, Map<ID, Product_Detail__c> recordMap) {
	// 	// Logic
	// }

	// @future public static void OnAfterDeleteAsync(Set<Id> deletedRecordIDs) {
	// 	// Future Logic
	// }

	// public void OnUndelete(List<Product_Detail__c> restoredRecords) {
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

	// ---------------------------------------------------------------------------------------------------------
	// This method validates that the Product_Detail__c object it's not duplicated.
    // Duplicates are based on the product, the start and end date and some other criteria in the formula field
    // Unique_Key__c
	// ---------------------------------------------------------------------------------------------------------
	private void validateDuplicates(List<Product_Detail__c> newRecords) {

		try {
			
			// Creating a Map of the new Product_Details with each Unique_Key__c as key and a list of Product_Detail__c as values.
			Map<String, List<Product_Detail__c>> productDetailMap = new Map<String, List<Product_Detail__c>>();
			Set<String> productIds = new Set<String>();
			for (Product_Detail__c record : newRecords) {
				String key = record.Unique_Key__c;
				if (productDetailMap.containsKey(key)) {
					productDetailMap.get(key).add(record);
				} else {
					productDetailMap.put(key, new List<Product_Detail__c>{record});
				}
				productIds.add(record.Product__c);
			}

			Map<Id, Product2> productsMap = new Map<Id, Product2>([SELECT Id, Requires_Document_Type__c FROM Product2 WHERE Id IN :productIds]);

			// Getting the existing records that match the Unique_Key__c		
			// Creating a Map, same as the previous, but with existing records.
			Map<String, List<Product_Detail__c>> existingProductDetailMap = new Map<String, List<Product_Detail__c>>();
			for (Product_Detail__c existingRecord : [SELECT Id, Name, Product__c, Product__r.Requires_Document_Type__c, Unique_Key__c, Start_Date__c, End_Date__c, All_Documents__c, Document_Type__c 
																							FROM Product_Detail__c 
																							WHERE Unique_Key__c IN :productDetailMap.keySet()]) {
				String key = existingRecord.Unique_Key__c;
				if (existingProductDetailMap.containsKey(key)) {
					existingProductDetailMap.get(key).add(existingRecord);
				} else {
					existingProductDetailMap.put(key, new List<Product_Detail__c>{existingRecord});
				}
			}
			
			// If there are existing records, validate that the dates don't overlap. If the dates overlap add error.
			if (existingProductDetailMap.keySet().size() > 0) {
				// For each unique key
				for (String key : productDetailMap.keySet()) {
					// and for each new Product_Detail__c record with that key
					// For each Unique_Key__c validate if there are existing records with the same key.
					if (existingProductDetailMap.containsKey(key)) {
						for (Product_Detail__c newRecord : productDetailMap.get(key)) {
							Date newStartDate = newRecord.Start_Date__c;
							Date newEndDate = newRecord.End_Date__c;
							Id productId = newRecord.Product__c;
							Boolean requiresDocumentType = productsMap.containsKey(productId)? productsMap.get(productId).Requires_Document_Type__c : false;
							Boolean newHasAllDocuments = newRecord.All_Documents__c;
							List<String> newDocumentTypes = new List<String>();
							if (requiresDocumentType && !newHasAllDocuments && newRecord.Document_Type__c != null) {
								newDocumentTypes = newRecord.Document_Type__c.split(';');
							}
							for (Product_Detail__c existingRecord : existingProductDetailMap.get(key)) {
								// Verify if it's the same record and break.
								if (existingRecord.Id == newRecord.Id) {
									continue;
								}
								// If it isn't the same record, validate if the dates overlap.
								Date existingStartDate = existingRecord.Start_Date__c;
								Date existingEndDate = existingRecord.End_Date__c;
								Boolean startDateOverlaps = newStartDate >= existingStartDate && newStartDate <= existingEndDate;
								Boolean endDateOverlaps = newEndDate >= existingStartDate && newEndDate <= existingEndDate;
								Boolean sameDocType = false;
								if (startDateOverlaps || endDateOverlaps) {
									if (requiresDocumentType) {
										Boolean existingAllDocuments = existingRecord.All_Documents__c;
										List<String> existingDocumentTypes = new List<String>();
										if (!existingAllDocuments && existingRecord.Document_Type__c != null) {
											existingDocumentTypes = existingRecord.Document_Type__c.split(';');
										}
										if (existingAllDocuments) {
											newRecord.addError('Duplicate value found, there\'s an existing product detail for this date range and all documents types.');
											break;
										} else if (newHasAllDocuments && existingDocumentTypes != null) {
											newRecord.addError('Duplicate value found, there\'s an existing product detail for this date range and specific document types.');
											break;
										} else {
											for (String newDocType : newRecord.Document_Type__c?.split(';')) {
												if (existingDocumentTypes.contains(newDocType)) {
													newRecord.addError('Duplicate value found, there\'s an existing product detail for this date range and the document type "' + newDocType + '"');
													sameDocType = true;
													break;
												}
											}
										}
									} else {
										newRecord.addError('Duplicate value found, the dates overlap.');
										break;
									}
								} // if the dates don't overlap, then do nothing
								if (sameDocType) {
									sameDocType = false;
									break;
								}
							} // end of existing records loop
						} // end of new records loop
					} // else do nothing
				} // end of each unique key loop
			} // if there are no existing records, do nothin

		} catch (Exception e) {
			System.debug('An error occurred while running the ProductDetailTriggerHandler: ' + e.getMessage());
		}
		
	} // ValidateDuplicates end
}