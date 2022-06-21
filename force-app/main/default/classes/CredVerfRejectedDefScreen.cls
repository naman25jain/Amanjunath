public with sharing class CredVerfRejectedDefScreen{
    //method to check rejected Credential affirmations for Cred Verification record for applicant view in case detail page
    @AuraEnabled(cacheable = false)
    public static List<String> getCredVerfDefLang(String caseId){
        try{            
            Map<String,String> defMap = new Map<String,String>();
            List<Deficiency_Language__mdt> defList = [SELECT Id, DeveloperName, Deficiency_Reason__c, Label, MasterLabel FROM Deficiency_Language__mdt WITH SECURITY_ENFORCED];        
            for(Deficiency_Language__mdt def : defList){
                defMap.put(def.DeveloperName, def.Deficiency_Reason__c);
            }
            if(Affirmation__c.SObjectType.getDescribe().isAccessible()){
                List<Affirmation__c> affirmations = [SELECT Id, Status__c, Asset_Type__c, Translation_Evaluation_Status__c, Translation_Required__c, Translation_is_legible__c, Credential_Rejection_Reason__c,
                                            Translation_is_not_missing_pages__c, Translation_is_not_cut_off__c, Translator_is_acceptable__c, Entity_Evaluation_Status__c,
                                            Translation_is_of_original_document__c, Translation_is_word_for_word__c, English_Certification_Statement_accept__c, Reject_Entity_Credential__c,
                                            Translation_is_signed_by_the_Translator__c, Translation_is_on_the_letterhead__c, Reject_Translation__c, 
                                            Case__r.Document_type__c, Credential_Evaluation_Status__c, Translation_Rejection_Reason__c,
                                            Document_is_a_Final_Medical_Diploma__c, Document_is_legible__c, Document_is_not_missing_pages__c, Document_is_not_cut_off__c, 
                                            Original_Language_Document_Submitted__c, Degree_Title_Acceptable__c, Graduation_Year_Acceptable_for_ECFMG__c, Document_is_not_acceptable_for_the_Clien__c,
                                            Reject_Credential__c, Applicant_Request__c, Curriculum_Length_Acceptable__c, Document_is_a_Final_Medical_School_Trans__c,
                                            Document_is_a_TCT__c, Transcript_lists_all_required_courses__c, Transcript_lists_correct_dates_of_attend__c, All_courses_were_passed_at_med_school__c, 
                                            Medical_school_acceptable__c, Credits_transferred_from_one_med_school__c, Change_Document_Type_Action__c, Rejection_Reason__c, Not_acceptable_for_Client_Reason__c, 
                                            Confirms_that_Diploma_has_not_issued__c,Expected_Degree_Issue_Date_is_present__c,Expected_Degree_Issue_Date_in_the_future__c,
                                            Program_Duration_Acceptable__c, Specialty_Program_is_Acceptable__c, Specialty_Licensure_Type_is_Acceptable__c, 
                                            Degree_Program_is_Acceptable__c, Comments__c 
                                            FROM Affirmation__c WHERE case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
                return getRejectedAffirmtnLang(defMap, affirmations);
            }
            return null;
        }catch(Exception e){
            return new List<string>{e.getMessage()};
        }
    }
    public static List<String> getRejectedAffirmtnLang(Map<String,String> defMap, List<Affirmation__c> affirmations){        
        List<String> returnVal = new List<String>();
        if(!affirmations.isEmpty() && !defMap.isEmpty()){
            for(Affirmation__c affr:affirmations){
                if(affr.Entity_Evaluation_Status__c == Constants.CASE_STATUS_REJECTED){
                    returnVal.addAll(getRejectedAffirmtnLangEntity(affr,defMap)); 
                }
                if(affr.Credential_Evaluation_Status__c == Constants.CASE_STATUS_REJECTED){
                    returnVal.addAll(getRejectedAffirmtnLangFMD(affr,defMap)); 
                    returnVal.addAll(getRejectedAffirmtnLangFT(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangTCT(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangAGD(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangDL(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangSMST(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangPGME(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangMRC(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangSQ(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangPIC(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangADMS(affr,defMap));
                    returnVal.addAll(getRejectedAffirmtnLangCGS(affr,defMap));
                }
            }
        }
        return returnVal;        
    }
    //FMD rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangFMD(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Final Medical Diploma'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }else{                
                returnVal.addAll(rejectedFMDCog(affr,defMap));
            }            
        }
        return returnVal;
    }
    // FMD cognitive issue handle method
    public static List<String> rejectedFMDCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_FMD_CI'));
        }
        if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            returnVal.add(defMap.get('Graduation_Year_Acceptable_FMD_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //Entity rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangEntity(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Reject_Entity_Credential__c){
            returnVal.add(affr.Credential_Rejection_Reason__c);            
        }
        return returnVal;
    }
    //Final Medical School Transcript rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangFT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Final Medical School Transcript'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{                
                returnVal.addAll(rejectedFTCog(affr, defMap));
            }            
        }
        return returnVal;
    }
    // rejected languages for FT
    public static List<String> rejectedFTCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_FMST_CI'));
        }
        if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            returnVal.add(defMap.get('Graduation_Year_Acceptable_FMST_CI'));
        } 
        if(affr.Curriculum_Length_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Curriculum_Length_Acceptable_No_FMST_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //TCT rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangTCT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Transcript to Document Transfer Credits'){
            if(affr.Document_is_a_TCT__c == 'No'){
                returnVal.add(defMap.get('Document_is_a_TCT_CI'));
            }
            if(affr.Transcript_lists_all_required_courses__c == 'No'){
                returnVal.add(defMap.get('Transcript_lists_all_required_cou_TCT_CI'));
            } 
            returnVal.addAll(getRejectedAffirmationLangTCTCog(affr,defMap)); 
        }
        return returnVal;
    }
    //ALternate Graduation Document rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangAGD(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Alternate Graduation Document'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Degree_Title_Acceptable__c == 'No'){
                    returnVal.add(defMap.get('Degree_Title_Acceptable_AGD_CI'));
                } 
                if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
                    returnVal.add(affr.Rejection_Reason__c);
                }                
            }
        }
        return returnVal;
    }
    //Deans Letter rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangDL(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Letter from Dean'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{                
                returnVal.addAll(rejectedDLCog(affr, defMap));
            }
        }
        return returnVal;
    }
    // rejected DL lang cognitive method handle
    public static List<String> rejectedDLCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_DL_CI'));
        } 
        if(affr.Expected_Degree_Issue_Date_is_present__c == 'No'){
            returnVal.add(defMap.get('Expected_Degree_Date_is_pre_DL_CI'));
        } 
        if(affr.Expected_Degree_Issue_Date_in_the_future__c == 'No'){
            returnVal.add(defMap.get('Expected_Degree_Date_is_in_the_fut_DL_CI'));
        } 
        if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            returnVal.add(defMap.get('Graduation_Year_Acceptable_for_DL_CI'));
        } 
        if(affr.Confirms_that_Diploma_has_not_issued__c == 'No'){
            returnVal.add(defMap.get('Confirms_the_Diploma_has_not_yet_DL_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //Student Medical School Transcript rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangSMST(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Student Medical School Transcript'){
             if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{    
                if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
                    returnVal.add(affr.Rejection_Reason__c);
                }
            }
        }
        return returnVal;
    }
    //Postgraduate Medical Education Cred rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangPGME(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Postgraduate Training Credential'){
           if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{                
                returnVal.addAll(rejectedPGMECog(affr, defMap));
            }
        }
        return returnVal;
    }
    // rejected PGME cognitive method handle
    public static List<String> rejectedPGMECog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Program_Duration_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Program_Duration_Acceptable_PGE_CI'));
        }  
        if(affr.Specialty_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_Program_is_Acceptable_PGE_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //Medical Registration Certificate/License to Practive Medicine rejected scenario for Cred Verification case detail - in applicant portal
    public static List<String> getRejectedAffirmtnLangMRC(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Medical Registration Certificate/License to Practice Medicine'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{  
                if(affr.Specialty_Licensure_Type_is_Acceptable__c == 'No'){
                    returnVal.add(defMap.get('Specialty_Licensure_Type_is_Acc_MRC_CI'));
                } 
                if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
                    returnVal.add(affr.Rejection_Reason__c);
                }  
            }
        }
        return returnVal;
    }
    //Specialist Qualification rejected scenario for Cred Verification case detail - in applicant
    public static List<String> getRejectedAffirmtnLangSQ(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Specialist Qualification'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{ 
                returnVal.addAll(rejectedSQCog(affr, defMap));
            }
        }
        return returnVal;
    }
    // rejected SQ cognitive method handle
    public static List<String> rejectedSQCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Program_Duration_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Program_Duration_Acceptable_SQ_CI'));
        } 
        if(affr.Specialty_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_is_Acceptable_SQ_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //Pregraduate Internship Certificate scenario for Cred Verification case detail - in applicant
    public static List<String> getRejectedAffirmtnLangPIC(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Pregraduate Internship Certificate'){
           if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{  
                returnVal.addAll(rejectedPICCog(affr, defMap));
            }
        }
        return returnVal;
    }
    // rejected PIC cognitive method handle
    public static List<String> rejectedPICCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Program_Duration_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Program_Duration_Acceptable_PIC_CI'));
        } 
        if(affr.Specialty_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_Program_is_Acceptable_PIC_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    //Advanced Degree in Medical Sciences scenario for Cred Verification case detail - in applicant
    public static List<String> getRejectedAffirmtnLangADMS(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Advanced Degree in the Medical Sciences'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{    
                if(affr.Degree_Program_is_Acceptable__c == 'No'){
                    returnVal.add(defMap.get('Degree_Program_is_Acceptable_ADMS_CI'));
                }
                if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
                    returnVal.add(affr.Rejection_Reason__c);
                }
            }
        }
        return returnVal;
    }
    //Certificate of Good Standing/Current Professional Status scenario for Cred Verification case detail - in applicant
    public static List<String> getRejectedAffirmtnLangCGS(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Certificate of Good Standing'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{    
                if(affr.Specialty_Licensure_Type_is_Acceptable__c == 'No'){
                    returnVal.add(defMap.get('Specialty_Licensure_Type_is_Acc_CGS_CI'));
                } 
                if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
                    returnVal.add(affr.Rejection_Reason__c);
                }
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangTCTCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Transcript_lists_correct_dates_of_attend__c == 'No'){
            returnVal.add(defMap.get('Transcript_lists_correct_date_TCT_CI'));
        } 
		if(affr.All_courses_were_passed_at_med_school__c == 'No'){
            returnVal.add(defMap.get('All_courses_were_passed_at_med_TCT_CI'));
        }
		if(affr.Medical_school_acceptable__c == 'No'){
            returnVal.add(defMap.get('Medical_school_acceptable_TCT_CI'));
        } 
		if(affr.Credits_transferred_from_one_med_school__c == 'No'){
            returnVal.add(defMap.get('Credits_transferred_only_from_one_TCT_CI'));
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
}