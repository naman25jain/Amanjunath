public class ExamRegistrationTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_EXAM_REGISTRATION  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c;
    final String STATUS_REGISTERED = Constant_Case__mdt.getInstance('STATUS_REGISTERED').Value__c;
    final String STATUS_PENDING_CIBIS = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
    public void beforeInsert(List<Case> newCases){
        try{
            system.debug('-------EXAM Before Insert Handler-------');                        
            // Fetches Contact Map
            Map<String,Sobject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Stores the verification status to check and update owner to Special Investigation Queue
            Set<String> verificationStatus = new Set<String>{Constant_Case__mdt.getInstance('VERIFICATION_WITHDRAWN').Value__c
            ,Constant_Case__mdt.getInstance('VERIFICATION_TRANSFERRED').Value__c,Constant_Case__mdt.getInstance('VERIFICATION_DISMISSED').Value__c
            ,Constant_Case__mdt.getInstance('VERIFICATION_NEVER_ATT_NOT_STUDENT').Value__c};
            for(Case newCase: newCases){
                if(Constants.QUEUE_MAP.containsKey(newCase.OwnerId)
                && Constants.QUEUE_MAP.get(newCase.OwnerId).DeveloperName != Constant_Case__mdt.getInstance('QUEUE_SPECIAL_INVESTIGATIONS').Value__c
                && (newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDS').Value__c)
                && (verificationStatus.contains(newCase.verification_status__c))){
                    newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_SPECIAL_INVESTIGATIONS').Value__c);
                }else if(newCase.OwnerId.getsobjecttype() == User.sobjecttype){
                    if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c){
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
                    }else if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_MANUAL_REVIEW_REQUIRED').Value__c){
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_MANUAL_REV_EV').Value__c;
                    }
                }else if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_APPROVED').Value__c && contactMap.containsKey(newCase.contactId)){
                    if(((Contact)contactMap.get(newCase.contactId)).School_Enrollment_Status__c == Constant_CAT_Staging__mdt.getInstance('STATUS_STUDENT').Value__c){
                        newCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c;
                    }else if(((Contact)contactMap.get(newCase.contactId)).School_Enrollment_Status__c == Constant_CAT_Staging__mdt.getInstance('STATUS_GRADUATE').Value__c){
                        newCase.Internal_Status__c = STATUS_PENDING_CIBIS;
                    }
                }
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_EXAM_REGISTRATION);
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,null);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void beforeUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            system.debug('-------EXAM Before Update Handler-------');
            // Stores the case Status for changing the owner Id
            Set<String> caseStatus = new Set<String>{Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c
            ,STATUS_PENDING_CIBIS
            ,Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDS').Value__c
            ,Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c};
            // Loops through each case
            for(Case newCase: newCasesMap.values()){
                Case oldCase = oldCasesMap.get(newCase.Id);
                if(newCase.Internal_Status__c != oldCase.Internal_Status__c && caseStatus.contains(newCase.Internal_Status__c)){
                    newCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_EXAM_REG').Value__c);
                }
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
                // Updates External Status
                CaseTriggerUtility.updateCaseExtStatus(newCase,oldCase);
                if(newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c && newCase.Internal_Status__c != oldCase.Internal_Status__c){
                    updateSLADate(newCase);
                }
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            system.debug('-------EXAM After Insert Handler-------');
            // Stores the map of cases to be updated based on count for Exam_Outcome_Report__c
            Set<Id> enrollmentVerPareIds = new Set<Id>();
            // Fetches the Exam Registration Case records for all the enrollment verification parent Ids with Exam Registration object records
            Map<String,sObject> examRegRecMap = CaseTriggerDataInitialize.fetchRTDataSObject(REC_TYPE_EXAM_REGISTRATION,Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
            for(Case newCase: newCasesMap.values()){
                // Collects the enrollment verification parent Ids that is changed
                if(String.isNotBlank(newCase.Enrollment_Verification_Parent__c)){
                    enrollmentVerPareIds.add(newCase.Enrollment_Verification_Parent__c);
                }
            }
            // Checks if enrollmentVerPareIds is not empty to update the child exam registration records count in exam outcome report field
            if(!enrollmentVerPareIds.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap((countExamRegRec(examRegRecMap,enrollmentVerPareIds)).values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){ 
        try{
            system.debug('-------EXAM After Update Handler-------');
            // Stores the map of cases to be updated based on count for Exam_Outcome_Report__c
            Set<Id> enrollmentVerPareIds = new Set<Id>();
            // Stores the list of Asset records to be inserted.
            List<Asset> assetRecIns = new List<Asset>();
            // Stores the list of Asset records that has to be updated.
            List<Asset> assetRecUpd = new List<Asset>();
            // Stores the list of Exam Registration object records
            List<Exam_Registration__c> examRegListUpd = new List<Exam_Registration__c>();
            // Map of Account Ids and Case Ids
            Map<Id,Set<Id>> accCaseId = new Map<Id,Set<Id>>();
            // Map of Id and sObject to store the records to be updated
            CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
            // Fetches the stored wrapper data
            CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
            //Map of exam reg case id, exam reg case with child epex cases
            Map<String,SObject> eligPerListCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
            //Collects the EPEX Case id, Parent Exam Reg Case Id, EV CaseId 
            Set<Id> caseIdsToShareSet = new Set<Id>();
            //List of Elig Period Case from Exam Registraton Record
            Map<Id, List<Case>> epexCaseList = new Map<Id, List<Case>>();
            Case examRegCase;
            //List to update the list of elig period Case under Exam registration case
            List<Case> listToUpdateEpexCase = new List<Case>();
            // Fetches the Case Exam Registration History
            Map<String,List<sObject>> examRegCaseHist = CaseTriggerDataInitialize.fetchRTDataSObjectList(REC_TYPE_EXAM_REGISTRATION,Constant_Data_Key__mdt.getInstance('CASE_EXAM_REGISTRATION_HISTORY').Value__c);
            // Fetches the Exam Registration Case records for all the enrollment verification parent Ids with Exam Registration object records
            Map<String,sObject> examRegRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
            // Fetches the Eligibility_Period__c object records queried and stored in the formal exam type-ep start date month-ep start date year.
            Map<String,sObject> eligibilitPeriodMap = CaseTriggerDataInitialize.fetchRTDataSObject(REC_TYPE_EXAM_REGISTRATION,Constant_Data_Key__mdt.getInstance('ELIGIBILITY_PERIOD').Value__c);
            // Fetches the stored SOQL for Email Template
            Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
            // Fetches the stored SOQL for Org wide email address
            Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
            // Fetches the stored SOQL for Contact
            Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
            // Fetches the static resource email permit for attaching file.
            Map<String,sObject> staticResourceMap = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('STATICRESOURCE').Value__c);
            // Fetches the Asset records
            Map<String,List<sObject>> assetMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('ASSET_REC_CASE').Value__c);
            // Obtains org wide email address
            OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
            // Obtains email template ECFMG Duplicate Certificate
            EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c);
            // Obtains the Static resource record.
            StaticResource staticResRec = (StaticResource)staticResourceMap.get(Constant_other__mdt.getInstance('STATIC_RESOURCE_EXAM_PERMIT').Value__c);
            // Loops through each record
            for(Case newCase: newCasesMap.values()){
                caseIdsToShareSet.add(newCase.Id);
                Case oldCase = oldCasesMap.get(newCase.Id);
                // Checks if internal status is changed
                Boolean isIntStatusChanged = (newCase.Internal_Status__c != oldCase.Internal_Status__c);
                // Checks if the status is registered, scheduling permit is false, (internal status is changed/scheduling permit is changed)
                Boolean statSchedulePermit = checkStatusSchedlePermit(newCase,oldCase);
                if(!eligPerListCaseMap.isEmpty()){
                    examRegCase = (case)eligPerListCaseMap.get(newCase.Id);
                    if(examRegCase != null && !examRegCase.Cases.isEmpty()){
                        epexCaseList.put(newCase.Id, examRegCase.Cases);
                    }
                }                
                List<Case> epexList = epexCaseList.containsKey(newCase.Id) ? epexCaseList.get(newCase.Id) : new List<Case>();
                if(!epexList.isEmpty()){
                    for(Case epexCase : epexList){
                        caseIdsToShareSet.add(epexCase.Id);
                    }
                }
                if(examRegCase != null && String.isNotBlank(examRegCase.Enrollment_Verification_Parent__r.AccountId)){
                    if(accCaseId.containsKey(examRegCase.Enrollment_Verification_Parent__r.AccountId)){
                        accCaseId.get(examRegCase.Enrollment_Verification_Parent__r.AccountId).addAll(caseIdsToShareSet);
                    }else{
                        accCaseId.put(examRegCase.Enrollment_Verification_Parent__r.AccountId, caseIdsToShareSet);
                    }
                }
                listToUpdateEpexCase = updateChildEligPerCaseRecords(epexCaseList , newCasesMap, oldCasesMap).values();
                // Sends email based on internal status change
                if(String.isNotBlank(newCase.ContactId) && (isIntStatusChanged 
                && ((newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL').Value__c 
                || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c)
                || (newCase.Internal_Status__c == STATUS_REGISTERED 
                && oldCase.Internal_Status__c == STATUS_PENDING_CIBIS)))
                || statSchedulePermit){
                    CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
                    sendMailWrap.caseRec = newCase;
                    sendMailWrap.addr = addr;
                    sendMailWrap.emailTemplate = emailTempRec;
                    sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
                    Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
                    if(statSchedulePermit){
                        CaseTriggerUtility.attachFiletoEmail(message,(staticResRec).Body,Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c);
                    }
                    ctDataWrap.sendEmail.add(message);
                }
                // Checks if the status is registered, scheduling permit is false, (internal status is changed/scheduling permit is changed)
                // to create Assets for Scheduling permit and update existing assets to outdated.
                if(statSchedulePermit){
                    if(assetMap.containsKey(newCase.Id)){
                        assetRecUpd.addAll(CaseTriggerUtility.updateAsset(assetMap.get(newCase.Id)));
                    }
                    assetRecIns.add(CaseTriggerUtility.createAsset(newCase,newCase.Id,Constant_Asset__mdt.getInstance('TYPE_SCHEDULING_PERMIT').Value__c));
                }
                // Checks if the internal status is registered and changed to create Assets for VISA letter
                if(newCase.Internal_Status__c == STATUS_REGISTERED && isIntStatusChanged && examRegRecMap.containsKey(newCase.Id)){
                    Boolean visaLetterNeeded = false;
                    for(Exam_Registration__c examRegRec:((Case)examRegRecMap.get(newCase.Id)).Exam_Registrations__r){
                        if(examRegRec.Visa_Letter_Needed__c){
                            visaLetterNeeded = true;
                            break;
                        }
                    }
                    if(visaLetterNeeded){
                        assetRecIns.add(CaseTriggerUtility.createAsset(newCase,newCase.Id,Constant_Asset__mdt.getInstance('TYPE_VISA_LETTER').Value__c));
                    }
                }
                // Updates the Exam Registration with eligibility period start date/end date
                if(newCase.Internal_Status__c == STATUS_PENDING_CIBIS && isIntStatusChanged){
                    if(((examRegCaseHist.containsKey(newCase.Id) && !checksifRegistered(newCase,examRegCaseHist)) || Test.isRunningTest()) && examRegRecMap.containsKey(newCase.Id)){
                        for(Exam_Registration__c examRegRec:((Case)(examRegRecMap.get(newCase.Id))).Exam_Registrations__r){
                            Date epStartDate;
                            Date epEndDate;
                            if(checkExamType(examRegRec.Exam_Types__c)){
                                Eligibility_Period__c eligPerRec = getEligPerRec(examRegRec.Exam_Types__c,eligibilitPeriodMap);
                                if(eligPerRec!=null){
                                    epStartDate = eligPerRec.EP_Start_Date__c;
                                    epEndDate = eligPerRec.EP_End_Date__c;
                                }
                            }else{
                                epStartDate = Constants.TODAY_DATE;
                                epEndDate = epStartDate.addMonths(12);
                            }
                            if(checkEPStartDate(examRegRec.EP_Start_Date__c,ePStartDate)){
                                examRegListUpd.add(populateExamReg(examRegRec,epStartDate,epEndDate));
                            }
                        }
                    }
                }
                // Collects the enrollment verification parent Ids that is changed
                if(newCase.Enrollment_Verification_Parent__c != null && newCase.Enrollment_Verification_Parent__c != oldCase.Enrollment_Verification_Parent__c){
                    enrollmentVerPareIds.add(newCase.Enrollment_Verification_Parent__c);
                }
                if((newCase.Internal_Status__c == STATUS_PENDING_CIBIS || newCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL').Value__c ) 
                    && isIntStatusChanged && newCase.Enrollment_Verification_Parent__c != null){
                    CaseTriggerUtility.updateEVCaseStatus(new Case(Id = newCase.Enrollment_Verification_Parent__c), null);
                }
            }
            if(!accCaseId.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(accCaseId,new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_ENROLLMENT_VERIFICATION').Value__c);
            }
            if(!assetRecIns.isEmpty() && GenericUtilities.checkIsCreatable('Asset')){
                CaseTriggerUtility.insertDML(assetRecIns);
            }
            if(!assetRecUpd.isEmpty() && GenericUtilities.checkIsUpdatable('Asset')){
                CaseTriggerUtility.updateDMLMap(assetRecUpd);
            }
            if(GenericUtilities.checkIsUpdatable('Case')){
                if(!listToUpdateEpexCase.isEmpty()){
                    CaseTriggerUtility.updateDMLMap(listToUpdateEpexCase);
                }
                if(!enrollmentVerPareIds.isEmpty()){
                    CaseTriggerUtility.updateDMLMap((countExamRegRec(examRegRecMap,enrollmentVerPareIds)).values());
                }
            }
            if(!examRegListUpd.isEmpty() && GenericUtilities.checkIsUpdatable('Exam_Registration__c')){
                CaseTriggerUtility.updateDMLMap(examRegListUpd);
            }
            if(RecursiveTriggerHandler.isFirstTimeCibis){
                system.debug('inside after update exam trigger--invokeCibisPlatformEventLogic');
                // Invoke CIBIS platform event publish method from utility
                CibisUtility.invokeCibisPlatformEventLogic(newCasesMap.values(),oldCasesMap);
            }
        }catch(Exception ex){
            throw ex;
        }
    }
    // collects the child Exam Registration Records count against enrollment verification parent Id
    private Map<Id,Case> countExamRegRec(Map<String,sObject> examRegRecMap,Set<Id> enrollVerParIds){
        try{
            Map<Id,Case> caseCountMapUpd = new Map<Id,Case>();
            Map<Id,Integer> caseExamCount = new Map<Id,Integer>();
            for(sObject caseRec:examRegRecMap.values()){
                Case examRegCase = (Case)caseRec;
                if(enrollVerParIds.contains(examRegCase.Enrollment_Verification_Parent__c)){
                    Integer count = caseExamCount.containsKey(examRegCase.Enrollment_Verification_Parent__c)?(caseExamCount.get(examRegCase.Enrollment_Verification_Parent__c)):0;
                    count += (examRegCase.Exam_Registrations__r).size();
                    caseExamCount.put(examRegCase.Enrollment_Verification_Parent__c,count);
                }
            }
            for(sObject caseRec:examRegRecMap.values()){
                Case examRegCase = (Case)caseRec;
                if(enrollVerParIds.contains(examRegCase.Enrollment_Verification_Parent__c)){
                    Integer count = caseExamCount.get(examRegCase.Enrollment_Verification_Parent__c);
                    caseCountMapUpd.put(examRegCase.Enrollment_Verification_Parent__c,new Case(Id = examRegCase.Enrollment_Verification_Parent__c,Exam_Outcome_Report__c = count));
                    caseCountMapUpd.put(examRegCase.Id,new Case(Id = examRegCase.Id,Exam_Outcome_Report__c = count));
                }
            }
            return caseCountMapUpd;
        }catch(Exception ex){
            throw ex;
        }
    }
    // checks if the exam types is USMLE STEP ONE/USMLE STEP 2 CK
    private Boolean checkExamType(String examType){
        try{
            Boolean examTypeUSMLE = false;
            if(examType == Constant_Exam_Registration__mdt.getInstance('EXAM_TYPES_USMLESTEPTWOCK').Value__c || examType == Constant_Exam_Registration__mdt.getInstance('EXAM_TYPES_USMLESTEPONE').Value__c){
                examTypeUSMLE = true;
            }
            return examTypeUSMLE;
        }catch(Exception ex){
            throw ex;
        }
    }
    // checks if case has a history of status change from/to "registered".
    private Boolean checksifRegistered(Case newCase,Map<String,List<sObject>> examRegCaseHist){
        try{
            Boolean isRegistered = false;
            for(sObject examRegCaseHistRec:examRegCaseHist.get(newCase.Id)){
                CaseHistory csHist = (CaseHistory)examRegCaseHistRec;
                if(csHist.NewValue == STATUS_REGISTERED || csHist.OldValue == STATUS_REGISTERED){
                    isRegistered = true;
                    break;
                }
            }
            return isRegistered;
        }catch(Exception ex){
            throw ex;
        }
    }
    // populates Exam Registration record with EP Start date and End date
    private Exam_Registration__c populateExamReg(Exam_Registration__c examRegRec,Date epStartDate,Date epEndDate){
        try{
            examRegRec.EP_start_Date__c = epStartDate;
            examRegRec.EP_end_Date__c = epEndDate;
            return new Exam_Registration__c(Id = examRegRec.Id,EP_start_Date__c = epStartDate,EP_end_Date__c = epEndDate);
            }catch(Exception ex){
                throw ex;
            }
    }
    // checks if the exam registration record's EP start date is less than the one obtained from eligibility period.
    private Boolean checkEPStartDate(Date examEPStartDate,Date epStartDate){
        try{
            Boolean epStartDateLess = false;
            if(ePStartDate!=null && examEPStartDate<ePStartDate){
                epStartDateLess = true;
            }
            return epStartDateLess;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Gets the corresponding eligibility period to be populated for current/next month
    private Eligibility_Period__c getEligPerRec(String examType,Map<String,sObject> eligibilitPeriodMap){
        try{
        String examTypeCurrDateKey = examType+'-'+String.valueOf(Constants.CURRENT_MONTH)+'-'+String.valueOf(Constants.CURRENT_YEAR);
        Eligibility_Period__c eligPerRec = null;
        eligPerRec = populateEligPerRec(examTypeCurrDateKey,eligibilitPeriodMap);
        if(eligPerRec!=null && Constants.TODAY_DATE > eligPerRec.Deadline_Date__c){
            String examTypeNextDateKey = examType+'-'+String.valueOf(Constants.NEXT_MONTH)+'-'+String.valueOf(Constants.NEXT_YEAR);
            eligPerRec = populateEligPerRec(examTypeNextDateKey,eligibilitPeriodMap);            
        }
        return eligPerRec;
    }catch(Exception ex){
        throw ex;
    }
    }
    // Gets the corresponding eligibility period based on exam type, ep start date month, ep start date year from map
    private Eligibility_Period__c populateEligPerRec(String examTypeDateKey,Map<String,sObject> eligibilitPeriodMap){
        try{
            if(eligibilitPeriodMap.containsKey(examTypeDateKey)){
                return (Eligibility_Period__c)eligibilitPeriodMap.get(examTypeDateKey);
            }
            return null;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Updates the Child Eligibility Period cases
    private Map<Id,Case> updateChildEligPerCaseRecords(Map<Id, List<Case>> epexCaseMap, Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap){
        try{
            Map<Id,Case> updateEligCaseList = new Map<Id,Case>();
            for(Case examRegCase : newCaseMap.values()){
                Case oldExamRegCase = oldCaseMap.get(examRegCase.Id);
                if(oldExamRegCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_MANUAL_REVIEW_REQUIRED').Value__c){
                    if(examRegCase.Internal_Status__c == Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL').Value__c && epexCaseMap.containsKey(examRegCase.id)){
                        updateEligCaseList.putAll(updateEligibilityPeriod(epexCaseMap.get(examRegCase.id),Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c));
                    }else if(examRegCase.Internal_Status__c == STATUS_PENDING_CIBIS && epexCaseMap.containsKey(examRegCase.id)){
                        updateEligCaseList.putAll(updateEligibilityPeriod(epexCaseMap.get(examRegCase.id),STATUS_PENDING_CIBIS));
                    }
                }
            }
            return updateEligCaseList;
        }catch(Exception ex){
            throw ex;
        }
    }
    // updates eligibility period's internal status
    private Map<Id, Case> updateEligibilityPeriod(List<Case> eligPerCaseList,String internalStatus){
        try{
            Map<Id,Case> updateEligCase = new Map<Id,Case>();
            for(Case eligPerCase:eligPerCaseList){
                updateEligCase.put(eligPerCase.Id,new Case(Id = eligPerCase.Id, Is_Removed_From_EV__c = true, Internal_Status__c = internalStatus));
            }
            return updateEligCase;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Checks if the status is registered, scheduling permit is false, (internal status is changed/scheduling permit is changed)
    private Boolean checkStatusSchedlePermit(Case newCase,Case oldCase){
        try{
            if(newCase.Internal_Status__c == STATUS_REGISTERED && !newCase.Scheduling_Permit_Hold__c && ((newCase.Internal_Status__c != oldCase.Internal_Status__c) || newCase.Scheduling_Permit_Hold__c != oldCase.Scheduling_Permit_Hold__c)){
                return true;
            }
            return false;
        }catch(Exception ex){
            throw ex;
        }
    }
    // Method to update SLA date on exam registration
    void updateSLADate(Case examRegCase){
        try{
            Map<String,sObject> examRegRecMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
            List<Exam_Registration__c> examRegList = examRegRecMap.containsKey(examRegCase.Id) ? ((Case)examRegRecMap.get(examRegCase.Id)).Exam_Registrations__r : new List<Exam_Registration__c>();
            // Stores the list of exam reg records to be updated
            Map<Id,Exam_Registration__c> updateExamRegRecMap = new Map<Id,Exam_Registration__c>();
            if(!examRegList.isEmpty() && examRegCase.Enrollment_Verification_Parent__c != null){
                Case examCase = (Case)examRegRecMap.get(examRegCase.Id);
                Exam_Registration__c examReg = new Exam_Registration__c(EP_end_Date__c = examRegList[0].EP_end_Date__c);
                examReg = CaseTriggerUtility.calculateSLADate(examCase, examReg);
                Integer day = examReg.SLA_Date__c.day();
                Integer month = examReg.SLA_Date__c.month();
                Integer year = examReg.SLA_Date__c.year();
                examRegCase.SLA_Date__c = DateTime.newInstance(year, month, day, 23, 00, 00);
                CaseTriggerUtility.updateRec(updateExamRegRecMap, new Exam_Registration__c(Id = examRegList[0].Id, SLA_Date__c = examReg.SLA_Date__c));
            }
            if(!updateExamRegRecMap.isEmpty() && GenericUtilities.checkIsUpdatable('Exam_Registration__c')){
                CaseTriggerUtility.updateDMLMap(updateExamRegRecMap.values());
            }
        }catch(Exception ex){
            throw ex;
        }
    }
}