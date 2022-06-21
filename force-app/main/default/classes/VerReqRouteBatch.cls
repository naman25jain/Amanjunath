/**
 * Created by Matthew on 2019-06-24.
 * Modification by Nayana on 2020-05-19
 */

global class VerReqRouteBatch implements Database.Batchable<sObject>, Database.Stateful{
	public static final Integer MAX_BATCH_SIZE = 1;
	static final String LOG_SOURCE = 'VerReqRouteBatch'; 
	// the queue ids to assign case ownership to
	private String credentialReviewQueueId;
	private String duplicateCheckQueueId;
	private String enrollmentVerifQueueId;
	// Case record type ids	
	private String caseCredentialVerificationTypeId; 
	private String caseIFOMRequestRecordTypeId;
	//Contact record type ids
	private String contactEICSApplicantRecordTypeId;
	private String contactIFOMApplicantRecordTypeId;
	//Verfication Request record type ids
	private String verReqCredentialReviewRecordTypeId;
	private String verReqIFOMRequestRecordTypeId;
	// scores and bucket thresholds
	private Integer applicantExactMatchScore;
	private Integer entityExactMatchScore;
	private Integer applicantCreateBucketStartRange;
	private Integer applicantCreateBucketEndRange;
	private Integer applicantMatchBucketStartRange;
	private Integer applicantMatchBucketEndRange;
	public Integer testScenario = 0;
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		List<String> queueList = new List<String>{Constants.CASE_QUEUE_CREDENTIAL_REVIEW, Constants.CASE_QUEUE_DUPLICATE_CHECK, Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION};
        
		// retrieve queue id for Credential Review and Duplicate Check
        List<Group> groups = [select Id, Name from Group where Type = 'Queue' and Name IN:queueList];
		//Assign the queue ids to variables
        for(Group itr:groups)
        {
         	if(itr.Name == Constants.CASE_QUEUE_CREDENTIAL_REVIEW){
                credentialReviewQueueId = itr.Id;
			}
            else if(itr.Name == Constants.CASE_QUEUE_DUPLICATE_CHECK){
				duplicateCheckQueueId = itr.Id;
			}
			else if(itr.Name == Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION){
				enrollmentVerifQueueId = itr.Id;
			}
        }
        if(credentialReviewQueueId == null){
            throw new BatchException(Constants.QUEUE_NOT_FOUND_MSG + Constants.CASE_QUEUE_CREDENTIAL_REVIEW);
		}
        if(duplicateCheckQueueId == null){
			throw new BatchException(Constants.QUEUE_NOT_FOUND_MSG + Constants.CASE_QUEUE_DUPLICATE_CHECK);
		}
		if(enrollmentVerifQueueId == null){
            throw new BatchException(Constants.QUEUE_NOT_FOUND_MSG + Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
		}
        // get the id of the credential review record type		
		caseCredentialVerificationTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
		// get the EICS Applicant record type
        contactEICSApplicantRecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Contact', Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT);
		caseIFOMRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
		contactIFOMApplicantRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_IFOM_APPLICANT).getRecordTypeId();
		//get verification request record type
		verReqCredentialReviewRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_CREDENTIAL_REVIEW).getRecordTypeId();
		verReqIFOMRequestRecordTypeId = Schema.SObjectType.Verification_Request__c.getRecordTypeInfosByDeveloperName().get(Constants.VERIFICATION_REQUEST_RECORD_TYPE_IFOM).getRecordTypeId();
		// populate bucket thresholds from settings
		List<Duplicate_Check_Setting__mdt> settings = [select Applicant_Create_Bucket_End_Range__c,
																Applicant_Create_Bucket_Start_Range__c,
																Applicant_Exact_Match_Score__c,
																Applicant_Match_Bucket_End_Range__c,
																Applicant_Match_Bucket_Start_Range__c,
																DeveloperName,
																Entity_Exact_Match_Score__c,
																Exact_Match_Applicant_Scenario_ID__c,
																Exact_Match_Entity_Scenario_ID__c,
																Id,
																Label,
																Language,
																MasterLabel,
																NamespacePrefix,
																Non_Exact_Match_Applicant_Scenario_ID__c,
																Non_Exact_Match_Entity_Scenario_ID__c,
																QualifiedApiName
														from
																Duplicate_Check_Setting__mdt
														where
																DeveloperName = 'Default_Settings'];
		if(settings.size() == 0) {
			throw new ControllerException('Could not find Duplicate Check Settings (custom metadata).');
		}
		applicantExactMatchScore = (Integer)settings[0].Applicant_Exact_Match_Score__c;
		entityExactMatchScore = (Integer)settings[0].Entity_Exact_Match_Score__c;
		applicantCreateBucketStartRange = (Integer)settings[0].Applicant_Create_Bucket_Start_Range__c;
		applicantCreateBucketEndRange = (Integer) settings[0].Applicant_Create_Bucket_End_Range__c;
		applicantMatchBucketStartRange = (Integer)settings[0].Applicant_Match_Bucket_Start_Range__c;
		applicantMatchBucketEndRange = (Integer) settings[0].Applicant_Match_Bucket_End_Range__c;
		if(applicantCreateBucketStartRange == null || applicantCreateBucketEndRange == null || applicantMatchBucketStartRange == null || applicantMatchBucketEndRange == null) {
			throw new BatchException('Duplicate Check Settings missing. Please make sure the bucket settings are populated.');
		}
		String query = 'SELECT Id, Last_Name__c, Rest_of_Name__c, Birth_Date__c, Birth_Country__c, Gender__c, Medschool_Code__c, ' +
				'Sender__c, Candidate_Code__c, USMLE_ID__c, EICS_ID__c, Previous_Last_Name__c, Previous_Rest_of_Name__c, Residence_Country__c, ' +
				'Contact_Exact_Scenario_Score__c, Account_Exact_Scenario_Score__c, Contact_Non_Exact_Scenario_Score__c, Account_Non_Exact_Scenario_Score__c, Exact_Match_Contact__c, Exact_Match_Account__c, ' +
				'RecordTypeId, Eligibility_Case_ID__c, Registration_ID__c, Email__c, Middle_Name__c,Client_Batch_Create_Date__c	 '+
				'from Verification_Request__c ' +
				'where Status__c = \'Scored\'';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<Verification_Request__c> scope){
		// holds the cases we are going to create/update
		List<Case> cases = new List<Case>();
		// holds the contact we are going to create
		List<Contact> contacts = new List<Contact>();
		// holds the case attributes we are going to create/update
		Map<String, Map<String, String>> attributeMap = new Map<String, Map<String, String>>();
        // holds the case id for creating account contact association record 
		List<String> newCaseList = new List<String>();
		// bulk create the cases and link them to the reqs
		Case parentCase = new Case();
		List<Case> lstParentCase = new List<Case>(); 
		List<Case> lstCase = new List<Case>(); //hold fcvs related cases 
		String batchId =  bc.getJobId();
		Boolean isParentCaseInDupCheck = false; 
		string examMatchAccount='';
		//To store client account name
		String clientAccountId = '';
		String serviceType = '';
		String verReqSource = '';
		Map<String,String> accountNameMap = new Map<String,String>();
		List<Account> relatedClientAccount = new List<Account>();
		List<String> accountNames = new List<String>();
		accountNames.add(Constants.ACCOUNT_NAME_MCC);
		accountNames.add(Constants.ACCOUNT_NAME_FSMB);
		accountNames.add(Constants.ACCOUNT_NAME_NBME);

		relatedClientAccount = [SELECT Id, Name FROM Account 
								WHERE Name IN:accountNames WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];

		if(relatedClientAccount.size()>0){
			for(Account accRec:relatedClientAccount){
				String accountName = String.valueOf(accRec.Name).toUppercase();
				accountNameMap.put(accountName, accRec.Id);
			}			
		}
		
		for(Verification_Request__c req : scope){
			/*
				When Case is Initially Created
				 - Status: New
				 - Owner: Credential Review Queue
				 - Applicant: {blank}
				 - Entity: {blank}
			 */	
            system.debug('enter in for loop ');
			if(req.RecordTypeId == verReqCredentialReviewRecordTypeId){
                   system.debug('enter in for verReqCredentialReviewRecordTypeId ');
				ClientAccountId = null;
				if(req.Sender__c != null){
					serviceType = req.Sender__c.toUppercase() == constants.VERIFICATION_REQUEST_CLIENT_PCRC ?Constants.CASE_SERVICE_EICS :Constants.CASE_SERVICE_FCVS; 
					verReqSource = req.Sender__c.toUppercase() == constants.VERIFICATION_REQUEST_CLIENT_PCRC ? Constants.VERIFICATION_REQUEST_CLIENT_MCC : Constants.VERIFICATION_REQUEST_CLIENT_FSMB;
				}else{
					serviceType = '';
				}

				if(serviceType != null && !accountNameMap.isEmpty()){
					if(serviceType == Constants.CASE_SERVICE_EICS && accountNameMap.containsKey(Constants.ACCOUNT_NAME_MCC)){
						ClientAccountId = accountNameMap.get(Constants.ACCOUNT_NAME_MCC);						
					}else if(serviceType == Constants.CASE_SERVICE_FCVS && accountNameMap.containsKey(Constants.ACCOUNT_NAME_FSMB)){
						ClientAccountId = accountNameMap.get(Constants.ACCOUNT_NAME_FSMB);
					}else{
						ClientAccountId = null;
					}
				}
				Case cse = new Case(
					Internal_Status__c = Constants.CASE_STATUS_NEW,
					OwnerId = credentialReviewQueueId,
					RecordTypeId = caseCredentialVerificationTypeId,
					Verification_Request__c = req.Id,
					Received_Date__c = req.Client_Batch_Create_Date__c,
					Verification_Request_Source__c = verReqSource,
					Service__c = serviceType,
					Client_Account_Name__c = ClientAccountId
				);
				cases.add(cse);
			}
			else if(req.RecordTypeId == verReqIFOMRequestRecordTypeId){
                      system.debug('enter in for verReqIFOMRequestRecordTypeId ');
				ClientAccountId = null;
				if(!accountNameMap.isEmpty() && accountNameMap.containsKey(Constants.ACCOUNT_NAME_NBME)){
					ClientAccountId = accountNameMap.get(Constants.ACCOUNT_NAME_NBME);
				}else{
					ClientAccountId = null;
				}
				Case cse = new Case();
				cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
				cse.OwnerId = enrollmentVerifQueueId;
				cse.RecordTypeId = caseIFOMRequestRecordTypeId;
				cse.Verification_Request__c = req.Id;
				cse.Received_Date__c = req.Client_Batch_Create_Date__c;
				cse.Eligibility_Case_ID__c = req.Eligibility_Case_ID__c;
				cse.Registration_ID__c = req.Registration_ID__c;
				if(ClientAccountId != null){
					cse.Client_Account_Name__c = ClientAccountId;
				}					
				cases.add(cse);
			}			
		}
        system.debug('cases>>'+cases);
		insert cases;
		// create case maps
		Map<String, Case> caseIdMap = new Map<String, Case>();
		Map<String, Case> verReqIdToCaseMap = new Map<String, Case>();
		Map<String, Case> verReqIdToDupCaseMap = new Map<String, Case>();
		String strSender = '';
		for(Case cse : cases){
			caseIdMap.put(cse.Id, cse);
			verReqIdToCaseMap.put(cse.Verification_Request__c, cse);
		}
		// route the case
		for(Verification_Request__c req : scope){
			strSender = req.Sender__c;
			// get the case from request id
			Case cse = verReqIdToCaseMap.get(req.Id);
			// set req as processed
			req.Status__c = Constants.VERIFICATION_REQUEST_STATUS_PROCESSED;
			examMatchAccount = req.Exact_Match_Account__c;
			/*
				If Applicant matches 100% and Entity matches 100%
				 - Status: Pending Credential Review
				 - Owner: Credential Review Queue
				 - Applicant: Linked to 100% match
				 - Entity: Linked to 100% match
				 - SCENARIO 1
			 */
			if((req.Contact_Exact_Scenario_Score__c == applicantExactMatchScore && req.Account_Exact_Scenario_Score__c == entityExactMatchScore) || testScenario == 1) {
				// set case status and owner as appropriate for this scenario
				if(req.RecordTypeId == verReqCredentialReviewRecordTypeId){
					cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
					cse.OwnerId = credentialReviewQueueId;
				}
				else if(req.RecordTypeId == verReqIFOMRequestRecordTypeId){
					cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_INITIAL_REVIEW;
				}
				//set case entity
				cse.Entity__c = req.Exact_Match_Account__c;
				// set case contact
				cse.ContactId = req.Exact_Match_Contact__c;
				// set the linked entity in case attribute map
				CaseService.appendToAttributeMap(attributeMap, cse.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, req.Exact_Match_Account__c);
				newCaseList.add(cse.Id);
			}
			else {
				/*
					If Applicant matches 100% and Entity matches < 100%
					 - Status: Duplicate Check
					 - Owner: Duplicate Check Queue
					 - Applicant: Linked to 100% match
					 - Entity: {blank} match to be resolved in UI
					 - SCENARIO 2
				 */
				if((req.Contact_Exact_Scenario_Score__c == applicantExactMatchScore && req.Account_Exact_Scenario_Score__c < entityExactMatchScore) || testScenario == 2) {
					// set case status and owner as appropriate for this scenario
					cse.Internal_Status__c = Constants.CASE_STATUS_DUPLICATE_CHECK;
					cse.OwnerId = duplicateCheckQueueId;
					// link existing 100% match applicant
					cse.ContactId = req.Exact_Match_Contact__c;
					verReqIdToDupCaseMap.put(cse.Verification_Request__c, cse);
				}
				/*
					If Applicant matches 40 - 99% and Entity matches < 100%
					 - Status: Duplicate Check
					 - Owner: Duplicate Check Queue
					 - Applicant: {blank} matched to be resolved in UI
					 - Entity: {blank} match to be resolved in UI
					 - SCENARIO 3
				 */
				else if((req.Contact_Non_Exact_Scenario_Score__c >= applicantMatchBucketStartRange && req.Contact_Non_Exact_Scenario_Score__c <= applicantMatchBucketEndRange && req.Account_Exact_Scenario_Score__c < entityExactMatchScore) || testScenario == 3) {
					// set case status and owner as appropriate for this scenario
					cse.Internal_Status__c = Constants.CASE_STATUS_DUPLICATE_CHECK;
					cse.OwnerId = duplicateCheckQueueId;
					verReqIdToDupCaseMap.put(cse.Verification_Request__c, cse);
				}
				/*
					If Applicant matches 0 - 39% and Entity matches < 100%
					 - Status: Duplicate Check
					 - Owner: Duplicate Check Queue
					 - Applicant: Create and link new Applicant
					 - Entity: {blank} match to be resolved in UI
					 - SCENARIO 4
				 */
				else if((req.Contact_Non_Exact_Scenario_Score__c >= applicantCreateBucketStartRange && req.Contact_Non_Exact_Scenario_Score__c <= applicantCreateBucketEndRange && req.Account_Exact_Scenario_Score__c < entityExactMatchScore) || testScenario == 4) {
					// set case status and owner as appropriate for this scenario
					cse.Internal_Status__c = Constants.CASE_STATUS_DUPLICATE_CHECK;
					cse.OwnerId = duplicateCheckQueueId;
					verReqIdToDupCaseMap.put(cse.Verification_Request__c, cse);

					// create the contact
					if(req.RecordTypeId == verReqCredentialReviewRecordTypeId) {
						Contact c = createContact(req, cse.Id, contactEICSApplicantRecordTypeId);
						contacts.add(c);
					}
					else if(req.RecordTypeId == verReqIFOMRequestRecordTypeId) {
						Contact c = createContact(req, cse.Id, contactIFOMApplicantRecordTypeId);
						contacts.add(c);
					}
				}
				/*
					If Applicant matches 40 - 99% and Entity matches 100%
					 - Status: Duplicate Check
					 - Owner: Duplicate Check Queue
					 - Applicant: {blank} match to be resolved in UI
					 - Entity: Linked to 100% match
					 - SCENARIO 5
				 */
				else if((req.Contact_Non_Exact_Scenario_Score__c >= applicantMatchBucketStartRange && req.Contact_Non_Exact_Scenario_Score__c <= applicantMatchBucketEndRange && req.Account_Exact_Scenario_Score__c == entityExactMatchScore) || testScenario == 5) {
					// set case status and owner as appropriate for this scenario
					cse.Internal_Status__c = Constants.CASE_STATUS_DUPLICATE_CHECK;
					cse.OwnerId = duplicateCheckQueueId;
					verReqIdToDupCaseMap.put(cse.Verification_Request__c, cse);
					attributeMap = CaseService.appendToAttributeMap(attributeMap, cse.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, req.Exact_Match_Account__c);
				}
				/*
					If Applicant matches 0 - 39% and Entity matches 100%
					 - Status: Pending Credential Review
					 - Owner: Credential Review Queue
					 - Applicant: Create and link new Applicant
					 - Entity: Linked to 100% match
					 - SCENARIO 6
				 */
				else if((req.Contact_Non_Exact_Scenario_Score__c >= applicantCreateBucketStartRange && req.Contact_Non_Exact_Scenario_Score__c <= applicantCreateBucketEndRange && req.Account_Exact_Scenario_Score__c == entityExactMatchScore) || testScenario == 6) {
					cse.Entity__c = req.Exact_Match_Account__c;
					if(req.RecordTypeId == verReqCredentialReviewRecordTypeId) {
						// set case status and owner as appropriate for this scenario
						cse.Internal_Status__c = Constants.CASE_STATUS_NEW;
						cse.OwnerId = credentialReviewQueueId;
						// create the contact
						Contact c = createContact(req, cse.Id, contactEICSApplicantRecordTypeId);
						contacts.add(c);
					}
					else if(req.RecordTypeId == verReqIFOMRequestRecordTypeId) {
						// set case status
						cse.Internal_Status__c = Constants.CASE_STATUS_PENDING_INITIAL_REVIEW;
						// create the contact
						Contact c = createContact(req, cse.Id, contactIFOMApplicantRecordTypeId);
						contacts.add(c);
					}
					// set the linked entity in case attribute map
					CaseService.appendToAttributeMap(attributeMap, cse.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, req.Exact_Match_Account__c);
					newCaseList.add(cse.Id);
                }
				else {
					/**
					 * - else we missed a scenario
					 * - SCENARIO 7
					 */
					req.Status__c = Constants.VERIFICATION_REQUEST_STATUS_ERROR;
					throw new BatchException('We hit a scenario or condition we did not anticipate.');
				}
			}
			if (!string.isBlank(req.Sender__c)){
			
                Id caseFCVSRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FCVS Request').getRecordTypeId();				                
                if (req.Sender__c.toUppercase() == Constants.VERIFICATION_REQUEST_CLIENT_FSMB) { 					
					if (verReqIdToDupCaseMap.containsKey(req.Id)){							
						isParentCaseInDupCheck = true;						 					
					}else {
						cse.Internal_Status__c = Constants.CASE_STATUS_NEW;						
					}                      
					cse.Verification_Request__c = req.Id;
					cse.Verification_Request_Source__c = req.Sender__c.toUppercase();  					
					cse.recordTypeId = caseFCVSRequestRecordTypeId;
					cse.Service__c = Constants.CASE_SERVICE_FCVS;
					parentCase = cse;
                }
            }
		}
		try {
			// bulk update the cases
			update cases;			
			// bulk set the case attributes if got any
			if(attributeMap.keySet().size() > 0) {
				CaseService.setCaseAttributes(attributeMap);
			}
			// create contacts
			insert contacts;
	        // populate case contacts for newly created contacts
			List<Case> newContactCases = new List<Case>();
			for(Contact c : contacts) {
				
				// find matching case
				Case cse = caseIdMap.get(c.Verification_Request_Case__c);
				// update case contact
				cse.ContactId = c.Id;
				parentCase.contactId = c.Id;
				// add to collection
				newContactCases.add(cse);
			}
			// update new contact cases
			update newContactCases;

	        if(newCaseList <> null && newCaseList.size()>0 && !isParentCaseInDupCheck){
	        	//create contact association types
				VerificationRequestService.createCATS(newCaseList);
				VerificationRequestService.createContactAssociationTypes(newCaseList);
			}
			
			if (Case.SObjectType.getDescribe().isCreateable()){
					if(strSender.toUppercase() == Constants.VERIFICATION_REQUEST_CLIENT_FSMB){
						//FSMB - Update parent case
						upsert parentCase;
					}
					if (!isParentCaseInDupCheck){
						if (strSender.toUppercase() == Constants.VERIFICATION_REQUEST_CLIENT_FSMB) {
							lstCase = createCasesForSourceFSMB (parentCase.Id); 
							insert lstCase; 
						}
						if (!string.isBlank(examMatchAccount)){
							List<String> newCaseIds = new List<String>();
							for(case a:lstCase){
								newCaseIds.add(a.id);
								attributeMap = CaseService.appendToAttributeMap(attributeMap, a.Id, Constants.REQUEST_VERIFICATION_LINKED_ENTITY_ID_ATTRIBUTE_NAME, examMatchAccount);
								CaseService.setCaseAttributes(attributeMap);
							}
							system.debug('newCaseList --> '+newCaseList); 
							VerificationRequestService.createCATS(newCaseIds);
							VerificationRequestService.createContactAssociationTypes(newCaseIds);
						}
					}
			}
			// update requests
			update scope;
		} catch (Exception e) {
			CommonUtils.logMessage(new Log_Message__c(Exception__c = e.getMessage(), 
			Source__c = LOG_SOURCE,
			Date_Time_Logged__c = DateTime.now(),
			Record_Id__c = batchId)); 
		}
	}

	global void finish(Database.BatchableContext info) {
	}

	private static Contact createContact(Verification_Request__c req, String caseId, String recordTypeId) {
		Contact con;		
		String contactEICSApplicantRecordTypeId = RecordTypeUtility.getRecordTypeIdByName('Contact', Constants.CONTACT_RECORD_TYPE_EICS_APPLICANT);
		String contactIFOMApplicantRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_IFOM_APPLICANT).getRecordTypeId();
		if(recordTypeId == contactEICSApplicantRecordTypeId) {			
			con = new Contact (
				RecordTypeId = recordTypeId,
				Candidate_Code__c = req.Candidate_Code__c,
				LastName = req.Last_Name__c,
				FirstName = req.Rest_of_Name__c,
				Gender__c = req.Gender__c,
				Birthdate = req.Birth_Date__c,
				Birth_Country__c = req.Birth_Country__c,
				Medschool_Code__c = req.Medschool_Code__c,
				USMLE_ID__c = req.USMLE_ID__c,
				EICS_ID__c = req.EICS_ID__c,
				Previous_Last_Name__c = req.Previous_Last_Name__c,
				Previous_Rest_of_Name__c = req.Previous_Rest_of_Name__c,
				//Code commented by Shailaja Yerneni. Bug#12052. Insertion of contact failed as mailingCountryCode is restricted picklist.1/11/2021
				//MailingCountryCode = req.Residence_Country__c,
				MailingCountry = req.Residence_Country__c,
				Verification_Request_Case__c = caseId
			);
		}
		else if(recordTypeId == contactIFOMApplicantRecordTypeId) {
			con = new Contact (
				RecordTypeId = recordTypeId,
				LastName = req.Last_Name__c,
				MiddleName = req.Middle_Name__c,
				FirstName = req.Rest_of_Name__c,
				Gender__c = req.Gender__c,
				Birthdate = req.Birth_Date__c,
				Email = req.Email__c,
				USMLE_ID__c = req.USMLE_ID__c,
				Verification_Request_Case__c = caseId //check whether this is required
			);
		}
		return con;
	}
	public static List<Group> getGroupIdByName(string queueName){        
        List<Group> groups = [select Id from Group where Type = 'Queue' and Name =: queueName];
        return groups; 
    }

	public static List<Case>  createCasesForSourceFSMB(Id parentCaseId){  
		case pCase = CaseService.getCase(parentCaseId);       
        List<Case> lstFSMBCase = new List<Case>();
        Id caseCredentialVerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        List<Group> lstGroups = getGroupIdByName(Constants.CASE_QUEUE_CREDENTIAL_REVIEW);

        Case fmdCse = new Case(); 
        fmdCse.Internal_Status__c = Constants.CASE_STATUS_NEW;
        fmdCse.document_type__c = Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA; 
		fmdCse.Document_type_selected_by_applicant__c = Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA; 
        fmdCse.ParentId= parentCaseId; 
        fmdCse.recordTypeId = caseCredentialVerRecordTypeId; 
        fmdCse.OwnerId = lstGroups[0].Id; 
        fmdCse.Verification_Request_Source__c = Constants.VERIFICATION_REQUEST_CLIENT_FSMB;
		fmdCse.ContactId = pCase.ContactId;
		fmdCse.Service__c = Constants.CASE_SERVICE_FCVS;
		fmdCse.Entity__c = pCase.Entity__c;
        lstFSMBCase.add(fmdCse); 		

        Case fmstCse = new Case();
        fmstCse.Internal_Status__c = Constants.CASE_STATUS_NEW;
        fmstCse.document_type__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT; 
		fmstCse.Document_type_selected_by_applicant__c = Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT; 
        fmstCse.ParentId= parentCaseId; 
        fmstCse.recordTypeId = caseCredentialVerRecordTypeId;  
        fmstCse.OwnerId = lstGroups[0].Id;
        fmstCse.Verification_Request_Source__c = Constants.VERIFICATION_REQUEST_CLIENT_FSMB;
		fmstCse.ContactId = pCase.ContactId;
		fmstCse.Service__c = Constants.CASE_SERVICE_FCVS;
		fmstCse.Entity__c = pCase.Entity__c;
        lstFSMBCase.add(fmstCse); 		

        Case msfCse = new Case(); 
        msfCse.Internal_Status__c = Constants.CASE_STATUS_NEW;
        msfCse.document_type__c = Constants.CASE_DOC_TYPE_MEDICAL_SCHOOL_FORM;
		msfCse.Document_type_selected_by_applicant__c = Constants.CASE_DOC_TYPE_MEDICAL_SCHOOL_FORM;
        msfCse.ParentId= parentCaseId; 
        msfCse.recordTypeId = Constants.MEDEDUFORMID;
        msfCse.OwnerId = Constants.MEDEDUFORMQUEUE.Id;
        msfCse.Verification_Request_Source__c = Constants.VERIFICATION_REQUEST_CLIENT_FSMB;
		msfCse.ContactId = pCase.ContactId;
		msfCse.Service__c = Constants.CASE_SERVICE_FCVS;
		msfCse.Entity__c = pCase.Entity__c;
        lstFSMBCase.add(msfCse); 		
 
        return lstFSMBCase;
    }
}