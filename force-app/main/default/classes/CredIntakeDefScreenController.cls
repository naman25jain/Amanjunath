public with sharing class CredIntakeDefScreenController{
    //method to check rejected Credential affirmations
    @AuraEnabled(cacheable = false)
    public static List<String> getCredIntakeDefLang(String caseId){
        List<String> returnVal = new List<String>();
        Map<String,String> defMap = new Map<String,String>();
        List<Deficiency_Language__mdt> defList = [SELECT Id,DeveloperName,Deficiency_Reason__c,Label,MasterLabel FROM Deficiency_Language__mdt WITH SECURITY_ENFORCED];        
        for(Deficiency_Language__mdt def : defList){
            defMap.put(def.DeveloperName, def.Deficiency_Reason__c);
        }
        List<Affirmation__c> affirmations = [SELECT id, Status__c, Asset_Type__c,Translation_Evaluation_Status__c,Translation_Required__c,Translation_is_legible__c,
                                            Translation_is_not_missing_pages__c,Translation_is_not_cut_off__c,Translator_is_acceptable__c,
                                            Translation_is_of_original_document__c,Translation_is_word_for_word__c,English_Certification_Statement_accept__c,
                                            Translation_is_signed_by_the_Translator__c,Translation_is_on_the_letterhead__c,Reject_Translation__c, 
                                            Case__r.Document_type__c,Credential_Evaluation_Status__c,Translation_Rejection_Reason__c,Entity_Evaluation_Status__c,Reject_Entity_Credential__c,Credential_Rejection_Reason__c,
                                            Document_is_a_Final_Medical_Diploma__c,Document_is_legible__c,Document_is_not_missing_pages__c,Document_is_not_cut_off__c,
                                            Original_Language_Document_Submitted__c,Degree_Title_Acceptable__c,Graduation_Year_Acceptable_for_ECFMG__c,Document_is_not_acceptable_for_the_Clien__c,
                                            Reject_Credential__c,Applicant_Request__c,Curriculum_Length_Acceptable__c,Document_is_a_Final_Medical_School_Trans__c,
                                            Document_is_a_TCT__c,Transcript_lists_all_required_courses__c,Transcript_lists_correct_dates_of_attend__c,All_courses_were_passed_at_med_school__c,
                                            Medical_school_acceptable__c,Credits_transferred_from_one_med_school__c,Change_Document_Type_Action__c,Rejection_Reason__c,Not_acceptable_for_Client_Reason__c,
                                            Confirms_that_Diploma_has_not_issued__c,Expected_Degree_Issue_Date_is_present__c,Expected_Degree_Issue_Date_in_the_future__c,
                                            Program_Duration_Acceptable__c,Specialty_Program_is_Acceptable__c,Specialty_Licensure_Type_is_Acceptable__c,
                                            Degree_Program_is_Acceptable__c
                                            FROM Affirmation__c WHERE case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
        for(Affirmation__c affr:affirmations){
            if(affr.Translation_Evaluation_Status__c == Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE){
                returnVal.addAll(getRejectedAffirmationLangTran(affr,defMap));   
            } 
            if(affr.Entity_Evaluation_Status__c == Constants.AFFIRMATION_STATUS_REJECTED){
                returnVal.addAll(getRejectedAffirmationLangEnt(affr,defMap)); 
            }
            if(affr.Credential_Evaluation_Status__c == Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE || affr.Credential_Evaluation_Status__c == Constants.AFFIRMATION_STATUS_REJECTED){
                returnVal.addAll(getRejectedAffirmationLangFMD(affr,defMap)); 
                returnVal.addAll(getRejectedAffirmationLangFT(affr,defMap));   
                returnVal.addAll(getRejectedAffirmationLangTCT(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangAGD(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangDL(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangSMST(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangPGE(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangMRC(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangSQ(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangPIC(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangADMS(affr,defMap));
                returnVal.addAll(getRejectedAffirmationLangCGS(affr,defMap));
            }          
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangTran(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Translation_Required__c == 'Translation required, not provided'){
            returnVal.add(defMap.get('Translation_required_not_provided_CI'));
        }
        if(affr.Translation_is_legible__c == 'No'){
            returnVal.add(defMap.get('Translation_is_legible_CI'));
        }
        if(affr.Translation_is_not_missing_pages__c == 'No'){
            returnVal.add(defMap.get('Translation_is_not_missing_pages_CI'));
        }
        if(affr.Translation_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Translation_is_not_cut_off_CI'));
        }
        if(affr.Translator_is_acceptable__c == 'No'){
            returnVal.add(defMap.get('Translator_is_acceptable_CI'));
        }
        if(affr.Translation_is_of_original_document__c == 'No'){
            returnVal.add(defMap.get('Translation_of_original_document_CI'));
        }
        if(affr.Translation_is_word_for_word__c == 'No'){
            returnVal.add(defMap.get('Translation_is_word_for_word_CI'));
        }
        if(affr.English_Certification_Statement_accept__c == 'No'){
            returnVal.add(defMap.get('English_Certification_Statement_is_ac_CI'));
        }
        if(affr.Translation_is_signed_by_the_Translator__c == 'No'){
            returnVal.add(defMap.get('Translation_is_signed_by_the_Trans_CI'));
        }
        if(affr.Translation_is_on_the_letterhead__c == 'No'){
            returnVal.add(defMap.get('Translation_is_on_the_letterhead_CI'));
        }
        if(affr.Reject_Translation__c){
            returnVal.add(affr.Translation_Rejection_Reason__c);            
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangEnt(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        returnVal = CredVerfRejectedDefScreen.getRejectedAffirmtnLangEntity(affr, defMap);
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFMD(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>(); 
        if(affr.Case__r.Document_type__c == 'Final Medical Diploma'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_Final_Medical_REQ_FMD_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_FMD_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_FMD_CI'));
                } 
                returnVal.addAll(getRejectedAffirmationLangFMDCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFMDCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();          
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_FMD_CI'));
        }          
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_FMD_CI'));
        }            
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_FMD_CI'));
        }  
        if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            returnVal.add(defMap.get('Graduation_Year_Acceptable_FMD_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Final Medical School Transcript'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_FMST_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_FMST_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_FMST_CI'));
                } 
                returnVal.addAll(getRejectedAffirmationLangFTCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFTCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();           
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_FMST_CI'));
        }          
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_FMST_CI'));
        }            
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_FMST_CI'));
        } 
        if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
            returnVal.add(defMap.get('Graduation_Year_Acceptable_FMST_CI'));
        } 
		if(affr.Curriculum_Length_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Curriculum_Length_Acceptable_No_FMST_CI'));
        }
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangTCT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Transcript to Document Transfer Credits'){
            if(affr.Document_is_a_TCT__c == 'No'){
                returnVal.add(defMap.get('Document_is_a_TCT_CI'));
            }
            if(affr.Document_is_legible__c == 'No'){
                returnVal.add(defMap.get('Document_is_legible_TCT_CI'));
            }
            if(affr.Document_is_not_missing_pages__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_missing_pages_TCT_CI'));
            }
            if(affr.Document_is_not_cut_off__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_cut_off_TCT_CI'));
            }
            if(affr.Original_Language_Document_Submitted__c == 'No'){
                returnVal.add(defMap.get('Original_Language_Document_Sub_TCT_CI'));
            }        
            if(affr.Transcript_lists_all_required_courses__c == 'No'){
                returnVal.add(defMap.get('Transcript_lists_all_required_cou_TCT_CI'));
            }   
            returnVal.addAll(getRejectedAffirmationLangTCTCog(affr,defMap));     
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
    public static List<String> getRejectedAffirmationLangAGD(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Alternate Graduation Document'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_an_AGD_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_AGD_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_AGD_CI'));
                }
                returnVal.addAll(getRejectedAffirmationLangAGDCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangAGDCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();   
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_AGD_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_AGD_CI'));
        }               
        if(affr.Degree_Title_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Title_Acceptable_AGD_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangDL(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Letter from Dean'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_Dean_s_Letter_Req_DL_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{            
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_DL_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_DL_CI'));
                }
                returnVal.addAll(getRejectedAffirmationLangDLCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangDLCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();                 
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_DL_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_DL_CI'));
        }         
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
    public static List<String> getRejectedAffirmationLangSMST(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Student Medical School Transcript'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_SMST_Req_SMST_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_SMST_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_SMST_CI'));
                } 
                returnVal.addAll(getRejectedAffirmationLangSMSTCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangSMSTCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>(); 
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_SMST_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_SMST_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangPGE(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Postgraduate Training Credential'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_Postgraduate_Medical_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_PGE_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_PGE_CI'));
                }  
                returnVal.addAll(getRejectedAffirmationLangPGECog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangPGECog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();        
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_PGE_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_PGE_CI'));
        }             
        if(affr.Program_Duration_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Program_Duration_Acceptable_PGE_CI'));
        }  
        if(affr.Specialty_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_Program_is_Acceptable_PGE_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangMRC(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Medical Registration Certificate/License to Practice Medicine'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_MRC_Reg_MRC_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_MRC_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_MRC_CI'));
                }
                returnVal.addAll(getRejectedAffirmationLangMRCCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangMRCCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();   
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_MRC_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_MRC_CI'));
        }  
        if(affr.Specialty_Licensure_Type_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_Licensure_Type_is_Acc_MRC_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangSQ(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Specialist Qualification'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_SQ_Req_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{            
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_SQ_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_SQ_CI'));
                }
                returnVal.addAll(getRejectedAffirmationLangSQCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangSQCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();   
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_SQ_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_SQ_CI'));
        }  
        if(affr.Program_Duration_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Program_Duration_Acceptable_SQ_CI'));
        } 
        if(affr.Specialty_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_is_Acceptable_SQ_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangPIC(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Pregraduate Internship Certificate'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_PIC_Req_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_PIC_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_PIC_CI'));
                }
                returnVal.addAll(getRejectedAffirmationLangPICCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangPICCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();   
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_PIC_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_PIC_CI'));
        }  
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
    public static List<String> getRejectedAffirmationLangADMS(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Advanced Degree in the Medical Sciences'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_an_ADMS_Req_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_ADMS_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_ADMS_CI'));
                }  
                returnVal.addAll(getRejectedAffirmationLangADMSCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangADMSCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();          
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_ADMS_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_ADMS_CI'));
        } 
        if(affr.Degree_Program_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Degree_Program_is_Acceptable_ADMS_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangCGS(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Case__r.Document_type__c == 'Certificate of Good Standing'){
            if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_REQ_NEW){
                returnVal.add(defMap.get('Document_is_a_CGS_Req_CI'));
            }
            else if(affr.Change_Document_Type_Action__c == Constants.AFFIRMATION_DOC_ACTION_DOC_CHG){
                returnVal.add(affr.Rejection_Reason__c);
            }
            else{
                if(affr.Document_is_legible__c == 'No'){
                    returnVal.add(defMap.get('Document_is_legible_CGS_CI'));
                }
                if(affr.Document_is_not_missing_pages__c == 'No'){
                    returnVal.add(defMap.get('Document_is_not_missing_pages_CGS_CI'));
                }  
                returnVal.addAll(getRejectedAffirmationLangCGSCog(affr,defMap));     
            }
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangCGSCog(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();        
        if(affr.Document_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Document_is_not_cut_off_CGS_CI'));
        }
        if(affr.Original_Language_Document_Submitted__c == 'No'){
            returnVal.add(defMap.get('Original_Language_Document_Sub_CGS_CI'));
        }   
        if(affr.Specialty_Licensure_Type_is_Acceptable__c == 'No'){
            returnVal.add(defMap.get('Specialty_Licensure_Type_is_Acc_CGS_CI'));
        } 
        if(affr.Document_is_not_acceptable_for_the_Clien__c){
            returnVal.add(affr.Not_acceptable_for_Client_Reason__c);
        }
        if(affr.Reject_Credential__c == TRUE || affr.Applicant_Request__c == 'Yes'){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
    @AuraEnabled
    public static String getDocType(String caseId){
        Case credVerCase = [SELECT Document_Type__c FROM Case WHERE id =:caseId WITH SECURITY_ENFORCED];
        return credVerCase.Document_Type__c;
    }
    @AuraEnabled
    public static String getEvalStatus(String caseId){
        affirmation__c affr = [SELECT Id, Credential_Evaluation_Status__c, Translation_Evaluation_Status__c FROM Affirmation__c 
                              WHERE Case__c =:caseId WITH SECURITY_ENFORCED];
        if(affr.Credential_Evaluation_Status__c == Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE && 
           affr.Translation_Evaluation_Status__c == Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE){ 
            return 'credTransIncomplete'; 
        }else if(affr.Credential_Evaluation_Status__c == Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE){ 
            return 'credIncomplete'; 
        }else if(affr.Translation_Evaluation_Status__c == Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE){
            return 'transIncomplete';
        }
        return null;
    }
    // method to update existing credential status and New crential parent case
    @AuraEnabled
    public static Boolean updateCredentials(String inputJSON){
        CredUploadWrapper wrapper = (CredUploadWrapper)JSON.deserialize(inputJSON, CredUploadWrapper.class);
        List<String> assetUrls = new List<String>();
        assetUrls.add(wrapper.credUrl);
        assetUrls.add(wrapper.nameUrl);
        assetUrls.add(wrapper.transUrl);
        String parentUrl = '';
        List<Contact_Association_Type_Staging__c> cats = [SELECT Id, Credential_Type__c FROM Contact_Association_Type_Staging__c WHERE Case__c =:wrapper.caseId WITH SECURITY_ENFORCED];
        updateCredVerCase(wrapper.caseId, wrapper.proceedWithCredVer, wrapper.nameOnDoc);
        List<Asset> assetsToUpdate = new List<Asset>();
        List<Asset> assetList = new List<Asset>();
        List<Asset> parentAsset = new List<Asset>();
        if(String.isblank(wrapper.credUrl) && String.isNotBlank(wrapper.transUrl)){
            assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c NOT IN:assetUrls AND case__c =:wrapper.caseId AND Azure_Storage_URL__c !=null AND Status =:Constants.IN_PROGRESS AND Type__c =:Constants.ASSET_TYPE_TRANSLATION WITH SECURITY_ENFORCED];
            parentAsset = [SELECT Id, Azure_Storage_URL__c, Name FROM Asset WHERE case__c =:wrapper.caseId AND Azure_Storage_URL__c !=null AND Status =:Constants.IN_PROGRESS AND Type__c =:cats[0].Credential_Type__c WITH SECURITY_ENFORCED];
        }else if(String.isNotBlank(wrapper.credUrl)){
            assetList = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c NOT IN:assetUrls AND case__c =:wrapper.caseId AND Azure_Storage_URL__c !=null AND Status =:Constants.IN_PROGRESS WITH SECURITY_ENFORCED];
        }
        List<Asset> currentAssets = [SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Azure_Storage_URL__c IN:assetUrls AND Azure_Storage_URL__c != null WITH SECURITY_ENFORCED];
        for(Asset ast:currentAssets){
            ast.Uploaded_by_applicant__c = true;
            if(ast.Azure_Storage_URL__c == wrapper.credUrl){
                ast.Name_on_Document__c = wrapper.nameOnDoc;
                ast.Name_on_Document_is_Different__c = wrapper.nameDifferent;
                ast.Document_is_not_in_English__c = wrapper.translationRequired;
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = cats[0].Id;
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.transUrl){
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = cats[0].Id;
                if(!parentAsset.isEmpty()){
                    ast.Parent_Azure_Storage_URL__c	= parentAsset[0].Azure_Storage_URL__c;
                }
                assetsToUpdate.add(ast);
            }
            if(ast.Azure_Storage_URL__c == wrapper.nameUrl){
                ast.case__c = wrapper.caseId;
                ast.Contact_Association_Type_Staging__c = cats[0].Id;
                assetsToUpdate.add(ast);
            }
        }
        for(Asset asst : assetList){
            asst.Status = Constants.ASSET_STATUS_OUTDATED;
            assetsToUpdate.add(asst);
        }
        if(!assetsToUpdate.isEmpty() && Schema.sObjectType.Asset.isUpdateable()){
            Update assetsToUpdate;
        }
        return true;
    }
    // method to update credential verification case status after resubmission
    public static void updateCredVerCase(Id caseId, String proceedWithCredVer, String nameOnDoc){
        List<Case> credVerCaseList = [SELECT Id, OwnerId, CaseNumber FROM Case WHERE Id =:caseId WITH SECURITY_ENFORCED];
        List<Contact_Association_Type_Staging__c> cats = [SELECT Id FROM Contact_Association_Type_Staging__c WHERE Case__c =:caseId WITH SECURITY_ENFORCED];
        if(!credVerCaseList.isEmpty()){
            Case credVerCase = credVerCaseList[0];
            Id caseOwnerId = credVerCase.OwnerId;
            Group credRevQueue = [SELECT Id FROM Group WHERE Type =:Constants.GROUP_TYPE_QUEUE AND DeveloperName =:Constants.CASE_QUEUE_CREDENTIAL_REVIEW_QUEUE WITH SECURITY_ENFORCED];
            if(Schema.sObjectType.Case.isUpdateable()){
                credVerCase.Internal_Status__c = Constants.CASE_STATUS_RESUBMITTED_PENDING_REVIEW;
                credVerCase.OwnerId = credRevQueue.Id;
                credVerCase.Proceed_with_Credential_Verification__c = proceedWithCredVer;
                Update credVerCase;
            }
            if(!cats.isEmpty() && Schema.sObjectType.Contact_Association_Type_Staging__c.isUpdateable() && String.isNotBlank(nameOnDoc)){
                cats[0].Name_on_Document__c = nameOnDoc;
                Update cats[0];
            }
        }
    }
    public class CredUploadWrapper{
        @auraenabled public string credUrl {get; set;}
		@auraenabled public string transUrl {get; set;}
		@auraenabled public string nameUrl {get; set;}
        @auraenabled public string nameOnDoc {get; set;}
        @auraenabled public Boolean nameDifferent {get; set;}
        @auraenabled public Boolean translationRequired {get; set;}
        @auraenabled public string caseId {get; set;}
        @auraenabled public string  proceedWithCredVer {get; set;}
    }
    @AuraEnabled
    public static Boolean getDocNotAcceptableForClient(Id caseId){
        Affirmation__c affr = [SELECT id, Document_is_not_acceptable_for_the_Clien__c FROM Affirmation__c WHERE Case__c =:caseId WITH SECURITY_ENFORCED];
        return affr.Document_is_not_acceptable_for_the_Clien__c;
    }
    @AuraEnabled
    public static List<String> getPicklistValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Case.Proceed_with_Credential_Verification__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }

    @AuraEnabled(cacheable = false)
    public static List<CloudStorageController.PayloadWrapper> getIncompleteAssets(Id caseId){
        List<CloudStorageController.PayloadWrapper> payloadList = new List<CloudStorageController.PayloadWrapper>();
        List<Affirmation__c> affirmations = [SELECT Id, Status__c, Asset_Type__c, Translation_Evaluation_Status__c, Credential_Evaluation_Status__c, Case__r.Document_Type__c
                                                FROM Affirmation__c 
                                                WHERE Case__c =: caseId AND Case__r.Internal_Status__c =: Constants.CASE_STATUS_CV_INCOMPLETE 
                                                AND (Translation_Evaluation_Status__c =: Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE OR Credential_Evaluation_Status__c =: Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE)
                                                WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        if(!affirmations.isEmpty()){
            List<String> assetTypes = new List<String>();
            for(Affirmation__c affr:affirmations){          
                if(affr.Translation_Evaluation_Status__c == Constants.AFFIRMATION_TRANSL_EVAL_STATUS_INCOMPLETE){
                    assetTypes.add(Constants.ASSET_TYPE_TRANSLATION);
                }  
                if(affr.Credential_Evaluation_Status__c == Constants.AFFIRMATION_CRED_EVAL_STATUS_INCOMPLETE){
                    assetTypes.add(affr.Case__r.Document_Type__c);
                }
            }
            Set<String> assetTypesSet = new Set<String>();
            assetTypesSet.addAll(assetTypes);
            if(assetTypesSet.contains(Constants.CASE_DOCUMENT_TYPE_TCT)){
                assetTypesSet.add(Constants.ASSET_TYPE_TCT);
            }
            assetTypesSet.add(Constants.ASSET_TYPE_PRE_MED_LETTER);
            List<Asset> assetList =  [SELECT Id, Name, Type__c, RecordTypeId, CreatedDate, contactId, Status, Dean_s_Letter_Date__c,
                                        Contact_Association_Type_Staging__r.Attendance_End_Date__c,
                                        Contact_Association_Type_Staging__r.Attendance_Start_Date__c,
                                        Contact_Association_Type_Staging__r.Degree_Issue_Date__c,
                                        Contact_Association_Type_Staging__r.Degree_Title__c,
                                        Contact_Association_Type_Staging__r.Graduation_Year__c,
                                        Contact_Association_Type_Staging__r.Degree_expected_to_be_issued_Month__c,
                                        Contact_Association_Type_Staging__r.Degree_expected_to_be_issued_Year__c,
                                        Contact_Association_Type_Staging__r.Expiration_Date__c,
                                        Contact_Association_Type_Staging__r.Issue_Date__c,
                                        Contact_Association_Type_Staging__r.Program_End_Date__c,
                                        Contact_Association_Type_Staging__r.Program_Start_Date__c,
                                        Contact_Association_Type_Staging__r.Title__c,
                                        Contact_Association_Type_Staging__r.Start_Month__c,
                                        Contact_Association_Type_Staging__r.End_Month__c,
                                        Contact_Association_Type_Staging__r.Start_Year__c,
                                        Contact_Association_Type_Staging__r.End_Year__c 
                                    FROM Asset WHERE Case__c =:caseId
                                    AND Uploaded_by_applicant__c = true AND Type__c IN: assetTypesSet AND Status =: Constants.ASSET_STATUS_IN_PROGRESS
                                    WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
            if(assetList != null){
                Date latestCreatedDate = Date.newInstance((assetList[0].CreatedDate).year(), (assetList[0].CreatedDate).month(), (assetList[0].CreatedDate).day());
                List<Asset> assetRecs = new List<Asset>();
                for(Asset assetRec : assetList){
                    if(Date.newinstance((assetRec.CreatedDate).year(),(assetRec.CreatedDate).month(),(assetRec.CreatedDate).day()) == latestCreatedDate){
                        assetRecs.add(assetRec);
                    }
                }
                for(Asset assetRec : assetRecs){
                    payloadList.add(new CloudStorageController.PayloadWrapper(assetRec.contactId, assetRec.Type__c, assetRec.RecordTypeId, null, 
                    caseId, null, null, assetRec.Status, assetRec.Id, assetRec.Name, 
                    assetRec.Contact_Association_Type_Staging__r.Attendance_End_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Attendance_Start_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Degree_Issue_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Degree_Title__c,
                    assetRec.Contact_Association_Type_Staging__r.Graduation_Year__c,
                    assetRec.Contact_Association_Type_Staging__r.Degree_expected_to_be_issued_Month__c,
                    assetRec.Contact_Association_Type_Staging__r.Degree_expected_to_be_issued_Year__c,
                    assetRec.Contact_Association_Type_Staging__r.Expiration_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Issue_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Program_End_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Program_Start_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Title__c,
                    assetRec.Dean_s_Letter_Date__c,
                    assetRec.Contact_Association_Type_Staging__r.Start_Month__c,
                    assetRec.Contact_Association_Type_Staging__r.End_Month__c,
                    assetRec.Contact_Association_Type_Staging__r.Start_Year__c,
                    assetRec.Contact_Association_Type_Staging__r.End_Year__c
                    ));
                }
            }
        }
        return payloadList;
    }
}