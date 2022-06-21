@isTest
public with sharing class ProductDetailTests {
	
	@isTest
	static void duplicateProductDetailValidation() {
		
		Id serviceRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();

		Product2 product1 = new Product2(Name = 'Test Product 1', RecordTypeId = serviceRecordTypeId, Requires_Document_Type__c = false);
		insert product1;
		System.assert(product1.Id != null, 'Insert product1 failed.');

		Product2 product2 = new Product2(Name = 'Test Product 2', RecordTypeId = serviceRecordTypeId, Requires_Document_Type__c = true);
		insert product2;
		System.assert(product2.Id != null, 'Insert product2 failed.');
		
		// Range 1 - 30 days.
		Date startRange1 = Date.today();
		Date endRange1 = startRange1.addDays(30);
		
		// Range 2 - 30 days after Range 1.
		Date startRange2 = endRange1.addDays(1);
		Date endRange2 = startRange2.addDays(30);

		// Range 3 - 30 days after Range 2.
		Date startRange3 = startRange2.addDays(1);
		Date endRange3 = startRange3.addDays(30);

		// Range overlaping with Range 1
		Date overlapStartRange1 = startRange1.addDays(-15);
		Date overlapEndRange1 = overlapStartRange1.addDays(30);

		// Range overlaping with Range 2 and 3
		Date overlapStartRange2 = startRange2.addDays(15);
		Date overlapEndRange2 = overlapStartRange2.addDays(30);

		// Range overlaping with Range 3
		Date overlapStartRange3 = startRange3.addDays(15);
		Date overlapEndRange3 = overlapStartRange3.addDays(30);
				
		Product_Detail__c pd1 = new Product_Detail__c(Product__c = product1.Id, Start_Date__c = startRange1, End_Date__c = endRange1, Service_Fee__c = 0.0);
		insert pd1;
		
		Product_Detail__c pd2 = new Product_Detail__c(Product__c = product1.Id, Start_Date__c = startRange2, End_Date__c = endRange2, Service_Fee__c = 0.0);
		insert pd2;
		
		Test.startTest();

		// Checking if the dates are the same.
		String errorMessage = 'none';
		try {
			Product_Detail__c pd3 = new Product_Detail__c(Product__c = product1.Id, Start_Date__c = startRange1, End_Date__c = endRange1, Service_Fee__c = 0.0);
			insert pd3;
		} catch (Exception e) {
			errorMessage = e.getMessage();
		}
		System.assertNotEquals('none', errorMessage);
		
		// Checking if the dates overlap.
		errorMessage = 'none';
		try {
			Product_Detail__c pd4 = new Product_Detail__c(Product__c = product1.Id, Start_Date__c = overlapStartRange1, End_Date__c = overlapEndRange1, Service_Fee__c = 0.0);
			insert pd4;
		} catch (Exception e) {
			errorMessage = e.getMessage();
		}
		System.assertNotEquals('none', errorMessage);

		// Checking for no errors
		update pd1;

		// Checking if the dates overlap when updated.
		errorMessage = 'none';
		try {
			pd2 = [SELECT Id, Product__c, Start_Date__c, End_Date__c FROM Product_Detail__c WHERE Product__c = :product1.Id AND Start_Date__c = :startRange2 AND End_Date__c = :endRange2];
			pd2.Start_Date__c = overlapStartRange1;
			pd2.End_Date__c = overlapEndRange1;
			update new List<Product_Detail__c>{pd1, pd2};
		} catch (Exception e) {
			errorMessage = e.getMessage();
		}
		System.assertNotEquals('none', errorMessage);


		// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		// Now testing product2 which needs Document Type or All Documents
		// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

		// Getting the first three picklist values for the Document_Type__c multi-select picklist.
		List<Schema.PicklistEntry> picklistEntries = Product_Detail__c.Document_Type__c.getDescribe().getPicklistValues();
		String concatenatedValues = '';
		for (Integer i = 0; i < 3; i++) {
			concatenatedValues += picklistEntries[i].label;
			if (i < 2) {
				concatenatedValues += ';';
			}
		}
		System.debug(concatenatedValues);

		// Inserting a pd with the All_Documents__c checkbox.
		Product_Detail__c pd5 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange1, End_Date__c = endRange1, Service_Fee__c = 0.0, All_Documents__c = true);
		insert pd5;
		
		// Checking when the dates overlap and a record exists with the All_Documents__c checkbox.
		Product_Detail__c pd6 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange1, End_Date__c = endRange1, Service_Fee__c = 0.0, Document_Type__c = picklistEntries[0].label);
		try {
			insert pd6;
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		System.assert(pd6.Id == null, 'Product Detail inserted without issues, it should give an error.');
		
		// Inserting a pd with 3 different document types.
		Product_Detail__c pd7 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange2, End_Date__c = endRange2, Service_Fee__c = 0.0, 
		Document_Type__c = concatenatedValues);
		insert pd7;

		// Checking when the dates overlap and a record exists that contains one of the Document Types and the new one contains the All_Documents__c checkbox.
		Product_Detail__c pd8 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange2, End_Date__c = endRange2, Service_Fee__c = 0.0, All_Documents__c = true);
		try {
			insert pd8;
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		System.assert(pd8.Id == null, 'Product Detail inserted without issues, it should give an error.');

		// Checking when the dates overlap and a record exists that contains one of the Document Types in an existing record.
		Product_Detail__c pd9 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange2, End_Date__c = endRange2, Service_Fee__c = 0.0, Document_Type__c = picklistEntries[0].label);
		try {
			insert pd9;
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
		System.assert(pd9.Id == null, 'Product Detail inserted without issues, it should give an error.');

		// Checking when the dates overlap and a record exists that contains one of the Document Types in an existing record.
		Product_Detail__c pd10 = new Product_Detail__c(Product__c = product2.Id, Start_Date__c = startRange2, End_Date__c = endRange2, Service_Fee__c = 0.0, Document_Type__c = picklistEntries[3].label);
		
		insert pd10;
		System.assert(pd10.Id != null, 'Failed to insert a Product Detail, it should have inserted (pd10).');

		// this should also not give an error.
		update pd10;

		Test.stopTest();
	}
	
}