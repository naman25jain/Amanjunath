public with sharing class DupEcfmgCertificateController{
    //method to check whether duplicate certificate request should be enabled.
    @AuraEnabled(Cacheable = false)
    public static Boolean enableDuplicateRequest(String contactId){
        Boolean returnValue = false;
        List<Asset> certAssets = [SELECT id FROM Asset where contactId =: contactId AND RecordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION AND Status =: Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
        if(!certAssets.isEmpty()){
            returnValue = true;
        }
        return returnValue;
    }
    //Method to complete payment and finalise Case status
    @AuraEnabled(Cacheable = false)
    public static Boolean paymentCompletion(){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        Case ecfmgCertCase = [SELECT Id, Reason_for_Duplicate_Certificate__c, Description,Internal_Status__c FROM Case 
                                        WHERE Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ContactId =: applicantId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC][0];
        boolean retVal = false;
        String reasonForDupReq = ecfmgCertCase.Reason_for_Duplicate_Certificate__c;
        if(reasonForDupReq == 'Name on Record Changed'){
            ecfmgCertCase.Internal_Status__c = Constants.CASE_STATUS_RETURN_ECFMG_CERTIFICATE;
        }
        else{
            ecfmgCertCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        }
        if(Schema.sObjectType.Case.isUpdateable()){
            update ecfmgCertCase; 
            retVal = true; 
        }
        return retVal;
    }
    //Method to fetch Case Number
    @AuraEnabled(Cacheable = false)
    public static String fetchCaseNumber(){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        List<Group> queueDupCert = [select Id, Name from Group where Type = 'Queue' and Name =: Constants.CASE_QUEUE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED];
        Id queueId = queueDupCert[0].Id;
        String caseNum;
        List<Case> retCaseList = new List<Case>([Select CaseNumber from Case where ContactId =: applicantId AND RecordType.DeveloperName = 'Duplicate_Certificate' AND Ownerid =: queueId WITH SECURITY_ENFORCED ORDER BY CaseNumber Desc LIMIT 1]);
        if(!retCaseList.isEmpty()){
            caseNum = retCaseList[0].CaseNumber;
        }
        return caseNum;
    }
    //Method to check if any duplicate Certificate Case request is present
    @AuraEnabled
    public static boolean checkDupCertSubmission(){
        Boolean retFlag = false;
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> dupCertCaseList = new List<Case>();
        dupCertCaseList = [Select Id from Case where ContactId =: applicantId AND Internal_Status__c !=: Constants.CASE_STATUS_SENT 
                        AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION AND Internal_Status__c !=: Constants.CASE_STATUS_MARKED_FOR_DELETION AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED];
        if(!dupCertCaseList.isEmpty()){
            retFlag = true;
        }
        return retFlag;
    }
     //Method to save the selectedReason and additionalInfo and create Duplicate Certificate
    @AuraEnabled
    public static Boolean saveDupCertReason(String dupCertReason, String dupCertAdditionalInfo){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        Id dupCertRecId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
        List<Group> queueDupCert = [select Id, Name from Group where Type = 'Queue' and Name =: Constants.CASE_QUEUE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED];
        List<Case> ecfmgCertCase = [SELECT Id FROM Case WHERE ContactId =: applicantId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        Case newCase = new Case();  
        newCase.ContactId = applicantId;
        newCase.RecordTypeId = dupCertRecId;
        newCase.OwnerId = queueDupCert[0].Id;
        newCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        newCase.Description = dupCertAdditionalInfo;
        newCase.Reason_for_Duplicate_Certificate__c = dupCertReason;
        if (ecfmgCertCase.size()>0){
            newCase.Id = ecfmgCertCase[0].Id;
            update newCase;
        }else if(Schema.sObjectType.Case.isCreateable()){
            insert newCase; 
        }
        return true;
    }
    @AuraEnabled
    public static List<string> fetchReasonAndDetails(){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        List<String> retVal = new List<String>();
        List<Case> ecfmgCertCase = [SELECT Id,Reason_for_Duplicate_Certificate__c,Description FROM Case WHERE Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ContactId =: applicantId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        if (ecfmgCertCase.size()>0){
            retVal.add(ecfmgCertCase[0].Reason_for_Duplicate_Certificate__c);
            retVal.add(ecfmgCertCase[0].Description);
            return retVal;
        }else{
            retVal.add('');
            retVal.add('');
            return retVal;
        }
    }
    @AuraEnabled
    public static Boolean markforDelete(){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        List<Case> ecfmgCertCase = [SELECT Id,Internal_Status__c FROM Case WHERE Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ContactId =: applicantId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        if (ecfmgCertCase.size()>0){
            ecfmgCertCase[0].Internal_Status__c = Constants.CASE_STATUS_MARKED_FOR_DELETION; 
            update ecfmgCertCase;
            return true;
        }
        return false;
    }
    @AuraEnabled(cacheable = false)
    public static String getDupCertCases(){
        Id applicantId = AppForCertHelper.retrieveCurrentContactId();
        String dupCertCaseId = '';
        List<Case> dupEcfmgCertCase = [SELECT Id FROM Case WHERE ContactId =: applicantId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        if(!dupEcfmgCertCase.isEmpty()){
            dupCertCaseId = dupEcfmgCertCase[0].Id;
        }
        return dupCertCaseId;
    }
}