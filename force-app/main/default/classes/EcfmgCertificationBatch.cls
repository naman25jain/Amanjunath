//Batch class for Ecfmg Certification Process
global with sharing class EcfmgCertificationBatch implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext bc) { 
		Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
		Set<Id> conIds = new Set<Id>();
		for(Case cs : [Select ContactId from Case where RecordTypeId =: ecfmgCertRecordTypeId]){ 
			conIds.add(cs.ContactId);
		}
		String query = 'Select Id, Name, Credential_Pre_req_exempted__c,Attestation_Prerequisite_met__c,English_Exam_Completed__c, Pathways_Completed__c, LastModifiedDate, Financial_Review_Cleared__c, Email, Fin_Email_Reminder_Sent__c,Applicant_certification_status__c from Contact where Id Not In:conIds AND Applicant_certification_status__c !=\'Certificate Issued\' AND USMLE_ID__c !=\'\'';
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext bc, List<Contact> contactRecords) {
		List<Contact> idVerCheckPassed = new List<Contact>();
		List<Contact> credentialCheckPassed = new List<Contact>();
		List<Contact> examCheckPassed = new List<Contact>();
		List<Contact> restrictionCheckPassed = new List<Contact>();
		List<Contact> finPreReqPassed = new List<Contact>();
		if (!contactRecords.isEmpty()){
			idVerCheckPassed = PreReqCheckHelper.checkIdVerificationPreReq(contactRecords);
		}
		if (!idVerCheckPassed.isEmpty()){
			credentialCheckPassed = PreReqCheckHelper.credentialPreReqCheck(idVerCheckPassed);
		}
		if (!credentialCheckPassed.isEmpty()){
			examCheckPassed = PreReqCheckHelper.checkExamPreReq(credentialCheckPassed);
		}
		if(!examCheckPassed.isEmpty()){
			restrictionCheckPassed = PreReqCheckHelper.checkRestrictions(examCheckPassed);
		}
		if(!restrictionCheckPassed.isEmpty()){
			finPreReqPassed = PreReqCheckHelper.checkFinancePreReq(restrictionCheckPassed);
		}
		if(!finPreReqPassed.isEmpty()){
			PreReqCheckHelper.notifyApplicantFinDebit(finPreReqPassed);
		}
	}
	global void finish(Database.BatchableContext bc) {
	// execute any post-processing operations
	}
}