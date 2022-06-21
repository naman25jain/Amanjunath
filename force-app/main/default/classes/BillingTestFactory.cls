@isTest
public class BillingTestFactory extends ECFMGTestFactory{

	
	public static User getCommunityUser(){
		List<User> runningUser = [SELECT Id, Name, Email FROM User WHERE UserName = 'testuser@test.com'];
		if (runningUser.size() == 0) {
			return null;
		}
		return runningUser[0];
	}
	
	@isTest
	public static void testCreateBilling() {
		
		// —— DATA PREPARATION ——
		Id adminProfileId = [ SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		User adminUser = [SELECT Id FROM USER WHERE UserRoleId != null AND IsActive = true AND ProfileId = :adminProfileId LIMIT 1];
		System.runAs(adminUser) {
			
			// =============================================================
			// Creating an account and a contact for the case lines.
			// =============================================================
			Account testAccount = new Account(Name = 'Applicant');
			ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, testAccount);
			run();
			System.assert(testAccount.Id != null, 'Error! Test Account not created.');
	
			Id applicantRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
	
			Contact testContact = new Contact(
				RecordTypeId = applicantRTId,
				AccountId = testAccount.Id,
				LastName = 'TestCon',
				Email = 'test@user.com',
				MailingStreet = 'Street 1',
				MailingCity = 'City',
				MailingCountry = 'Afghanistan',
				MailingPostalCode = '00000'
			);
			ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, testContact);
			run();
			System.assert(testContact.Id != null, 'Error! Test Contact not created.');

			// =============================================================
			// Creating a test User
			// =============================================================
			User testUser = new User(
				Alias = 'testUser',
				Email = 'test2@test.com',
				Emailencodingkey = 'UTF-8',
				Lastname = 'test user',
				Languagelocalekey = 'en_US',
				Localesidkey = 'en_US',
				Profileid = [SELECT Id FROM Profile WHERE Name = '4-Customer Community Plus Login' LIMIT 1].Id,
				Country = 'United States',
				IsActive = true,
				ContactId = testContact.Id,
				Timezonesidkey = 'America/Los_Angeles',
				Username = 'testuser@test.com'
			);
			insert testUser;
			System.assert(testUser.Id != null, 'Error! User not created.');
		}
		
		// =======================================================================================
		// insert 6 billing formats
		// =======================================================================================
		AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
		PDFformats.add(
			new AcctSeed__Billing_Format__c(
				Name = 'Default Billing Product',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__Type__c = 'Billing',
				AcctSeed__Sort_Field__c = 'Name'
			)
		);
		
		PDFformats.add(
			new AcctSeed__Billing_Format__c(
				Name = 'Default Billing Service',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__Type__c = 'Billing',
				AcctSeed__Sort_Field__c = 'Name'
			)
		);
		
		PDFformats.add(
			new AcctSeed__Billing_Format__c (
				Name = 'Billing Outstanding Statement',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
				AcctSeed__Type__c = 'Outstanding Statement'
			)
		);
		
		PDFformats.add(
			new AcctSeed__Billing_Format__c (
				Name = 'Billing Activity Statement',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
				AcctSeed__Type__c = 'Activity Statement'
			)
		);
		
		PDFformats.add(
			new AcctSeed__Billing_Format__c(
				Name = 'Default Purchase Order',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__Type__c = 'Purchase Order',
				AcctSeed__Sort_Field__c = 'Name'
			)
		);
		
		PDFformats.add(
			new AcctSeed__Billing_Format__c(
				Name = 'Default Packing Slip',
				AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
				AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
				AcctSeed__Type__c = 'Packing Slip',
				AcctSeed__Sort_Field__c = 'Name'
			)
		);
		
		insert PDFformats;
		
		// =======================================================================================
		// Insert 5 cash flow GL Accounts
		// =======================================================================================
		AcctSeed__GL_Account__c [] glAccounts = new List<AcctSeed__GL_Account__c>();
		// 0
		glAccounts.add(
			new AcctSeed__GL_Account__c(
				Name = '1000-Cash',
				AcctSeed__Active__c = true,
				AcctSeed__Type__c = 'Balance Sheet',
				AcctSeed__Bank__c = true,
				AcctSeed__Sub_Type_1__c = 'Assets',
				AcctSeed__Sub_Type_2__c = 'Cash'
			)
		);
		
