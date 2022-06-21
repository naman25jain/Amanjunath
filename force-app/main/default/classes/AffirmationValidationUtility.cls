// Affirmation validation utillity class
public inherited sharing class AffirmationValidationUtility{
    // Checks if entity portal is enabled
    public static string checkPortal(Id caseRecId){
        boolean verifyWithAlternateEntity = false;
        Id accId;
        for(Affirmation__c rec:[SELECT Id,Verify_with_Alternate_Entity__c FROM Affirmation__c WHERE Case__c=:caseRecId AND recordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION AND Verify_with_Alternate_Entity__c = TRUE WITH SECURITY_ENFORCED]){
            verifyWithAlternateEntity = true;
        }
        Case caseRec=[SELECT Id,Entity__c,Alternate_Entity__c FROM Case WHERE Id=:caseRecId WITH SECURITY_ENFORCED];
        if(verifyWithAlternateEntity){
            accId = caseRec.Alternate_Entity__c;
        }else{
            accId = caseRec.Entity__c;
        }
        if([SELECT Id FROM Account2Service__c WHERE Account__c =: accId AND Service__r.Name=:Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION AND Active__c=true WITH SECURITY_ENFORCED].isEmpty()){
            return Error_Message__mdt.getInstance('Not_Verified_Screen_1_Next_Action_Portal').Error_Message__c;
        }
        return 'SUCCESS';
    }
    public static string markReqdBasedOnPrevAff(Map<String, Object> mapValues, String prev, String next){
        if(String.valueOf(mapValues.get(prev)) == 'Yes' && (!mapValues.containsKey(next) || (mapValues.containsKey(next) && String.isBlank(String.valueOf(mapvalues.get(next)))))){
            return 'Please provide your comments';
        }
        return null;
    }
    public static string checkCurrLengthAcceptable(Map<String, Object> mapValues){
        Id caseRecId = String.valueof(mapValues.get('Case__c'));
        String currLengthAcceptable = String.valueof(mapValues.get('Curriculum_Length_Acceptable__c'));
        Case caseRec = [SELECT Id, Service__c FROM Case WHERE Id =: caseRecId WITH SECURITY_ENFORCED];
        if(caseRec.Service__c != 'ECFMG_Certification' && 
           (currLengthAcceptable == 'Yes, due to acceptable transfer credits' || currLengthAcceptable == 'No, Transfer Credit Review Required')){
            return 'This response for Curriculum Length Acceptable refers to ECFMG Certification cases only';
        }
        return 'SUCCESS';
    }
    public static string checkDocNotAccForClient(Map<String, Object> mapValues){
        Id caseRecId = String.valueof(mapValues.get('Case__c'));
        Boolean docNotAccForClient = Boolean.valueof(mapValues.get('Document_is_not_acceptable_for_the_Clien__c'));
        Boolean incomplOutcome = false;
        Case caseRec = [SELECT Id, Service__c FROM Case WHERE Id =: caseRecId WITH SECURITY_ENFORCED];
        Affirmation__c aff = [SELECT Document_is_complete_and_legible__c, Original_Language_Document_Submitted__c, Graduation_Year_Acceptable_for_ECFMG__c FROM Affirmation__c
                              WHERE Case__c =: caseRecId AND recordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW WITH SECURITY_ENFORCED];
        if(aff.Document_is_complete_and_legible__c == 'No' || aff.Original_Language_Document_Submitted__c == 'No' || aff.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            incomplOutcome = true;
        }
        if(caseRec.Service__c != 'EPIC' && docNotAccForClient){
            return 'This response for Document is not acceptable for Client refers to EPIC cases only';
        }else if(incomplOutcome && docNotAccForClient){
            return 'This response for Document is not acceptable for Client cannot be selected as the outcome of previous affirmations is Incomplete';
        }
        return 'SUCCESS';
    }
    public static string checkTranslationFilled(Id caseRecId){
        Case caseRec = [SELECT Id,Date_Translation_Request_Sent__c,Date_Translation_Received__c,Number_of_Pages_Translated__c FROM Case WHERE Id =:caseRecId WITH SECURITY_ENFORCED];
        String fields = '';
        if(caseRec.Date_Translation_Request_Sent__c == null){
            fields = fields + ' Date Translation Request Sent,';
        }
        if(caseRec.Date_Translation_Received__c == null){
            fields = fields + ' Date Translation Received,';
        }
        if(caseRec.Number_of_Pages_Translated__c == null){
            fields = fields + ' Number of Pages to be Translated';
        }
        String errorMsg = '';
        if(String.isNotBlank(fields)){
            fields = fields.substring(fields.length()-1) == ',' ? fields.removeEnd(',') : fields;
            errorMsg = 'Please fill' + fields + ' fields of case record.';
        }
        return errorMsg;
    }
    public static string checkReturnDocMissingPages(Map<String, Object> mapValues){
        String retCredCompleteLegible = String.valueof(mapValues.get('Returned_credential_complete_and_legible__c'));
        Boolean retDocMissingPages = Boolean.valueof(mapValues.get('Returned_document_is_missing_pages__c'));
        Boolean retDocCutoff = Boolean.valueof(mapValues.get('Returned_document_is_cut_off__c'));
        String errorMsg = '';
        if(retCredCompleteLegible == 'No' && (!retDocMissingPages && !retDocCutoff)){
            errorMsg = 'Please select one or more checkboxes.';
        }
        else{
            errorMsg = 'SUCCESS';
        }
        return errorMsg;
    }
    public static string checkOnlineVerAsset(Map<String, Object> mapValues){
        Id caseRecId = String.valueof(mapValues.get('Case__c'));
        String attMedLicenseVer = String.valueof(mapValues.get('Attestor_License_ver_state_medical_board__c'));
        List<Asset> asstList = [SELECT Id FROM Asset WHERE Case__c =: caseRecId AND RecordType.DeveloperName =: Constants.ASSET_RECORD_TYPE_VERIFICATION 
                                AND Type__c =: Constants.ASSET_TYPE_ONLINE_VERIFICATION AND Status =: Constants.ASSET_STATUS_ACCEPTED WITH SECURITY_ENFORCED];
        if(attMedLicenseVer == 'Yes' && asstList.isEmpty()){
            return 'Please upload the verification information to the case';
        }
        return 'SUCCESS';
    }
    public static string acknReasonSelected(Map<String, Object> mapValues){
        String acknComplete = String.valueof(mapValues.get('Acknowledgment_complete_and_include_sign__c'));
        Boolean signMissing = Boolean.valueof(mapValues.get('Notary_signature_is_missing__c'));
        Boolean sealMissing = Boolean.valueof(mapValues.get('Notary_seal_stamp_is_missing__c'));
        Boolean infoMissing = Boolean.valueof(mapValues.get('Acknowledgment_is_missing_information__c'));
        if(acknComplete == 'No' && !signMissing && !sealMissing && !infoMissing){
            return 'Please select atleast one Reason for Incomplete Acknowledgment';
        }
        return 'SUCCESS';
    }
}