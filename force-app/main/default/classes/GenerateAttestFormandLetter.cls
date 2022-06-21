public with sharing class GenerateAttestFormandLetter{
    //Check whether AttestationForm and Cover letter are generated already exists for the attestation case
    @AuraEnabled
    public static Boolean checkAttestAsstExists(Id recordId){
        try{
            List<Asset> attstList = [SELECT Id, Name, Type__c FROM Asset WHERE Case__c =: recordId and RecordType.DeveloperName = 'Attestation' AND (Type__c = 'Attestation Form' OR Type__c = 'Cover Letter') WITH SECURITY_ENFORCED];
            if(!attstList.isEmpty()){
                return true;
            }
            return false;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean updateCaseStatus(Id recordId){
        try{
            Case attestCase = [SELECT Id, Internal_Status__c, OwnerId FROM Case WHERE Id =: recordId WITH SECURITY_ENFORCED];
            Group pendingPrintQue = [SELECT Id, Name, Group.DeveloperName FROM Group WHERE Type = 'Queue' AND Group.DeveloperName = 'Print_Queue' WITH SECURITY_ENFORCED];
            attestCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT;
            attestCase.OwnerId = pendingPrintQue.Id;
            if(Case.SObjectType.getDescribe().isUpdateable() && attestCase.Id != null){
                UPDATE attestCase;
            } 
            return true;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void generateAttestFormAndLetterCallOut(Id caseId){
        try{
            String attestformDocConfig = EntityServiceRequestSharingDisabled.getDocConfigRecordId(Constants.DOCCONFIG_ATTESTATION_FORM);
            String attestCoverLetterDocConfig = EntityServiceRequestSharingDisabled.getDocConfigRecordId(Constants.DOCCONFIG_ATTESTATION_COVER_LETTER);
            PDFButlerCallout calloutaAttestForm = new PDFButlerCallout(attestformDocConfig, caseId);
            System.enqueueJob(calloutaAttestForm);
            PDFButlerCallout calloutAttestCoverLetter = new PDFButlerCallout(attestCoverLetterDocConfig, caseId);
            System.enqueueJob(calloutAttestCoverLetter);
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
}