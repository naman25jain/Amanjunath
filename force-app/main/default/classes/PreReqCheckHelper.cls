public with sharing class PreReqCheckHelper {
	public static String fmdOrAttestStringLogMsg = '';
	public static String tctAcceptStringLogMsg = '';
	public static String contctDegStringSchLogMsg = '';
	//To check whether the applicants have completed the id verification process.
	public static List<Contact> checkIdVerificationPreReq(List<Contact> applicants) {
		List<Contact> eligibleApplicants = new List<Contact>();
		List<Asset> notaryAssets = new List<Asset>();
		List<Id> eligibileContactIds = new List<Id>();
		String logMessage = '';
		notaryAssets = [SELECT id, contactId FROM Asset where ContactId IN: applicants AND (status =: Constants.ASSET_STATUS_VERIFIED OR status =: Constants.ASSET_STATUS_ACCEPTED) AND Name =: Constants.ASSET_NAME_ID_FORM_NOTARIZED WITH SECURITY_ENFORCED];
		for (Asset asst: notaryAssets) {
			eligibileContactIds.add(asst.ContactId);
		}
		for (Contact cnt: applicants) {
			if (eligibileContactIds.contains(cnt.Id)) {
				eligibleApplicants.add(cnt);
			} else if (cnt.LastModifiedDate > System.today().addMonths(-3)) {
				logMessage = logMessage + cnt.Name + '(' + cnt.Id + ')' + ', ';
			}
		}
		if (String.isNotBlank(logMessage) && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
			Log_Message__c logMsg = new Log_Message__c();
			logMsg.Exception__c = 'ID verification pre requisite check failed for following contacts:' + logMessage.Substring(0, logMessage.length() - 2);
			logMsg.Date_Time_Logged__c = DateTime.now();
			insert logMsg;
		}
		return eligibleApplicants;
	}
	//To check whether applicants have passed Credential pre requisites
	public static List<Contact> credentialPreReqCheck(List<Contact> applicantsList) {
		List<Contact> nonExemptedapplicants = new List<Contact>();
		List<Contact> eligibleApplicants = new List<Contact>();
		List<Contact> eligibleApplicantsTemp = new List<Contact>();
		List<Asset> finalMedAssets = new List<Asset>();
		Map<String, Boolean> contactIdfinalMedMap = new Map<String, Boolean>();
		Map<String, Boolean> contactIdfinalMedTranscriptMap = new Map<String, Boolean>();
		List<Contact_Association_Type__c > existingConAssoObjList = new List<Contact_Association_Type__c >();
		Map<String, List<String>> acctIdYearMap = new Map<String, List<String>>();
		Map<String, List<String>> acctIdYearMapTemp = new Map<String, List<String>>();
		List<Object2Degree__c > obj2degList = new List<Object2Degree__c >();
		Map<String, Boolean> contactIdMedScholMap = new Map<String, Boolean>();
		Map<String, Boolean> tctAcceptableAssetMap = new Map<String, Boolean>();
		Map<String, Boolean> tctAcceptableAssetMapTemp = new Map<String, Boolean>();
		Map<String, Boolean> contactIdMedScholMapTemp = new Map<String, Boolean>();
		for (Contact eachCont: applicantsList) {
			if (eachCont.Credential_Pre_req_exempted__c) {
				eligibleApplicants.add(eachCont);
			} else {
				nonExemptedapplicants.add(eachCont);
			}
		}
		if (!nonExemptedapplicants.isEmpty()) {
			//Condition 1:to check for final Medical diploma asset and fina medicalSchool trnascipt
			finalMedAssets = [SELECT id, contactId, Type__c FROM Asset WHERE ContactId IN: nonExemptedapplicants AND status =: Constants.ASSET_STATUS_ACCEPTED AND(Type__c =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR Type__c =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) WITH SECURITY_ENFORCED];
			for (Asset asst: finalMedAssets) {
				if (asst.Type__c == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA) {
					contactIdfinalMedMap.put(asst.ContactId, True);
				}
				if (asst.Type__c == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT) {
					contactIdfinalMedTranscriptMap.put(asst.ContactId, True);
				}
			}
			existingConAssoObjList = [SELECT id, Account__c, Account_Name__c, Graduation_Year__c, Account__r.ECFMG_Acceptable__c, Transfer_Credit_to_Degree_School__c, Contact__c, recordType.DeveloperName,
				(SELECT Id FROM Assets__r WHERE Asset.status =: constants.ASSET_STATUS_ACCEPTED AND Asset.Type__c =: Constants.ASSET_TYPE_TCT)
				FROM Contact_Association_Type__c
				WHERE(recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL OR recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL)
				AND Contact__c IN: nonExemptedapplicants WITH SECURITY_ENFORCED
			];
			obj2degList = [SELECT Account__c, Graduation_Year__c FROM Object2Degree__c WITH SECURITY_ENFORCED];
			acctIdYearMapTemp = getAcctIdYearMap(obj2degList);
			acctIdYearMap.putAll(acctIdYearMapTemp);
			//Condition 2:to check for AcceptableSchool and Graduation year
			contactIdMedScholMapTemp = getContactIdMedSchoolMap(existingConAssoObjList, acctIdYearMap);
			contactIdMedScholMap.putAll(contactIdMedScholMapTemp);
			//Condition 3:to check for TCT, if TCTDegree school is checekd
			tctAcceptableAssetMapTemp = getTctAcceptableAssetMap(existingConAssoObjList, nonExemptedapplicants);
			tctAcceptableAssetMap.putAll(tctAcceptableAssetMapTemp);
			//final List of applicants after Credential checks
			eligibleApplicantsTemp = getFinalEligibleApplicants(nonExemptedapplicants, contactIdfinalMedMap, contactIdfinalMedTranscriptMap, tctAcceptableAssetMap, contactIdMedScholMap);
			eligibleApplicants.addAll(eligibleApplicantsTemp);
		}
		return eligibleApplicants;
	}
	//method to get the accountId and Graduation year mapping
	public static Map<String, List<String>> getAcctIdYearMap(List<Object2Degree__c > obj2degList) {
		Map<String, List<String>> acctIdYearMap = new Map<String, List<String>>();
		if (!obj2degList.isEmpty()) {
			for (Object2Degree__c eachObj: obj2degList) {
				List<String> yearList = new List<String>();
				if (acctIdYearMap.containsKey(eachObj.Account__c)) {
					yearList = acctIdYearMap.get(eachObj.Account__c);
					yearList.add(eachObj.Graduation_Year__c);
					acctIdYearMap.put(string.valueof(eachObj.Account__c), yearList);
				}
				yearList.add(string.valueof(eachObj.Graduation_Year__c));
				acctIdYearMap.put(string.valueof(eachObj.Account__c), yearList);
			}
		}
		return acctIdYearMap;
	}
	//method to get the eligible contact Id for degree medical school and Graduation year check
	public static Map<String, Boolean> getContactIdMedSchoolMap(List<Contact_Association_Type__c > existingConAssoObjList, Map<String, List<String>> acctIdYearMap) {
		Map<String, Boolean> contactIdMedScholMap = new Map<String, Boolean>();
		if (!existingConAssoObjList.isEmpty()) {
			for (Contact_Association_Type__c eachCat: existingConAssoObjList) {
				if (eachCat.recordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL &&
					acctIdYearMap.containsKey(eachCat.Account__c) && !acctIdYearMap.get(eachCat.Account__c).isEmpty() &&
					acctIdYearMap.get(eachCat.Account__c).contains(eachCat.Graduation_Year__c) &&
					eachCat.Account__r.ECFMG_Acceptable__c) {
					contactIdMedScholMap.put(eachCat.Contact__c, True);
				}
			}
		}
		return contactIdMedScholMap;
	}
	//method to get the eligible contact Id for Acceptable TCT in other medical school check
	public static Map<String, Boolean> getTctAcceptableAssetMap(List<Contact_Association_Type__c > existingConAssoObjList, List<Contact> nonExemptedapplicants) {
		Map<String, Boolean> tctAcceptableAssetMap = new Map<String, Boolean>();
		Map<String, Boolean> tctAcceptableAssetMapTemp = new Map<String, Boolean>();
		if (!existingConAssoObjList.isEmpty()) {
			for (Contact_Association_Type__c eachCat: existingConAssoObjList) {
				if (eachCat.recordType.DeveloperName == Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL) {
					tctAcceptableAssetMapTemp = getAcceptableTempMap(eachCat, tctAcceptableAssetMap);
					tctAcceptableAssetMap.putAll(tctAcceptableAssetMapTemp);
				}
			}
			//if there are no other medical schools, then applicant is eligible for Ecfmg Certification
			for (Contact eachCont: nonExemptedapplicants) {
				if (!tctAcceptableAssetMap.containsKey(eachCont.Id)) {
					tctAcceptableAssetMap.put(eachCont.Id, True);
				}
			}
		}
		return tctAcceptableAssetMap;
	}

	public static Map<String, Boolean> getAcceptableTempMap(Contact_Association_Type__c eachCat, Map<String, Boolean> tctAcceptableAssetMap) {
		Map<String, Boolean> tctAcceptableAssetMapTemp = new Map<String, Boolean>();
		if (eachCat.Transfer_Credit_to_Degree_School__c) {
			if (!eachCat.Assets__r.isEmpty()) {
				tctAcceptableAssetMapTemp.put(eachCat.Contact__c, True);
			} else {
				tctAcceptableAssetMapTemp.put(eachCat.Contact__c, false); //if there is a medical school and no TCT assets, applicant is NOT eligible
			}
		} else {
			if (!tctAcceptableAssetMap.containsKey(eachCat.Contact__c)) {
				tctAcceptableAssetMapTemp.put(eachCat.Contact__c, True); //if there is only one medical school and Transfer credits is not checked, applicant is eligible
			}
		}
		return tctAcceptableAssetMapTemp;
	}

	public static List<Contact> getFinalEligibleApplicants(List<Contact> nonExemptedapplicants, Map<String, Boolean> contactIdfinalMedMap, Map<String, Boolean> contactIdfinalMedTranscriptMap, Map<String, Boolean> tctAcceptableAssetMap, Map<String, Boolean> contactIdMedScholMap) {
		List<Contact> eligibleApplicants = new List<Contact>();
		List<Contact> nonEligibleApplicants = new List<Contact>();
		for (Contact eachCont: nonExemptedapplicants) {
			if (checkContactIdFinal(eachCont, contactIdfinalMedMap, contactIdfinalMedTranscriptMap)) {
				if (checkTCTAcceptableAsset(eachCont, tctAcceptableAssetMap)) {
					if (checkContactIdMedSchol(eachCont, contactIdMedScholMap)) {
						eligibleApplicants.add(eachCont);
					} else if (eachCont.LastModifiedDate > System.today().addMonths(-3)) {
						contctDegStringSchLogMsg = contctDegStringSchLogMsg + eachCont.Name + '(' + eachCont.Id + '),';
					}
				}
			}
		}
		insertLogMessages(contctDegStringSchLogMsg, tctAcceptStringLogMsg, fmdOrAttestStringLogMsg);
		return eligibleApplicants;
	}

	public static Boolean checkContactIdFinal(Contact eachCont, Map<String, Boolean> contactIdfinalMedMap, Map<String, Boolean> contactIdfinalMedTranscriptMap) {
		if ((contactIdfinalMedMap.get(eachCont.Id) != null && contactIdfinalMedTranscriptMap.get(eachCont.Id) != null &&
				contactIdfinalMedMap.get(eachCont.Id) && contactIdfinalMedTranscriptMap.get(eachCont.Id)) || eachCont.Attestation_Prerequisite_met__c) {
			return true;
		} else if (eachCont.LastModifiedDate > System.today().addMonths(-3)) {
			fmdOrAttestStringLogMsg = fmdOrAttestStringLogMsg + eachCont.Name + '(' + eachCont.Id + '),';
			return false;
		}
		return false;
	}

	public static Boolean checkTCTAcceptableAsset(Contact eachCont, Map<String, Boolean> tctAcceptableAssetMap) {
		if (tctAcceptableAssetMap.get(eachCont.Id) != null && tctAcceptableAssetMap.get(eachCont.Id)) {
			return true;
		} else if (eachCont.LastModifiedDate > System.today().addMonths(-3)) {
			tctAcceptStringLogMsg = tctAcceptStringLogMsg + eachCont.Name + '(' + eachCont.Id + '),';
			return false;
		}
		return false;
    }

	public static Boolean checkContactIdMedSchol(Contact eachCont, Map<String, Boolean> contactIdMedScholMap) {
		if (contactIdMedScholMap.get(eachCont.Id) != null && contactIdMedScholMap.get(eachCont.Id)) {
			return true;
		}
		return false;
	}

	public static void insertLogMessages(String contctDegStringSchLogMsg, String tctAcceptStringLogMsg, String fmdOrAttestStringLogMsg) {
		List<Log_Message__c > nonEligibleLogMsgs = new List<Log_Message__c >();
		Log_Message__c fmdOrAttestLogMsg = new Log_Message__c();
		Log_Message__c tctAcceptLogMsg = new Log_Message__c();
		Log_Message__c contctDegSchLogMsg = new Log_Message__c();
		if (String.isNotBlank(fmdOrAttestStringLogMsg)) {
			fmdOrAttestStringLogMsg = fmdOrAttestStringLogMsg.removeEnd(',');
			fmdOrAttestLogMsg.Exception__c = 'Credential Pre-Requisite check failed(Final Medical Diploma & FinalMedSchool Transcript Asset is not Available or Attestation_Prerequisite_met__c is not checked) for following contacts:' + fmdOrAttestStringLogMsg;
			nonEligibleLogMsgs.add(fmdOrAttestLogMsg);
		}
		if (String.isNotBlank(tctAcceptStringLogMsg)) {
			tctAcceptStringLogMsg = tctAcceptStringLogMsg.removeEnd(',');
			tctAcceptLogMsg.Exception__c = 'Credential Pre-Requisite check failed(Accetpable TCT is not available or valid Other Med School is not available) for following contacts:' + tctAcceptStringLogMsg;
			nonEligibleLogMsgs.add(tctAcceptLogMsg);
		}
		if (String.isNotBlank(contctDegStringSchLogMsg)) {
			contctDegStringSchLogMsg = contctDegStringSchLogMsg.removeEnd(',');
			contctDegSchLogMsg.Exception__c = 'Credential Pre-Requisite check failed(Medical School is not acceptable or Graduation year is not valid) for following contacts:' + contctDegStringSchLogMsg;
			nonEligibleLogMsgs.add(contctDegSchLogMsg);
		}
		if (!nonEligibleLogMsgs.isEmpty() && Schema.sObjectType.Log_Message__c.isCreateable()) {
			INSERT nonEligibleLogMsgs;
		}
	}

	//To check whether the applicants have completed the exam pre requisites.
	public static List<Contact> checkExamPreReq(List<Contact> applicants) {
		List<Contact> eligibleApplicants = new List<Contact>();
		List<Exam_Registration__c > examRegs = new List<Exam_Registration__c >();
		Map<Id, Exam_Registration__c > step1CkMap = new Map<Id, Exam_Registration__c >();
		Map<Id, Exam_Registration__c > step2CkMap = new Map<Id, Exam_Registration__c >();
		Map<Id, Exam_Registration__c > step2CsMap = new Map<Id, Exam_Registration__c >();
		List<Id> eligibileContactIds = new List<Id>();
		examRegs = [SELECT Id, Applicant__c, Exam_Types__c
			FROM Exam_Registration__c
			WHERE Applicant__c IN: applicants
			AND Voided__c = false
			AND Exam_Status__c =: Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED WITH SECURITY_ENFORCED
		];
		for (Exam_Registration__c examReg: examRegs) {
			if (examReg.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE) {
				step1CkMap.put(examReg.Applicant__c, examReg);
			}
			if (examReg.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK) {
				step2CkMap.put(examReg.Applicant__c, examReg);
			}
			if (examReg.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS) {
				step2CsMap.put(examReg.Applicant__c, examReg);
			}
		}
		for (Contact cnt: applicants) {
			if (step1CkMap.get(cnt.Id) != null && step2CkMap.get(cnt.Id) != null && (step2CsMap.get(cnt.Id) != null || (cnt.English_Exam_Completed__c && cnt.Pathways_Completed__c))) {
				eligibleApplicants.add(cnt);
			}
		}
		logExamPreCheck(applicants, eligibleApplicants);
		return eligibleApplicants;
	}
    //To check whether the applicants have completed the Restriction pre requisites.
    public static list<contact> checkRestrictions(list<contact> contactList) {
        list<contact> nonRestrApplicants=new list<contact>();
        String logMessage = '';
        for(contact con: contactList ){
            if(con.Applicant_certification_status__c==null || con.Applicant_certification_status__c=='' || con.Applicant_certification_status__c=='Hold Released') {
             nonRestrApplicants.add(con);
            }
            else if(con.LastModifiedDate > System.today().addMonths(-3)){
              logMessage = logMessage+con.Name+' ('+con.Id+')'+', ';
            }
        } 
        if (String.isNotBlank(logMessage) && Log_Message__c.SObjectType.getDescribe().isCreateable()){
            Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= 'Restriction pre requisite check failed for following contacts: '+ logMessage.Substring(0,logMessage.length()-2);
            logMsg.Date_Time_Logged__c = DateTime.now();
            insert logMsg;
        }
        return nonRestrApplicants;
    }
	//To log the list of records which failed exam pre requisites check.
	public static void logExamPreCheck(List<Contact> applicants, List<Contact> eligibleApplicants) {
		String logMessage = '';
		for (Contact cnt: applicants) {
			if (!eligibleApplicants.contains(cnt) && cnt.LastModifiedDate > System.today().addMonths(-3)) {
				logMessage = logMessage + cnt.Name + '(' + cnt.Id + ')' + ', ';
			}
		}
		if (String.isNotBlank(logMessage) && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
			Log_Message__c logMsg = new Log_Message__c();
			logMsg.Exception__c = 'Exam pre requisite check failed for following contacts:' + logMessage.Substring(0, logMessage.length() - 2);
			logMsg.Date_Time_Logged__c = DateTime.now();
			insert logMsg;
		}
	}
	// //Method to check if there are any Financial pre-requisites pending
	// public static List<Contact> checkFinancePreReq(List<Contact> applicantList) {
	// 	List<Contact> checkContactVal = new List<Contact>();
	// 	List<Contact> returnConList = new List<Contact>();
	// 	List<Contact> createCaseList = new List<Contact>();
	// 	String logMessage = '';
	// 	for (Contact loopVar: applicantList) {
	// 		if (loopVar.Financial_Review_Cleared__c == false && loopVar.Fin_Email_Reminder_Sent__c == false) {
	// 			returnConList.add(loopVar);
	// 			logMessage = logMessage + loopVar.Name + '(' + loopVar.Id + ')' + ', ';
	// 		} else if (loopVar.Financial_Review_Cleared__c == true) {
	// 			createCaseList.add(loopVar);
	// 		}
	// 	}
	// 	if (String.isNotBlank(logMessage) && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
	// 		Log_Message__c logMsg = new Log_Message__c();
	// 		logMsg.Exception__c = 'Financial Pre-requisite check failed for following contacts:' + logMessage.Substring(0, logMessage.length() - 2);
	// 		logMsg.Date_Time_Logged__c = DateTime.now();
	// 		insert logMsg;
	// 	}
	// 	if (!createCaseList.isEmpty()) {
  //           createEcfmgCertCase(createCaseList);
  //           notifyApplicantUpdtAddr(createCaseList);
	// 	}
	// 	return returnConList;
	// }

	// --------------------------------------------------------------------------
	// Method to check if applicants pass the financial check. The pass or fail 
	// is determined by the balance in their account. If they have a negative 
	// balance (they owe money) then they fail the check.
	// --------------------------------------------------------------------------
	public static List<Contact> checkFinancePreReq(List<Contact> applicantList) {
		Map<Id, Contact> applicantsMap = new Map<Id, Contact>(applicantList);
		Map<Id, Boolean> applicantsFinancialCheck = ShoppingCartController.getApplicantsBalance(applicantsMap);
		// Lists to store the applicants depending on the check.
		List<Contact> checkFailedApplicants = new List<Contact>();
		List<Contact> checkPassedApplicants = new List<Contact>();
		// String to log the applicants that didn't pass the financial check.
		String logMessage = '';

		for (Id contactId : applicantsMap.keySet()) {
			Contact applicant = applicantsMap.get(contactId);
			Boolean financialCheckPassed = applicantsFinancialCheck.containsKey(contactId)? applicantsFinancialCheck.get(contactId) : false;

			if(financialCheckPassed) {
				checkPassedApplicants.add(applicant);
			} else if (!financialCheckPassed && !applicant.Fin_Email_Reminder_Sent__c) {
				checkFailedApplicants.add(applicant);
				logMessage = logMessage + applicant.Name + '(' + contactId + ')' + ', ';
			}
		}

		// Section to log the applicants which didn't pass the financial check.
		if (String.isNotBlank(logMessage) && Log_Message__c.SObjectType.getDescribe().isCreateable()) {
			Log_Message__c logMsg = new Log_Message__c();
			logMsg.Exception__c = 'Financial Pre-requisite check failed for following contacts:' + logMessage.Substring(0, logMessage.length() - 2);
			logMsg.Date_Time_Logged__c = DateTime.now();
			insert logMsg;
		}

		// Create cases for the applicants that passed the financial check.
		if (!checkPassedApplicants.isEmpty()) {
			createEcfmgCertCase(checkPassedApplicants);
			notifyApplicantUpdtAddr(checkPassedApplicants);
		}
		return checkFailedApplicants;
	}


	//Trigger Email to notify applicant on Pending Financial debits
	public static void notifyApplicantFinDebit(List<Contact> applicantList) {
		EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.UPDATE_APPLICANT_ON_DEBIT WITH SECURITY_ENFORCED];
		List<Messaging.SingleEmailMessage > messages = new List<Messaging.SingleEmailMessage >();
		List<OrgWideEmailAddress> addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS WITH SECURITY_ENFORCED];
		for (Contact con: applicantList) {
			if (con.Email != null) {
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setTargetObjectId(con.Id);
				message.setTemplateID(emailTemplate.Id);
				message.setOrgWideEmailAddressId(addr[0].Id);
				String htmlBody = emailTemplate.HtmlValue;
				message.setHtmlBody(htmlBody);
				message.toAddresses = new String[] {
					con.Email
				};
				messages.add(message);
			}
		}
		try {
			Messaging.sendEmail(messages);
			for (Contact loopVar: applicantList) {
				loopVar.Fin_Email_Reminder_Sent__c = true;
			}
			if (Contact.SObjectType.getDescribe().isUpdateable()) {
				update applicantList;
			}
		} catch (exception e) {
			Log_Message__c logMsg = new Log_Message__c();
            logMsg.Exception__c	= 'Unhandled Exception while sending mail:'+ e.getMessage();
            logMsg.Date_Time_Logged__c = DateTime.now();
            insert logMsg;
		}
	}
	//Method to create ECFMG Certification Case if all pre-requisites are met
	public static void createEcfmgCertCase(List<Contact> eligibleContactsList) {
		List<Group> finalQAQueue = [SELECT Id
			FROM Group
			WHERE Type = 'Queue'
			AND DeveloperNAME = 'ECFMG_Certification'
			WITH SECURITY_ENFORCED
		];
		if (!finalQAQueue.isEmpty()) {
			List<Case> casesToInsert = new List<Case>();
			Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
			for (Contact con: eligibleContactsList) {
				Case tempCase = new Case();
				tempCase.RecordTypeId = ecfmgCertRecordTypeId;
				tempCase.ContactId = con.Id;
				tempCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
				tempCase.OwnerId = finalQAQueue[0].Id;
				casesToInsert.add(tempCase);
			}
			if (Case.SObjectType.getDescribe().isCreateable()) {
				Insert casesToInsert;
			}
		}
	}

	// to send email to Applicants informing them to verify / update mailing address
	public static void notifyApplicantUpdtAddr(List<Contact> eligibleContactsList){
		List<EmailTemplate> emailTemplate = [SELECT Id, Subject, Description, DeveloperName, Body, HtmlValue
			FROM EmailTemplate
			WHERE DeveloperName = :Constants.UPDATE_MAILING_ADDRESS_TEMPLATE
			WITH SECURITY_ENFORCED
		];
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
		List<OrgWideEmailAddress> orgWideAddrList = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS WITH SECURITY_ENFORCED];
		if(!emailTemplate.isEmpty() && !orgWideAddrList.isEmpty()){
			for(Contact con: eligibleContactsList){
				if(con.Email != null){
					Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
					message.setTargetObjectId(con.Id);
					message.setTemplateID(emailTemplate[0].Id);
					message.setOrgWideEmailAddressId(orgWideAddrList[0].Id);
					String htmlBody = emailTemplate[0].HtmlValue;
					message.setHtmlBody(htmlBody);
					message.toAddresses = new String[] {
						con.Email
					};
					messages.add(message);
				}
			}
			try{
				Messaging.sendEmail(messages);
			}catch (exception e){
				Log_Message__c logMsg = new Log_Message__c();
				logMsg.Exception__c	= 'Unhandled Exception while sending update mailing address email:'+ e.getMessage();
				logMsg.Date_Time_Logged__c = DateTime.now();
				INSERT logMsg;
			}
		}
	}
}