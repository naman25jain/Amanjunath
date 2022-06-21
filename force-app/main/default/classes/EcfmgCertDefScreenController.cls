public with sharing class EcfmgCertDefScreenController{
    //method to check rejected ECFMG certification affirmations
    @AuraEnabled(cacheable = false)
	public static List<String> checkRejectedAffirmations(String caseId){
        Affirmation__c finalDiploma;
        Affirmation__c finalTranscript;
        Affirmation__c tct;
        List<Affirmation__c> affirmations = [SELECT id, Status__c, Asset_Type__c FROM Affirmation__c WHERE case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
        for(Affirmation__c affr:affirmations){
            if(finalDiploma == null && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA){
                finalDiploma = affr;
            }
            if(finalTranscript == null && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT){
                finalTranscript = affr;
            }
            if(tct == null && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_TCT){
                tct = affr;
            }
        }
        return checkRejectedAffirmationsRefr(finalDiploma, finalTranscript, tct);
    }
    public static List<String> checkRejectedAffirmationsRefr(Affirmation__c finalDiploma, Affirmation__c finalTranscript, Affirmation__c tct){
        List<String> rejectedAffirmations = new List<String>();
        if(tct != null && tct.status__c == Constants.AFFIRMATION_STATUS_REJECTED){
            rejectedAffirmations.add(Constants.AFFIRMATION_ASSET_TYPE_TCT);
        }
        if(finalDiploma != null && finalDiploma.status__c == Constants.AFFIRMATION_STATUS_REJECTED){
            rejectedAffirmations.add(Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA);
        }
        if(finalTranscript != null && finalTranscript.status__c == Constants.AFFIRMATION_STATUS_REJECTED){
            rejectedAffirmations.add(Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT);
        }
        return rejectedAffirmations;
    }
    //method to fetch ECFMG Certification case for the applicant
    @AuraEnabled(cacheable = false)
	public static String getECFMGCertCase(String contactId){
        List<Case> certcases = [SELECT id FROM Case where contactId =: contactId AND RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED];
        if(!certcases.isEmpty()){
            return certcases[0].Id;
        }
        return null;
    }
    //method to fetch details of Medical school with transfer credit
    @AuraEnabled(cacheable = false)
	public static AppForCertHelper.OtherSchoolObjWrapper getMedicalSchoolWithTc(String contactId){
        List<Contact_Association_Type__c> catRecords = [SELECT Id, Case__r.Internal_Status__c, Account__c, Number_of_Years_Attended__c, Account_Name__c, School_Program__c, Student_ID__c, Specialty__c, Start_Date__c, End_Date__c, Start_Month__c, Start_Year__c, End_Month__c, End_Year__c, Transfer_Credit_to_Degree_School__c FROM Contact_Association_Type__c where Contact__c =: contactId AND RecordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL AND Transfer_Credit_to_Degree_School__c = true WITH SECURITY_ENFORCED];
        if(!catRecords.isEmpty()){
            Contact_Association_Type__c catRecord = catRecords[0];
            string tempRecordIdVal = catRecord.Id;
            List<Transfer_Credit__c> transferCredits = [SELECT Id, Course_Outcome__c, Credits_Earned_Month__c, Credits_Earned_Year__c, Transfer_Credit_Course__c, Transfer_Credit_Grade__c, Contact_Association_Type__c FROM Transfer_Credit__c WHERE Contact_Association_Type__c =: tempRecordIdVal WITH SECURITY_ENFORCED];
			string tempOtherSchool = catRecord.Account_Name__c;
			String tempnumberOfYearsAttended;
			if(catRecord.Number_of_Years_Attended__c != null) {
				tempnumberOfYearsAttended = String.valueOf(catRecord.Number_of_Years_Attended__c);
			}else{
				tempnumberOfYearsAttended = '';
			}
			string tempOtherSchoolId = catRecord.Account__c;
			string tempSchoolProgram = catRecord.School_Program__c;
			string tempStudentId = catRecord.Student_ID__c;
			string tempSpecialty = catRecord.Specialty__c;
            string tempStartMonth = catRecord.Start_Month__c;
			string tempStartYear = catRecord.Start_Year__c;
			string tempEndMonth = catRecord.End_Month__c;
			string tempEndYear = catRecord.End_Year__c;
            String caseInternalStatus = catRecord.Case__r.Internal_Status__c;
            string tempTransferCreditsCheckbox = String.valueOf(catRecord.Transfer_Credit_to_Degree_School__c);
			List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
			tcObjList = getTcRecords(transferCredits, tempOtherSchoolId);
            AppForCertHelper.OtherSchoolObjWrapper tempJsObj;
            tempJsObj = new AppForCertHelper.OtherSchoolObjWrapper(tempRecordIdVal, tempOtherSchool, tempnumberOfYearsAttended, tempOtherSchoolId, tempSchoolProgram, tempStudentId, tempSpecialty, null, null, tempStartMonth, tempStartYear, tempEndMonth, tempEndYear, tempTransferCreditsCheckbox, tcObjList, null, 'Contact_Association_Type__c', caseInternalStatus);
			tempJsObj.numberOfYearsAttended = tempnumberOfYearsAttended;
			return tempJsObj;
        }
        return null;
    }
    //Method to get the list of tc records from Contact Assocaition Type - Other_MedSchool
    @AuraEnabled
	public static List<AppForCertHelper.TcObjWrapper> getTcRecords(List<Transfer_Credit__c> transferCredits, String tempOtherSchoolId){
		List<AppForCertHelper.TcObjWrapper> tcObjList = new List<AppForCertHelper.TcObjWrapper>();
		AppForCertHelper.TcObjWrapper tcTemp;
		for(Transfer_Credit__c tcIter : transferCredits){
            String tcId = tcIter.Id;
            String tcCourse = AppforcertController.tcCourseMethod(tcIter);
            String tcGrade = AppforCertController.tcGradeMethod(tcIter);
            String courseOutcome = tcIter.Course_Outcome__c == null ? '' : tcIter.Course_Outcome__c;
            String creditsEarnedMonth = tcIter.Credits_Earned_Month__c == null ? '' : tcIter.Credits_Earned_Month__c;
            String creditsEarnedYear = tcIter.Credits_Earned_Year__c == null ? '' : tcIter.Credits_Earned_Year__c;
            tcTemp = new AppForCertHelper.TcObjWrapper(String.valueOf(tcId), String.valueOf(tempOtherSchoolId), tcCourse, tcGrade, courseOutcome, creditsEarnedMonth, creditsEarnedYear);
            tcObjList.add(tcTemp);
        }
		return tcObjList;
	}
    //Method to mark diploma and transcript documents for deletion
    @AuraEnabled
	public static void markAssetsForDeletion(String contactId){
        List<String> assetTypeList = new List<String>();
        assetTypeList.add(Constants.ASSET_TYPE_TCT);
		assetTypeList.add(Constants.ASSET_TYPE_FINAL_MED_DIPLOMA);
		assetTypeList.add(Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT);
		List<Asset> assetList = new List<Asset>();
		if (Asset.SObjectType.getDescribe().isAccessible()){
			assetList = [SELECT id from Asset where Contact_Association_Type_Staging__c = null AND contactId =: contactId AND Contact_Association_Type__c = null AND status !=: constants.ASSET_STATUS_MARKED_FOR_DELETION AND (Type__c IN : assetTypeList OR Parent.Type__c IN : assetTypeList)];
		}
		List<RecordType> rts = new List<RecordType>();
		if(RecordType.SObjectType.getDescribe().isAccessible()){
			rts = [SELECT Id, Name from RecordType where DeveloperName =: Constants.ASSET_RECORD_TYPE_MARKED_FOR_DELETION AND SObjectType = 'Asset'];
		}
		if(rts.size() == 0){
			throw new CommunityException('Could not find record type named Marked for Deletion for Asset.');
		}
		RecordType assetMarkedForDeletionRT = rts[0];
		if(!assetList.isEmpty() && Asset.SObjectType.getDescribe().isUpdateable()){
			for(Asset asst : assetList){
				asst.case__c = null;
				asst.status = constants.ASSET_STATUS_MARKED_FOR_DELETION;
				asst.RecordTypeId = assetMarkedForDeletionRT.Id;
			}
			update assetList;
		}
    }
    //method to resubmit ecfmg certification case for review from deficiency screen
    @AuraEnabled
    public static boolean resubmitCredential(Id caseId, Id contactId, String medschoolJson){
        List<Asset> asstList = new List<Asset>();
        asstList = [SELECT id, Name, Parent.Name, Case__c FROM asset
                    where contactID =:contactId AND Case__c = null
                    AND status =: Constants.ASSET_STATUS_IN_PROGRESS
                    AND (Name =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR Name =: Constants.ASSET_TYPE_TCT OR
                        Name =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT OR
                        Parent.Name =: Constants.ASSET_TYPE_FINAL_MED_DIPLOMA OR 
                        Parent.Name =: Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT OR Parent.Name =: Constants.ASSET_TYPE_TCT) WITH SECURITY_ENFORCED];
        // code for inserting new med school and creating cat and tct assets correspondingly, also update the tct asset Contact_Association_Type__c field with  new cat record id.
        String recordTypeDeveloperName = Constants.CONASCTYPESTG_RECORD_TYPE_MEDICAL_SCHOOL;
        AppForCertHelper.OtherSchoolObjWrapper medSchObject= (AppForCertHelper.OtherSchoolObjWrapper) JSON.deserialize(medschoolJson, AppForCertHelper.OtherSchoolObjWrapper.class);
        if(String.isBlank(medSchObject.recordIdVal)  && String.isNotBlank(medSchObject.otherSchool)){
                Contact_Association_Type__c conAsso = new Contact_Association_Type__c();
                List<Transfer_Credit__c> tcNew =new list<Transfer_Credit__c>();
                conAsso = createCATrec(medSchObject,caseId,recordTypeDeveloperName);
                tcNew  = saveOtherMedicalSchoolsRefactorContTranCredMethod(medSchObject,conAsso, caseId);
        }
        List<Contact_Association_Type__c> cat = new List<Contact_Association_Type__c>([SELECT Id, Case__c, Parent_Case__c, recordTypeId, Transfer_Credit_to_Degree_School__c,Account__c,Credential_Type__c FROM Contact_Association_Type__c
                                    WHERE contact__c =: contactId AND
                                    (recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL OR
                                    (recordType.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_CREDENTIAL_INTAKE) OR
                                    (Transfer_Credit_to_Degree_School__c = true AND recordtype.DeveloperName =: Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL))]);
        Map<String,Id> catAcctMap = new Map<String,Id>();
        for (Contact_Association_Type__c catRec : cat) {
            if (catRec.Credential_Type__c == 'Transcript to Document Transfer Credits') {
                catAcctMap.put('TCT', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical Diploma'){
                catAcctMap.put('FinalDiploma', catRec.Account__c);
            }else if (catRec.Credential_Type__c == 'Final Medical School Transcript'){
               catAcctMap.put('FinalTranscript', catRec.Account__c);
            }
        }
        createVerificationCase(asstList, caseId, contactId,catAcctMap);
        updateCATidOfinalDip(cat,asstList);
        updateCATidOfTCT(cat,asstList);
        Case ecfCerCase  = [select id, Internal_Status__c from Case where id =: caseId WITH SECURITY_ENFORCED];
        ecfCerCase.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
        if(Schema.sObjectType.Case.isUpdateable()){
            update ecfCerCase;
        }
        return true;
    }
    public static void createVerificationCase(List<Asset> asstList, String caseId, String contactId, Map<String,Id> catAcctMap){
        Id qId = [select Id from Group where Type = 'Queue' and Name = 'Credential Review Queue' limit 1].Id;
        Id cvCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        List<Asset> tctAssets = new List<Asset>();
        List<Asset> diplomaAssets = new List<Asset>();
        List<Asset> transcriptAssets = new List<Asset>();
        for(Asset a : asstList){
            if(a.Name == Constants.ASSET_TYPE_TCT || a.Parent.Name == Constants.ASSET_TYPE_TCT){
                tctAssets.add(a);
            }
            if(a.Name == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT || a.Parent.Name == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT){
                transcriptAssets.add(a);
            }
            if(a.Name == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA || a.Parent.Name == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA){
                diplomaAssets.add(a);
            }
        }
        createCVCaseForDiploma(diplomaAssets, caseId, contactId, qId, cvCaseRecordTypeId,catAcctMap.get('FinalDiploma'));
        createCVCaseForTCT(tctAssets, caseId, contactId, qId, cvCaseRecordTypeId,catAcctMap.get('TCT'));
        createCVCaseForFinTrans(transcriptAssets, caseId, contactId, qId, cvCaseRecordTypeId,catAcctMap.get('FinalTranscript'));
    }
    public static void createCVCaseForDiploma(List<Asset> diplomaAssets, String caseId, String contactId, Id qId, Id cvCaseRecordTypeId, Id acctId){
        Case credCase;
        if(!diplomaAssets.isEmpty()){
            credCase = new Case(ParentId = caseId, ContactId = contactId, Internal_Status__c = 'Pending Credential Review', External_Status__c = 'Submitted; Pending Review at ECFMG', OwnerId = qId, RecordTypeId = cvCaseRecordTypeId);
            credCase.Document_Type__c = 'Final Medical Diploma';
            credCase.Document_type_selected_by_applicant__c = 'Final Medical Diploma';
            credCase.Entity__c = acctId;
            if(Schema.sObjectType.Case.isCreateable()){
                insert credCase;
                for(Asset a: diplomaAssets){
                    a.case__c = credCase.Id;
                }
                update diplomaAssets;
            }
        }
    }
    public static void createCVCaseForTCT(List<Asset> tctAssets, String caseId, String contactId, Id qId, Id cvCaseRecordTypeId,Id acctId){
        Case credCase;
        if(!tctAssets.isEmpty()){
            credCase = new Case(ParentId = caseId, ContactId = contactId, Internal_Status__c = 'Pending Credential Review', External_Status__c = 'Submitted; Pending Review at ECFMG', OwnerId = qId, RecordTypeId = cvCaseRecordTypeId);
            credCase.Document_Type__c = 'Transcript to Document Transfer Credits';
            credCase.Document_type_selected_by_applicant__c = 'Transcript to Document Transfer Credits';
            credCase.Entity__c = acctId;
            if(Schema.sObjectType.Case.isCreateable()){
                insert credCase;
                for(Asset a: tctAssets){
                    a.case__c = credCase.Id;
                }
                update tctAssets;
            }
        }
    }
    public static void createCVCaseForFinTrans(List<Asset> transcriptAssets, String caseId, String contactId, Id qId, Id cvCaseRecordTypeId,Id acctId){
        Case credCase;
        if(!transcriptAssets.isEmpty()){
            credCase = new Case(ParentId = caseId, ContactId = contactId, Internal_Status__c = 'Pending Credential Review', External_Status__c = 'Submitted; Pending Review at ECFMG', OwnerId = qId, RecordTypeId = cvCaseRecordTypeId);
            credCase.Document_Type__c = 'Final Medical School Transcript';
            credCase.Document_type_selected_by_applicant__c = 'Final Medical School Transcript';
            credCase.Entity__c = acctId;
            if(Schema.sObjectType.Case.isCreateable()){
                insert credCase;
                for(Asset a: transcriptAssets){
                    a.case__c = credCase.Id;
                }
                update transcriptAssets;
            }
        }
    }
    public static List<Asset> updateCATidOfinalDip(List<Contact_Association_Type__c> cat,List<Asset> asstList){
        Id degMedRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        List<Asset> updasstList1 = new List<Asset>();
        for(Contact_Association_Type__c c : cat){
            if(c.recordTypeId == degMedRecTypeId){
                for(Asset a : asstList){
                    if(a.Name == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA || a.Name == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT || a.Parent.Name == Constants.ASSET_TYPE_FINAL_MED_DIPLOMA || a.Parent.Name == Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT){
                        a.Contact_Association_type__c = c.id;
                        updasstList1.add(a);
                    }
                }
            }
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset>(); // map to avoid duplicate ids in list
        for(Asset ast : updasstList1){
            assetMap.put(ast.Id, ast);
        }
        update assetMap.values();
        return assetMap.values();
    }
    public static List<Asset> updateCATidOfTCT(List<Contact_Association_Type__c> cat,List<Asset> asstList){
        Id medSchRecTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        List<Asset> updasstList1 = new List<Asset>();
        List<Contact_Association_Type__c> catToUpdate = new List<Contact_Association_Type__c>();
        for(Contact_Association_Type__c c : cat){
            if(c.Transfer_Credit_to_Degree_School__c == true && c.recordTypeId == medSchRecTypeId){
                for(Asset a:asstList){
                    if(a.Name == Constants.ASSET_TYPE_TCT || a.Parent.Name == Constants.ASSET_TYPE_TCT){
                        a.Contact_Association_type__c = c.id;
                        updasstList1.add(a);
                        if (c.Case__c == c.Parent_Case__c) {
                            c.Case__c = a.case__c;
                            catToUpdate.add(c);
                        }
                    }
                }
            }
        }
        Map<Id, Asset> assetMap = new Map<Id, Asset>(); // map to avoid duplicate ids in list
        for(Asset ast : updasstList1){
            assetMap.put(ast.Id, ast);
        }
        if (catToUpdate.size()>0 && Schema.sObjectType.Contact_Association_Type__c.isUpdateable()) {
            Update catToUpdate;
        }
        update assetMap.values();
        return assetMap.values();
    }
    public static Contact_Association_Type__c createCATrec(AppForCertHelper.OtherSchoolObjWrapper wrap, String caseId, String recordTypeDeveloperName){
		Id medSchlRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		Contact_Association_Type__c catNew = new Contact_Association_Type__c();
		catNew.Contact__c = AppForCertHelper.retrieveCurrentContactId();
		catNew.Account__c = wrap.otherSchoolId;
		catNew.recordTypeId = medSchlRecordTypeId;
		catNew.School_Program__c = wrap.schoolProgram;
		if(!String.isBlank(wrap.fromDate)){
			catNew.Start_Date__c = Date.valueOf(wrap.fromDate);
		} 
        else{
			catNew.Start_Date__c = null;
		}
		if(!String.isBlank(wrap.endDate)){
			catNew.End_Date__c = Date.valueOf(wrap.endDate);
		} 
        else{
			catNew.End_Date__c = null;
		}
		catNew.Start_Month__c = wrap.startMonth;
		catNew.Start_Year__c = wrap.startYear;
		catNew.End_Month__c = wrap.endMonth;
		catNew.End_Year__c = wrap.endYear;
		catNew.Specialty__c = wrap.Specialty;
		if(!String.isBlank(wrap.numberOfYearsAttended)){
			catNew.Number_of_Years_Attended__c = Decimal.valueOf(wrap.numberOfYearsAttended);
		} 
        else{
			catNew.Number_of_Years_Attended__c = null;
		}
		catNew.Student_ID__c = wrap.studentId;
		catNew.Transfer_Credit_to_Degree_School__c = Boolean.valueOf(wrap.transferCreditsCheckbox);
		catNew.Case__c = caseId;
        catNew.Credential_Type__c = 'Transcript to Document Transfer Credits';
        Case cse = [SELECT Id,ParentId FROM Case WHERE Id=: caseId WITH SECURITY_ENFORCED][0];
        catNew.Parent_Case__c = cse.ParentId != null ? cse.ParentId : caseId;
        if(Schema.sObjectType.Contact_Association_Type__c.isCreateable()){
		    Insert catNew;
        }
		return catNew;
	}
    public static List<Transfer_Credit__c> saveOtherMedicalSchoolsRefactorContTranCredMethod(AppForCertHelper.OtherSchoolObjWrapper wrap, Contact_Association_Type__c catNew, string caseId){
		List<Transfer_Credit__c> tcList = new List<Transfer_Credit__c>();
		Id currentUser = AppForCertHelper.retrieveCurrentContactId();
		if(Boolean.valueOf(wrap.transferCreditsCheckbox) && wrap.tcWrapperList != null && wrap.tcWrapperList.size()>0){
			for(AppForCertHelper.TcObjWrapper childTc: wrap.tcWrapperList){
				Transfer_Credit__c tc = new Transfer_Credit__c();
				if(String.isNotBlank(childTc.recordIdVal)){
					tc.Id = childTc.recordIdVal;
				}
				tc.Applicant__c = currentUser;
				tc.Contact_Association_Type__c = catNew.Id;
				tc.From_School__c = childTc.fromSchool;
				tc.Transfer_Credit_Course__c = childTc.transferCreditCourse;
				tc.Transfer_Credit_Grade__c = childTc.transferCreditGrade;
				tc.Course_Outcome__c = childTc.courseOutcome;
				tc.Credits_Earned_Month__c = childTc.creditsEarnedMonth != 'undefined' ? childTc.creditsEarnedMonth : '';
				tc.Credits_Earned_Year__c = childTc.creditsEarnedYear != 'undefined' ? childTc.creditsEarnedYear : '';
				tc.Case__c = caseId;
				tcList.add(tc);
			}
            tcList = createTCList(tcList);
		}
		return tcList;
    }
    public static List<Transfer_Credit__c> createTCList(List<Transfer_Credit__c> tcList){
        if(Schema.sObjectType.Transfer_Credit__c.isCreateable()){
            insert tcList;
        }
        return tcList;
    }
    //method to get rejected ECFMG certification affirmations Languages
    @AuraEnabled(cacheable = false)
    public static List<String> getRejectedAffirmationLang(String caseId, String affrmType){
        List<String> returnVal = new List<String>();
        Map<String,String> defMap = new Map<String,String>();
        List<Deficiency_Language__mdt> defList = [SELECT Id,DeveloperName,Deficiency_Reason__c,Label,MasterLabel FROM Deficiency_Language__mdt WITH SECURITY_ENFORCED];        
        for(Deficiency_Language__mdt def : defList){
            defMap.put(def.DeveloperName, def.Deficiency_Reason__c);
        }
        List<Affirmation__c> affirmations = [SELECT id,Status__c,Asset_Type__c,TCT_Required__c,Document_is_legible__c,
            Document_is_not_missing_pages__c,Document_is_not_cut_off__c,Original_Language_Document_Submitted__c,Document_is_a_TCT__c,
            Transcript_lists_all_required_courses__c,Transcript_lists_correct_dates_of_attend__c,All_courses_were_passed_at_med_school__c,
            Medical_school_acceptable__c,Credits_transferred_from_one_med_school__c,Document_is_a_Final_Medical_School_Trans__c,
            Transcript_Format_Acceptable__c,Degree_Title_Acceptable__c,Graduation_Year_Acceptable_for_ECFMG__c,Curriculum_Length_Acceptable__c,
            Document_is_a_Final_Medical_Diploma__c,Diploma_Format_Acceptable__c,Translation_Required__c,Translation_is_legible__c,
            Translation_is_not_missing_pages__c,Translation_is_not_cut_off__c,Translator_is_acceptable__c,Translation_is_of_original_document__c,
            Translation_is_word_for_word__c,English_Certification_Statement_accept__c,Translation_is_signed_by_the_Translator__c,
            Translation_is_on_the_letterhead__c,Reject_Credential__c,Credential_Rejection_Reason__c,Reject_Translation__c,Rejection_Reason__c 
            FROM Affirmation__c WHERE case__c =: caseId WITH SECURITY_ENFORCED ORDER BY createdDate Desc];
        for(Affirmation__c affr : affirmations){
            if(affrmType == 'FD' && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_DIPLOMA){
                returnVal.addAll(getRejectedAffirmationLangFD(affr,defMap));               
                returnVal.addAll(getRejectedAffirmationLangTran(affr,defMap));
            }
            if(affrmType == 'FT' && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_FINAL_TRANSCRIPT){                
                returnVal.addAll(getRejectedAffirmationLangFT(affr,defMap)); 
                returnVal.addAll(getRejectedAffirmationLangTran(affr,defMap));                                              
            }
            if(affrmType == 'TCT' && affr.Asset_Type__c == Constants.AFFIRMATION_ASSET_TYPE_TCT){                                
                returnVal.addAll(getRejectedAffirmationLangTCT(affr,defMap));  
                returnVal.addAll(getRejectedAffirmationLangTran(affr,defMap));               
            }                                         
        }
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFD(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
            if(affr.Document_is_legible__c == 'No'){
                returnVal.add(defMap.get('Document_is_legible'));
            }
            if(affr.Document_is_not_missing_pages__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_missing_pages'));
            }
            if(affr.Document_is_not_cut_off__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_cut_off'));
            }
            if(affr.Original_Language_Document_Submitted__c == 'No'){
                returnVal.add(defMap.get('Original_Language_Document_Submitted'));
            }
            if(affr.Document_is_a_Final_Medical_Diploma__c == 'No'){
                returnVal.add(defMap.get('Document_is_a_Final_Medical_Diploma'));
            }
            if(affr.Diploma_Format_Acceptable__c == 'No'){
                returnVal.add(defMap.get('Diploma_Format_Acceptable'));
            }
            if(affr.Degree_Title_Acceptable__c == 'No'){
                returnVal.add(defMap.get('Degree_Title_Acceptable'));
            }
            if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
                returnVal.add(defMap.get('Graduation_Year_Acceptable_for_ECFMG_Cer'));
            }
            if(affr.Reject_Credential__c){
                returnVal.add(affr.Credential_Rejection_Reason__c);
            }        
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangFT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
            if(affr.Document_is_legible__c == 'No'){
                returnVal.add(defMap.get('Document_is_legible_FT'));
            }
            if(affr.Document_is_not_missing_pages__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_missing_pages_FT'));
            }
            if(affr.Document_is_not_cut_off__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_cut_off_FT'));
            }
            if(affr.Original_Language_Document_Submitted__c == 'No'){
                returnVal.add(defMap.get('Original_Language_Document_Submitted_FT'));
            }
            if(affr.Document_is_a_Final_Medical_School_Trans__c == 'No'){
                returnVal.add(defMap.get('Document_is_a_Final_Medical_School_Trans'));
            }
            if(affr.Transcript_Format_Acceptable__c == 'No'){
                returnVal.add(defMap.get('Transcript_Format_Acceptable'));
            }
            if(affr.Degree_Title_Acceptable__c == 'No'){
                returnVal.add(defMap.get('Degree_Title_Acceptable_FT'));
            }
            if(affr.Graduation_Year_Acceptable_for_ECFMG__c == 'No'){
                returnVal.add(defMap.get('Graduation_Year_Acceptable_for_ECFMG_FT'));
            }
            if(affr.Curriculum_Length_Acceptable__c == 'No'){
                returnVal.add(defMap.get('Curriculum_Length_Acceptable'));
            }
            if(affr.Reject_Credential__c){
                returnVal.add(affr.Credential_Rejection_Reason__c);
            }        
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangTCT(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();         
            if(affr.TCT_Required__c == 'TCT required, not provided'){
                returnVal.add(defMap.get('TCT_required_not_provided'));
            }
            if(affr.Document_is_legible__c == 'No'){
                returnVal.add(defMap.get('Document_is_legible_TCT'));
            }
            if(affr.Document_is_not_missing_pages__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_missing_pages_TCT'));
            }
            if(affr.Document_is_not_cut_off__c == 'No'){
                returnVal.add(defMap.get('Document_is_not_cut_off_TCT'));
            }
            if(affr.Original_Language_Document_Submitted__c == 'No'){
                returnVal.add(defMap.get('Original_Language_Document_Submitted_TCT'));
            }
            if(affr.Document_is_a_TCT__c == 'No'){
                returnVal.add(defMap.get('Document_is_a_TCT'));
            }
            if(affr.Transcript_lists_all_required_courses__c == 'No'){
                returnVal.add(defMap.get('Transcript_lists_all_required_courses'));
            }
            if(affr.Transcript_lists_correct_dates_of_attend__c == 'No'){
                returnVal.add(defMap.get('Transcript_lists_correct_dates_of_attend'));
            }
            if(affr.All_courses_were_passed_at_med_school__c == 'No'){
                returnVal.add(defMap.get('All_courses_were_passed_at_medical_sch'));
            }
            if(affr.Medical_school_acceptable__c == 'No'){
                returnVal.add(defMap.get('Medical_school_acceptable'));
            }
            if(affr.Credits_transferred_from_one_med_school__c == 'No'){
                returnVal.add(defMap.get('Credits_transferred_only_from_one_med'));
            }  
            if(affr.Reject_Credential__c){
                returnVal.add(affr.Credential_Rejection_Reason__c);
            }        
        return returnVal;
    }
    public static List<String> getRejectedAffirmationLangTran(Affirmation__c affr, Map<String,String> defMap){
        List<String> returnVal = new List<String>();
        if(affr.Translation_Required__c == 'Translation required, not provided'){
            returnVal.add(defMap.get('Translation_required_not_provided'));
        }
        if(affr.Translation_is_legible__c == 'No'){
            returnVal.add(defMap.get('Translation_is_legible'));
        }
        if(affr.Translation_is_not_missing_pages__c == 'No'){
            returnVal.add(defMap.get('Translation_is_not_missing_pages'));
        }
        if(affr.Translation_is_not_cut_off__c == 'No'){
            returnVal.add(defMap.get('Translation_is_not_cut_off'));
        }
        if(affr.Translator_is_acceptable__c == 'No'){
            returnVal.add(defMap.get('Translator_is_acceptable'));
        }
        if(affr.Translation_is_of_original_document__c == 'No'){
            returnVal.add(defMap.get('Translation_is_of_original_document'));
        }
        if(affr.Translation_is_word_for_word__c == 'No'){
            returnVal.add(defMap.get('Translation_is_word_for_word'));
        }
        if(affr.English_Certification_Statement_accept__c == 'No'){
            returnVal.add(defMap.get('English_Certification_Statement_is_accep'));
        }
        if(affr.Translation_is_signed_by_the_Translator__c == 'No'){
            returnVal.add(defMap.get('Translation_is_signed_by_the_Translator'));
        }
        if(affr.Translation_is_on_the_letterhead__c == 'No'){
            returnVal.add(defMap.get('Translation_is_on_the_letterhead'));
        }
        if(affr.Reject_Translation__c){
            returnVal.add(affr.Rejection_Reason__c);
        }
        return returnVal;
    }
}