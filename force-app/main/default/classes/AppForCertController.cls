/**
 * Helper class for AppCert Valdiation
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   19-DEC-2019
 */

/* AppForCertControllerTest
*/
public with sharing class AppForCertController {

	public static Set<Case> casesToRejectFinal = new Set<Case>();
	//Method to send message if the country is in the OFAC's warning category
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageOFACSoft(String accountId) {
		Boolean isAccountInOFAC = False;

		Map<String,
			OFAC__c > ofacCountriesMap = ServicesComponentController.getOFACCountryList();
		if (!ofacCountriesMap.isEmpty() && accountId != null) {

			Account thisAccount = [Select id, BillingCountry from Account where id =: accountId Limit 1];
			if (ofacCountriesMap.containsKey(thisAccount.BillingCountry) && ofacCountriesMap.get(thisAccount.BillingCountry).type__c == System.Label.OFAC_Country_Warning) {
				isAccountInOFAC = True;
			}
		}
		return isAccountInOFAC;
	}

	//Method to send message if the Mailing country is in the OFAC's warning category on profile page
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageOFACContact() {
		Boolean isContactInOFAC = False;

		Map<String,
			OFAC__c > ofacCountriesMap = ServicesComponentController.getOFACCountryList();
		if (!ofacCountriesMap.isEmpty()) {

			Id contactId = AppforCertHelper.retrieveCurrentContactId();
			if (contactId != null) {
				Contact thisContact = [Select id, MailingCountry from Contact where id =: contactId Limit 1];
				if (ofacCountriesMap.containsKey(thisContact.MailingCountry) && ofacCountriesMap.get(thisContact.MailingCountry).type__c == System.Label.OFAC_Country_Warning) {
					isContactInOFAC = True;
				}
			}
		}
		return isContactInOFAC;
	}

	//Method to send error message if the current date is not between from and to date
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageCurrentDate(String type, Date fromDate, Date toDate) {
		Boolean returnVal = False;
		Date currentDate = Date.Today();

		if (type != '' && fromDate != null && toDate != null && type == System.Label.Medical_Education_type_Student && (fromDate > currentDate || toDate<currentDate)) {

			returnVal = True;
		}
		return returnVal;
	}

	/**
	 * Created by Femi
	 * Method Name: toAndFromDateValidation
	 * Purpose : Method to check whether the to and from dates are future dates
	 * Return Type : Boolean
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean toAndFromDateValidation(Date fromDate, Date toDate) {
		Boolean returnVal = False;
		Date currentDate = Date.Today();

		if (fromDate > currentDate || toDate > currentDate) {

			returnVal = True;
		}
		return returnVal;
	}

	/**
	 * Created by Chinmay Menon
	 * Method Name: getSchoolRecords
	 * Purpose : Method to get the list of ECFMG approved schools
	 * Return Type : List of the Account records
	 */
	@AuraEnabled(Cacheable = true)
	public static List<Account> getSchoolRecords() {
		return [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
			FROM Account
			WHERE recordType.DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY
			AND School__c = true
		];
	}
	// Method to delete saved Other Institutions and related Transfer Credit and Asset records if the Transfer Credits Checkbox is unchecked
	@AuraEnabled
	public static string deleteOtherInstitutions(String contactId, String parentCaseId, String caseId){
		List<Contact_Association_Type_Staging__c> otherInstList = 
			new List<Contact_Association_Type_Staging__c>([SELECT Id,
				(SELECT Id FROM Transfer_Credits__r),
				(SELECT Id FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND
				Parent_Case__c =: parentCaseId AND
				(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG)
				ORDER BY createdDate ASC
			]);
		List<Contact_Association_Type_Staging__c> otherInstitutionsToDel = new List<Contact_Association_Type_Staging__c>();
		List<Transfer_Credit__c> otherInstitutionsTCsToDel = new List<Transfer_Credit__c> ();
		List<Asset> otherInstitutionsAssetsToDel = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		for(Contact_Association_Type_Staging__c tempconAssocStag: otherInstList){
			otherInstitutionsToDel.add(tempconAssocStag);
			if(!tempconAssocStag.Transfer_Credits__r.isEmpty()){
				for(Transfer_Credit__c tcObjTemp: tempconAssocStag.Transfer_Credits__r){
					otherInstitutionsTCsToDel.add(tcObjTemp);
				}
			}
			RecordType assetMarkedForDeletionRT = rts[0];
			if(!tempconAssocStag.Assets__r.isEmpty()){
				for(Asset a: tempconAssocStag.Assets__r){
					Asset asst = new Asset();
					asst.Id = a.Id;
					asst.Parent_Case__c = null;
					asst.case__c = null;
					asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
					asst.RecordTypeId = assetMarkedForDeletionRT.Id;
					otherInstitutionsAssetsToDel.add(asst);
				}
			}
		}
		markTctAssetsForDeletion(contactId, parentCaseId);
		return deleteOtherInstitutionsRefactor(otherInstitutionsToDel, otherInstitutionsTCsToDel, otherInstitutionsAssetsToDel);
	}
	//method to reduce complexity of deleteOtherInstitutions
	public static string deleteOtherInstitutionsRefactor(List<Contact_Association_Type_Staging__c> otherInstitutionsToDel, List<Transfer_Credit__c> otherInstitutionsTCsToDel, List<Asset> otherInstitutionsAssetsToDel) {
		try{
			if(Contact_Association_Type_Staging__c.SObjectType.getDescribe().isDeletable()){
				DELETE otherInstitutionsToDel;
			}
			if(Transfer_Credit__c.SObjectType.getDescribe().isDeletable()){
				DELETE otherInstitutionsTCsToDel;
			}
			if(Asset.SObjectType.getDescribe().isUpdateable()){
				UPDATE otherInstitutionsAssetsToDel;
			}
			return 'true';
		}catch(exception e){
			return String.valueOf(e);
		}
	}

	//Method to delete saved Transfer Credit and Asset records if the Transfer Credits Checkbox is unchecked
	@AuraEnabled
	public static string deleteUncheckedTransferCreditAndAsset(String contactId, String parentCaseId, String caseId){
		List<Contact_Association_Type_Staging__c > otherMedSchoolList =
			new List<Contact_Association_Type_Staging__c > ([SELECT Id, Transfer_Credit_to_Degree_School__c,
				(SELECT Id FROM Transfer_Credits__r),
				(SELECT Id FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND
				Parent_Case__c =: parentCaseId AND
				recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL
				ORDER BY createdDate ASC
			]);
		List<Transfer_Credit__c> creditsToDel = new List<Transfer_Credit__c>();
		List<Asset> assetsToDel = new List<Asset>();
		List<RecordType> recTypeToDel = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		RecordType assetMarkedForDeletionRT = recTypeToDel[0];
		for(Contact_Association_Type_Staging__c tempconAssocStag: otherMedSchoolList){	
			if(!tempconAssocStag.Transfer_Credit_to_Degree_School__c){
				if(!tempconAssocStag.Transfer_Credits__r.isEmpty()){
					creditsToDel = deleteUncheckedTcAndAssetRefactorCont(tempconAssocStag.Transfer_Credits__r);
				}
				if(!tempconAssocStag.Assets__r.isEmpty()){
					for(Asset a: tempconAssocStag.Assets__r){
						Asset asst = new Asset();
						asst.Id = a.Id;
						asst.Parent_Case__c = null;
						asst.case__c = null;
						asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
						asst.RecordTypeId = assetMarkedForDeletionRT.Id;
						assetsToDel.add(asst);
					}
				}
			}
		}
		return deleteUncheckedTcAndAssetRefactor(creditsToDel, assetsToDel);
	}
	//method to reduce complexity of deleteUncheckedTransferCreditAndAsset
	@AuraEnabled
	public static string deleteUncheckedTcAndAssetRefactor(List<Transfer_Credit__c> tCsToDel, List<Asset> assetsToDel){
		try{
			if(Transfer_Credit__c.SObjectType.getDescribe().isDeletable()){
				DELETE tCsToDel;
			}
			if(Asset.SObjectType.getDescribe().isUpdateable()){
				UPDATE assetsToDel;
			}
			return 'true';
		}catch(exception e){
			return String.valueOf(e);
		}
	}
	//Continuation of deleteUncheckedTransferCreditAndAsset Method to delete saved Transfer Credit and Asset records if the Transfer Credits Checkbox is unchecked
	@AuraEnabled(Cacheable = true)
	public static List<Transfer_Credit__c> deleteUncheckedTcAndAssetRefactorCont(List<Transfer_Credit__c> tcObjList){
		List<Transfer_Credit__c> returnTCList = new List<Transfer_Credit__c>();
		for(Transfer_Credit__c tcObjTemp : tcObjList){
			returnTCList.add(tcObjTemp);
		}
		return returnTCList;
	}
	/**
	 * Created by Chinmay Menon
	 * Method Name: getOtherMedicalSchoolRecords
	 * Purpose : Method to get the list of ECFMG approved schools except for the degree medical school selected
	 * Return Type : List of the Account records
	 */
	@AuraEnabled(Cacheable = true)
	public static List<Account> getOtherMedicalSchoolRecords() {

		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		Id selectedDegMedSchoolId = null;

		List<case >newCases = [SELECT id FROM Case
				WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
			];

		if (!newCases.isEmpty()) {
			List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c > ();
			existingConAssoStagingObjList = [SELECT id, Account__c FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: newCases[0].id
			];
			if (!existingConAssoStagingObjList.isEmpty()) {
				selectedDegMedSchoolId = existingConAssoStagingObjList[0].Account__c;
			}
		} else {
			List<Contact_Association_Type__c > existingConAssoObjList = new List<Contact_Association_Type__c > ();
			existingConAssoObjList = [SELECT ID, Account__c From Contact_Association_Type__c
				WHERE Contact__c =: contactId and recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
			];
			if (!existingConAssoObjList.isEmpty()) {
				selectedDegMedSchoolId = existingConAssoObjList[0].Account__c;
			}
		}

		return [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
			FROM Account
			WHERE recordType.DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY
			AND
			School__c = true AND
			id !=: selectedDegMedSchoolId
		];
	}

	//Method to get the list of ECFMG approved schools
	@AuraEnabled(Cacheable = true)
	public static List<Account> getSchoolRecordsOthers() {

		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		Id selectedDegMedSchoolId = null;

		List<case >newCases = [SELECT id FROM Case
				WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
			];

		if (!newCases.isEmpty()) {
			List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c > ();
			existingConAssoStagingObjList = [SELECT id, Account__c FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: newCases[0].id
			];
			if (!existingConAssoStagingObjList.isEmpty()) {
				selectedDegMedSchoolId = existingConAssoStagingObjList[0].Account__c;
			}
		} else {
			List<Contact_Association_Type__c > existingConAssoObjList = new List<Contact_Association_Type__c > ();
			existingConAssoObjList = [SELECT ID, Account__c From Contact_Association_Type__c
				WHERE Contact__c =: contactId and recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
			];
			if (!existingConAssoObjList.isEmpty()) {
				selectedDegMedSchoolId = existingConAssoObjList[0].Account__c;
			}
		}

		return [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
			FROM Account
			WHERE recordType.DeveloperName =: Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY AND(Sponsoring_Institution__c = true OR School__c = true) AND
			id !=: selectedDegMedSchoolId
		];

	}
	/**
	 * Created by Chinmay
	 * Modified by AJOYDHAS.M.A
	 * Modified by Nayana
	 * Method Name: getContactAssociationOrStaging
	 * Purpose : Method to fetch degree medical school data to auto populate on the applicant screen
	 * Parameters : showExamRegActionButton (From Exam Reg Page Flag)
	 * Return Type : String
	 */
	@AuraEnabled
	public static String getContactAssociationOrStaging(Boolean showExamRegActionButton) {
		String valuesToReturn = '';
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		if (contactId != null) {
			List<case >newCases = [SELECT id, Internal_Status__c FROM Case
					WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
					AND ContactId =: contactId
					AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
				];

			// Get Case Status - Record Type Application_For_Certification
			String caseStatus = '';
			if (!newCases.isEmpty()) {
				caseStatus = newCases[0].Internal_Status__c;
			}

			if (!newCases.isEmpty() && caseStatus != Constants.CASE_STATUS_ACCEPTED && showExamRegActionButton == false) {
				List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = [SELECT id FROM Contact_Association_Type_Staging__c WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
					AND Parent_Case__c =: newCases[0].id
				];
				if (!existingConAssoStagingObjList.isEmpty()) {
					valuesToReturn = String.valueOf(existingConAssoStagingObjList[0].id) + ',Contact_Association_Type_Staging__c,' + caseStatus;
				}
			} else {
				List<Contact_Association_Type__c > existingConAssoObjList = [SELECT ID From Contact_Association_Type__c WHERE Contact__c =: contactId and recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL];
				if (!existingConAssoObjList.isEmpty()) {
					valuesToReturn = String.valueOf(existingConAssoObjList[0].id) + ',Contact_Association_Type__c,' + caseStatus;
				}
			}
		}
		return valuesToReturn;
	}

	/**
	 * Created by Nayana
	 * Method Name: getContactAssociationStagingExamReg
	 * Purpose : Method to fetch degree medical school data to populate on the summary screen
	 * Return Type : String
	 */
	@AuraEnabled
	public static Contact_Association_Type_Staging__c getContactAssociationStagingExamReg(Boolean showExamRegActionButton, Boolean showCaseDetail) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = getCaseIdAllStatus(showCaseDetail, contactId);

		String recordTypeDeveloperName;
		if (showExamRegActionButton == true) {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
		} else {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
		}
		//code added by Shailaja. Date Format Stories. Added new fields to the query.
		String catsQuery = 'SELECT ID, Status__c, Specialty__c, Account_Name__c, School_Program__c, Number_of_Years_Attended__c, ' +
			'Graduation_Month__c, Graduation_Year__c, Degree_Title__c, Student_ID__c, Start_Date__c, Start_Month__c, Start_Year__c, End_Date__c, Degree_Issue_Date__c,End_Month__c, Degree_Issue_Month__c,End_Year__c, Degree_Issue_Year__c ' +
			'From Contact_Association_Type_Staging__c WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName';

		if (!showExamRegActionButton && caseId != null) {
			catsQuery += ' AND Parent_Case__c =: caseId';
		}

		Contact_Association_Type_Staging__c catsToReturn = new Contact_Association_Type_Staging__c();
		List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c > ();
		if (contactId != null) {
			existingConAssoStagingObjList = Database.query(catsQuery);
		}
		if (!existingConAssoStagingObjList.isEmpty()) {
			catsToReturn = existingConAssoStagingObjList[0];
		}
		return catsToReturn;
	}

	// Method to fetch degree medical school data to populate on the summary section of case detail page 
	@AuraEnabled
	public static Contact_Association_Type__c getContactAssociationForCaseDetail(){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		String recordTypeDeveloperName = Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL;
		//code added by Shailaja. Date format stories. New fields added to the query.
		Contact_Association_Type__c catToReturn = new Contact_Association_Type__c();
		List<Contact_Association_Type__c> existingConAssoObjList = new List<Contact_Association_Type__c>();
		if(contactId != null){
			existingConAssoObjList = [SELECT ID, Case__c, Parent_Case__r.Internal_Status__c, Case__r.Internal_Status__c, Status__c, Specialty__c, Account_Name__c,
				School_Program__c, Number_of_Years_Attended__c, Graduation_Month__c, Graduation_Year__c, Degree_Title__c, Student_ID__c,
				Start_Date__c, Start_Month__c, Start_Year__c, End_Date__c, End_Month__c, End_Year__c, Degree_Issue_Date__c, Degree_Issue_Month__c, Degree_Issue_Year__c, 
				IsDeanLetter__c, Courier_service_for_an_additional_fee__c, Credential_Type__c
				FROM Contact_Association_Type__c
				WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName
			];
		}
		if(!existingConAssoObjList.isEmpty()){
			catToReturn = existingConAssoObjList[0];
		}
		return catToReturn;
	}
	// Method to parsing the values from Deg med School Page
	public static Map<String, String> degMedSchoolFrmVals(String fieldvals){
		Map<String, String> fieldvalmap = new Map<String, String>();
		String tempKey,
		tempValue;
		JSONParser parsedMap = JSON.createParser(fieldvals);
		while(parsedMap.nextToken() != null){
			if(parsedMap.getCurrentToken() == JSONToken.FIELD_NAME){
				tempKey = parsedMap.getText();
				JSONToken tok = parsedMap.nextToken();
				if(tok != JSONToken.VALUE_NULL){
					tempValue = parsedMap.getText();
					fieldvalmap.put(tempKey, tempValue);
				}else{
					fieldvalmap.put(tempKey, '');
				}
			}
		}
		return fieldvalmap;
	}
	// Method to get Case ID. If not available, create new Case Id
	public static Id getAppForCertCaseId(){
		Id currentUser = UserInfo.getUserId();
		List<User> userList = [select contactId, Contact.AccountId from User u where u.Id =: currentUser]; // Dont use WITH SECURITY_ENFORCED
		Id contactId = userList[0].contactId;
		Id accountId = userList[0].Contact.AccountId;
		Id caseId;
		Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();		
		List<Case> appforCertCase = [SELECT Id FROM Case WHERE ContactId =: contactId AND RecordTypeId =: appCertRecordTypeId AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED AND Case_Status__c !=: Constants.CASE_STATUS_CANCELLED AND Case_Status__c !=: Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED];
		if(!appforCertCase.isEmpty()){
			caseId = appforCertCase[0].Id;
		}else{
			Case newCase = new Case(
				RecordTypeId = appCertRecordTypeId, ContactId = contactId, AccountId = accountId, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION);
				if(Case.SObjectType.getDescribe().isCreateable()){
					Insert newCase;
				}
			caseId = newCase.Id;
		}
		return caseId;
	}
	//Method to create and updatnewCaseselated records
	@AuraEnabled
	public static String manageAppforCertCases(String fieldvals, Boolean defscreen){
		Map<String, String> fieldvalmap = degMedSchoolFrmVals(fieldvals);
		String recordTypeDeveloperName;
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = getAppForCertCaseId();
		Contact_Association_Type__c catRecord = getContactAssociationForCaseDetail();
		Boolean isDeanLetter = false;
		Boolean courierServiceAdditionalFee = false;
		String credentialType = '';
		String caseFMDInternalStatus = '';
		if(fieldvalmap.get('showExamRegActionButton') == 'true'){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
			isDeanLetter = catRecord.IsDeanLetter__c;
			courierServiceAdditionalFee = catRecord.Courier_service_for_an_additional_fee__c;
			credentialType = catRecord.Credential_Type__c;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
			if(catRecord != null && (catRecord.Parent_Case__c != null && catRecord.Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_EXPIRED)){
				isDeanLetter = catRecord.IsDeanLetter__c;
				courierServiceAdditionalFee = catRecord.Courier_service_for_an_additional_fee__c;
				credentialType = catRecord.Credential_Type__c;
				if(credentialType == Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA){
					caseFMDInternalStatus = catRecord.Case__r.Internal_Status__c;
				}
			}
		}
		Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		List<Contact_Association_Type_Staging__c> degMedSchStaging = [Select Id, Account__c, Case__c, Contact__c, Number_of_Years_Attended__c, Degree_Issue_Date__c, Graduation_Year__c, Degree_Title__c, End_Date__c, Graduation_Date__c, Graduation_Month__c, RecordTypeId, School_Program__c, Specialty__c, Start_Date__c, Status__c, Student_ID__c, Type__c From Contact_Association_Type_Staging__c Where Case__c =: caseId And RecordTypeId =: degMedSchRecordTypeId WITH SECURITY_ENFORCED];
		Id degMedSchoolId;
		if(!degMedSchStaging.isEmpty()){
			Contact_Association_Type_Staging__c updDegMedSchStaging = degMedSchStaging[0];
			updDegMedSchStaging.Account__c = fieldvalmap.get('Account__c');
			updDegMedSchStaging.Number_of_Years_Attended__c = Decimal.valueOf(fieldvalmap.get('Number_of_Years_Attended__c'));
			//Code commented as Date eplaced by Month & Year.			
			updDegMedSchStaging.Degree_Title__c = fieldvalmap.get('Degree_Title__c');
			//code added by Shailaja.
			updDegMedSchStaging.Start_Month__c = fieldvalmap.get('Start_Month__c');
			updDegMedSchStaging.Start_Year__c = fieldvalmap.get('Start_Year__c');
			updDegMedSchStaging.End_Month__c = fieldvalmap.get('End_Month__c');
			updDegMedSchStaging.End_Year__c = fieldvalmap.get('End_Year__c');
			updDegMedSchStaging.Degree_Issue_Month__c = fieldvalmap.get('Degree_Issue_Month__c');
			updDegMedSchStaging.Degree_Issue_Year__c = fieldvalmap.get('Degree_Issue_Year__c');
			updDegMedSchStaging.Graduation_Year__c = fieldvalmap.get('gradYear');
			updDegMedSchStaging.Graduation_Month__c = fieldvalmap.get('gradMonth');
			updDegMedSchStaging.School_Program__c = fieldvalmap.get('School_Program__c');
			updDegMedSchStaging.Specialty__c = fieldvalmap.get('Specialty__c');
			updDegMedSchStaging.Status__c = fieldvalmap.get('Status__c');
			updDegMedSchStaging.Student_ID__c = fieldvalmap.get('Student_ID__c');
			updDegMedSchStaging.Parent_Case__c = caseId;
			if(Contact_Association_Type_Staging__c.SObjectType.getDescribe().isUpdateable()){
				Update updDegMedSchStaging;
			}
			degMedSchoolId = degMedSchStaging[0].Id;
		}else{
			Contact_Association_Type_Staging__c newDegMedSchool = new Contact_Association_Type_Staging__c(
				RecordTypeId = degMedSchRecordTypeId,
				Contact__c = contactId,
				Account__c = fieldvalmap.get('Account__c'),
				Parent_Case__c = caseId,
				Case__c = caseId,				
				Degree_Title__c = fieldvalmap.get('Degree_Title__c'),				
				//Code added by Shailaja.
				Start_Month__c = fieldvalmap.get('Start_Month__c'),
				Start_Year__c = fieldvalmap.get('Start_Year__c'),
				End_Month__c = fieldvalmap.get('End_Month__c'),
				End_Year__c = fieldvalmap.get('End_Year__c'),
				Degree_Issue_Month__c = fieldvalmap.get('Degree_Issue_Month__c'),
				Degree_Issue_Year__c = fieldvalmap.get('Degree_Issue_Year__c'),
				Graduation_Year__c = fieldvalmap.get('gradYear'),
				Graduation_Month__c = fieldvalmap.get('gradMonth'),
				School_Program__c = fieldvalmap.get('School_Program__c'),
				Specialty__c = fieldvalmap.get('Specialty__c'),
				Status__c = fieldvalmap.get('Status__c'),
				Number_of_Years_Attended__c = Decimal.valueOf(fieldvalmap.get('Number_of_Years_Attended__c')),
				Student_ID__c = fieldvalmap.get('Student_ID__c'),
				IsDeanLetter__c = isDeanLetter,
				Courier_service_for_an_additional_fee__c = courierServiceAdditionalFee,
				Credential_Type__c = credentialType
			);
			if(Contact_Association_Type_Staging__c.SObjectType.getDescribe().isCreateable()){
				Insert newDegMedSchool;
			}
			degMedSchoolId = newDegMedSchool.Id;
		}
		if(defscreen){
			string caseIdValue = degMedSchStaging[0].Case__c;
			AppForCertHelper.updateIncompleteCaseStatus(caseIdValue);
		}
		return caseId;
	}
	// Method to fetch Degree Medical School values for Step 2 - Medical School and Graduation Details
	@AuraEnabled(Cacheable = true)
	public static Map<string, string> getSelectedValues(Boolean showExamRegActionButton){
		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		String contactStatus = [SELECT School_Enrollment_Status__c FROM Contact WHERE id =: contactId].School_Enrollment_Status__c;
		Map<String, String> valuesToReturn = new Map<String, String>();
		List<case> newCases = [SELECT Id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Case_Status__c !=: Constants.CASE_STATUS_REJECTED
				AND Case_Status__c !=: Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED];
		if(!newCases.isEmpty() && showExamRegActionButton == false){
			List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = [SELECT Id, Case__r.Internal_Status__c, Status__c, Number_of_Years_Attended__c, Account__c, Degree_Title__c, Account_Name__c,
				Start_Date__c, End_Date__c, Graduation_Year__c, Graduation_Month__c, Degree_Issue_Date__c, School_Program__c, Student_ID__c, Specialty__c,
				Start_Month__c, Start_Year__c, End_Year__c, End_Month__c, Degree_Issue_Month__c, Degree_Issue_Year__c
				FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: newCases[0].id 
				WITH SECURITY_ENFORCED];
			if(String.valueOf(existingConAssoStagingObjList[0].Status__c) == '' || String.valueOf(existingConAssoStagingObjList[0].Status__c) == null){
				valuesToReturn.put('Status__c', contactStatus);
			}else{
				valuesToReturn.put('Status__c', String.valueOf(existingConAssoStagingObjList[0].Status__c));
			}
			valuesToReturn.put('Account__c', String.valueOf(existingConAssoStagingObjList[0].Account__c));
			valuesToReturn.put('Number_of_Years_Attended__c', String.valueOf(existingConAssoStagingObjList[0].Number_of_Years_Attended__c));
			valuesToReturn.put('Degree_Title__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Title__c));
			valuesToReturn.put('Account_Name__c', String.valueOf(existingConAssoStagingObjList[0].Account_Name__c));
			valuesToReturn.put('Start_Date__c', String.valueOf(existingConAssoStagingObjList[0].Start_Date__c));
			valuesToReturn.put('End_Date__c', String.valueOf(existingConAssoStagingObjList[0].End_Date__c));
			valuesToReturn.put('Degree_Issue_Date__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Date__c));
			valuesToReturn.put('School_Program__c', String.valueOf(existingConAssoStagingObjList[0].School_Program__c));
			valuesToReturn.put('Student_ID__c', String.valueOf(existingConAssoStagingObjList[0].Student_ID__c));
			valuesToReturn.put('Specialty__c', String.valueOf(existingConAssoStagingObjList[0].Specialty__c));
			valuesToReturn.put('Graduation_Year__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Year__c));
			valuesToReturn.put('Graduation_Month__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Month__c));
			valuesToReturn.put('Start_Month__c', String.valueOf(existingConAssoStagingObjList[0].Start_Month__c));
			valuesToReturn.put('Start_Year__c', String.valueOf(existingConAssoStagingObjList[0].Start_Year__c));
			valuesToReturn.put('End_Month__c', String.valueOf(existingConAssoStagingObjList[0].End_Month__c));
			valuesToReturn.put('End_Year__c', String.valueOf(existingConAssoStagingObjList[0].End_Year__c));
			valuesToReturn.put('Degree_Issue_Month__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Month__c));
			valuesToReturn.put('Degree_Issue_Year__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Year__c));
		}else{
			valuesToReturn = getSelectedValuesRefactorContinue(showExamRegActionButton, newCases, contactStatus);
		}
		return valuesToReturn;
	}
	// Continuation of getSelectedValues Method to fetch medical school values to populate on custom styled fields in applicant portal
	@AuraEnabled(Cacheable = true)
	public static Map<string, string> getSelectedValuesRefactorContinue(Boolean showExamRegActionButton, List<Case> newCases, String contactStatus){
		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		Map<String, String> valuesToReturnMap = new Map<String, String>();
		List<Contact_Association_Type_Staging__c> existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c>();
		if(showExamRegActionButton == true){
			existingConAssoStagingObjList = [SELECT Id, Case__r.Internal_Status__c, Status__c, Number_of_Years_Attended__c, Account__c, Degree_Title__c, Account_Name__c,
				Start_Date__c, End_Date__c, Graduation_Year__c, Graduation_Month__c, Degree_Issue_Date__c, School_Program__c, Student_ID__c, Specialty__c,
				Start_Month__c, Start_Year__c, End_Year__c, End_Month__c, Degree_Issue_Month__c, Degree_Issue_Year__c
				FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG
				AND Case__c =: newCases[0].id WITH SECURITY_ENFORCED];
			if(!existingConAssoStagingObjList.isEmpty()){
				if(String.valueOf(existingConAssoStagingObjList[0].Status__c) == '' || String.valueOf(existingConAssoStagingObjList[0].Status__c) == null){
					valuesToReturnMap.put('Status__c', contactStatus);
				}else{
					valuesToReturnMap.put('Status__c', String.valueOf(existingConAssoStagingObjList[0].Status__c));
				}
				valuesToReturnMap.put('Account__c', String.valueOf(existingConAssoStagingObjList[0].Account__c));
				valuesToReturnMap.put('Number_of_Years_Attended__c', String.valueOf(existingConAssoStagingObjList[0].Number_of_Years_Attended__c));
				valuesToReturnMap.put('Degree_Title__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Title__c));
				valuesToReturnMap.put('Account_Name__c', String.valueOf(existingConAssoStagingObjList[0].Account_Name__c));
				valuesToReturnMap.put('Start_Date__c', String.valueOf(existingConAssoStagingObjList[0].Start_Date__c));
				valuesToReturnMap.put('End_Date__c', String.valueOf(existingConAssoStagingObjList[0].End_Date__c));
				valuesToReturnMap.put('Degree_Issue_Date__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Date__c));
				valuesToReturnMap.put('School_Program__c', String.valueOf(existingConAssoStagingObjList[0].School_Program__c));
				valuesToReturnMap.put('Student_ID__c', String.valueOf(existingConAssoStagingObjList[0].Student_ID__c));
				valuesToReturnMap.put('Specialty__c', String.valueOf(existingConAssoStagingObjList[0].Specialty__c));
				valuesToReturnMap.put('Graduation_Year__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Year__c));
				valuesToReturnMap.put('Graduation_Month__c', String.valueOf(existingConAssoStagingObjList[0].Graduation_Month__c));
				valuesToReturnMap.put('Start_Month__c', String.valueOf(existingConAssoStagingObjList[0].Start_Month__c));
				valuesToReturnMap.put('Start_Year__c', String.valueOf(existingConAssoStagingObjList[0].Start_Year__c));
				valuesToReturnMap.put('End_Month__c', String.valueOf(existingConAssoStagingObjList[0].End_Month__c));
				valuesToReturnMap.put('End_Year__c', String.valueOf(existingConAssoStagingObjList[0].End_Year__c));
				valuesToReturnMap.put('Degree_Issue_Month__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Month__c));
				valuesToReturnMap.put('Degree_Issue_Year__c', String.valueOf(existingConAssoStagingObjList[0].Degree_Issue_Year__c));
			}
		}
		if(existingConAssoStagingObjList.isEmpty()){
			List<Case> oldCases = new List<Case>();
			List<Case> expCases = new List<Case>();
			oldCases = [SELECT Id, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
						AND ContactId =: contactId
						AND (Internal_Status__c =: Constants.CASE_STATUS_EXPIRED OR Internal_Status__c =: Constants.CASE_STATUS_REJECTED) WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
			if(oldCases.size()>0){
				if(oldCases[0].Internal_Status__c == Constants.CASE_STATUS_EXPIRED){
					expCases.add(oldCases[0]);
				}
			}			
			List<Contact_Association_Type__c> existingConAssoObjList = [SELECT Id, Case__r.Internal_Status__c, Status__c, Number_of_Years_Attended__c, Account__c, Degree_Title__c, Account_Name__c,
				Start_Date__c, End_Date__c, Graduation_Year__c, Graduation_Month__c, Degree_Issue_Date__c, School_Program__c, Student_ID__c,
				Specialty__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Degree_Issue_Month__c, Degree_Issue_Year__c
				FROM Contact_Association_Type__c
				WHERE recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
				AND Contact__c =: contactId WITH SECURITY_ENFORCED];
			valuesToReturnMap = getSelectedValuesRefactorContinue2(existingConAssoObjList, expCases, contactStatus);
		}
		return valuesToReturnMap;
	}
	@AuraEnabled(Cacheable = true)
	public static Map<string, string> getSelectedValuesRefactorContinue2(List<Contact_Association_Type__c> existingConAssoObjList, List<Case> expCases, String contactStatus){
		Map<String, String> valuesToReturnMap = new Map<String, String>();
		if(String.valueOf(existingConAssoObjList[0].Status__c) == '' || String.valueOf(existingConAssoObjList[0].Status__c) == null) {
			valuesToReturnMap.put('Status__c', contactStatus);
		} else {
			valuesToReturnMap.put('Status__c', String.valueOf(existingConAssoObjList[0].Status__c));
		}
		valuesToReturnMap.put('Account__c', String.valueOf(existingConAssoObjList[0].Account__c));
		valuesToReturnMap.put('Account_Name__c', String.valueOf(existingConAssoObjList[0].Account_Name__c));
		valuesToReturnMap.put('Start_Date__c', String.valueOf(existingConAssoObjList[0].Start_Date__c));
		valuesToReturnMap.put('End_Date__c', String.valueOf(existingConAssoObjList[0].End_Date__c));
		valuesToReturnMap.put('Degree_Issue_Date__c', String.valueOf(existingConAssoObjList[0].Degree_Issue_Date__c));
		valuesToReturnMap.put('Student_ID__c', String.valueOf(existingConAssoObjList[0].Student_ID__c));
		valuesToReturnMap.put('Start_Month__c', String.valueOf(existingConAssoObjList[0].Start_Month__c));
		valuesToReturnMap.put('Start_Year__c', String.valueOf(existingConAssoObjList[0].Start_Year__c));
		valuesToReturnMap.put('End_Month__c', String.valueOf(existingConAssoObjList[0].End_Month__c));
		valuesToReturnMap.put('End_Year__c', String.valueOf(existingConAssoObjList[0].End_Year__c));
		valuesToReturnMap.put('Degree_Issue_Month__c', String.valueOf(existingConAssoObjList[0].Degree_Issue_Month__c));
		valuesToReturnMap.put('Degree_Issue_Year__c', String.valueOf(existingConAssoObjList[0].Degree_Issue_Year__c));
		if(expCases.size()>0){
			valuesToReturnMap.put('Number_of_Years_Attended__c', '');
			valuesToReturnMap.put('School_Program__c', '');
			valuesToReturnMap.put('Graduation_Year__c', '');
			valuesToReturnMap.put('Graduation_Month__c', '');
			valuesToReturnMap.put('Degree_Title__c', '');
			valuesToReturnMap.put('Specialty__c', '');
		}else{
			valuesToReturnMap.put('Number_of_Years_Attended__c', String.valueOf(existingConAssoObjList[0].Number_of_Years_Attended__c));
			valuesToReturnMap.put('School_Program__c', String.valueOf(existingConAssoObjList[0].School_Program__c));
			valuesToReturnMap.put('Graduation_Year__c', String.valueOf(existingConAssoObjList[0].Graduation_Year__c));
			valuesToReturnMap.put('Graduation_Month__c', String.valueOf(existingConAssoObjList[0].Graduation_Month__c));
			valuesToReturnMap.put('Degree_Title__c', String.valueOf(existingConAssoObjList[0].Degree_Title__c));
			valuesToReturnMap.put('Specialty__c', String.valueOf(existingConAssoObjList[0].Specialty__c));
		}
		return valuesToReturnMap;
	}
	// Method to delete the orphaned assets which do not have any associated contact association type staging on load 
	@AuraEnabled
	public static String deleteOrphanedAssets(){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();		
		List<Asset> orphanedAssets = new List<Asset>([SELECT Id
			FROM Asset
			WHERE ContactId =: contactId
			AND recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL
			AND Contact_Association_Type_Staging__c = ''
			AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
		]);
		List<RecordType> markedForDeletionRecordType  = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		RecordType assetMarkedForDeletionRT = markedForDeletionRecordType[0];
		if(!orphanedAssets.isEmpty()){
			for(asset asst: orphanedAssets){
				asst.Parent_Case__c = null;
				asst.case__c = null;
				asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				asst.RecordTypeId = assetMarkedForDeletionRT.Id;
			}
			try{
				if(Asset.SObjectType.getDescribe().isUpdateable()){
					UPDATE orphanedAssets;
				}
				return 'true';
			}catch(exception e){
				return string.valueOf(e);
			}
		}
		return 'No orphaned Assets';
	}
	// Purpose : Method to get the list of previously inserted Other Medical Schools
	@AuraEnabled
	public static List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper> getOtherMedSchoolRecords(Boolean showExamRegActionButton){
		List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper> fetchedValuesToReturnCombined = new List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper>();
		// Get Data from Contact Association Type
		AppForCertHelper.OtherMedicalSchoolCombinedWrapper tempCombinedJsObj;
		tempCombinedJsObj = new AppForCertHelper.OtherMedicalSchoolCombinedWrapper(getOtherMedSchoolConAssocType());
		fetchedValuesToReturnCombined.add(tempCombinedJsObj);
		// Get Data from Contact Association Type Staging
		AppForCertHelper.OtherMedicalSchoolCombinedWrapper tempCombinedJsObjStaging;
		tempCombinedJsObjStaging = new AppForCertHelper.OtherMedicalSchoolCombinedWrapper(getOtherMedSchoolConAssocTypeStaging(showExamRegActionButton));
		fetchedValuesToReturnCombined.add(tempCombinedJsObjStaging);
		return fetchedValuesToReturnCombined;
	}
	//Method to get the list of ECFMG approved schools- Other instituitions
	@AuraEnabled
	public static List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper> getOtherInstitutionRecords(Boolean showExamRegActionButton) {
		List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper> fetchedValuesToReturnCombined = new List<AppForCertHelper.OtherMedicalSchoolCombinedWrapper>();
		// Get Data from Contact Association Type
		AppForCertHelper.OtherMedicalSchoolCombinedWrapper tempCombinedJsObj;
		tempCombinedJsObj = new AppForCertHelper.OtherMedicalSchoolCombinedWrapper(getOtherInstitutionConAssocType());
		fetchedValuesToReturnCombined.add(tempCombinedJsObj);
		// Get Data from Contact Association Type Staging
		AppForCertHelper.OtherMedicalSchoolCombinedWrapper tempCombinedJsObjStaging;
		tempCombinedJsObjStaging = new AppForCertHelper.OtherMedicalSchoolCombinedWrapper(getOtherInstitutionConAssocTypeStaging(showExamRegActionButton));
		fetchedValuesToReturnCombined.add(tempCombinedJsObjStaging);
		AppForCertHelper.OtherMedicalSchoolCombinedWrapper tempCombinedJsObjCatRec;
		if(fetchedValuesToReturnCombined[0].otherSchoolWrapperList == null && fetchedValuesToReturnCombined[1].otherSchoolWrapperList == null){
			tempCombinedJsObjCatRec = new AppForCertHelper.OtherMedicalSchoolCombinedWrapper(AppForCertHelper.getOtherInstitutionConAssocType());
			fetchedValuesToReturnCombined.set(1,tempCombinedJsObjCatRec);
		}
		return fetchedValuesToReturnCombined;
	}
	@AuraEnabled
	public static string saveOtherMedicalSchools(String jsonString, List<String> assetsUrlsList, String parentCaseId, String caseId, List<String> tcsToDelList, Boolean showExamRegActionButton){
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
		}
		List<AppForCertHelper.OtherSchoolObjWrapper> objectList = (List<AppForCertHelper.OtherSchoolObjWrapper>) JSON.deserialize(jsonString, List<AppForCertHelper.OtherSchoolObjWrapper>.class);
		List<Contact_Association_Type_Staging__c> stagingListToUpdate = new List<Contact_Association_Type_Staging__c>();
		List<Transfer_Credit__c> tcListToUpsert = new List<Transfer_Credit__c>();
		List<Asset> assetsListToUpdate = new List<Asset>();
		List<Transfer_Credit__c> tcListToDel = new List<Transfer_Credit__c>([SELECT Id FROM Transfer_Credit__c WHERE ID IN: tcsToDelList]);
		if(!tcListToDel.isEmpty()){
			try{
				DELETE tcListToDel;
			}catch(exception e){
				saveLogMessage(e.getMessage());
			}
		}
		List<Asset> assetsCreatedFromPageList = new List<Asset>([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN:assetsUrlsList]);
		Map<String, Asset> azureUrlAssetMap = new Map<String, Asset>();
		for(Asset asstIter:assetsCreatedFromPageList){
			azureUrlAssetMap.put(asstIter.Azure_Storage_URL__c, asstIter);
		}
		AppForCertHelper.checkForRejectedCat(objectList);
		for(AppForCertHelper.OtherSchoolObjWrapper wrap : objectList){
			if(String.isNotBlank(wrap.recordIdVal)){
				Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
				stageRec = saveOtherMedicalSchoolsRefactorContCATFirstMethod(wrap, recordTypeDeveloperName, parentCaseId, caseId, azureUrlAssetMap);
				stagingListToUpdate.add(stageRec);
				tcListToUpsert.addAll(saveOtherMedicalSchoolsRefactorContTranCredMethod(wrap, caseId));
				assetsListToUpdate.addAll(saveOtherMedicalSchoolsRefactorContAssMethod(wrap, parentCaseId, azureUrlAssetMap));
			}else if(String.isBlank(wrap.recordIdVal)){
				Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
				stageRec = createStageRecord(wrap, parentCaseId, caseId, recordTypeDeveloperName, azureUrlAssetMap);
				tcListToUpsert.addAll(saveOtherMedicalSchoolsRefactorContTraCredMethod(wrap, stageRec, caseId));
				assetsListToUpdate.addAll(saveOtherMedicalSchoolsRefactorContAssetMethod(wrap, stageRec, azureUrlAssetMap));
			}
		}
		try{			
			saveOtherMedicalSchoolsRefactor(stagingListToUpdate, tcListToUpsert, assetsListToUpdate);
		}catch(exception e){
			return String.valueOf(e);
		}
		return 'true';
	}
	public static void saveOtherMedicalSchoolsRefactor(List<Contact_Association_Type_Staging__c> stagingListToUpdate, List<Transfer_Credit__c> tcListToUpsert, List<Asset> assetsListToUpdate){
		if(!stagingListToUpdate.isEmpty() && Contact_Association_Type_Staging__c.SObjectType.getDescribe().isUpdateable()){
			update stagingListToUpdate;
		}			
		if(!tcListToUpsert.isEmpty() && (Transfer_Credit__c.SObjectType.getDescribe().isCreateable() || Transfer_Credit__c.SObjectType.getDescribe().isUpdateable())){
			upsert tcListToUpsert;
		}
		if(!assetsListToUpdate.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
			update assetsListToUpdate;
		}
	}
	// To avoiding cognitive complexity issues  - calling as seperate method
    public static void saveLogMessage(String getMessage){
		if(Schema.sObjectType.Log_Message__c.isCreateable()){
			Log_Message__c logMsg = new Log_Message__c();
			logMsg.Source__c = 'AppForCertController';
			logMsg.Exception__c	= 'Transfer Credit Delete Error:'+getMessage;
			logMsg.Date_Time_Logged__c = DateTime.now();
			INSERT logMsg;
		}
	}
	@AuraEnabled
	public static List<Transfer_Credit__c> saveOtherMedicalSchoolsRefactorContTranCredMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, string caseId){
		List<Transfer_Credit__c> tcListToUpsert = new List<Transfer_Credit__c>();
		Id currentUser = AppForCertHelper.retrieveCurrentContactId();
		if(Boolean.valueOf(wrap.transferCreditsCheckbox) && wrap.tcWrapperList != null && wrap.tcWrapperList.size() > 0){
			for(AppForCertHelper.TcObjWrapper childTc: wrap.tcWrapperList){
				Transfer_Credit__c tcToUpsert = new Transfer_Credit__c();
				if(String.isNotBlank(childTc.recordIdVal)){
					tcToUpsert.Id = childTc.recordIdVal;
				}
				tcToUpsert.Applicant__c = currentUser;
				tcToUpsert.Contact_Association_Type_Staging__c = wrap.recordIdVal;
				tcToUpsert.From_School__c = childTc.fromSchool;
				tcToUpsert.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tcToUpsert.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tcToUpsert.Course_Outcome__c = childTc.courseOutcome;
				tcToUpsert.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tcToUpsert.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tcToUpsert.Case__c = caseId;
				tcListToUpsert.add(tcToUpsert);
			}
		}
		return tcListToUpsert;
	}
	@AuraEnabled
	public static Contact_Association_Type_Staging__c saveOtherMedicalSchoolsRefactorContCATFirstMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, String recordTypeDeveloperName, String parentCaseId, String caseId, Map<String, Asset> assetsMap){
		Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c(Id = wrap.recordIdVal);
		stageRec.Account__c = wrap.otherSchoolId;
		stageRec.recordTypeId = medSchlRecordTypeId;
		stageRec.School_Program__c = wrap.schoolProgram;
		if(!String.isBlank(wrap.fromDate)){
			stageRec.Start_Date__c = Date.valueOf(wrap.fromDate);
		}else{
			stageRec.Start_Date__c = null;
		}
		if(!String.isBlank(wrap.endDate)){
			stageRec.End_Date__c = Date.valueOf(wrap.endDate);
		}else{
			stageRec.End_Date__c = null;
		}
		stageRec.Start_Month__c = wrap.startMonth;
		stageRec.Start_Year__c = wrap.startYear;
		stageRec.End_Month__c = wrap.endMonth;
		stageRec.End_Year__c = wrap.endYear;
		stageRec.Specialty__c = wrap.Specialty;
		if(!String.isBlank(wrap.numberOfYearsAttended)){
			stageRec.Number_of_Years_Attended__c = Decimal.valueOf(wrap.numberOfYearsAttended);
		}else{
			stageRec.Number_of_Years_Attended__c = null;
		}
		stageRec.Student_ID__c = wrap.studentId;
		stageRec.Transfer_Credit_to_Degree_School__c = Boolean.valueOf(wrap.transferCreditsCheckbox);
		if(!assetsMap.isEmpty()){
			stageRec.Credential_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT;
		}
		stageRec.Parent_Case__c = parentCaseId;
		stageRec.Case__c = caseId;
		return stageRec;
	}
	@AuraEnabled
	public static List<Asset> saveOtherMedicalSchoolsRefactorContAssMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, String parentCaseId, Map<String, Asset> assetsMap){
		List<Asset> assetsListToUpdate = new List<Asset>();
		if(Boolean.valueOf(wrap.transferCreditsCheckbox) && wrap.assets != null && wrap.assets.size() > 0){
			for(AppForCertHelper.AssetObjWrapper tempAsset: wrap.assets){
				if(tempAsset.azureUrl != '' && tempAsset.azureUrl != 'true' && assetsMap.containsKey(tempAsset.azureUrl)){
					Asset childAsset = new Asset(Id = assetsMap.get(tempAsset.azureUrl).Id);
					childAsset.Parent_Case__c = parentCaseId;
					childAsset.Contact_Association_Type_Staging__c = wrap.recordIdVal;
					childAsset.Name_on_Document__c = tempAsset.nameOnDoc;
					childAsset.Name_on_Document_is_Different__c = tempAsset.nameOnDocIsDifferent == 'true';
					childAsset.Document_is_not_in_English__c = tempAsset.docNotInEnglish == 'true';
					if(String.isNotBlank(tempAsset.parentAssetAzureUrl)){
						childAsset.parentId = assetsMap.get(tempAsset.parentAssetAzureUrl).Id;
						childAsset.Parent_Azure_Storage_URL__c = tempAsset.parentAssetAzureUrl;
					}
					childAsset.Uploaded_by_applicant__c = true;
					assetsListToUpdate.add(childAsset);
				}
			}
		}
		return assetsListToUpdate;
	}
	@AuraEnabled
	public static List<Transfer_Credit__c> saveOtherMedicalSchoolsRefactorContTraCredMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, Contact_Association_Type_Staging__c stageRec, string caseId){
		List<Transfer_Credit__c> tcListToUpsert = new List<Transfer_Credit__c>();
		Id currentUser = AppForCertHelper.retrieveCurrentContactId();
		if(Boolean.valueOf(wrap.transferCreditsCheckbox) && wrap.tcWrapperList != null && wrap.tcWrapperList.size() > 0){
			for(AppForCertHelper.TcObjWrapper childTc: wrap.tcWrapperList){
				Transfer_Credit__c tcToUpsert = new Transfer_Credit__c();
				if(String.isNotBlank(childTc.recordIdVal)){
					tcToUpsert.Id = childTc.recordIdVal;
				}
				tcToUpsert.Applicant__c = currentUser;
				tcToUpsert.Contact_Association_Type_Staging__c = stageRec.Id;
				tcToUpsert.From_School__c = childTc.fromSchool;
				tcToUpsert.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tcToUpsert.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tcToUpsert.Course_Outcome__c = childTc.courseOutcome;
				tcToUpsert.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tcToUpsert.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tcToUpsert.Case__c = caseId;
				tcListToUpsert.add(tcToUpsert);
			}
		}
		return tcListToUpsert;
	}
	@AuraEnabled
	public static List<Asset> saveOtherMedicalSchoolsRefactorContAssetMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, Contact_Association_Type_Staging__c stageRec, Map<String, Asset> assetsMap){
		List<Asset> assetsListToUpdate = new List<Asset>();
		if(Boolean.valueOf(wrap.transferCreditsCheckbox) && wrap.assets != null && wrap.assets.size() > 0){
			for(AppForCertHelper.AssetObjWrapper tempAsset: wrap.assets){
				if(tempAsset.azureUrl != '' && tempAsset.azureUrl != 'true' && assetsMap.containsKey(tempAsset.azureUrl)){
					Asset childAsset = new Asset(Id = assetsMap.get(tempAsset.azureUrl).Id);
					childAsset.Parent_Case__c = stageRec.Parent_Case__c;
					childAsset.Contact_Association_Type_Staging__c = stageRec.Id;
					childAsset.Name_on_Document__c = tempAsset.nameOnDoc;
					childAsset.Name_on_Document_is_Different__c = tempAsset.nameOnDocIsDifferent == 'true';
					childAsset.Document_is_not_in_English__c = tempAsset.docNotInEnglish == 'true';
					if(String.isNotBlank(tempAsset.parentAssetAzureUrl)){
						childAsset.parentId = assetsMap.get(tempAsset.parentAssetAzureUrl).Id;
						childAsset.Parent_Azure_Storage_URL__c = tempAsset.parentAssetAzureUrl;
					}
					childAsset.Uploaded_by_applicant__c = true;
					assetsListToUpdate.add(childAsset);
				}
			}
		}
		return assetsListToUpdate;
	}

	// To Insert a new Contact_Association_Type_Staging__c object
	public static Contact_Association_Type_Staging__c createStageRecord(AppForCertHelper.OtherSchoolObjWrapper wrap, String parentCaseId, String caseId, String recordTypeDeveloperName, Map<String, Asset> assetsMap){
		Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
		stageRec.Contact__c = AppForCertHelper.retrieveCurrentContactId();
		stageRec.Account__c = wrap.otherSchoolId;
		stageRec.recordTypeId = medSchlRecordTypeId;
		stageRec.School_Program__c = wrap.schoolProgram;
		if(!String.isBlank(wrap.fromDate)){
			stageRec.Start_Date__c = Date.valueOf(wrap.fromDate);
		}else{
			stageRec.Start_Date__c = null;
		}
		if(!String.isBlank(wrap.endDate)){
			stageRec.End_Date__c = Date.valueOf(wrap.endDate);
		}else{
			stageRec.End_Date__c = null;
		}
		stageRec.Start_Month__c = wrap.startMonth;
		stageRec.Start_Year__c = wrap.startYear;
		stageRec.End_Month__c = wrap.endMonth;
		stageRec.End_Year__c = wrap.endYear;
		stageRec.Specialty__c = wrap.Specialty;
		if(!String.isBlank(wrap.numberOfYearsAttended)){
			stageRec.Number_of_Years_Attended__c = Decimal.valueOf(wrap.numberOfYearsAttended);
		}else{
			stageRec.Number_of_Years_Attended__c = null;
		}
		stageRec.Student_ID__c = wrap.studentId;
		stageRec.Transfer_Credit_to_Degree_School__c = Boolean.valueOf(wrap.transferCreditsCheckbox);
		if(!assetsMap.isEmpty()){
			stageRec.Credential_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT;
		}
		stageRec.Parent_Case__c = parentCaseId;
		stageRec.Case__c = caseId;
		Insert stageRec;
		return stageRec;
	}	

	//Purpose : Method to upsert the list of other institutions
	@AuraEnabled(cacheable = false)
	public static string saveOtherInstitutionRecords(String values, List<String> assetsUrlsList, String parentCaseId, String caseId, List<String> tcsToDelList, Boolean showExamRegActionButton){
		Id currentUser = AppForCertHelper.retrieveCurrentContactId();
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION;
		}
		List<AppForCertHelper.OtherSchoolObjWrapper> wrappedObjList = (List<AppForCertHelper.OtherSchoolObjWrapper>) JSON.deserialize(values, List<AppForCertHelper.OtherSchoolObjWrapper>.class);
		List<Contact_Association_Type_Staging__c> recordsToUpdate = new List<Contact_Association_Type_Staging__c>();
		List<Transfer_Credit__c> tcsToUpsert = new List<Transfer_Credit__c>();
		List<Transfer_Credit__c> tcsToUpsertEachObj = new List<Transfer_Credit__c>();
		List<Asset> assetsToUpdate = new List<Asset>();
		List<Asset> assetsToUpdateEachObj = new List<Asset>();
		List<Transfer_Credit__c> tcListToDel = new List<Transfer_Credit__c>([SELECT Id FROM Transfer_Credit__c WHERE ID IN: tcsToDelList]);
		if(!tcListToDel.isEmpty()){
			try{
				DELETE tcListToDel;
			}catch(exception e){
				saveLogMessage(e.getMessage());
			}
		}
		List<Asset> assetsCreatedFromPageList = new List<Asset>([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN:assetsUrlsList]);
		Map<String, Asset> azureUrlAssetMap = new Map<String, Asset>();
		for(Asset asstIter : assetsCreatedFromPageList){
			azureUrlAssetMap.put(asstIter.Azure_Storage_URL__c, asstIter);
		}
		AppForCertHelper.checkForRejectedCat(wrappedObjList);
		for(AppForCertHelper.OtherSchoolObjWrapper jsObj : wrappedObjList){
			if(!String.isBlank(jsObj.recordIdVal)){
				Contact_Association_Type_Staging__c tempContAssoTypeStag = new Contact_Association_Type_Staging__c();
				tempContAssoTypeStag = createtempContAssoTypeStag(jsObj, parentCaseId, caseId);
				recordsToUpdate.add(tempContAssoTypeStag);
				tcsToUpsertEachObj = addTcsToUpsert(jsObj, currentUser, caseId);
				tcsToUpsert.addall(tcsToUpsertEachObj);
				assetsToUpdateEachObj = addassetsToUpdate(jsObj, azureUrlAssetMap, parentCaseId);
				assetsToUpdate.addall(assetsToUpdateEachObj);
			}else if(String.isBlank(jsObj.recordIdVal)){
				Contact_Association_Type_Staging__c tempContAssoTypeStag = new Contact_Association_Type_Staging__c();
				tempContAssoTypeStag = createOtherInstitutionRecord(jsObj, parentCaseId, caseId, recordTypeDeveloperName);
				tcsToUpsertEachObj = addElseIfTcsToUpsert(jsObj, currentUser, tempContAssoTypeStag, caseId);
				tcsToUpsert.addall(tcsToUpsertEachObj);
				assetsToUpdateEachObj = addElseIfassetsToUpdate(jsObj, tempContAssoTypeStag, azureUrlAssetMap);
				assetsToUpdate.addall(assetsToUpdateEachObj);
			}
		}
		try{
			AppForCertHelper.updateCatsAndAssets(recordsToUpdate,tcsToUpsert,assetsToUpdate);
			return 'true';
		}catch(exception e){
			return string.valueOf(e);
		}
	}
	// Creating New Contact Association Type Staging Record
	public static Contact_Association_Type_Staging__c createOtherInstitutionRecord(AppForCertHelper.OtherSchoolObjWrapper wrap, String parentCaseId, String caseId, String recordTypeDeveloperName){
		Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		Contact_Association_Type_Staging__c tempObj = new Contact_Association_Type_Staging__c();
		tempObj.Contact__c = AppForCertHelper.retrieveCurrentContactId();
		tempObj.Account__c = wrap.otherSchoolId;
		tempObj.recordTypeId = medSchlRecordTypeId;
		tempObj.Parent_Case__c = parentCaseId;
		tempObj.Case__c = caseId;
        if (!String.isBlank(wrap.startMonth)) {
            tempObj.Start_Month__c = wrap.startMonth;
        } else {
            tempObj.Start_Month__c = null;
        }
        if (!String.isBlank(wrap.startYear)) {
            tempObj.Start_Year__c = wrap.startYear;
        } else {
            tempObj.Start_Year__c = null;
        }
        if (!String.isBlank(wrap.endMonth)) {
            tempObj.End_Month__c = wrap.endMonth;
        } else {
            tempObj.End_Month__c = null;
        }
        if (!String.isBlank(wrap.endYear)) {
            tempObj.End_Year__c = wrap.endYear;
        } else {
            tempObj.End_Year__c = null;
        }
        if (!String.isBlank(wrap.numberOfYearsAttended)) {
            tempObj.Number_of_Years_Attended__c = Decimal.valueOf(wrap.numberOfYearsAttended);
        } else {
            tempObj.Number_of_Years_Attended__c = null;
        }
		tempObj.Transfer_Credit_to_Degree_School__c = true;
		tempObj.Credential_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT;
		Insert tempObj;
		return tempObj;
	}
	// Updating existing Contact Association Type Staging Record
	public static Contact_Association_Type_Staging__c createtempContAssoTypeStag(AppForCertHelper.OtherSchoolObjWrapper jsObj, String parentCaseId, String caseId){
		Contact_Association_Type_Staging__c tempContAssoTypeStag = new Contact_Association_Type_Staging__c(id = jsObj.recordIdVal);
		tempContAssoTypeStag.Account__c = jsObj.otherSchoolId;
		tempContAssoTypeStag.Transfer_Credit_to_Degree_School__c = jsObj.transferCreditsCheckbox == 'true';
		if (!String.isBlank(jsObj.fromDate)) {
			tempContAssoTypeStag.Start_Date__c = Date.valueOf(jsObj.fromDate);
		} else {
			tempContAssoTypeStag.Start_Date__c = null;
		}
		if (!String.isBlank(jsObj.numberOfYearsAttended)) {
			tempContAssoTypeStag.Number_of_Years_Attended__c = Decimal.valueOf(jsObj.numberOfYearsAttended);
		} else {
			tempContAssoTypeStag.Number_of_Years_Attended__c = null;
		}
		if (!String.isBlank(jsObj.endDate)) {
			tempContAssoTypeStag.End_Date__c = Date.valueOf(jsObj.endDate);
		} else {
			tempContAssoTypeStag.End_Date__c = null;
		}
		tempContAssoTypeStag.Start_Month__c = jsObj.startMonth;
		tempContAssoTypeStag.Start_Year__c = jsObj.startYear;
		tempContAssoTypeStag.End_Month__c = jsObj.endMonth;
		tempContAssoTypeStag.End_Year__c = jsObj.endYear;
		tempContAssoTypeStag.Credential_Type__c = Constants.CASE_DOCUMENT_TYPE_TCT;
		tempContAssoTypeStag.Parent_Case__c = parentCaseId;
		tempContAssoTypeStag.Case__c = caseId;
		return tempContAssoTypeStag;
	}
	// Creating TCT list for Transfer_Credit__c	
	public static List<Transfer_Credit__c> addTcsToUpsert(AppForCertHelper.OtherSchoolObjWrapper jsObj, Id currentUser, String caseId){
		List<Transfer_Credit__c> tcsToUpsert = new List<Transfer_Credit__c>();
		if(jsObj.tcWrapperList != null && jsObj.tcWrapperList.size() > 0){
			for(AppForCertHelper.TcObjWrapper childTc : jsObj.tcWrapperList){
				Transfer_Credit__c tcToUpsert = new Transfer_Credit__c();
				if(String.isNotBlank(childTc.recordIdVal)){
					tcToUpsert.Id = childTc.recordIdVal;
				}
				tcToUpsert.Applicant__c = currentUser;
				tcToUpsert.Contact_Association_Type_Staging__c = jsObj.recordIdVal;
				tcToUpsert.From_School__c = childTc.fromSchool;
				tcToUpsert.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tcToUpsert.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tcToUpsert.Course_Outcome__c = childTc.courseOutcome;
				tcToUpsert.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tcToUpsert.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tcToUpsert.Case__c = caseId;
				tcsToUpsert.add(tcToUpsert);
			}
		}
		return tcsToUpsert;
	}
	// Creating the LIST to update the assets 
	public static List<Asset> addassetsToUpdate(AppForCertHelper.OtherSchoolObjWrapper jsObj, Map<String, Asset> assetsMap, String parentCaseId){
		List<Asset> assetsToUpdate = new List<Asset>();
		if(jsObj.assets.size() > 0 && jsObj.assets != null){
			for(AppForCertHelper.AssetObjWrapper tempAsset : jsObj.assets){
				if(tempAsset.azureUrl != '' && tempAsset.azureUrl != 'true' && assetsMap.containsKey(tempAsset.azureUrl)){
					Asset childAsset = new Asset(Id = assetsMap.get(tempAsset.azureUrl).Id);
					childAsset.Parent_Case__c = parentCaseId;
					childAsset.Contact_Association_Type_Staging__c = jsObj.recordIdVal;
					childAsset.Name_on_Document__c = tempAsset.nameOnDoc;
					childAsset.Name_on_Document_is_Different__c = tempAsset.nameOnDocIsDifferent == 'true';
					childAsset.Document_is_not_in_English__c = tempAsset.docNotInEnglish == 'true';
					if(String.isNotBlank(tempAsset.parentAssetAzureUrl)){
						childAsset.parentId = assetsMap.get(tempAsset.parentAssetAzureUrl).Id;
						childAsset.Parent_Azure_Storage_URL__c = tempAsset.parentAssetAzureUrl;
					}
					childAsset.Uploaded_by_applicant__c = true;
					assetsToUpdate.add(childAsset);
				}
			}
		}
		return assetsToUpdate;
	}
	// Creating TCT list for Transfer_Credit__c	
	public static List<Transfer_Credit__c> addElseIfTcsToUpsert(AppForCertHelper.OtherSchoolObjWrapper jsObj, Id currentUser, Contact_Association_Type_Staging__c tempContAssoTypeStag, String caseId){
		List<Transfer_Credit__c> tcsToUpsert = new List<Transfer_Credit__c>();
		if(jsObj.tcWrapperList != null && jsObj.tcWrapperList.size() > 0){
			for(AppForCertHelper.TcObjWrapper childTc : jsObj.tcWrapperList){
				Transfer_Credit__c tcToUpsert = new Transfer_Credit__c();
				if (String.isNotBlank(childTc.recordIdVal)){
					tcToUpsert.Id = childTc.recordIdVal;
				}
				tcToUpsert.Applicant__c = currentUser;
				tcToUpsert.Contact_Association_Type_Staging__c = tempContAssoTypeStag.Id;
				tcToUpsert.From_School__c = childTc.fromSchool;
				tcToUpsert.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tcToUpsert.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tcToUpsert.Course_Outcome__c = childTc.courseOutcome;
				tcToUpsert.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tcToUpsert.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tcToUpsert.Case__c = caseId;
				tcsToUpsert.add(tcToUpsert);
			}
		}
		return tcsToUpsert;
	}
	// Creating the LIST to update the assets 
	public static List<Asset> addElseIfassetsToUpdate(AppForCertHelper.OtherSchoolObjWrapper jsObj, Contact_Association_Type_Staging__c tempContAssoTypeStag, Map<String, Asset> assetsMap){
		List<Asset> assetsToUpdate = new List<Asset>();
		if(jsObj.assets.size() > 0 && jsObj.assets != null){
			for(AppForCertHelper.AssetObjWrapper tempAsset : jsObj.assets){
				if(tempAsset.azureUrl != '' && tempAsset.azureUrl != 'true' && assetsMap.containsKey(tempAsset.azureUrl)){
					Asset childAsset = new Asset(Id = assetsMap.get(tempAsset.azureUrl).Id);
					childAsset.Parent_Case__c = tempContAssoTypeStag.Parent_Case__c;
					childAsset.Contact_Association_Type_Staging__c = tempContAssoTypeStag.Id;
					childAsset.Name_on_Document__c = tempAsset.nameOnDoc;
					childAsset.Name_on_Document_is_Different__c = tempAsset.nameOnDocIsDifferent == 'true';
					childAsset.Document_is_not_in_English__c = tempAsset.docNotInEnglish == 'true';					
					if(String.isNotBlank(tempAsset.parentAssetAzureUrl)){
						childAsset.parentId = assetsMap.get(tempAsset.parentAssetAzureUrl).Id;
						childAsset.Parent_Azure_Storage_URL__c = tempAsset.parentAssetAzureUrl;
					}
					childAsset.Uploaded_by_applicant__c = true;
					assetsToUpdate.add(childAsset);
				}
			}
		}
		return assetsToUpdate;
	}
	/************************************************************************************ */

	/**
	 * Created by Balashankar
	 * Method Name: getContactId
	 * Purpose : Method to get contactId
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static String getContactId() {

		String returnVal = '';
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		if (contactId != null) returnVal = contactId;

		return returnVal;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getCaseId
	 * Purpose : Method to get caseId
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static String getCaseId() {

		String returnVal = '';
		returnVal = AppForCertHelper.getCaseId();

		return returnVal;
	}
	@AuraEnabled
	public static Contact_Association_Type_Staging__c getCatCheckboxValues(String catsId){
        List<Contact_Association_Type_Staging__c> catsList = [SELECT Id, Name_on_Document__c, Credential_Type__c, Issued_in_the_last_90_days__c, Case__c, Requested_to_be_sent_to_ECFMG__c, account__c, account__r.Name, account__r.BillingStreet, account__r.BillingCity, account__r.BillingState, account__r.BillingCountry, account__r.BillingcountryCode, Degree_Issue_Date__c, Degree_Title__c, Graduation_Year__c, Degree_expected_to_be_issued_Year__c, Degree_expected_to_be_issued_Month__c, Attendance_Start_Date__c, Attendance_End_Date__c, Program_Start_Date__c, Program_End_Date__c, Title__c, Issue_Date__c, Expiration_Date__c, Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c where Id =:catsId WITH SECURITY_ENFORCED];
        if(!catsList.isEmpty()){
            return catsList[0];
        }
        return null;
    }
	/**  Created By : Sheena John Purpose : To update Cats checkbox value */
	@AuraEnabled
	public static Contact_Association_Type_Staging__c updateCatscheckbox(String catsId, Boolean couriercheckbox){
        List<Contact_Association_Type_Staging__c> upcatsList = new List<Contact_Association_Type_Staging__c>();
        for(Contact_Association_Type_Staging__c  conAssTyStgn : [SELECT Id,Account__c,Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c where Id =:catsId WITH SECURITY_ENFORCED]){
			conAssTyStgn.Courier_service_for_an_additional_fee__c = couriercheckbox;
			upcatsList.add(conAssTyStgn);
		}		
		if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){
			update upcatsList;
		}
        if(!upcatsList.isEmpty()){
            return upcatsList[0];
        }
        return null;
    }
	/**
	 * Created by Femi
	 * Method Name: getMetadataId
	 * Purpose : Method to get metadata Id of confirmation message
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static String getMetadataId() {

		String returnVal = '';
		returnVal = AppForCertHelper.getMetadataId();

		return returnVal;
	}
	/**
	 * Created by Femi
	 * Method Name: getCaseNumber
	 * Purpose : Method to get caseNumber
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static String getCaseNumber() {
		String returnVal = '';
		returnVal = AppForCertHelper.getCaseNumber();

		return returnVal;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getContactAssociationTypeStaging
	 * Purpose : Method to get Contact Association Type Staging Id
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static String getContactAssociationTypeStaging(Boolean showExamRegActionButton) {
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		String caseId = AppForCertHelper.getCaseId();
		String currentContactAssociatonTypeId = '';
		currentContactAssociatonTypeId = AppForCertHelper.getContactAssociationTypeStaging(showExamRegActionButton, caseId, contactId);
		return currentContactAssociatonTypeId;
	}

	/**
	 * Created by Balashankar
	 * Method Name: checkFinalTranscript
	 * Purpose : Method to check whether finaltranscript is required or not
	 * Return Type : boolean
	 */
	@AuraEnabled
	public static boolean checkFinalTranscript(Boolean showExamRegActionButton) {
		Boolean finaltranscriptRequired = false;
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		String caseId = AppForCertHelper.getCaseId();
		String currentContactAssociationTypeStagingId = '';
		currentContactAssociationTypeStagingId = AppForCertHelper.getContactAssociationTypeStaging(showExamRegActionButton, caseId, contactId);
		List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = new List<Contact_Association_Type_Staging__c > ();
		existingConAssoStagingObjList = [SELECT id, Account__r.Is_Final_Transcript_Required__c
			FROM Contact_Association_Type_Staging__c WHERE Id =: currentContactAssociationTypeStagingId
		];

		if (!existingConAssoStagingObjList.isEmpty()) {
			finaltranscriptRequired = existingConAssoStagingObjList[0].Account__r.Is_Final_Transcript_Required__c;

		}

		return finaltranscriptRequired;
	}
	/**
	 * Created by Balashankar
	 * Modified : Ajoydhas (Refactor issue fixes)
	 * Method Name: createAsset
	 * Purpose : Method to create Asset
	 * Return Type : String
	 */
	@AuraEnabled
	public static String createAsset(String contentDocId, String caseId, String type, String contactId, String contactAssociationType, String val, String examType) {
		String keyval = val.substringBefore('++');
		String parentkeyval = val.substringAfter('++');
		//To overwrite the existing file
		if (String.isNotBlank(contactAssociationType) || keyval == Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC) {
			deleteAssetAndRelatedDocument(contactId, keyval, contactAssociationType);
		}
		String nameValue = '';
		if (type == constants.ASSET_TYPE_DEAN_LETTER) {
			nameValue = constants.ASSET_NAME_DEAN_LETTER;
		} else {
			nameValue = type;
		}
		Asset a;
		if (keyval == Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC) {
			a = new Asset(
				Name = nameValue, Type__c = type, Status = Constants.ASSET_STATUS_IN_PROGRESS, ContactId = contactId, key__c = keyval, Parent_Key__c = parentkeyval, RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_EXAM_REG).getRecordTypeId(), Exam_Registration_Exam_Type__c = examType);
		} else {
			if (!String.isBlank(contactAssociationType)) {
				a = new Asset(
					Name = nameValue, Type__c = type, Status = Constants.ASSET_STATUS_IN_PROGRESS, Case__c = caseId, ContactId = contactId, Contact_Association_Type_Staging__c = contactAssociationType, key__c = keyval, Parent_Key__c = parentkeyval, RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId());
			} else {
				a = new Asset(
					Name = nameValue, Type__c = type, Status = Constants.ASSET_STATUS_IN_PROGRESS, Case__c = caseId, ContactId = contactId, key__c = keyval, Parent_Key__c = parentkeyval, RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId());
			}
		}

		insert a;
		if (a != null) {

			List<ContentDocumentLink> cdlList = new List<ContentDocumentLink> ();
			ContentDocumentLink cdlAsset = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = a.Id, ShareType = 'I', Visibility = 'AllUsers');
			cdlList.add(cdlAsset);

			if (keyval != Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC) {
				ContentDocumentLink cdlContact = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = contactId, ShareType = 'I', Visibility = 'AllUsers');
				cdlList.add(cdlContact);
			}

			if (!String.isBlank(contactAssociationType)) {
				ContentDocumentLink cdlContactAssociationTypeStaging = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = contactAssociationType, ShareType = 'I', Visibility = 'AllUsers');
				cdlList.add(cdlContactAssociationTypeStaging);
			}

			insert cdlList;

		}
		String returnDet = getDocumentbyId(contentDocId);
		returnDet = returnDet + ':`:' + a.id;
		return returnDet;
	}

	// Purpose : Method to update Parent Asset in child Assets 
	@AuraEnabled
	public static Boolean updateParentAsset(String jsonString, Boolean couriercheckbox, Boolean courierFMST){
		Boolean returnVal = false;
		String contactId;
		Boolean isDeanLetter;
		Boolean reSubmitFromAppForCert;
		Date dateonDeanLetterDocument;
		Boolean showExamRegActionButton;
		Boolean isFinalTranscriptRequired;
		AppForCertHelper.UpdateParentAssetWrapper objectList = (AppForCertHelper.UpdateParentAssetWrapper) JSON.deserialize(jsonString, AppForCertHelper.UpdateParentAssetWrapper.class);
		contactId = objectList.contactId;
		isDeanLetter = objectList.isDeanLetter;
		dateonDeanLetterDocument = objectList.dateonDeanLetterDocument;
		showExamRegActionButton = objectList.showExamRegActionButton;
		reSubmitFromAppForCert = objectList.reSubmitFromAppForCert;
		isFinalTranscriptRequired = objectList.isFinalTranscriptRequired;
		Id parentCaseId = AppForCertHelper.getCaseId();
		if (isDeanLetter && dateonDeanLetterDocument == null) {
			returnVal = true;
		} else {
			returnVal = false;
			String credentialType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
            if(isDeanLetter){
                credentialType = Constants.ASSET_NAME_DEAN_LETTER;
            }
			Map<String, String> keyAssetMap = new Map<String, String>();
			Map<String, String> keyAssetMapParentAzure = new Map<String, String>();			
			Set<String> keySet = new Set<String>{
				System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
				System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
				System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
				System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
				System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
				System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT
			};
			// Checking in Degree Medical School record type
			String recordTypeDevNameDegree = getRecordTypeDegree(showExamRegActionButton);
			List<Asset> updatedParentAssetList = new List<Asset>();
			List<Asset> updatedParentAssetListDummy = new List<Asset>();
			for (Asset a: [SELECT Id, key__c, Type__c, Contact_Association_Type_Staging__c, Parent_Key__c, ParentId, Contact_Association_Type__c,Azure_Storage_URL__c
					FROM Asset WHERE contactId =: contactId and key__c IN: keySet AND status !=: constants.ASSET_STATUS_REJECTED AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND status !=:constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED order by createdDate Desc
				]) {
				keyAssetMap.put(a.key__c, a.Id);
				keyAssetMapParentAzure.put(a.key__c,a.Azure_Storage_URL__c);
			}
			// Updating DeaisDeanLetter Status in Contact_Association_Type_Staging__c
			List <Contact_Association_Type_Staging__c> conAssType = [SELECT Id, IsDeanLetter__c, Account__c, Parent_Case__c, Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c
                                                                        WHERE Contact__c =: contactId
                                                                        AND Parent_Case__c =: parentCaseId
                                                                        AND recordtype.developerName =: recordTypeDevNameDegree WITH SECURITY_ENFORCED
                                                                    ];
			if (!conAssType.isEmpty() && Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()) {
				conAssType[0].IsDeanLetter__c = isDeanLetter;
				conAssType[0].Courier_service_for_an_additional_fee__c = couriercheckbox;
				conAssType[0].Credential_Type__c = credentialType;
				update conAssType[0];
			}
			isFinalTranscriptRequired = AppForCertHelper.checkFMST(conAssType[0].Account__c);
			Boolean isFMSTCVAccepted = AppForCertHelper.checkFMSTCVAccepted(contactId);
			if(isFinalTranscriptRequired && isFMSTCVAccepted == false && isDeanLetter == false){
				String intakeCATSRecId = getCATSCredIntakeRecord(contactId, parentCaseId);
				manageCATSCredIntakeRecord(intakeCATSRecId, parentCaseId, conAssType, objectList, courierFMST);
			}
			Boolean fmstFlag = false;
			updtOrDltParentAsset(conAssType[0].Id, reSubmitFromAppForCert, keyAssetMap, objectList, fmstFlag);
			for(Asset parentAsset: [SELECT Id, contactId, Parent_Case__c, Contact_Association_Type_Staging__c, Type__c, key__c, Parent_Key__c, ParentId,Azure_Storage_URL__c,Parent_Azure_Storage_URL__c FROM Asset WHERE contactId =: contactId AND key__c IN: keySet AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED]){
				if(keyAssetMap.containsKey(parentAsset.Parent_Key__c)){
					parentAsset.ParentId = keyAssetMap.get(parentAsset.Parent_Key__c);
					parentAsset.Parent_Azure_Storage_URL__c = keyAssetMapParentAzure.get(parentAsset.Parent_Key__c);					
				}
				parentAsset.Uploaded_by_applicant__c = true;
				updatedParentAssetListDummy = updateParentAssetList(parentAsset, objectList, conAssType);
				updatedParentAssetList.addall(updatedParentAssetListDummy);
			}
			if (!updatedParentAssetList.isEmpty() && Schema.sObjectType.Asset.isUpdateable()) {
				update updatedParentAssetList;
			}
		}
		return returnVal;
	}
	// US 16769 - Check Credential Intake CATS ID already there
	public static String getCATSCredIntakeRecord(String contactId, String parentCaseId){
		String intakeCATSRecId = '';
		List<Contact_Association_Type_Staging__c> intakeCATSList = [SELECT Id FROM Contact_Association_Type_Staging__c
                                                                        WHERE Contact__c =: contactId
                                                                        AND Parent_Case__c =: parentCaseId
                                                                        AND recordtype.developerName =: Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE WITH SECURITY_ENFORCED];																
		if(!intakeCATSList.isEmpty()){
			intakeCATSRecId = intakeCATSList[0].Id;
		}
		return intakeCATSRecId;
	}
	// US 16769 - Creating new CATS - Record Type is Credential Intake
	@AuraEnabled
	public static void manageCATSCredIntakeRecord(String intakeCATSRecId, String parentCaseId, List<Contact_Association_Type_Staging__c> conAssType, AppForCertHelper.UpdateParentAssetWrapper objectList, Boolean courierFMST){
		Contact_Association_Type_Staging__c intakeCATSRec = new Contact_Association_Type_Staging__c();
		String credIntakeCATSRecId;
		if(intakeCATSRecId != ''){
			credIntakeCATSRecId = intakeCATSRecId;
			updateCATSCredIntakeRecord(parentCaseId, conAssType, intakeCATSRecId);
		}else{
			intakeCATSRec = createCATSCredIntakeRecord(parentCaseId, conAssType);
			credIntakeCATSRecId = intakeCATSRec.Id;
		}
		Map<String, String> keyAssetMap = new Map<String, String>();
		Map<String, String> keyAssetMapParentAzure = new Map<String, String>();		
		Set<String> keyValue = new Set<String>{
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT
		};
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		Boolean reSubmitFromAppForCert = objectList.reSubmitFromAppForCert;
		for(Asset a: [SELECT Id,Azure_Storage_URL__c,Parent_Azure_Storage_URL__c,key__c, Type__c, Contact_Association_Type_Staging__c, Parent_Key__c, ParentId, Contact_Association_Type__c
				from Asset WHERE contactId =: contactId and key__c IN: keyValue AND status !=: constants.ASSET_STATUS_REJECTED AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY createdDate DESC
			]){				
			keyAssetMap.put(a.key__c, a.Id);
			keyAssetMapParentAzure.put(a.key__c,a.Azure_Storage_URL__c);
		}
		Boolean fmstFlag = true;
		updtOrDltParentAsset(credIntakeCATSRecId, reSubmitFromAppForCert, keyAssetMap, objectList, fmstFlag);
		List<Asset> updatedParentAssetList = new List<Asset>();
		List<Asset> updatedParentAssetListDummy = new List<Asset>();
		for(Asset parentAsset: [SELECT Id, contactId, Parent_Case__c, Contact_Association_Type_Staging__c, Type__c, key__c, Parent_Key__c, ParentId,Azure_Storage_URL__c,Parent_Azure_Storage_URL__c FROM Asset 
									WHERE contactId =: contactId AND key__c IN: keyValue 
										AND status =: Constants.ASSET_STATUS_IN_PROGRESS 
									WITH SECURITY_ENFORCED]) {
			if(keyAssetMap.containsKey(parentAsset.Parent_Key__c)){
				parentAsset.ParentId = keyAssetMap.get(parentAsset.Parent_Key__c);
				parentAsset.Parent_Azure_Storage_URL__c = keyAssetMapParentAzure.get(parentAsset.Parent_Key__c);				
			}
			parentAsset.Parent_Case__c = parentCaseId;
			parentAsset.Uploaded_by_applicant__c = true;
			updatedParentAssetListDummy = updateFMSTParentAssetList(parentAsset, objectList, credIntakeCATSRecId);
			updatedParentAssetList.addall(updatedParentAssetListDummy);
		}
		if(!updatedParentAssetList.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
			update updatedParentAssetList;
		}
		if(credIntakeCATSRecId != ''){
			Contact_Association_Type_Staging__c upd = updateCatscheckbox(credIntakeCATSRecId, courierFMST);
		}
	}
	// US 16769 - Cloning CATS Degree Medical School record to CATS Credential Intake
	public static Contact_Association_Type_Staging__c createCATSCredIntakeRecord(String parentCaseId, List<Contact_Association_Type_Staging__c> conAssType){
		Id intakeCATSRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
		String degMedSchoolCATSId = conAssType[0].id;
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		Contact_Association_Type_Staging__c degMedSchoolCATSRec = [SELECT Id, Account__c, Status__c, Degree_Issue_Date__c, Degree_Issue_Month__c, Degree_Issue_Year__c, Degree_Title__c, Start_Date__c, Start_Month__c, Start_Year__c, End_Date__c, End_Month__c, End_Year__c, Graduation_Date__c, Graduation_Month__c, Graduation_Year__c, 
																	School_Program__c, Specialty__c, Number_of_Years_Attended__c, Student_ID__c, Transfer_Credit_to_Degree_School__c, Courier_service_for_an_additional_fee__c
																	 FROM Contact_Association_Type_Staging__c
                                                                        WHERE Id =: degMedSchoolCATSId WITH SECURITY_ENFORCED];
		Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c();
		if(Schema.sObjectType.Contact_Association_Type_Staging__c.isCreateable()){																			
			stageRec.Contact__c = contactId;
			stageRec.Account__c = degMedSchoolCATSRec.Account__c;
			stageRec.recordTypeId = intakeCATSRecordTypeId;
			stageRec.Status__c = degMedSchoolCATSRec.Status__c;
			stageRec.Degree_Title__c = degMedSchoolCATSRec.Degree_Title__c;
			stageRec.Degree_Issue_Date__c = degMedSchoolCATSRec.Degree_Issue_Date__c;
			stageRec.Degree_Issue_Month__c = degMedSchoolCATSRec.Degree_Issue_Month__c;
			stageRec.Degree_Issue_Year__c = degMedSchoolCATSRec.Degree_Issue_Year__c;		
			stageRec.Start_Date__c =degMedSchoolCATSRec.Start_Date__c;
			stageRec.Start_Month__c = degMedSchoolCATSRec.Start_Month__c;
			stageRec.Start_Year__c = degMedSchoolCATSRec.Start_Year__c;
			stageRec.End_Date__c = degMedSchoolCATSRec.End_Date__c;		
			stageRec.End_Month__c = degMedSchoolCATSRec.End_Month__c;
			stageRec.End_Year__c = degMedSchoolCATSRec.End_Year__c;
			stageRec.Graduation_Date__c = degMedSchoolCATSRec.Graduation_Date__c;
			stageRec.Graduation_Month__c = degMedSchoolCATSRec.Graduation_Month__c;
			stageRec.Graduation_Year__c = degMedSchoolCATSRec.Graduation_Year__c;
			stageRec.School_Program__c = degMedSchoolCATSRec.School_Program__c;
			stageRec.Specialty__c = degMedSchoolCATSRec.Specialty__c;
			stageRec.Student_ID__c = degMedSchoolCATSRec.Student_ID__c;
			stageRec.Number_of_Years_Attended__c = degMedSchoolCATSRec.Number_of_Years_Attended__c;
			stageRec.Transfer_Credit_to_Degree_School__c = degMedSchoolCATSRec.Transfer_Credit_to_Degree_School__c;
			stageRec.Courier_service_for_an_additional_fee__c = degMedSchoolCATSRec.Courier_service_for_an_additional_fee__c;		
			stageRec.Credential_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
			stageRec.Parent_Case__c = parentCaseId;
			stageRec.Case__c = parentCaseId;
			Insert stageRec;
		}
		return stageRec;
	}
	// US 16769 - Updating CATS Degree Medical School record to CATS Credential Intake
	public static void updateCATSCredIntakeRecord(String parentCaseId, List<Contact_Association_Type_Staging__c> conAssType, String intakeCATSRecId){
		Id intakeCATSRecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE).getRecordTypeId();
		String degMedSchoolCATSId = conAssType[0].id;
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		Contact_Association_Type_Staging__c degMedSchoolCATSRec = [SELECT Id, Account__c, Status__c, Degree_Issue_Date__c, Degree_Issue_Month__c, Degree_Issue_Year__c, Degree_Title__c, Start_Date__c, Start_Month__c, Start_Year__c, End_Date__c, End_Month__c, End_Year__c, Graduation_Date__c, Graduation_Month__c, Graduation_Year__c, 
																	School_Program__c, Specialty__c, Number_of_Years_Attended__c, Student_ID__c, Transfer_Credit_to_Degree_School__c, Courier_service_for_an_additional_fee__c
																	 FROM Contact_Association_Type_Staging__c
                                                                        WHERE Id =: degMedSchoolCATSId WITH SECURITY_ENFORCED];
		Contact_Association_Type_Staging__c stageRec = new Contact_Association_Type_Staging__c(Id = intakeCATSRecId);
		if(Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable()){																			
			stageRec.Account__c = degMedSchoolCATSRec.Account__c;
			stageRec.recordTypeId = intakeCATSRecordTypeId;
			stageRec.Status__c = degMedSchoolCATSRec.Status__c;
			stageRec.Degree_Title__c = degMedSchoolCATSRec.Degree_Title__c;
			stageRec.Degree_Issue_Date__c = degMedSchoolCATSRec.Degree_Issue_Date__c;
			stageRec.Degree_Issue_Month__c = degMedSchoolCATSRec.Degree_Issue_Month__c;
			stageRec.Degree_Issue_Year__c = degMedSchoolCATSRec.Degree_Issue_Year__c;		
			stageRec.Start_Date__c =degMedSchoolCATSRec.Start_Date__c;
			stageRec.Start_Month__c = degMedSchoolCATSRec.Start_Month__c;
			stageRec.Start_Year__c = degMedSchoolCATSRec.Start_Year__c;
			stageRec.End_Date__c = degMedSchoolCATSRec.End_Date__c;		
			stageRec.End_Month__c = degMedSchoolCATSRec.End_Month__c;
			stageRec.End_Year__c = degMedSchoolCATSRec.End_Year__c;
			stageRec.Graduation_Date__c = degMedSchoolCATSRec.Graduation_Date__c;
			stageRec.Graduation_Month__c = degMedSchoolCATSRec.Graduation_Month__c;
			stageRec.Graduation_Year__c = degMedSchoolCATSRec.Graduation_Year__c;
			stageRec.School_Program__c = degMedSchoolCATSRec.School_Program__c;
			stageRec.Specialty__c = degMedSchoolCATSRec.Specialty__c;
			stageRec.Student_ID__c = degMedSchoolCATSRec.Student_ID__c;
			stageRec.Number_of_Years_Attended__c = degMedSchoolCATSRec.Number_of_Years_Attended__c;
			stageRec.Transfer_Credit_to_Degree_School__c = degMedSchoolCATSRec.Transfer_Credit_to_Degree_School__c;
			stageRec.Courier_service_for_an_additional_fee__c = degMedSchoolCATSRec.Courier_service_for_an_additional_fee__c;		
			stageRec.Credential_Type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
			stageRec.Parent_Case__c = parentCaseId;
			stageRec.Case__c = parentCaseId;
			update stageRec;
		}
	}
	//US 16769 - Continuation of above updateParentAsset Method.updateFMSTParentAssetList
	@AuraEnabled
	public static List<Asset> updateFMSTParentAssetList(Asset parentAsset, AppForCertHelper.UpdateParentAssetWrapper objectList, String intakeCATSRecId){
		List<Asset> updatedParentAssetList = new List<Asset>();
		Asset rec = parentAsset;
		if (parentAsset.key__c == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT && string.isNotBlank(objectList.nameonFinalTranscriptDocument)) {
			rec.Name_on_Document__c = objectList.nameonFinalTranscriptDocument;
			rec.Name_on_Document_is_Different__c = objectList.isFinalMedicalTranscriptDifferent;
			rec.Document_is_not_in_English__c = objectList.isFinalMedicalTranscriptinEnglish;
		}
		rec.Contact_Association_Type_Staging__c = intakeCATSRecId;		
		updatedParentAssetList.add(rec);
		return updatedParentAssetList;
	}
	/** Created By Sheena John  Purpose : Based on the deanletter chekbox  fetch Contact2Service record and return the prefrered mode of comm  ***/ 
	@AuraEnabled
	public static String checkVerifictn(String accId, boolean isdeancheckbox){	
        String returnValue= '';
		Boolean finalTranscriptReqd = AppForCertHelper.checkFMST(accId);
        List<Account2Service__c> acc2ServPortalList  = new List<Account2Service__c>();
        List<Account2Service__c> acc2ServNonPortalList = new List<Account2Service__c>();
        List<CONTACT2ACCTSERVICE__c> con2AccList = new List<CONTACT2ACCTSERVICE__c>();
		List<CONTACT2ACCTSERVICE__c> con2AccListFMST = new List<CONTACT2ACCTSERVICE__c>();
        if(Account2Service__c.SObjectType.getDescribe().isAccessible()){
            acc2ServPortalList = [Select id,name from Account2Service__c where Account__c =: accId and Service__r.Name=: constants.SERVICE_NAME_CREDENTIAL_VERIFICATION and Active__c = True WITH SECURITY_ENFORCED];
            acc2ServNonPortalList = [Select id,name from Account2Service__c where Account__c =: accId and Service__r.Name=: constants.SERVICE_NAME_CREDENTIAL_VERIFICATION and Active__c = False WITH SECURITY_ENFORCED];
            if(!acc2ServPortalList.isEmpty()){
                returnValue = 'PORTAL';
            }else if(!acc2ServNonPortalList.isEmpty()){
			         if(isdeancheckbox == False){ 
                        con2AccList = [Select id,name,Preferred_Mode_of_Communication__c from CONTACT2ACCTSERVICE__c Where Account_Service__c =: acc2ServNonPortalList[0].Id And Credential_Type__c = 'Final Medical Diploma'AND Active__c = True WITH SECURITY_ENFORCED];
						if(finalTranscriptReqd){
							con2AccListFMST = [Select id,name,Preferred_Mode_of_Communication__c from CONTACT2ACCTSERVICE__c Where Account_Service__c =: acc2ServNonPortalList[0].Id And Credential_Type__c = 'Final Medical School Transcript' AND Active__c = True WITH SECURITY_ENFORCED];
						}
			         }else if(isdeancheckbox == True){
				        con2AccList = [Select id,name,Preferred_Mode_of_Communication__c from CONTACT2ACCTSERVICE__c Where Account_Service__c =: acc2ServNonPortalList[0].Id And Credential_Type__c = 'Letter from Dean' AND Active__c = True WITH SECURITY_ENFORCED];
					}
                if(!con2AccList.isEmpty()){
                    returnValue = checkVerPerMode(con2AccList, con2AccListFMST);
                }
            }
        }
		return returnValue;
	}
	public static string checkVerPerMode(List<CONTACT2ACCTSERVICE__c> con2AccList,List<CONTACT2ACCTSERVICE__c> con2AccListFMST){
        String returnValue = '';
        if(con2AccList[0].Preferred_Mode_of_Communication__c == 'Email' || con2AccList[0].Preferred_Mode_of_Communication__c == 'Website'){
            returnValue = 'NONPORTAL_EM_Web';
        }else if(con2AccList[0].Preferred_Mode_of_Communication__c == 'Paper'){
            returnValue = 'NONPORTAL_PAPER';
			if(!con2AccListFMST.isEmpty() && con2AccListFMST[0].Preferred_Mode_of_Communication__c == 'Paper'){
				returnValue = 'NONPORTAL_PAPER_FMD_FMST';
			}
        }
        return returnValue;
    }
	// Purpose : Method to refactor updateParentAsset 
	@AuraEnabled
	public static void updtOrDltParentAsset(String catsId, Boolean reSubmitFromAppForCert, Map<String, String> keyAssetMap, AppForCertHelper.UpdateParentAssetWrapper objectList, Boolean fmstFlag) {
		if (reSubmitFromAppForCert) {
			dltAssetforResubAppForCert(catsId, keyAssetMap, objectList, fmstFlag);
		} else {
			updateParentAssetRefactor(catsId, keyAssetMap, objectList, fmstFlag);
		}
	}

	//Purpose : Continuation of above updateParentAsset Method
	@AuraEnabled
	public static string getRecordTypeDegree(Boolean showExamRegActionButton) {
		String recordTypeDevNameDegree;
		if (showExamRegActionButton == true) {
			recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
		} else {
			recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
		}
		return recordTypeDevNameDegree;
	}

	//Purpose : Continuation of above updateParentAsset Method.
	@AuraEnabled
	public static List<Asset> updateParentAssetList(Asset parentAsset, AppForCertHelper.UpdateParentAssetWrapper objectList, List<Contact_Association_Type_Staging__c> conAssType){
		List<Asset> updatedParentAssetList = new List<Asset>();
		Asset rec = parentAsset;
		if (parentAsset.key__c == System.Label.App_for_Cert_DIPLOMA_DOCUMENT && string.isNotBlank(objectList.nameonDiplomaDocument)) {
			rec.Name_on_Document__c = objectList.nameonDiplomaDocument;
			rec.Name_on_Document_is_Different__c = objectList.isDiplomaNameDifferent;
			rec.Document_is_not_in_English__c = objectList.isDiplomaNameinEnglish;
		}
		if (parentAsset.key__c == System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT && string.isNotBlank(objectList.nameonDeanLetterDocument)) {
			rec.Name_on_Document__c = objectList.nameonDeanLetterDocument;
			rec.Name_on_Document_is_Different__c = objectList.isDeanLetterDifferent;
			rec.Document_is_not_in_English__c = objectList.isDeanLetterNameinEnglish;
			rec.Dean_s_Letter_Date__c = objectList.dateonDeanLetterDocument;
		}
		if (parentAsset.Contact_Association_Type_Staging__c == null || parentAsset.Contact_Association_Type_Staging__c != conAssType[0].id){
			rec.Contact_Association_Type_Staging__c = conAssType[0].id;
		}		
		rec.Parent_Case__c = conAssType[0].Parent_Case__c;
		updatedParentAssetList.add(rec);
		return updatedParentAssetList;
	}

	//Purpose : Continuation of above updateParentAsset Method
	@AuraEnabled
	public static void updateParentAssetRefactor(String catsId, Map<String, String> keyAssetMap, AppForCertHelper.UpdateParentAssetWrapper objectList, Boolean fmstFlag){
		String contactId = objectList.contactId;
		Boolean isDeanLetter = objectList.isDeanLetter;
		Boolean isDiplomaNameDifferent = objectList.isDiplomaNameDifferent;
		Boolean isDiplomaNameinEnglish = objectList.isDiplomaNameinEnglish;
		Boolean isDeanLetterNameinEnglish = objectList.isDeanLetterNameinEnglish;
		Boolean isFinalMedicalTranscriptinEnglish = objectList.isFinalMedicalTranscriptinEnglish;
		Boolean isFinalMedicalTranscriptDifferent = objectList.isFinalMedicalTranscriptDifferent;
		if(fmstFlag){
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, '');
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, '');
			}
			if (!isFinalMedicalTranscriptinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, '');
			}
			if (!isFinalMedicalTranscriptDifferent){
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, '');
			}
		}else{
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_DIPLOMA_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, '');
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, '');
			}		
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, '');
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, '');
			}
			if (!isDiplomaNameDifferent) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, '');
			}
			if (!isDiplomaNameinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, '');
			}
			if (!isDeanLetterNameinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, '');
			}
		}	
		if (isDeanLetter) {
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, '');
		} else {
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, '');
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, '');
		}
	}

	//Purpose : Continuation of above updateParentAsset Method
	@AuraEnabled
	public static void dltAssetforResubAppForCert(String catsId, Map<String, String> keyAssetMap, AppForCertHelper.UpdateParentAssetWrapper objectList, Boolean fmstFlag){
		String contactId = objectList.contactId;
		Boolean isDeanLetter = objectList.isDeanLetter;
		Boolean isDiplomaNameDifferent = objectList.isDiplomaNameDifferent;
		Boolean isDiplomaNameinEnglish = objectList.isDiplomaNameinEnglish;
		Boolean isDeanLetterNameinEnglish = objectList.isDeanLetterNameinEnglish;
		Boolean isFinalMedicalTranscriptinEnglish = objectList.isFinalMedicalTranscriptinEnglish;
		Boolean isFinalMedicalTranscriptDifferent = objectList.isFinalMedicalTranscriptDifferent;
		Id caseId = AppForCertHelper.getCaseId();
		String conAssTypeId = catsId;
		if(fmstFlag){
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, conAssTypeId);
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, conAssTypeId);
			}
			if (!isFinalMedicalTranscriptinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, conAssTypeId);
			}
			if(!isFinalMedicalTranscriptDifferent) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, conAssTypeId);
			}
		}else{
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_DIPLOMA_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, conAssTypeId);
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, conAssTypeId);
			}
			if (!keyAssetMap.containsKey(System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT)) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, conAssTypeId);
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, conAssTypeId);
			}
			if (!isDiplomaNameDifferent) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, conAssTypeId);
			}
			if (!isDiplomaNameinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, conAssTypeId);
			}
			if (!isDeanLetterNameinEnglish) {
				deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, conAssTypeId);
			}			
		}
		if (isDeanLetter) {
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, conAssTypeId);
		} else {
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, conAssTypeId);
			deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, conAssTypeId);
		}		
	}
	
	//Purpose : Method to delete Asset and related content document
	@AuraEnabled(cacheable = false)
	public static void deleteAssetAndRelatedDocument(String contactId, String keyval, String contactAssociationTypeStagingId) {
		List<Asset> assetList = new List<Asset> ();
		if (keyval == Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC) {
			assetList = [Select Id from Asset where ContactId =: contactId AND key__c =: keyval AND Case__c = ''
				AND Exam_Registration__c = ''
				AND IsExpired__c = FALSE AND IsOrphan__c = FALSE AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED
			];
		} else {
			if (contactAssociationTypeStagingId != '') {
				assetList = getAssetList(contactAssociationTypeStagingId, keyval, contactId);
			} else {
				assetList = [Select Id from Asset where ContactId =: contactId AND key__c =: keyval AND IsExpired__c = FALSE AND IsOrphan__c = FALSE AND status !=:Constants.ASSET_STATUS_ACCEPTED AND status !=:Constants.ASSET_STATUS_REJECTED AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
			}
		}
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink> ();
		List<ContentDocument> cdList = new List<ContentDocument> ();
		if (!assetList.isEmpty()) {
			cdlList = [Select Id, ContentDocumentId from ContentDocumentLink
				Where LinkedEntityId =: assetList[0].Id WITH SECURITY_ENFORCED
			];
			if (!cdlList.isEmpty()) {
				cdList = [Select Id from ContentDocument where Id =: cdlList[0].ContentDocumentId WITH SECURITY_ENFORCED];
			}
		}
		if (!cdlList.isEmpty() && Schema.sObjectType.ContentDocumentLink.isDeletable()) {
			delete cdlList;
		}
		if (!cdList.isEmpty() && Schema.sObjectType.ContentDocument.isDeletable()) {
			delete cdList;
		}
		deleteAffirmationAndUpdateAsset(assetList);
	}

	//method to delete the affirmations and update the asset status to Marked For Deletion
	public static void deleteAffirmationAndUpdateAsset(List<Asset> assetList) {
		List<Affirmation__c > afmList = new List<Affirmation__c > ();
		List<Asset> assetListToUpdate = new List<Asset> ();
		if (!assetList.isEmpty()) {
			String recordtypeAssetId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
			for (Asset eachAsset: assetList) {
				eachAsset.Status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				eachAsset.RecordTypeId = recordtypeAssetId;
				eachAsset.Contact_Association_Type_Staging__c = null;
				eachAsset.Parent_Case__c = null;
				eachAsset.Case__c = null;
				assetListToUpdate.add(eachAsset);
			}
			if (Schema.sObjectType.Asset.isUpdateable()) {
				update assetListToUpdate;
			}
		}
	}
	//method to get the list of assets for deletion.
	public static List<Asset> getAssetList(string contactAssociationTypeStagingId, String keyval, String contactId) {
		List<Asset> assetList = new List<Asset>();
		assetList = [Select Id from Asset where ContactId =: contactId AND key__c =: keyval
					AND Contact_Association_Type_Staging__c =: contactAssociationTypeStagingId AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
					AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED];
		//to handle the existing GradScreen delete functionality while checking the box 'I dont have a diploma'.
		if(assetList.isEmpty()){
			assetList = [Select Id from Asset where ContactId =: contactId AND key__c =: keyval
			AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
			AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND status =: constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED];
		}
		return assetList;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getDocument
	 * Purpose : Method used in file upload component to get file name and type
	 * Return Type : String
	 */
	@AuraEnabled(cacheable = false)
	public static String getDocument(String contactId, String keyval, String contactAssociationType, String parentId) {
		String returnValue = '';
		List<Asset> assetList = new List<Asset> ();
		if (contactAssociationType != '' && contactAssociationType != 'null' && contactAssociationType != 'undefined') {
			assetList = [Select Id from Asset where ContactId =: contactId AND key__c =: keyval
				AND Contact_Association_Type_Staging__c =: contactAssociationType AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		if (keyval == Constants.ASSET_KEYVAL_VISA_EXCEPTION_DOC) {
			assetList = [Select Id from Asset where ContactId =: contactId AND
				key__c =: keyval AND
				IsExpired__c = FALSE AND
				IsOrphan__c = FALSE AND
				Case__c =: parentId AND
				status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink> ();
		List<ContentDocument> cdList = new List<ContentDocument> ();
		if (!assetList.isEmpty()) {
			cdlList = [Select Id, ContentDocumentId from ContentDocumentLink
				Where LinkedEntityId =: assetList[0].Id
			];
			if (!cdlList.isEmpty()) {
				cdList = [Select Id, Title, FileType from ContentDocument where Id =: cdlList[0].ContentDocumentId];
				if (!cdList.isEmpty()) {
					String fileURL = Constants.FILE_DOWNLOAD_URL + cdList[0].Id;
					returnValue = cdList[0].Title + ':`:' + cdList[0].FileType + ':`:' + fileURL;
				}
			}
		}
		return returnValue;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getDocumentbyId
	 * Purpose : Method used in create Asset method to return content document's file namd and type
	 * Return Type : String
	 */
	public static String getDocumentbyId(String contentdocId) {
		String returnValue = '';
		List<ContentDocument> cdList = new List<ContentDocument> ();

		if (contentdocId != null) {
			cdList = [Select Id, Title, FileType from ContentDocument where Id =: contentdocId];
			if (!cdList.isEmpty()) {
				String fileURL = Constants.FILE_DOWNLOAD_URL + cdList[0].Id;
				returnValue = cdList[0].Title + ':`:' + cdList[0].FileType + ':`:' + fileURL;
			}
		}

		return returnValue;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getContactName
	 * Purpose : Method to return Contact's Name
	 * Return Type : String
	 */
	@AuraEnabled(cacheable = true)
	public static string getContactName(String contactId) {
		String conName = '';
		List<Contact> con = new List<Contact> ();
		if (contactId != null) {
			con = [Select Id, Name from Contact where Id =: contactId];
			if (!con.isEmpty()) conName = con[0].Name;
		}
		return conName;
	}

	/**
	 * Created by Balashankar
	 * Method Name: checkIsDeanLetter
	 * Purpose : Method to check whether the Graduate is opted for Diploma (or) Dean's Letter
	 * Return Type : Boolean
	 */
	@AuraEnabled(cacheable = false)
	public static Boolean checkIsDeanLetter(String contactAssociationStagingId) {
		Boolean returnVal = false;
		List<Contact_Association_Type_Staging__c > conType = new List<Contact_Association_Type_Staging__c > ();
		if (contactAssociationStagingId != null) {
			conType = [Select Id, IsDeanLetter__c from Contact_Association_Type_Staging__c
				where Id =: contactAssociationStagingId
			];
			if (!conType.isEmpty()) {
				returnVal = conType[0].IsDeanLetter__c;
			}
		}
		return returnVal;
	}

	// Method to return Primary Assets
	@AuraEnabled(cacheable = false)
	public static Boolean getPrimaryAssets(String contactId, String keyVal){
		Boolean returnValue = false;
		String csId = AppForCertHelper.getCaseId();
		Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
		List<Asset> assetList = new List<Asset>();
		assetList = [SELECT Id, Case__c, Name_on_Document__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Dean_s_Letter_Date__c
			FROM Asset WHERE ContactId =: contactId AND Parent_Case__c =: csId AND key__c =: keyVal AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
			AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
		];
		if(!assetList.isEmpty()){
			returnValue = true;
		}
		return returnValue;
	}

	// Method to return Name on Document field value for all Assets
	@AuraEnabled(cacheable = false)
	public static List<String> getAssetNameonDocument(String contactId, String keyVal, String contactAssociationStagingId) {
		List<String> returnValue = new List<String> ();
		List<String> returnValueFromMethod1 = new List<String> ();
		List<String> returnValueFromMethod2 = new List<String> ();
		List<Asset> assetList = new List<Asset> ();
		String csId = AppForCertHelper.getCaseId();
		if (String.isNotBlank(contactAssociationStagingId)) {
			assetList = [SELECT Id, Azure_Storage_URL__c, Case__c, Name_on_Document__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Dean_s_Letter_Date__c 
				FROM Asset WHERE ContactId =: contactId and Contact_Association_Type_Staging__c =: contactAssociationStagingId AND key__c =: keyVal AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1
			];
			/*
			if(assetList.isEmpty()){
				assetList = [SELECT Id, Azure_Storage_URL__c, Case__c, Name_on_Document__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Dean_s_Letter_Date__c
					FROM Asset WHERE ContactId =: contactId AND key__c =: keyVal AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
					AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1
				];
			}
			*/
		} else {
			assetList = [SELECT Id, Azure_Storage_URL__c, Case__c, Name_on_Document__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Dean_s_Letter_Date__c
				FROM Asset WHERE ContactId =: contactId AND key__c =: keyVal AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1
			];
		}
		if (!assetList.isEmpty()) {
			returnValueFromMethod1 = getAssetNameonDocumentDiplomaDocument(keyVal, assetList);
			returnValue.addall(returnValueFromMethod1);
			returnValueFromMethod2 = getAssetNameonDocumentMedSchoolTransciptTransD(keyVal, assetList);
			returnValue.addall(returnValueFromMethod2);

			if (keyVal == System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT) {
				if (assetList[0].Name_on_Document__c == null) {
					returnValue.add('EMPTY');
				} else {
					returnValue.add(assetList[0].Name_on_Document__c);
				}
				returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
				returnValue.add(String.valueof(assetList[0].Document_is_not_in_English__c));
				returnValue.add(String.valueof(assetList[0].Dean_s_Letter_Date__c));
			}
			if (keyVal == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT) {

				if (assetList[0].Name_on_Document__c == null) {
					returnValue.add('EMPTY');
				} else {
					returnValue.add(assetList[0].Name_on_Document__c);
				}
				returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
			}
			returnValue.add(assetList[0].Azure_Storage_URL__c);

		}
		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getAssetNameonDocumentDiplomaDocument
	 * Purpose : Method to return Name on Document field value for all Assets
	 * Return Type : List<string>
	 */
	@AuraEnabled(cacheable = false)
	public static List<String> getAssetNameonDocumentDiplomaDocument(String keyVal, List<Asset> assetList) {

		List<String> returnValue = new List<String> ();

		if (keyVal == System.Label.App_for_Cert_DIPLOMA_DOCUMENT) {

			if (assetList[0].Name_on_Document__c == null) {
				returnValue.add('EMPTY');
			} else {
				returnValue.add(assetList[0].Name_on_Document__c);
			}
			returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
			returnValue.add(String.valueof(assetList[0].Document_is_not_in_English__c));
		}
		if (keyVal == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT) {
			if (assetList[0].Name_on_Document__c == null) {
				returnValue.add('EMPTY');
			} else {
				returnValue.add(assetList[0].Name_on_Document__c);
			}
			returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
		}
		if (keyVal == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT) {

			if (assetList[0].Name_on_Document__c == null) {
				returnValue.add('EMPTY');
			} else {
				returnValue.add(assetList[0].Name_on_Document__c);
			}
			returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
			returnValue.add(String.valueof(assetList[0].Document_is_not_in_English__c));
		}

		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getAssetNameonDocumentMedSchoolTransciptTransD
	 * Purpose : Method to return Name on Document field value for all Assets
	 * Return Type : List<string>
	 */
	@AuraEnabled(cacheable = false)
	public static List<String> getAssetNameonDocumentMedSchoolTransciptTransD(String keyVal, List<Asset> assetList) {

		List<String> returnValue = new List<String> ();
		if (keyVal == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT) {

			if (assetList[0].Name_on_Document__c == null) {
				returnValue.add('EMPTY');
			} else {
				returnValue.add(assetList[0].Name_on_Document__c);
			}
			returnValue.add(String.valueof(assetList[0].Name_on_Document_is_Different__c));
		}
		return returnValue;
	}

	/**
	 * Created by Femi
	 * Method Name: getStartDateAndEndDate
	 * Purpose : Method to get start date , End date and Degree issue date of medical school
	 * Return Type : date
	 */
	@AuraEnabled(cacheable = false)
	public static Map<String, Date> getStartDateAndEndDate(String objectId, String objectType) {

		Map<String, Date> valuesToReturn = new Map<String, Date> ();
		if (objectType == 'Contact_Association_Type_Staging__c') {
			Contact_Association_Type_Staging__c data = [SELECT Start_Date__c, End_Date__c, Degree_Issue_Date__c FROM Contact_Association_Type_Staging__c where id =: objectId][0];
			valuesToReturn.put('Start_Date__c', data.Start_Date__c);
			valuesToReturn.put('End_Date__c', data.End_Date__c);
			valuesToReturn.put('Degree_Issue_Date__c', data.Degree_Issue_Date__c);

		} else {
			Contact_Association_Type__c data = [SELECT Start_Date__c, End_Date__c, Degree_Issue_Date__c FROM Contact_Association_Type__c where id =: objectId][0];
			valuesToReturn.put('Start_Date__c', data.Start_Date__c);
			valuesToReturn.put('End_Date__c', data.End_Date__c);
			valuesToReturn.put('Degree_Issue_Date__c', data.Degree_Issue_Date__c);
		}
		return valuesToReturn;

	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: getStartEndAndDegreeMonthYear
	 * Purpose : Method to get start, End and Degree issue month & year of medical school
	 * Parameters : 
	 * Return Type : String
	 */
	@AuraEnabled(cacheable = false)
	public static Map<String, String> getStartEndAndDegreeMonthYear(String objectId, String objectType) {

		Map<String, String> valuesToReturn = new Map<String, String> ();

		if (objectType == 'Contact_Association_Type_Staging__c') {
			Contact_Association_Type_Staging__c data = [SELECT Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Degree_Issue_Month__c, Degree_Issue_Year__c FROM Contact_Association_Type_Staging__c where id =: objectId][0];
			valuesToReturn.put('Start_Month__c', data.Start_Month__c);
			valuesToReturn.put('Start_Year__c', data.Start_Year__c);
			valuesToReturn.put('End_Month__c', data.End_Month__c);
			valuesToReturn.put('End_Year__c', data.End_Year__c);
			valuesToReturn.put('Degree_Issue_Month__c', data.Degree_Issue_Month__c);
			valuesToReturn.put('Degree_Issue_Year__c', data.Degree_Issue_Year__c);
		} else {
			Contact_Association_Type__c data = [SELECT Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Degree_Issue_Month__c, Degree_Issue_Year__c FROM Contact_Association_Type__c where id =: objectId][0];
			valuesToReturn.put('Start_Month__c', data.Start_Month__c);
			valuesToReturn.put('Start_Year__c', data.Start_Year__c);
			valuesToReturn.put('End_Month__c', data.End_Month__c);
			valuesToReturn.put('End_Year__c', data.End_Year__c);
			valuesToReturn.put('Degree_Issue_Month__c', data.Degree_Issue_Month__c);
			valuesToReturn.put('Degree_Issue_Year__c', data.Degree_Issue_Year__c);
		}
		return valuesToReturn;
	}

	// Method to check validation in Other Medical school & Other Institution page for Graduate
	@AuraEnabled(cacheable = false)
	public static Boolean yearsAttended(Id caseId, Boolean showExamRegActionButton){
		Boolean returnValue = false;
		List<Contact_Association_Type_Staging__c> conAssocDegreeMedicalSchoolLists = new List<Contact_Association_Type_Staging__c>();
		if(caseId != null){
			String recordTypeDevNameDegree;
			if(showExamRegActionButton == true){
				recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
			} else {
				recordTypeDevNameDegree = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
			}
			conAssocDegreeMedicalSchoolLists = [SELECT id, Status__c, Account__c, Number_of_Years_Attended__c, Degree_Title__c, Account__r.Curriculum_Duration__c, Start_Date__c, End_Date__c
				FROM Contact_Association_Type_Staging__c
				WHERE recordType.DeveloperName =: recordTypeDevNameDegree
				AND Case__c =: caseId
			];
			if(!conAssocDegreeMedicalSchoolLists.isEmpty()){
				if(conAssocDegreeMedicalSchoolLists[0].Status__c == System.Label.Medical_Education_type_Graduate){
					Decimal finaldiffyears = 0;
					Decimal dmsCurriculumYears;
					dmsCurriculumYears = yearsAttendedRefactorContDMSCurriYears(conAssocDegreeMedicalSchoolLists);
					finaldiffyears = yearsAttendedRefactorCont(caseId, conAssocDegreeMedicalSchoolLists);
					if(finaldiffyears >= dmsCurriculumYears){
						returnValue = true;
					}
				}else{
					returnValue = true;
				}
			}
		}
		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: yearsAttendedRefactorCont2nd
	 * Purpose : Method to check validation in Other Medical school & Other Institution page for Graduate
	 * Return Type : Decimal
	 */
	@AuraEnabled(cacheable = false)
	public static Decimal yearsAttendedRefactorContDMSCurriYears(List<Contact_Association_Type_Staging__c > conAssocDegreeMedicalSchoolLists) {

		Decimal dmsCurriculumYears = conAssocDegreeMedicalSchoolLists[0].Account__r.Curriculum_Duration__c;
		if (dmsCurriculumYears == null || dmsCurriculumYears > Constants.CURRICULUM_YEARS_GRADUATE) {
			dmsCurriculumYears = Constants.CURRICULUM_YEARS_GRADUATE;
		}
		return dmsCurriculumYears;
	}

	/**
	 * Created by Jofrin
	 * Method Name: yearsAttendedRefactorCont
	 * Purpose : Method to check validation in Other Medical school & Other Institution page for Graduate
	 * Return Type : Decimal
	 */
	@AuraEnabled(cacheable = false)
	public static Decimal yearsAttendedRefactorCont(ID caseId, List<Contact_Association_Type_Staging__c > conAssocDegreeMedicalSchoolLists) {

		Decimal finaldiffyears = 0;

		if (conAssocDegreeMedicalSchoolLists[0].Number_of_Years_Attended__c != null) {
			finaldiffyears = finaldiffyears + conAssocDegreeMedicalSchoolLists[0].Number_of_Years_Attended__c;
		}

		// Checking in Medical School record type
		List<Contact_Association_Type_Staging__c > conAssocMedicalSchoolLists = new List<Contact_Association_Type_Staging__c > ();
		conAssocMedicalSchoolLists = [SELECT id, Status__c, Account__c, Number_of_Years_Attended__c, Degree_Title__c, Account__r.Curriculum_Duration__c, Start_Date__c, End_Date__c
			FROM Contact_Association_Type_Staging__c
			WHERE(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG)
			AND Case__c =: caseId AND
			Transfer_Credit_to_Degree_School__c = true
		];

		if (!conAssocMedicalSchoolLists.isEmpty() && conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c != null) {
			finaldiffyears = finaldiffyears + conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c;
		}

		// Checking in Other Institution record type
		List<Contact_Association_Type_Staging__c > conAssocOtherInstitutionLists = new List<Contact_Association_Type_Staging__c > ();
		conAssocOtherInstitutionLists = [SELECT id, Status__c, Account__c, Number_of_Years_Attended__c, Degree_Title__c, Account__r.Curriculum_Duration__c, Start_Date__c, End_Date__c
			FROM Contact_Association_Type_Staging__c
			WHERE(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG)
			AND Case__c =: caseId
		];

		if (!conAssocOtherInstitutionLists.isEmpty()) {
			for (Contact_Association_Type_Staging__c tempInst: conAssocOtherInstitutionLists) {
				if (tempInst.Number_of_Years_Attended__c != null) {
					finaldiffyears = finaldiffyears + tempInst.Number_of_Years_Attended__c;
				}
			}
		}
		return finaldiffyears;
	}

	/**
	 * Method Name: manageReporterQuestionValue
	 * Purpose : Method to update reporter question value in contact
	 * Return Type : Boolean
	 * @Params : List of fields and values as json string
	 */
	@AuraEnabled
	public static Boolean manageReporterQuestionValue(String fieldvals) {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();

		Contact updRepQuesVal = [Select Id, ECFMG_Reporter__c from Contact Where id =: contactId];
		updRepQuesVal.ECFMG_Reporter__c = Boolean.valueOf(fieldvals);
		Update updRepQuesVal;

		return true;
	}

	/**
	 * Method Name: getTermsandConditionsData
	 * Purpose : Method to fetch Terms and conditions content to display
	 * Return Type : List of wrapper with terms content
	 * @Params : None
	 */
	@AuraEnabled(Cacheable = true)
	public static List<AppForCertHelper.TermsObjWrapper > getTermsandConditionsData() {
		List<AppForCertHelper.TermsObjWrapper > fetchedValuesToReturn = new List<AppForCertHelper.TermsObjWrapper > ();
		List<Terms_and_Conditions__c > termsList = new List<Terms_and_Conditions__c > ();
		termsList = [Select Id, Copy__c, Name, Short_Copy__c From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS
			and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			Order By CreatedDate ASC
		];
		if (!termsList.isEmpty()) {
			For(Terms_and_Conditions__c terms: termsList) {
				string termsId = terms.Id;
				string termsContent = terms.Copy__c;
				string termsCheckBox = terms.Short_Copy__c;

				AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);

				fetchedValuesToReturn.add(tempTermsObj);
			}
		}

		return fetchedValuesToReturn;
	}

	/**
	 * Method Name: createTermsRecord
	 * Purpose : Methodto create terms and conditions record for contact
	 * Return Type : Boolean
	 * @Params : None
	 */

	@AuraEnabled
	public static Boolean createTermsRecord(string examRegVar) {

		List<Terms_and_Conditions__c > termsList = new List<Terms_and_Conditions__c > ();
		if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_EXAM_REGISTRATION_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		} else if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_APP_FOR_CERT_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		} else if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		} else if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_EPEX_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_EPEX_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		} else if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_TRANSCRIPT_REQUEST_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		} else if (String.isNotEmpty(examRegVar) && examRegVar == constants.PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS) {
			termsList = [Select Id, Copy__c, Name From Terms_and_Conditions__c Where Product__r.Name =: Constants.PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS
				and Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE
			];
		}
		if (!termsList.isEmpty()) {
			createTermsRecordRefactorContinue(termsList);
		}

		return true;
	}

	/**
	 * Method Name: createTermsRecordRefactorContinue
	 * Purpose : Continuation of createTermsRecord Methodto create terms and conditions record for contact
	 * Return Type : string
	 * @Params : termsList
	 */

	@AuraEnabled
	public static void createTermsRecordRefactorContinue(List<Terms_and_Conditions__c > termsList) {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<Id> termsId = new List<Id> ();
		For(Terms_and_Conditions__c terms: termsList) {
			termsId.add(terms.Id);
		}

		List<Terms_and_Conditions_Agreement__c > deactList = new List<Terms_and_Conditions_Agreement__c > ();
		deactList = [Select Id, Status__c From Terms_and_Conditions_Agreement__c Where Contact__c =: contactId And TermsandConditions__c IN: termsId];
		if (!deactList.isEmpty()) {
			For(Terms_and_Conditions_Agreement__c deactRec: deactList) {
				deactRec.Status__c = Constants.TERMS_AND_COND_AGR_STATUS_INACTIVE;
			}
			Update deactList;
		}

		List<Terms_and_Conditions_Agreement__c > termsInsert = new List<Terms_and_Conditions_Agreement__c > ();
		For(Terms_and_Conditions__c term: termsList) {
			Terms_and_Conditions_Agreement__c tcAgr = new Terms_and_Conditions_Agreement__c(
				Contact__c = contactId, TermsandConditions__c = term.Id, Name = term.Name + contactId, Status__c = Constants.TERMS_AND_COND_AGR_STATUS_ACTIVE, Copy__c = term.Copy__c);

			termsInsert.add(tcAgr);
		}
		Insert termsInsert;

	}

	// Method to fetch other medical school records along with transfer credits if any
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c> getOtherMedicalSchoolsWithTransferCredits(Boolean showExamRegActionButton, Boolean showCaseDetail, String caseRecordId){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
		}
		List<Contact_Association_Type_Staging__c> medicalschoolsList = new List<Contact_Association_Type_Staging__c>
			([SELECT Id, Account__c, Account_Name__c, School_Program__c, Start_Date__c, End_Date__c, Start_Month__c, End_Month__c, Start_Year__c, End_Year__c, Student_ID__c, Specialty__c, Number_of_Years_Attended__c, Transfer_Credit_to_Degree_School__c,
				(SELECT Id, To_School__c, From_School__c, From_School_Name__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC),
				(SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName
				AND Parent_Case__c =: caseRecordId
				ORDER BY createdDate ASC
			]);
		return medicalschoolsList;
	}

	/**
	 * Created by Ajith Vamsani on 11/01/2020
	 * Method Name: isApplicantGraduate
	 * Purpose : Method to check if the applicant is graduate or not
	 * Return Type : Boolean
	 * @Params : Record Id of the contact association type staging object
	 */
	@AuraEnabled(Cacheable = false)
	public static Boolean isApplicantGraduate(Boolean showExamRegActionButton, Boolean showCaseDetail) {
		Boolean isGraduate = false;

		String recordTypeDeveloperName;
		if (showExamRegActionButton == true) {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
		} else {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
		}

		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id currentCaseId = getCaseIdAllStatus(showCaseDetail, contactId);

		List<Contact_Association_Type_Staging__c > existingConAssoStagingObjList = [SELECT Id, Status__c FROM Contact_Association_Type_Staging__c
			WHERE recordType.DeveloperName =: recordTypeDeveloperName
			AND Parent_Case__c =: currentCaseId
		];

		if (!existingConAssoStagingObjList.isEmpty() && existingConAssoStagingObjList[0].Status__c == Constants.CONASCTYPESTG_STATUS_GRADUATE) {
			isGraduate = true;
		}

		return isGraduate;
	}

	/**
	 * Created by Chinmay Menon on 18/02/2020
	 * Method Name: isApplicantGraduate
	 * Purpose : Method to check if the applicant is graduate or not
	 * Return Type : Boolean
	 * @Params : Record Id of the contact association type staging object
	 */
	@AuraEnabled(Cacheable = false)
	public static Boolean isApplicantStudentOrGraduate() {
		Boolean isGraduate = false;

		Id contactId = AppforCertHelper.retrieveCurrentContactId();

		String contactStatus = [SELECT School_Enrollment_Status__c
			FROM Contact
			WHERE id =: contactId
		].School_Enrollment_Status__c;

		if (contactStatus == Constants.CONASCTYPESTG_STATUS_GRADUATE) {
			isGraduate = true;
		}

		return isGraduate;
	}

	// Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getAssetsAndDocuments(String recId) {
		Map<String, String> returnValue = new Map<String, String> ();
		String tctId = null;
		String tctName = '';
		String tctNameDiff = '';
		String tctTransId = null;
		String tctTrans = '';
		String tctTransName = '';
		String tctNameDocId = '';
		String tctTransNameDiff = '';
		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		List<Id> assetIds = new List<Id> ();
		List<Asset> assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId FROM Asset WHERE
			Contact_Association_Type_Staging__c =: recId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
		];
		tctId = getAssetsAndDocumentsRefactMethodtctId(assetList);
		for (Asset rec: assetList) {
			assetIds.add(rec.Id);
			assetsMap.put(rec.Id, rec);
			if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
				tctId = rec.Id;
				tctName = rec.Name_on_Document__c;
				tctNameDiff = 'No';
				if (rec.Name_on_Document_is_Different__c) {
					tctNameDiff = 'Yes';
				}
				tctTrans = 'No';
				if (rec.Document_is_not_in_English__c) {
					tctTrans = 'Yes';
				}
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == tctId) {
				tctTransId = rec.Id;
				tctTransName = rec.Name_on_Document__c;
				tctTransNameDiff = 'No';
				if (rec.Name_on_Document_is_Different__c) {
					tctTransNameDiff = 'Yes';
				}
			} else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == tctId) {
				tctNameDocId = rec.Id;
			}
		}
		if (assetIds.size() > 0) {
			returnValue = getAssetsAndDocumentsRefactMethod(assetIds, assetsMap, tctId, tctTransId);
		}
		returnValue.put('tctId', tctId);
		returnValue.put('tctName', tctName);
		returnValue.put('tctNameDiff', tctNameDiff);
		returnValue.put('tctTransId', tctTransId);
		returnValue.put('tctTrans', tctTrans);
		returnValue.put('tctTransName', tctTransName);
		returnValue.put('tctNameDocId', tctNameDocId);
		returnValue.put('tctTransNameDiff', tctTransNameDiff);
		returnValue.put('recid', recId);
		return returnValue;
	}

	@AuraEnabled(Cacheable = false)
	public static String getAssetsAndDocumentsRefactMethodtctId(List<Asset> assetList) {

		String tctId = null;
		for (Asset assId: assetList) {
			if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
				tctId = assId.Id;
			}
		}
		return tctId;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getAssetsAndDocumentsRefactMethod
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert.Continuation of above method getAssetsAndDocuments.
	 * Return Type : List of Wrapper
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getAssetsAndDocumentsRefactMethod(List<Id> assetIds, Map<Id, Asset> assetsMap, String tctId, String tctTransId) {

		String tctFile = '';
		String tctNameDoc = '';
		String tctTransFile = '';
		String tctTransNameDoc = '';

		Map<String, String> returnValue = new Map<String, String> ();
		List<ContentDocumentLink> contentDocumentLinksList = new List<ContentDocumentLink> ();
		Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
		List<Id> contentDocumentIds = new List<Id> ();
		Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();

		for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {

			contentDocumentLinksList.add(contentDoc);
			contentDocumentIds.add(contentDoc.ContentDocumentId);
			if (!contentMap.containsKey(contentDoc.LinkedEntityId)) {
				contentMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> ());
			}
			contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
		}
		if (contentDocumentIds.size() > 0) {
			for (ContentVersion contentVer: [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds]) {
				contentVersionMap.put(contentVer.ContentDocumentId, contentVer);
			}
		}

		for (Id assetId: assetsMap.keyset()) {
			Id fileId;
			fileId = getAssetsAndDocumentsRefactMethodFileId(assetId, contentMap, contentVersionMap);

			Asset assetRecord = assetsMap.get(assetId);
			if (assetRecord.Type__c == Constants.ASSET_TYPE_TCT) {
				tctFile = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId) {
				tctNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId) {
				tctTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctTransId) {
				tctTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
			}
		}

		returnValue.put('tctFile', tctFile);
		returnValue.put('tctNameDoc', tctNameDoc);
		returnValue.put('tctTransFile', tctTransFile);
		returnValue.put('tctTransNameDoc', tctTransNameDoc);

		return returnValue;
	}

	@AuraEnabled(Cacheable = false)
	public static Id getAssetsAndDocumentsRefactMethodFileId(Id assetId, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {

		Id fileId;
		if (contentMap.get(assetId) != null) {
			for (ContentDocumentLink contentlink: contentMap.get(assetId)) {
				if (contentVersionMap.get(contentlink.ContentDocumentId) != null) {
					fileId = contentVersionMap.get(contentlink.ContentDocumentId).ContentDocumentId;
				}
			}
		}
		return fileId;
	}

	/**
	 * Created by Ajoydhas
	 * Method Name: getInstAssetsAndDocumentsRecBased
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173
	 * Return Type : List of Map<String, String>
	 * @Params : String instId  (Institute Record ID)
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsRecBased(String instId) {

		Map<String, String> returnValue = new Map<String, String> ();
		String tctId = null;
		String tctName = '';
		String tctNameDiff = '';
		String tctTransId = null;
		String tctTrans = '';
		String tctTransName = '';
		String tctTransNameDiff = '';
		String pmlId = null;
		String pmlName = '';
		String pmlNameDiff = '';
		String pmlTransId = null;
		String pmlTrans = '';
		String pmlTransName = '';
		String pmlTransNameDiff = '';

		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		List<Id> assetIds = new List<Id> ();

		List<Asset> assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId FROM Asset WHERE
			Contact_Association_Type_Staging__c =: instId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
		];

		for (Asset assId: assetList) {
			if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
				tctId = assId.Id;
			} else if (assId.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlId = assId.Id;
			}
		}

		for (Asset rec: assetList) {
			assetIds.add(rec.Id);
			assetsMap.put(rec.Id, rec);
			if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
				tctId = rec.Id;
				tctName = rec.Name_on_Document__c;
				tctNameDiff = getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDiff(rec);
				tctTrans = getInstAssetsAndDocumentsRecBasedRefactMethodtctTrans(rec);

			} else if (rec.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlId = rec.Id;
				pmlName = rec.Name_on_Document__c;
				pmlNameDiff = getInstAssetsAndDocumentsRecBasedRefactMethodpmlNameDiff(rec);
				pmlTrans = getInstAssetsAndDocumentsRecBasedRefactMethodpmlTrans(rec);
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == tctId) {
				tctTransId = rec.Id;
				tctTransName = rec.Name_on_Document__c;
				tctTransNameDiff = getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDiff(rec);
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == pmlId) {
				pmlTransId = rec.Id;
				pmlTransName = rec.Name_on_Document__c;
				pmlTransNameDiff = getInstAssetsAndDocumentsRecBasedRefactMethodpmlTransNameDiff(rec);
			}
		}

		if (assetIds.size() > 0) {
			returnValue = getInstAssetsAndDocumentsRecBasedRefactMethod(assetIds, assetsMap, tctId, tctTransId, pmlId, pmlTransId);
		}

		returnValue.put('tctId', tctId);
		returnValue.put('tctName', tctName);
		returnValue.put('tctNameDiff', tctNameDiff);
		returnValue.put('tctTransId', tctTransId);
		returnValue.put('tctTrans', tctTrans);
		returnValue.put('tctTransName', tctTransName);
		returnValue.put('tctTransNameDiff', tctTransNameDiff);
		returnValue.put('pmlId', pmlId);
		returnValue.put('pmlName', pmlName);
		returnValue.put('pmlNameDiff', pmlNameDiff);
		returnValue.put('pmlTransId', pmlTransId);
		returnValue.put('pmlTrans', pmlTrans);
		returnValue.put('pmlTransName', pmlTransName);
		returnValue.put('pmlTransNameDiff', pmlTransNameDiff);

		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDiff
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDiff(Asset rec) {
		String tctNameDiff = '';
		tctNameDiff = 'No';
		if (rec.Name_on_Document_is_Different__c) {
			tctNameDiff = 'Yes';
		}
		return tctNameDiff;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctTrans
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctTrans(Asset rec) {
		String tctTrans = '';
		tctTrans = 'No';
		if (rec.Document_is_not_in_English__c) {
			tctTrans = 'Yes';
		}
		return tctTrans;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodpmlNameDiff
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodpmlNameDiff(Asset rec) {
		String pmlNameDiff = '';
		pmlNameDiff = 'No';
		if (rec.Name_on_Document_is_Different__c) {
			pmlNameDiff = 'Yes';
		}
		return pmlNameDiff;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodpmlTrans
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodpmlTrans(Asset rec) {
		String pmlTrans = '';
		pmlTrans = 'No';
		if (rec.Document_is_not_in_English__c) {
			pmlTrans = 'Yes';
		}
		return pmlTrans;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDiff
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDiff(Asset rec) {
		String tctTransNameDiff = '';
		tctTransNameDiff = 'No';
		if (rec.Name_on_Document_is_Different__c) {
			tctTransNameDiff = 'Yes';
		}
		return tctTransNameDiff;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodpmlTransNameDiff
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodpmlTransNameDiff(Asset rec) {
		String pmlTransNameDiff = '';
		pmlTransNameDiff = 'No';
		if (rec.Name_on_Document_is_Different__c) {
			pmlTransNameDiff = 'Yes';
		}
		return pmlTransNameDiff;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethod
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsRecBasedRefactMethod(List<Id> assetIds, Map<Id, Asset> assetsMap, String tctId, String tctTransId, String pmlId, String pmlTransId) {

		Map<String, String> returnValue = new Map<String, String> ();
		List<ContentDocumentLink> contentDocumentLinksList = new List<ContentDocumentLink> ();
		List<Id> contentDocumentIds = new List<Id> ();
		Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
		Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();
		String tctFile = '';
		String tctNameDoc = '';
		String tctTransFile = '';
		String tctTransNameDoc = '';
		String pmlFile = '';
		String pmlNameDoc = '';
		String pmlTransFile = '';
		String pmlTransNameDoc = '';

		for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {

			contentDocumentLinksList.add(contentDoc);
			contentDocumentIds.add(contentDoc.ContentDocumentId);
			if (!contentMap.containsKey(contentDoc.LinkedEntityId)) {
				contentMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> ());
			}
			contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
		}
		if (contentDocumentIds.size() > 0) {
			for (ContentVersion contentVer: [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds]) {
				contentVersionMap.put(contentVer.ContentDocumentId, contentVer);
			}
		}

		for (Id assetId: assetsMap.keyset()) {
			Id fileId;
			fileId = getAssetsAndDocumentsRefactMethodFileId(assetId, contentMap, contentVersionMap);

			Asset assetRecord = assetsMap.get(assetId);

			tctFile = getInstAssetsAndDocumentsRecBasedRefactMethodtctFile(tctFile, assetRecord, fileId);

			tctNameDoc = getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDoc(tctNameDoc, assetRecord, fileId, tctId);

			tctTransFile = getInstAssetsAndDocumentsRecBasedRefactMethodtctTransFile(tctTransFile, assetRecord, fileId, tctId);

			tctTransNameDoc = getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDoc(tctTransNameDoc, assetRecord, fileId, tctTransId);

			if (assetRecord.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlFile = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlId) {
				pmlNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == pmlId) {
				pmlTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlTransId) {
				pmlTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
			}
		}

		returnValue.put('tctFile', tctFile);
		returnValue.put('tctNameDoc', tctNameDoc);
		returnValue.put('tctTransFile', tctTransFile);
		returnValue.put('tctTransNameDoc', tctTransNameDoc);
		returnValue.put('pmlFile', pmlFile);
		returnValue.put('pmlNameDoc', pmlNameDoc);
		returnValue.put('pmlTransFile', pmlTransFile);
		returnValue.put('pmlTransNameDoc', pmlTransNameDoc);

		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctFile
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : string
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctFile(string tctFile, Asset assetRecord, Id fileId) {

		if (assetRecord.Type__c == Constants.ASSET_TYPE_TCT) {
			tctFile = Constants.FILE_DOWNLOAD_URL + fileId;
		}
		return tctFile;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDoc
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : string
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctNameDoc(string tctNameDoc, Asset assetRecord, Id fileId, String tctId) {

		if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId) {
			tctNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
		}
		return tctNameDoc;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctTransFile
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : string
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctTransFile(string tctTransFile, Asset assetRecord, Id fileId, String tctId) {

		if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId) {
			tctTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
		}
		return tctTransFile;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDoc
	 * Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert  - US 2173.Continuation of above method getInstAssetsAndDocumentsRecBased.
	 * Return Type : string
	 */
	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecBasedRefactMethodtctTransNameDoc(string tctTransNameDoc, Asset assetRecord, Id fileId, String tctTransId) {

		if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctTransId) {
			tctTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
		}
		return tctTransNameDoc;
	}

	// List of the contact association type staging records based on AppForCert Case Id
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c> getOtherInstitutionsWithTransferCredits(Boolean showExamRegActionButton, Boolean showCaseDetail, String caseRecordId){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION;
		}
		List<Contact_Association_Type_Staging__c> institutionsList = new List<Contact_Association_Type_Staging__c>([SELECT Id, Account__c, Account_Name__c, Account__r.University_Name__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry, Account__r.BillingPostalCode, Account__r.RecordType.DeveloperName, School_Program__c, Start_Date__c, Start_Month__c, Start_Year__c, End_Date__c, End_Month__c, End_Year__c, Student_ID__c, Specialty__c, Number_of_Years_Attended__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, From_School_Name__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c FROM Assets__r WHERE Asset.status != :constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type_Staging__c
            WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName AND Parent_Case__c =: caseRecordId
            ORDER BY createdDate ASC
        ]);
		return institutionsList;
	}

	// Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getInstAssetsAndDocuments(Boolean showExamRegActionButton, Boolean showCaseDetail) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = getCaseIdAllStatus(showCaseDetail, contactId);
		String recordTypeDeveloperName;
		recordTypeDeveloperName = getInstAssetsAndDocumentsRecordTypeDeveloperName(showExamRegActionButton);
		Map<String,
			Map<String, String>> returnValue = new Map<String,
			Map<String, String>> ();
		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		List<Id> assetIds = new List<Id> ();
		Map<String, Map<String, String>> retVal = new Map<String, Map<String, String>> ();
		List<Id> instIds = new List<Id> ();
		List<Contact_Association_Type_Staging__c > institutionsList = [SELECT Id, Account__c, Account_Name__c FROM Contact_Association_Type_Staging__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName
			AND Parent_Case__c =: caseId
			ORDER BY createdDate ASC
		];
		for (Contact_Association_Type_Staging__c institution: institutionsList) {
			instIds.add(institution.Id);
		}
		List<Asset> assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId FROM Asset WHERE
			Contact_Association_Type_Staging__c IN: instIds AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
		];
		Map<String, String> tctInstMap = new Map<String, String> ();
		Map<String, String> tctInstMapDummy = new Map<String, String> ();
		Map<String, String> pmlInstMap = new Map<String, String> ();
		Map<String, String> pmlInstMapDummy = new Map<String, String> ();
		for (Asset assId: assetList) {
			assetIds.add(assId.Id);
			assetsMap.put(assId.Id, assId);
			tctInstMapDummy = getInstAssetsAndDocumentsTctInstMap(assId);
			tctInstMap.putAll(tctInstMapDummy);
			pmlInstMapDummy = getInstAssetsAndDocumentsPmlInstMap(assId);
			pmlInstMap.putAll(pmlInstMapDummy);
		}
		Map<String, String> tctNameInstMap = new Map<String, String> ();
		Map<String, String> tctNameDiffInstMap = new Map<String, String> ();
		Map<String, String> tctNameDiffInstMapDummy = new Map<String, String> ();
		Map<String, String> tctTransInstMap = new Map<String, String> ();
		Map<String, String> tctTransInstMapDummy = new Map<String, String> ();
		Map<String, String> tctTransIdInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocIdInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDiffInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDiffInstMapDummy = new Map<String, String> ();
		Map<String, String> pmlNameInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDiffInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDiffInstMapDummy = new Map<String, String> ();
		Map<String, String> pmlTransInstMap = new Map<String, String> ();
		Map<String, String> pmlTransInstMapDummy = new Map<String, String> ();
		Map<String, String> pmlTransIdInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocIdInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDiffInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDiffInstMapDummy = new Map<String, String> ();
		for (Asset rec: assetList) {
			String assInstId = tctInstMap.get(rec.Contact_Association_Type_Staging__c);
			String assPmlInstId = pmlInstMap.get(rec.Contact_Association_Type_Staging__c);
			if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
				tctNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				tctNameDiffInstMapDummy = getInstAssetsAndDocumentsTctNameDiffInstMap(rec);
				tctNameDiffInstMap.putAll(tctNameDiffInstMapDummy);
				tctTransInstMapDummy = getInstAssetsAndDocumentsTctTransInstMap(rec);
				tctTransInstMap.putAll(tctTransInstMapDummy);
			} else if (rec.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				pmlNameDiffInstMapDummy = getInstAssetsAndDocumentsPmlNameDiffInstMap(rec);
				pmlNameDiffInstMap.putAll(pmlNameDiffInstMapDummy);
				pmlTransInstMapDummy = getInstAssetsAndDocumentsPmlTransInstMap(rec);
				pmlTransInstMap.putAll(pmlTransInstMapDummy);
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assInstId) {
				tctTransIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
				tctTransNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				tctTransNameDiffInstMapDummy = getInstAssetsAndDocumentsTctTransNameDiffInstMap(rec);
				tctTransNameDiffInstMap.putAll(tctTransNameDiffInstMapDummy);
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assPmlInstId) {
				pmlTransIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
				pmlTransNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				pmlTransNameDiffInstMapDummy = getInstAssetsAndDocumentsPmlTransNameDiffInstMap(rec);
				pmlTransNameDiffInstMap.putAll(pmlTransNameDiffInstMapDummy);
			}
			else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == assInstId) {
				tctNameDocIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
			} else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == assPmlInstId) {
				pmlNameDocIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
			}
		}
		if (assetIds.size() > 0) {
			retVal = getInstAssetsAndDocumentsReturnValue(assetIds, assetsMap, tctInstMap, tctTransIdInstMap, pmlInstMap, pmlTransIdInstMap, instIds);
		}
		For(Id instId: instIds) {
			Map<String,
				String > instRetVal = new Map<String,
				String > ();
			instRetVal.put('tctId', tctInstMap.get(instId));
			instRetVal.put('tctName', tctNameInstMap.get(instId));
			instRetVal.put('tctNameDiff', tctNameDiffInstMap.get(instId));
			instRetVal.put('tctTransId', tctTransIdInstMap.get(instId));
			instRetVal.put('tctNameDocId', tctNameDocIdInstMap.get(instId));
			instRetVal.put('tctTrans', tctTransInstMap.get(instId));
			instRetVal.put('tctTransName', tctTransNameInstMap.get(instId));
			instRetVal.put('tctTransNameDiff', tctTransNameDiffInstMap.get(instId));
			instRetVal.put('pmlId', pmlInstMap.get(instId));
			instRetVal.put('pmlName', pmlNameInstMap.get(instId));
			instRetVal.put('pmlNameDiff', pmlNameDiffInstMap.get(instId));
			instRetVal.put('pmlTransId', pmlTransIdInstMap.get(instId));
			instRetVal.put('pmlNameDocId', pmlNameDocIdInstMap.get(instId));
			instRetVal.put('pmlTrans', pmlTransInstMap.get(instId));
			instRetVal.put('pmlTransName', pmlTransNameInstMap.get(instId));
			instRetVal.put('pmlTransNameDiff', pmlTransNameDiffInstMap.get(instId));
			if (retVal.containsKey(instId)) {
				instRetVal.put('tctFile', retVal.get(instId).get('tctFile'));
				instRetVal.put('tctNameDoc', retVal.get(instId).get('tctNameDoc'));
				instRetVal.put('tctTransFile', retVal.get(instId).get('tctTransFile'));
				instRetVal.put('tctTransNameDoc', retVal.get(instId).get('tctTransNameDoc'));
				instRetVal.put('pmlFile', retVal.get(instId).get('pmlFile'));
				instRetVal.put('pmlNameDoc', retVal.get(instId).get('pmlNameDoc'));
				instRetVal.put('pmlTransFile', retVal.get(instId).get('pmlTransFile'));
				instRetVal.put('pmlTransNameDoc', retVal.get(instId).get('pmlTransNameDoc'));
			}
			returnValue.put(instId, instRetVal);
		}
		return returnValue;
	}

	/**
	 * Method Name: getInstAssetsAndDocumentsTctInstMap
	 * Purpose : Continuation of main Method getInstAssetsAndDocuments to return the tctInstMap
	 * Return Type : String
	 */

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsTctInstMap(Asset assId) {
		Map<String, String> tctInstMap = new Map<String, String> ();

		if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
			tctInstMap.put(assId.Contact_Association_Type_Staging__c, assId.Id);
		}
		return tctInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlInstMap(Asset assId) {
		Map<String, String> pmlInstMap = new Map<String, String> ();

		if (assId.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
			pmlInstMap.put(assId.Contact_Association_Type_Staging__c, assId.Id);
		}
		return pmlInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getInstAssetsAndDocumentsReturnValue(List<Id> assetIds, Map<Id, Asset> assetsMap, Map<String, String> tctInstMap, Map<String, String> tctTransIdInstMap, Map<String, String> pmlInstMap, Map<String, String> pmlTransIdInstMap, List<Id> instIds) {

		List<ContentDocumentLink> contentDocumentLinksList = new List<ContentDocumentLink> ();
		Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
		List<Id> contentDocumentIds = new List<Id> ();
		Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();

		Map<String, String> tctFileInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlFileInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocInstMap = new Map<String, String> ();

		Map<String, Map<String, String>> returnValue = new Map<String, Map<String, String>> ();

		for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {

			contentDocumentLinksList.add(contentDoc);
			contentDocumentIds.add(contentDoc.ContentDocumentId);
			if (!contentMap.containsKey(contentDoc.LinkedEntityId)) {
				contentMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> ());
			}
			contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
		}
		if (contentDocumentIds.size() > 0) {
			for (ContentVersion contentVer: [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds]) {
				contentVersionMap.put(contentVer.ContentDocumentId, contentVer);
			}
		}

		for (Id assetId: assetsMap.keyset()) {
			Id fileId;
			fileId = getAssetsAndDocumentsRefactMethodFileId(assetId, contentMap, contentVersionMap);

			Asset assetRecord = assetsMap.get(assetId);
			String tctId = tctInstMap.get(assetRecord.Contact_Association_Type_Staging__c);
			String pmlId = pmlInstMap.get(assetRecord.Contact_Association_Type_Staging__c);

			tctFileInstMap = fileInstanceMapCreator(1, tctFileInstMap, fileId, assetRecord, tctId, pmlId);
			tctNameDocInstMap = fileInstanceMapCreator(2, tctNameDocInstMap, fileId, assetRecord, tctId, pmlId);
			tctTransFileInstMap = fileInstanceMapCreator(3, tctTransFileInstMap, fileId, assetRecord, tctId, pmlId);
			pmlFileInstMap = fileInstanceMapCreator(4, pmlFileInstMap, fileId, assetRecord, tctId, pmlId);
			pmlNameDocInstMap = fileInstanceMapCreator(5, pmlNameDocInstMap, fileId, assetRecord, tctId, pmlId);
			pmlTransFileInstMap = fileInstanceMapCreator(6, pmlTransFileInstMap, fileId, assetRecord, tctId, pmlId);
		}

		For(Id instId: instIds) {
			Map<String,
				String > instRetVal = new Map<String,
				String > ();

			instRetVal.put('tctFile', tctFileInstMap.get(instId));
			instRetVal.put('tctNameDoc', tctNameDocInstMap.get(instId));
			instRetVal.put('tctTransFile', tctTransFileInstMap.get(instId));
			instRetVal.put('tctTransNameDoc', tctTransNameDocInstMap.get(instId));
			instRetVal.put('pmlFile', pmlFileInstMap.get(instId));
			instRetVal.put('pmlNameDoc', pmlNameDocInstMap.get(instId));
			instRetVal.put('pmlTransFile', pmlTransFileInstMap.get(instId));
			instRetVal.put('pmlTransNameDoc', pmlTransNameDocInstMap.get(instId));

			returnValue.put(instId, instRetVal);
		}
		return returnValue;
	}

	/**
	 * @author: Chinmay Menon
	 * @methodname: fileInstanceMapCreator
	 * @description: Method created to reduce cognitive complexity. Main purpose is to populate the different file instance
	 *               maps based on the conditions
	 * @Parameters: The file instance map, file id, Asset record, transfer credit transcript id and premed letter id
	 * @return type: Map<String, String>
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> fileInstanceMapCreator(Integer scenario, Map<String, String> fileInstanceMap, Id fileId, Asset assetRecord, String tctId, String pmlId) {
		if (assetRecord.Type__c == Constants.ASSET_TYPE_TCT && scenario == 1) {
			fileInstanceMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId && scenario == 2) {
			fileInstanceMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId && scenario == 3) {
			fileInstanceMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		} else if (assetRecord.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER && scenario == 4) {
			fileInstanceMap = getInstAssetsAndDocumentsPmlFileInstMap(assetRecord, fileId);
		} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlId && scenario == 5) {
			fileInstanceMap = getInstAssetsAndDocumentsPmlNameDocInstMap(assetRecord, fileId, pmlId);
		} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == pmlId && scenario == 6) {
			fileInstanceMap = getInstAssetsAndDocumentsPmlTransFileInstMap(assetRecord, fileId, pmlId);
		}

		return fileInstanceMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlFileInstMap(Asset assetRecord, Id fileId) {
		Map<String, String> pmlFileInstMap = new Map<String, String> ();

		if (assetRecord.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
			pmlFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		}
		return pmlFileInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlNameDocInstMap(Asset assetRecord, Id fileId, String pmlId) {

		Map<String, String> pmlNameDocInstMap = new Map<String, String> ();
		if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlId) {
			pmlNameDocInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		}
		return pmlNameDocInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentspmlTransFileInstMap(Asset assetRecord, Id fileId, String pmlId) {

		Map<String, String> pmlTransFileInstMap = new Map<String, String> ();

		if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == pmlId) {
			pmlTransFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
		}

		return pmlTransFileInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static String getInstAssetsAndDocumentsRecordTypeDeveloperName(Boolean showExamRegActionButton) {
		String recordTypeDeveloperName;
		if (showExamRegActionButton == true) {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG;
		} else {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION;
		}
		return recordTypeDeveloperName;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsTctNameDiffInstMap(Asset rec) {
		Map<String, String> tctNameDiffInstMap = new Map<String, String> ();
		tctNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Name_on_Document_is_Different__c) {
			tctNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return tctNameDiffInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsTctTransInstMap(Asset rec) {
		Map<String, String> tctTransInstMap = new Map<String, String> ();
		tctTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Document_is_not_in_English__c) {
			tctTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return tctTransInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlNameDiffInstMap(Asset rec) {
		Map<String, String> pmlNameDiffInstMap = new Map<String, String> ();
		pmlNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Name_on_Document_is_Different__c) {
			pmlNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return pmlNameDiffInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlTransInstMap(Asset rec) {
		Map<String, String> pmlTransInstMap = new Map<String, String> ();
		pmlTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Document_is_not_in_English__c) {
			pmlTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return pmlTransInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsTctTransNameDiffInstMap(Asset rec) {
		Map<String, String> tctTransNameDiffInstMap = new Map<String, String> ();
		tctTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Name_on_Document_is_Different__c) {
			tctTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return tctTransNameDiffInstMap;
	}

	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getInstAssetsAndDocumentsPmlTransNameDiffInstMap(Asset rec) {
		Map<String, String> pmlTransNameDiffInstMap = new Map<String, String> ();
		pmlTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
		if (rec.Name_on_Document_is_Different__c) {
			pmlTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
		}
		return pmlTransNameDiffInstMap;
	}

	// Purpose : Method to return the files/Documents uploaded by applicant for the app For Cert
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGraduateOnlyRecords(Boolean showExamRegActionButton, Boolean showCaseDetail, Boolean resubmitAppForCert) {
		Map<String, String> returnValue = new Map<String, String> ();
		String fmdId = null,
			fmdFile = '',
			fmdName = '',
			fmdNameDiff = '',
			fmdNameDoc = '',
			fmdTransId = null,
			fmdNameDocId = null,
			fmdTrans = '',
			fmdTransFile = '';
		String dlId = null,
			dlFile = '',
			dlName = '',
			dlNameDiff = '',
			dlNameDoc = '',
			dlTransId = null,
			dlNameDocId = null,
			dlTrans = '',
			dlTransFile = '',
			dlDate = '';
		String ftId = null,
			ftFile = '',
			ftName = '',
			ftNameDiff = '',
			ftNameDoc = '',
			ftTransId = null,
			ftNameDocId = null,
			ftTrans = '',
			ftTransFile = '';
		String isDeanLetter = 'No',
			isFTReqd = 'No';
			//User story#15591 - Courier_service_for_an_additional_fee__c
		String isCourierService = 'No';
		String isCourierServiceFMST = 'No';
		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		List<Id> assetIds = new List<Id> ();
		String recordTypeDeveloperName;
		if (showExamRegActionButton == true) {
			if (resubmitAppForCert) {
				recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
			} else {
				recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG;
			}
		} else {
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL;
		}
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = getCaseIdAllStatus(showCaseDetail, contactId);
		//User story#15591 - new field Courier_service_for_an_additional_fee__c added to query
		List<Contact_Association_Type_Staging__c> degMeDSchoolRec = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c, Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName
			AND Parent_Case__c =: caseId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC
		];
		if(!degMeDSchoolRec.isEmpty()){
			Id degMedSchoolId = degMeDSchoolRec[0].Id;
			Boolean deanLetter = degMeDSchoolRec[0].IsDeanLetter__c;
			Boolean finalTranscriptReqd = degMeDSchoolRec[0].Account__r.Is_Final_Transcript_Required__c;
			//User story#15591- getting Courier_service_for_an_additional_fee__c
			Boolean courierService = degMeDSchoolRec[0].Courier_service_for_an_additional_fee__c;
			if(courierService){
				isCourierService = 'Yes';
			}
			List<Asset> assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c =: degMedSchoolId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC
			];
			// Getting FMST from CATS-Credential Intake
			List<Asset> intakeAssetList = new List<Asset>();
			if(finalTranscriptReqd){
				String intakeRecordTypeDevName = Constants.CONASCTYPESTG_RECORD_TYPE_CREDENTIAL_INTAKE;
				List<Contact_Association_Type_Staging__c> credIntakeCATSRec = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c, Courier_service_for_an_additional_fee__c FROM Contact_Association_Type_Staging__c
																					WHERE Contact__c =: contactId AND recordType.DeveloperName =: intakeRecordTypeDevName
																					AND Parent_Case__c =: caseId WITH SECURITY_ENFORCED];
				if(!credIntakeCATSRec.isEmpty()){
					Id credIntakeCATSRecId = credIntakeCATSRec[0].Id;
					Boolean courierServiceFMST = credIntakeCATSRec[0].Courier_service_for_an_additional_fee__c;
					if(courierServiceFMST){
						isCourierServiceFMST = 'Yes';
					}
					intakeAssetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
													Contact_Association_Type_Staging__c =: credIntakeCATSRecId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
				}
			}
			assetList.addAll(intakeAssetList);
			// This method is created for avoiding SonarCloud issue
			Map<String, String> assetIdsMap = new Map<String, String> ();
			assetIdsMap = getGradAssetIds(deanLetter, finalTranscriptReqd, assetList);
			dlId = assetIdsMap.get('dlId');
			fmdId = assetIdsMap.get('fmdId');
			ftId = assetIdsMap.get('ftId');
			// This method is created for avoiding SonarCloud issue...Refactoring Methods
			// ASSET_TYPE_DEAN_LETTER
			if (deanLetter) {
				isDeanLetter = 'Yes';
				Map<String, String> assetDeanLetterMap = new Map<String, String> ();
				assetDeanLetterMap = getGradDeanLetter(assetList, dlId);
				dlName = assetDeanLetterMap.get('dlName');
				dlNameDiff = assetDeanLetterMap.get('dlNameDiff');
				dlTrans = assetDeanLetterMap.get('dlTrans');
				dlTransId = assetDeanLetterMap.get('dlTransId');
				dlDate = assetDeanLetterMap.get('dlDate');
				dlNameDocId = assetDeanLetterMap.get('dlNameDocId');
			} else {
				// ASSET_TYPE_FINAL_MED_DIPLOMA
				Map<String, String> asseMedDiplomaMap = new Map<String, String> ();
				asseMedDiplomaMap = getGradMedDiploma(assetList, fmdId);
				fmdName = asseMedDiplomaMap.get('fmdName');
				fmdNameDiff = asseMedDiplomaMap.get('fmdNameDiff');
				fmdTrans = asseMedDiplomaMap.get('fmdTrans');
				fmdTransId = asseMedDiplomaMap.get('fmdTransId');
				fmdNameDocId = asseMedDiplomaMap.get('fmdNameDocId');
			}
			// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
			if (finalTranscriptReqd) {
				isFTReqd = 'Yes';
				Map<String, String> assetTransscriptMap = new Map<String, String> ();
				assetTransscriptMap = getGradTranscript(intakeAssetList, ftId);
				ftName = assetTransscriptMap.get('ftName');
				ftNameDiff = assetTransscriptMap.get('ftNameDiff');
				ftTrans = assetTransscriptMap.get('ftTrans');
				ftTransId = assetTransscriptMap.get('ftTransId');
				ftNameDocId = assetTransscriptMap.get('ftNameDocId');
			}
			// Creating Map for Asset Trans Id
			Map<String, String> assetTransIdMap = new Map<String, String> ();
			assetTransIdMap.put('dlTransId', dlTransId);
			assetTransIdMap.put('fmdTransId', fmdTransId);
			assetTransIdMap.put('ftTransId', ftTransId);
			for (Asset rec: assetList) {
				assetIds.add(rec.Id);
				assetsMap.put(rec.Id, rec);
			}
			if (assetIds.size() > 0) {
				// This method is created for avoiding SonarCloud issue
				Map<String, String> assetFilesMap = new Map<String, String> ();
				assetFilesMap = getGraduateOnlyRecordsRefactorDocument(assetIdsMap, assetTransIdMap, deanLetter, finalTranscriptReqd, assetIds, assetsMap);
				// ASSET_TYPE_DEAN_LETTER
				dlFile = assetFilesMap.get('dlFile');
				dlNameDoc = assetFilesMap.get('dlNameDoc');
				dlTransFile = assetFilesMap.get('dlTransFile');
				// ASSET_TYPE_FINAL_MED_DIPLOMA
				fmdFile = assetFilesMap.get('fmdFile');
				fmdNameDoc = assetFilesMap.get('fmdNameDoc');
				fmdTransFile = assetFilesMap.get('fmdTransFile');
				// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
				ftFile = assetFilesMap.get('ftFile');
				ftNameDoc = assetFilesMap.get('ftNameDoc');
				ftTransFile = assetFilesMap.get('ftTransFile');
			}
		}
		returnValue.put('fmdId', fmdId);
		returnValue.put('fmdFile', fmdFile);
		returnValue.put('fmdName', fmdName);
		returnValue.put('fmdNameDiff', fmdNameDiff);
		returnValue.put('fmdNameDoc', fmdNameDoc);
		returnValue.put('fmdTransId', fmdTransId);
		returnValue.put('fmdNameDocId', fmdNameDocId);
		returnValue.put('fmdTrans', fmdTrans);
		returnValue.put('fmdTransFile', fmdTransFile);
		returnValue.put('dlId', dlId);
		returnValue.put('dlFile', dlFile);
		returnValue.put('dlName', dlName);
		returnValue.put('dlNameDiff', dlNameDiff);
		returnValue.put('dlNameDoc', dlNameDoc);
		returnValue.put('dlTransId', dlTransId);
		returnValue.put('dlNameDocId', dlNameDocId);
		returnValue.put('dlTrans', dlTrans);
		returnValue.put('dlTransFile', dlTransFile);
		returnValue.put('dlDate', dlDate);
		returnValue.put('ftId', ftId);
		returnValue.put('ftFile', ftFile);
		returnValue.put('ftName', ftName);
		returnValue.put('ftNameDiff', ftNameDiff);
		returnValue.put('ftNameDoc', ftNameDoc);
		returnValue.put('ftTransId', ftTransId);
		returnValue.put('ftNameDocId', ftNameDocId);
		returnValue.put('ftTrans', ftTrans);
		returnValue.put('ftTransFile', ftTransFile);
		returnValue.put('isDeanLetter', isDeanLetter);
		returnValue.put('isFTReqd', isFTReqd);
		returnValue.put('isCourierService', isCourierService);
		returnValue.put('isCourierServiceFMST', isCourierServiceFMST);
		return returnValue;
	}

	//Purpose : Method to avoid SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGradAssetIds(Boolean deanLetter, Boolean finalTranscriptReqd, List<Asset> assetList){
		String fmdId = null;
		String dlId = null;
		String ftId = null;
		Map<String, String> assetIdsMap = new Map<String, String> ();
		for (Asset assId: assetList){
			if(deanLetter){
				if(assId.Type__c == Constants.ASSET_NAME_DEAN_LETTER){
					dlId = assId.Id;
				}
			} else{
				if(assId.Type__c == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA){
					fmdId = assId.Id;
				}
			}
			if(finalTranscriptReqd && assId.Type__c == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT){
				ftId = assId.Id;
			}
		}
		assetIdsMap.put('fmdId', fmdId);
		assetIdsMap.put('dlId', dlId);
		assetIdsMap.put('ftId', ftId);
		return assetIdsMap;
	}

	//Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGradDeanLetter(List<Asset> assetList, String dlId) {
		// ASSET_TYPE_DEAN_LETTER        
		String dlName = '';
		String dlNameDiff = '';
		String dlTrans = '';
		String dlTransId = null;
		String dlNameDocId = null;
		String dlDate = '';
		String dlTransName = '';
		String dlTransNameDiff = '';
		Map<String, String> assetRecordMap = new Map<String, String>();
		for(Asset rec: assetList) {
			if(rec.Type__c == Constants.ASSET_NAME_DEAN_LETTER){
				dlId = rec.Id;
				dlName = rec.Name_on_Document__c;
				dlNameDiff = getNameOnDocDiff(rec);
				dlTrans = 'No';
				if(rec.Document_is_not_in_English__c){
					dlTrans = 'Yes';
				}
				Date dlDateVal = rec.Dean_s_Letter_Date__c;
				dlDate = String.valueOf(dlDateVal);
			} else if(rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == dlId){
				dlTransId = rec.Id;
				dlTransName = rec.Name_on_Document__c;
				dlTransNameDiff = getNameOnDocDiff(rec);
			} else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == dlId) {
				dlNameDocId = rec.Id;
			}
		}
		// ASSET_TYPE_DEAN_LETTER
		assetRecordMap.put('dlId', dlId);
		assetRecordMap.put('dlName', dlName);
		assetRecordMap.put('dlNameDiff', dlNameDiff);
		assetRecordMap.put('dlTrans', dlTrans);
		assetRecordMap.put('dlTransId', dlTransId);
		assetRecordMap.put('dlNameDocId', dlNameDocId);
		assetRecordMap.put('dlDate', dlDate);
		assetRecordMap.put('dlTransName', dlTransName);
		assetRecordMap.put('dlTransNameDiff', dlTransNameDiff);
		return assetRecordMap;
	}
	
	public static string getNameOnDocDiff(Asset rec){
		string nameOnDoc = 'No';
		if (rec.Name_on_Document_is_Different__c){
			nameOnDoc = 'Yes';
		}
		return nameOnDoc;
	}
	// Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGradMedDiploma(List<Asset> assetList, String fmdId) {
		// ASSET_TYPE_FINAL_MED_DIPLOMA
		String fmdName = '';
		String fmdNameDiff = '';
		String fmdTrans = '';
		String fmdTransId = null;
		String fmdNameDocId = null;
		String fmdTransName = '';
		String fmdTransNameDiff = '';

		Map<String, String> assetRecordMap = new Map<String, String> ();
		for (Asset rec: assetList) {
			if (rec.Type__c == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA) {
				fmdId = rec.Id;
				fmdName = rec.Name_on_Document__c;
				fmdNameDiff = getNameOnDocDiff(rec);
				fmdTrans = 'No';
				if (rec.Document_is_not_in_English__c) {
					fmdTrans = 'Yes';
				}
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == fmdId) {
				fmdTransId = rec.Id;
				fmdTransName = rec.Name_on_Document__c;
				fmdTransNameDiff = getNameOnDocDiff(rec);
			} else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == fmdId) {
				fmdNameDocId = rec.Id;
			}
		}

		// ASSET_TYPE_FINAL_MED_DIPLOMA
		assetRecordMap.put('fmdId', fmdId);
		assetRecordMap.put('fmdName', fmdName);
		assetRecordMap.put('fmdNameDiff', fmdNameDiff);
		assetRecordMap.put('fmdTrans', fmdTrans);
		assetRecordMap.put('fmdTransId', fmdTransId);
		assetRecordMap.put('fmdNameDocId', fmdNameDocId);
		assetRecordMap.put('fmdTransName', fmdTransName);
		assetRecordMap.put('fmdTransNameDiff', fmdTransNameDiff);

		return assetRecordMap;
	}
	// Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGradTranscript(List<Asset> assetList, String ftId) {
		// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
		String ftName = '';
		String ftNameDiff = '';
		String ftTrans = '';
		String ftTransId = null;
		String ftNameDocId = null;
		String ftTransName = '';
		String ftTransNameDiff = '';

		Map<String, String> assetTransscriptMap = new Map<String, String> ();
		for (Asset rec: assetList) {
			if (rec.Type__c == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) {
				ftId = rec.Id;
				ftName = rec.Name_on_Document__c;
				ftNameDiff = getNameOnDocDiff(rec);
				ftTrans = 'No';
				if (rec.Document_is_not_in_English__c) {
					ftTrans = 'Yes';
				}
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == ftId) {
				ftTransId = rec.Id;
				ftTransName = rec.Name_on_Document__c;
				ftTransNameDiff = getNameOnDocDiff(rec);
			} else if (rec.Type__c == Constants.ASSET_TYPE_NAME_DOC && rec.ParentId == ftId) {
				ftNameDocId = rec.Id;
			}
		}

		// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
		assetTransscriptMap.put('ftId', ftId);
		assetTransscriptMap.put('ftName', ftName);
		assetTransscriptMap.put('ftNameDiff', ftNameDiff);
		assetTransscriptMap.put('ftTrans', ftTrans);
		assetTransscriptMap.put('ftTransId', ftTransId);
		assetTransscriptMap.put('ftNameDocId', ftNameDocId);
		assetTransscriptMap.put('ftTransName', ftTransName);
		assetTransscriptMap.put('ftTransNameDiff', ftTransNameDiff);

		return assetTransscriptMap;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getGraduateOnlyRecordsRefactorDocument
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIdsMap, deanLetter, finalTranscriptReqd, assetIds and assetsMap
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGraduateOnlyRecordsRefactorDocument(Map<String, String> assetIdsMap, Map<String, String> assetTransIdMap, Boolean deanLetter, Boolean finalTranscriptReqd, List<Id> assetIds, Map<Id, Asset> assetsMap) {
		Map<Id, List<ContentDocumentLink>> contentMap = getRefactorContentMap(assetIds);
		List<Id> contentDocumentIds = getRefactorContentDocumentIds(assetIds);
		Map<Id, ContentVersion> contentVersionMap = getRefactorContentVersionMap(contentDocumentIds);

		Map<String, String> assetFilesMap = new Map<String, String> ();

		if (deanLetter) {
			Map<String, String> assetDocDeanMap = new Map<String, String> ();
			assetDocDeanMap = getGradDeanDocs(assetIdsMap, assetTransIdMap, assetsMap, contentMap, contentVersionMap);
			// ASSET_TYPE_DEAN_LETTER
			assetFilesMap.put('dlFile', assetDocDeanMap.get('dlFile'));
			assetFilesMap.put('dlFileName', assetDocDeanMap.get('dlFileName'));
			assetFilesMap.put('dlFileType', assetDocDeanMap.get('dlFileType'));
			assetFilesMap.put('dlNameDoc', assetDocDeanMap.get('dlNameDoc'));
			assetFilesMap.put('dlNameDocName', assetDocDeanMap.get('dlNameDocName'));
			assetFilesMap.put('dlNameDocType', assetDocDeanMap.get('dlNameDocType'));
			assetFilesMap.put('dlTransFile', assetDocDeanMap.get('dlTransFile'));
			assetFilesMap.put('dlTransFileName', assetDocDeanMap.get('dlTransFileName'));
			assetFilesMap.put('dlTransFileType', assetDocDeanMap.get('dlTransFileType'));
			assetFilesMap.put('dlTransNameDoc', assetDocDeanMap.get('dlTransNameDoc'));
			assetFilesMap.put('dlTransNameDocName', assetDocDeanMap.get('dlTransNameDocName'));
			assetFilesMap.put('dlTransNameDocType', assetDocDeanMap.get('dlTransNameDocType'));
		} else {
			Map<String, String> assetDocDiplomaMap = new Map<String, String> ();
			assetDocDiplomaMap = getGraduateOnlyRecordsRefactorDocDiploma(assetIdsMap, assetTransIdMap, assetsMap, contentMap, contentVersionMap);
			// ASSET_TYPE_FINAL_MED_DIPLOMA
			assetFilesMap.put('fmdFile', assetDocDiplomaMap.get('fmdFile'));
			assetFilesMap.put('fmdFileName', assetDocDiplomaMap.get('fmdFileName'));
			assetFilesMap.put('fmdFileType', assetDocDiplomaMap.get('fmdFileType'));
			assetFilesMap.put('fmdNameDoc', assetDocDiplomaMap.get('fmdNameDoc'));
			assetFilesMap.put('fmdNameDocName', assetDocDiplomaMap.get('fmdNameDocName'));
			assetFilesMap.put('fmdNameDocType', assetDocDiplomaMap.get('fmdNameDocType'));
			assetFilesMap.put('fmdTransFile', assetDocDiplomaMap.get('fmdTransFile'));
			assetFilesMap.put('fmdTransFileName', assetDocDiplomaMap.get('fmdTransFileName'));
			assetFilesMap.put('fmdTransFileType', assetDocDiplomaMap.get('fmdTransFileType'));
			assetFilesMap.put('fmdTransNameDoc', assetDocDiplomaMap.get('fmdTransNameDoc'));
			assetFilesMap.put('fmdTransNameDocName', assetDocDiplomaMap.get('fmdTransNameDocName'));
			assetFilesMap.put('fmdTransNameDocType', assetDocDiplomaMap.get('fmdTransNameDocType'));
		}

		if (finalTranscriptReqd) {
			Map<String, String> assetTranscriptMap = new Map<String, String> ();
			assetTranscriptMap = getGraduateOnlyRecordsRefactorDocTranscript(assetIdsMap, assetTransIdMap, assetsMap, contentMap, contentVersionMap);
			// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
			assetFilesMap.put('ftFile', assetTranscriptMap.get('ftFile'));
			assetFilesMap.put('ftFileName', assetTranscriptMap.get('ftFileName'));
			assetFilesMap.put('ftFileType', assetTranscriptMap.get('ftFileType'));
			assetFilesMap.put('ftNameDoc', assetTranscriptMap.get('ftNameDoc'));
			assetFilesMap.put('ftNameDocName', assetTranscriptMap.get('ftNameDocName'));
			assetFilesMap.put('ftNameDocType', assetTranscriptMap.get('ftNameDocType'));
			assetFilesMap.put('ftTransFile', assetTranscriptMap.get('ftTransFile'));
			assetFilesMap.put('ftTransFileName', assetTranscriptMap.get('ftTransFileName'));
			assetFilesMap.put('ftTransFileType', assetTranscriptMap.get('ftTransFileType'));
			assetFilesMap.put('ftTransNameDoc', assetTranscriptMap.get('ftTransNameDoc'));
			assetFilesMap.put('ftTransNameDocName', assetTranscriptMap.get('ftTransNameDocName'));
			assetFilesMap.put('ftTransNameDocType', assetTranscriptMap.get('ftTransNameDocType'));
		}

		return assetFilesMap;
	}

	//Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGradDeanDocs(Map<String, String> assetIdsMap, Map<String, String> assetTransIdMap, Map<Id, Asset> assetsMap, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {
		// ASSET_TYPE_DEAN_LETTER
		String dlFile = '';
		String dlFileName = '';
		String dlFileType = '';
		String dlNameDoc = '';
		String dlNameDocName = '';
		String dlNameDocType = '';
		String dlTransFile = '';
		String dlTransFileName = '';
		String dlTransFileType = '';
		String dlTransNameDoc = '';
		String dlTransNameDocName = '';
		String dlTransNameDocType = '';
		String dlId = assetIdsMap.get('dlId');
		String dlTransId = assetTransIdMap.get('dlTransId');
		Map<String, String> assetDocMap = new Map<String, String>();
		for(Id assetId: assetsMap.keyset()){
			// Refactoring Method....Getting fileId, 
			Map<String, String> contentDocMap = new Map<String, String>();
			contentDocMap = getRefactorFileIdNameType(assetId, contentMap, contentVersionMap);
			Id fileId = contentDocMap.get('fileId');
			String fileName = contentDocMap.get('fileName');
			String fileType = contentDocMap.get('fileType');
			Asset assetRecord = assetsMap.get(assetId);
			if(assetRecord.Type__c == Constants.ASSET_NAME_DEAN_LETTER){
				dlFile = Constants.FILE_DOWNLOAD_URL + fileId;
				dlFileName = fileName;
				dlFileType = fileType;
			} else if(assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == dlId){
				dlNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				dlNameDocName = fileName;
				dlNameDocType = fileType;
			} else if(assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == dlId){
				dlTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
				dlTransFileName = fileName;
				dlTransFileType = fileType;
			} else if(assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == dlTransId){
				dlTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				dlTransNameDocName = fileName;
				dlTransNameDocType = fileType;
			}
		}
		// ASSET_TYPE_DEAN_LETTER
		assetDocMap.put('dlFile', dlFile);
		assetDocMap.put('dlFileName', dlFileName);
		assetDocMap.put('dlFileType', dlFileType);
		assetDocMap.put('dlNameDoc', dlNameDoc);
		assetDocMap.put('dlNameDocName', dlNameDocName);
		assetDocMap.put('dlNameDocType', dlNameDocType);
		assetDocMap.put('dlTransFile', dlTransFile);
		assetDocMap.put('dlTransFileName', dlTransFileName);
		assetDocMap.put('dlTransFileType', dlTransFileType);
		assetDocMap.put('dlTransNameDoc', dlTransNameDoc);
		assetDocMap.put('dlTransNameDocName', dlTransNameDocName);
		assetDocMap.put('dlTransNameDocType', dlTransNameDocType);
		return assetDocMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getGraduateOnlyRecordsRefactorDocDiploma
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIdsMap, assetsMap and fileId
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGraduateOnlyRecordsRefactorDocDiploma(Map<String, String> assetIdsMap, Map<String, String> assetTransIdMap, Map<Id, Asset> assetsMap, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {
		// ASSET_TYPE_FINAL_MED_DIPLOMA
		String fmdFile = '';
		String fmdFileName = '';
		String fmdFileType = '';
		String fmdNameDoc = '';
		String fmdNameDocName = '';
		String fmdNameDocType = '';
		String fmdTransFile = '';
		String fmdTransFileName = '';
		String fmdTransFileType = '';
		String fmdTransNameDoc = '';
		String fmdTransNameDocName = '';
		String fmdTransNameDocType = '';

		String fmdId = assetIdsMap.get('fmdId');
		String fmdTransId = assetTransIdMap.get('fmdTransId');
		Map<String, String> assetDocMap = new Map<String, String> ();

		for (Id assetId: assetsMap.keyset()) {
			// Refactoring Method....Getting fileId, 
			Map<String, String> contentDocMap = new Map<String, String> ();
			contentDocMap = getRefactorFileIdNameType(assetId, contentMap, contentVersionMap);
			Id fileId = contentDocMap.get('fileId');
			String fileName = contentDocMap.get('fileName');
			String fileType = contentDocMap.get('fileType');

			Asset assetRecord = assetsMap.get(assetId);

			if (assetRecord.Type__c == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA) {
				fmdFile = Constants.FILE_DOWNLOAD_URL + fileId;
				fmdFileName = fileName;
				fmdFileType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == fmdId) {
				fmdNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				fmdNameDocName = fileName;
				fmdNameDocType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == fmdId) {
				fmdTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
				fmdTransFileName = fileName;
				fmdTransFileType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == fmdTransId) {
				fmdTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				fmdTransNameDocName = fileName;
				fmdTransNameDocType = fileType;
			}
		}

		// ASSET_TYPE_FINAL_MED_DIPLOMA
		assetDocMap.put('fmdFile', fmdFile);
		assetDocMap.put('fmdFileName', fmdFileName);
		assetDocMap.put('fmdFileType', fmdFileType);
		assetDocMap.put('fmdNameDoc', fmdNameDoc);
		assetDocMap.put('fmdNameDocName', fmdNameDocName);
		assetDocMap.put('fmdNameDocType', fmdNameDocType);
		assetDocMap.put('fmdTransFile', fmdTransFile);
		assetDocMap.put('fmdTransFileName', fmdTransFileName);
		assetDocMap.put('fmdTransFileType', fmdTransFileType);
		assetDocMap.put('fmdTransNameDoc', fmdTransNameDoc);
		assetDocMap.put('fmdTransNameDocName', fmdTransNameDocName);
		assetDocMap.put('fmdTransNameDocType', fmdTransNameDocType);

		return assetDocMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getGraduateOnlyRecordsRefactorDocTranscript
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIdsMap, assetsMap and fileId
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getGraduateOnlyRecordsRefactorDocTranscript(Map<String, String> assetIdsMap, Map<String, String> assetTransIdMap, Map<Id, Asset> assetsMap, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {
		// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
		String ftFile = '';
		String ftFileName = '';
		String ftFileType = '';
		String ftNameDoc = '';
		String ftNameDocName = '';
		String ftNameDocType = '';
		String ftTransFile = '';
		String ftTransFileName = '';
		String ftTransFileType = '';
		String ftTransNameDoc = '';
		String ftTransNameDocName = '';
		String ftTransNameDocType = '';

		String ftId = assetIdsMap.get('ftId');
		String ftTransId = assetTransIdMap.get('ftTransId');
		Map<String, String> assetDocMap = new Map<String, String> ();

		for (Id assetId: assetsMap.keyset()) {
			// Refactoring Method....Getting fileId, 
			Map<String, String> contentDocMap = new Map<String, String> ();
			contentDocMap = getRefactorFileIdNameType(assetId, contentMap, contentVersionMap);
			Id fileId = contentDocMap.get('fileId');
			String fileName = contentDocMap.get('fileName');
			String fileType = contentDocMap.get('fileType');

			Asset assetRecord = assetsMap.get(assetId);

			if (assetRecord.Type__c == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) {
				ftFile = Constants.FILE_DOWNLOAD_URL + fileId;
				ftFileName = fileName;
				ftFileType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == ftId) {
				ftNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				ftNameDocName = fileName;
				ftNameDocType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == ftId) {
				ftTransFile = Constants.FILE_DOWNLOAD_URL + fileId;
				ftTransFileName = fileName;
				ftTransFileType = fileType;
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == ftTransId) {
				ftTransNameDoc = Constants.FILE_DOWNLOAD_URL + fileId;
				ftTransNameDocName = fileName;
				ftTransNameDocType = fileType;
			}
		}

		// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
		assetDocMap.put('ftFile', ftFile);
		assetDocMap.put('ftFileName', ftFileName);
		assetDocMap.put('ftFileType', ftFileType);
		assetDocMap.put('ftNameDoc', ftNameDoc);
		assetDocMap.put('ftNameDocName', ftNameDocName);
		assetDocMap.put('ftNameDocType', ftNameDocType);
		assetDocMap.put('ftTransFile', ftTransFile);
		assetDocMap.put('ftTransFileName', ftTransFileName);
		assetDocMap.put('ftTransFileType', ftTransFileType);
		assetDocMap.put('ftTransNameDoc', ftTransNameDoc);
		assetDocMap.put('ftTransNameDocName', ftTransNameDocName);
		assetDocMap.put('ftTransNameDocType', ftTransNameDocType);

		return assetDocMap;
	}
	// Method to return Contact Asscociation type staging for Incomplete case processing 
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c> getOtherMedicalSchool() {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		List<Contact_Association_Type_Staging__c> institutionsList = new List<Contact_Association_Type_Staging__c> ([SELECT Id, Account__c, Account_Name__c, School_Program__c,
			Start_Date__c, End_Date__c, Student_ID__c, Specialty__c, Transfer_Credit_to_Degree_School__c,Contact__c,
			(SELECT Id, To_School__c, From_School__c, From_School_Name__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c,
				Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r),
			(SELECT Id, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c,
				Type__c FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type_Staging__c
			WHERE Contact__c =: contactId AND(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL)
			AND Case__c =: caseId
			ORDER BY createdDate ASC
		]);
		return institutionsList;
	}	
	// Method to return files and data for Incomplete case processing	 	
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsAndDocumentsForOtherMedical() {
		Boolean isExamReOpened = AppForCertHelper.checkExamReopenedCase();
		Map<String, Map<String, String>> returnAllValue = new Map<String, Map<String, String>> ();
		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		List<Id> assetIds = new List<Id> ();
		List<Id> instIds = new List<Id> ();
		List<Contact_Association_Type_Staging__c> institutionsList = getAssetsOtherMedicalRFInstitutionsList(isExamReOpened);
		List<Contact_Association_Type_Staging__c> graduateList = getAssetsOtherMedicalRFGraduateList(isExamReOpened);	
		List<Contact_Association_Type_Staging__c> degreeChangeList = AppForCertHelper.getAssetsDegreeChangeList(isExamReOpened);

		for (Contact_Association_Type_Staging__c institution: institutionsList) {
			instIds.add(institution.Id);
		}		
		Map<String, Map<Id, Id>> afmListsMap = new Map<String, Map<Id, Id>> ();
		Map<Id, Id> tctAssetId = new Map<Id, Id> ();
		Map<Id, Id> preMedAssetId = new Map<Id, Id> ();
		Map<Id, Id> courceDetailsAssetId = new Map<Id, Id> ();
		Map<String, String> tctNameDocAffirmationLabInstMap = new Map<String, String> ();
		Map<String, String> tctTranslationAffirmationLabInstMap = new Map<String, String> ();
		List<Id> allAffmir = new List<Id> ();
		if (!institutionsList.isEmpty()) {
			allAffmir.addall(instIds);
		}	
		// Get Affirmation Rejection
		List<Affirmation__c> affListForRejection = getAssetsOtherMedicalRFAffRejection(isExamReOpened, allAffmir);
		if (affListForRejection.isEmpty()) {
			List<Affirmation__c> afmList = getAssetsOtherMedicalRFAffLists(isExamReOpened, instIds);
			afmListsMap = getAssetsOtherMedicalRFAffListsMap(afmList);
			courceDetailsAssetId = afmListsMap.get('courceDetailsAssetId');
			tctAssetId = afmListsMap.get('tctAssetId');
			preMedAssetId = afmListsMap.get('preMedAssetId');
			Map<String, Map<String, String>> afmListsTCTMap = getAssetsOtherMedicalRFAffListsTCTMap(afmList);
			tctNameDocAffirmationLabInstMap = afmListsTCTMap.get('tctNameDocAffirmationLabInstMap');
			tctTranslationAffirmationLabInstMap = afmListsTCTMap.get('tctTranslationAffirmationLabInstMap');
		}
		// Get Asset Lists
		List<Asset> assetList = getAssetsOtherMedicalRFAssetList(isExamReOpened, instIds);
		for (Asset assId: assetList) {
			assetIds.add(assId.Id);
			assetsMap.put(assId.Id, assId);
		}
		Map<String, Map<String, String>> assetInstMap = getAssetsOtherMedicalRFAssetInstMap(assetList);
		Map<String, String> tctInstMap = assetInstMap.get('tctInstMap');
		Map<String, String> pmlInstMap = assetInstMap.get('pmlInstMap');
		Map<String, String> tctNameDocIdInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocIdInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocIdInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocIdInstMap = new Map<String, String> ();
		// TCT
		Map<String, String> tctNameInstMap = new Map<String, String> ();
		Map<String, String> tctNameDiffInstMap = new Map<String, String> ();
		Map<String, String> tctTransInstMap = new Map<String, String> ();
		// TCT Transcript
		Map<String, String> tctTransIdInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDiffInstMap = new Map<String, String> ();
		// Pre Med Letter
		Map<String, String> pmlNameInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDiffInstMap = new Map<String, String> ();
		Map<String, String> pmlTransInstMap = new Map<String, String> ();
		// Pre Med Letter Transscript
		Map<String, String> pmlTransIdInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDiffInstMap = new Map<String, String> ();
		// TCT File
		Map<String, String> tctFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocAffirmationInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileAffirmationInstMap = new Map<String, String> ();
		// Pre Med Letter File
		Map<String, String> pmlFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocAffirmationInstMap = new Map<String, String> ();
		// Course Detail Affirmation
		Map<String, String> courceDetailsAffirmationInstMap = new Map<String, String> ();
		Map<String, Map<String, String>> assetTCTPMLMap = getAssetsOtherMedicalRFAssetListsTCTMap(afmListsMap, assetList, assetInstMap);
		// TCT
		tctNameInstMap = assetTCTPMLMap.get('tctNameInstMap');
		tctNameDiffInstMap = assetTCTPMLMap.get('tctNameDiffInstMap');
		tctTransInstMap = assetTCTPMLMap.get('tctTransInstMap');
		// TCT Transcript
		tctTransIdInstMap = assetTCTPMLMap.get('tctTransIdInstMap');
		tctTransNameInstMap = assetTCTPMLMap.get('tctTransNameInstMap');
		tctTransNameDiffInstMap = assetTCTPMLMap.get('tctTransNameDiffInstMap');
		// Pre Med Letter
		pmlNameInstMap = assetTCTPMLMap.get('pmlNameInstMap');
		pmlNameDiffInstMap = assetTCTPMLMap.get('pmlNameDiffInstMap');
		pmlTransInstMap = assetTCTPMLMap.get('pmlTransInstMap');
		// Pre Med Letter Transscript
		pmlTransIdInstMap = assetTCTPMLMap.get('pmlTransIdInstMap');
		pmlTransNameInstMap = assetTCTPMLMap.get('pmlTransNameInstMap');
		pmlTransNameDiffInstMap = assetTCTPMLMap.get('pmlTransNameDiffInstMap');
		// TCT File
		tctFileAffirmationInstMap = assetTCTPMLMap.get('tctFileAffirmationInstMap');
		tctNameDocAffirmationInstMap = assetTCTPMLMap.get('tctNameDocAffirmationInstMap');
		tctTransFileAffirmationInstMap = assetTCTPMLMap.get('tctTransFileAffirmationInstMap');
		// Pre Med Letter File
		pmlFileAffirmationInstMap = assetTCTPMLMap.get('pmlFileAffirmationInstMap');
		pmlNameDocAffirmationInstMap = assetTCTPMLMap.get('pmlNameDocAffirmationInstMap');
		pmlTransFileAffirmationInstMap = assetTCTPMLMap.get('pmlTransFileAffirmationInstMap');
		pmlTransNameDocAffirmationInstMap = assetTCTPMLMap.get('pmlTransNameDocAffirmationInstMap');
		// Course Detail Affirmation
		courceDetailsAffirmationInstMap = assetTCTPMLMap.get('courceDetailsAffirmationInstMap');
		Map<String, String> tctFileInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlFileInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocInstMap = new Map<String, String> ();
		Map<String, String> tctFileNameInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> pmlFileNameInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> tctFileTypeInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileTypeInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlFileTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocTypeInstMap = new Map<String, String> ();
		if (assetIds.size() > 0) {
			Map<Id, List<ContentDocumentLink>> contentMap = getRefactorContentMap(assetIds);
			List<Id> contentDocumentIds = getRefactorContentDocumentIds(assetIds);
			Map<Id, ContentVersion> contentVersionMap = getRefactorContentVersionMap(contentDocumentIds);
			for (Id assetId: assetsMap.keyset()) {
				// Refactoring Method....Getting fileId, 
				Map<String, String> contectDocMap = new Map<String, String> ();
				contectDocMap = getRefactorFileIdNameType(assetId, contentMap, contentVersionMap);
				Id fileId = contectDocMap.get('fileId');
				String fileName = contectDocMap.get('fileName');
				String fileType = contectDocMap.get('fileType');
				Asset assetRecord = assetsMap.get(assetId);
				// TCT File
				if (assetRecord.Type__c == Constants.ASSET_TYPE_TCT) {
					tctFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
					tctFileNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
					tctFileTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
				}
				// This method is created for avoiding SonarCloud issue
				Map<String, Map<String, String>> assetDocumentMap = new Map<String, Map<String, String>> ();
				assetDocumentMap = getAssetsOtherMedicalRefactorDocument(assetIds, assetsMap, assetInstMap, assetTCTPMLMap);
				// TCT Name
				tctNameDocInstMap = assetDocumentMap.get('tctNameDocInstMap');
				tctNameDocNameInstMap = assetDocumentMap.get('tctNameDocNameInstMap');
				tctNameDocTypeInstMap = assetDocumentMap.get('tctNameDocTypeInstMap');
				tctNameDocIdInstMap = assetDocumentMap.get('tctNameDocIdInstMap');
				// TCT Trans File
				tctTransFileInstMap = assetDocumentMap.get('tctTransFileInstMap');
				tctTransFileNameInstMap = assetDocumentMap.get('tctTransFileNameInstMap');
				tctTransFileTypeInstMap = assetDocumentMap.get('tctTransFileTypeInstMap');
				// TCT Trans Name
				tctTransNameDocInstMap = assetDocumentMap.get('tctTransNameDocInstMap');
				tctTransNameDocNameInstMap = assetDocumentMap.get('tctTransNameDocNameInstMap');
				tctTransNameDocTypeInstMap = assetDocumentMap.get('tctTransNameDocTypeInstMap');
				tctTransNameDocIdInstMap = assetDocumentMap.get('tctTransNameDocIdInstMap');
				// Pml File
				pmlFileInstMap = assetDocumentMap.get('pmlFileInstMap');
				pmlFileNameInstMap = assetDocumentMap.get('pmlFileNameInstMap');
				pmlFileTypeInstMap = assetDocumentMap.get('pmlFileTypeInstMap');
				// Pml Name
				pmlNameDocInstMap = assetDocumentMap.get('pmlNameDocInstMap');
				pmlNameDocNameInstMap = assetDocumentMap.get('pmlNameDocNameInstMap');
				pmlNameDocTypeInstMap = assetDocumentMap.get('pmlNameDocTypeInstMap');
				pmlNameDocIdInstMap = assetDocumentMap.get('pmlNameDocIdInstMap');
				// Pml Trans File
				pmlTransFileInstMap = assetDocumentMap.get('pmlTransFileInstMap');
				pmlTransFileNameInstMap = assetDocumentMap.get('pmlTransFileNameInstMap');
				pmlTransFileTypeInstMap = assetDocumentMap.get('pmlTransFileTypeInstMap');
				// Pml Trans Name
				pmlTransNameDocInstMap = assetDocumentMap.get('pmlTransNameDocInstMap');
				pmlTransNameDocNameInstMap = assetDocumentMap.get('pmlTransNameDocNameInstMap');
				pmlTransNameDocTypeInstMap = assetDocumentMap.get('pmlTransNameDocTypeInstMap');
				pmlTransNameDocIdInstMap = assetDocumentMap.get('pmlTransNameDocIdInstMap');
			}
		}
		for (Id instId: instIds) {
			Map<String, String> instRetVal = new Map<String, String> ();
			instRetVal.put('tctId', tctInstMap.get(instId));
			instRetVal.put('tctFile', tctFileInstMap.get(instId));
			instRetVal.put('tctName', tctNameInstMap.get(instId));
			instRetVal.put('tctNameDiff', tctNameDiffInstMap.get(instId));
			instRetVal.put('tctNameDoc', tctNameDocInstMap.get(instId));
			instRetVal.put('tctTransId', tctTransIdInstMap.get(instId));
			instRetVal.put('tctTrans', tctTransInstMap.get(instId));
			instRetVal.put('tctTransFile', tctTransFileInstMap.get(instId));
			instRetVal.put('tctTransName', tctTransNameInstMap.get(instId));
			instRetVal.put('tctTransNameDiff', tctTransNameDiffInstMap.get(instId));
			instRetVal.put('tctTransNameDoc', tctTransNameDocInstMap.get(instId));
			instRetVal.put('pmlId', pmlInstMap.get(instId));
			instRetVal.put('pmlFile', pmlFileInstMap.get(instId));
			instRetVal.put('pmlName', pmlNameInstMap.get(instId));
			instRetVal.put('pmlNameDiff', pmlNameDiffInstMap.get(instId));
			instRetVal.put('pmlNameDoc', pmlNameDocInstMap.get(instId));
			instRetVal.put('pmlTransId', pmlTransIdInstMap.get(instId));
			instRetVal.put('pmlTrans', pmlTransInstMap.get(instId));
			instRetVal.put('pmlTransFile', pmlTransFileInstMap.get(instId));
			instRetVal.put('pmlTransName', pmlTransNameInstMap.get(instId));
			instRetVal.put('pmlTransNameDiff', pmlTransNameDiffInstMap.get(instId));
			instRetVal.put('pmlTransNameDoc', pmlTransNameDocInstMap.get(instId));
			instRetVal.put('tctFileName', tctFileNameInstMap.get(instId));
			instRetVal.put('tctNameDocName', tctNameDocNameInstMap.get(instId));
			instRetVal.put('tctTransFileName', tctTransFileNameInstMap.get(instId));
			instRetVal.put('tctTransNameDocName', tctTransNameDocNameInstMap.get(instId));
			instRetVal.put('pmlFileName', pmlFileNameInstMap.get(instId));
			instRetVal.put('pmlNameDocName', pmlNameDocNameInstMap.get(instId));
			instRetVal.put('pmlTransFileName', pmlTransFileNameInstMap.get(instId));
			instRetVal.put('pmlTransNameDocName', pmlTransNameDocNameInstMap.get(instId));
			instRetVal.put('tctFileType', tctFileTypeInstMap.get(instId));
			instRetVal.put('tctNameDocType', tctNameDocTypeInstMap.get(instId));
			instRetVal.put('tctTransFileType', tctTransFileTypeInstMap.get(instId));
			instRetVal.put('tctTransNameDocType', tctTransNameDocTypeInstMap.get(instId));
			instRetVal.put('pmlFileType', pmlFileTypeInstMap.get(instId));
			instRetVal.put('pmlNameDocType', pmlNameDocTypeInstMap.get(instId));
			instRetVal.put('pmlTransFileType', pmlTransFileTypeInstMap.get(instId));
			instRetVal.put('pmlTransNameDocType', pmlTransNameDocTypeInstMap.get(instId));
			instRetVal.put('tctFileAffirmation', tctFileAffirmationInstMap.get(instId));
			instRetVal.put('tctNameDocAffirmation', tctNameDocAffirmationInstMap.get(instId));
			instRetVal.put('tctTransFileAffirmation', tctTransFileAffirmationInstMap.get(instId));
			instRetVal.put('pmlFileAffirmation', pmlFileAffirmationInstMap.get(instId));
			instRetVal.put('pmlNameDocAffirmation', pmlNameDocAffirmationInstMap.get(instId));
			instRetVal.put('pmlTransFileAffirmation', pmlTransFileAffirmationInstMap.get(instId));
			instRetVal.put('pmlTransNameDocAffirmation', pmlTransNameDocAffirmationInstMap.get(instId));
			instRetVal.put('tctNameCondLabAffr', tctNameDocAffirmationLabInstMap.get(instId));
			instRetVal.put('tctTranslationLabAffr', tctTranslationAffirmationLabInstMap.get(instId));
			instRetVal.put('courceDetailsAffirmation', courceDetailsAffirmationInstMap.get(instId));
			instRetVal.put('tctNameId', tctNameDocIdInstMap.get(instId));
			instRetVal.put('tctTransNameId', tctTransNameDocIdInstMap.get(instId));
			instRetVal.put('pmlNameId', pmlNameDocIdInstMap.get(instId));
			instRetVal.put('pmlTransNameId', pmlTransNameDocIdInstMap.get(instId));

			returnAllValue.put(instId, instRetVal);
		}
		if (!graduateList.isEmpty() && affListForRejection.isEmpty()) {
			Map<String, String> returnGraduateMap = new Map<String, String> ();
			returnGraduateMap = getGraduateOnlyRecordsForIncompleteCaseProcessing();
			returnAllValue.put(graduateList[0].Id, returnGraduateMap);
		}
		if (!degreeChangeList.isEmpty() && affListForRejection.isEmpty()) {
			Map<String, String> returnDegreeMap = new Map<String, String> ();
			if(returnAllValue.containsKey(degreeChangeList[0].Id)) {
				Map<String, String> grMap = new Map<String, String> ();
				grMap = returnAllValue.get(degreeChangeList[0].Id);
				returnDegreeMap = AppForCertHelper.getDegIncompleteCaseProc();
				grMap.putAll(returnDegreeMap);
				returnAllValue.put(degreeChangeList[0].Id, grMap); 

			}
			else{
				returnDegreeMap = AppForCertHelper.getDegIncompleteCaseProc();
				returnAllValue.put(degreeChangeList[0].Id, returnDegreeMap);
			}
			
		}	
		return returnAllValue;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getRefactorContentMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIds
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<Id, List<ContentDocumentLink>> getRefactorContentMap(List<Id> assetIds) {
		Map<Id, List<ContentDocumentLink>> contentMap = new Map<Id, List<ContentDocumentLink>> ();
		for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {
			if (!contentMap.containsKey(contentDoc.LinkedEntityId)) {
				contentMap.put(contentDoc.LinkedEntityId, new List<ContentDocumentLink> ());
			}
			contentMap.get(contentDoc.LinkedEntityId).add(contentDoc);
		}
		return contentMap;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getRefactorContentDocumentIds
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIds
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Id> getRefactorContentDocumentIds(List<Id> assetIds) {
		List<Id> contentDocumentIds = new List<Id> ();
		for (contentDocumentLink contentDoc: [SELECT Id, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.Title FROM contentDocumentLink WHERE LinkedEntityId IN: assetIds]) {
			contentDocumentIds.add(contentDoc.ContentDocumentId);
		}
		return contentDocumentIds;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRefactorContentVersionMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : contentDocumentIds
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<Id, ContentVersion> getRefactorContentVersionMap(List<Id> contentDocumentIds) {
		Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion> ();
		if (contentDocumentIds.size() > 0) {
			for (ContentVersion contentVer: [SELECT ContentDocumentId, ContentDocument.LatestPublishedVersionId, FileExtension, Title FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds]) {
				contentVersionMap.put(contentVer.ContentDocumentId, contentVer);
			}
		}
		return contentVersionMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRefactorFileId
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Id (FileId)
	 * @Params : assetsMap, contentMap and contentVersionMap
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getRefactorFileIdNameType(Id assetId, Map<Id, List<ContentDocumentLink>> contentMap, Map<Id, ContentVersion> contentVersionMap) {
		Id fileId;
		String fileName = '';
		String fileType = '';
		Map<String, String> contectDocMap = new Map<String, String> ();
		if (contentMap.get(assetId) != null) {
			for (ContentDocumentLink contentlink: contentMap.get(assetId)) {
				if (contentVersionMap.get(contentlink.ContentDocumentId) != null) {
					fileId = contentVersionMap.get(contentlink.ContentDocumentId).ContentDocumentId;
					fileName = contentVersionMap.get(contentlink.ContentDocumentId).Title;
					fileType = contentVersionMap.get(contentlink.ContentDocumentId).FileExtension;
				}
			}
		}

		contectDocMap.put('fileId', fileId);
		contectDocMap.put('fileName', fileName);
		contectDocMap.put('fileType', fileType);

		return contectDocMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRefactorDocument
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : assetIdsMap, deanLetter, finalTranscriptReqd, assetIds and assetsMap
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRefactorDocument(List<Id> assetIds, Map<Id, Asset> assetsMap, Map<String, Map<String, String>> assetInstMap, Map<String, Map<String, String>> assetTCTPMLMap) {
		Map<Id, List<ContentDocumentLink>> contentMap = getRefactorContentMap(assetIds);
		List<Id> contentDocumentIds = getRefactorContentDocumentIds(assetIds);
		Map<Id, ContentVersion> contentVersionMap = getRefactorContentVersionMap(contentDocumentIds);

		Map<String, Map<String, String>> assetDocumentMap = new Map<String, Map<String, String>> ();

		// TCT Name
		Map<String, String> tctNameDocInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocIdInstMap = new Map<String, String> ();
		// TCT Trans File
		Map<String, String> tctTransFileInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileTypeInstMap = new Map<String, String> ();
		// TCT Trans Name
		Map<String, String> tctTransNameDocInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDocIdInstMap = new Map<String, String> ();
		// Pml File
		Map<String, String> pmlFileInstMap = new Map<String, String> ();
		Map<String, String> pmlFileNameInstMap = new Map<String, String> ();
		Map<String, String> pmlFileTypeInstMap = new Map<String, String> ();
		// Pml Name
		Map<String, String> pmlNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocIdInstMap = new Map<String, String> ();
		// Pml Trans File
		Map<String, String> pmlTransFileInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileTypeInstMap = new Map<String, String> ();
		// Pml Trans Name
		Map<String, String> pmlTransNameDocInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocTypeInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocIdInstMap = new Map<String, String> ();

		Map<String, String> tctInstMap = assetInstMap.get('tctInstMap');
		Map<String, String> tctTransIdInstMap = assetTCTPMLMap.get('tctTransIdInstMap');
		Map<String, String> pmlInstMap = assetInstMap.get('pmlInstMap');
		Map<String, String> pmlTransIdInstMap = assetTCTPMLMap.get('pmlTransIdInstMap');

		for (Id assetId: assetsMap.keyset()) {
			// Refactoring Method....Getting fileId, 
			Map<String, String> contectDocMap = new Map<String, String> ();
			contectDocMap = getRefactorFileIdNameType(assetId, contentMap, contentVersionMap);
			Id fileId = contectDocMap.get('fileId');
			String fileName = contectDocMap.get('fileName');
			String fileType = contectDocMap.get('fileType');

			Asset assetRecord = assetsMap.get(assetId);

			String tctId = tctInstMap.get(assetRecord.Contact_Association_Type_Staging__c);
			String tctTransId = tctTransIdInstMap.get(assetRecord.Contact_Association_Type_Staging__c);
			String pmlId = pmlInstMap.get(assetRecord.Contact_Association_Type_Staging__c);
			String pmlTransId = pmlTransIdInstMap.get(assetRecord.Contact_Association_Type_Staging__c);

			// TCT 
			if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctId) { // TCT Name
				tctNameDocInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				tctNameDocNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				tctNameDocTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
				tctNameDocIdInstMap.put(assetRecord.Contact_Association_Type_Staging__c, assetRecord.Id);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == tctId) { // TCT Trans File
				tctTransFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				tctTransFileNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				tctTransFileTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == tctTransId) { // TCT Trans Name
				tctTransNameDocInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				tctTransNameDocNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				tctTransNameDocTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
				tctTransNameDocIdInstMap.put(assetRecord.Contact_Association_Type_Staging__c, assetRecord.Id);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) { // Pml File   
				pmlFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				pmlFileNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				pmlFileTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlId) { // Pml Name
				pmlNameDocInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				pmlNameDocNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				pmlNameDocTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
				pmlNameDocIdInstMap.put(assetRecord.Contact_Association_Type_Staging__c, assetRecord.Id);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_TRANSLATION && assetRecord.ParentId == pmlId) { // Pml Trans File
				pmlTransFileInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				pmlTransFileNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				pmlTransFileTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
			} else if (assetRecord.Type__c == Constants.ASSET_TYPE_NAME_DOC && assetRecord.ParentId == pmlTransId) { // Pml Trans Name                
				pmlTransNameDocInstMap.put(assetRecord.Contact_Association_Type_Staging__c, Constants.FILE_DOWNLOAD_URL + fileId);
				pmlTransNameDocNameInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileName);
				pmlTransNameDocTypeInstMap.put(assetRecord.Contact_Association_Type_Staging__c, fileType);
				pmlTransNameDocIdInstMap.put(assetRecord.Contact_Association_Type_Staging__c, assetRecord.Id);
			}
		}

		// TCT Name
		assetDocumentMap.put('tctNameDocInstMap', tctNameDocInstMap);
		assetDocumentMap.put('tctNameDocNameInstMap', tctNameDocNameInstMap);
		assetDocumentMap.put('tctNameDocTypeInstMap', tctNameDocTypeInstMap);
		assetDocumentMap.put('tctNameDocIdInstMap', tctNameDocIdInstMap);
		// TCT Trans File
		assetDocumentMap.put('tctTransFileInstMap', tctTransFileInstMap);
		assetDocumentMap.put('tctTransFileNameInstMap', tctTransFileNameInstMap);
		assetDocumentMap.put('tctTransFileTypeInstMap', tctTransFileTypeInstMap);
		// TCT Trans Name
		assetDocumentMap.put('tctTransNameDocInstMap', tctTransNameDocInstMap);
		assetDocumentMap.put('tctTransNameDocNameInstMap', tctTransNameDocNameInstMap);
		assetDocumentMap.put('tctTransNameDocTypeInstMap', tctTransNameDocTypeInstMap);
		assetDocumentMap.put('tctTransNameDocIdInstMap', tctTransNameDocIdInstMap);
		// Pml File
		assetDocumentMap.put('pmlFileInstMap', pmlFileInstMap);
		assetDocumentMap.put('pmlFileNameInstMap', pmlFileNameInstMap);
		assetDocumentMap.put('pmlFileTypeInstMap', pmlFileTypeInstMap);
		// Pml Name
		assetDocumentMap.put('pmlNameDocInstMap', pmlNameDocInstMap);
		assetDocumentMap.put('pmlNameDocNameInstMap', pmlNameDocNameInstMap);
		assetDocumentMap.put('pmlNameDocTypeInstMap', pmlNameDocTypeInstMap);
		assetDocumentMap.put('pmlNameDocIdInstMap', pmlNameDocIdInstMap);
		// Pml Trans File
		assetDocumentMap.put('pmlTransFileInstMap', pmlTransFileInstMap);
		assetDocumentMap.put('pmlTransFileNameInstMap', pmlTransFileNameInstMap);
		assetDocumentMap.put('pmlTransFileTypeInstMap', pmlTransFileTypeInstMap);
		// Pml Trans Name
		assetDocumentMap.put('pmlTransNameDocInstMap', pmlTransNameDocInstMap);
		assetDocumentMap.put('pmlTransNameDocNameInstMap', pmlTransNameDocNameInstMap);
		assetDocumentMap.put('pmlTransNameDocTypeInstMap', pmlTransNameDocTypeInstMap);
		assetDocumentMap.put('pmlTransNameDocIdInstMap', pmlTransNameDocIdInstMap);

		return assetDocumentMap;
	}

	// Method to avoid SonarCloud Issue  (Complexity issue)
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRFAssetListsTCTMap(Map<String, Map<Id, Id>> afmListsMap, List<Asset> assetList, Map<String, Map<String, String>> assetInstMap) {
		Map<String, Map<String, String>> assetTCTMap = new Map<String, Map<String, String>> ();
		Map<String, Map<String, String>> assetPreMedLetterMap = new Map<String, Map<String, String>> ();
		Map<String, String> emptyMap = new Map<String, String> ();
		assetPreMedLetterMap.put('pmlNameInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlNameDiffInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlTransInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlFileAffirmationInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlNameDocAffirmationInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlTransFileAffirmationInstMap',emptyMap);
		assetPreMedLetterMap.put('pmlTransNameDocAffirmationInstMap',emptyMap);
		assetTCTMap.put('tctNameInstMap',emptyMap);
		assetTCTMap.put('tctNameDiffInstMap',emptyMap);
		assetTCTMap.put('tctTransInstMap',emptyMap);
		assetTCTMap.put('tctFileAffirmationInstMap',emptyMap);
		assetTCTMap.put('tctNameDocAffirmationInstMap',emptyMap);
		assetTCTMap.put('tctTransFileAffirmationInstMap',emptyMap);
		assetTCTMap.put('courceDetailsAffirmationInstMap',emptyMap);
		Map<String, String> tctTransIdInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameInstMap = new Map<String, String> ();
		Map<String, String> tctTransNameDiffInstMap = new Map<String, String> ();
		Map<String, String> pmlTransIdInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDiffInstMap = new Map<String, String> ();
		Map<String, Map<String, String>> assetListMap = new Map<String, Map<String, String>> ();
		Map<String, String> tctInstMap = assetInstMap.get('tctInstMap');
		Map<String, String> pmlInstMap = assetInstMap.get('pmlInstMap');
		for (Asset rec: assetList) {
			String assInstId = tctInstMap.get(rec.Contact_Association_Type_Staging__c);
			String assPmlInstId = pmlInstMap.get(rec.Contact_Association_Type_Staging__c);
			if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
				assetTCTMap = getAssetsOtherMedicalRFAssetTypeTCT(afmListsMap, assetList, assetInstMap);
			} else if (rec.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				assetPreMedLetterMap = getAssetsOtherMedicalRFAssetTypePreMedLetter(afmListsMap, assetList, assetInstMap);
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assInstId) {
				tctTransIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
				tctTransNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				tctTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				if (rec.Name_on_Document_is_Different__c) {
					tctTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
			} else if (rec.Type__c == Constants.ASSET_TYPE_TRANSLATION && rec.ParentId == assPmlInstId) {
				pmlTransIdInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Id);
				pmlTransNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				pmlTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				if (rec.Name_on_Document_is_Different__c) {
					pmlTransNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
			}
		}
		// TCT
		assetListMap.put('tctNameInstMap', assetTCTMap.get('tctNameInstMap'));
		assetListMap.put('tctNameDiffInstMap', assetTCTMap.get('tctNameDiffInstMap'));
		assetListMap.put('tctTransInstMap', assetTCTMap.get('tctTransInstMap'));
		assetListMap.put('tctFileAffirmationInstMap', assetTCTMap.get('tctFileAffirmationInstMap'));
		assetListMap.put('tctNameDocAffirmationInstMap', assetTCTMap.get('tctNameDocAffirmationInstMap'));
		assetListMap.put('tctTransFileAffirmationInstMap', assetTCTMap.get('tctTransFileAffirmationInstMap'));
		assetListMap.put('courceDetailsAffirmationInstMap', assetTCTMap.get('courceDetailsAffirmationInstMap'));
		// Pre Med Letter
		assetListMap.put('pmlNameInstMap', assetPreMedLetterMap.get('pmlNameInstMap'));
		assetListMap.put('pmlNameDiffInstMap', assetPreMedLetterMap.get('pmlNameDiffInstMap'));
		assetListMap.put('pmlTransInstMap', assetPreMedLetterMap.get('pmlTransInstMap'));
		assetListMap.put('pmlFileAffirmationInstMap', assetPreMedLetterMap.get('pmlFileAffirmationInstMap'));
		assetListMap.put('pmlNameDocAffirmationInstMap', assetPreMedLetterMap.get('pmlNameDocAffirmationInstMap'));
		assetListMap.put('pmlTransFileAffirmationInstMap', assetPreMedLetterMap.get('pmlTransFileAffirmationInstMap'));
		assetListMap.put('pmlTransNameDocAffirmationInstMap', assetPreMedLetterMap.get('pmlTransNameDocAffirmationInstMap'));
		// TCT Transcript
		assetListMap.put('tctTransIdInstMap', tctTransIdInstMap);
		assetListMap.put('tctTransNameInstMap', tctTransNameInstMap);
		assetListMap.put('tctTransNameDiffInstMap', tctTransNameDiffInstMap);
		// Pre Med Letter Transscript
		assetListMap.put('pmlTransIdInstMap', pmlTransIdInstMap);
		assetListMap.put('pmlTransNameInstMap', pmlTransNameInstMap);
		assetListMap.put('pmlTransNameDiffInstMap', pmlTransNameDiffInstMap);
		return assetListMap;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAssetTypePreMedLetter
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map<String, Map<String, String>>
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRFAssetTypePreMedLetter(Map<String, Map<Id, Id>> afmListsMap, List<Asset> assetList, Map<String, Map<String, String>> assetInstMap) {

		Map<String, Map<String, String>> assetPreMedLetterMap = new Map<String, Map<String, String>> ();

		Map<String, String> pmlNameInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDiffInstMap = new Map<String, String> ();
		Map<String, String> pmlTransInstMap = new Map<String, String> ();
		Map<String, String> pmlFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlNameDocAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlTransFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> pmlTransNameDocAffirmationInstMap = new Map<String, String> ();

		Map<Id, Id> preMedAssetId = afmListsMap.get('preMedAssetId');

		for (Asset rec: assetList) {
			if (rec.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);

				pmlNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				if (rec.Name_on_Document_is_Different__c) {
					pmlNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}

				pmlTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				if (rec.Document_is_not_in_English__c) {
					pmlTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}

				if (rec.Id == preMedAssetId.get(rec.Contact_Association_Type_Staging__c)) {
					pmlFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					pmlNameDocAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					pmlTransFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					pmlTransNameDocAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
			}
		}
		// Pre Med Letter
		assetPreMedLetterMap.put('pmlNameInstMap', pmlNameInstMap);
		assetPreMedLetterMap.put('pmlNameDiffInstMap', pmlNameDiffInstMap);
		assetPreMedLetterMap.put('pmlTransInstMap', pmlTransInstMap);
		assetPreMedLetterMap.put('pmlFileAffirmationInstMap', pmlFileAffirmationInstMap);
		assetPreMedLetterMap.put('pmlNameDocAffirmationInstMap', pmlNameDocAffirmationInstMap);
		assetPreMedLetterMap.put('pmlTransFileAffirmationInstMap', pmlTransFileAffirmationInstMap);
		assetPreMedLetterMap.put('pmlTransNameDocAffirmationInstMap', pmlTransNameDocAffirmationInstMap);

		return assetPreMedLetterMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAssetTypeTCT
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map<String, Map<String, String>>
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRFAssetTypeTCT(Map<String, Map<Id, Id>> afmListsMap, List<Asset> assetList, Map<String, Map<String, String>> assetInstMap) {

		Map<String, Map<String, String>> assetTCTMap = new Map<String, Map<String, String>> ();

		Map<String, String> tctNameInstMap = new Map<String, String> ();
		Map<String, String> tctNameDiffInstMap = new Map<String, String> ();
		Map<String, String> tctTransInstMap = new Map<String, String> ();
		Map<String, String> tctFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> tctNameDocAffirmationInstMap = new Map<String, String> ();
		Map<String, String> tctTransFileAffirmationInstMap = new Map<String, String> ();
		Map<String, String> courceDetailsAffirmationInstMap = new Map<String, String> ();

		Map<Id, Id> courceDetailsAssetId = afmListsMap.get('courceDetailsAssetId');
		Map<Id, Id> tctAssetId = afmListsMap.get('tctAssetId');

		for (Asset rec: assetList) {
			if (rec.Type__c == Constants.ASSET_TYPE_TCT) {
				tctNameInstMap.put(rec.Contact_Association_Type_Staging__c, rec.Name_on_Document__c);
				if (rec.Name_on_Document_is_Different__c) {
					tctNameDiffInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}

				tctTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				tctFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'No');
				if (rec.Document_is_not_in_English__c) {
					tctTransInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
				if (rec.Id == tctAssetId.get(rec.Contact_Association_Type_Staging__c)) {
					tctFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					tctNameDocAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					tctTransFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
				if (rec.Id == courceDetailsAssetId.get(rec.Contact_Association_Type_Staging__c)) {
					courceDetailsAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					tctFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					tctNameDocAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
					tctTransFileAffirmationInstMap.put(rec.Contact_Association_Type_Staging__c, 'Yes');
				}
			}

		}

		assetTCTMap.put('tctNameInstMap', tctNameInstMap);
		assetTCTMap.put('tctNameDiffInstMap', tctNameDiffInstMap);
		assetTCTMap.put('tctTransInstMap', tctTransInstMap);
		assetTCTMap.put('tctFileAffirmationInstMap', tctFileAffirmationInstMap);
		assetTCTMap.put('tctNameDocAffirmationInstMap', tctNameDocAffirmationInstMap);
		assetTCTMap.put('tctTransFileAffirmationInstMap', tctTransFileAffirmationInstMap);
		assetTCTMap.put('courceDetailsAffirmationInstMap', courceDetailsAffirmationInstMap);

		return assetTCTMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAssetInstMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map<String, Map<String, String>>
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRFAssetInstMap(List<Asset> assetList) {
		Map<String, String> tctInstMap = new Map<String, String> ();
		Map<String, String> pmlInstMap = new Map<String, String> ();

		Map<String, Map<String, String>> assetListTCTMap = new Map<String, Map<String, String>> ();

		for (Asset assId: assetList) {
			if (assId.Type__c == Constants.ASSET_TYPE_TCT) {
				tctInstMap.put(assId.Contact_Association_Type_Staging__c, assId.Id);
			} else if (assId.Type__c == Constants.ASSET_TYPE_PRE_MED_LETTER) {
				pmlInstMap.put(assId.Contact_Association_Type_Staging__c, assId.Id);
			}
		}

		assetListTCTMap.put('tctInstMap', tctInstMap);
		assetListTCTMap.put('pmlInstMap', pmlInstMap);

		return assetListTCTMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAffListsMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map<String, Map<Id, Id>>
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<Id, Id>> getAssetsOtherMedicalRFAffListsMap(List<Affirmation__c > afmList) {
		Map<Id, Id> tctAssetId = new Map<Id, Id> ();
		Map<Id, Id> preMedAssetId = new Map<Id, Id> ();
		Map<Id, Id> courceDetailsAssetId = new Map<Id, Id> ();

		Map<String, Map<Id, Id>> afmListMap = new Map<String, Map<Id, Id>> ();

		String recordtypeTCTID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_TCT).getRecordTypeId();
		String recordtypeTCTPreMedID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_PRE_MED_LETTER).getRecordTypeId();

		for (Affirmation__c afm: afmList) {
			if (afm.TCT_Courses_Distinctly_Identified__c == 'No' && recordtypeTCTID == afm.RecordTypeId) {
				courceDetailsAssetId.put(afm.Contact_Association_Type_Staging__c, afm.Asset__c);
			}
			if ((afm.Acceptable_TCT_Submitted__c == 'No' || afm.TCT_Translation_Meets_Requirements__c == 'No' ||
					afm.Name_Documentation_Meets_Requirements__c == 'No') &&
				recordtypeTCTID == afm.RecordTypeId) {
				tctAssetId.put(afm.Contact_Association_Type_Staging__c, afm.Asset__c);
			} else if (afm.Pre_Med_letter_Meets_Requirements__c == 'No' && recordtypeTCTPreMedID == afm.RecordTypeId) {
				preMedAssetId.put(afm.Contact_Association_Type_Staging__c, afm.Asset__c);
			}
		}

		afmListMap.put('courceDetailsAssetId', courceDetailsAssetId);
		afmListMap.put('tctAssetId', tctAssetId);
		afmListMap.put('preMedAssetId', preMedAssetId);

		return afmListMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAffListsTCTMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map<String, Map<String, String>>
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, Map<String, String>> getAssetsOtherMedicalRFAffListsTCTMap(List<Affirmation__c > afmList) {
		Map<String, String> tctNameDocAffirmationLabInstMap = new Map<String, String> ();
		Map<String, String> tctTranslationAffirmationLabInstMap = new Map<String, String> ();

		Map<String, Map<String, String>> afmListTCTMap = new Map<String, Map<String, String>> ();

		String recordtypeTCTID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_TCT).getRecordTypeId();

		for (Affirmation__c afm: afmList) {
			if ((afm.Acceptable_TCT_Submitted__c == 'No' || afm.TCT_Translation_Meets_Requirements__c == 'No' ||
					afm.Name_Documentation_Meets_Requirements__c == 'No') &&
				recordtypeTCTID == afm.RecordTypeId) {
				if (afm.Name_Documentation_Meets_Requirements__c == 'No') {
					tctNameDocAffirmationLabInstMap.put(afm.Contact_Association_Type_Staging__c, 'Yes');
				}
				if (afm.TCT_Translation_Meets_Requirements__c == 'No') {
					tctTranslationAffirmationLabInstMap.put(afm.Contact_Association_Type_Staging__c, 'Yes');
				}
			}
		}

		afmListTCTMap.put('tctNameDocAffirmationLabInstMap', tctNameDocAffirmationLabInstMap);
		afmListTCTMap.put('tctTranslationAffirmationLabInstMap', tctTranslationAffirmationLabInstMap);

		return afmListTCTMap;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFInstitutionsList
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Contact_Association_Type_Staging__c List
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c > getAssetsOtherMedicalRFInstitutionsList(Boolean isExamReOpened) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		List<Contact_Association_Type_Staging__c > institutionsList = new List<Contact_Association_Type_Staging__c > ();
		if (isExamReOpened) {
			institutionsList = [SELECT Id, Account__c, Account_Name__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL)
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = TRUE
				ORDER BY createdDate ASC
			];
		} else {
			institutionsList = [SELECT Id, Account__c, Account_Name__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND(recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION OR recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL)
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = FALSE
				ORDER BY createdDate ASC
			];
		}
		return institutionsList;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFGraduateList
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Contact_Association_Type_Staging__c List
	 * @Params : Boolean isExamReOpened
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c > getAssetsOtherMedicalRFGraduateList(Boolean isExamReOpened) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		List<Contact_Association_Type_Staging__c > graduateList = new List<Contact_Association_Type_Staging__c > ();
		if (isExamReOpened) {
			graduateList = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = TRUE
			];
		} else {
			graduateList = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId
				AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Case__c =: caseId
				AND Is_Reopened_Exam_Reg__c = FALSE
			];
		}
		return graduateList;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAffRejection
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Affirmation__c List
	 * @Params : Boolean isExamReOpened, List Id
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Affirmation__c > getAssetsOtherMedicalRFAffRejection(Boolean isExamReOpened, List<Id> allAffmir) {
		List<Affirmation__c > affListForRejection = new List<Affirmation__c > ();
		if (isExamReOpened) {
			affListForRejection = [Select Id, Any_Other_Reason_To_Reject__c from Affirmation__c
				where Contact_Association_Type_Staging__c IN: allAffmir and Any_Other_Reason_To_Reject__c =: 'Yes'
				and Asset__r.IsOrphan__c = False and Asset__r.Is_Expired_Exam_Reg__c = False
			];
		} else {
			affListForRejection = [Select Id, Any_Other_Reason_To_Reject__c from Affirmation__c
				where Contact_Association_Type_Staging__c IN: allAffmir and Any_Other_Reason_To_Reject__c =: 'Yes'
				and Asset__r.IsOrphan__c = False and Asset__r.IsExpired__c = False
			];
		}
		return affListForRejection;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAffLists
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Affirmation__c List
	 * @Params : instIds
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Affirmation__c > getAssetsOtherMedicalRFAffLists(Boolean isExamReOpened, List<Id> instIds) {
		List<Affirmation__c > afmList = new List<Affirmation__c > ();
		if (isExamReOpened) {
			afmList = [SELECT Id, Asset__c, Acceptable_TCT_Submitted__c, TCT_Translation_Meets_Requirements__c,
				Name_Documentation_Meets_Requirements__c, Pre_Med_letter_Meets_Requirements__c,
				TCT_Courses_Passed__c, TCT_Courses_Distinctly_Identified__c, RecordTypeId, Contact_Association_Type_Staging__c
				from Affirmation__c where Contact_Association_Type_Staging__c IN: instIds
				and Asset__r.IsOrphan__c = False and Asset__r.Is_Expired_Exam_Reg__c = False
			];
		} else {
			afmList = [SELECT Id, Asset__c, Acceptable_TCT_Submitted__c, TCT_Translation_Meets_Requirements__c,
				Name_Documentation_Meets_Requirements__c, Pre_Med_letter_Meets_Requirements__c,
				TCT_Courses_Passed__c, TCT_Courses_Distinctly_Identified__c, RecordTypeId, Contact_Association_Type_Staging__c
				from Affirmation__c where Contact_Association_Type_Staging__c IN: instIds
				and Asset__r.IsOrphan__c = False and Asset__r.IsExpired__c = False
			];

		}
		return afmList;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getAssetsOtherMedicalRFAssetList
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Affirmation__c List
	 * @Params : instIds
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Asset> getAssetsOtherMedicalRFAssetList(Boolean isExamReOpened, List<Id> instIds) {
		List<Asset> assetList = new List<Asset> ();

		if (isExamReOpened) {
			assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c IN: instIds and IsOrphan__c = False and Is_Expired_Exam_Reg__c = False AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
			];
		} else {
			assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c IN: instIds and IsOrphan__c = False and IsExpired__c = False AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION Order By CreatedDate ASC
			];
		}
		return assetList;
	}
	// Method to return the files/Documents uploaded by applicant for the app For Cert Return Type : Map of strings with label and values
	public static Map<String, String> getGraduateOnlyRecordsForIncompleteCaseProcessing() {
		Map<String, String> returnValue = new Map<String, String> ();
		String fmdId = null,
			fmdFile = '',
			fmdName = '',
			fmdNameDiff = '',
			fmdNameDoc = '',
			fmdTransId = null,
			fmdTrans = '',
			fmdTransFile = '',
			fmdTransName = '',
			fmdTransNameDiff = '',
			fmdTransNameDoc = '';
		String dlId = null,
			dlFile = '',
			dlName = '',
			dlNameDiff = '',
			dlNameDoc = '',
			dlTransId = null,
			dlTrans = '',
			dlTransFile = '',
			dlTransName = '',
			dlTransNameDiff = '',
			dlTransNameDoc = '',
			dlDate = '';
		String ftId = null,
			ftFile = '',
			ftName = '',
			ftNameDiff = '',
			ftNameDoc = '',
			ftTransId = null,
			ftTrans = '',
			ftTransFile = '',
			ftTransName = '',
			ftTransNameDiff = '',
			ftTransNameDoc = '';
		String isDeanLetter = 'No',
			isFTReqd = 'No';
		String fmdFileName = '';
		String fmdNameDocName = '';
		String fmdTransFileName = '';
		String fmdTransNameDocName = '';
		String dlFileName = '';
		String dlNameDocName = '';
		String dlTransFileName = '';
		String dlTransNameDocName = '';
		String ftFileName = '';
		String ftNameDocName = '';
		String ftTransFileName = '';
		String ftTransNameDocName = '';
		String fmdFileType = '';
		String fmdNameDocType = '';
		String fmdTransFileType = '';
		String fmdTransNameDocType = '';
		String dlFileType = '';
		String dlNameDocType = '';
		String dlTransFileType = '';
		String dlTransNameDocType = '';
		String ftFileType = '';
		String ftNameDocType = '';
		String ftTransFileType = '';
		String ftTransNameDocType = '';
		String fmdNameId = '';
		String fmdTransNameId = '';
		String dlNameId = '';
		String dlTransNameId = '';
		String ftNameId = '';
		String ftTransNameId = '';
		Boolean isExamReOpened = AppForCertHelper.checkExamReopenedCase();
		List<Contact_Association_Type_Staging__c > degMeDSchoolRec = getIncompleteCaseProcessingRFCATS(isExamReOpened);
		List<Affirmation__c> afmList = new List<Affirmation__c> ();
		if (!degMeDSchoolRec.isEmpty()) {
			Id degMedSchoolId = degMeDSchoolRec[0].Id;
			afmList = getIncompleteCaseProcessingRFAffirmation(isExamReOpened, degMedSchoolId);
			if (!afmList.isEmpty()) {
				Boolean deanLetter = degMeDSchoolRec[0].IsDeanLetter__c;
				Boolean finalTranscriptReqd = degMeDSchoolRec[0].Account__r.Is_Final_Transcript_Required__c;
				List<Asset> assetList = getIncompleteCaseProcessingRFAssetLists(isExamReOpened, degMedSchoolId);
				// This method is created for avoiding SonarCloud issue
				Map<String, String> assetIdsMap = getGradAssetIds(deanLetter, finalTranscriptReqd, assetList);
				dlId = assetIdsMap.get('dlId');
				fmdId = assetIdsMap.get('fmdId');
				ftId = assetIdsMap.get('ftId');
				// This method is created for avoiding SonarCloud issue...Refactoring Methods
				// ASSET_TYPE_DEAN_LETTER
				if (deanLetter) {
					isDeanLetter = 'Yes';
					Map<String, String> assetDeanLetterMap = getGradDeanLetter(assetList, dlId);
					dlName = assetDeanLetterMap.get('dlName');
					dlNameDiff = assetDeanLetterMap.get('dlNameDiff');
					dlTrans = assetDeanLetterMap.get('dlTrans');
					dlTransId = assetDeanLetterMap.get('dlTransId');
					dlDate = assetDeanLetterMap.get('dlDate');
					dlTransName = assetDeanLetterMap.get('dlTransName');
					dlTransNameDiff = assetDeanLetterMap.get('dlTransNameDiff');
				} else {
					// ASSET_TYPE_FINAL_MED_DIPLOMA
					Map<String, String> asseMedDiplomaMap = getGradMedDiploma(assetList, fmdId);
					fmdName = asseMedDiplomaMap.get('fmdName');
					fmdNameDiff = asseMedDiplomaMap.get('fmdNameDiff');
					fmdTrans = asseMedDiplomaMap.get('fmdTrans');
					fmdTransId = asseMedDiplomaMap.get('fmdTransId');
					fmdTransName = asseMedDiplomaMap.get('fmdTransName');
					fmdTransNameDiff = asseMedDiplomaMap.get('fmdTransNameDiff');
				}
				// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
				if (finalTranscriptReqd) {
					isFTReqd = 'Yes';
					Map<String, String> assetTransscriptMap = getGradTranscript(assetList, ftId);
					ftName = assetTransscriptMap.get('ftName');
					ftNameDiff = assetTransscriptMap.get('ftNameDiff');
					ftTrans = assetTransscriptMap.get('ftTrans');
					ftTransId = assetTransscriptMap.get('ftTransId');
					ftTransName = assetTransscriptMap.get('ftTransName');
					ftTransNameDiff = assetTransscriptMap.get('ftTransNameDiff');
				}

				// Creating Map for Asset Trans Id
				Map<String, String> assetTransIdMap = new Map<String, String> ();
				assetTransIdMap.put('dlTransId', dlTransId);
				assetTransIdMap.put('fmdTransId', fmdTransId);
				assetTransIdMap.put('ftTransId', ftTransId);

				// This methods are created for avoiding SonarCloud issue
				List<Id> assetIds = getIncompleteCaseProcessingRFAssetIds(assetList);
				Map<Id, Asset> assetsMap = getIncompleteCaseProcessingRFAssetsMap(assetList);

				// Asset Name Document Record
				Map<String, String> asseNameDocRecMap = getIncompleteCaseProcessingRFAssetNameDocRec(assetList, assetIdsMap, assetTransIdMap);
				dlNameId = asseNameDocRecMap.get('dlNameId');
				dlTransNameId = asseNameDocRecMap.get('dlTransNameId');
				fmdNameId = asseNameDocRecMap.get('fmdNameId');
				fmdTransNameId = asseNameDocRecMap.get('fmdTransNameId');
				ftNameId = asseNameDocRecMap.get('ftNameId');
				ftTransNameId = asseNameDocRecMap.get('ftTransNameId');

				if (assetIds.size() > 0) {
					// This method is created for avoiding SonarCloud issue
					Map<String, String> assetFilesMap = getGraduateOnlyRecordsRefactorDocument(assetIdsMap, assetTransIdMap, deanLetter, finalTranscriptReqd, assetIds, assetsMap);

					// ASSET_TYPE_DEAN_LETTER
					dlFile = assetFilesMap.get('dlFile');
					dlFileName = assetFilesMap.get('dlFileName');
					dlFileType = assetFilesMap.get('dlFileType');
					dlNameDoc = assetFilesMap.get('dlNameDoc');
					dlNameDocName = assetFilesMap.get('dlNameDocName');
					dlNameDocType = assetFilesMap.get('dlNameDocType');
					dlTransFile = assetFilesMap.get('dlTransFile');
					dlTransFileName = assetFilesMap.get('dlTransFileName');
					dlTransFileType = assetFilesMap.get('dlTransFileType');
					dlTransNameDoc = assetFilesMap.get('dlTransNameDoc');
					dlTransNameDocName = assetFilesMap.get('dlTransNameDocName');
					dlTransNameDocType = assetFilesMap.get('dlTransNameDocType');
					// ASSET_TYPE_FINAL_MED_DIPLOMA
					fmdFile = assetFilesMap.get('fmdFile');
					fmdFileName = assetFilesMap.get('fmdFileName');
					fmdFileType = assetFilesMap.get('fmdFileType');
					fmdNameDoc = assetFilesMap.get('fmdNameDoc');
					fmdNameDocName = assetFilesMap.get('fmdNameDocName');
					fmdNameDocType = assetFilesMap.get('fmdNameDocType');
					fmdTransFile = assetFilesMap.get('fmdTransFile');
					fmdTransFileName = assetFilesMap.get('fmdTransFileName');
					fmdTransFileType = assetFilesMap.get('fmdTransFileType');
					fmdTransNameDoc = assetFilesMap.get('fmdTransNameDoc');
					fmdTransNameDocName = assetFilesMap.get('fmdTransNameDocName');
					fmdTransNameDocType = assetFilesMap.get('fmdTransNameDocType');
					// ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
					ftFile = assetFilesMap.get('ftFile');
					ftFileName = assetFilesMap.get('ftFileName');
					ftFileType = assetFilesMap.get('ftFileType');
					ftNameDoc = assetFilesMap.get('ftNameDoc');
					ftNameDocName = assetFilesMap.get('ftNameDocName');
					ftNameDocType = assetFilesMap.get('ftNameDocType');
					ftTransFile = assetFilesMap.get('ftTransFile');
					ftTransFileName = assetFilesMap.get('ftTransFileName');
					ftTransFileType = assetFilesMap.get('ftTransFileType');
					ftTransNameDoc = assetFilesMap.get('ftTransNameDoc');
					ftTransNameDocName = assetFilesMap.get('ftTransNameDocName');
					ftTransNameDocType = assetFilesMap.get('ftTransNameDocType');
				}

				returnValue.put('showGraduate', 'Yes');
				returnValue.put('fmdId', fmdId);
				returnValue.put('fmdFile', fmdFile);
				returnValue.put('fmdName', fmdName);
				returnValue.put('fmdNameDiff', fmdNameDiff);
				returnValue.put('fmdNameDoc', fmdNameDoc);
				returnValue.put('fmdTransId', fmdTransId);
				returnValue.put('fmdTrans', fmdTrans);
				returnValue.put('fmdTransFile', fmdTransFile);
				returnValue.put('fmdTransName', fmdTransName);
				returnValue.put('fmdTransNameDiff', fmdTransNameDiff);
				returnValue.put('fmdTransNameDoc', fmdTransNameDoc);
				returnValue.put('dlId', dlId);
				returnValue.put('dlFile', dlFile);
				returnValue.put('dlName', dlName);
				returnValue.put('dlNameDiff', dlNameDiff);
				returnValue.put('dlNameDoc', dlNameDoc);
				returnValue.put('dlTransId', dlTransId);
				returnValue.put('dlTrans', dlTrans);
				returnValue.put('dlTransFile', dlTransFile);
				returnValue.put('dlTransName', dlTransName);
				returnValue.put('dlTransNameDiff', dlTransNameDiff);
				returnValue.put('dlTransNameDoc', dlTransNameDoc);
				returnValue.put('dlDate', dlDate);
				returnValue.put('ftId', ftId);
				returnValue.put('ftFile', ftFile);
				returnValue.put('ftName', ftName);
				returnValue.put('ftNameDiff', ftNameDiff);
				returnValue.put('ftNameDoc', ftNameDoc);
				returnValue.put('ftTransId', ftTransId);
				returnValue.put('ftTrans', ftTrans);
				returnValue.put('ftTransFile', ftTransFile);
				returnValue.put('ftTransName', ftTransName);
				returnValue.put('ftTransNameDiff', ftTransNameDiff);
				returnValue.put('ftTransNameDoc', ftTransNameDoc);
				returnValue.put('isDeanLetter', isDeanLetter);
				returnValue.put('isFTReqd', isFTReqd);
				returnValue.put('fmdFileName', fmdFileName);
				returnValue.put('fmdNameDocName', fmdNameDocName);
				returnValue.put('fmdTransFileName', fmdTransFileName);
				returnValue.put('fmdTransNameDocName', fmdTransNameDocName);
				returnValue.put('dlFileName', dlFileName);
				returnValue.put('dlNameDocName', dlNameDocName);
				returnValue.put('dlTransFileName', dlTransFileName);
				returnValue.put('dlTransNameDocName', dlTransNameDocName);
				returnValue.put('ftFileName', ftFileName);
				returnValue.put('ftNameDocName', ftNameDocName);
				returnValue.put('ftTransFileName', ftTransFileName);
				returnValue.put('ftTransNameDocName', ftTransNameDocName);
				returnValue.put('fmdFileType', fmdFileType);
				returnValue.put('fmdNameDocType', fmdNameDocType);
				returnValue.put('fmdTransFileType', fmdTransFileType);
				returnValue.put('fmdTransNameDocType', fmdTransNameDocType);
				returnValue.put('dlFileType', dlFileType);
				returnValue.put('dlNameDocType', dlNameDocType);
				returnValue.put('dlTransFileType', dlTransFileType);
				returnValue.put('dlTransNameDocType', dlTransNameDocType);
				returnValue.put('ftFileType', ftFileType);
				returnValue.put('ftNameDocType', ftNameDocType);
				returnValue.put('ftTransFileType', ftTransFileType);
				returnValue.put('ftTransNameDocType', ftTransNameDocType);
				returnValue.put('fmdNameId', fmdNameId);
				returnValue.put('fmdTransNameId', fmdTransNameId);
				returnValue.put('dlNameId', dlNameId);
				returnValue.put('dlTransNameId', dlTransNameId);
				returnValue.put('ftNameId', ftNameId);
				returnValue.put('ftTransNameId', ftTransNameId);
			}
		}
		return returnValue;
	}
	// Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	@AuraEnabled(Cacheable = false)
	public static List<Contact_Association_Type_Staging__c> getIncompleteCaseProcessingRFCATS(Boolean isExamReOpened) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();		
		Id caseId = AppForCertHelper.getCaseId();		
		List<Contact_Association_Type_Staging__c> degMeDSchoolRec = new List<Contact_Association_Type_Staging__c > ();
		if(isExamReOpened){
			degMeDSchoolRec = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: caseId AND Is_Reopened_Exam_Reg__c = TRUE
			];
		}else{
			degMeDSchoolRec = [SELECT Id, IsDeanLetter__c, Account__r.Is_Final_Transcript_Required__c FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL
				AND Parent_Case__c =: caseId AND Is_Reopened_Exam_Reg__c = FALSE
			];
		}
		return degMeDSchoolRec;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getIncompleteCaseProcessingAffirmation
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Affirmation List
	 * @Params : Boolean, Id
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Affirmation__c > getIncompleteCaseProcessingRFAffirmation(Boolean isExamReOpened, Id degMedSchoolId) {
		List<Affirmation__c > afmList = new List<Affirmation__c > ();
		String recordtypeCVID = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();

		if (isExamReOpened) {
			afmList = [SELECT Id, Asset__c, Credential_Verification_Status__c, RecordTypeId, Contact_Association_Type_Staging__c
				from Affirmation__c where Contact_Association_Type_Staging__c =: degMedSchoolId
				and Credential_Verification_Status__c =: Constants.CASE_STATUS and recordtypeId =: recordtypeCVID
				and Asset__r.IsOrphan__c = False and Asset__r.Is_Expired_Exam_Reg__c = False
			];
		} else {
			afmList = [SELECT Id, Asset__c, Credential_Verification_Status__c, RecordTypeId, Contact_Association_Type_Staging__c
				from Affirmation__c where Contact_Association_Type_Staging__c =: degMedSchoolId
				and Credential_Verification_Status__c =: Constants.CASE_STATUS and recordtypeId =: recordtypeCVID
				and Asset__r.IsOrphan__c = False and Asset__r.IsExpired__c = False
			];

		}
		return afmList;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getIncompleteCaseProcessingRFAssetLists
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map of strings with label and values
	 * @Params : Boolean value determining whether redirected from Exam Registration
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Asset> getIncompleteCaseProcessingRFAssetLists(Boolean isExamReOpened, Id degMedSchoolId) {
		List<Asset> assetList = new List<Asset> ();
		if (isExamReOpened) {
			assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c =: degMedSchoolId and IsOrphan__c = False and Is_Expired_Exam_Reg__c = False AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION order by createdDate Asc
			];
		} else {
			assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c =: degMedSchoolId and IsOrphan__c = False and IsExpired__c = False AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION order by createdDate Asc
			];
		}
		return assetList;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getIncompleteCaseProcessingAssetNameDocRec
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Map // Id and Names
	 * @Params : Boolean, Id
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<String, String> getIncompleteCaseProcessingRFAssetNameDocRec(List<Asset> assetList, Map<String, String> assetIdsMap, Map<String, String> assetTransIdMap) {
		String dlNameId = '';
		String dlTransNameId = '';
		String fmdNameId = '';
		String fmdTransNameId = '';
		String ftNameId = '';
		String ftTransNameId = '';

		String dlId = assetIdsMap.get('dlId');
		String fmdId = assetIdsMap.get('fmdId');
		String ftId = assetIdsMap.get('ftId');

		String dlTransId = assetTransIdMap.get('dlTransId');
		String fmdTransId = assetTransIdMap.get('fmdTransId');
		String ftTransId = assetTransIdMap.get('ftTransId');

		Map<String, String> assetRecordMap = new Map<String, String> ();
		for (Asset nameDocRec: assetList) {
			if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == dlId) {
				dlNameId = nameDocRec.Id;
			} else if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == dlTransId) {
				dlTransNameId = nameDocRec.Id;
			} else if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == fmdId) {
				fmdNameId = nameDocRec.Id;
			} else if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == fmdTransId) {
				fmdTransNameId = nameDocRec.Id;
			} else if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == ftId) {
				ftNameId = nameDocRec.Id;
			} else if (nameDocRec.Type__c == Constants.ASSET_TYPE_NAME_DOC && nameDocRec.ParentId == ftTransId) {
				ftTransNameId = nameDocRec.Id;
			}
		}

		assetRecordMap.put('dlNameId', dlNameId);
		assetRecordMap.put('dlTransNameId', dlTransNameId);
		assetRecordMap.put('fmdNameId', fmdNameId);
		assetRecordMap.put('fmdTransNameId', fmdTransNameId);
		assetRecordMap.put('ftNameId', ftNameId);
		assetRecordMap.put('ftTransNameId', ftTransNameId);

		return assetRecordMap;
	}
	/**
	 * Created : Ajoydhas
	 * Method Name: getIncompleteCaseProcessingRFAssetIds
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : List Ids
	 * @Params : Asset List 
	 */
	@AuraEnabled(Cacheable = false)
	public static List<Id> getIncompleteCaseProcessingRFAssetIds(List<Asset> assetList) {
		List<Id> assetIds = new List<Id> ();
		for (Asset rec: assetList) {
			assetIds.add(rec.Id);
		}
		return assetIds;
	}

	/**
	 * Created : Ajoydhas
	 * Method Name: getIncompleteCaseProcessingRFAssetsMap
	 * Purpose : Method to avoiding SonarCloud Issue Fixes (Refactor issue fixes)
	 * Return Type : Asset Map
	 * @Params : Asset List 
	 */
	@AuraEnabled(Cacheable = false)
	public static Map<Id, Asset> getIncompleteCaseProcessingRFAssetsMap(List<Asset> assetList) {
		Map<Id, Asset> assetsMap = new Map<Id, Asset> ();
		for (Asset rec: assetList) {
			assetsMap.put(rec.Id, rec);
		}
		return assetsMap;
	}

	//Method to create assets for incomplete case
   @AuraEnabled
   public static Map<String, Map<String, String>> createAssetForIncompleteCaseProcessing(String contentDocId, String assetId, String type, String contactAssociationStagingId, String keyval) {

	   String contactAssociationType = contactAssociationStagingId;
	   String caseId = getCaseId();
	   String contactId = getContactId();

	   List<Asset> existingAssetList = new List<Asset> ();
	   Map<String, Map<String, String>> returnValMapFinal = new Map<String, Map<String, String>> ();
	   if (!String.isBlank(assetId)) {
		   existingAssetList = [Select Id, Name, Type__c, Status, Case__c, Key__c, Parent_Key__c, ParentId, ContactId,
			   Contact_Association_Type_Staging__c, RecordTypeId, Document_is_not_in_English__c,
			   Name_on_Document__c, Name_on_Document_is_Different__c
			   from Asset where Id =: assetId
			   AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
		   ];
	   }

	   Asset a;

	   if (!existingAssetList.isEmpty()) {

		   List<Asset> delexistingOrphanAssetList = new List<Asset> ();
		   delexistingOrphanAssetList = [Select Id from Asset where Name =: existingAssetList[0].Name and Case__c =: existingAssetList[0].Case__c
			   and Contact_Association_Type_Staging__c =: existingAssetList[0].Contact_Association_Type_Staging__c
			   and RecordTypeId =: existingAssetList[0].RecordTypeId
			   and ParentId =: existingAssetList[0].ParentId and IsOrphan__c = True
			   AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
		   ];

		   if (!delexistingOrphanAssetList.isEmpty()) {
			   delete delexistingOrphanAssetList;
		   }

		   a = new Asset();
		   a.Name = existingAssetList[0].Name;
		   a.Type__c = existingAssetList[0].Type__c;
		   a.Status = existingAssetList[0].Status;
		   a.Case__c = existingAssetList[0].Case__c;
		   a.Key__c = existingAssetList[0].Key__c;
		   a.Parent_Key__c = existingAssetList[0].Parent_Key__c;
		   a.Contact_Association_Type_Staging__c = existingAssetList[0].Contact_Association_Type_Staging__c;
		   a.RecordTypeId = existingAssetList[0].RecordTypeId;
		   a.IsOrphan__c = True;
		   a.ContactId = existingAssetList[0].ContactId;
		   a.Name_on_Document__c = existingAssetList[0].Name_on_Document__c;
		   a.Name_on_Document_is_Different__c = existingAssetList[0].Name_on_Document_is_Different__c;
		   a.Document_is_not_in_English__c = existingAssetList[0].Document_is_not_in_English__c;
		   if (existingAssetList[0].ParentId != null) {
			   a.ParentId = existingAssetList[0].ParentId;
		   }

		   insert a;

	   } else {
		   String nameValue = '';
		   if (type == constants.ASSET_TYPE_DEAN_LETTER) {
			   nameValue = constants.ASSET_NAME_DEAN_LETTER;
		   } else {
			   nameValue = type;
		   }
		   a = new Asset();
		   a.Name = nameValue;
		   a.Type__c = type;
		   a.Status = Constants.ASSET_STATUS_IN_PROGRESS;
		   a.Case__c = caseId;
		   a.ContactId = contactId;
		   a.Contact_Association_Type_Staging__c = contactAssociationType;
		   a.IsOrphan__c = TRUE;
		   a.key__c = keyval;
		   a.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
		   insert a;

	   }

	   if (a != null) {
		   returnValMapFinal = createAssetForIncompleteCaseProcessingRefactorContinue(contentDocId, a);
	   }

	   return returnValMapFinal;

   }

   //Continuation of createAssetForIncompleteCaseProcessing Method to create assets for incomplete case
   @AuraEnabled
   public static Map<String, Map<String, String>> createAssetForIncompleteCaseProcessingRefactorContinue(String contentDocId, Asset a) {

	   String fileName = '';
	   String fileType = '';
	   String fileURL = '';
	   Map<String, String> assetMap = new Map<String, String> ();
	   Map<String, Map<String, String>> returnValMap = new Map<String, Map<String, String>> ();
	   List<ContentDocumentLink> cdlList = new List<ContentDocumentLink> ();
	   ContentDocumentLink cdlAsset = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = a.Id, ShareType = 'I', Visibility = 'AllUsers');
	   cdlList.add(cdlAsset);
	   ContentDocumentLink cdlContact = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = a.ContactId, ShareType = 'I', Visibility = 'AllUsers');
	   cdlList.add(cdlContact);
	   ContentDocumentLink cdlContactAssociationTypeStaging = new ContentDocumentLink(ContentDocumentId = contentDocId, LinkedEntityId = a.Contact_Association_Type_Staging__c, ShareType = 'I', Visibility = 'AllUsers');
	   cdlList.add(cdlContactAssociationTypeStaging);

	   insert cdlList;
	   List<ContentDocument> conDocList = new List<ContentDocument> ();

	   if (contentdocId != null) {
		   conDocList = [Select Id, Title, FileType from ContentDocument where Id =: contentdocId];
		   if (!conDocList.isEmpty()) {
			   fileURL = Constants.FILE_DOWNLOAD_URL + conDocList[0].Id;
			   fileType = conDocList[0].FileType;
			   fileName = conDocList[0].Title;
		   }
	   }

	   assetMap.put('assetId', a.Id);
	   assetMap.put('fileName', fileName);
	   assetMap.put('fileType', fileType);
	   assetMap.put('fileUrl', fileURL);
	   assetMap.put('assetNameDoc', a.Name_on_Document__c);
	   if (a.Document_is_not_in_English__c) {
		   assetMap.put('assetNameDocnotinEnglish', 'Yes');
	   } else {
		   assetMap.put('assetNameDocnotinEnglish', 'No');
	   }
	   if (a.Name_on_Document_is_Different__c) {
		   assetMap.put('assetNameDocDifferent', 'Yes');
	   } else {
		   assetMap.put('assetNameDocDifferent', 'No');
	   }
	   returnValMap.put(a.Contact_Association_Type_Staging__c, assetMap);

	   return returnValMap;
   }

	// Method to update details for incomplete case 	 
	@AuraEnabled
	public static Boolean saveIncompleteRecords(String values, String caseId) {
		Map<String, String> assetTypeMap = new Map<String, String> ();
		Set<String> stagingIds = new Set<String> ();
		Set<String> existingAssetType = new Set<String> ();
		Boolean isExamReOpened = AppForCertHelper.checkExamReopenedCase();
		List<AppForCertHelper.incompleteSchoolObjWrapper> wrappedObjList = (List<AppForCertHelper.incompleteSchoolObjWrapper>) JSON.deserialize(values, List<AppForCertHelper.incompleteSchoolObjWrapper > .class);
		List<Transfer_Credit__c> tcsToUpsert = new List<Transfer_Credit__c> ();
		List<Asset> assetsToUpdate = new List<Asset> ();
		Set<String> allAssetId = new Set<String> ();
		List<String> allAssetSet = new List<String> ();
		List<Asset> expiredAssetList = new List<Asset> ();
		Set<String> delStagingIds = new Set<String> ();
		Boolean returnval = false;
		Set<String> tcDelStagingId = new Set<String> ();
		for (AppForCertHelper.incompleteSchoolObjWrapper jsObj: wrappedObjList) {
			if (!String.isBlank(jsObj.recordIdVal)) {
				Contact_Association_Type_Staging__c tempContAssoTypeStag = new Contact_Association_Type_Staging__c(id = jsObj.recordIdVal);
				delStagingIds.add(jsObj.recordIdVal);
				AppForCertHelper.TcredObjWrapper tcResponse = updateTrasferCredit(jsObj, caseId);
				tcsToUpsert.addAll(tcResponse.tcsToUpsert);
				tcDelStagingId.addAll(tcResponse.tcDelStagingId);
				AppForCertHelper.AssetObjctWrapper updateAsset = updateAssetList(jsObj, tempContAssoTypeStag);
				stagingIds.addAll(updateAsset.stagingIds);
				allAssetSet.addAll(updateAsset.allAssetSet);
				allAssetId.addAll(updateAsset.allAssetId);
				assetsToUpdate.addAll(updateAsset.assetsToUpdate);
			}
		}
		if (!assetsToUpdate.isEmpty()) {
			update assetsToUpdate;
			returnval = true;
		}
		//To change the TCT's Name Document,Translation to Expired
		//Get asset type for all Assets
		for (Asset a: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Contact_Association_Type_Staging__c IN: stagingIds
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			assetTypeMap.put(a.Id, a.Type__c);
		}
		existingAssetType.addAll(getExistingAssetType(allAssetId, caseId, assetTypeMap));
		List<Asset> tctMarkNameTransToExpList = new List<Asset> ();
		if (isExamReOpened) {
			tctMarkNameTransToExpList = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Contact_Association_Type_Staging__c IN: stagingIds and Id Not IN: allAssetId and Is_Expired_Exam_Reg__c = False
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		} else {
			tctMarkNameTransToExpList = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Contact_Association_Type_Staging__c IN: stagingIds and Id Not IN: allAssetId and IsExpired__c = False
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		expiredAssetList.addAll(getExpiredAssetList(tctMarkNameTransToExpList, existingAssetType, isExamReOpened, assetTypeMap));
		//To change the entire TCT assets to Expired
		expiredAssetList.addAll(getExpiredAssets(allAssetId, caseId, isExamReOpened));
		//Change all assets to expired except TCT
		expiredAssetList.addAll(getExpiredAssetsExptTct(allAssetId, caseId, isExamReOpened));
		updateExpiredAssets(expiredAssetList);
		dltOrphanedAssets(delStagingIds, isExamReOpened);
		updateIncompleteAssets(tcsToUpsert, tcDelStagingId, isExamReOpened, caseId);
		if (String.isNotBlank(caseId)) {
			AppForCertHelper.updateIncompleteCaseStatus(caseId);
			returnval = true;
		}
		return returnval;
	}

	/**
	 * Created by Balashankar
	 * Method Name: getIncompleteCase
	 * Purpose : method to get incomplete case id
	 * Return Type : String
	 */
	@AuraEnabled(Cacheable = true)
	public static Boolean getIncompleteCase() {

		Boolean returnVal = false;
		String caseVal = '';
		caseVal = AppForCertHelper.getCaseId();

		List<case >caseList = new List<case >();
		caseList = [Select Id, Internal_Status__c from
			case where Id =:
			caseVal and Internal_Status__c =: constants.CASE_STATUS WITH SECURITY_ENFORCED
		];
		if (!caseList.isEmpty()) {
			returnVal = true;
		}

		return returnVal;
	}

	// AppForCert - Method to check the validation for updating the case status during complete payment
	@AuraEnabled(Cacheable = false)
    public static Boolean paymentCompletion(){
        String currentContactAssociatonTypeMedSchool = '';
        String currentCaseId = '';
        String currentContactId = '';
        Boolean graduate = false;
        Boolean transferCredits = false;
        Boolean returnVal = false;
        Boolean showExamRegActionButton = false;
		currentCaseId = AppForCertHelper.getCaseId();
        currentContactId = AppForCertHelper.retrieveCurrentContactId();
        currentContactAssociatonTypeMedSchool = AppForCertHelper.getContactAssociationTypeStaging(showExamRegActionButton, currentCaseId, currentContactId);        
        String conId = '';
        conId = currentContactId;
        List<Case> caseList = new List<Case> ();
        Case newCase = [SELECT id, Graduate_affirmation_required__c, Transfer_credit_affirmation_required__c, 
						Internal_Status__c, RecordTypeId, RecordType.DeveloperName FROM Case 
						WHERE Case.Id =: currentCaseId LIMIT 1];
						system.debug('newCase.Internal_Status__c');
						system.debug(newCase.Internal_Status__c);
        newCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED;
        if(Case.SObjectType.getDescribe().isUpdateable()){
            update newCase;
        }
        List<Contact_Association_Type_Staging__c> allInstitutions = new List<Contact_Association_Type_Staging__c>();
            allInstitutions = [Select Id, Name, Contact__r.Id, Contact__r.is_CIBIS_Origin__c, Case__r.Id, Status__c, RecordType.Name, RecordType.DeveloperName, Case__r.Graduate_affirmation_required__c, Case__r.Transfer_credit_affirmation_required__c, Transfer_Credit_to_Degree_School__c from Contact_Association_Type_Staging__c where Contact__r.Id =: currentContactId AND Case__r.Id =: currentCaseId];
        system.debug('allInstitutions');
		system.debug(allInstitutions);
			for(Contact_Association_Type_Staging__c cats: allInstitutions){
				system.debug('cats.RecordType.DeveloperName');
				system.debug(cats.RecordType.DeveloperName);
            if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL && cats.Status__c == Constants.CONASCTYPESTG_STATUS_GRADUATE) {
                system.debug('CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL');
				newCase.Graduate_affirmation_required__c = true;
                graduate = True;
            } else if ((cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL && cats.Transfer_Credit_to_Degree_School__c == true) || cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION) {
                newCase.Transfer_credit_affirmation_required__c = true;
                transferCredits = True;
            }
        }
		system.debug('graduate');
		system.debug(graduate);
		system.debug('transferCredits');
		system.debug(transferCredits);
        if(graduate == True || transferCredits == True){
            newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
            caseList.add(newCase);
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group
                       WHERE Type = 'Queue'
                       and Group.DeveloperName =: Constants.QUEUE_APP_FOR_CERT
                      ];
            newCase.OwnerId = g.Id;
            returnVal = true;
        }else if(graduate == False && transferCredits == False){
			system.debug('allInstitutions.isEmpty()');
			system.debug(allInstitutions.isEmpty());
			system.debug('allInstitutions[0].Contact__r.is_CIBIS_Origin__c');            
			system.debug(allInstitutions[0].Contact__r.is_CIBIS_Origin__c);
			system.debug('conId');
			system.debug(conId);
            // added cibis component to update Cibis with App for cert latest Information
            if(!allInstitutions.isEmpty() && !allInstitutions[0].Contact__r.is_CIBIS_Origin__c && conId <> null && conId != ''){
                newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
				newcase.External_Status__c=Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
			}else{
				system.debug('newCase.Internal_Status__c');
				system.debug(newCase.Internal_Status__c);
                newCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
            }
            caseList.add(newCase);
            sendMailForAcceptedStatus(currentContactId, currentCaseId);
            returnVal = true;
        }
        if(Case.SObjectType.getDescribe().isUpdateable()){
            update caseList;
		}
        //create CV case
        AppForCertHelper.creatCVCaseForAppForCert(showExamRegActionButton, currentCaseId, currentContactId);		
		//AppForCert Summary PDF	
		List<cadmus_core__Doc_Config__c> docConfigList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE Name = 'AppForCert Summary' WITH SECURITY_ENFORCED];
        Id docConfigId = docConfigList[0].Id;				
		if(String.isNotBlank(docConfigId)){
			PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, currentCaseId);
			System.enqueueJob(calloutClass);
		}
        return returnVal;
    }

	/**
	 * Created by Chinmay
	 * Modified by AJOYDHAS.M.A
	 * Method Name: getDegreeRecords
	 * Purpose : Method to get the list of degrees provided by selected graduation year
	 * Parameters : entityId (School ID) and Year (Graduation Year)
	 * Return Type : List<String>
	 */
	@AuraEnabled(Cacheable = true)
	public static List<Degree__c > getDegreeRecords(Id entityId, String graduationYear) {
		list<Object2Degree__c > obj2degList = new list<Object2Degree__c > ();
		obj2degList = [SELECT Degree__c FROM Object2Degree__c
			WHERE Account__c =: entityId
			AND Graduation_Year__c =: graduationYear
		];

		list<id> degreeIdList = new list<id> ();

		for (Object2Degree__c iter: obj2degList) {
			degreeIdList.add(iter.Degree__c);
		}
		return [SELECT Id, Name FROM Degree__c WHERE id IN: degreeIdList];
	}
	/**
	 * Created by Chinmay
	 * Modified by AJOYDHAS.M.A
	 * Method Name: getGradYearValues
	 * Purpose : To get the Graduation Years from the School based on the selected Degree School
	 * Parameters : entityId (Degree School Id)
	 * Return Type : List<String>
	 */
	@AuraEnabled(Cacheable = true)
	public static List<String> getGradYearValues(Id entityId) {
		list<Object2Degree__c > obj2degList = new list<Object2Degree__c > ();
		obj2degList = [SELECT Graduation_Year__c
			FROM Object2Degree__c
			WHERE Account__c =: entityId
			ORDER BY Graduation_Year__c ASC
		];

		SET<String> gradYearsSet = new SET<String> ();

		for (Object2Degree__c iter: obj2degList) {
			gradYearsSet.add(iter.Graduation_Year__c);
		}

		List<String> gradYearsList = new List<String> (gradYearsSet);
		return gradYearsList;
	}
	/**
	 * Created by Chinmay
	 * Modified by AJOYDHAS.M.A
	 * Method Name: errorMessageGraduationDate
	 * Purpose : Method to send error message if the graduation date is less than TO date
	 * Parameters : entityId (Degree School Id)
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageGraduationDate(String gradYear, String gradMonth, Date toDate) {
		Boolean returnVal = false;
		if (gradYear != null && gradMonth != null && toDate != null) {
			list<String> lstSplitDate = String.valueOf(toDate).split('-');
			Integer graduationMonth = AppForCertHelper.convertMonthTextToNumber(gradMonth);
			Integer graduationYear = Integer.valueOf(gradYear);
			Integer toDateYear = Integer.valueOf(lstSplitDate[0]);
			Integer toDateMonth = Integer.valueOf(lstSplitDate[1]);
			if (graduationYear<toDateYear) {
				returnVal = true;
			} else if (graduationYear == toDateYear && graduationMonth<toDateMonth) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: errorMessageDegreeIssueDate
	 * Purpose : Method to send error message if the degree issue date is less than End date
	 * Parameters : EndYear, EndMonth & Degree Issue Month & Degree Issue Year
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageDegreeIssueDate(String endMonth, String endYear, String degIssueMonth, String degIssueYear) {
		Boolean returnVal = false;
		if (endYear != null && endMonth != null && endYear != '' && endMonth != '' && degIssueMonth != null && degIssueYear != null && degIssueMonth != '' && degIssueYear != '') {
			//list<String> lstSplitDate = String.valueOf(degIssueDate).split('-');
			Integer iEndMonth = AppForCertHelper.convertMonthTextToNumber(endMonth);
			Integer iEndYear = Integer.valueOf(endYear);
			Integer iDegIssueYear = Integer.valueOf(degIssueYear);
			Integer iDegIssueMonth = AppForCertHelper.convertMonthTextToNumber(degIssueMonth);

			Date attendanceEndDate = Date.newInstance(iEndYear, iEndMonth, 01);
			Date degreeDate = Date.newInstance(iDegIssueYear, iDegIssueMonth, 01);

			if (attendanceEndDate > degreeDate) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: errorMessageNewGraduationDate
	 * Purpose : Method to send error message if the graduation date is less than New End date
	 * Parameters : String gradMonth, String gradYear, String endMonth, String endYear
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageNewGraduationDate(String gradMonth, String gradYear, String endMonth, String endYear) {
		Boolean returnVal = false;
		if (gradMonth != null && gradYear != null && gradMonth != '' && gradYear != '' && endMonth != null && endYear != null && endMonth != '' && endYear != '') {
			Integer graduationMonth = AppForCertHelper.convertMonthTextToNumber(gradMonth);
			Integer graduationYear = Integer.valueOf(gradYear);
			Integer endDateMonth = AppForCertHelper.convertMonthTextToNumber(endMonth);
			Integer endDateYear = Integer.valueOf(endYear);

			if (graduationYear<endDateYear) {
				returnVal = true;
			} else if (graduationYear == endDateYear && graduationMonth<endDateMonth) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: errorMessageNewCurrentDate
	 * Purpose : Method to send error message if current date is not between start and end dates
	 * Parameters : String startYear, String startMonth, String endYear, String endMonth
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageNewCurrentDate(String type, String startMonth, String startYear, String endMonth, String endYear) {
		Boolean returnVal = false;
		Date currentDate = Date.Today();
		Integer currentYear = currentDate.year();

		if (startMonth != null && startYear != null && startMonth != '' && startYear != '' && endMonth != null && endYear != null && endMonth != '' && endYear != '') {
			Integer startDateYear = Integer.valueOf(startYear);
			Integer endDateYear = Integer.valueOf(endYear);
			Integer sMonth = Integer.valueOf(startMonth);
			Integer eMonth = Integer.valueOf(endMonth);
			Date sDate = Date.newInstance(startDateYear, sMonth, 01);
			Date eDate = Date.newInstance(endDateYear, eMonth, 01);
			eDate = eDate.addMonths(1); // Add a month for grace period (story 9958)

			/* if (type != '' && type == System.Label.Medical_Education_type_Student && (startDateYear > currentYear || endDateYear<currentYear)) {
			    returnVal = true;
			} */
			if (type != '' && sDate != null && eDate != null && type == System.Label.Medical_Education_type_Student && (sDate > currentDate || eDate<= currentDate)) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: startAndEndDateValidation
	 * Purpose : Method to send error message if current date is not between start and end dates
	 * Parameters : String startYear, String startMonth, String endYear, String endMonth
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean startAndEndDateValidation(String startMonth, String startYear, String endMonth, String endYear) {
		Boolean returnVal = false;
		Date currentDate = Date.Today();
		String strStartDate = '';
		String strEndDate = '';
		if (startMonth != null && startYear != null && startMonth != '' && startYear != '' && endMonth != null && endYear != null && endMonth != '' && endYear != '') {
			//construct start and end dates
			//get integer of the month
			Integer startDateMonth = AppForCertHelper.convertMonthTextToNumber(startMonth);
			Integer startDateYear = Integer.valueOf(startYear);
			Integer endDateMonth = AppForCertHelper.convertMonthTextToNumber(endMonth);
			Integer endDateYear = Integer.valueOf(endYear);

			//strStartDate = startYear+'-'+startMonth+'-'+Constants.CONASCTYPE_START_END_DAY;
			//strEndDate = endYear+'-'+endMonth+'-'+Constants.CONASCTYPE_START_END_DAY;
			strStartDate = startDateYear + '-' + startDateMonth + '-' + Constants.CONASCTYPE_START_END_DAY;
			strEndDate = endDateYear + '-' + endDateMonth + '-' + Constants.CONASCTYPE_START_END_DAY;

			Date startDate = date.valueOf(strStartDate);
			Date endDate = date.valueOf(strEndDate);
			if (startDate > currentDate || endDate >= currentDate) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	/**
	 * Created by Shailaja Yerneni
	 * Method Name: errorMessageNewStartDateEndDate
	 * Purpose : Method to send error message if the Start date is greater than End date
	 * Parameters : String startYear, String startMonth, String endYear, String endMonth
	 * Return Type : Boolean (true or false)
	 */
	@AuraEnabled(cacheable = true)
	public static Boolean errorMessageNewStartDateEndDate(String startMonth, String startYear, String endMonth, String endYear) {
		Boolean returnVal = false;
		if (startYear != null && startMonth != null && startYear != '' && startMonth != '' && endYear != null && endMonth != null && endYear != '' && endMonth != '') {
			Integer startDateMonth = AppForCertHelper.convertMonthTextToNumber(startMonth);
			Integer startDateYear = Integer.valueOf(startYear);
			Integer endDateMonth = AppForCertHelper.convertMonthTextToNumber(endMonth);
			Integer endDateYear = Integer.valueOf(endYear);

			if (endDateYear<startDateYear) {
				returnVal = true;
			} else if (startDateYear == endDateYear && endDateMonth<= startDateMonth) {
				returnVal = true;
			}
		}
		return returnVal;
	}

	@AuraEnabled(cacheable = true)
	public static Constants getAllConstants() {
		return new Constants();
	}
	// Delete the record in Contact Association Type Staging. Record Type - Exam Registration - Degree Medical School
	@AuraEnabled
	public static String deleteExamRegRecordTypeRecords(){
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		String caseId = AppForCertHelper.getCaseId();
		String returnFlag = 'false';
		if(contactId != null){
			SET<String> recordTypeDeveloperName = new SET<String> ();
			recordTypeDeveloperName.add(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG);
			recordTypeDeveloperName.add(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG);
			recordTypeDeveloperName.add(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG);

			List<Contact_Association_Type_Staging__c > degMedSchoolLists =
				new List<Contact_Association_Type_Staging__c > ([SELECT Id
					FROM Contact_Association_Type_Staging__c
					WHERE Contact__c =: contactId
					AND Case__c =: caseId
					AND recordType.DeveloperName IN: recordTypeDeveloperName
				]);

			List<Contact_Association_Type_Staging__c > degMedSchoolDel = new List<Contact_Association_Type_Staging__c > ();

			for (Contact_Association_Type_Staging__c tempconAssocStag: degMedSchoolLists) {
				degMedSchoolDel.add(tempconAssocStag);
			}

			// Delete Graduate Assets
			String currentContactAssociatonTypeId = '';
			Boolean showExamRegActionButton = true;
			Boolean showCaseDetail = false;
			Boolean isGraduate = isApplicantGraduate(showExamRegActionButton, showCaseDetail);
			if (isGraduate) {
				currentContactAssociatonTypeId = AppForCertHelper.getContactAssociationTypeStaging(showExamRegActionButton, caseId, contactId);
				deleteGraduateAssets(contactId, currentContactAssociatonTypeId);
			}
			try {
				DELETE degMedSchoolDel;
				returnFlag = 'true';
				markTctAssetsForDeletion(contactId, caseId);
				AppForCertHelper.markPmlAssetsForDeletion(contactId, caseId);
			} catch (exception e) {
				returnFlag = String.valueOf(e);
			}
		}
		return returnFlag;
	}
	/**
	 * Created by Ajoydhas
	 * Method Name: deleteGraduateAssets
	 * Purpose : Method to delete All Assets and related content document in Graduate Sections
	 * Return Type : no return type
	 */
	public static void deleteGraduateAssets(String contactId, String contactAssociationTypeStagingId) {
		Map<String, String> keyAssetMap = new Map<String, String> ();
		Set<String> keySet = new Set<String> {
			System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_TRANSLATION_NAME_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_NAME_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_NAME_DOCUMENT
		};

		for (Asset a: [SELECT Id, key__c, Type__c, Contact_Association_Type_Staging__c, Parent_Key__c, ParentId, Contact_Association_Type__c
				from Asset WHERE contactId =: contactId and key__c IN: keySet AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			keyAssetMap.put(a.key__c, a.Id);
		}

		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DIPLOMA_TRANSLATION_NAME_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_NAME_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT, contactAssociationTypeStagingId);
		deleteAssetAndRelatedDocument(contactId, System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_NAME_DOCUMENT, contactAssociationTypeStagingId);
	}

	//Purpose : Method to get Dean's letter date
	@AuraEnabled(cacheable = false)
	public static Date getDlDate() {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<Asset> assetList = new List<Asset>();
		assetList = [Select Id, Dean_s_Letter_Date__c
			from Asset where ContactId =: contactId AND Type__c =: Constants.ASSET_NAME_DEAN_LETTER AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY createdDate DESC
		];
		return assetList[0].Dean_s_Letter_Date__c;
	}

	//Purpose : Method to get Dean's letter date
	@AuraEnabled(cacheable = false)
	public static Date getDlDateForExistingCAT(string contactAssociationType) {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<Asset> assetList = new List<Asset>();
		assetList = [SELECT Id, Dean_s_Letter_Date__c
			FROM Asset WHERE ContactId =: contactId AND Type__c =: Constants.ASSET_NAME_DEAN_LETTER AND Contact_Association_Type__c =: contactAssociationType ORDER BY createdDate DESC
		];
		return assetList[0].Dean_s_Letter_Date__c;
	}
	/* Purpose : Method to copy Contact Association Type Staging to Contact Association Type called from process builder*/
	@InvocableMethod
	public static List<String> contactAssTypeMigration(List<Case> cases){
		string currentCaseId = cases[0].Id;
		string currentContactId = cases[0].ContactId;
		string fieldNames = '';
		string fieldNamesCat = '';
		Contact_Association_Type__c catRecord = new Contact_Association_Type__c();
		string catsSchoolEnrlmentstatus = '';
		Map<String, Schema.SObjectField> fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		Map<String, Schema.SObjectField> fieldMapCat = Schema.getglobaldescribe().get('Contact_Association_Type__c').getdescribe().fields.getmap();
		List<Contact_Association_Type_Staging__c> recordsList = new List<Contact_Association_Type_Staging__c> ();
		List<Contact_Association_Type_Staging__c> cvAcceptedCATSList = new List<Contact_Association_Type_Staging__c>();
		List<Contact_Association_Type_Staging__c> currentCATSList = new List<Contact_Association_Type_Staging__c>();
		List<Contact_Association_Type__c> recordsDelList = new List<Contact_Association_Type__c> ();
		List<Contact_Association_Type__c> recordsListCat = new List<Contact_Association_Type__c> ();
		List<Contact_Association_Type__c> recordsListCatFinal = new List<Contact_Association_Type__c> ();
		List<string> recordsIdList = new List<string> ();
		Set<String> cvAcceptedCATSIds = new Set<String>();

		Contact_Association_Type__c catDegreeMedicalSchoolRecord = new Contact_Association_Type__c();
		Contact_Association_Type_Staging__c catsDegreeMedicalSchoolRecord = new Contact_Association_Type_Staging__c();

		fieldNames = getFieldNames(fieldMapCatStaging);
		for (Schema.SObjectField field2: fieldMapCat.values()) {
			fieldNamesCat = fieldNamesCat + field2.getDescribe().getName() + ',';
		}
		fieldNamesCat = fieldNamesCat.removeEnd(',');

		// Checking as AppForCert Case is existing with Rejected and any CV Case is 'CV Accepted'
		List<Case> cvAcceptedCases = [SELECT Id FROM Case WHERE ContactId =: currentContactId AND ParentId !=: currentCaseId AND Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED AND Service__c =: Constants.CASE_SERVICE_ECFMG_CERTIFICATION AND RecordTypeId =:Constants.CVRECORDTYPEID];
		if(!cvAcceptedCases.isEmpty()){
			List<Contact_Association_Type_Staging__c> cvCATSLists = [SELECT Id, Case__c FROM Contact_Association_Type_Staging__c WHERE Contact__c =: currentContactId AND Case__c =: cvAcceptedCases];
			for(Contact_Association_Type_Staging__c catsRec : cvCATSLists){
				cvAcceptedCATSIds.add(catsRec.Id);
			}
		}
		String soqlQueryCat = 'SELECT RecordType.DeveloperName,' + ' ' + fieldNamesCat + ' ' + 'FROM' + ' ' + 'Contact_Association_Type__c where Contact__c = \'' + currentContactId + '\'' + 'and RecordType.DeveloperName in (\'' + Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE + '\')';
		recordsDelList = Database.query(soqlQueryCat);
		catDegreeMedicalSchoolRecord = deleteContactAssociationTypeRecords(recordsDelList);
		String catDegMedSchoolAccountId = catDegreeMedicalSchoolRecord.Account__c;
		String catSchoolEnrlmentStatus = catDegreeMedicalSchoolRecord.Status__c;
		if(!cvAcceptedCATSIds.isEmpty()){
			List<String> cvAcceptedCATSIdsList = new List<String>();
			for(String catIdStr : cvAcceptedCATSIds){
				String catIdVal = '\''+catIdStr+'\'';
				cvAcceptedCATSIdsList.add(catIdVal);
			}
			String cvAcceptedCATSIdsStr = String.join(cvAcceptedCATSIdsList, ',');
			String soqlQueryCATS = 'SELECT RecordType.DeveloperName,' + ' ' + fieldNames + ' ' + 'FROM' + ' ' + 'Contact_Association_Type_Staging__c WHERE Contact__c = \'' + currentContactId + '\'' + ' and Id IN (' + cvAcceptedCATSIdsStr + ') and RecordType.DeveloperName in (\'' + Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE + '\')';
			cvAcceptedCATSList = Database.query(soqlQueryCATS);
			recordsList.addAll(cvAcceptedCATSList);
		}
		string soqlQuery = 'SELECT RecordType.DeveloperName,' + ' ' + fieldNames + ' ' + 'FROM' + ' ' + 'Contact_Association_Type_Staging__c where Contact__c = \'' + currentContactId + '\'' + ' and Parent_Case__c = \'' + currentCaseId + '\'' + ' and RecordType.DeveloperName in (\'' + Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION + '\',\'' + Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE + '\')';
		currentCATSList = Database.query(soqlQuery);
		recordsList.addAll(currentCATSList);
		Boolean acceptedFMDStatus = AppForCertHelper.getCATDegMedSchFMDStatus(currentContactId);
		for(Contact_Association_Type_Staging__c record: recordsList){
			catRecord = new Contact_Association_Type__c();
			if(string.valueof(catDegreeMedicalSchoolRecord.Id) != '' && string.valueof(catDegreeMedicalSchoolRecord.Id) != null && record.RecordType.DeveloperName == catDegreeMedicalSchoolRecord.RecordType.DeveloperName){
				if(acceptedFMDStatus == false){
					catsDegreeMedicalSchoolRecord = new Contact_Association_Type_Staging__c();
					catDegreeMedicalSchoolRecord = contactAssTypeMigrationCatRecordRefactorMethodDegMed(record, catDegreeMedicalSchoolRecord);
					catDegreeMedicalSchoolRecord.put('CatIdentifier__c', record.Id);
					recordsListCatFinal.add(catDegreeMedicalSchoolRecord);
					catsSchoolEnrlmentstatus = getSchoolEnrollmentStatus(record);
					catsDegreeMedicalSchoolRecord = record;
					recordsIdList.add(record.Id);
				}
			}else{
				catRecord = contactAssTypeMigrationCatRecordRefactorMethod(record);
				catRecord.put('Contact__c', currentContactId);
				catRecord.put('CatIdentifier__c', record.Id);
				recordsListCat.add(catRecord);
				recordsListCatFinal.add(catRecord);
				recordsIdList.add(record.Id);
			}			
		}
		// US 9035: Relate degree school change affirmation to Contact Association Type
		updateDegreeSchoolChangeAffirmation(catsDegreeMedicalSchoolRecord.Id, catDegreeMedicalSchoolRecord.Id);		
		// US 6148 -- System updates when App4Cert is Accepted - Degree School Changed
		appForCertAccepted(cases, catDegMedSchoolAccountId, catSchoolEnrlmentStatus, catsDegreeMedicalSchoolRecord);		
		dmlDegMedSchCAT(recordsListCat,catDegreeMedicalSchoolRecord);	
		List<Asset> assetList = new List<Asset> ([SELECT id, Name, Key__c, status, Contact_Association_Type__c, RecordType.DeveloperName, Contact_Association_Type_Staging__c, Dean_s_Letter_Date__c, Case__c FROM asset WHERE contactId =: currentContactId AND Contact_Association_Type_Staging__c IN: recordsIdList AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED]);
		List<Transfer_Credit__c> transfercreditList = new List<Transfer_Credit__c>([SELECT id, Case__c, Contact_Association_Type__c, Contact_Association_Type_Staging__c from Transfer_Credit__c WHERE Applicant__c =: currentContactId AND Contact_Association_Type_Staging__c IN: recordsIdList WITH SECURITY_ENFORCED]);
		integer count = 0;
		count = countreturnRefactorMethod(assetList, transfercreditList);
		if(count > 0){
			for(integer i = 0; i<count; i++){
				if(recordsListCatFinal.size() > 0){
					transfercreditList = transfercreditListRefactorMethod(transfercreditList, recordsListCatFinal, i);
					assetList = assetcreditListRefactorMethod(assetList, recordsListCatFinal, i);
				}
			}
		}
		updateTcAndAssetList(transfercreditList, assetList, currentContactId);
		List<Contact> contactList = [SELECT Id, School_Enrollment_Status__c FROM Contact WHERE Id =: currentContactId WITH SECURITY_ENFORCED];
		if (string.isNotEmpty(catsSchoolEnrlmentstatus)  && Schema.sObjectType.Contact.isUpdateable()) {
			contactList[0].School_Enrollment_Status__c = catsSchoolEnrlmentstatus;
			update contactList;
		}
		examRegistrationCheckOnStatus(cases);
		return new List<String> ();
	}

	public static void updateTcAndAssetList(List<Transfer_Credit__c > transfercreditList,List<Asset> assetList, String currentContactId){
		if (!assetList.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
			update assetList;
			// Update existing ACCEPTED CAT for Letter from Dean Asset - unlink CAT and CATS
			SET<Id> assetIdSet = new SET<Id>();
			Set<String> keySet = new Set<String>{
				System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
				System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
				System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT
			};
			for(Asset assetRec : assetList){
				if(keySet.contains(assetRec.Key__c)){
					assetIdSet.add(assetRec.Id);
				}				
			}
			List<Asset> assetAcceptedToDelete = new List<Asset>([SELECT Id, Status, Contact_Association_Type__c, RecordType.DeveloperName, Contact_Association_Type_Staging__c, Dean_s_Letter_Date__c, Case__c 
																	FROM Asset 
																	WHERE ContactId =: currentContactId 
																		AND Id NOT IN: assetIdSet 
																		AND key__c IN: keySet
																		AND Status =: constants.ASSET_STATUS_ACCEPTED
																	WITH SECURITY_ENFORCED]);
			if(!assetAcceptedToDelete.isEmpty()){
				AppForCertHelper.unlinkAcceptedDeanAsset(assetAcceptedToDelete);
			}
		}
		if (!transfercreditList.isEmpty() && Schema.sObjectType.Transfer_Credit__c.isUpdateable()){
			update transfercreditList;
		}
	}
	public static void dmlDegMedSchCAT(List<Contact_Association_Type__c> recordsListCat,Contact_Association_Type__c catDegreeMedicalSchoolRecord){
		if(!recordsListCat.isEmpty() && Schema.sObjectType.Contact_Association_Type__c.isCreateable()){		
			insert recordsListCat;
		}
		if(catDegreeMedicalSchoolRecord.Id != null && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()){		
			update catDegreeMedicalSchoolRecord;
		}
	}
	/**
	 * Created By: Reshma
	 * Method Name: updateDegreeSchoolChangeAffirmation
	 * Purpose: Relate Degree School Change affirmation records to Contact Association Type
	 * Return Type: Void
	 */
	public static void updateDegreeSchoolChangeAffirmation(String catsDegreeMedicalSchoolRecordId, String catDegreeMedicalSchoolRecordId) {
		List<Affirmation__c > dscAffirmations = new List<Affirmation__c > ();
		for (Affirmation__c affirmation: [SELECT Id, Contact_Association_Type_Staging__c, Contact_Association_Type__c FROM Affirmation__c WHERE Contact_Association_Type_Staging__c =: catsDegreeMedicalSchoolRecordId AND RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_DEGREE_SCHOOL]) {
			affirmation.Contact_Association_Type__c = catDegreeMedicalSchoolRecordId;
			dscAffirmations.add(affirmation);
		}
		if (!dscAffirmations.isEmpty()) {
			UPDATE dscAffirmations;
		}
	}

	// US 6148 -- System updates when App4Cert is Accepted - Degree School Changed
	public static void appForCertAccepted(List<Case> cases, String catDegMedSchoolAccountId, String catSchoolEnrlmentStatus, Contact_Association_Type_Staging__c catsDegreeMedicalSchoolRecord) {
		string currentContactId = cases[0].ContactId;
		String appForCertCaseStatus = cases[0].Internal_Status__c;
		if (appForCertCaseStatus == Constants.CASE_STATUS_ACCEPTED) {
			// CATS
			String catsDegMedSchoolAccountId = catsDegreeMedicalSchoolRecord.Account__c;
			String catsSchoolEnrlmentStatus = catsDegreeMedicalSchoolRecord.Status__c;
			if (catsDegMedSchoolAccountId != catDegMedSchoolAccountId && catsSchoolEnrlmentStatus == catSchoolEnrlmentStatus && catSchoolEnrlmentStatus == Constants.CONASCTYPESTG_STATUS_STUDENT) {
				// To avoid CognitiveComplexity create the new method for "appForCertAccepted" method
				handleStudentExamRegStatus(currentContactId, catsDegreeMedicalSchoolRecord);
			}
			// User Story 8297 - System updates when App4Cert is Accepted - Student-to-Graduate
			appForCertAcceptedGraduate(currentContactId, catSchoolEnrlmentStatus, catsSchoolEnrlmentStatus);
		}
	}

	// To avoid CognitiveComplexity create the new method for "appForCertAccepted" method
	public static void handleStudentExamRegStatus(String currentContactId, Contact_Association_Type_Staging__c catsDegreeMedicalSchoolRecord) {
		Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		List<Case> examRegCaseList = [SELECT Id, ContactId, Enrollment_Verification_Parent__c, Enrollment_Re_Verification_Parent__c, Internal_Status__c FROM Case
					WHERE RecordTypeId =: examRegRecordTypeId
					AND ContactId =: currentContactId
				];
		if (!examRegCaseList.isEmpty()) {
			SET<Id> examRegCaseSetId = new SET<Id> ();
			// avoid soql within loop
			for (Case examregCaseRecord: examRegCaseList) {
				examRegCaseSetId.add(examregCaseRecord.Id);
			}
			Map<Id, Exam_Registration__c> examRegCaseMap = new Map<Id, Exam_Registration__c>();
			for (Exam_Registration__c examReg: [SELECT Id, Exam_taken_date__c, Exam_Status__c, Case__c
					FROM Exam_Registration__c
					WHERE Applicant__c =: currentContactId
					AND Case__c IN: examRegCaseSetId
					AND Exam_taken_date__c = null
					AND Exam_Status__c = null
				]) {
				examRegCaseMap.put(examReg.Case__c, examReg);
			}
			// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
			studentExamRegNotRegistered(currentContactId, catsDegreeMedicalSchoolRecord, examRegCaseList);
			// Open exam registration case for that applicant, in internal status "Pending CIBIS" or "Registered"
			studentExamRegRegistered(currentContactId, catsDegreeMedicalSchoolRecord, examRegCaseList, examRegCaseMap);
		}
	}

	// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
	public static void studentExamRegNotRegistered(String currentContactId, Contact_Association_Type_Staging__c catsDegreeMedicalSchoolRecord, List<Case> examRegCaseList) {
		List<Case> newExamRegCaseList = new List<Case> ();
		List<Case> newEVCaseList = new List<Case> ();
		List<Case> newCombineCaseList = new List<Case> ();		
		SET<Id> evParentIdSet 		= new SET<Id> ();
		Set<Case> newCombineCaseSet = new Set<Case>();
		List<Case> finalCombineCaseList = new List<Case>();
		// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
		for (Case examregCaseRecord: examRegCaseList) {
			if (examregCaseRecord.Internal_Status__c != Constants.CASE_STATUS_PENDING_CIBIS && examregCaseRecord.Internal_Status__c != Constants.CASE_STATUS_REGISTERED) {
				Case examregCaseObj = new Case();
				examregCaseObj.Id = examregCaseRecord.Id;
				examregCaseObj.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
				examregCaseObj.Deficiency_Reason_RTF__c = Constants.CASE_DEFICIENCY_REASON_DEGREE_SCHOOL_CHANGED;
				newExamRegCaseList.add(examregCaseObj);
				// Enrollment Verification case
				if (examregCaseRecord.Enrollment_Verification_Parent__c != null) {
					evParentIdSet.add(examregCaseRecord.Enrollment_Verification_Parent__c);
				}
			}
		}
		newCombineCaseList.addAll(newExamRegCaseList);
		// Enrollment Verification case
		if (!evParentIdSet.isEmpty()) {
			for (Id evParentId: evParentIdSet) {
				Case evCaseObj = new Case();
				evCaseObj.Id = evParentId;
				evCaseObj.Internal_Status__c = Constants.CASE_STATUS_CLOSED_SCHOOL_CHANGED;
				evCaseObj.Verification_Status__c=null;
				newEVCaseList.add(evCaseObj);
			}
			newCombineCaseList.addAll(newEVCaseList);
		}		
		if (!newCombineCaseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()) {
			newCombineCaseSet.addAll(newCombineCaseList);
			finalCombineCaseList.addAll(newCombineCaseSet);
			update finalCombineCaseList;
		}
	}

	// Open exam registration case for that applicant, in internal status "Pending CIBIS" or "Registered"
	public static void studentExamRegRegistered(String currentContactId, Contact_Association_Type_Staging__c catsDegreeMedicalSchoolRecord, List<Case> examRegCaseList, Map<Id, Exam_Registration__c > examRegCaseMap) {
		List<Case> newExamRegisCaseList = 	new List<Case> ();
		SET<Id> evParentIdSet           =   new SET<Id>();
        SET<Id> examRegCaseIdSet        =   new SET<Id>();
		SET<Id> ervCaseIdSet            =   new SET<Id>();
		List<Case> newCombineCaseList 	= 	new List<Case>();
		Set<Case> newCombineCaseSet 	= 	new Set<Case>();
		List<Case> finalCombineCaseList = 	new List<Case>();
		// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
		for (Case examCaseRecord: examRegCaseList) {
			if ((examCaseRecord.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || examCaseRecord.Internal_Status__c == Constants.CASE_STATUS_REGISTERED) && examRegCaseMap.containsKey(examCaseRecord.Id)) {
				// i.Change the associated EV case status to "Closed; School Changed". // Enrollment Verification case
				if(examCaseRecord.Enrollment_Verification_Parent__c != null) {
                    evParentIdSet.add(examCaseRecord.Enrollment_Verification_Parent__c);          
                }
                if(examCaseRecord.Enrollment_Re_Verification_Parent__c != null) {
                    ervCaseIdSet.add(examCaseRecord.Enrollment_Re_Verification_Parent__c);          
                }
                // Change the internal/external exam registration case status to "Rejected".
                Case examRegCaseObj    =    new Case();
                examRegCaseObj.Id      =    examCaseRecord.Id;
                examRegCaseObj.Internal_Status__c  =    Constants.CASE_STATUS_REJECTED;
                examregCaseObj.Deficiency_Reason_RTF__c = Constants.CASE_DEFICIENCY_REASON_DEGREE_SCHOOL_CHANGED;
                newExamRegisCaseList.add(examRegCaseObj);                
                // Exam Reg Case Id
                examRegCaseIdSet.add(examCaseRecord.Id);
			}
		}
		newCombineCaseList.addAll(newExamRegisCaseList);
		// Enrollment Verification case
		List<Case> evCaseList = studentUpdateEVCase(evParentIdSet);
		newCombineCaseList.addAll(evCaseList);
        // US 10217 - Check if there are any outstanding Enrollment Re-verification cases
		List<Case> ervCaseList = AppForCertHelper.studentUpdateERVCase(ervCaseIdSet);
		newCombineCaseList.addAll(ervCaseList);
       	// US 10217 - Check if there are any outstanding EPEx requests
		List<Case> epexCaseList = AppForCertHelper.studentUpdateEpexCase(examRegCaseIdSet); 
		newCombineCaseList.addAll(epexCaseList);
		// Update combind all case lists
		if (!newCombineCaseList.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()) {
			newCombineCaseSet.addAll(newCombineCaseList);
			finalCombineCaseList.addAll(newCombineCaseSet);
			update finalCombineCaseList;
		}
	}
	
	// Create seperate method for Refactor // Enrollment Verification case
	public static List<Case> studentUpdateEVCase(SET<Id> evParentIdSet) {
		List<Case> newEVCaseList = new List<Case> ();
		// Enrollment Verification case
		if (!evParentIdSet.isEmpty()) {
			for (Id evParentId: evParentIdSet) {
				Case evCaseObj = new Case();
				evCaseObj.Id = evParentId;
				evCaseObj.Internal_Status__c = Constants.CASE_STATUS_CLOSED_SCHOOL_CHANGED;
				evCaseObj.Verification_Status__c=null;
				newEVCaseList.add(evCaseObj);
			}
		}
		return newEVCaseList;
	}

	// User Story 8297 | Open exam registration case for that applicant, (not/in) in internal status "Pending CIBIS" or "Registered"
	public static void appForCertAcceptedGraduate(String currentContactId, String catSchoolEnrlmentStatus, String catsSchoolEnrlmentStatus) {
		if (catSchoolEnrlmentStatus == Constants.CONASCTYPESTG_STATUS_STUDENT && catsSchoolEnrlmentStatus == Constants.CONASCTYPESTG_STATUS_GRADUATE) {
			Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
			List<Case> examRegCaseList = [SELECT Id, ContactId, Enrollment_Verification_Parent__c, Enrollment_Re_Verification_Parent__c, Internal_Status__c FROM Case
				WHERE RecordTypeId =: examRegRecordTypeId
				AND ContactId =: currentContactId
			];
			if (!examRegCaseList.isEmpty()) {
				// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
				graduateExamRegNotPenidngCibisRegisteredRefactor(examRegCaseList);
				// Open exam registration case for that applicant, in internal status "Pending CIBIS" or "Registered"
				graduateExamRegPenidngCibisRegisteredRefactor(examRegCaseList);
			}
		}
	}
	/**
	 * Created by Ajoydhas
	 * Method Name: graduateExamRegNotPenidngCibisRegisteredRefactor
	 * Purpose : Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered"  | User Story 8297
	 * Return Type : no
	 */
	public static void graduateExamRegNotPenidngCibisRegisteredRefactor(List<Case> examRegCaseList) {
		List<Case> newExamRegCaseList = new List<Case> ();
		SET<Id> evParentIdSet = new SET<Id> ();

		// Open exam registration case for that applicant, not in internal status "Pending CIBIS" or "Registered":
		for (Case examRegCaseRecord: examRegCaseList) {
			if (examRegCaseRecord.Internal_Status__c != Constants.CASE_STATUS_PENDING_CIBIS && examRegCaseRecord.Internal_Status__c != Constants.CASE_STATUS_REGISTERED) {
				// Exam Registration case
				Case examRegCaseObj = new Case();
				examRegCaseObj.Id = examRegCaseRecord.Id;
				examRegCaseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
				examRegCaseObj.Is_Removed_From_EV__c = true;
				newExamRegCaseList.add(examRegCaseObj);

				// Enrollment Verification case
				if (examRegCaseRecord.Enrollment_Verification_Parent__c != null) {
					evParentIdSet.add(examRegCaseRecord.Enrollment_Verification_Parent__c);
				}
			}
		}
		if (!newExamRegCaseList.isEmpty()) {
			update newExamRegCaseList;
		}
		// Enrollment Verification case
		graduateUpdateEVCaseRefactor(evParentIdSet);
	}
	/**
	 * Created by Ajoydhas
	 * Method Name: graduateExamRegPenidngCibisRegisteredRefactor
	 * Purpose : Open exam registration case for that applicant, in internal status "Pending CIBIS" or "Registered" | User Story 8297
	 * Return Type : no
	 */
	public static void graduateExamRegPenidngCibisRegisteredRefactor(List<Case> examRegCaseList) {
		List<Case> newExamRegCaseList = new List<Case> ();
		SET<Id> evParentIdSet = new SET<Id> ();
		SET<Id> ervParentIdSet = new SET<Id> ();
		SET<Id> examRegCaseIdSet = new SET<Id> ();

		// Open exam registration case for that applicant, in internal status "Pending CIBIS" or "Registered":
		for (Case examRegCaseRecord: examRegCaseList) {
			if (examRegCaseRecord.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS || examRegCaseRecord.Internal_Status__c == Constants.CASE_STATUS_REGISTERED) {
				// Exam Registration case
				Case examRegCaseObj = new Case();
				examRegCaseObj.Id = examRegCaseRecord.Id;
				examRegCaseObj.Is_Removed_From_EV__c = true;
				newExamRegCaseList.add(examRegCaseObj);

				// Enrollment Verification case 
				if (examRegCaseRecord.Enrollment_Verification_Parent__c != null) {
					evParentIdSet.add(examRegCaseRecord.Enrollment_Verification_Parent__c);
				}

				// Enrollment Re-verification case
				if (examRegCaseRecord.Enrollment_Re_Verification_Parent__c != null) {
					ervParentIdSet.add(examRegCaseRecord.Enrollment_Re_Verification_Parent__c);
				}

				// Exam Reg Case Id
				examRegCaseIdSet.add(examRegCaseRecord.Id);
			}
		}

		if (!newExamRegCaseList.isEmpty()) {
			update newExamRegCaseList;
		}

		// Enrollment Verification case
		graduateUpdateEVCaseRefactor(evParentIdSet);

		// Enrollment Re-verification case
		graduateUpdateERVCaseRefactor(ervParentIdSet);

		// US 10218 - Additional Changes to Story 8297: System updates when App4Cert is Accepted - Student-to-Graduate
		graduateUpdateEpexCaseRefactor(examRegCaseIdSet);
	}
	/**
	 * Created by Ajoydhas
	 * Method Name: graduateUpdateEVCaseRefactor
	 * Purpose : Create seperate method for Refactor // Enrollment Verification case
	 * Return Type : no
	 */
	public static void graduateUpdateEVCaseRefactor(SET<Id> evParentIdSet) {
		List<Case> newEVCaseList = new List<Case> ();
		// Enrollment Verification case
		if (!evParentIdSet.isEmpty()) {
			for (Id evParentId: evParentIdSet) {
				Case evCaseObj = new Case();
				evCaseObj.Id = evParentId;
				evCaseObj.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE;
				newEVCaseList.add(evCaseObj);
			}
			if (!newEVCaseList.isEmpty()) {
				update newEVCaseList;
			}
		}
	}
	/**
	 * Created by Ajoydhas
	 * Method Name: graduateUpdateERVCaseRefactor
	 * Purpose : Create seperate method for Refactor // Enrollment Re-verification case
	 * Return Type : no
	 */
	public static void graduateUpdateERVCaseRefactor(SET<Id> ervParentIdSet) {
		List<Case> newERVCaseList = new List<Case> ();
		if (!ervParentIdSet.isEmpty()) {
			for (Id ervParentId: ervParentIdSet) {
				Case ervCaseObj = new Case();
				ervCaseObj.Id = ervParentId;
				ervCaseObj.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFIED;
				newERVCaseList.add(ervCaseObj);
			}
			if (!newERVCaseList.isEmpty()) {
				update newERVCaseList;
			}
		}
	}
	// Description : US 10218 - Additional Changes to Story 8297: System updates when App4Cert is Accepted - Student-to-Graduate
	public static void graduateUpdateEpexCaseRefactor(SET<Id> examRegCaseIdSet) {
		List<Case> newEpexCaseList = new List<Case> ();
		if (!examRegCaseIdSet.isEmpty()) {
			SET<Id> evParentIdSet = new SET<Id> ();
			Id epexRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
			List<Case> epexCaseList = [SELECT Id, ContactId, ParentId, Enrollment_Verification_Parent__c, Internal_Status__c FROM Case
				WHERE RecordTypeId =: epexRecordTypeId
				AND ParentId =: examRegCaseIdSet
				AND(Internal_Status__c !=: Constants.CASE_STATUS_PENDING_CIBIS AND Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED)
			];

			for (Case epexCase: epexCaseList) {
				Case epexCaseObj = new Case();
				epexCaseObj.Id = epexCase.Id;
				epexCaseObj.Is_Removed_From_EV__c = true;
				epexCaseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
				newEpexCaseList.add(epexCaseObj);

				// Enrollment Verification case 
				if (epexCase.Enrollment_Verification_Parent__c != null) {
					evParentIdSet.add(epexCase.Enrollment_Verification_Parent__c);
				}
			}
			if (!newEpexCaseList.isEmpty()) {
				update newEpexCaseList;
			}
			// Enrollment Verification case
			graduateUpdateEVCaseRefactor(evParentIdSet);
		}
	}
	/**
	 * Created by Jofrin
	 * Method Name: getSchoolEnrollmentStatus
	 * Purpose : RefactorMethod of contactAssTypeMigration method to get school enrollment status
	 * Return Type : string
	 */

	@AuraEnabled
	public static string getSchoolEnrollmentStatus(Contact_Association_Type_Staging__c record) {

		string schoolEnrlmentstatus = '';
		if (record.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL) {
			schoolEnrlmentstatus = record.Status__c;
		}
		return schoolEnrlmentstatus;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getFieldNames
	 * Purpose : RefactorMethod of contactAssTypeMigration method to get field names in a string 
	 * Return Type : string
	 */

	public static string getFieldNames(Map<String, Schema.SObjectField > fieldMapCatStaging) {

		string fieldNames = '';
		for (Schema.SObjectField field1: fieldMapCatStaging.values()) {
			fieldNames = fieldNames + field1.getDescribe().getName() + ',';
		}
		fieldNames = fieldNames.removeEnd(',');
		return fieldNames;
	}

	/**
	 * Created by Jofrin
	 * Method Name: contactAssTypeMigrationCatRecordRefactorMethod
	 * Purpose : RefactorMethod of contactAssTypeMigration method to create new records in contAssType 
	 * Return Type : Contact_Association_Type__c
	 */

	@AuraEnabled
	public static Contact_Association_Type__c contactAssTypeMigrationCatRecordRefactorMethod(Contact_Association_Type_Staging__c record) {

		Map<String, Schema.SObjectField > fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		Map<String, Schema.SObjectField > fieldMapCat = Schema.getglobaldescribe().get('Contact_Association_Type__c').getdescribe().fields.getmap();
		Contact_Association_Type__c catRecord = new Contact_Association_Type__c();

		for (Schema.SObjectField field: fieldMapCatStaging.values()) {
			string fieldName = field.getDescribe().getName();
			if (fieldMapCat.containsKey(fieldName) && field.getDescribe().isUpdateable() && field.getDescribe().isAccessible() && fieldName != 'RecordTypeId') {
				catRecord.put(fieldName, record.get(fieldName));
			}
		}

		Map<String, Schema.RecordTypeInfo > recordTypes = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName();
		for (string recordTypeValue: recordTypes.Keyset()) {
			string customRecType = recordTypes.get(recordTypeValue).getDeveloperName();
			Id customRecId = recordTypes.get(recordTypeValue).getRecordTypeId();

			if (customRecType == record.RecordType.DeveloperName) {
				catRecord.put('RecordTypeId', customRecId);
			}
		}
		return catRecord;
	}

	/**
	 * Created by Jofrin
	 * Method Name: contactAssTypeMigrationCatRecordRefactorMethodDegMed
	 * Purpose : RefactorMethod of contactAssTypeMigration method to update degree medical school record
	 * Return Type : Contact_Association_Type__c
	 */

	@AuraEnabled
	public static Contact_Association_Type__c contactAssTypeMigrationCatRecordRefactorMethodDegMed(Contact_Association_Type_Staging__c record, Contact_Association_Type__c degreeMedicalSchoolRecord) {

		Map<String, Schema.SObjectField > fieldMapCatStaging = Schema.getglobaldescribe().get('Contact_Association_Type_Staging__c').getdescribe().fields.getmap();
		Map<String, Schema.SObjectField > fieldMapCat = Schema.getglobaldescribe().get('Contact_Association_Type__c').getdescribe().fields.getmap();

		if (record.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL) {
			for (Schema.SObjectField field: fieldMapCatStaging.values()) {
				string fieldName = field.getDescribe().getName();
				if (fieldMapCat.containsKey(fieldName) && field.getDescribe().isUpdateable() && field.getDescribe().isAccessible() && fieldName != 'RecordTypeId') {
					degreeMedicalSchoolRecord.put(fieldName, record.get(fieldName));
				}
			}
		}
		return degreeMedicalSchoolRecord;
	}

	/**
	 * Created by Jofrin
	 * Method Name: countreturnRefactorMethod
	 * Purpose : RefactorMethod of contactAssTypeMigration method
	 * Return Type : Integer
	 */

	@AuraEnabled
	public static Integer countreturnRefactorMethod(List<Asset> assetList, List<Transfer_Credit__c > transfercreditList) {

		integer count = 0;
		if (assetList.size() > 0 && transfercreditList.size() > 0) {
			if (assetList.size() > transfercreditList.size()) {
				count = assetList.size();
			} else {
				count = transfercreditList.size();
			}
		} else if (assetList.size() == 0 && transfercreditList.size() > 0) {
			count = transfercreditList.size();
		} else if (transfercreditList.size() == 0 && assetList.size() > 0) {
			count = assetList.size();
		} else {
			count = 0;
		}
		return count;
	}
	// Update CAT Id in Transfer_Credit__c
	@AuraEnabled
	public static List<Transfer_Credit__c> transfercreditListRefactorMethod(List<Transfer_Credit__c> transfercreditList, List<Contact_Association_Type__c> recordsListCat, integer i){
		for(Contact_Association_Type__c cat: recordsListCat){
			if(transfercreditList.size() > i && string.valueof(transfercreditList[i].Id) != null && string.valueof(transfercreditList[i].Id) != '' && cat.CatIdentifier__c == transfercreditList[i].Contact_Association_Type_Staging__c){
				transfercreditList[i].Contact_Association_Type__c = cat.Id;
			}
		}
		return transfercreditList;
	}
	// Update CAT Id in Asset
	@AuraEnabled
	public static List<Asset> assetcreditListRefactorMethod(List<Asset> assetList, List<Contact_Association_Type__c> recordsListCat, integer i){
		for(Contact_Association_Type__c cat: recordsListCat){
			if (assetList.size() > i && string.valueof(assetList[i].Id) != null && string.valueof(assetList[i].Id) != '' && cat.CatIdentifier__c == assetList[i].Contact_Association_Type_Staging__c){
				assetList[i].Contact_Association_Type__c = cat.Id;
			}
		}
		return assetList;
	}
	/**
	 * Created by Jofrin
	 * Method Name: deleteContactAssociationTypeRecords
	 * Purpose : Method to delete the contact association type records except degree medical school record.
	 * Return Type : List<Asset>
	 */
	@AuraEnabled
	public static Contact_Association_Type__c deleteContactAssociationTypeRecords(List<Contact_Association_Type__c > recordsDelList) {

		Contact_Association_Type__c degreeMedicalSchoolRecord = new Contact_Association_Type__c();
		List<Contact_Association_Type__c > recordsDelListFinal = new List<Contact_Association_Type__c > ();
		for (Contact_Association_Type__c delList: recordsDelList) {
			if (delList.RecordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL) {
				degreeMedicalSchoolRecord = delList;
			} else {
				recordsDelListFinal.add(delList);
			}
		}
		Delete recordsDelListFinal;
		return degreeMedicalSchoolRecord;
	}

	/**
	 * Created by Jofrin
	 * Method Name: sendMailForAcceptedStatus
	 * Purpose : Send mail when the status is accepted.
	 * Return Type : null
	 */

	public static void sendMailForAcceptedStatus(Id idContact, Id idCase) {

		Contact contactEmail = [Select Id, Email, Name from Contact where Id =: idContact];
		case newCase = [Select id, Internal_Status__c, contact.Name, ECFMG_Portal_Case_Url__c from Case where Id =: idCase];

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setTargetObjectId(newCase.ContactId);
		EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
		message.setTemplateID(emailTemplate.Id);

		List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
		message.setOrgWideEmailAddressId(addr[0].Id);

		String htmlBody = emailTemplate.HtmlValue;
		htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', Constants.CASE_STATUS_ACCEPTED);
		htmlBody = htmlBody.replace('{!Case.Contact}', contactEmail.Name);
		htmlBody = htmlBody.replace('[Link]', '<a href="' + newCase.ECFMG_Portal_Case_Url__c + '">Case Status</a>');

		htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
		htmlBody = htmlBody.replaceAll('\\]\\]>', '');

		message.setHtmlBody(htmlBody);
		message.toAddresses = new String[] {
			contactEmail.email
		};

		try {
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage > {
				message
			};
			Messaging.sendEmail(messages);
		} catch (exception e) {
			system.debug('results: e' + e.getMessage());
		}
	}

	/**
	 * Created by Jofrin
	 * Method Name: previousLicenseUpdate
	 * Purpose : Update previous license field in contact and contact staging.
	 * Return Type : string
	 */

	@AuraEnabled(cacheable = false)
	public static string previousLicenseUpdate(string selectedOption) {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		string licenseValue = '';
		List<Contact_Staging__c > csRecords = new List<Contact_Staging__c > ();
		csRecords = [Select Id, Contact__c, Previous_License__c, RecordType.DeveloperName from Contact_Staging__c where Contact__c =: contactId AND RecordType.DeveloperName =: Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION LIMIT 1];
		try {

			if (selectedOption == 'Option2') {
				licenseValue = 'No';
			} else {
				licenseValue = 'Yes';
			}
			if (csRecords.size() > 0) {
				csRecords[0].Previous_License__c = licenseValue;
				update csRecords;
			} else {
				Contact_Staging__c newRecord = new Contact_Staging__c();

				Id customRecId = Schema.SObjectType.Contact_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_STAGING_RECORDTYPE_EXAMREGISTRATION).getRecordTypeId();
				newRecord.RecordTypeId = customRecId;
				newRecord.Contact__c = contactId;
				newRecord.Previous_License__c = licenseValue;

				insert newRecord;
			}

		} catch (exception e) {
			system.debug(e);
		}
		return 'Success';
	}

	// Purpose : Method to get the list of previously inserted Other Medical Schools
	@AuraEnabled
	public static List<AppForCertHelper.OtherSchoolObjWrapper> getOtherMedSchoolConAssocTypeStaging(Boolean showExamRegActionButton){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
		}
		List<AppForCertHelper.OtherSchoolObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.OtherSchoolObjWrapper>();
		List<Contact_Association_Type_Staging__c> medicalschoolsList = new List<Contact_Association_Type_Staging__c>([SELECT Id, Case__r.Internal_Status__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type_Staging__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName AND Parent_Case__c =: caseId
			WITH SECURITY_ENFORCED ORDER BY createdDate ASC
		]);
		if(!medicalschoolsList.isEmpty()){
			for(Contact_Association_Type_Staging__c tempconAssocStag: medicalschoolsList){
				fetchedValuesToReturn.add(getCancelledOtherMedSchoolObj(tempconAssocStag));
			}
		}else{
			List<Case> cancelledAppForCerList = [SELECT Id, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND ContactId =: contactId AND Id !=: caseId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
       		if(!cancelledAppForCerList.isEmpty() && cancelledAppForCerList[0].Internal_Status__c == Constants.CASE_STATUS_CANCELLED){
				List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>([SELECT Id, Case__r.Internal_Status__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
					FROM Contact_Association_Type_Staging__c
					WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName AND Parent_Case__c =: cancelledAppForCerList[0].Id
						AND (Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_REJECTED OR Case__r.Internal_Status__c =: Constants.CASE_STATUS_CANCELLED)
					ORDER BY createdDate DESC
				]);
				if(!catsList.isEmpty()){
					for(Contact_Association_Type_Staging__c tempconAssocStag : catsList){
						fetchedValuesToReturn.add(getCancelledOtherMedSchoolObj(tempconAssocStag));
					}
				}
			}else{
				List<Contact_Association_Type__c> medicalschoolsListCAT = new List<Contact_Association_Type__c>([SELECT Id, Parent_Case__c, Parent_Case__r.Internal_Status__c, Case__c, Case__r.Internal_Status__c, Deleted_On_Resubmission__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
					FROM Contact_Association_Type__c
					WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName
					ORDER BY createdDate ASC
				]);
				for(Contact_Association_Type__c tempconAssocStag : medicalschoolsListCAT){
					if(tempconAssocStag.Case__r.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED || (tempconAssocStag.Parent_Case__c == tempconAssocStag.Case__c && tempconAssocStag.Parent_Case__r.Internal_Status__c == Constants.CASE_STATUS_REJECTED && tempconAssocStag.Deleted_On_Resubmission__c == false)){
						String tempRecordIdVal = tempconAssocStag.Id;
						String tempOtherSchool = tempconAssocStag.Account_Name__c;
						String tempnumberOfYearsAttended;
						if (tempconAssocStag.Number_of_Years_Attended__c != null) {
							tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
						} else {
							tempnumberOfYearsAttended = '';
						}
						String tempOtherSchoolId = tempconAssocStag.Account__c;
						String tempSchoolProgram = tempconAssocStag.School_Program__c;
						String tempStudentId = tempconAssocStag.Student_ID__c;
						String tempSpecialty = tempconAssocStag.Specialty__c;
						String tempFromDate;
						if (tempconAssocStag.Start_Date__c != null) {
							tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
						} else {
							tempFromDate = '';
						}
						String tempEndDate;
						if (tempconAssocStag.End_Date__c != null) {
							tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
						} else {
							tempEndDate = '';
						}
						//code added by Shailaja. Date format
						String tempStartMonth = tempconAssocStag.Start_Month__c;
						String tempStartYear = tempconAssocStag.Start_Year__c;
						String tempEndMonth = tempconAssocStag.End_Month__c;
						String tempEndYear = tempconAssocStag.End_Year__c;
						String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
						String tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);
						List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
						tcObjList = getOtherMedSchoolConAssocTypeRefactorMethod(tempconAssocStag, tempOtherSchoolId, tempTransferCreditsCheckbox);
						List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
						assetObjList = getOtherInstitutionConAssocTypeRefactorAssetList(tempconAssocStag);
						AppForCertHelper.OtherSchoolObjWrapper tempJsObj;			
						tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type_Staging__c', caseInternalStatus);
						tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
						fetchedValuesToReturn.add(tempJsObj);
					}
				}
			}			
		}
		return fetchedValuesToReturn;
	}
	// Contact_Association_Type_Staging__c - fetchign values and set to wrapper class
	public Static AppForCertHelper.OtherSchoolObjWrapper getCancelledOtherMedSchoolObj(Contact_Association_Type_Staging__c tempconAssocStag){
		String tempRecordIdVal = tempconAssocStag.Id;
		String tempOtherSchool = tempconAssocStag.Account_Name__c;
		String tempnumberOfYearsAttended;
		if (tempconAssocStag.Number_of_Years_Attended__c != null) {
			tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
		} else {
			tempnumberOfYearsAttended = '';
		}
		String tempOtherSchoolId = tempconAssocStag.Account__c;
		String tempSchoolProgram = tempconAssocStag.School_Program__c;
		String tempStudentId = tempconAssocStag.Student_ID__c;
		String tempSpecialty = tempconAssocStag.Specialty__c;
		String tempFromDate;
		if (tempconAssocStag.Start_Date__c != null) {
			tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
		} else {
			tempFromDate = '';
		}
		String tempEndDate;
		if (tempconAssocStag.End_Date__c != null) {
			tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
		} else {
			tempEndDate = '';
		}
		String tempStartMonth = tempconAssocStag.Start_Month__c;
		String tempStartYear = tempconAssocStag.Start_Year__c;
		String tempEndMonth = tempconAssocStag.End_Month__c;
		String tempEndYear = tempconAssocStag.End_Year__c;
		String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
		String tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);
		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		tcObjList = getOtherMedSchoolConAssocTypeStagingRefactorMethod(tempconAssocStag, tempOtherSchoolId, tempTransferCreditsCheckbox);
		List<AppForCertHelper.AssetObjWrapper > assetObjList = new List<AppForCertHelper.AssetObjWrapper > ();
		assetObjList = getOtherInstitutionConAssocTypeStagingRefactorAssetList(tempconAssocStag);
		AppForCertHelper.OtherSchoolObjWrapper tempJsObj;			
		tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type_Staging__c', caseInternalStatus);
		tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
		return tempJsObj;
	}  
	/**
	 * Created by Jofrin
	 * Method Name: getOtherMedSchoolConAssocTypeStagingRefactorMethod
	 * Purpose : Method to get the list of inserted records from Contact Assocaition Type - Other_MedSchool
	 * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type Staging
	 */
	@AuraEnabled
	public static List<AppForCertHelper.TcObjWrapper > getOtherMedSchoolConAssocTypeStagingRefactorMethod(Contact_Association_Type_Staging__c tempconAssocStag, string tempOtherSchoolId, string tempTransferCreditsCheckbox) {

		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		AppForCertHelper.TcObjWrapper tcTemp;

		if (!tempconAssocStag.Transfer_Credits__r.isEmpty() && tempconAssocStag.Transfer_Credits__r[0].From_School__c == tempOtherSchoolId && tempTransferCreditsCheckbox == 'true') {
			for (Transfer_Credit__c tcIter: tempconAssocStag.Transfer_Credits__r) {
				String tcId = tcIter.Id;
				String tcCourse = tcCourseMethod(tcIter);
				String tcGrade = tcGradeMethod(tcIter);
				String courseOutcome = tcIter.Course_Outcome__c == null ? '' : tcIter.Course_Outcome__c;
				String creditsEarnedMonth = tcIter.Credits_Earned_Month__c == null ? '' : tcIter.Credits_Earned_Month__c;
				String creditsEarnedYear = tcIter.Credits_Earned_Year__c == null ? '' : tcIter.Credits_Earned_Year__c;
				tcTemp = new AppForCertHelper.TcObjWrapper(String.valueOf(tcId), String.valueOf(tempOtherSchoolId), tcCourse, tcGrade, courseOutcome, creditsEarnedMonth, creditsEarnedYear);
				tcObjList.add(tcTemp);
			}
		}
		return tcObjList;
	}
	// Method to get the list of CV Accepted records from Contact Assocaition Type (Record Type : Medical_School)
	@AuraEnabled
	public static List<AppForCertHelper.OtherSchoolObjWrapper> getOtherMedSchoolConAssocType(){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<AppForCertHelper.OtherSchoolObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.OtherSchoolObjWrapper>();
		List<Contact_Association_Type__c> medicalschoolsList = new List<Contact_Association_Type__c>([SELECT Id, Case__r.Internal_Status__c, Parent_Case__r.Internal_Status__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL 
				AND (Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED OR Parent_Case__r.Internal_Status__c =: Constants.CASE_STATUS_ACCEPTED)
			ORDER BY createdDate ASC
		]);
		if(!medicalschoolsList.isEmpty()){
			for(Contact_Association_Type__c tempconAssocStag : medicalschoolsList){
				String tempRecordIdVal = tempconAssocStag.Id;
				String tempOtherSchool = tempconAssocStag.Account_Name__c;
				String tempnumberOfYearsAttended;
				if(tempconAssocStag.Number_of_Years_Attended__c != null){
					tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
				}else{
					tempnumberOfYearsAttended = '';
				}
				String tempOtherSchoolId = tempconAssocStag.Account__c;
				String tempSchoolProgram = tempconAssocStag.School_Program__c;
				String tempStudentId = tempconAssocStag.Student_ID__c;
				String tempSpecialty = tempconAssocStag.Specialty__c;
				String tempFromDate;
				if(tempconAssocStag.Start_Date__c != null){
					tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
				}else{
					tempFromDate = '';
				}
				String tempEndDate;
				if(tempconAssocStag.End_Date__c != null){
					tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
				}else{
					tempEndDate = '';
				}
				String tempStartMonth = tempconAssocStag.Start_Month__c;
				String tempStartYear = tempconAssocStag.Start_Year__c;
				String tempEndMonth = tempconAssocStag.End_Month__c;
				String tempEndYear = tempconAssocStag.End_Year__c;
				String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
				String tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);
				List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
				tcObjList = getOtherMedSchoolConAssocTypeRefactorMethod(tempconAssocStag, tempOtherSchoolId, tempTransferCreditsCheckbox);
				List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
				assetObjList = getOtherInstitutionConAssocTypeRefactorAssetList(tempconAssocStag);
				AppForCertHelper.OtherSchoolObjWrapper tempJsObj;
				tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type__c', caseInternalStatus);
				tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
				fetchedValuesToReturn.add(tempJsObj);
			}
		}
		return fetchedValuesToReturn;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getOtherMedSchoolConAssocTypeRefactorMethod
	 * Purpose : Method to get the list of inserted records from Contact Assocaition Type - Other_MedicalSchool
	 * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type
	 */
	@AuraEnabled
	public static List<AppForCertHelper.TcObjWrapper > getOtherMedSchoolConAssocTypeRefactorMethod(Contact_Association_Type__c tempconAssocStag, string tempOtherSchoolId, string tempTransferCreditsCheckbox) {

		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		AppForCertHelper.TcObjWrapper tcTemp;
		if (!tempconAssocStag.Transfer_Credits__r.isEmpty() && tempconAssocStag.Transfer_Credits__r[0].From_School__c == tempOtherSchoolId && tempTransferCreditsCheckbox == 'true') {
			for (Transfer_Credit__c tcIter: tempconAssocStag.Transfer_Credits__r) {
				String tcId = tcIter.Id;
				String tcCourse = tcCourseMethod(tcIter);
				String tcGrade = tcGradeMethod(tcIter);
				String courseOutcome = tcIter.Course_Outcome__c == null ? '' : tcIter.Course_Outcome__c;
				String creditsEarnedMonth = tcIter.Credits_Earned_Month__c == null ? '' : tcIter.Credits_Earned_Month__c;
				String creditsEarnedYear = tcIter.Credits_Earned_Year__c == null ? '' : tcIter.Credits_Earned_Year__c;
				tcTemp = new AppForCertHelper.TcObjWrapper(String.valueOf(tcId), String.valueOf(tempOtherSchoolId), tcCourse, tcGrade, courseOutcome, creditsEarnedMonth, creditsEarnedYear);
				tcObjList.add(tcTemp);
			}
		}
		return tcObjList;
	}

	@AuraEnabled
	public static string tcGradeMethod(Transfer_Credit__c tcObjTemp) {
		string tcGrade = tcObjTemp.Transfer_Credit_Grade__c == null ? '' : tcObjTemp.Transfer_Credit_Grade__c;
		return tcGrade;
	}

	// Method to get the list of inserted records from Contact Assocaition Type Staging or Contact Assocaition Type - Other_Institution
	@AuraEnabled
	public static List<AppForCertHelper.OtherSchoolObjWrapper> getOtherInstitutionConAssocTypeStaging(Boolean showExamRegActionButton){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		String recordTypeDeveloperName;
		if(showExamRegActionButton == true){
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG;
		}else{
			recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION;
		}
		List<Contact_Association_Type_Staging__c> medicalschoolsList = new List<Contact_Association_Type_Staging__c>([SELECT Id, Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type_Staging__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName AND Parent_Case__c =: caseId
			WITH SECURITY_ENFORCED ORDER BY createdDate ASC
		]);
		List<AppForCertHelper.OtherSchoolObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.OtherSchoolObjWrapper>();
		if(!medicalschoolsList.isEmpty()){
			for(Contact_Association_Type_Staging__c tempconAssocStag: medicalschoolsList){
				fetchedValuesToReturn.add(getCancelledOtherInstitutionObj(tempconAssocStag));
			}
		}else{
			List<Case> cancelledAppForCerList = [SELECT Id, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND ContactId =: contactId AND Id !=: caseId WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        	if(!cancelledAppForCerList.isEmpty() && cancelledAppForCerList[0].Internal_Status__c == Constants.CASE_STATUS_CANCELLED){
				List<Contact_Association_Type_Staging__c> catsList = new List<Contact_Association_Type_Staging__c>([SELECT Id, Case__r.Internal_Status__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
					FROM Contact_Association_Type_Staging__c
					WHERE Contact__c =: contactId AND recordType.DeveloperName =: recordTypeDeveloperName AND Parent_Case__c =: cancelledAppForCerList[0].Id
						AND (Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_REJECTED OR Case__r.Internal_Status__c =: Constants.CASE_STATUS_CANCELLED)
					ORDER BY createdDate DESC
				]);
				if(!catsList.isEmpty()){
					for(Contact_Association_Type_Staging__c tempconAssocStag : catsList){
						fetchedValuesToReturn.add(getCancelledOtherInstitutionObj(tempconAssocStag));
					}
				}
			}else{
				List<Contact_Association_Type__c> medicalschoolsListCAT = new List<Contact_Association_Type__c>([SELECT Id, Case__c, Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
					FROM Contact_Association_Type__c
					WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION
					ORDER BY createdDate ASC
				]);
				for(Contact_Association_Type__c tempconAssocStag: medicalschoolsListCAT){
					if(tempconAssocStag.Case__r.Internal_Status__c == Constants.CASE_STATUS_CV_REJECTED){
						string tempRecordIdVal = tempconAssocStag.Id;
						string tempOtherSchool = tempconAssocStag.Account_Name__c;
						String tempnumberOfYearsAttended;
						if(tempconAssocStag.Number_of_Years_Attended__c != null){
							tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
						}else{
							tempnumberOfYearsAttended = '';
						}
						string tempOtherSchoolId = tempconAssocStag.Account__c;
						string tempSchoolProgram = tempconAssocStag.School_Program__c;
						string tempStudentId = tempconAssocStag.Student_ID__c;
						string tempSpecialty = tempconAssocStag.Specialty__c;
						string tempFromDate;
						if(tempconAssocStag.Start_Date__c != null){
							tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
						}else{
							tempFromDate = '';
						}
						string tempEndDate;
						if(tempconAssocStag.End_Date__c != null){
							tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
						}else{
							tempEndDate = '';
						}
						string tempStartMonth = tempconAssocStag.Start_Month__c;
						string tempStartYear = tempconAssocStag.Start_Year__c;
						string tempEndMonth = tempconAssocStag.End_Month__c;
						string tempEndYear = tempconAssocStag.End_Year__c;
						String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
						string tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);
						List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper>();
						tcObjList = getOtherInstitutionConAssocTypeRefactorMethod(tempconAssocStag, tempOtherSchoolId);
						List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
						assetObjList = getOtherInstitutionConAssocTypeRefactorAssetList(tempconAssocStag);
						AppForCertHelper.OtherSchoolObjWrapper tempJsObj;					
						tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type__c', caseInternalStatus);
						tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
						fetchedValuesToReturn.add(tempJsObj);
					}
				}
			}
		}
		return fetchedValuesToReturn;
	}
	// Contact_Association_Type_Staging__c - fetchign values and set to wrapper class
	public Static AppForCertHelper.OtherSchoolObjWrapper getCancelledOtherInstitutionObj(Contact_Association_Type_Staging__c tempconAssocStag){
		string tempRecordIdVal = tempconAssocStag.Id;
		string tempOtherSchool = tempconAssocStag.Account_Name__c;
		String tempnumberOfYearsAttended;
		if (tempconAssocStag.Number_of_Years_Attended__c != null) {
			tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
		} else {
			tempnumberOfYearsAttended = '';
		}
		string tempOtherSchoolId = tempconAssocStag.Account__c;
		string tempSchoolProgram = tempconAssocStag.School_Program__c;
		string tempStudentId = tempconAssocStag.Student_ID__c;
		string tempSpecialty = tempconAssocStag.Specialty__c;
		string tempFromDate;
		if (tempconAssocStag.Start_Date__c != null) {
			tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
		} else {
			tempFromDate = '';
		}
		string tempEndDate;
		if (tempconAssocStag.End_Date__c != null) {
			tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
		} else {
			tempEndDate = '';
		}
		string tempStartMonth = tempconAssocStag.Start_Month__c;
		string tempStartYear = tempconAssocStag.Start_Year__c;
		string tempEndMonth = tempconAssocStag.End_Month__c;
		string tempEndYear = tempconAssocStag.End_Year__c;
		String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
		string tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);

		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		tcObjList = getOtherInstitutionConAssocTypeStagingRefactorMethod(tempconAssocStag, tempOtherSchoolId);

		List<AppForCertHelper.AssetObjWrapper > assetObjList = new List<AppForCertHelper.AssetObjWrapper > ();
		assetObjList = getOtherInstitutionConAssocTypeStagingRefactorAssetList(tempconAssocStag);

		AppForCertHelper.OtherSchoolObjWrapper tempJsObj;				
		tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear,  tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type_Staging__c', caseInternalStatus);
		tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
		return tempJsObj;
	}
	/**
	 * Created by Jofrin
	 * Method Name: getOtherInstitutionConAssocTypeStagingRefactorMethod
	 * Purpose : Method to get the list of inserted records from Contact Assocaition Type - Other_Institution
	 * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type Staging
	 */
	@AuraEnabled
	public static List<AppForCertHelper.TcObjWrapper > getOtherInstitutionConAssocTypeStagingRefactorMethod(Contact_Association_Type_Staging__c tempconAssocStag, string tempOtherSchoolId) {

		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		if (!tempconAssocStag.Transfer_Credits__r.isEmpty()) {
			for (Transfer_Credit__c tcObjTemp: tempconAssocStag.Transfer_Credits__r) {
				String tcId = tcObjTemp.Id;
				String tcCourse = tcCourseMethod(tcObjTemp);
				String tcGrade = tcObjTemp.Transfer_Credit_Grade__c == null ? '' : tcObjTemp.Transfer_Credit_Grade__c;
				String courseOutcome = tcObjTemp.Course_Outcome__c == null ? '' : tempconAssocStag.Transfer_Credits__r[0].Course_Outcome__c;
				String creditsEarnedMonth = tcObjTemp.Credits_Earned_Month__c == null ? '' : tcObjTemp.Credits_Earned_Month__c;
				String creditsEarnedYear = tcObjTemp.Credits_Earned_Year__c == null ? '' : tcObjTemp.Credits_Earned_Year__c;
				AppForCertHelper.TcObjWrapper tcTemp = new AppForCertHelper.TcObjWrapper(String.valueOf(tcId), String.valueOf(tempOtherSchoolId), tcCourse, tcGrade, courseOutcome, creditsEarnedMonth, creditsEarnedYear);
				tcObjList.add(tcTemp);
			}
		}
		return tcObjList;
	}

	@AuraEnabled
	public static string tcCourseMethod(Transfer_Credit__c tcObjTemp) {
		string tcCourse = tcObjTemp.Transfer_Credit_Course__c == null ? '' : tcObjTemp.Transfer_Credit_Course__c;
		return tcCourse;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getOtherInstitutionConAssocTypeStagingRefactorAssetList
	 * Purpose : Method to get the list of inserted records from Contact Assocaition Type - Other_Institution
	 * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type Staging
	 */
	@AuraEnabled
	public static List<AppForCertHelper.AssetObjWrapper > getOtherInstitutionConAssocTypeStagingRefactorAssetList(Contact_Association_Type_Staging__c tempconAssocStag) {

		List<AppForCertHelper.AssetObjWrapper > assetObjList = new List<AppForCertHelper.AssetObjWrapper > ();
		AppForCertHelper.AssetObjWrapper assetTemp;
		if (!tempconAssocStag.Assets__r.isEmpty()) {
			for (Asset a: tempconAssocStag.Assets__r) {
				assetTemp = new AppForCertHelper.AssetObjWrapper(String.valueOf(a.Id), String.valueOf(a.Document_is_not_in_English__c), String.valueOf(a.Name_on_Document__c), String.valueOf(a.Name_on_Document_is_Different__c), String.valueOf(a.Type__c), String.valueOf(a.Key__c), String.valueOf(a.Parent_Key__c), String.valueOf(a.ParentId));
				assetTemp.azureUrl = a.Azure_Storage_URL__c;
				assetObjList.add(assetTemp);
			}
		}
		return assetObjList;
	}
	// Method to get the list of CV Accepted records from Contact Assocaition Type (Record Type : Other_Institution)
	@AuraEnabled
	public static List<AppForCertHelper.OtherSchoolObjWrapper> getOtherInstitutionConAssocType(){
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		List<AppForCertHelper.OtherSchoolObjWrapper> fetchedValuesToReturn = new List<AppForCertHelper.OtherSchoolObjWrapper>();
		List<Contact_Association_Type__c> medicalschoolsList = new List<Contact_Association_Type__c>([SELECT Id, Case__c, Case__r.Internal_Status__c, Parent_Case__r.Internal_Status__c, Account__c, Account_Name__c, School_Program__c, Student_ID__c, Number_of_Years_Attended__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c, (SELECT Id, To_School__c, From_School__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c FROM Transfer_Credits__r ORDER BY Name ASC), (SELECT Id, Azure_Storage_URL__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Key__c, Parent_Key__c, ParentId FROM Assets__r WHERE Asset.status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION)
			FROM Contact_Association_Type__c
			WHERE Contact__c =: contactId AND recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION 
			AND (Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_ACCEPTED OR Case__r.Internal_Status__c =: Constants.CASE_STATUS_PREV_VERIFIED_ACCEPTED)
			ORDER BY createdDate ASC
		]);
		if(!medicalschoolsList.isEmpty()){
			for(Contact_Association_Type__c tempconAssocStag : medicalschoolsList){
				string tempRecordIdVal = tempconAssocStag.Id;
				string tempOtherSchool = tempconAssocStag.Account_Name__c;
				String tempnumberOfYearsAttended;
				if(tempconAssocStag.Number_of_Years_Attended__c != null){
					tempnumberOfYearsAttended = String.valueOf(tempconAssocStag.Number_of_Years_Attended__c);
				}else{
					tempnumberOfYearsAttended = '';
				}
				string tempOtherSchoolId = tempconAssocStag.Account__c;
				string tempSchoolProgram = tempconAssocStag.School_Program__c;
				string tempStudentId = tempconAssocStag.Student_ID__c;
				string tempSpecialty = tempconAssocStag.Specialty__c;
				string tempFromDate;
				if(tempconAssocStag.Start_Date__c != null){
					tempFromDate = String.valueOf(DateTime.newInstance(tempconAssocStag.Start_Date__c.year(), tempconAssocStag.Start_Date__c.month(), tempconAssocStag.Start_Date__c.day()).format(Constants.DATE_FORMAT));
				}else{
					tempFromDate = '';
				}
				string tempEndDate;
				if(tempconAssocStag.End_Date__c != null){
					tempEndDate = String.valueOf(DateTime.newInstance(tempconAssocStag.End_Date__c.year(), tempconAssocStag.End_Date__c.month(), tempconAssocStag.End_Date__c.day()).format(Constants.DATE_FORMAT));
				}else{
					tempEndDate = '';
				}
				string tempStartMonth = tempconAssocStag.Start_Month__c;
				string tempStartYear = tempconAssocStag.Start_Year__c;
				string tempEndMonth = tempconAssocStag.End_Month__c;
				string tempEndYear = tempconAssocStag.End_Year__c;
				String caseInternalStatus = tempconAssocStag.Case__r.Internal_Status__c;
				string tempTransferCreditsCheckbox = String.valueOf(tempconAssocStag.Transfer_Credit_to_Degree_School__c);
				List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
				tcObjList = getOtherInstitutionConAssocTypeRefactorMethod(tempconAssocStag, tempOtherSchoolId);
				List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
				assetObjList = getOtherInstitutionConAssocTypeRefactorAssetList(tempconAssocStag);
				AppForCertHelper.OtherSchoolObjWrapper tempJsObj;					
				tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, tempFromDate, tempEndDate, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, assetObjList, 'Contact_Association_Type__c', caseInternalStatus);
				tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
				fetchedValuesToReturn.add(tempJsObj);
			}
		}
		return fetchedValuesToReturn;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getOtherInstitutionConAssocTypeRefactorMethod
	 * Purpose : Method to get the list of inserted records from Contact Assocaition Type - Other_Institution
	 * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type
	 */
	@AuraEnabled
	public static List<AppForCertHelper.TcObjWrapper > getOtherInstitutionConAssocTypeRefactorMethod(Contact_Association_Type__c tempconAssocStag, string tempOtherSchoolId) {

		List<AppForCertHelper.TcObjWrapper > tcObjList = new List<AppForCertHelper.TcObjWrapper > ();
		for (Transfer_Credit__c tcObjTemp: tempconAssocStag.Transfer_Credits__r) {
			String tcId = tcObjTemp.Id;
			String tcCourse = tcCourseMethod(tcObjTemp);
			String tcGrade = tcObjTemp.Transfer_Credit_Grade__c == null ? '' : tcObjTemp.Transfer_Credit_Grade__c;
			String courseOutcome = tcObjTemp.Course_Outcome__c == null ? '' : tempconAssocStag.Transfer_Credits__r[0].Course_Outcome__c;
			String creditsEarnedMonth = tcObjTemp.Credits_Earned_Month__c == null ? '' : tcObjTemp.Credits_Earned_Month__c;
			String creditsEarnedYear = tcObjTemp.Credits_Earned_Year__c == null ? '' : tcObjTemp.Credits_Earned_Year__c;
			AppForCertHelper.TcObjWrapper tcTemp = new AppForCertHelper.TcObjWrapper(String.valueOf(tcId), String.valueOf(tempOtherSchoolId), tcCourse, tcGrade, courseOutcome, creditsEarnedMonth, creditsEarnedYear);
			tcObjList.add(tcTemp);
		}
		return tcObjList;
	}

	// Method to get the list of inserted records from Contact Assocaition Type - Other_Institution * Return Type : List of the OtherSchoolObjWrapper instances which wraps Contact Association Type	 
	@AuraEnabled
	public static List<AppForCertHelper.AssetObjWrapper> getOtherInstitutionConAssocTypeRefactorAssetList(Contact_Association_Type__c tempconAssocStag){
		List<AppForCertHelper.AssetObjWrapper> assetObjList = new List<AppForCertHelper.AssetObjWrapper>();
		AppForCertHelper.AssetObjWrapper assetTemp;
		if(!tempconAssocStag.Assets__r.isEmpty()){
			for(Asset a : tempconAssocStag.Assets__r){
				assetTemp = new AppForCertHelper.AssetObjWrapper(String.valueOf(a.Id), String.valueOf(a.Document_is_not_in_English__c), String.valueOf(a.Name_on_Document__c), String.valueOf(a.Name_on_Document_is_Different__c), String.valueOf(a.Type__c), String.valueOf(a.Key__c), String.valueOf(a.Parent_Key__c), String.valueOf(a.ParentId));
				assetTemp.azureUrl = a.Azure_Storage_URL__c;
				assetObjList.add(assetTemp);
			}
		}
		return assetObjList;
	}

	/**
	 * Created by Nayana
	 * Method Name: reSubmitAppforCert
	 * Purpose : Method to resubmit the Application for Certification from Exam Registration
	 * Return Type : Boolean
	 */
	@AuraEnabled(Cacheable = false)
	public static Boolean reSubmitAppforCert() {
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		Boolean isGraduate = false;
		Boolean hasTransferCredits = false;
		Boolean returnVal = false;
		String catsDegMedSchoolAccountId;
		String conId = String.valueOf(contactId);
		List<Contact_Association_Type_Staging__c > catsToUpdate = new List<Contact_Association_Type_Staging__c > ();
		List<Contact_Association_Type_Staging__c > catsToDelete = new List<Contact_Association_Type_Staging__c > ();
		Case newCase = [SELECT Id, Graduate_affirmation_required__c, Transfer_credit_affirmation_required__c, Internal_Status__c FROM Case
			WHERE Case.Id =: caseId
			LIMIT 1
		];
		List<Contact_Association_Type_Staging__c > tempCatsList = new List<Contact_Association_Type_Staging__c > ();
		tempCatsList = [SELECT Id, Name, Account__c, Contact__r.Id, Case__r.Id, Status__c, Is_Reopened_Exam_Reg__c, RecordType.Name, RecordType.DeveloperName, Case__r.Graduate_affirmation_required__c, Case__r.Transfer_credit_affirmation_required__c, Transfer_Credit_to_Degree_School__c FROM Contact_Association_Type_Staging__c
			WHERE Contact__r.Id =: contactId
			AND Case__r.Id =: caseId
			AND(RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG OR RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG OR RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG OR RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL)
		];
		List<Contact_Association_Type__c > catDegMedSchoolRecord = [SELECT RecordType.DeveloperName, Account__c
			FROM Contact_Association_Type__c
			WHERE Contact__c =: contactId
			AND RecordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
			LIMIT 1
		];
		String catDegMedSchoolAccountId = catDegMedSchoolRecord[0].Account__c;
		if (!tempCatsList.isEmpty()) {
			for (Contact_Association_Type_Staging__c cats: tempCatsList) {
				if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL) {
					catsToDelete.add(cats);
				} else if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG && cats.Status__c == Constants.CONASCTYPESTG_STATUS_GRADUATE) {
					cats.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
					newCase.Graduate_affirmation_required__c = true;
					cats.Is_Reopened_Exam_Reg__c = true;
					isGraduate = true;
					catsToUpdate.add(cats);
					catsDegMedSchoolAccountId = cats.Account__c;
				} else if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG) {
					Contact_Association_Type_Staging__c catsAffirmationCheck = checkAffirmationFlag(catDegMedSchoolAccountId, cats);
					catsToUpdate.add(catsAffirmationCheck);
					catsDegMedSchoolAccountId = cats.Account__c;
				} else if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG && cats.Transfer_Credit_to_Degree_School__c == true) {
					cats.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
					newCase.Transfer_credit_affirmation_required__c = true;
					cats.Is_Reopened_Exam_Reg__c = true;
					hasTransferCredits = true;
					catsToUpdate.add(cats);
				} else if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG) {
					cats.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
					catsToUpdate.add(cats);
				} else if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG) {
					cats.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
					newCase.Transfer_credit_affirmation_required__c = true;
					cats.Is_Reopened_Exam_Reg__c = true;
					hasTransferCredits = true;
					catsToUpdate.add(cats);
				}
			}
		}
		if (!catsToUpdate.isEmpty()) {
			update catsToUpdate;
		}
		updateOldAssetsCatIdToNewCatID(catsToDelete, catsToUpdate, contactId, caseId);
		if (!catsToDelete.isEmpty()) {
			delete catsToDelete;
		}
		//AppForCert Summary PDF	
		List<cadmus_core__Doc_Config__c> docConfigList = [SELECT Id,cadmus_core__View_Customer_DocConfig_Id__c FROM cadmus_core__Doc_Config__c WHERE Name = 'AppForCert Summary' WITH SECURITY_ENFORCED];
        Id docConfigId = docConfigList[0].Id;				
		if(String.isNotBlank(docConfigId)){
			PDFButlerCallout calloutClass = new PDFButlerCallout(docConfigId, caseId);
			System.enqueueJob(calloutClass);
		}
		returnVal = updateCaseonResubmit(isGraduate, hasTransferCredits, newCase, catsDegMedSchoolAccountId);		
		return returnVal;
	}

	/**
	 * Created by Jofrin
	 * Method Name: checkAffirmationFlag
	 * Purpose : Method to update the is reopened exam reg flag if medical school is changed
	 * Return Type : Contact_Association_Type_Staging__c
	 * @Params : String and Contact_Association_Type_Staging__c record
	 */
	public static Contact_Association_Type_Staging__c checkAffirmationFlag(String catDegMedSchoolAccountId, Contact_Association_Type_Staging__c cats) {
		String catsDegMedSchoolAccountId = cats.Account__c;
		cats.RecordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId();
		if (catDegMedSchoolAccountId != catsDegMedSchoolAccountId) {
			cats.Is_Reopened_Exam_Reg__c = true;
		}
		return cats;
	}
	/**
	 * Created by Nayana
	 * Method Name: updateCaseonResubmit
	 * Purpose : Method to update case on resubmit of Application for Certification from Exam Registration
	 * Return Type : Boolean
	 * @Params : Boolean values and Case object
	 */
	public static Boolean updateCaseonResubmit(Boolean isGraduate, Boolean hasTransferCredits, Case newCase, String catsDegMedSchoolAccountId) {
		List<Case> caseToUpdate = new List<Case> ();
		Boolean returnVal = false;
		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();

		List<Asset> assetList = new List<Asset> ();
		List<Asset> assetListToBeUpdated = new List<Asset> ();

		Set<String> keySet = new Set<String> {
			System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT
		};
		assetList = [Select Id, Case__c, Name_on_Document__c, Is_Expired_Exam_Reg__c, Name_on_Document_is_Different__c, Document_is_not_in_English__c, Dean_s_Letter_Date__c
			from Asset where ContactId =: contactId AND status !=: Constants.ASSET_STATUS_IN_PROGRESS AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND key__c in: keySet AND IsExpired__c = FALSE AND IsOrphan__c = FALSE
			AND Case__c =: caseId
		];
		if (!assetList.isEmpty()) {
			for (Asset eachAsset: assetList) {
				eachAsset.Is_Expired_Exam_Reg__c = true;
				assetListToBeUpdated.add(eachAsset);
			}
		}
		try {
			if (!assetListToBeUpdated.isEmpty()) {
				update assetListToBeUpdated;
			}
		} catch (Exception e) {
			System.debug('Exception Asset Update::' + e.getMessage());
		}

		// User Story 8292
		// App for Cert manual review when edited App for Cert has a change of Degree School
		List<Contact_Association_Type__c > catDegMedSchoolRecord = [SELECT RecordType.DeveloperName, Account__c
			FROM Contact_Association_Type__c
			WHERE Contact__c =: contactId
			AND RecordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL
			LIMIT 1
		];
		String catDegMedSchoolAccountId = catDegMedSchoolRecord[0].Account__c;

		if (isGraduate == true || hasTransferCredits == true || catDegMedSchoolAccountId != catsDegMedSchoolAccountId) {
			newCase.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED;
			newCase.Is_Reopened_Exam_Reg__c = true;
			caseToUpdate.add(newCase);

			// User Story 8292 - Add the language "Degree School Changed" to the "Manual Review Reasons" field on the AppForCert case.
			if (catDegMedSchoolAccountId != catsDegMedSchoolAccountId) {
				newCase.Manual_Review_Reasons__c = Constants.CASE_DEFICIENCY_REASON_DEGREE_SCHOOL_CHANGED;
			}

			Group g = [SELECT Id, name, Group.DeveloperName FROM Group
				WHERE Type = 'Queue'
				and Group.DeveloperName =: Constants.QUEUE_APP_FOR_CERT
			];
			newCase.OwnerId = g.Id;
			returnVal = true;
		} else if (isGraduate == false && hasTransferCredits == false) {
			newCase.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED;
			newCase.Is_Reopened_Exam_Reg__c = true;
			update newCase;
			newCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
			caseToUpdate.add(newCase);
			try {
				returnVal = true;
				sendMailForAcceptedStatus(contactId, caseId);
			} catch (Exception e) {
				System.debug('Exception::' + e.getMessage());
			}
		}
		//create CV case
        AppForCertHelper.creatCVCaseForAppForCert(true, caseId, contactId);
		if (!caseToUpdate.isEmpty()) {
			update caseToUpdate;
		}

		return returnVal;
	}
	/**
	 * Created by Femi
	 * Method Name: getReporterQuestionValue
	 * Purpose : Method to get reporter question value in contact
	 * Return Type : Boolean
	 */
	@AuraEnabled
	public static Boolean getReporterQuestionValue() {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();

		Contact updRepQuesVal = [Select Id, ECFMG_Reporter__c from Contact Where id =: contactId];
		Boolean returnValue = updRepQuesVal.ECFMG_Reporter__c;

		return returnValue;
	}
	/**
	 * Created by Nayana
	 * Method Name: getContactDetails
	 * Purpose : Method to get contact details
	 * Return Type : Contact
	 */
	@AuraEnabled
	public static Contact getContactDetails() {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();

		Contact contactDetail = [SELECT Id, LastName, FirstName, Generational_Suffix__c, Gender__c,
			MailingCountry, MailingStreet, MailingCity, MailingState, MailingPostalCode,
			Email, Phone, Citizenship_Upon_Entering_Medical_School__c
			FROM Contact
			WHERE id =: contactId
		];

		return contactDetail;
	}

	/* Purpose : Method to get case id irrespective of case status*/
	@AuraEnabled
	public static Id getCaseIdAllStatus(Boolean showCaseDetail, Id contactId) {
		Id caseId;
		if(!showCaseDetail) {
			caseId = AppForCertHelper.getCaseId();
		}else{
			caseId = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId order by CreatedDate Desc LIMIT 1].Id;
		}
		return caseId;
	}
	/**
	 * Created by Femi
	 * Method Name: updateTrasferCredit
	 * Purpose : Method to update transfer credit records
	 * Return Type : TcredObjWrapper
	 */
	@AuraEnabled
	public static AppForCertHelper.TcredObjWrapper updateTrasferCredit(AppForCertHelper.incompleteSchoolObjWrapper jsObj, String caseId) {
		Set<String> tcDelStagingId = new Set<String> ();
		Id currentUser = AppForCertHelper.retrieveCurrentContactId();
		List<Transfer_Credit__c > tcsToUpsert = new List<Transfer_Credit__c > ();
		if (jsObj.tcWrapperList != null && jsObj.tcWrapperList.size() > 0) {
			for (AppForCertHelper.tcObjWrapper childTc: jsObj.tcWrapperList) {
				Transfer_Credit__c tcToUpsert = new Transfer_Credit__c();
				if (String.isNotBlank(childTc.recordIdVal)) {
					tcToUpsert.Id = childTc.recordIdVal;
				}

				tcToUpsert.Applicant__c = currentUser;
				tcToUpsert.Contact_Association_Type_Staging__c = jsObj.recordIdVal;
				tcToUpsert.From_School__c = childTc.fromSchool;
				tcToUpsert.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tcToUpsert.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tcToUpsert.Course_Outcome__c = childTc.courseOutcome;
				tcToUpsert.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tcToUpsert.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tcToUpsert.Case__c = caseId;

				tcDelStagingId.add(jsObj.recordIdVal);
				tcsToUpsert.add(tcToUpsert);
			}
		}
		AppForCertHelper.TcredObjWrapper response = new AppForCertHelper.TcredObjWrapper(tcsToUpsert, tcDelStagingId);
		return response;
	}
	/**
	 * Created by Femi
	 * Method Name: updateAssetList
	 * Purpose : Method to update asset records
	 * Return Type : AssetObjctWrapper
	 */
	@AuraEnabled
	public static AppForCertHelper.AssetObjctWrapper updateAssetList(AppForCertHelper.incompleteSchoolObjWrapper jsObj, Contact_Association_Type_Staging__c tempContAssoTypeStag) {
		Set<String> stagingIds = new Set<String> ();
		Set<String> allAssetId = new Set<String> ();
		List<String> allAssetSet = new List<String> ();
		List<Asset> assetsToUpdate = new List<Asset> ();
		if (jsObj.assets.size() > 0) {

			for (AppForCertHelper.IncompleteAssetObjWrapper a: jsObj.assets) {
				Asset tempAsset = new Asset(id = a.recordIdVal);
				tempAsset.Contact_Association_Type_Staging__c = jsObj.recordIdVal;
				tempAsset.Document_is_not_in_English__c = a.docNotInEnglish == 'true';
				tempAsset.Name_on_Document__c = a.nameOnDoc;
				tempAsset.Name_on_Document_is_Different__c = a.nameOnDocIsDifferent == 'true';
				if (String.isNotBlank(a.deanDate)) {

					tempAsset.Dean_s_Letter_Date__c = Date.valueof(a.deanDate);
				}
				String mapVal = '';
				mapVal = tempContAssoTypeStag.Id + '-' + a.type;
				if (String.isNotBlank(a.parentAssetId)) {
					tempAsset.parentId = a.parentAssetId;
					mapVal = mapVal + '-' + a.parentAssetId;
				}
				tempAsset.IsOrphan__c = False;

				stagingIds.add(tempContAssoTypeStag.Id);
				allAssetSet.add(mapVal);
				allAssetId.add(a.recordIdVal);

				assetsToUpdate.add(tempAsset);
			}
		}
		AppForCertHelper.AssetObjctWrapper response = new AppForCertHelper.AssetObjctWrapper(stagingIds, allAssetSet, allAssetId, assetsToUpdate);
		return response;
	}	
	//Method to get existingAssetTypes
	public static Set<String> getExistingAssetType(Set<String> allAssetId, String caseId, Map<String, String> assetTypeMap) {
		Set<String> existingAssetType = new Set<String> ();
		for (Asset rootAss: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Id IN: allAssetId
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			String val = '';
			val = rootAss.Contact_Association_Type_Staging__c + '-' + rootAss.Type__c;
			if (String.isNotBlank(rootAss.parentId)) {
				val = val + '-' + assetTypeMap.get(rootAss.parentId);
			}
			if (String.isNotBlank(rootAss.RootAssetId)) {
				val = val + '-' + assetTypeMap.get(rootAss.RootAssetId);
			}
			existingAssetType.add(val);
		}
		return existingAssetType;
	}
	// Method to get ExpiredAssetList
	public static List<Asset> getExpiredAssetList(List<Asset> tctMarkNameTransToExpList, Set<String> existingAssetType, Boolean isExamReOpened, Map<String, String> assetTypeMap) {
		List<Asset> expiredAssetList = new List<Asset> ();
		for (Asset a: tctMarkNameTransToExpList) {

			if (assetTypeMap.get(a.RootAssetId) == Constants.ASSET_TYPE_TCT && a.Type__c != Constants.ASSET_TYPE_TCT) {
				String val = '';
				val = a.Contact_Association_Type_Staging__c + '-' + a.Type__c + '-' + assetTypeMap.get(a.parentId) + '-' + assetTypeMap.get(a.RootAssetId);

				if (existingAssetType.contains(val)) {
					Asset exp = new Asset(Id = a.Id);
					if (isExamReOpened) {
						exp.Is_Expired_Exam_Reg__c = true;
					} else {
						exp.IsExpired__c = true;
					}

					expiredAssetList.add(exp);

				}
			}
		}
		return expiredAssetList;
	}
	//Method to get ExpiredAsset
	public static List<Asset> getExpiredAssets(Set<String> allAssetId, String caseId, Boolean isExamReOpened) {
		List<Asset> expiredAssetList = new List<Asset> ();
		Set<String> rootAllAsset = new Set<String> ();
		Set<String> rootTCTStagingIds = new Set<String> ();
		Set<String> rootTCTAsset = new Set<String> ();
		for (Asset rootAss: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Id IN: allAssetId
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			rootAllAsset.add(rootAss.RootAssetId);
		}
		for (Asset rootAss: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		       (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Id IN: rootAllAsset and Type__c =: Constants.ASSET_TYPE_TCT
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			rootTCTStagingIds.add(rootAss.Contact_Association_Type_Staging__c);
			rootTCTAsset.add(rootAss.Id);
		}
		Set<String> tctRootVal = new Set<String> ();
		for (Asset rootAss: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Id Not IN: rootTCTAsset and Type__c =: Constants.ASSET_TYPE_TCT
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			if (rootTCTStagingIds.contains(rootAss.Contact_Association_Type_Staging__c)) {
				tctRootVal.add(rootAss.Id);
			}
		}
		List<Asset> allRootAssetForEntireTCTToExp = new List<Asset> ();
		if (isExamReOpened) {
			allRootAssetForEntireTCTToExp = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId IN: tctRootVal and Is_Expired_Exam_Reg__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = True
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		} else {
			allRootAssetForEntireTCTToExp = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId IN: tctRootVal and IsExpired__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = False
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		for (Asset rootAss: allRootAssetForEntireTCTToExp) {
			Asset exp = new Asset(Id = rootAss.Id);
			if (isExamReOpened) {
				exp.Is_Expired_Exam_Reg__c = true;
			} else {
				exp.IsExpired__c = true;
			}
			expiredAssetList.add(exp);
		}
		return expiredAssetList;
	}
    // Method to get ExpiredAssets except TCT
	public static List<Asset> getExpiredAssetsExptTct(Set<String> allAssetId, String caseId, Boolean isExamReOpened) {
		List<Asset> expiredAssetList = new List<Asset> ();
		Set<String> rootAssetIds = new Set<String> ();
		Set<String> rootType = new Set<String> ();
		Set<String> rootActual = new Set<String> ();
		for (Asset rootAss: [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
		        (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And Id IN: allAssetId
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			if (rootAss.Id == rootAss.RootAssetId && rootAss.Type__c != Constants.ASSET_TYPE_TCT) {
				rootType.add(rootAss.Contact_Association_Type_Staging__c + '-' + rootAss.Type__c);
				rootAssetIds.add(rootAss.RootAssetId);
			}
		}
		List<Asset> nonTCTAssetList = new List<Asset> ();
		if (isExamReOpened) {
			nonTCTAssetList = [Select Id, Type__c, RootAssetId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId Not IN: rootAssetIds and Is_Expired_Exam_Reg__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = True
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		} else {
			nonTCTAssetList = [Select Id, Type__c, RootAssetId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId Not IN: rootAssetIds and IsExpired__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = False
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		for (Asset root: nonTCTAssetList) {
			String toCom = '';
			toCom = root.Contact_Association_Type_Staging__c + '-' + root.Type__c;
			if (rootType.contains(toCom)) {
				rootActual.add(root.RootAssetId);
			}
		}
		List<Asset> nonTCTAssetToMarkExp = new List<Asset> ();
		if (isExamReOpened) {
			nonTCTAssetToMarkExp = [Select Id, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId IN: rootActual and Is_Expired_Exam_Reg__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = true
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		} else {
			nonTCTAssetToMarkExp = [Select Id, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
			    (recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_CREDENTIAL OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_IDENTITY OR recordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_APP_FOR_CERT)
				And RootAssetId IN: rootActual and IsExpired__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = false
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		expiredAssetList =  expiredAssetsListRF(nonTCTAssetToMarkExp,isExamReOpened); 
		return expiredAssetList;
	}
	//Method to return expired List
	public static List<Asset> expiredAssetsListRF(List<Asset> nonTCTAssetToMarkExp,Boolean isExamReOpened) {
        List<Asset> expiredAssetList = new List<Asset>();
        for (Asset allAsset: nonTCTAssetToMarkExp) {
			Asset exp = new Asset(Id = allAsset.Id);
			if (isExamReOpened) {
				exp.Is_Expired_Exam_Reg__c = true;
			} else {
				exp.IsExpired__c = true;
			}
			expiredAssetList.add(exp);

		}
		return expiredAssetList;
	}

	/**
	 * Created by Femi
	 * Method Name: updateExpiredAssets
	 * Purpose : Method to update Expired Assets
	 * Return Type : 
	 */
	public static void updateExpiredAssets(List<Asset> expiredAssetList) {
		if (!expiredAssetList.isEmpty()) {
			Set<Asset> duplicateAsset = new Set<Asset> ();
			duplicateAsset.addall(expiredAssetList);

			List<Asset> uniqueExpiredList = new List<Asset> ();
			uniqueExpiredList.addall(duplicateAsset);

			if (!uniqueExpiredList.isEmpty()) {
				update uniqueExpiredList;
			}
		}
	}
	//Method to delete orphaned Assets
	public static void dltOrphanedAssets(Set<String> delStagingIds, Boolean isExamReOpened) {
		List<Asset> delOrphanedAssetList = new List<Asset>();
		List<Asset> delOrphanedAsset = new List<Asset>();
		if (isExamReOpened) {
			delOrphanedAssetList = [Select Id from Asset where Contact_Association_Type_Staging__c IN: delStagingIds and IsOrphan__c = True and
				Is_Expired_Exam_Reg__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = True
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		} else {
			delOrphanedAssetList = [Select Id from Asset where Contact_Association_Type_Staging__c IN: delStagingIds and IsOrphan__c = True and
				IsExpired__c = False and Contact_Association_Type_Staging__r.Is_Reopened_Exam_Reg__c = False
				AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			];
		}
		for (Asset del: delOrphanedAssetList) {
			delOrphanedAsset.add(del);
		}
		if (!delOrphanedAsset.isEmpty()) {
			List<Asset> updExistingOrphanAssetList = new List<Asset>();
			for(Asset dec:delOrphanedAsset){
				Asset recAc = new Asset(Id = dec.Id);
				recAc.Case__c = null;
				recAc.Contact_Association_Type_Staging__c =null;
				recAc.Contact_Association_Type__c = null;
				recAc.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				recAc.recordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION).getRecordTypeId();
				updExistingOrphanAssetList.add(recAc);
			}
			if (!updExistingOrphanAssetList.isEmpty()) {
				update updExistingOrphanAssetList;
			}
		}
	}
	/**
	 * Created by Femi
	 * Method Name: updateIncompleteAssets
	 * Purpose : Method to update incomplete Assets
	 * Return Type : 
	 */
	public static void updateIncompleteAssets(List<Transfer_Credit__c > tcsToUpsert, Set<String> tcDelStagingId, Boolean isExamReOpened, String caseId) {
		List<Transfer_Credit__c > tcListForDel = new List<Transfer_Credit__c > ();
		if (!tcsToUpsert.isEmpty()) {
			upsert tcsToUpsert;

			if (!tcDelStagingId.isEmpty()) {
				for (Transfer_Credit__c tc: [Select Id, Contact_Association_Type_Staging__c from Transfer_Credit__c
						where Id Not IN: tcsToUpsert And Contact_Association_Type_Staging__c IN: tcDelStagingId
					]) {
					tcListForDel.add(tc);
				}
				if (!tcListForDel.isEmpty()) {
					delete tcListForDel;
				}
				List<Asset> tcAssetList = new List<Asset> ();

				if (isExamReOpened) {
					tcAssetList = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
						recordTypeId =: Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId()
						And Contact_Association_Type_Staging__c IN: tcDelStagingId and Is_Expired_Exam_Reg__c = False
						AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
					];
				} else {
					tcAssetList = [Select Id, RootAssetId, IsExpired__c, Name, Type__c, parentId, Contact_Association_Type_Staging__c from Asset where Case__c =: caseId and
						recordTypeId =: Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId()
						And Contact_Association_Type_Staging__c IN: tcDelStagingId and IsExpired__c = False
						AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
					];
				}

				updateIncompleteAssetsRfctr(tcAssetList);
			}
		}
	}
	/**
	 * Created by Femi
	 * Method Name: updateIncompleteAssetsRfctr
	 * Purpose : Method to reduce conplexity of updateIncompleteAssets method
	 * Return Type : 
	 */
	public static void updateIncompleteAssetsRfctr(List<Asset> tcAssetList) {
		List<Asset> assetToMarkIncomp = new List<Asset> ();
		Set<Id> tcRootAssetId = new Set<Id> ();
		for (Asset rootAss: tcAssetList) {
			tcRootAssetId.add(rootAss.RootAssetId);
		}

		for (Asset asst: [Select Id, RootAssetId, status, Contact_Association_Type_Staging__c from Asset where
				RootAssetId IN: tcRootAssetId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION
			]) {
			if (asst.status == Constants.ASSET_STATUS_INCOMPLETE) {
				Asset a = new Asset(Id = asst.Id);
				a.Status = Constants.ASSET_STATUS_IN_PROGRESS;
				assetToMarkIncomp.add(a);
			}
		}

		if (!assetToMarkIncomp.isEmpty()) {
			update assetToMarkIncomp;
		}
	}
	/**
	 * Created by Femi
	 * Method Name: getApplicationStatus
	 * Purpose : Method to find application status that has to displayed on appforcert screen
	 * Return Type : 
	 */
	@AuraEnabled
	public static String getApplicationStatus() {
		String responseString = 'Not Started';
		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		List<case >newCases = [SELECT id, External_Status__c, Internal_Status__c FROM Case
				WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT
				AND ContactId =: contactId
				AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED AND Internal_Status__c !=: Constants.CASE_STATUS_EXPIRED AND Internal_Status__c !=: Constants.CASE_STATUS_CANCELLED];
			if (!newCases.isEmpty()) {
			if (newCases[0].Internal_Status__c == Constants.CASE_STATUS_PENDING_SUBMISSION) {
				responseString = Constants.CASE_STATUS_PENDING_SUBMISSION;
			} else {
				responseString = newCases[0].External_Status__c;
			}
		}
		return responseString;
	}
	// Method to return whether applicant is ECFMG certified
	@AuraEnabled
	public static Boolean checkIfCertified(){
		Id contactId = AppforCertHelper.retrieveCurrentContactId();
		List<case> certifiedCaseList = [SELECT id FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION
				AND ContactId =: contactId
				AND Certificate_Issue_Date__c != null WITH SECURITY_ENFORCED
			];
		if(certifiedCaseList.isEmpty()){
			return false;
		}
		return true;
	}
	// Method to reject open Exam Registration case when AppForCert Case is Rejected
	@AuraEnabled
	public static void examRegistrationCheckOnStatus(List<Case> cases) {
		List<Case> rejectedCases = new List<Case> ();
		List<String> contactList = new List<String> ();
		Set<String> contactSet = new Set<String> ();
		Set<String> caseId = new Set<String> ();
		List<Case> listToUpdate = new List<Case> ();
		for (integer count = 0; count<cases.size(); count++) {
			if (cases[count].Internal_Status__c == Constants.CASE_STATUS_REJECTED) {
				rejectedCases.add(cases[count]);
				contactList.add(cases[count].ContactId);
			}
		}
		if (rejectedCases.size() > 0) {
			contactSet.addAll(contactList);
		}
		List<Case> casesToReject = new List<Case> ();
		Set<String> caseStatus = new Set<String> {
			Constants.CASE_STATUS_PENDING_CIBIS, Constants.CASE_STATUS_REGISTERED
		};
		casesToReject = [SELECT Id, Internal_Status__c, External_Status__c, Enrollment_Verification_Parent__c ,(SELECT Id, Exam_taken_date__c, Exam_Status__c FROM Exam_Registrations__r WHERE Exam_taken_date__c = NULL AND Exam_Status__c = NULL) FROM Case WHERE RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION
			            AND ContactId =: contactSet AND Internal_Status__c NOT IN: caseStatus WITH SECURITY_ENFORCED];
		if (casesToReject.size() > 0) {
			for (integer i = 0; i<casesToReject.size(); i++) {
				caseId.add(casesToReject[i].Enrollment_Verification_Parent__c);
				casesToReject[i].Internal_Status__c = Constants.CASE_STATUS_REJECTED;
				casesToReject[i].Deficiency_Reason_RTF__c = Constants.CASE_DEFICIENCY_REASON_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(casesToReject[i]);
			}
		}
		if (caseId.size() > 0) {
			listToUpdate = [Select Id, Internal_Status__c from Case where Id =: caseId];
			for (integer j = 0; j<listToUpdate.size(); j++) {
				listToUpdate[j].Internal_Status__c = Constants.CASE_STATUS_CLOSED_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(listToUpdate[j]);
			}
		}
		List<Case> openCases = new List<Case> ();
		openCases = [SELECT Id, Internal_Status__c, External_Status__c, Enrollment_Verification_Parent__c, Exam_Registration__c FROM Case WHERE RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION
			AND ContactId =: contactSet AND Internal_Status__c IN: caseStatus WITH SECURITY_ENFORCED];
		if (openCases.size() > 0) {
			refactorExamRegistrationCheckOnStatus(openCases);
		} else {
			if (Case.SObjectType.getDescribe().isUpdateable()) {
				List<Case> copyCaseVal = new List<Case>(casesToRejectFinal);
                update copyCaseVal;
			}
		}
	}

	@AuraEnabled
	public static void refactorExamRegistrationCheckOnStatus(List<Case> openCases) {
		List<String> casesRejectList = new list<String> ();
		List<String> examsId = new List<String> ();
		for (integer countVar = 0; countVar<openCases.size(); countVar++) {
			examsId.add(openCases[countVar].Id);
		}
		List<Exam_Registration__c > examRecs = new List<Exam_Registration__c > ();
		examRecs = [Select Id, Exam_taken_date__c, Exam_Status__c, Case__c from Exam_Registration__c where Case__c IN: examsId];
		for (integer countLoop = 0; countLoop<examRecs.size(); countLoop++) {
			if (examRecs[countLoop].Exam_taken_date__c == NULL && examRecs[countLoop].Exam_Status__c == NULL) {
				casesRejectList.add(examRecs[countLoop].Case__c);
			}
		}
		if (casesRejectList.size() > 0) {
			List<Case> updateReject = new List<Case> ();
			for (integer iCount = 0; iCount<casesRejectList.size(); iCount++) {
				Case newCase = new Case();
				newCase.Id = casesRejectList[iCount];
				newCase.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
				newCase.Deficiency_Reason_RTF__c = Constants.CASE_DEFICIENCY_REASON_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(newCase);
			}
			List<Case> casesToClose = new List<Case> ();
			casesToClose = [Select Enrollment_Verification_Parent__c from Case where Id =: casesRejectList];
			List<String> parentCase = new List<String> ();
			for (integer jCount = 0; jCount<casesToClose.size(); jCount++) {
				parentCase.add(casesToClose[jCount].Enrollment_Verification_Parent__c);
			}
			casesToClose.clear();
			casesToClose = [Select Id, Internal_Status__c from Case where Id IN: parentCase];
			for (Case c: casesToClose) {
				c.Internal_Status__c = Constants.CASE_STATUS_CLOSED_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(c);
			}

			refactorExamRegn(casesRejectList);
		}
	}

	//Method to check status of Epex Cases and change status of it
	public static void refactorEpexExamCase(List<String> casesRejectList){
		List<Case> checkEPEXCase = new List<Case>();
		if(Case.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Case.fields.Enrollment_Verification_Parent__c.isAccessible() && Schema.SObjectType.Case.fields.Id.isAccessible()){
			Set<String> statusString = new Set<String>();
			statusString.add(Constants.CASE_STATUS_PENDING_CIBIS);
			statusString.add(Constants.CASE_STATUS_REJECTED);
			statusString.add(Constants.CASE_STATUS_ACCEPTED);
			checkEPEXCase = [Select Id, Enrollment_Verification_Parent__c from Case where ParentId IN: casesRejectList And RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND Status NOT IN: statusString];
		}
		if(!checkEPEXCase.isEmpty()){
			Set<String> idList = new Set<String>();
			for (Case loopVar: checkEpEXCase){
				loopVar.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
				idList.add(loopVar.Enrollment_Verification_Parent__c);
				casesToRejectFinal.add(loopVar);
			}
			List<Case> evCase = new List<Case>();
			evCase = [Select Id, Internal_Status__c from Case where Id IN: idList];
			for(Case loopVariable: evCase){
				loopVariable.Internal_Status__c = Constants.CASE_STATUS_CLOSED_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(loopVariable);
			}
		}
		if(!casesToRejectFinal.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
			Map<Id, Case> caseMap = new Map<Id, Case>();
			for(Case newCase : casesToRejectFinal){
				caseMap.put(newCase.Id, newCase);
			}
			update caseMap.values();
		}
	}

	// Method used in Graduate screen to check whether asset status is accepted for appforcert updating method.
	@AuraEnabled(cacheable = false)
	public static Boolean getAssetStatusAndType(String contactId, String contactAssociationType, String assetName){
		Boolean returnValue = False;
		List<Asset> assetList = new List<Asset>();
		if (contactAssociationType != '' && contactAssociationType != 'null' && contactAssociationType != 'undefined'){
			assetList = [SELECT Id, Status, Name, Type__c FROM Asset WHERE ContactId =: contactId AND Type__c =: assetName
				AND Contact_Association_Type__c =: contactAssociationType AND IsOrphan__c = FALSE ORDER BY CreatedDate DESC LIMIT 1];
		}
		if(!assetList.isEmpty()){
			if(assetList[0].Status == Constants.ASSET_STATUS_ACCEPTED || assetList[0].Status == Constants.ASSET_STATUS_EXPIRED){
				returnValue = True;
			}
		}
		return returnValue;
	}

	/**
	 * Created by Jofrin
	 * Method Name: getDeanLetterExpiredStatus
	 * Purpose : Method used in Graduate screen to check whether asset status is accepted for final Transcript.
	 * Return Type : Boolean
	 */
	@AuraEnabled(cacheable = false)
	public static Boolean getDeanLetterExpiredStatus(String contactId, String contactAssociationType) {
		Boolean returnValueDL = False;
		String keyval = System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT;
		List<Asset> assetDLList = new List<Asset> ();
		if (contactAssociationType != '' && contactAssociationType != 'null' && contactAssociationType != 'undefined') {
			assetDLList = [Select Id, Status, Name, Type__c from Asset where ContactId =: contactId AND Key__c =: keyval
				AND Contact_Association_Type_Staging__c =: contactAssociationType AND IsOrphan__c = FALSE Order By CreatedDate Desc Limit 1
			];
		}
		if (!assetDLList.isEmpty() && assetDLList[0].Status == Constants.ASSET_STATUS_EXPIRED) {
			returnValueDL = True;
		}
		return returnValueDL;
	}

	/**
	 * Created by Jofrin
	 * Method Name: updateOldAssetsCatIdToNewCatID
	 * Purpose : Method to update old existing accepted Assets with the new CAT record id during resubmitting the AppForCert Process .
	 * Return Type : Boolean
	 */
	@AuraEnabled(cacheable = false)
	public static void updateOldAssetsCatIdToNewCatID(List<Contact_Association_Type_Staging__c > catsToDelete, List<Contact_Association_Type_Staging__c > catsToUpdate, Id contactId, Id caseId) {

		Set<String> keySet = new Set<String> {
			System.Label.App_for_Cert_DIPLOMA_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT,
			System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT,
			System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT,
			System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_NAME_DOCUMENT
		};

		Id newCatIdToAssociate;
		List<Asset> assetList = new List<Asset> ();
		List<Asset> assetListToUpdate = new List<Asset> ();

		if (!catsToDelete.isEmpty()) {
			assetList = [Select Id, Status, Name, Type__c, Contact_Association_Type_Staging__c from Asset where ContactId =: contactId
				AND Contact_Association_Type_Staging__c =: catsToDelete[0].Id AND key__c in: keySet AND Case__c =: caseId
			];

			for (Contact_Association_Type_Staging__c eachCats: catsToUpdate) {
				if (eachCats.RecordTypeId == Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL).getRecordTypeId()) {
					newCatIdToAssociate = eachCats.Id;
				}
			}
			for (Asset eachAsset: assetList) {
				eachAsset.Contact_Association_Type_Staging__c = newCatIdToAssociate;
				assetListToUpdate.add(eachAsset);
			}
		}
		try {
			if (!assetListToUpdate.isEmpty()) {
				update assetListToUpdate;
			}
		} catch (Exception e) {
			System.debug('Exception assetupdate::' + e.getMessage());
		}

	}

	//Method to check Status of Enrollment Reverification Parent and set status
	public static void refactorExamRegn(List<String> casesRejectList) {
		List<Case> reverificationParent = new List<Case> ();
		if (Case.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Case.fields.Enrollment_Re_Verification_Parent__c.isAccessible()) {
			reverificationParent = [Select Enrollment_Re_Verification_Parent__c from Case where Id =: casesRejectList];
		}
		List<Case> casesToClose = new List<Case> ();
		if (reverificationParent.size() > 0) {
			List<String> reverificationCases = new List<String> ();
			for (integer countVar = 0; countVar<reverificationParent.size(); countVar++) {
				reverificationCases.add(reverificationParent[countVar].Enrollment_Re_Verification_Parent__c);
			}
			if (Case.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Case.fields.Id.isAccessible() && Schema.SObjectType.Case.fields.Status.isAccessible()) {
				casesToClose = [Select Id, Internal_Status__c from Case where Id IN: reverificationCases AND Status !=: Constants.CASE_STATUS_ENROLLMENT_VERIFIED];
			}
			for (Case c: casesToClose) {
				c.Internal_Status__c = Constants.CASE_STATUS_CLOSED_NO_LONGER_ELIGIBLE;
				casesToRejectFinal.add(c);
			}
		}
		refactorEpexExamCase(casesRejectList);
	}

	//metho to check if any change is made during update my application for a Graduate.
	@AuraEnabled
	public static string checkGradValOnSummary() {

		Boolean otherInstExist = checkExamRegOtherInstitutions();
		Boolean finalMedOrDeanLetExist = checkFinalMedDipOrDeanLet();
		String otherMedSchoolExist = checkExamRegOtherMedSchoolTC();

		if (otherInstExist || finalMedOrDeanLetExist || otherMedSchoolExist == 'True') {
			return 'false';
		} else if (otherMedSchoolExist == 'RecordNoTc') {
			return 'SecondaryValidation';
		} else {
			return 'PrimaryValidation';
		}
	}

	//metho to check if any change is made during update my application for a Student.
	@AuraEnabled
	public static Boolean checkStudValOnSummary() {

		Boolean otherInstExist = checkExamRegOtherInstitutions();
		String otherMedSchoolExist = checkExamRegOtherMedSchoolTC();

		Id contactId = AppforCertHelper.retrieveCurrentContactId();

		List<Contact_Association_Type_Staging__c > newConAssoStagingObjList =
			new List<Contact_Association_Type_Staging__c > ([SELECT Id, Account__c, Status__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Number_of_Years_Attended__c,
				School_Program__c, Graduation_Month__c, Graduation_Year__c, Degree_Title__c, Degree_Issue_Month__c, Degree_Issue_Year__c, Student_ID__c, Specialty__c
				FROM Contact_Association_Type_Staging__c
				WHERE Contact__c =: contactId AND
				recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_DEGREE_MED_SCHOOL_EXAM_REG
				ORDER BY createdDate ASC
			]);

		List<Contact_Association_Type__c > existingConAssoObjList = new List<Contact_Association_Type__c > ();
		existingConAssoObjList = [SELECT ID, Account__c, Status__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Number_of_Years_Attended__c, School_Program__c,
			Graduation_Month__c, Graduation_Year__c, Degree_Title__c, Degree_Issue_Month__c, Degree_Issue_Year__c, Student_ID__c, Specialty__c From Contact_Association_Type__c
			WHERE Contact__c =: contactId and recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL WITH SECURITY_ENFORCED
		];

		Boolean contProceed = false;
		if (newConAssoStagingObjList[0].Account__c != existingConAssoObjList[0].Account__c || newConAssoStagingObjList[0].Status__c != existingConAssoObjList[0].Status__c ||
			newConAssoStagingObjList[0].Start_Month__c != existingConAssoObjList[0].Start_Month__c || newConAssoStagingObjList[0].Start_Year__c != existingConAssoObjList[0].Start_Year__c ||
			newConAssoStagingObjList[0].End_Month__c != existingConAssoObjList[0].End_Month__c || newConAssoStagingObjList[0].End_Year__c != existingConAssoObjList[0].End_Year__c ||
			newConAssoStagingObjList[0].Number_of_Years_Attended__c != existingConAssoObjList[0].Number_of_Years_Attended__c || newConAssoStagingObjList[0].School_Program__c != existingConAssoObjList[0].School_Program__c ||
			newConAssoStagingObjList[0].Graduation_Month__c != existingConAssoObjList[0].Graduation_Month__c || newConAssoStagingObjList[0].Graduation_Year__c != existingConAssoObjList[0].Graduation_Year__c ||
			newConAssoStagingObjList[0].Degree_Title__c != existingConAssoObjList[0].Degree_Title__c || newConAssoStagingObjList[0].Degree_Issue_Month__c != existingConAssoObjList[0].Degree_Issue_Month__c ||
			newConAssoStagingObjList[0].Degree_Issue_Year__c != existingConAssoObjList[0].Degree_Issue_Year__c || newConAssoStagingObjList[0].Student_ID__c != existingConAssoObjList[0].Student_ID__c ||
			newConAssoStagingObjList[0].Specialty__c != existingConAssoObjList[0].Specialty__c) {
			contProceed = true;
		}

		if (contProceed || otherMedSchoolExist == 'True' || otherInstExist) {
			return false;
		}
		return true;

	}

	//metho to check if new Other Institution has been added during update my application.
	@AuraEnabled
	public static Boolean checkExamRegOtherInstitutions() {

		Id contactId = AppforCertHelper.retrieveCurrentContactId();

		List<Contact_Association_Type_Staging__c > otherInstList = new List<Contact_Association_Type_Staging__c > ();
		otherInstList = [SELECT Id FROM Contact_Association_Type_Staging__c WHERE Contact__c =: contactId AND
			recordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_OTHER_INSTITUTION_EXAM_REG WITH SECURITY_ENFORCED
			ORDER BY createdDate ASC
		];

		if (!otherInstList.isEmpty()) {
			return True;
		}
		return False;
	}

	//metho to check if new Other Medical has been added during update my application.
	@AuraEnabled
	public static String checkExamRegOtherMedSchoolTC() {

		Id contactId = AppForCertHelper.retrieveCurrentContactId();
		Id caseId = AppForCertHelper.getCaseId();
		String isGraduate = AppForCertHelper.getContactAssTypeStagingStatus(); //get status from degree medical school RecordType
		String returnValue = '';

		List<Contact_Association_Type_Staging__c > tempCatsList = new List<Contact_Association_Type_Staging__c > ();
		tempCatsList = [SELECT Id, Name, Account__c, Contact__r.Id, Case__r.Id, Status__c, Is_Reopened_Exam_Reg__c, RecordType.Name, RecordType.DeveloperName, Case__r.Graduate_affirmation_required__c, Case__r.Transfer_credit_affirmation_required__c, Transfer_Credit_to_Degree_School__c FROM Contact_Association_Type_Staging__c
			WHERE Contact__r.Id =: contactId
			AND Case__r.Id =: caseId
			AND RecordType.DeveloperName =: Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG WITH SECURITY_ENFORCED
		];

		if (!tempCatsList.isEmpty()) {
			for (Contact_Association_Type_Staging__c cats: tempCatsList) {
				if (cats.RecordType.DeveloperName == Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL_EXAM_REG && ((cats.Transfer_Credit_to_Degree_School__c == true && isGraduate == 'Graduate') || (isGraduate == 'Student'))) {
					return 'True';
				} else {
					returnValue = 'RecordNoTc';
				}
			}
		}
		if (returnValue == 'RecordNoTc') {
			return returnValue;
		}
		return 'False';
	}

	//metho to check if new Final Medical Diploma or Dean Letter has been uploaded during update my application.
	@AuraEnabled
	public static Boolean checkFinalMedDipOrDeanLet(){
		String contactId = AppForCertHelper.retrieveCurrentContactId();
		String caseId = AppForCertHelper.getCaseId();
		String degMedSchoolId = AppForCertHelper.getContactAssociationTypeStaging(true, caseId, contactId);
		if(degMedSchoolId != ''){
			List<Asset> assetList = [SELECT Id, Contact_Association_Type_Staging__c, Document_is_not_in_English__c, Name_on_Document__c, Name_on_Document_is_Different__c, Type__c, Dean_s_Letter_Date__c, ParentId FROM Asset WHERE
				Contact_Association_Type_Staging__c =: degMedSchoolId AND Status =: Constants.ASSET_STATUS_INPROGRESS AND(Type__c =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR Type__c =: Constants.ASSET_NAME_DEAN_LETTER) WITH SECURITY_ENFORCED order by createdDate Asc
			];
			if(!assetList.isEmpty()){
				return true;
			}
		}		
		return false;
	}
	// Purpose To retrieve latest uploaded TCT Asset's id
	@AuraEnabled
	public static String retrieveTCTId(String contactId, String caseId) {
		List<Asset> assetList = new List<Asset> ();
		if (Asset.SObjectType.getDescribe().isAccessible()) {
			assetList = [SELECT id FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_TYPE_TCT AND status =: Constants.ASSET_STATUS_IN_PROGRESS ORDER BY CreatedDate DESC];
		}
		String assetId = null;
		if (!assetList.isEmpty()) {
			assetId = assetList[0].id;
			Asset a = new Asset();
			a.Id = assetId;
			a.key__c = Constants.ASSET_TYPE_TCT_DOCUMENT;
			if (Asset.SObjectType.getDescribe().isUpdateable()) {
				update a;
			}

		}
		return assetId;
	}

	// Purpose To update assets Status to mark tct assets for deletion
	@AuraEnabled
	public static String markTctAssetsForDeletion(String contactId, String parentCaseId) {
		List<String> assetTypeList = new List<String> ();
		assetTypeList.add(Constants.ASSET_TYPE_TCT);
		assetTypeList.add(Constants.ASSET_TYPE_TRANSLATION);
		assetTypeList.add(Constants.ASSET_TYPE_NAME_DOC);
		List<Asset> assetList = new List<Asset> ();
		if (Asset.SObjectType.getDescribe().isAccessible()){
			assetList = [SELECT id FROM Asset WHERE Parent_Case__c =: parentCaseId AND Contact_Association_Type_Staging__c = null AND contactId =: contactId AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND type__c IN: assetTypeList];
		}
		List<RecordType> rts = new List<RecordType> ();
		if (RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name FROM RecordType WHERE DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if (rts.size() == 0) {
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if (!assetList.isEmpty()) {
			for (Asset asst: assetList) {
				asst.Parent_Case__c = null;
				asst.case__c = null;
				asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				asst.RecordTypeId = assetMarkedForDeletionRT.Id;
			}
			update assetList;
		}
		return 'true';
	}

    /** Purpose : Method used in Graduate screen to update the newly created asset after file upload.*/
    @AuraEnabled(cacheable = false)
    public static String updateCatIDinAsset(String catsId,String contactId,String key,String parentKey) {
        List <Asset> assetList = new List <Asset>();
		String assetType = '';
		String assetName = '';
		String assetId = '';
		String parentId = '';
        if(key == System.Label.App_for_Cert_DIPLOMA_DOCUMENT){
            assetType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        }
		else if(key == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT
		|| key == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
			assetType = Constants.ASSET_TYPE_NAME_DOC;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
		}
		else if(key == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_FINAL_DIPLOMA_TRANSLATION;
		}
		else if(key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT){
            assetType = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
		}
		else if(key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION;
		}
		else if(key == System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT){
			assetType = Constants.ASSET_NAME_DEAN_LETTER;
		}
		else if(key == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION;
		}
		assetList = [SELECT Id,Status,Name,Type__c FROM Asset WHERE ContactId =: contactId AND Key__c =: key AND Status =: Constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED Order By CreatedDate Desc Limit 1];
		if(assetList.isEmpty()){
			assetList = [SELECT Id,Status,Name,Type__c FROM Asset WHERE ContactId =: contactId AND Type__c =: assetType
			AND Status =: Constants.ASSET_STATUS_INPROGRESS AND IsOrphan__c = FALSE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
		}
		assetId = updateAssetList(catsId,assetList,assetName,parentId,key,parentKey);
		return assetId;
	}
	/** Purpose : Method used in Graduate screen to update the newly created asset after file upload.*/
	@AuraEnabled(cacheable = false)
	public static String updateCatIDinAssetFMD(String catsId,String key,String parentKey,String azure){
		List <Asset> assetList = new List <Asset>();
		String contactId = getContactId();
		String assetType = '';
		String assetName = '';
		String assetId = '';
		String parentId = '';
		if(key == System.Label.App_for_Cert_DIPLOMA_DOCUMENT){
			assetType = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
		}
		else if(key == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT
		|| key == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
			assetType = Constants.ASSET_TYPE_NAME_DOC;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
		}
		else if(key == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_FINAL_DIPLOMA_TRANSLATION;
		}
		else if(key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_DOCUMENT){
			assetType = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
		}
		else if(key == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION;
		}
		else if(key == System.Label.App_for_Cert_DEAN_LETTER_DOCUMENT){
			assetType = Constants.ASSET_NAME_DEAN_LETTER;
		}
		else if(key == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
			assetType = Constants.ASSET_TYPE_TRANSLATION;
			parentId = AppforCertHelper.getParentAssetId(contactId, key);
			assetName = Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION;
		}		
		assetList = [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c =: azure LIMIT 1];  
		assetId = updateAssetList(catsId,assetList,assetName,parentId,key,parentKey);
		return assetId;
	}	
	public static string updateAssetList(String catsId, List<Asset> assetList, string assetName, string parentId, string key, string parentKey){
		string assetId = '';
		if(!assetList.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
			Id parentCaseId = AppForCertHelper.getCaseId();
			assetId = assetList[0].Id;
            assetList[0].key__c = key;
			assetList[0].Parent_Key__c = parentKey;
			assetList[0].Parent_Case__c = parentCaseId;
			if(String.isNotBlank(catsId)){
				assetList[0].Contact_Association_Type_Staging__c = catsId;
			}
			if(String.isNotBlank(assetName)){
				assetList[0].Name = assetName;
			}
			if(String.isNotBlank(parentId)){
				assetList[0].ParentId = parentId;
				assetList[0].Parent_Azure_Storage_URL__c = [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE Id=:parentId].Azure_Storage_URL__c;
			}
            update assetList;
		}
		return assetId;
	}

    /* Description : To create payload for uploaded assets status = In Progress */
    @AuraEnabled
    public static CloudStorageController.PayloadWrapper createFMDTranscriptDeanPayload(String contactId, String assetName){
        List<Asset> assetList = [SELECT Id,Azure_Storage_URL__c, Parent_Case__r.Internal_Status__c FROM Asset WHERE contactId =:contactId AND Type__c =: assetName AND Status =:Constants.ASSET_STATUS_INPROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        String assetId = null;
		String azureUrl = null;
        String accountId = '';
        String caseId = null;
        string createOrReplace = 'Replace';	
		String key = ''	;
        List<Case> caseList = [SELECT id,AccountId FROM Case WHERE contactId =:contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Internal_Status__c != :Constants.CASE_STATUS_REJECTED
		AND Internal_Status__c != :Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!caseList.isEmpty()){
            accountId= caseList[0].AccountId;
            caseId= caseList[0].Id;
        }
        if(!assetList.isEmpty()){
			if(assetList[0].Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_EXPIRED){
				assetId= assetList[0].Id;
				azureUrl = assetList[0].Azure_Storage_URL__c;
			}
        }        
		if(assetName == 'Final Medical Diploma'){
			key = 'DIPLOMA DOCUMENT';			
		}	
		else if(assetName == 'Final Medical School Transcript'){
			key = 'FINAL MEDICAL SCHOOL TRANSCRIPT DOCUMENT';			
		}
		else if(assetName == 'Letter from Dean'){
			key = 'DEAN LETTER DOCUMENT';
		}		
			CloudStorageController.PayloadWrapper payloadFMD= new CloudStorageController.PayloadWrapper(contactId, assetName, Constants.ASSET_RECORD_TYPE_CREDENTIAL, createOrReplace, caseId, accountId,  'true', Constants.CASE_STATUS_IN_PROGRESS , assetId,assetName,key,'','true',azureUrl);
        	return payloadFMD;
    }
	/* Description : To create payload for uploaded assets status = In Progress */
	@AuraEnabled
	public static CloudStorageController.PayloadWrapper createGradNameOrTransDocPayloadFMD(String contactId,String keyName,String parentKey) {
			List<Asset> assetList = [SELECT Id,Azure_Storage_URL__c, Parent_Case__r.Internal_Status__c FROM Asset WHERE contactId =:contactId AND key__c =:keyName AND (status =:Constants.ASSET_STATUS_INPROGRESS) AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
			String assetId = null;
			String azureUrl = null;
			String accountId = null;
			String caseId = null;
			string createOrReplace = 'Create';
			string assetName = '';
			string recordType = '';
			String type = '';
			List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Internal_Status__c != :Constants.CASE_STATUS_REJECTED
			AND Internal_Status__c != :Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
			if(!caseList.isEmpty()){
				accountId= caseList[0].AccountId;
				caseId= caseList[0].Id;
			}
			if(!assetList.isEmpty()){
				if(assetList[0].Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_EXPIRED){
					assetId= assetList[0].Id;
					azureUrl = assetList[0].Azure_Storage_URL__c;
				}
			}
			if(keyName == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
				assetName = Constants.ASSET_TYPE_NAME_DOC;
				recordType = Constants.ASSET_RECORD_TYPE_IDENTITY;
				type = Constants.ASSET_TYPE_NAME_DOC;
			}
			else if(keyName == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
				assetName = Constants.ASSET_NAME_FINAL_DIPLOMA_TRANSLATION;
				recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
				createOrReplace = 'Replace';
				type = Constants.ASSET_TYPE_TRANSLATION;
			}
			else if(keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
				assetName = Constants.ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION;
				recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
				createOrReplace = 'Replace';
				type = Constants.ASSET_TYPE_TRANSLATION;
			}
			else if(keyName == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
				assetName = Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION;
				recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
				createOrReplace = 'Replace';
				type = Constants.ASSET_TYPE_TRANSLATION;
			}			
			CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, assetName, recordType, createOrReplace, caseId, accountId,  'true', Constants.CASE_STATUS_IN_PROGRESS , assetId,type,keyName,parentKey,'true',azureUrl);
			return payload;
	} 
	/* Description : To create payload for uploaded assets status = In Progress */
	@AuraEnabled
	public static CloudStorageController.PayloadWrapper createGradNameOrTransDocPayload(String contactId,string keyName) {
		List<Asset> assetList = [SELECT Id,Azure_Storage_URL__c FROM Asset WHERE contactId =:contactId AND key__c =:keyName AND (status =:Constants.ASSET_STATUS_INPROGRESS) AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		String assetId = null;
		String azureUrl = null;
		String accountId = null;
		String caseId = null;
		string createOrReplace = 'Create';
		string assetName = '';
		string recordType = '';
		List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Internal_Status__c != :Constants.CASE_STATUS_REJECTED
		AND Internal_Status__c != :Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		if(!caseList.isEmpty()){
			accountId= caseList[0].AccountId;
			caseId= caseList[0].Id;
		}
		if(!assetList.isEmpty()){
			assetId= assetList[0].Id;
			azureUrl = assetList[0].Azure_Storage_URL__c;
		}
		if(keyName == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
			assetName = Constants.ASSET_TYPE_NAME_DOC;
			recordType = Constants.ASSET_RECORD_TYPE_IDENTITY;
		}
		else if(keyName == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
			assetName = Constants.ASSET_NAME_FINAL_DIPLOMA_TRANSLATION;
			recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
			createOrReplace = 'Replace';
		}
		else if(keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
			assetName = Constants.ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION;
			recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
			createOrReplace = 'Replace';
		}
		else if(keyName == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
			assetName = Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION;
			recordType = Constants.ASSET_RECORD_TYPE_CREDENTIAL;
			createOrReplace = 'Replace';
	    }
		CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId,assetName, recordType, createOrReplace, caseId, null,  'true', Constants.CASE_STATUS_IN_PROGRESS , assetId);		
		return payload;
	}   
     /* Description : To create payload for already uploaded Accepted assets */
     @AuraEnabled
     public static CloudStorageController.PayloadWrapper createFMDAcceptedPayload(String contactId,string assetName) {
		List<Asset> assetList = new List<Asset>(); 
		if(assetName == Constants.ASSET_NAME_DEAN_LETTER){
			assetList = [SELECT id, Parent_Case__r.Internal_Status__c FROM Asset where contactId =:contactId AND Type__c =:assetName AND (status =:Constants.ASSET_STATUS_ACCEPTED OR status =:Constants.ASSET_STATUS_EXPIRED) AND status !=:Constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		 }
		 else{
			assetList = [SELECT id, Parent_Case__r.Internal_Status__c FROM Asset where contactId =:contactId AND Type__c =:assetName AND status =:Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		 }
         String assetId = null;
         String accountId = null;
         String caseId = null;
         string createOrReplace = 'Replace';
         List<Case> caseList = [SELECT id,AccountId FROM Case where contactId =:contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Case_Status__c != :Constants.CASE_STATUS_REJECTED
		 AND Case_Status__c != :Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
         if(!caseList.isEmpty()){
             accountId= caseList[0].AccountId;
             caseId= caseList[0].Id;
         }
         if(!assetList.isEmpty()){
			if(assetList[0].Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_EXPIRED){
            	assetId= assetList[0].Id;
			}
         }
         CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId,assetName, Constants.ASSET_RECORD_TYPE_CREDENTIAL, createOrReplace, caseId, null,  'true', 'Accepted', assetId);
         return payload;
     }
     
      /* Description : To create payload for already uploaded Accepted assets */
      @AuraEnabled
      public static CloudStorageController.PayloadWrapper createGradAcceptedPayload(String contactId, String keyName) {
		List<Asset> assetList = new List<Asset>();
		if(keyName == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
			assetList = [SELECT Id, Parent_Case__r.Internal_Status__c FROM Asset WHERE contactId =: contactId AND key__c =: keyName AND (Status =: Constants.ASSET_STATUS_ACCEPTED OR Status =: Constants.ASSET_STATUS_EXPIRED) AND Status !=: Constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		}else{
			assetList = [SELECT Id, Parent_Case__r.Internal_Status__c FROM Asset WHERE contactId =: contactId AND key__c =: keyName AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Status !=: Constants.ASSET_STATUS_MARKED_FOR_DELETION WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		}  
        String assetId = null;
        String accountId = null;
        String caseId = null;
        string createOrReplace = 'Replace';
        string assetName = '';
        List<Case> caseList = [SELECT Id, AccountId FROM Case WHERE contactId =: contactId and RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Case_Status__c != :Constants.CASE_STATUS_REJECTED
		AND Case_Status__c != :Constants.CASE_STATUS_EXPIRED WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!caseList.isEmpty()){
            accountId = caseList[0].AccountId;
            caseId = caseList[0].Id;
        }
        if(!assetList.isEmpty()){
			if(assetList[0].Parent_Case__r.Internal_Status__c != Constants.CASE_STATUS_EXPIRED){
            	assetId = assetList[0].Id;
			}
        }
		if(keyName == System.Label.App_for_Cert_DIPLOMA_NAME_DOCUMENT || keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_NAME_DOCUMENT
		|| keyName == System.Label.App_for_Cert_DEAN_LETTER_NAME_DOCUMENT){
            assetName = Constants.ASSET_TYPE_NAME_DOC;
		}
		else if(keyName == System.Label.App_for_Cert_DIPLOMA_TRANSLATION_DOCUMENT){
            assetName = Constants.ASSET_NAME_FINAL_DIPLOMA_TRANSLATION;
		}
		else if(keyName == System.Label.App_for_Cert_FINAL_MEDICAL_SCHOOL_TRANSCRIPT_TRANSLATION_DOCUMENT){
            assetName = Constants.ASSET_NAME_FINAL_TRANSCRIPT_TRANSLATION;
		}
		else if(keyName == System.Label.App_for_Cert_DEAN_LETTER_TRANSLATION_DOCUMENT){
            assetName = Constants.ASSET_NAME_DEAN_LETTER_TRANSLATION;
		}
        CloudStorageController.PayloadWrapper payload= new CloudStorageController.PayloadWrapper(contactId, assetName, Constants.ASSET_RECORD_TYPE_CREDENTIAL, createOrReplace, caseId, null, 'true', 'Accepted', assetId);
        return payload;
      }

	// Purpose To retrieve latest uploaded TCT Translation Asset's id
	@AuraEnabled
	public static String retrieveTctTranslationId(String contactId, String caseId) {
		List<Asset> assetList = [SELECT id, Key__c, Parent_Key__c FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name = 'TCT Translation'
			AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC
		];
		String assetId = null;
		if (!assetList.isEmpty()) {
			assetId = assetList[0].id;
			assetList[0].Key__c = 'Transfer Credit Transcript Translation Document';
			assetList[0].Parent_Key__c = Constants.ASSET_TYPE_TCT_DOCUMENT;
			if (Asset.SObjectType.getDescribe().isUpdateable()) {
				UPDATE assetList[0];
			}
		}
		return assetId;
	}
	// Purpose To retrieve latest uploaded Name Documentation Asset's id
	@AuraEnabled
	public static String retrieveNameDocId(String contactId, String caseId) {
		List<Asset> assetList = [SELECT id, Key__c, Parent_Key__c FROM Asset where contactId =: contactId AND Case__c =: caseId AND Name =: Constants.ASSET_TYPE_NAME_DOC AND status =: Constants.ASSET_STATUS_IN_PROGRESS WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
		String assetId = null;
		if (!assetList.isEmpty()) {
			assetId = assetList[0].id;
			if(String.isBlank(assetList[0].Key__c)){
				assetList[0].Key__c = 'Transfer Credit Transcript Name Document';
				assetList[0].Parent_Key__c = Constants.ASSET_TYPE_TCT_DOCUMENT;
				if (Asset.SObjectType.getDescribe().isUpdateable()) {
					UPDATE assetList[0];
				}
			}
		}
		return assetId;
	}
	// Purpose To update assets Status to mark for deletion
	@AuraEnabled
	public static String markAssetsForDeletion(String assetIdsString) {
		List<String> assetIdsList = assetIdsString.split(',');
		List<Asset> assetsToUpdateList = new List<Asset> ();
		List<RecordType> rts = new List<RecordType> ();
		if (RecordType.SObjectType.getDescribe().isAccessible()) {
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if (rts.size() == 0) {
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if (Asset.SObjectType.getDescribe().isUpdateable()) {
			for (Asset a: [SELECT Id, Status, Case__c, Contact_Association_Type_Staging__c, Exam_Registration__c, Exam_Registration_Exam_Type__c FROM Asset WHERE Id IN: assetIdsList WITH SECURITY_ENFORCED]) {
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.Contact_Association_Type_Staging__c = null;
				a.Exam_Registration__c = null;
				a.Exam_Registration_Exam_Type__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
			}
			UPDATE assetsToUpdateList;
		}
		return 'true';
	}
	// Purpose To update assets Status to mark for deletion from azure urls
	@AuraEnabled
	public static String markAssetsForDeletionFromUrls(String assetUrlsString){
		String assetUrlsStr = assetUrlsString.substring(1,assetUrlsString.length()-1).replace('"','');
		List<String> assetUrlsList = assetUrlsStr.split(',');
		List<Asset> assetsToUpdateList = new List<Asset>();
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(rts.size() == 0){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset a: [SELECT Id, Status, Case__c, Contact_Association_Type_Staging__c, Exam_Registration__c, Exam_Registration_Exam_Type__c FROM Asset WHERE Azure_Storage_URL__c IN: assetUrlsList WITH SECURITY_ENFORCED]){
				a.Status = Constants.ASSET_STATUS_MARKED_FOR_DELETION;
				a.Case__c = null;
				a.Contact_Association_Type_Staging__c = null;
				a.Exam_Registration__c = null;
				a.Exam_Registration_Exam_Type__c = null;
				a.RecordTypeId = assetMarkedForDeletionRT.Id;
				assetsToUpdateList.add(a);
			}
			UPDATE assetsToUpdateList;
		}
		return 'true';
	}
	// Purpose To get status of assets Id passed
	@AuraEnabled
	public static String getAssetStatus(String assetId) {
		List<Asset> assetList = new List<Asset>([SELECT Id, Status FROM Asset where Id =:assetId WITH SECURITY_ENFORCED]);
		String returnVal = '';
		if(assetList.size() > 0) {
			returnVal = assetList[0].Status;
		}
		return returnVal;
	}
	//Method to search for other institutions with the search key
	@AuraEnabled
	public static List<Account> searchOtherInstitutions(String searchKey){
		List<Account> accountsList = new List<Account>();
		if(String.isnotBlank(searchKey)){
            String keyValue = '%' + searchKey + '%';
			accountsList = new List<Account>([SELECT Id, RecordType.DeveloperName, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Parent_Authority__c, EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.EPIC_Client_Special_Instructions_Languag__c, Parent_Authority__r.Use_same_instruction_for_child_entities__c FROM Account WHERE Name LIKE :keyValue AND RecordType.DeveloperName = :Constants.ACCOUNT_RECORD_TYPE_DEV_ENTITY WITH SECURITY_ENFORCED LIMIT 50]);
		}
		return accountsList;
	}
}