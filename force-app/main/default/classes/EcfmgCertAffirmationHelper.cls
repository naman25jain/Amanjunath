//helper class for ECFMG Certificate affirmation flow
public with sharing class EcfmgCertAffirmationHelper{
    @InvocableMethod
	public static void handleAffirmationCompleted(List<Id> caseIds){
        Case certCase = [SELECT id, Internal_Status__c, contactId FROM Case where Id =: caseIds[0]][0];
        if(certCase.Internal_Status__c == Constants.CASE_STATUS_FINAL_QA_COMPLETE){
            handleAffirmationAccepted(certCase);
        }
        else if(certCase.Internal_Status__c == Constants.CASE_STATUS_INCOMPLETE){
            handleAffirmationRejected(certCase);
        }
    }
    //The method to execute actions on acceptance of ECFMG Certificate case 
    public static void handleAffirmationAccepted(Case ecfmgCertCase){
        Exam_Registration__c step1Exam;
        Exam_Registration__c step2CKExam;
        Exam_Registration__c step2CSExam;
        Contact applicant = new Contact();
        applicant.Id = ecfmgCertCase.contactId;
        applicant.Certificate_Issue_Date__c = System.today();
        ecfmgCertCase.Certificate_Issue_Date__c = System.today();
        List<Exam_Registration__c> examRegsToUpdate = new List<Exam_Registration__c>();
        List<Exam_Registration__c> examList = [SELECT Id, Applicant__c, Exam_Types__c FROM Exam_Registration__c WHERE Applicant__c =: ecfmgCertCase.ContactId AND Voided__c = false AND Exam_Status__c =:Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED WITH SECURITY_ENFORCED ORDER BY Exam_taken_date__c ASC];
        for(Exam_Registration__c exam: examList){
            if(exam.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE && step1Exam == null){
                exam.Applicant_Certified_On__c = true;
                step1Exam = exam;
            }
            if(exam.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK && step2CKExam == null){
                exam.Applicant_Certified_On__c = true;
                step2CKExam = exam;
            }
            if(exam.Exam_Types__c == Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCS && step2CSExam == null){
                exam.Applicant_Certified_On__c = true;
                step2CSExam = exam;
            }
        }
        examRegsToUpdate.add(step1Exam);
        examRegsToUpdate.add(step2CKExam);
        if(step2CSExam != null){
            examRegsToUpdate.add(step2CSExam); 
        }
        if(Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Exam_Registration__c.isUpdateable() && Schema.sObjectType.Contact.isUpdateable()){
            update examRegsToUpdate;
            update applicant;
            update ecfmgCertCase;
        }
    }    
    //The method to execute actions on rejection of ECFMG Certificate case 
    public static void handleAffirmationRejected(Case ecfmgCertCase){
        SET<ID> affirmationIdsSet = new SET<ID>();
        for(Affirmation__c affirmReccord : [SELECT Id, Name, Status__c, ECFMG_Cert_Affirmation_Rejection__c 
                                            FROM Affirmation__c 
                                            WHERE Status__c =: Constants.AFFIRMATION_STATUS_REJECTED 
                                            AND Case__c =: ecfmgCertCase.Id WITH SECURITY_ENFORCED]){
            affirmationIdsSet.add(affirmReccord.Id);
        }
        if(!affirmationIdsSet.isEmpty()){  
            // Passing rejected Affirmation Ids - User Story 12919, 12920 and 12921         
            affirmationReviewRejection(affirmationIdsSet);  
            // Check Rejected Affirmation with formula field has ‘No’
            List<Affirmation__c> affirLists = [SELECT Id, Name, Status__c, ECFMG_Cert_Affirmation_Rejection__c 
                                                FROM Affirmation__c 
                                                WHERE Status__c =: Constants.AFFIRMATION_STATUS_REJECTED 
                                                AND ECFMG_Cert_Affirmation_Rejection__c =: Constants.STATUS_NO
                                                AND Id IN: affirmationIdsSet WITH SECURITY_ENFORCED];
            if(!affirLists.isEmpty()){
                Case caseObj = new Case();
                caseObj.Id = ecfmgCertCase.Id;
                caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_APPLICANT_ACTION_RESUBMIT_DOCUMENTS;
                caseObj.External_Status__c = Constants.CASE_STATUS_PENDING_APPLICANT_ACTION_RESUBMIT_DOCUMENTS;
                caseObj.Action_Required__c = true;
                update caseObj;
            }
        }
    }
    //Update accepted assets as Incomplete
    public static void updateAssetStatus(string contactId, List<string> assetType){
        List<Asset> updateList = new List<Asset>();
        Id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        List<Asset> assetList = [select id,status from Asset where Contactid = :contactId AND status = :Constants.ASSET_STATUS_ACCEPTED AND Type__c IN :assetType AND (Type__c != :Constants.ASSET_TYPE_TCT OR Contact_Association_Type__r.RecordTypeId = :catRecTypeId) WITH SECURITY_ENFORCED];
        Set<Id> assetIds = new Map<Id,SObject>(assetList).keySet();
        List<Asset> transAssetList = [select id,status from Asset where Contactid = :contactId AND status = :Constants.ASSET_STATUS_ACCEPTED AND Type__c = :Constants.ASSET_TYPE_TRANSLATION AND parentId IN :assetIds WITH SECURITY_ENFORCED];
        if(!transAssetList.isEmpty()){
            assetList.addAll(transAssetList);
        }
        For(Asset asst: assetList){
            asst.status = Constants.ASSET_STATUS_INCOMPLETE;
            updateList.add(asst);
        }
        if(!updateList.isEmpty() && Schema.sObjectType.Asset.isUpdateable() && Schema.sObjectType.Asset.fields.status.isUpdateable()){
            Update updateList;
        }
    }
    // Reopen Credential Verification case
    public static void reopenCredVerCase(string contactId, string caseId, List<String> verifiedAssetTypeList, List<String> verFormAssetTypeList, List<String> verFormParentTypeList, Set<Id> verFormParentAssetIds){
        List<String> docTypeList = new List<String>();
        List<String> cvCaseIdList = new List<String>();
        List<Case> credVerCaseList = new List<Case>();
        id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        if(verifiedAssetTypeList.contains(Constants.ASSET_TYPE_VERIFIED_FINAL_DIPLOMA)){
            docTypeList.add(Constants.CASE_DOC_TYPE_FINAL_MED_DIPLOMA);
        }
        if(verifiedAssetTypeList.contains(Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL)){
            docTypeList.add(Constants.CASE_DOC_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT);
        }
        if(verifiedAssetTypeList.contains(Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT)){
            docTypeList.add(Constants.CASE_DOCUMENT_TYPE_TCT);
        }
        for(Case cse:[SELECT Id, Internal_Status__c, Secondary_Parent_Case__c, Document_Type__c FROM Case WHERE ContactId = :contactId AND RecordTypeId = :caseRecTypeId AND Document_Type__c IN :docTypeList WITH SECURITY_ENFORCED]){
            cvCaseIdList.add(cse.Id);
            credVerCaseList.add(cse);
        }  
        List<Asset> assetList = [select id,status from Asset where Name LIKE 'Verified%' AND Case__c IN :cvCaseIdList WITH SECURITY_ENFORCED];
        List<Asset> verFormAssetList = [select id,status from Asset where Name LIKE '%Verification Form%' AND ContactId = :contactId AND (Case__c IN :cvCaseIdList OR parentId IN :verFormParentAssetIds) WITH SECURITY_ENFORCED];
        if(!verFormAssetList.isEmpty()){
            assetList.addAll(verFormAssetList);
        }
        if(!credVerCaseList.isEmpty() && Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.fields.Internal_Status__c.isUpdateable()){
            for(Case cvCase :credVerCaseList){
                cvCase.Internal_Status__c = Constants.CASE_STATUS_COMPILE_PACKET;
                cvCase.Secondary_Parent_Case__c = caseId;
            }
            Update credVerCaseList;
        }
        for(Asset asst : assetList){
            asst.status = Constants.ASSET_STATUS_INCOMPLETE;
        }
        if(!assetList.isEmpty() && Schema.sObjectType.Asset.isUpdateable() && Schema.sObjectType.Asset.fields.status.isUpdateable()){
            Update assetList;
        }
    }
    // Create Name Review Case when Name Document Affirmations Rejected
    public static void createNameReviewCase(string contactId, string caseId, List<Asset> assetList, List<Asset> translAssetList, List<Asset> nameDocAssetList){
        Map<Id,Asset> translAssetMap = new Map<Id,Asset>();
        Map<Id,Asset> nameDocAssetMap = new Map<Id,Asset>();
        List<Asset> assetListUpdate = new List<Asset>();
        list<Case> newCaseList = new list<Case>();
        Integer i = 0;
        for(Asset asst : translAssetList){
            translAssetMap.put(asst.parentId,asst);
        }
        for(Asset asst : nameDocAssetList){
            nameDocAssetMap.put(asst.parentId,asst);
        }
        newCaseList = createCases(contactId, caseId, assetList);
        for(Asset asst : assetList){
            asst.name_review_case__c = newCaseList[i].id;
            assetListUpdate.add(asst);
            Asset transAsset = translAssetMap.get(asst.Id);
            if(transAsset != null){
                transAsset.name_review_case__c = newCaseList[i].id;
                assetListUpdate.add(transAsset);
            }
            Asset nameDocAsset = nameDocAssetMap.get(asst.Id);
            if(nameDocAsset != null){
                nameDocAsset.name_review_case__c = newCaseList[i].id;
                assetListUpdate.add(nameDocAsset);
            }
            i++;
        }
        if(Schema.sObjectType.Asset.isUpdateable() && Schema.sObjectType.Asset.fields.name_review_case__c.isUpdateable()){
            update assetListUpdate;
        }
    }
    // Name review case creation
    public static list<Case> createCases(string contactId, string caseId, List<Asset> assetList){
        id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_NAME_REVIEW).getRecordTypeId();
        Group biogReviewQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_BIOGRAPHIC_REVIEW);
        list<Case> newCaseList = new list<Case>();
        for(Asset ass : assetList){
            Case newCase = new Case(Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW, ParentId = caseId, OwnerId = biogReviewQueue.id, RecordTypeId= caseRecTypeId, ContactId = contactId);
            newCaseList.add(newCase);
        }      
        if(Schema.sObjectType.Case.isCreateable() && !newCaseList.isEmpty()){
            insert newCaseList;
        }
        return newCaseList;
    }
     //US 20407,20408,20409 - Create new DOB Review subcase
    public static void createDOBReviewCase(EcfmgCertAffirmationHelper.SubcaseCreationWrapper wrp){
        Map<Id,Asset> translAssetMap = new Map<Id,Asset>();
        Map<Id,Asset> nameDocAssetMap = new Map<Id,Asset>();
        List<Asset> assetListUpdate = new List<Asset>();
        List<Case> newCaseList = new list<Case>();
        Integer i = 0;
        for(Asset asst : wrp.transassetList){
            translAssetMap.put(asst.parentId,asst);
        }
        for(Asset asst : wrp.nameDocassetList){
            nameDocAssetMap.put(asst.parentId,asst);
        }
        newCaseList = createDOBCases(wrp.contactId, wrp.caseId, wrp.assetList);
        for(Asset asst : wrp.assetList){
            asst.DOB_Review_Case__c = newCaseList[i].id;
            assetListUpdate.add(asst);
            Asset transAsset = translAssetMap.get(asst.Id);
            if(transAsset != null){
                transAsset.DOB_Review_Case__c = newCaseList[i].id;
                assetListUpdate.add(transAsset);
            }
            Asset nameDocAsset = nameDocAssetMap.get(asst.Id);
            if(nameDocAsset != null){
                nameDocAsset.DOB_Review_Case__c = newCaseList[i].id;
                assetListUpdate.add(nameDocAsset);
            }
            Asset dobDocAsset = wrp.dobDocasset;
            if(dobDocAsset != null && dobDocAsset.DOB_Review_Case__c == null){
                dobDocAsset.DOB_Review_Case__c = newCaseList[i].Id;
                assetListUpdate.add(dobDocAsset);
            }
            i++;
        }
        if(Schema.sObjectType.Asset.isUpdateable() && Schema.sObjectType.Asset.fields.DOB_Review_Case__c.isUpdateable()){
            UPDATE assetListUpdate;
        }
    }
    // DOB review case creation
    public static list<Case> createDOBCases(String contactId, String caseId, List<Asset> assetList){
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_BIOGRAPHIC_REVIEW).getRecordTypeId();
        Group biogReviewQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_BIOGRAPHIC_REVIEW);
        List<Case> newCaseList = new List<Case>();
        for(Asset ass : assetList){
            Case newCase = new Case(Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW, ParentId = caseId, OwnerId = biogReviewQueue.id, RecordTypeId = caseRecTypeId, ContactId = contactId, Case_Type__c = Constants.CASE_TYPE_DOB_REVIEW);
            newCaseList.add(newCase);
        }      
        if(Schema.sObjectType.Case.isCreateable() && !newCaseList.isEmpty()){
            INSERT newCaseList;
        }
        return newCaseList;
    }
    // Check if "Translation required, not provided" was selected, or if any Translation affirmations are No or if "Reject Translation" selected 
    public static boolean checkTranslationRejected(Affirmation__c affr){
        if(affr.Translation_is_complete_and_legible__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Translation_is_of_original_document__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO ||
           affr.Translation_is_word_for_word__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.English_Certification_Statement_accept__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Translation_is_signed_by_the_Translator__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO ||
           affr.Translation_is_on_the_letterhead__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Translator_is_acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO  || affr.Translation_Required__c == Constants.AFFIRMATION_TRANSLATION_REQUIRED_NOT_PROVIDED || affr.Reject_Translation__c == true){
            return True;
        }
        return false;
    }
    //check if any Final Diploma affirmations are No or if "Reject Credential" was selected
    public static boolean checkFinalDiplomaAffirmationRejected(Affirmation__c affr){
        if(affr.Document_is_a_Final_Medical_Diploma__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Diploma_Format_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Document_is_complete_and_legible__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Original_Language_Document_Submitted__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO ||
           affr.Degree_Title_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Graduation_Year_Acceptable_for_ECFMG__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Reject_Credential__c == true){
            return True;
        }
        return false;
    }
    // Check if any Final Transcript affirmations are No or "Reject Credential" was selected
    public static boolean checkFinalTranscriptAffirmationRejected(Affirmation__c affr){
        if(affr.Document_is_complete_and_legible__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Original_Language_Document_Submitted__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Document_is_a_Final_Medical_School_Trans__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Transcript_Format_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO ||
           affr.Degree_Title_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Graduation_Year_Acceptable_for_ECFMG__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Curriculum_Length_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Reject_Credential__c == true){
            return True;
        }
        return false;
    }
    // Check if any TCT affirmations are No or "Reject Credential" was selected or if "TCT required; not provided" 
    public static boolean checkTCTAffirmationRejected(Affirmation__c affr){
        if((affr.Document_is_complete_and_legible__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Original_Language_Document_Submitted__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Document_is_a_TCT__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Transcript_lists_all_required_courses__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO ||
           affr.Transcript_lists_correct_dates_of_attend__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.All_courses_were_passed_at_med_school__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Medical_school_acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO || affr.Credits_transferred_from_one_med_school__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO
            || affr.Reject_Credential__c == true || affr.TCT_Required__c == Constants.AFFIRMATION_TCT_REQUIRED_NOT_PROVIDED) && affr.Transfer_Credit_Exception_Granted__c == false){
            return TRUE;
        }
        return false;
    }
    // Get asset types to be updated according to affirmation asset types
    public static List<String> getAssetTypes(Affirmation__c affr){
        String assetType1;
        String assetType2;
        String assetType3;
        List<String> assetTypeList = new List<String>();
        if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA){
            assetType1 = Constants.ASSET_TYPE_FINAL_DIPLOMA_VERIFICATION_FORM;
            assetType2 = Constants.ASSET_TYPE_VERIFIED_FINAL_DIPLOMA;
            assetType3 = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        }else if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT){
            assetType1 = Constants.ASSET_TYPE_FINAL_TRANSCRIPT_VERIFICATION_FORM;
            assetType2 = Constants.ASSET_TYPE_VERIFIED_FINAL_TRANSCRIPT_CREDENTIAL;
            assetType3 = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT;
        }else if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_TCT){
            assetType1 = Constants.ASSET_TYPE_TRANSFER_CREDIT_TRANSCRIPT_VERIFICATION_FORM;
            assetType2 = Constants.ASSET_TYPE_VERIFIED_TRANSFER_CREDIT_TRANSCRIPT;
            assetType3 = Constants.ASSET_TYPE_TCT;
        }
        assetTypeList.add(assetType1);
        assetTypeList.add(assetType2);
        assetTypeList.add(assetType3);
        return assetTypeList;
    }
    // Check affirmation rejections according to affirmation asset types
    public static boolean checkAffirmationRejected(Affirmation__c affr){
        Boolean affrRejected;
        if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA){
            affrRejected = checkFinalDiplomaAffirmationRejected(affr);
        }else if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT){
            affrRejected = checkFinalTranscriptAffirmationRejected(affr);
        }else if(affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_TCT){
            affrRejected = checkTCTAffirmationRejected(affr);
        }
        return affrRejected;       
    }
    // Check name doc rejection 
    public static boolean checkNameReviewRejection(Affirmation__c affr){
        if(affr.Name_on_Document__c == Constants.AFFIRMATION_NAME_DOC_REQUIRES_REVIEW || affr.Name_on_Document__c == Constants.AFFIRMATION_NAME_DOC_NOT_RECEIVED){
            return true;
        }
        return false;
    }
    //US 20407/20408/20409 - Check DOB rejection
    public static Boolean checkDOBReviewRejected(Affirmation__c affr){
        if(affr.Date_Of_Birth__c == Constants.AFFIRMATION_DOB_PRESENT_NOT_MATCH_NO_DOC){
            return true;
        }
        return false;
    }
    // Method to be executed for Rejected affirmations of all asset types
    public static void affirmationReviewRejection(Set<Id> affirmationIds){
        Boolean translAffrRejected;
        Boolean affrRejected;
        String assetType1;
        String assetType2;
        String assetType3;
        boolean nameReviewRejection;
        Boolean dobReviewRejection;
        List<String> assetTypeList = new List<String>();
        List<String> updateAssetTypeList = new List<String>();
        List<String> verifiedAssetTypeList = new List<String>();
        List<String> verFormAssetTypeList = new List<String>();
        List<String> verFormParentTypeList = new List<String>();
        List<String> nameReviewAssetType = new List<String>();
        List<String> dobReviewAssetType = new List<String>();
        id catRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        List<Affirmation__c> affrList = [SELECT Id, Case__c, Case__r.ContactId, Asset_Type__c, Name_on_Document__c, Date_Of_Birth__c, Translator_is_acceptable__c, Translation_is_complete_and_legible__c, Translation_is_of_original_document__c, Translation_is_word_for_word__c, English_Certification_Statement_accept__c,
                                        Translation_is_signed_by_the_Translator__c, Translation_is_on_the_letterhead__c, Translation_Required__c, Reject_Translation__c, Document_is_a_Final_Medical_Diploma__c, Diploma_Format_Acceptable__c,
                                        Document_is_complete_and_legible__c, Original_Language_Document_Submitted__c, Degree_Title_Acceptable__c, Graduation_Year_Acceptable_for_ECFMG__c, Verification_Form_Acceptable__c, Reject_Credential__c,
                                        Document_is_a_Final_Medical_School_Trans__c, Transcript_Format_Acceptable__c, Curriculum_Length_Acceptable__c, Document_is_a_TCT__c, Transcript_lists_all_required_courses__c,
                                        Transcript_lists_correct_dates_of_attend__c, All_courses_were_passed_at_med_school__c, Medical_school_acceptable__c, Credits_transferred_from_one_med_school__c, Transfer_Credit_Exception_Granted__c, TCT_Required__c
                                        FROM Affirmation__c WHERE Id IN : affirmationIds WITH SECURITY_ENFORCED];
        for(Affirmation__c affr : affrList){
            translAffrRejected = checkTranslationRejected(affr);
            affrRejected = checkAffirmationRejected(affr);
            assetTypeList = getAssetTypes(affr);
            nameReviewRejection = checkNameReviewRejection(affr);
            dobReviewRejection =  checkDOBReviewRejected(affr);
            assetType1 = assetTypeList[0];
            assetType2 = assetTypeList[1];
            assetType3 = assetTypeList[2];
            if(affrRejected || translAffrRejected){
                updateAssetTypeList.add(assetType3);
            }
            if(affr.Verification_Form_Acceptable__c == Constants.AFFIRMATION_PICKLIST_VALUE_NO && !affrRejected){
                verFormAssetTypeList.add(assetType1);
                verifiedAssetTypeList.add(assetType2);
                verFormParentTypeList.add(assetType3);
            }
            if(nameReviewRejection){
                nameReviewAssetType.add(assetType3);
            }
            if(dobReviewRejection){
                dobReviewAssetType.add(assetType3);
            }
        }
        List<Asset> assetListNameReview = [SELECT Id, Name_Review_Case__c FROM Asset WHERE Type__c IN : nameReviewAssetType AND ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND (Type__c !=: Constants.ASSET_TYPE_TCT OR Contact_Association_Type__r.RecordTypeId =: catRecTypeId) WITH SECURITY_ENFORCED];
        List<Asset> assetListDobReview = [SELECT Id, DOB_Review_Case__c FROM Asset WHERE  Type__c IN : dobReviewAssetType AND ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND (Type__c !=: Constants.ASSET_TYPE_TCT OR Contact_Association_Type__r.RecordTypeId =: catRecTypeId) WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
        Set<Id> assetIdsNameReview = new Map<Id,SObject>(assetListNameReview).keySet();
        Set<Id> assetIdsDobReview = new Map<Id, SObject>(assetListDobReview).keySet();
        List<Asset> translAssetList = [SELECT Id, Name_Review_Case__c, ParentId FROM Asset WHERE ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Type__c =: Constants.ASSET_TYPE_TRANSLATION AND parentId IN : assetIdsNameReview WITH SECURITY_ENFORCED];
        List<Asset> nameDocAssetList = [SELECT Id, Name_Review_Case__c, ParentId FROM Asset WHERE ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Type__c =: Constants.ASSET_TYPE_NAME_DOC AND ParentId IN : assetIdsNameReview WITH SECURITY_ENFORCED];
        List<Asset> verFormParentAssets = [SELECT Id FROM Asset WHERE Type__c IN : verFormParentTypeList AND Status =: Constants.ASSET_STATUS_ACCEPTED AND ContactId =: affrList[0].Case__r.ContactId AND (Type__c !=: Constants.ASSET_TYPE_TCT OR Contact_Association_Type__r.RecordTypeId =: catRecTypeId) WITH SECURITY_ENFORCED];
        Set<Id> verFormParentAssetIds = new Map<Id,SObject>(verFormParentAssets).keySet();
        List<Asset> transDobAssets = [SELECT Id, DOB_Review_Case__c, ParentId FROM Asset WHERE ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Type__c =: Constants.ASSET_TYPE_TRANSLATION AND ParentId IN : assetIdsDobReview WITH SECURITY_ENFORCED];
        List<Asset> nameDocDobAssets = [SELECT Id, DOB_Review_Case__c, ParentId FROM Asset WHERE ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Type__c =: Constants.ASSET_TYPE_NAME_DOC AND ParentId IN : assetIdsDobReview WITH SECURITY_ENFORCED];
        List<Asset> dobDocAsset = [SELECT Id, DOB_Review_Case__c, ParentId FROM Asset WHERE ContactId =: affrList[0].Case__r.ContactId AND Status =: Constants.ASSET_STATUS_ACCEPTED AND Type__c =: Constants.ASSET_TYPE_DOB_DOCUMENT WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        SubcaseCreationWrapper dobReviewWrap = new SubcaseCreationWrapper();
        dobReviewWrap.contactId = affrList[0].Case__r.ContactId;
        dobReviewWrap.caseId = affrList[0].Case__c;
        dobReviewWrap.assetList = assetListDobReview;
        dobReviewWrap.transassetList = transDobAssets;
        dobReviewWrap.nameDocassetList = nameDocDobAssets;
        if(!dobDocAsset.isEmpty()){
            dobReviewWrap.dobDocasset = dobDocAsset[0];
        }
        AssetListsWrapper asstListWrp = new AssetListsWrapper();
        asstListWrp.contactId = affrList[0].case__r.contactId;
        asstListWrp.caseId = affrList[0].case__c;
        asstListWrp.updateAssetlist = updateAssetTypeList;
        asstListWrp.verifiedAsstTypelist = verifiedAssetTypeList;
        asstListWrp.verFormAsstTypelist = verFormAssetTypeList;
        asstListWrp.verFormParTypelist = verFormParentTypeList;
        asstListWrp.verFormParAsstIds = verFormParentAssetIds;
        asstListWrp.assetlistNameRev = assetListNameReview;
        asstListWrp.transAsstlist = translAssetList;
        asstListWrp.nameDocAsstlist = nameDocAssetList;
        asstListWrp.nameRevAsstType = nameReviewAssetType;
        checkRefactorAssetUpdates(asstListWrp);
        if(!dobReviewAssetType.isEmpty()){
            createDOBReviewCase(dobReviewWrap);
        }      
    }
    public static void checkRefactorAssetUpdates(EcfmgCertAffirmationHelper.AssetListsWrapper asstListWrp){
        if(!asstListWrp.updateAssetlist.isEmpty()){
            updateAssetStatus(asstListWrp.contactId, asstListWrp.updateAssetlist);
        }
        if(!asstListWrp.verifiedAsstTypelist.isEmpty()){
            reopenCredVerCase(asstListWrp.contactId, asstListWrp.caseId, asstListWrp.verifiedAsstTypelist, asstListWrp.verFormAsstTypelist, asstListWrp.verFormParTypelist, asstListWrp.verFormParAsstIds);
        }
        if(!asstListWrp.nameRevAsstType.isEmpty()){
            createNameReviewCase(asstListWrp.contactId, asstListWrp.caseId, asstListWrp.assetlistNameRev, asstListWrp.transAsstlist, asstListWrp.nameDocAsstlist);
        }  
    } 
    public class AssetListsWrapper{
        public String contactId {get; set;}
        public String caseId {get; set;}
        public List<String> updateAssetlist {get; set;}
        public List<String> verifiedAsstTypelist {get; set;}
        public List<String> verFormAsstTypelist {get; set;}
        public List<String> verFormParTypelist {get; set;}
        public Set<Id> verFormParAsstIds {get; set;}
        public List<Asset> assetlistNameRev {get; set;}
        public List<Asset> transAsstlist {get; set;}
        public List<Asset> nameDocAsstlist {get; set;}
        public List<String> nameRevAsstType {get; set;}
    }
    public class SubcaseCreationWrapper{
        public String contactId { get; set; }
        public String caseId { get; set; }
        public List<Asset> assetList { get; set; }
        public List<Asset> transassetList { get; set; }
        public List<Asset> nameDocassetList { get; set; }
        public Asset dobDocasset { get; set; }
    } 
}