		// 1
		glAccounts.add(
			new AcctSeed__GL_Account__c(
				Name = '1205-Unapplied A/R',
				AcctSeed__Active__c = true,
				AcctSeed__Type__c = 'Balance Sheet',
				AcctSeed__Sub_Type_1__c = 'Assets',
				AcctSeed__Sub_Type_2__c = 'Cash'
			)
		);

		// 2
		glAccounts.add(
			new AcctSeed__GL_Account__c(
				Name = '0100-000-Cash Control',
				AcctSeed__Active__c = true,
				AcctSeed__Bank__c = true,
				AcctSeed__Type__c = 'Balance Sheet',
				GL_Code__c = '0100-000',
				AcctSeed__Sub_Type_1__c = 'Assets'
			)
		);

		// 3
		glAccounts.add(
			new AcctSeed__GL_Account__c(
				Name = '0342-535-EPIC Unearned',
				AcctSeed__Active__c = true,
				AcctSeed__Bank__c = false,
				AcctSeed__Type__c = 'Balance Sheet',
				GL_Code__c = '0342-535',
				AcctSeed__Sub_Type_1__c = 'Liabilities'
			)
		);

		// 4
		glAccounts.add(
			new AcctSeed__GL_Account__c(
				Name = '0536-000-EPIC Report Revenue',
				AcctSeed__Active__c = true,
				AcctSeed__Bank__c = false,
				AcctSeed__Type__c = 'Revenue',
				GL_Code__c = '0536-000',
				AcctSeed__Sub_Type_1__c = 'Electronic Portfolio of Int\'l Credentials'
			)
		);

		insert glAccounts;

		// =======================================================================================
		// Inserting 2 Gateways
		// =======================================================================================
		Id cybersourceRTId = Schema.SObjectType.ChargentBase__Gateway__c.getRecordTypeInfosByName().get('Cybersource').getRecordTypeId();

		List<ChargentBase__Gateway__c> gateways = new List<ChargentBase__Gateway__c>();
		
		gateways.add(
			new ChargentBase__Gateway__c(
				Name = 'Cybersource FinDev',
				RecordTypeId = cybersourceRTId,
				ChargentBase__Active__c = true,
				ChargentBase__Test_Mode__c = true,
				ChargentBase__Use_Tokenization__c = true,
				ChargentBase__Ignore_AVS_check__c = true,
				ChargentBase__Credit_Card_Data_Handling__c = 'Clear When Token Present',
				ChargentBase__Available_Card_Types__c = 'Visa;Mastercard;Discover;American Express',
				ChargentBase__Available_Currencies__c = 'United States dollar',
				ChargentBase__Available_Payment_Methods__c = 'Credit Card;Bank Account',
				ChargentBase__Show_Create_Update_Token_Button__c = true,
				ChargentBase__Show_Charge_Button__c = true,
				ChargentBase__Show_Authorize_Button__c = true,
				ChargentBase__Show_Setup_Recurring_Button__c = true,
				ChargentBase__Require_CVV__c = false
			)
		);

		gateways.add(
			new ChargentBase__Gateway__c(
				Name = 'Cybersource FinDev - Unlinked Refunds',
				RecordTypeId = cybersourceRTId,
				ChargentBase__Active__c = true,
				ChargentBase__Test_Mode__c = true,
				ChargentBase__Use_Tokenization__c = true,
				ChargentBase__Ignore_AVS_check__c = true,
				ChargentBase__Allow_Unlinked_Refund__c = true,
				ChargentBase__Credit_Card_Data_Handling__c = 'Clear When Token Present',
				ChargentBase__Available_Card_Types__c = 'Visa;Mastercard;Discover;American Express',
				ChargentBase__Available_Currencies__c = 'United States dollar',
				ChargentBase__Available_Payment_Methods__c = 'Credit Card',
				ChargentBase__Show_Create_Update_Token_Button__c = true,
				ChargentBase__Show_Charge_Button__c = true,
				ChargentBase__Show_Authorize_Button__c = true,
				ChargentBase__Show_Setup_Recurring_Button__c = false,
				ChargentBase__Require_CVV__c = false
			)
		);

		insert gateways;

