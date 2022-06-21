public without sharing class ShoppingCartController {

	// =========================================================================================
	// This method returns the currently logged in user record.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static User getCurrentUser() {
		return [SELECT Id, Name, ContactId FROM User  WHERE Id = :UserInfo.getUserId()];
	}

	// =========================================================================================
	// This method returns the currently logged in user's contact.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static Contact getCurrentUsersContact() {
		try {
			return [SELECT Id, Name, FirstName, LastName, AccountId, MailingAddress, Email FROM Contact WHERE Id = :getCurrentUser().ContactId LIMIT 1];
		} catch (Exception e) {
			return null;
		}
	}

	// =========================================================================================
	// This method returns the currently logged in user's contact Id.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static String getCurrentUsersContactId(){
		return [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1]?.ContactId;
	}

	// =========================================================================================
	// This method returns the currently logged in user's account.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static Account getCurrentUsersAccount() {
		return [SELECT Id, Name FROM Account WHERE Id = :getCurrentUsersContact().AccountId LIMIT 1];
	}

	// =========================================================================================
	// This method queries all the cases for a given case id list.
	// =========================================================================================
	@AuraEnabled
	public static List<Case> getCases(List<String> caseRecordIds) {
		try {
			List<Case> cases = new List<Case>(
				[SELECT Id, CaseNumber, AccountId, Case_Status__c 
				FROM Case 
				WHERE AccountId = :getCurrentUsersAccount().Id AND Id IN :caseRecordIds]
			);

			if (cases.size() <= 0) {
				return null;
			}
			return cases;

		} catch (Exception e) {
			System.debug('An error occurred while trying to get the current user\'s case lines: ' + e.getMessage());
			return null;
		}
	}

	// =========================================================================================
	// This method queries all the case lines for a given case id list.
	// =========================================================================================
	@AuraEnabled
	public static List<Case_Line__c> getCaseLines(List<String> caseRecordIds) {
		try {
			Map<Id, Case> cases = new Map<Id, Case>(getCases(caseRecordIds));
			System.debug('Cases: ' + cases.values());

			// Get case lines from the cases on the previous step.
			List<Case_Line__c> caseLines = [SELECT Id, Name, Accounting_Status__c, Case__c, Date__c, Fulfilled_Amount__c, Price__c, Processing_Fee_Formula__c, Product__c, Product_Detail__c, Product_Detail__r.Product__c, 
			Product2Service__c, Product2Service__r.Product__c, Quantity__c, Total__c
			FROM Case_Line__c WHERE Case__c IN :cases.keySet() AND Accounting_Status__c = 'New'];
			System.debug('Case lines: ' + caseLines);
			Map<Id, Case_Line__c> caseLinesMap = new Map<Id, Case_Line__c>(caseLines);

			if (caseLinesMap.values().size() <= 0) {
				return null;
			}

			// Creating a set of product ids to get the product details.
			Set<Id> productIds = new Set<Id>();
			for (Case_Line__c caseLine : caseLinesMap.values()) {
				productIds.add(caseLine.Product_Detail__r.Product__c);
			}

			// Creating a map with the Id of the product as key and the active Product_Detail__c as value.
			Map<Id, Product_Detail__c> activeProductDetailsMap = getActiveProductDetails(productIds);

			// The list of case lines to update.
			List<Case_Line__c> caseLinesToUpdate = new List<Case_Line__c>();

			for (Case_Line__c caseLine : caseLinesMap.values()) {
				Id productId = caseLine.Product_Detail__r.Product__c;
				// Validating that the map contains a value for the current product/caseLine
				if (activeProductDetailsMap.containsKey(productId)) {
					Product_Detail__c activeProductDetail = activeProductDetailsMap.get(productId);
					// If the active and current Product_Detail__c aren't the same, update them.
					if (caseLine.Product_Detail__c != activeProductDetail.Id) {
						caseLine.Product_Detail__c = activeProductDetail.Id;
						caseLine.Price__c = activeProductDetail.Service_Fee__c;
						caseLinesToUpdate.add(caseLine);
					} 
				} // For now, if the product detail isn't found do nothing.
			}

			if (caseLinesToUpdate.size() > 0) {
				update caseLinesToUpdate;
				caseLines = [SELECT Id, Name, Accounting_Status__c, Case__c, Date__c, Fulfilled_Amount__c, Price__c, Processing_Fee_Formula__c, Product__c, Product_Detail__c, Product_Detail__r.Product__c, 
				Product2Service__c, Product2Service__r.Product__c, Quantity__c, Total__c
				FROM Case_Line__c WHERE Id IN :caseLinesMap.keySet()];
			}
			return caseLines;

		} catch (Exception e) {
			System.debug('An error occurred while trying to get the current user\'s case lines: ' + e.getMessage());
			return null;
		}
	}

	// =========================================================================================
	// This method queries the different credits for the current account and returns the total 
	// amount.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static Decimal getCredits() {
		try {
			List<Id> accountId = new List<Id>{ getCurrentUsersAccount().Id };
			return getCredits(accountId).get(accountId[0]);
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<Id, Decimal> getCredits(List<Id> accountIds) {
		try {
			Map<Id, Decimal> creditsMap = new Map<Id, Decimal>();
			for (Id accountId : accountIds) {
				creditsMap.put(accountId, 0.0);
			}

			// This query returns the unapplied credits and adds them to the total for each applicant.
			for(AcctSeed__Billing__c billing : [SELECT Id, AcctSeed__Balance__c, AcctSeed__Status__c, AcctSeed__Customer__c
																					FROM AcctSeed__Billing__c 
																					WHERE AcctSeed__Customer__c IN :accountIds AND AcctSeed__Balance__c < 0 AND AcctSeed__Status__c = 'Posted' ORDER BY AcctSeed__Customer__c]) {
				Id accountId = billing.AcctSeed__Customer__c;
				Decimal credit = creditsMap.get(accountId) - billing.AcctSeed__Balance__c;
				creditsMap.put(accountId, credit);
			}

			for(AcctSeed__Cash_Receipt__c cashReceipt : [SELECT Id, AcctSeed__Balance__c, AcctSeed__Status__c, AcctSeed__Account__c 
																									FROM AcctSeed__Cash_Receipt__c 
																									WHERE AcctSeed__Account__c IN :accountIds AND AcctSeed__Balance__c != 0 AND AcctSeed__Status__c = 'Posted' ORDER BY AcctSeed__Account__c]) {
				Id accountId = cashReceipt.AcctSeed__Account__c;
				Decimal credit = creditsMap.get(accountId) + cashReceipt.AcctSeed__Balance__c;
				creditsMap.put(accountId, credit);
			}

			return creditsMap;
		} catch (Exception e) {
			System.debug('An error occurred while trying to get the current user\'s unpaid balances: ' + e.getMessage());
			return null;
		}
	}

	// =========================================================================================
	// This method queries the unpaid balances for the current account and returns the total 
	// amount.
	// =========================================================================================
	@AuraEnabled(cacheable=true)
	public static Decimal getUnpaidBalances() {
		try {
			List<Id> accountId = new List<Id>{ getCurrentUsersAccount().Id };
			return getUnpaidBalances(accountId).get(accountId[0]);
		} catch (Exception e) {
			return null;
		}
	}

	public static Map<Id, Decimal> getUnpaidBalances(List<Id> accountIds) {
		try {
			Map<Id, Decimal> unpaidBalancesMap = new Map<Id, Decimal>();
			for (Id accountId : accountIds) {
				unpaidBalancesMap.put(accountId, 0.0);
			}

			// This query returns the unapplied credits and adds them to the total for each applicant.
			List<AcctSeed__Billing__c> billings = [SELECT Id, AcctSeed__Balance__c, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE AcctSeed__Customer__c IN :accountIds AND AcctSeed__Status__c = 'Posted' AND AcctSeed__Balance__c > 0 ORDER BY AcctSeed__Customer__c];
			for(AcctSeed__Billing__c billing : billings) {
				Id accountId = billing.AcctSeed__Customer__c;
				Decimal unpaidBalance = unpaidBalancesMap.get(accountId) + billing.AcctSeed__Balance__c;
				unpaidBalancesMap.put(accountId, unpaidBalance);
			}
			return unpaidBalancesMap;

		} catch (Exception e) {
			System.debug('An error occurred while trying to get the current user\'s unpaid balances: ' + e.getMessage());
			return null;
		}
	}

	// =========================================================================================
	// This method gets the current Product_Detail__c for a given product
	// =========================================================================================
	public static Map<Id, Product_Detail__c> getActiveProductDetails(Set<Id> productIds) {
		try {

			Map<Id, Product_Detail__c> productDetailsMap = new Map<Id, Product_Detail__c>();

			// Get the active product details for today's date.
			for (Product_Detail__c productDetail : [SELECT Id, Name, Start_Date__c, End_Date__c, Product__c, Service_Fee__c FROM Product_Detail__c WHERE Product__c IN :productIds AND Start_Date__c <= TODAY AND End_Date__c >= TODAY]) {
				productDetailsMap.put(productDetail.Product__c, productDetail);
			}

			// Getting all the products that didn't find a product detail.
			List<Id> productIdsWithoutPrice = new List<Id>();
			for (Id productId : productIds) {
				if (!productDetailsMap.containsKey(productId)) {
					productIdsWithoutPrice.add(productId);
				}
			}

			if (productIdsWithoutPrice.size() > 0) {
				// Getting product details for every product that doesn't have one.
				for (Product_Detail__c productDetail : [SELECT Id, Name, Start_Date__c, End_Date__c, Product__c, Service_Fee__c FROM Product_Detail__c 
				WHERE Product__c IN :productIdsWithoutPrice AND Start_Date__c <= TODAY ORDER BY Start_Date__c DESC]) {
					Id productId = productDetail.Product__c;
					if (!productDetailsMap.containsKey(productId)) {
						productDetailsMap.put(productId, productDetail);
					}
				}
			}
			
			return productDetailsMap;

		} catch (Exception e) {
			System.debug('An error occurred while trying to get the active product detail records: ' + e.getMessage());
			return null;
		}
	}

	@AuraEnabled
	public static String createChargentOrder(Decimal chargeAmount, List<String> caseRecordIds, String caseNumbers,  Boolean singleCase){
		try {

			Id gatewayId = [SELECT Id, Default_Gateway__c FROM AcctSeed__Accounting_Variable__c WHERE Name = 'ECFMG' AND AcctSeed__Type__c = 'GL Account Variable 1'].Default_Gateway__c;

			List<Case> caseRecords = [SELECT Id, Case_Service__c FROM Case WHERE Id IN :caseRecordIds];

			Contact currentContact = getCurrentUsersContact();

			String state = currentContact.MailingAddress?.getState();
			if (state == null) {
				state = 'Outside US';
			}

			ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c(
				Contact__c = currentContact.Id,
				ChargentOrders__Billing_First_Name__c = currentContact.FirstName,
				ChargentOrders__Billing_Last_Name__c = currentContact.LastName,
				ChargentOrders__Account__c = currentContact.AccountId,
				ChargentOrders__Billing_Email__c = currentContact.Email,
				ChargentOrders__Billing_State__c = state,
				ChargentOrders__Charge_Amount__c = chargeAmount,
				ChargentOrders__Subtotal__c = chargeAmount,
				ChargentOrders__Manual_Charge__c = true,
				ChargentOrders__Gateway__c = gatewayId,
				Case_Numbers__c = caseNumbers
			);
			if (currentContact.MailingAddress != null) {
				order.ChargentOrders__Billing_Address__c = currentContact.MailingAddress.getStreet();
				order.ChargentOrders__Billing_City__c = currentContact.MailingAddress.getCity();
				order.ChargentOrders__Billing_Country__c = currentContact.MailingAddress.getCountry();
				order.ChargentOrders__Billing_Zip_Postal__c = currentContact.MailingAddress.getPostalCode();
			}
			if (caseRecords.size() > 0) {
				order.Case_Service__c = caseRecords[0].Case_Service__c;
				if (singleCase) {
					order.Case__c = caseRecords[0].Id;
				}
			}

			insert order;

			return order.Id;

		} catch (Exception e) {
			System.debug('An error occurred while trying to create the chargent order: ' + e.getMessage());
			return null;
		}
	}

	// =========================================================================================
	// This method returns the currently logged in user's account balance.
	// =========================================================================================
	@AuraEnabled
	public static Decimal getAccountBalance(){
		try {

			Decimal total = 0.0;

			// Getting the ammount from unpaid balances
			total += getUnpaidBalances();

			// Getting the ammount from credits
			total -= getCredits();

			return total;

		} catch (Exception e) {
			System.debug('An error occurred while trying to getAccountBalance: ' + e.getMessage());
			return null;
		}
	}

	public static Map<Id, Boolean> getApplicantsBalance(Map<Id, Contact> applicantsMap) {
		Map<Id, Boolean> applicantsFinancialCheck = new Map<Id, Boolean>();

		Map<Id, Decimal> credits = getCredits(new List<Id> (applicantsMap.keySet()));
		Map<Id, Decimal> unpaidBalances = getUnpaidBalances(new List<Id> (applicantsMap.keySet()));

		for (Contact contactRecord : applicantsMap.values()) {
			Id contactId = contactRecord.Id;
			Decimal total = credits.get(contactId) - unpaidBalances.get(contactId);
			Boolean check = total >= 0.0? true : false;
			applicantsFinancialCheck.put(contactRecord.Id, check);
		}

		return applicantsFinancialCheck;
	}
}