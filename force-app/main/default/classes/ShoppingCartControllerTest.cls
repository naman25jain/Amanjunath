@isTest
public with sharing class ShoppingCartControllerTest {

	final static Id caseEpicExtractionRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();

	@TestSetup
	static void makeData(){
		BillingTestFactory.createEpicCase();
		BillingTestFactory.forceCreateEpicCasesWithoutService();
	}

	@IsTest
	static void testGettingCurrentUsersData(){
		User runningUser =  BillingTestFactory.getCommunityUser();

		Test.startTest();
		System.runAs(runningUser){
			User user = ShoppingCartController.getCurrentUser();
			System.assert(user != null, 'Error testing the getCurrentUser() method.');

			Contact contact = ShoppingCartController.getCurrentUsersContact();
			System.assert(contact != null, 'Error testing the getCurrentUsersContact() method.');

			String contactId = ShoppingCartController.getCurrentUsersContactId();
			System.assert(contactId != null, 'Error testing the getCurrentUsersContactId() method.');

			Account account = ShoppingCartController.getCurrentUsersAccount();
			System.assert(account != null, 'Error testing the getCurrentUsersAccount() method.');
		}
		Test.stopTest();
	}
	
	@isTest
	static void testLoadingShoppingCart() {
		User runningUser =  BillingTestFactory.getCommunityUser();
		Map<Id, Case> casesMap = new Map<Id, Case>(
			[SELECT Id, Subject, Case_Service__c FROM Case WHERE RecordTypeId = :caseEpicExtractionRTId AND (Subject LIKE 'Test%' OR Subject LIKE 'Case without service')]
		);
		List<Id> caseRecordIds = new List<Id> (casesMap.keySet());
		List<String> singleCaseRecordId = new List<String>{ caseRecordIds[0] };

		Test.startTest();
		System.runAs(runningUser) {
			List<Case> cases = ShoppingCartController.getCases(caseRecordIds);
			System.assert(cases.size() > 0, 'Error testing the getCases() method.');

			List<Case_Line__c> caseLines = ShoppingCartController.getCaseLines(caseRecordIds);
			System.assert(caseLines.size() > 0, 'Error testing the getCaseLines() method.');
			
			Decimal creditAmount = ShoppingCartController.getCredits();
			System.assert(creditAmount != null, 'Error testing the getCredits() method.');

			Decimal unappliedBalance = ShoppingCartController.getUnpaidBalances();
			System.assert(unappliedBalance != null, 'Error testing the getUnpaidBalances() method.');

			String orderId = ShoppingCartController.createChargentOrder(10, singleCaseRecordId, '12345678', true);
			System.assert(orderId != null, 'Error testing the createChargentOrder() method.');
		}
		Test.stopTest();
	}

	@IsTest
	static void testFailedShoppingCartMethods(){
		User runningUser =  BillingTestFactory.getCommunityUser();

		Test.startTest();
		System.runAs(runningUser) {
			List<Case> cases = ShoppingCartController.getCases(null);
			System.assert(cases == null, 'Error testing the getCases() method.');

			List<Case_Line__c> caseLines = ShoppingCartController.getCaseLines(null);
			System.assert(caseLines == null, 'Error testing the getCaseLines() method.');
		}

		List<Case> cases = ShoppingCartController.getCases(null);
		System.assert(cases == null, 'Error testing the getCases() method.');

		List<Case_Line__c> caseLines = ShoppingCartController.getCaseLines(null);
		System.assert(caseLines == null, 'Error testing the getCaseLines() method.');
		
		Decimal creditAmount = ShoppingCartController.getCredits();
		System.assert(creditAmount == null, 'Error testing the getCredits() method.');

		Decimal unappliedBalance = ShoppingCartController.getUnpaidBalances();
		System.assert(unappliedBalance == null, 'Error testing the getUnpaidBalances() method.');

		Map<Id, Product_Detail__c> productDetails = ShoppingCartController.getActiveProductDetails(null);
		System.assert(productDetails == null, 'Error testing the getActiveProductDetails() method.');

		String orderId = ShoppingCartController.createChargentOrder(10, null, '12345678', true);
		System.assert(orderId == null, 'Error testing the createChargentOrder() method.');
		
		Test.stopTest();
	}

	@IsTest
	static void testContactRedirect(){
		Test.startTest();
	
		String response = ContactRedirectController.redirect();
		System.assert(response != null, 'The ContactRedirectController didnt return anything.');

		Test.stopTest();
	}

	@IsTest
	static void testGetAccountBalance(){
		User runningUser =  BillingTestFactory.getCommunityUser();
		
		Test.startTest();
		System.runAs(runningUser) {
			Decimal balacne = ShoppingCartController.getAccountBalance();
			System.assert(balacne != null, 'The getAccountBalance didnt return anything.');
		}
		Test.stopTest();
	}

	@IsTest
	static void testFailedGetAccountBalance(){
		Test.startTest();

			Decimal balacne = ShoppingCartController.getAccountBalance();
			System.assert(balacne == null, 'The getAccountBalance didnt return anything.');

		Test.stopTest();
	}
}