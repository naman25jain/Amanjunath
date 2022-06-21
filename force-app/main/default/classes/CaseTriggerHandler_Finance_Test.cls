@isTest
public class CaseTriggerHandler_Finance_Test {

	@TestSetup
	static void makeData(){

		BillingTestFactory.createEpicCase();

		BillingTestFactory.forceCreateEpicCasesWithoutService();

	}

	// ==================================================================================================
	// This method is for testing some methods on the CaseTriggerHandler.cls. Those methods are 
	// createCaseLineItemsOnAfterInsert(), createCaseLineItemsOnAfterUpdate() and createCaseLineItems()
	// ==================================================================================================
	@isTest
	static void testCaseLineRecordCreationOnInsert() {

		Id caseEpicExtractionRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();

		List<Case> caseList = [SELECT Id, Subject, Case_Service__c FROM Case WHERE RecordTypeId = :caseEpicExtractionRTId AND Subject LIKE 'Case without service%' LIMIT 2];

		Test.startTest();

		for (Case caseRecord : caseList) {
			caseRecord.Case_Service__c = 'EPIC Credentials Verification';
		}
		update caseList;

		Test.stopTest();

		System.assert([SELECT Id FROM Case_Line__c WHERE Case__c = :caseList[0].Id].size() != 0, 'Error! No case lines created.');
	}

	// @IsTest
	// static void testInvoiceableServiceProcess(){
		
	// 	Test.startTest();
		
	// 	Case IFOMCase = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'IFOM Case 1'];
	// 	System.assert(IFOMCase.Id != null);

	// 	IFOMCase.Internal_Status__c = 'Accepted';
	// 	update IFOMCase;

	// 	List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :IFOMCase.Id];
	// 	System.debug(caseLines);
	// 	System.assert(caseLines[0].Id != null);
	// 	// System.assert(caseLines[0].Accounting_Status__c == 'To Invoice');

	// 	Test.stopTest();
		
	// }

	// @IsTest
	// static void testFailedInvoiceableServiceProcess(){
		
	// 	Test.startTest();
		
	// 	Case IFOMCase = [SELECT Id, Internal_Status__c FROM Case WHERE Subject = 'IFOM Case 2'];
	// 	System.assert(IFOMCase.Id != null);

	// 	IFOMCase.Internal_Status__c = 'Accepted';
	// 	update IFOMCase;

	// 	List<Case_Line__c> caseLines = [SELECT Id, Accounting_Status__c FROM Case_Line__c WHERE Case__c = :IFOMCase.Id];
	// 	System.debug(caseLines);
	// 	System.assert(caseLines[0].Id != null);
	// 	System.assert(caseLines[0].Accounting_Status__c == 'To Bill');

	// 	Test.stopTest();
		
	// }
}