		System.assertEquals(2, [SELECT Id FROM ChargentBase__Gateway__c].size(),'Count is not equal to 2');

		
		// =======================================================================================
		// insert 1 Ledger records
		// =======================================================================================
		AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
			Name = 'Actual',
			AcctSeed__Type__c = 'Transactional',
			AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
			AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
			AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
			AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
			AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
			AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
		
		insert ledger;
		
		// =======================================================================================
		// insert 1 Accounting Period
		// =======================================================================================
		Date startDate = Date.today().toStartOfMonth();
		Date endDate = Date.today().addMonths(1).toStartOfMonth();
		String month = String.valueOf(Date.today().month());
		String strMonth = month.length() == 1? '0' + month : month;
		String name = String.valueOf(Date.today().year()) + '-' + strMonth;
		AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
			Name = name,
			AcctSeed__Start_Date__c = startDate,
			AcctSeed__End_Date__c = endDate,
			AcctSeed__Status__c = 'Open');
		insert acctPeriod;
		
		// =======================================================================================
		// Create Accounting Variables (Company and Department)
		// =======================================================================================
		AcctSeed__Accounting_Variable__c[] accountingVariables = new List<AcctSeed__Accounting_Variable__c> ();

		accountingVariables.add(
			new AcctSeed__Accounting_Variable__c(
				Name = 'ECFMG',
				AcctSeed__Type__c = 'GL Account Variable 1',
				AcctSeed__Active__c = true,
				Default_Bank_Account__c = glAccounts[2].Id,
				Default_Gateway__c = gateways[0].Id,
				Default_Unlinked_Refund_Gateway__c = gateways[1].Id
			)
		);

		accountingVariables.add(
			new AcctSeed__Accounting_Variable__c(
				Name = '086-EPIC',
				AcctSeed__Type__c = 'GL Account Variable 2',
				AcctSeed__Active__c = true,
				GL_Code__c = '086'
			)
		);
		insert accountingVariables;
		System.assertEquals(1, [Select count() FROM AcctSeed__Accounting_Variable__c WHERE Id = :accountingVariables[0].Id], 'Count is not equal to 1');

		
		// --- START HERE ---
		// =======================================================================================
		// Create BILLING RECORDS to post and unpost
		// =======================================================================================
		AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
		
		billings.add(
			new AcctSeed__Billing__c(
				AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
				AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
				AcctSeed__Date__c = System.today(),
				AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
				AcctSeed__Status__c = 'Approved',
				Status__c = 'New',
				AcctSeed__Due_Date2__c = System.today() + 30,
				AcctSeed__Ledger__c = ledger.Id,
				AcctSeed__Billing_Format__c = PDFformats[0].Id,
				AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
			)
		);
		
		billings.add(
			new AcctSeed__Billing__c(
				AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
				AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
				AcctSeed__Date__c = System.today(),
				AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
				AcctSeed__Status__c = 'Approved',
				Status__c = 'New',
				AcctSeed__Due_Date2__c = System.today() + 30,
				AcctSeed__Ledger__c = ledger.Id,
				AcctSeed__Billing_Format__c = PDFformats[0].Id,
				AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
			)
		);
		
		insert billings;
		
		System.assertEquals(1, [Select count() FROM AcctSeed__Billing__c WHERE Id = :billings[0].Id], 'Count is not equal to 1');
		
		// =======================================================================================
		// Create billing line records to post and unpost
		// =======================================================================================
		AcctSeed__Billing_Line__c[] bLines = new List <AcctSeed__Billing_Line__c> ();
		
		for (AcctSeed__Billing__c bill : billings) {
			AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
			objBillingLine.AcctSeed__Billing__c = bill.id;
			objBillingLine.AcctSeed__Date__c = System.today();
			objBillingLine.AcctSeed__Rate__c = 25;
			objBillingLine.AcctSeed__Hours_Units__c = 1;
			objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
			objBillingLine.AcctSeed__GL_Account_Variable_1__c = accountingVariables[0].Id;
			objBillingLine.AcctSeed__GL_Account_Variable_2__c = accountingVariables[1].Id;
			bLines.add(objBillingLine);
			
			objBillingLine = new AcctSeed__Billing_Line__c();
			objBillingLine.AcctSeed__Billing__c = bill.id;
			objBillingLine.AcctSeed__Date__c = System.today();
			objBillingLine.AcctSeed__Rate__c = 25;
			objBillingLine.AcctSeed__Hours_Units__c = 2;
			objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
			objBillingLine.AcctSeed__GL_Account_Variable_1__c = accountingVariables[0].Id;
			objBillingLine.AcctSeed__GL_Account_Variable_2__c = accountingVariables[1].Id;
			bLines.add(objBillingLine);
			
			objBillingLine = new AcctSeed__Billing_Line__c();
			objBillingLine.AcctSeed__Billing__c = bill.id;
			objBillingLine.AcctSeed__Date__c = System.today();
			objBillingLine.AcctSeed__Rate__c = 25;
			objBillingLine.AcctSeed__Hours_Units__c = 1;
			objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
			objBillingLine.AcctSeed__GL_Account_Variable_1__c = accountingVariables[0].Id;
			objBillingLine.AcctSeed__GL_Account_Variable_2__c = accountingVariables[1].Id;
			bLines.add(objBillingLine);
		}
		insert bLines;
		System.assertEquals(1, [Select count() FROM AcctSeed__Billing_Line__c WHERE Id = :bLines[0].Id LIMIT 1],'Count is not equal to 1');
		
	}

	@IsTest
	public static void createEpicCase(){

		testCreateBilling();

		Id caseEpicExtractionRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
		Id epicCredVerifRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();

		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		System.assert(testAccount.Id != null, 'Error! Account not created.');

		Contact testContact = [SELECT Id FROM Contact LIMIT 1];
		System.assert(testContact.Id != null, 'Error! Contact not created.');

		User runningUser = getCommunityUser();
		
		AcctSeed__GL_Account__c epicUnearnedAccount = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name = '0342-535-EPIC Unearned' LIMIT 1];
		System.assert(epicUnearnedAccount.Id != null, 'Error! Unearned Account not created.');

		AcctSeed__GL_Account__c epicReportRevenueAccount = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name = '0536-000-EPIC Report Revenue' LIMIT 1];
		System.assert(epicReportRevenueAccount.Id != null, 'Error! EPIC Report Revenue Account not created.');

		AcctSeed__Accounting_Variable__c company = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name = 'ECFMG' LIMIT 1];
		System.assert(company.Id != null, 'Error! Company not created.');

		AcctSeed__Accounting_Variable__c department = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name = '086-EPIC' LIMIT 1];
		System.assert(department.Id != null, 'Error! Department not created.');

		// ------------------------------------------------------------------------
		// Inserting 2 products
		// ------------------------------------------------------------------------
		List<Product2> products = new List<Product2>();
		// Product 0
		products.add(
			new Product2(
				Name = 'EPIC Report',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id,
				P2S_Requires_Record_Type__c = true
			)
		);
		// Product 1
		products.add(
			new Product2(
				Name = 'EPIC Registration',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id,
				P2S_Requires_Record_Type__c = true
			)
		);
		// Product 2
		products.add(
			new Product2(
				Name = 'EPIC Credential Verification',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id,
				P2S_Requires_Record_Type__c = true
			)
		);
		insert products;
		System.assert(products[0].Id != null, 'Error! Products not created.');


		// ------------------------------------------------------------------------
		// Inserting 2 Product2Service to tie the products to services
		// ------------------------------------------------------------------------
		List<Product2Service__c> product2Services = new List<Product2Service__c>();
		// Product2Service 0
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'EPIC Credentials Verification',
				Product__c = products[0].Id,
				Quantity__c = 1,
				Default__c = true,
				Subsidy_GL_Account__c = epicReportRevenueAccount.Id,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Complete',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Closed - No Longer Eligible',
				Fulfilled_Price_Date_Field__c = 'EP_End_Date__c',
				Record_Type_Name__c = 'Epic Extraction'
			)
		);
		// Product2Service 1
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'EPIC Credentials Verification',
				Product__c = products[1].Id,
				Quantity__c = 1,
				Default__c = true,
				Subsidy_GL_Account__c = epicReportRevenueAccount.Id,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Complete',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Closed - No Longer Eligible',
				Fulfilled_Price_Date_Field__c = 'EP_End_Date__c',
				Record_Type_Name__c = 'Epic Extraction'
			)
		);
		// Product2Service 2
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'EPIC Credentials Verification',
				Product__c = products[2].Id,
				Quantity__c = 1,
				Default__c = true,
				Subsidy_GL_Account__c = epicReportRevenueAccount.Id,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Complete',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Closed - No Longer Eligible',
				Fulfilled_Price_Date_Field__c = 'EP_End_Date__c',
				Record_Type_Name__c = 'Credential Verification'
			)
		);
		insert product2Services;
		System.assert(product2Services[0].Id != null, 'Error! Product2Services not created.');

		Date startOfMonth = Date.today().toStartOfMonth();
		Date endOfMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);
		Date startOfPreviousMonth = Date.today().addMonths(-1).toStartOfMonth();
		Date endOfPreviousMonth = Date.today().toStartOfMonth().addDays(-1);

		// ------------------------------------------------------------------------
		// Inserting 2 Product Details. One for each product.
		// ------------------------------------------------------------------------
		List<Product_Detail__c> productDetails = new List<Product_Detail__c>();
		// Product Detail for product 0
		productDetails.add(
			new Product_Detail__c(
				Product__c = products[0].Id,
				Start_Date__c = startOfMonth,
				End_Date__c = endOfMonth,
				Service_Fee__c = 200.0,
				Processing_Fee__c = 50.0
			)
		);
		// Product Detail for product 1
		productDetails.add(
			new Product_Detail__c(
				Product__c = products[1].Id,
				Start_Date__c = startOfPreviousMonth,
				End_Date__c = endOfPreviousMonth,
				Service_Fee__c = 200.0,
				Processing_Fee__c = 50.0
			)
		);
		// Product Detail for product 1
		productDetails.add(
			new Product_Detail__c(
				Product__c = products[2].Id,
				Start_Date__c = startOfPreviousMonth,
				End_Date__c = endOfPreviousMonth,
				Service_Fee__c = 200.0,
				Processing_Fee__c = 50.0
			)
		);
		insert productDetails;
		System.assert(productDetails[0].Id != null, 'Error! Product Details not created.');

		// Inserting a Case with a Case_Service__c. This will create case lines for this case.
		List<Case> caseList = new List<Case>();
		caseList.add(new Case(
			RecordTypeId = caseEpicExtractionRTId,
			AccountId = testAccount.Id,
			contactId = testContact.Id,
			Service__c = 'EPIC',
			Internal_Status__c = 'New',
			Keep_Processing_Fee__c = true,
			Subject = 'Test 1',
			Case_Service__c = 'EPIC Credentials Verification',
			Case_Service_Family__c = 'EPIC',
			Case_Service_Line__c = 'Credentials Verification',
			Origin = 'Phone',
			Priority = 'Medium',
			Status = 'Not Applicable'
		));
		caseList.add(new Case(
			RecordTypeId = caseEpicExtractionRTId,
			AccountId = testAccount.Id,
			contactId = testContact.Id,
			Service__c = 'EPIC',
			Internal_Status__c = 'New',
			Keep_Processing_Fee__c = true,
			Subject = 'Test 2',
			Case_Service__c = 'EPIC Credentials Verification',
			Case_Service_Family__c = 'EPIC',
			Case_Service_Line__c = 'Credentials Verification',
			Origin = 'Phone',
			Priority = 'Medium',
			Status = 'Not Applicable'
		));

		System.runAs(runningUser) {
			insert caseList;
		}
		System.assertEquals(2, [SELECT Id FROM Case_Line__c WHERE Case__c = :caseList[0].Id].size(), 'The amount of case lines for case 1 did not match the expected!');

		insert new Product_Detail__c(
			Product__c = products[1].Id,
			Start_Date__c = startOfMonth,
			End_Date__c = endOfMonth,
			Service_Fee__c = 300.0,
			Processing_Fee__c = 75.0
		);
		
	}

	@IsTest
	public static void forceCreateEpicCasesWithoutService(){

		Id caseEpicExtractionRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();

		List<Account> testAccount = [SELECT Id FROM Account LIMIT 1];
		
		List<Contact> testContact = [SELECT Id FROM Contact LIMIT 1];
		
		User runningUser = getCommunityUser();

		if (testAccount.size() == 0 || testContact.size() == 0 || runningUser == null) {
			return;
		}

		// Inserting a Case with a Case_Service__c. This will create case lines for this case.
		List<Case> caseList = new List<Case>();
		caseList.add(new Case(
			RecordTypeId = caseEpicExtractionRTId,
			AccountId = testAccount[0].Id,
			contactId = testContact[0].Id,
			Service__c = 'EPIC',
			Internal_Status__c = 'New',
			Keep_Processing_Fee__c = true,
			Subject = 'Case without service 1',
			Case_Service__c = 'EPIC Credentials Verification',
			Case_Service_Family__c = 'EPIC',
			Case_Service_Line__c = 'Credentials Verification',
			Origin = 'Phone',
			Priority = 'Medium',
			Status = 'Not Applicable'
		));
		caseList.add(new Case(
			RecordTypeId = caseEpicExtractionRTId,
			AccountId = testAccount[0].Id,
			contactId = testContact[0].Id,
			Service__c = 'EPIC',
			Internal_Status__c = 'New',
			Keep_Processing_Fee__c = true,
			Subject = 'Case without service 2',
			Case_Service__c = 'EPIC Credentials Verification',
			Case_Service_Family__c = 'EPIC',
			Case_Service_Line__c = 'Credentials Verification',
			Origin = 'Phone',
			Priority = 'Medium',
			Status = 'Not Applicable'
		));

		System.runAs(runningUser) {
			insert caseList;
		}
	}

	@IsTest
	public static void createProductsData(){

		testCreateBilling();

		Id appForCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();

		Account testAccount = [SELECT Id FROM Account LIMIT 1];
		System.assert(testAccount.Id != null, 'Error! Account not created.');

		Contact testContact = [SELECT Id FROM Contact LIMIT 1];
		System.assert(testContact.Id != null, 'Error! Contact not created.');
		
		AcctSeed__GL_Account__c epicUnearnedAccount = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name = '0342-535-EPIC Unearned' LIMIT 1];
		System.assert(epicUnearnedAccount.Id != null, 'Error! Unearned Account not created.');

		AcctSeed__GL_Account__c epicReportRevenueAccount = [SELECT Id, Name FROM AcctSeed__GL_Account__c WHERE Name = '0536-000-EPIC Report Revenue' LIMIT 1];
		System.assert(epicReportRevenueAccount.Id != null, 'Error! EPIC Report Revenue Account not created.');

		AcctSeed__Accounting_Variable__c company = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name = 'ECFMG' LIMIT 1];
		System.assert(company.Id != null, 'Error! Company not created.');

		AcctSeed__Accounting_Variable__c department = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name = '086-EPIC' LIMIT 1];
		System.assert(department.Id != null, 'Error! Department not created.');

		// ------------------------------------------------------------------------
		// Inserting products
		// ------------------------------------------------------------------------
		List<Product2> products = new List<Product2>();
		// Product 0
		products.add(
			new Product2(
				Name = 'Application for Certification',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		// Product 1
		products.add(
			new Product2(
				Name = 'ECFMG Cert Credential Verification',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		// Product 2
		products.add(
			new Product2(
				Name = 'IFOM',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		// Product 3
		products.add(
			new Product2(
				Name = 'IFOM Fee',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		// Product 4
		products.add(
			new Product2(
				Name = 'EPIC Report',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		// Product 5
		products.add(
			new Product2(
				Name = 'EPIC Report Fee',
				IsActive = true,
				AcctSeed__Revenue_GL_Account__c = epicUnearnedAccount.Id,
				Recognized_Revenue_GL_Account__c = epicReportRevenueAccount.Id,
				AcctSeed__GL_Account_Variable_1__c = company.Id,
				AcctSeed__GL_Account_Variable_2__c = department.Id
			)
		);
		insert products;
		System.assert(products[0].Id != null, 'Error! Products not created.');


		// ------------------------------------------------------------------------
		// Inserting Product2Service to tie the products to services
		// ------------------------------------------------------------------------
		List<Product2Service__c> product2Services = new List<Product2Service__c>();
		// Product2Service 0
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'Application for Certification',
				Product__c = products[0].Id,
				Quantity__c = 1,
				Default__c = true,
				Billing_Statuses__c = 'Submitted',
				Fulfillment_Statuses__c = 'Accepted;Expired;Pending Credential Verification;Rejected',
				Rejected_Statuses__c = 'CV Rejected'
			)
		);
		// Product2Service 1
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'Application for Certification',
				Product__c = products[1].Id,
				Quantity__c = 1,
				Default__c = true,
				Billing_Statuses__c = 'Submitted',
				Fulfillment_Statuses__c = 'Accepted;Expired;Pending Credential Verification;Rejected',
				Rejected_Statuses__c = 'CV Rejected'
			)
		);
		// Product2Service 2
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'IFOM',
				Product__c = products[2].Id,
				Quantity__c = 1,
				Default__c = true,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Submitted',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Resent',
				Invoiceable_Service__c = true
			)
		);
		// Product2Service 3
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'IFOM',
				Product__c = products[3].Id,
				Quantity__c = 1,
				Default__c = true,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Submitted',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Resent',
				Invoiceable_Service__c = true
			)
		);
		// Product2Service 4
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'EPIC Credentials Verification',
				Product__c = products[4].Id,
				Quantity__c = 1,
				Default__c = true,
				Subsidy_GL_Account__c = epicReportRevenueAccount.Id,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Complete',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Closed - No Longer Eligible',
				Fulfilled_Price_Date_Field__c = 'EP_End_Date__c'
			)
		);
		// Product2Service 5
		product2Services.add(
			new Product2Service__c(
				Case_Service__c = 'EPIC Credentials Verification',
				Product__c = products[5].Id,
				Quantity__c = 1,
				Default__c = true,
				Subsidy_GL_Account__c = epicReportRevenueAccount.Id,
				Billing_Statuses__c = 'Accepted',
				Fulfillment_Statuses__c = 'Complete',
				Rejected_Statuses__c = 'Rejected',
				Cancelled_Statuses__c = 'Closed - No Longer Eligible',
				Fulfilled_Price_Date_Field__c = 'EP_End_Date__c'
			)
		);
		insert product2Services;
		System.assert(product2Services[0].Id != null, 'Error! Product2Services not created.');

		Date startOfMonth = Date.today().toStartOfMonth();
		Date endOfMonth = Date.today().addMonths(1).toStartOfMonth().addDays(-1);

		// ------------------------------------------------------------------------
		// Inserting 2 Product Details. One for each product.
		// ------------------------------------------------------------------------
		List<Product_Detail__c> productDetails = new List<Product_Detail__c>();
		// Product Detail for product 0
		productDetails.add(
			new Product_Detail__c(
				Product__c = products[0].Id,
				Start_Date__c = startOfMonth,
				End_Date__c = endOfMonth,
				Service_Fee__c = 100.0,
				Processing_Fee__c = 25.0
			)
		);
		// Product Detail for product 1
		productDetails.add(
			new Product_Detail__c(
				Product__c = products[1].Id,
				Start_Date__c = startOfMonth,
				End_Date__c = endOfMonth,
				Service_Fee__c = 200.0,
				Processing_Fee__c = 50.0
			)
		);
		insert productDetails;
		System.assert(productDetails[0].Id != null, 'Error! Product Details not created.');
		
	}


	public static void createIFOMCaseWithCaseLines(String accountName, Integer count){

		if (count < 1) {
			return;
		}

		Account entityAccount = new Account(Name = accountName, Invoiceable_Client__c = true);
		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, entityAccount);
		run();
		System.assert(entityAccount.Id != null, 'Account not created');

		Contact entityContact = new Contact(
			AccountId = entityAccount.Id,
			LastName = accountName + 'Contact',
			Email = accountName.replaceAll(' ', '') + '.test@user.com'
		);
		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, entityContact);
		run();
		System.assert(entityContact.Id != null, 'Contact not created');

		Id iFOMRequestRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_IFOM).getRecordTypeId();

		List<Case> newCasesList = new List<Case>();
		for (Integer i = 0; i < count; i++) {
			newCasesList.add( new Case(
				Subject = 'IFOM Case ' + (i+1),
				RecordTypeId = iFOMRequestRTId,
				ContactId = entityContact.Id,
				AccountId = entityAccount.Id,
				Client_Account_Name__c = entityAccount.Id,
				Internal_Status__c = 'New',
				Case_Service__c = 'IFOM'
			));
		}

		insert newCasesList;
		
	}
}