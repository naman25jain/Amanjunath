/**
 * Batch class for Auto Releasing scores to students
 *
 * @author        Nayana
 * @version       1.0
 * @createdDate   05-MAY-2020
 */
global with sharing class ScoreReleaseBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, Withheld_Score__c, Exam_Status__c, Applicant__c, Case__c, Posted_Date__c, Score_report_Document_id__c, Withheld_Reason__c, Case__r.Enrollment_Re_Verification_Parent__c, Case__r.Enrollment_Re_Verification_Parent__r.Status, Case__r.Enrollment_Re_Verification_Parent__r.Internal_Status__c'
            +' FROM Exam_Registration__c'
            +' WHERE Withheld_Score__c = true AND Withheld_Reason__c != \''+ Constants.SCORE_WITHHELD_REASON_REQUESTED_BY_NBME+'\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Exam_Registration__c> examRegList) {
        List<String> applicantIdList = new List<String>();
        List<String> appIdListUpdateAsset = new List<String>();
        List<String> appIdListUpdateCase = new List<String>();
        List<Case> bioStatChangecase = new List<Case>();
        List<Asset> assetList = new List<Asset>();
        Map<Id, Asset> assetMap =new Map<Id, Asset>();
        Set<String> contactIdFormNotarized = new Set<String>();
        Set<String> contactApplicantBioChange = new Set<String>();
        
        for(Exam_Registration__c examReg : examRegList) {
            applicantIdList.add(examReg.Applicant__c);
        }
        
        assetList = [SELECT Id, Status, ContactId FROM Asset WHERE ContactId IN :applicantIdList AND Name =: Constants.ASSET_NAME_ID_FORM_NOTARIZED AND Type__c =: Constants.ASSET_TYPE_IDENTITY_VERIFICATION  AND status != :constants.ASSET_STATUS_MARKED_FOR_DELETION ORDER BY CreatedDate DESC];
        for(Asset idAsset: assetList){
            contactIdFormNotarized.add(idAsset.ContactId);
            if(!assetMap.containsKey(idAsset.ContactId)){
            	assetMap.put(idAsset.ContactId, idAsset);
                if(idAsset.Status == Constants.ASSET_STATUS_VERIFIED){
                    appIdListUpdateAsset.add(idAsset.ContactId);
                }
            }
        }
        

        bioStatChangecase = [SELECT Id, ContactId, Internal_Status__c FROM Case WHERE ContactId IN :applicantIdList AND recordType.DeveloperName =:Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE];
        for(Case bsCase : bioStatChangecase){
            contactApplicantBioChange.add(bsCase.contactId);
            if(bsCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED || bsCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED || bsCase.Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_APPLICANT || bsCase.Internal_Status__c == Constants.CASE_STATUS_CANCELLED_BY_ECFMG) {
                appIdListUpdateCase.add(bsCase.contactId);
            }
        }
        
        ScoreWithheldHelper.updateWithHeldScore(examRegList, appIdListUpdateAsset, appIdListUpdateCase, contactIdFormNotarized, contactApplicantBioChange);

    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }  
}