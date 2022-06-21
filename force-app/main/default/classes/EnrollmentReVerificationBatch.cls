/*Batch class for Enrollment Re-verification */
global with sharing class EnrollmentReVerificationBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        Id examregRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        String query = 'SELECT Id, Internal_Status__c, ContactId, Signature_Date__c, Exam_Registration__c, Enrollment_Re_Verification_Parent__c, Exam_Registration__r.EP_start_Date__c, Enrollment_Verification_Parent__r.Signature_Date__c '
            +'FROM Case WHERE RecordTypeId = \''+ examregRecordTypeId +'\''
            +' AND Enrollment_Re_Verification_Parent__c = null' + ' AND Enrollment_Verification_Parent__c != null' + ' AND Enrollment_Verification_Parent__r.Signature_Date__c != null'
            +' AND Enrollment_Verification_Parent__r.Enrolled_in_Entity_Portal__c = false'
            +' AND (Internal_Status__c = \''+ Constants.CASE_STATUS_PENDING_CIBIS+'\'  OR Internal_Status__c = \''+Constants.CASE_STATUS_REGISTERED +'\')' 
            +' AND Contact.School_Enrollment_Status__c =  \'' +Constants.CONASCTYPESTG_STATUS_STUDENT +'\''; 
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case> caseList){
        List<Case> ervCasesToInsert = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        Map<Id,Case> contReVerifCaseNewMap = new Map<Id,Case>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Contact_Association_Type__c> contactCatsMap = new Map<Id,Contact_Association_Type__c>();
        Map<Id,Exam_Registration__c> contactExamRegMap = new Map<Id,Exam_Registration__c>();
        Group ervQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name =: Constants.CASE_QUEUE_ENROLLMENT_RE_VERIFICATION LIMIT 1];
        for(Exam_Registration__c examReg : [SELECT Id, Case__c, EP_start_Date__c, Exam_Types__c FROM Exam_Registration__c 
            WHERE Case__c IN: caseList]){
                contactExamRegMap.put(examReg.Case__c, examReg);
        }
        contactIdSet = EnrollmentReVerificationBatchHelper.checkSignDateEPStartDate(caseList,contactExamRegMap);
        if(!contactIdSet.isEmpty()){
            contactCatsMap = EnrollmentReVerificationBatchHelper.getContactAssociationType(contactIdSet);
            ervCasesToInsert = EnrollmentReVerificationBatchHelper.createEVCaseObject(ervQueue.Id, contactCatsMap);
            Database.insert(ervCasesToInsert);
            for(Case c : ervCasesToInsert){
                contReVerifCaseNewMap.put(c.ContactId, c);
                casesToUpdate.add(c);             
            }
            EnrollmentReVerificationBatchHelper.updateERVAsset(contReVerifCaseNewMap);
        }
        for(Case c : caseList){
            if(contReVerifCaseNewMap.containsKey(c.ContactId) && c.Enrollment_Re_Verification_Parent__c == null){
                c.Enrollment_Re_Verification_Parent__c = contReVerifCaseNewMap.get(c.ContactId).Id;
                casesToUpdate.add(c);
            }
        } 
        Database.update(casesToUpdate);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}