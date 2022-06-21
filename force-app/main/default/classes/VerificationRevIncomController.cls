public with sharing class VerificationRevIncomController{
    //Method to get affirmation led to Incomplete Status
    @AuraEnabled(cacheable = false)
    public static List<String> getIncAffirmations(String caseId){
        try{
            List<String> returnVal = new List<String>();
            Case credVerCase = [SELECT Id, Send_Method__c, Document_Type__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED];
            List<Affirmation__c> affirmation = [SELECT Id, Verification_method__c, Verification_method_is_acceptable__c, Verification_response_returned__c, Verification_response_returned_directly__c, 
            Verification_is_complete_and_legible__c, Verification_is_legible__c, Verification_is_not_cut_off__c, Verification_is_not_missing_pages__c, Verification_response_indicate_cred_auth__c, Credential_returned_with_verification__c, Ret_cred_same_sent_for_verif__c,
            Returned_Credential__c, Returned_credential_complete_and_legible__c, Verification_completed_authorized_offici__c, Official_s_Signature_Acceptable__c,
            Official_s_Written_Name_Acceptable__c, Official_s_Title_Acceptable__c, Verification_date_acceptable__c, Institution_seal_acceptable__c,
            Document_is_Certificate_of_GoodStanding__c, Change_Document_Type_Action__c, Document_is_legible__c, Document_is_not_missing_pages__c, Document_is_not_cut_off__c, 
            Document_is_complete_and_legible__c, Original_Language_Document_Submitted__c, Document_is_not_acceptable_for_the_Clien__c,
            Document_is_a_Final_Medical_School_Trans__c, Online_portal_confirm_information__c, Online_portal_has_access_date__c, Letter_in_lieu_confirms_all_information__c, Letter_includes_an_acceptable_cert__c, Letter_completed_by_authorized_official__c,
            Letter_is_on_institution_letterhead__c, Letter_is_signed_by_official__c, Date_of_letter_is_acceptable__c, Institution_seal_is_acceptable__c, Returned_credential_is_same_credential__c, Returned_credential_is_not_same_cred__c, Form_returned_from_correct_authority__c,
            Form_is_complete_and_legible__c, Form_returned_directly_from_primary_sou__c, Responses_are_in_English__c, Certification_Form_completed_by_aut__c, Certification_Official_s_signature__c, Certification_Official_s_written_name__c,
            Certification_Official_s_title_is_accep__c, Certification_Signature_date_is_accept__c, Certification_Institution_seal_is_accep__c, Years_of_education_required_provided__c, Credential_degree_presented_provided__c, Applicant_transferred_credits__c, All_Information_Provided__c,
            Attendance_end_date_is_provided__c, Attendance_start_date_is_provided__c, Total_Attendance_is_Provided__c FROM Affirmation__c WHERE Case__c =: caseId AND RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
            for(Affirmation__c affirm : affirmation){
                if(credVerCase.Send_Method__c == 'Entity Portal' && credVerCase.Document_Type__c != Constants.MED_EDU_FORM){
                    if(credVerCase.Document_Type__c == 'Final Medical School Transcript' || credVerCase.Document_Type__c == 'Certificate of Good Standing'){
                        returnVal.addAll(getIncAffirmCGSorFMST(affirm));
                    }
                    else{
                        returnVal.addAll(getIncAffirmVF(affirm));
                    }
                }
                else if(credVerCase.Document_Type__c == Constants.MED_EDU_FORM){
                    returnVal.addAll(getIncAffirmRetMedForm(affirm));
                }
                else{
                    returnVal.addAll(getAllIncAffirmForOther(affirm));
                }
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getAllIncAffirmForOther(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Verification_method_is_acceptable__c == 'No'){
                returnVal.add('Verification method is acceptable for this document type - <Strong>No</Strong>');
            }
            if(affirm.Verification_response_returned__c == 'No'){
                returnVal.add('Verification response returned from correct authority - <Strong>No</Strong>');
            }
            if(affirm.Verification_method_is_acceptable__c == 'No' || affirm.Verification_response_returned__c == 'No'){
                return returnVal;
            }
            else{
                returnVal.addAll(refgetAllIncAffirmForOther(affirm));
            }
            returnVal.addAll(getAllIncAffirmForPaper2(affirm));
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> refgetAllIncAffirmForOther(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Verification_response_returned_directly__c == 'No'){
                returnVal.add('Verification response returned directly from primary source - <Strong>No</Strong>');
            }
            if(affirm.Verification_is_complete_and_legible__c == 'No'){
                returnVal.add('Verification is complete and legible - <Strong>No</Strong>');
            }
            if(affirm.Verification_is_legible__c == 'No'){
                returnVal.add('Verification is legible - <Strong>No</Strong>');
            }
            if(affirm.Verification_is_not_missing_pages__c == 'No'){
                returnVal.add('Verification is not missing pages - <Strong>No</Strong>');
            }
            if(affirm.Verification_is_not_cut_off__c == 'No'){
                returnVal.add('Verification is not cut off - <Strong>No</Strong>');
            }
            if(affirm.Verification_response_indicate_cred_auth__c == 'No'){
                returnVal.add('Verification response indicates credential is authentic and correct - <Strong>No</Strong>');
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getAllIncAffirmForPaper2(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Verification_method__c == 'ECFMG Verification Form'){
                returnVal.addAll(getIncAffirmVF(affirm));
            }
            if(affirm.Verification_method__c == 'Final Medical School Transcript provided to ECFMG directly by institution' || affirm.Verification_method__c == 'CGS provided to ECFMG directly by institution'){
                returnVal.addAll(getIncAffirmCGSorFMST(affirm));
            }
            if(affirm.Verification_method__c == 'Online Verification'){
                returnVal.addAll(getIncAffirmOnlineWeb(affirm));
            }
            if(affirm.Verification_method__c == 'Letter in Lieu'){
                returnVal.addAll(getIncAffirmLetterInLieu(affirm));
            }
            return returnVal;   
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getIncAffirmLetterInLieu(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Returned_credential_is_same_credential__c == 'No' && (affirm.Returned_credential_is_not_same_cred__c == 'Incorrect Credential returned' || affirm.Returned_credential_is_not_same_cred__c == 'Revised/Updated Credential Provided Unacceptable')){
                if(affirm.Returned_credential_is_not_same_cred__c == 'Incorrect Credential returned'){
                    returnVal.add('Returned credential is same credential sent for verification - <Strong>No</Strong>, Incorrect Credential returned');
                }
                else{
                    returnVal.add('Returned credential is same credential sent for verification - <Strong>No</Strong>, Revised/Updated Credential Provided Unacceptable');
                }
            }
            if(affirm.Letter_includes_an_acceptable_cert__c == 'No'){
                returnVal.add('Letter includes an acceptable certification statement - <Strong>No</Strong>');
            }
            if(affirm.Letter_completed_by_authorized_official__c == 'No'){
                returnVal.add('Letter completed by authorized official - <Strong>No</Strong>');
            }
            if(affirm.Letter_is_on_institution_letterhead__c == 'No'){
                returnVal.add('Letter is on institution letterhead - <Strong>No</Strong>');
            }
            if(affirm.Letter_is_signed_by_official__c == 'No'){
                returnVal.add('Letter is signed by official - <Strong>No</Strong>');
            }
            if(affirm.Date_of_letter_is_acceptable__c == 'No'){
                returnVal.add('Date of letter is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Institution_seal_is_acceptable__c == 'No, seal is not acceptable'){
                returnVal.add('Institution seal is acceptable - <Strong>No</Strong>, seal is not acceptable');
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getIncAffirmVF(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Credential_returned_with_verification__c == 'No'){
                returnVal.add('Credential returned with verification - <Strong>No</Strong>');
            }
            if(affirm.Ret_cred_same_sent_for_verif__c == 'No' && affirm.Returned_Credential__c != 'Revised/Updated Credential Provided Acceptable (paper/email)'){
                returnVal.add('Returned credential is same credential sent for verification - <Strong>No</Strong>');
            }
            if(affirm.Returned_credential_complete_and_legible__c == 'No'){
                returnVal.add('Returned credential is complete and legible - <Strong>No</Strong>');
            }
            if(affirm.Verification_completed_authorized_offici__c == 'No'){
                returnVal.add('Verification completed by authorized official - <Strong>No</Strong>');
            }
            if(affirm.Official_s_Signature_Acceptable__c == 'No'){
                returnVal.add('Official’s signature is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Official_s_Written_Name_Acceptable__c == 'No'){
                returnVal.add('Official’s written name is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Official_s_Title_Acceptable__c == 'No'){
                returnVal.add('Official’s title is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Verification_date_acceptable__c == 'No'){
                returnVal.add('Verification date is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Institution_seal_acceptable__c == 'No, seal is not acceptable'){
                returnVal.add('Institution seal is acceptable - <Strong>No</Strong>, seal is not acceptable');
            }
            return returnVal;  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getIncAffirmCGSorFMST(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if((affirm.Document_is_Certificate_of_GoodStanding__c == 'No' || affirm.Document_is_a_Final_Medical_School_Trans__c == 'No') && affirm.Change_Document_Type_Action__c == 'Request New Document from Entity'){
                if(affirm.Document_is_Certificate_of_GoodStanding__c == 'No'){
                    returnVal.add('Document is a Certificate of Good Standing - <Strong>No</Strong>, Request New Document from Entity');
                }
                if(affirm.Document_is_a_Final_Medical_School_Trans__c == 'No'){
                    returnVal.add('Document is a Final Medical School Transcript - <Strong>No</Strong>, Request New Document from Entity');
                }
            } 
            if(affirm.Document_is_complete_and_legible__c == 'No'){
                returnVal.add('Document is complete and legible - <Strong>No</Strong>');
            }
            if(affirm.Document_is_legible__c == 'No'){
                returnVal.add('Document is legible - <Strong>No</Strong>');
            }
            if(affirm.Document_is_not_missing_pages__c == 'No'){
                returnVal.add('Document is not missing pages - <Strong>No</Strong>');
            }
            if(affirm.Document_is_not_cut_off__c == 'No'){
                returnVal.add('Document is not cut off - <Strong>No</Strong>');
            }
            if(affirm.Original_Language_Document_Submitted__c == 'No'){
                returnVal.add('Original Language Document Submitted - <Strong>No</Strong>');
            }
            if(affirm.Document_is_not_acceptable_for_the_Clien__c == true){
                returnVal.add('Document is not acceptable for Client is selected');
            }
            returnVal.addAll(getIncAffirmVF(affirm));
            return returnVal;   
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getIncAffirmOnlineWeb(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Online_portal_confirm_information__c == 'No'){
                returnVal.add('Online Portal confirms all information on the credential - <Strong>No</Strong>');
            }
            if(affirm.Online_portal_has_access_date__c == 'No'){
                returnVal.add('Online Portal verification includes an access date - <Strong>No</Strong>');
            }
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> getIncAffirmRetMedForm(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Form_returned_from_correct_authority__c == 'No'){
                returnVal.add('Form returned from correct authority - <Strong>No</Strong>');
                return returnVal;
            }
            if(affirm.Form_is_complete_and_legible__c == 'No'){
                returnVal.add('Form is complete and legible - <Strong>No</Strong>');
            }
            if(affirm.Form_returned_directly_from_primary_sou__c == 'No'){
                returnVal.add('Form returned directly from primary source - <Strong>No</Strong>');
            }
            if(affirm.Certification_Form_completed_by_aut__c == 'No'){
                returnVal.add('Certification: Form completed by authorized official per ASL - <Strong>No</Strong>');
            }
            if(affirm.Certification_Official_s_signature__c == 'No'){
                returnVal.add('Certification: Official’s signature is acceptable per ASL - <Strong>No</Strong>');
            }
            if(affirm.Certification_Official_s_written_name__c == 'No'){
                returnVal.add('Certification: Official’s written name is acceptable per ASL - <Strong>No</Strong>');
            }
            if(affirm.Certification_Official_s_title_is_accep__c == 'No'){
                returnVal.add('Certification: Official’s title is acceptable per ASL - <Strong>No</Strong>');
            }
            if(affirm.Certification_Signature_date_is_accept__c == 'No'){
                returnVal.add('Certification: Signature date is acceptable - <Strong>No</Strong>');
            }
            if(affirm.Certification_Institution_seal_is_accep__c == 'No'){
                returnVal.add('Certification: Institution seal is acceptable per ASL - <Strong>No</Strong>');
            }
            returnVal.addAll(refgetIncAffirmRetMedForm(affirm));
            return returnVal;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> refgetIncAffirmRetMedForm(Affirmation__c affirm){
        try{
            List<String> returnVal = new List<String>();
            if(affirm.Years_of_education_required_provided__c == 'No'){
                returnVal.add('Pre-Medical Education: Years of education required provided - <Strong>No</Strong>');
            }
            if(affirm.Credential_degree_presented_provided__c == 'No'){
                returnVal.add('Pre-Medical Education: Credential/degree presented provided - <Strong>No</Strong>');
            }
            if(affirm.Applicant_transferred_credits__c == 'No'){
                returnVal.add('Pre-Medical Education: Applicant transferred credits to this institution response provided - <Strong>No</Strong>');
            }
            if(affirm.Total_Attendance_is_Provided__c == 'No'){
                returnVal.add('Medical Education: Total Attendance is Provided - <Strong>No</Strong>');
            }
            if(affirm.Attendance_start_date_is_provided__c == 'No'){
                returnVal.add('Medical Education: Attendance start date is provided - <Strong>No</Strong>');
            }
            if(affirm.Attendance_end_date_is_provided__c == 'No'){
                returnVal.add('Medical Education: Attendance end date is provided - <Strong>No</Strong>');
            }
            if(affirm.All_Information_Provided__c == 'No'){
                returnVal.add('Unusual Circumstances: All Information Provided - <Strong>No</Strong>');
            }
            return returnVal;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable = false)
    public static Affirmation__c getVerReviewAffirm(Id caseId){
        try{
            Affirmation__c affirm = [SELECT Id, Incomplete_Reason_Authorization__c, Incomplete_Reason_Completion_Med_Ed_form__c, Incomplete_Reason_Completion_Verform__c, Incomplete_Reason_Credential__c,
            Incomplete_Reason_Envelope__c, Incomplete_Reason_Grades__c, Incomplete_Reason_Name_Match__c, Incomplete_Reason_Name_Missing__c, Incomplete_Reason_OfficeSeal_Stamp_Miss__c, Incomplete_Reason_OfficeSeal_StampNotMat__c,
            Incomplete_Reason_Other__c, Incomplete_Reason_Response__c, Incomplete_Reason_Return__c, Incomplete_Reason_Signature_Match__c, Incomplete_Reason_Signature_Missing__c, Incomplete_Reason_Title_Match__c, 
            Incomplete_Reason_Title_Missing__c, Incomplete_Reason_Transcript__c, Incomplete_Reason_Transcript_Seal__c, Incomplete_Reason_Verification__c, Comments__c
            FROM Affirmation__c WHERE Case__c =: caseId AND RecordType.DeveloperName =: Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
            return affirm;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Case getCase(Id caseId){
        try{
            Case cvCase = [SELECT Id, Send_Method__c, Document_Type__c FROM Case WHERE Id =: caseId WITH SECURITY_ENFORCED LIMIT 1];
            return cvCase;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean saveAffirmationRec(String affirmDetails){
        system.debug('savemethod');
        try{
            Boolean updated = true;
            Map<String,String> affirmDetailsMap = (Map<String,String>) JSON.deserialize(affirmDetails, Map<String,String>.class);
            system.debug('affirmDetailsMap :'+affirmDetailsMap);
            Affirmation__c affirm = [SELECT Id, Incomplete_Reason_Authorization__c, Incomplete_Reason_Completion_Med_Ed_form__c, Incomplete_Reason_Completion_Verform__c, Incomplete_Reason_Credential__c,
            Incomplete_Reason_Envelope__c, Incomplete_Reason_Grades__c, Incomplete_Reason_Name_Match__c, Incomplete_Reason_Name_Missing__c, Incomplete_Reason_OfficeSeal_Stamp_Miss__c, Incomplete_Reason_OfficeSeal_StampNotMat__c,
            Incomplete_Reason_Other__c, Incomplete_Reason_Response__c, Incomplete_Reason_Return__c, Incomplete_Reason_Signature_Match__c, Incomplete_Reason_Signature_Missing__c, Incomplete_Reason_Title_Match__c, 
            Incomplete_Reason_Title_Missing__c, Incomplete_Reason_Transcript__c, Incomplete_Reason_Transcript_Seal__c, Incomplete_Reason_Verification__c, Comments__c
            FROM Affirmation__c WHERE Id =: affirmDetailsMap.get('affirmId') WITH SECURITY_ENFORCED];
            affirm.Incomplete_Reason_Authorization__c = Boolean.valueOf(affirmDetailsMap.get('authorization'));
            affirm.Incomplete_Reason_Completion_Med_Ed_form__c = Boolean.valueOf(affirmDetailsMap.get('completionMedform'));
            affirm.Incomplete_Reason_Completion_Verform__c = Boolean.valueOf(affirmDetailsMap.get('completionVerform'));
            affirm.Incomplete_Reason_Credential__c = Boolean.valueOf(affirmDetailsMap.get('credential'));
            affirm.Incomplete_Reason_Envelope__c = Boolean.valueOf(affirmDetailsMap.get('envelope'));
            affirm.Incomplete_Reason_Grades__c = Boolean.valueOf(affirmDetailsMap.get('grades'));
            affirm.Incomplete_Reason_Name_Match__c = Boolean.valueOf(affirmDetailsMap.get('nameMatch'));
            affirm.Incomplete_Reason_Name_Missing__c = Boolean.valueOf(affirmDetailsMap.get('nameMissing'));
            affirm.Incomplete_Reason_OfficeSeal_Stamp_Miss__c = Boolean.valueOf(affirmDetailsMap.get('OfficeSealMissing'));
            affirm.Incomplete_Reason_OfficeSeal_StampNotMat__c = Boolean.valueOf(affirmDetailsMap.get('officeSealNotMatch'));
            affirm.Incomplete_Reason_Other__c = Boolean.valueOf(affirmDetailsMap.get('other'));
            affirm.Incomplete_Reason_Response__c = Boolean.valueOf(affirmDetailsMap.get('response'));
            affirm.Incomplete_Reason_Return__c = Boolean.valueOf(affirmDetailsMap.get('returnR'));
            affirm.Incomplete_Reason_Signature_Match__c = Boolean.valueOf(affirmDetailsMap.get('signatureMatch'));
            affirm.Incomplete_Reason_Signature_Missing__c = Boolean.valueOf(affirmDetailsMap.get('signMiss'));
            affirm.Incomplete_Reason_Title_Match__c = Boolean.valueOf(affirmDetailsMap.get('titleMatching'));
            affirm.Incomplete_Reason_Title_Missing__c = Boolean.valueOf(affirmDetailsMap.get('titleMiss'));
            affirm.Incomplete_Reason_Transcript__c = Boolean.valueOf(affirmDetailsMap.get('transc'));
            affirm.Incomplete_Reason_Transcript_Seal__c = Boolean.valueOf(affirmDetailsMap.get('transcrSeal'));
            affirm.Incomplete_Reason_Verification__c = Boolean.valueOf(affirmDetailsMap.get('verification'));
            affirm.Comments__c = affirmDetailsMap.get('comments');
            if(Affirmation__c.SObjectType.getDescribe().isUpdateable() && affirm.Id != null){
                UPDATE affirm;
            }
            return updated;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}