public with sharing class EnrollmentVerificationTriggerHandler implements CaseTriggerHandlerInterface{
    final String REC_TYPE_ENROLLMENT_VERIFICATION  = Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c;
    final String REC_TYPE_EXAM_REGISTRATION = Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c;
    final String REC_TYPE_ELIGIBILITY_PERIOD = Constant_Case__mdt.getInstance('REC_TYPE_ELIGIBILITY_PERIOD').Value__c;
    final String STATUS_NEW = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
    final String CASE_STATUS_RECEIVED_IN_REVIEW = Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c;
    final String CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
    final String DATA_KEY_EV_CHILD_CASES = Constant_Data_Key__mdt.getInstance('EV_CHILD_CASES').Value__c;
    final String DATA_KEY_EV_CHILD_EXAM_REG_CASES = Constant_Data_Key__mdt.getInstance('EV_CHILD_EXAM_REG_CASES').Value__c;
    final String CASE_STATUS_POSTED_TO_ENTITY_PORTAL = Constant_Case__mdt.getInstance('STATUS_POSTED_TO_ENTITY_PORTAL').Value__c;
    final String CASE_STATUS_PENDING_ENROLLMENT = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c;
    final String CASE_STATUS_ENROLLMENT_VER_INCOMPLETE = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c;
    final String CASE_STATUS_ENROL_VER_RECEIVED_IN_REVIEW = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VER_RECEIVED_IN_REVIEW').Value__c;
    final String CASE_STATUS_MANUAL_REVIEW_REQUIRED = Constant_Case__mdt.getInstance('STATUS_MANUAL_REVIEW_REQUIRED').Value__c;
    final String CASE_STATUS_PENDING_REVIEW = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
    final Id CASE_QUEUE_MANUAL_REVIEW_ID = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MANUAL_REVIEW').Value__c);
    final Id CASE_QUEUE_ENROLLMENT_VERIFICATION_ID = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENROLLMENT_VERIFICATION').Value__c);
    final String CASE_VERIFICATION_STATUS_NOT_REVIEWED = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c;
    final String CASE_VERIFICATION_STATUS_DECEASED = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_DECEASED').Value__c;
    final String CASE_VERIFICATION_STATUS_ENROLLED = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
    final String CASE_VERIFICATION_STATUS_GRADUATED = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_GRADUATED').Value__c;
    final String STATUS_NO = Constant_Case__mdt.getInstance('STATUS_NO').Value__c;
    final String STATUS_YES = Constant_Case__mdt.getInstance('STATUS_YES').Value__c;
    final String CASE_STATUS_PENDING_CIBIS = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
    final String CASE_STATUS_REGISTERED = Constant_Case__mdt.getInstance('STATUS_REGISTERED').Value__c;
    final String CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_NOT_VERIFIED_MEDS').Value__c;
    final String CASE_STATUS_REJECTED = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
    final String CASE_STATUS_ACCEPTED = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
    final String CASE_MANUAL_REVIEW_REASON_NOT_ENROLLED = Constant_Case__mdt.getInstance('MANUAL_REVIEW_REASON_NOT_ENROLLED').Value__c;
    final String CASE_MANUAL_REVIEW_REASON_NOT_BASIC_SCIENCE = Constant_Case__mdt.getInstance('MANUAL_REVIEW_REASON_NOT_BASIC_SCIENCE').Value__c;
    final String CASE_VERIFICATION_WITHDRAWN = Constant_Case__mdt.getInstance('VERIFICATION_WITHDRAWN').Value__c;
    final String CASE_VERIFICATION_DISMISSED = Constant_Case__mdt.getInstance('VERIFICATION_DISMISSED').Value__c;
    final String CASE_VERIFICATION_TRANSFERRED = Constant_Case__mdt.getInstance('VERIFICATION_TRANSFERRED').Value__c;
    final String CIBIS_REGISTRATION_EVENT = 	Constant_other__mdt.getInstance('CIBIS_REGISTRATION_EVENT').Value__c;
    final String CIBIS_ELIGIBILITY_EVALUATION_EVENT = Constant_other__mdt.getInstance('CIBIS_ELIGIBILITY_EVALUATION_EVENT').Value__c;
    Map<String,List<sObject>> evChildCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(DATA_KEY_EV_CHILD_CASES);
    Map<String,List<sObject>> evExamRegCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(DATA_KEY_EV_CHILD_EXAM_REG_CASES);
    Map<String,sObject> examRegCaseMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_RECORDS').Value__c);
    Map<String,sObject> examRegChildRecords = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CHILD_CASE_EXAM_REGISTRATION').Value__c);
    Map<String,List<sObject>> catsMap = CaseTriggerDataInitialize.fetchGenericDataSObjectList(Constant_Data_Key__mdt.getInstance('CAT_CONTACT').Value__c);
    // Getting the instance of CaseTriggerDataInitialize
    CaseTriggerDataInitialize ctData = CaseTriggerDataInitialize.getInstance(new List<Case>(),false);
    // Fetches the stored wrapper data
    CaseTriggerDataInitialize.CaseTriggerDataWrapper ctDataWrap = ctData.fetchData();
    // Fetches the stored SOQL for Email Template
    Map<String,sObject> emailTemplate = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('EMAIL_TEMPLATE').Value__c);
    // Fetches the stored SOQL for Org wide email address
    Map<String,sObject> orgWideEmailAddRec = GetCommonQueries.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('ORGWIDEEMAILADD').Value__c);
    // Obtains org wide email address
    OrgWideEmailAddress addr = (OrgWideEmailAddress)orgWideEmailAddRec.get(Constant_other__mdt.getInstance('ORG_WIDE_ADDRESS').Value__c);
    // Obtains email template ECFMG Duplicate Certificate
    EmailTemplate emailTempRec = (EmailTemplate)emailTemplate.get(Constant_Case__mdt.getInstance('EMAIL_TEMPLATE_STATUS_UPDATE').Value__c);
    // Fetches the stored SOQL for Contact
    Map<String,sObject> contactMap = CaseTriggerDataInitialize.fetchGenericDataSObject(Constant_Data_Key__mdt.getInstance('CONTACT_REC').Value__c);
    public void beforeInsert(List<Case> newCases){
        try{
            for(Case newCase: newCases){
                if(newCase.Internal_Status__c == STATUS_NEW){
                    newCase.Record_Available_Date__c = Date.today();
                }
                // Updates Case Service
                CaseTriggerUtility.updateCaseService(newCase,REC_TYPE_ENROLLMENT_VERIFICATION);
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
            Id enrolVerQueueId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENROLLMENT_VERIFICATION').Value__c);
            for(Case newCase: newCasesMap.values()){
                if(newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                    if(newCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE || newCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VER_INCOMPLETE){
                        newCase.OwnerId = enrolVerQueueId;
                    }
                    if(newCase.Internal_Status__c == CASE_STATUS_RECEIVED_IN_REVIEW || newCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE){
                        newCase.External_Status__c = newCase.Verification_Status__c;
                    }else{
                        // Updates External Status
                        CaseTriggerUtility.updateCaseExtStatus(newCase,oldCasesMap.get(newCase.Id));
                    }
                }
                if(newCase.Internal_Status__c == STATUS_NEW && (oldCasesMap.get(newCase.Id).RecordTypeId != newCase.RecordTypeId || newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c)){
                    newCase.Record_Available_Date__c = Date.today();
                }
                // Updates the Applicant_Last_Submission_Date__c field
                CaseTriggerUtility.updateCaseRecordDate(newCase);
                // Updates standard case status field to closed/not applicable based on internal status
                CaseTriggerUtility.updateCaseRecordStatusFlag(newCase);
            }
            // Updates standard case status field to closed/not applicable based on internal status
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterInsert(Map<Id,Case> newCasesMap){
        try{
            Map<Id,Set<Id>> accCaseIdMap = new Map<Id,Set<Id>>();
            List<Case> evCasesShare = new List<Case>();
            List<Case> childCasesShare = new List<Case>();
            List<Case> epexCasesShare = new List<Case>();
            for(Case newCase : newCasesMap.values()){
                evCasesShare.add(newCase);
                List<Case> childCases = evChildCaseMap.containsKey(newCase.Id) ? (List<Case>)evChildCaseMap.get(newCase.Id) : new List<Case>();
                if(!childCases.isEmpty()){
                    getCasesToShare(childCases, childCasesShare, epexCasesShare);
                }
            }
            if(!evCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, newCasesMap.values(), REC_TYPE_ENROLLMENT_VERIFICATION);
            }
            if(!childCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, childCasesShare, DATA_KEY_EV_CHILD_CASES);
            }
            if(!epexCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, epexCasesShare, REC_TYPE_ELIGIBILITY_PERIOD);
            }
            if(!accCaseIdMap.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(accCaseIdMap,new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_ENROLLMENT_VERIFICATION').Value__c);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    public void afterUpdate(Map<Id,Case> newCasesMap,Map<Id,Case> oldCasesMap){
        try{
            Map<Id,Set<Id>> accCaseIdMap = new Map<Id,Set<Id>>();
            List<Case> evCasesShare = new List<Case>();
            List<Case> childCasesShare = new List<Case>();
            List<Case> epexCasesShare = new List<Case>();
            List<Case> evCasesToUpdate = new List<Case>();
            // populates Doc Config
            Map<String, cadmus_core__Doc_Config__c> populateDocConfig = CaseTriggerUtility.populateDocConfig();
            // Obtains the doc config Id for Customer
            String customerDocConfigId = Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c;
            for(Case newCase : newCasesMap.values()){
                if(oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.Enrolled_in_Entity_Portal__c == false && (newCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT || newCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VER_INCOMPLETE)){
                    sendMailCaseStatus(newCase);
                }
                manageExamRegManualReview(newCase, oldCasesMap.get(newCase.Id), evCasesToUpdate);
                systemCheckEVCase(newCase, oldCasesMap.get(newCase.Id));
                if(oldCasesMap.get(newCase.Id).Internal_Status__c != newCase.Internal_Status__c && newCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE){
                    handleEVCaseVerificationStatus(newCase);
                }
                if(newCase.Enrolled_in_Entity_Portal__c == false && newCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT && newCase.Internal_Status__c != oldCasesMap.get(newCase.Id).Internal_Status__c){
                    CaseTriggerUtility.generateDocHelper(populateDocConfig.get(customerDocConfigId).Id, newCase);
                }
                evCasesShare.add(newCase);
                List<Case> childCases = evChildCaseMap.containsKey(newCase.Id) ? (List<Case>)evChildCaseMap.get(newCase.Id) : new List<Case>();
                if(!childCases.isEmpty()){
                    getCasesToShare(childCases, childCasesShare, epexCasesShare);
                }
            }
            if(!evCasesToUpdate.isEmpty()){
                updateCases(evCasesToUpdate);
            }
            if(!evCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, newCasesMap.values(), REC_TYPE_ENROLLMENT_VERIFICATION);
            }
            if(!childCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, childCasesShare, DATA_KEY_EV_CHILD_CASES);
            }
            if(!epexCasesShare.isEmpty()){
                CaseTriggerUtility.populatesAccCaseMap(accCaseIdMap, epexCasesShare, REC_TYPE_ELIGIBILITY_PERIOD);
            }
            if(!accCaseIdMap.isEmpty()){
                CaseTriggerUtility.collectCaseShareAcc(accCaseIdMap,new Map<Id,Set<Id>>(),Constant_other__mdt.getInstance('SERVICE_NAME_ENROLLMENT_VERIFICATION').Value__c);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private void sendMailCaseStatus(Case newCase){
        try{
            CaseTriggerUtility.SendMailWrapper sendMailWrap = new CaseTriggerUtility.SendMailWrapper();
            sendMailWrap.caseRec = newCase;
            sendMailWrap.addr = addr;
            sendMailWrap.emailTemplate = emailTempRec;
            sendMailWrap.con = (Contact)contactMap.get(newCase.contactId);
            Messaging.SingleEmailMessage message = CaseTriggerUtility.sendCaseStatusMail(sendMailWrap);
            ctDataWrap.sendEmail.add(message);
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private void getCasesToShare(List<Case> childCases, List<Case> childCasesShare, List<Case> epexCasesShare){
        try{
            childCasesShare.addAll(childCases);
            for(Case childCase : childCases){
                if(childCase.RecordType.DeveloperName == REC_TYPE_EXAM_REGISTRATION && examRegCaseMap.containsKey(childCase.Id)){
                    Case examRegCase = (Case)examRegCaseMap.get(childCase.Id);
                    List<Case> epexCases = examRegCase.Cases;
                    if(!epexCases.isEmpty()){
                        epexCasesShare.addAll(epexCases);
                    }
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //check and update impacted exam reg case(s) needs manual review from Enrollment Verification
    private void manageExamRegManualReview(Case newCase, Case oldCase, List<Case> evCasesToUpdate){
        try{
            if(newCase.Internal_Status__c == CASE_STATUS_RECEIVED_IN_REVIEW && oldCase.Internal_Status__c != newCase.Internal_Status__c && newCase.Enrolled_in_Entity_Portal__c == false){
                updateFirstTimeExamCases(newCase, CASE_STATUS_ENROL_VER_RECEIVED_IN_REVIEW, null);
                newCase.OwnerId = CASE_QUEUE_ENROLLMENT_VERIFICATION_ID;
                newCase.Internal_Status__c = CASE_STATUS_PENDING_REVIEW;
                evCasesToUpdate.add(new Case(Id = newCase.Id, Internal_Status__c = CASE_STATUS_PENDING_REVIEW, OwnerId = CASE_QUEUE_ENROLLMENT_VERIFICATION_ID));
            }
            if(oldCase.Verification_Status__c != newCase.Verification_Status__c && newCase.Verification_Status__c != CASE_VERIFICATION_STATUS_NOT_REVIEWED && newCase.Enrolled_in_Entity_Portal__c == true){
                newCase.Internal_Status__c = CASE_STATUS_RECEIVED_IN_REVIEW;
                evCasesToUpdate.add(new Case(Id = newCase.Id, Internal_Status__c = CASE_STATUS_RECEIVED_IN_REVIEW));
                manageEVFromEntityportal(newCase, oldCase);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //check and update impacted first time exam reg case(s) needs manual review 
    private void updateFirstTimeExamCases(Case newCase, String newStatus, String reviewReason){
        try{
            List<Case> examRegCasesToUpdate = new List<Case>();
            List<Case> examRegCases = evExamRegCaseMap.containsKey(newCase.Id) ? (List<Case>)evExamRegCaseMap.get(newCase.Id) : new List<Case>();
            if(!examRegCases.isEmpty()){
                for(Case exRegCase : examRegCases){
                    Case caseToUpdate = new case();
                    if(exRegCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT || exRegCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VER_INCOMPLETE){
                        exRegCase.Internal_Status__c = newStatus;
                        caseToUpdate.Id = exRegCase.Id;
                        caseToUpdate.Internal_Status__c = newStatus;
                        if(newStatus == CASE_STATUS_MANUAL_REVIEW_REQUIRED){
                            exRegCase.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                            exRegCase.Manual_Review_Reasons__c = reviewReason;
                            caseToUpdate.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                            caseToUpdate.Manual_Review_Reasons__c = reviewReason;
                        }else if(newStatus == CASE_STATUS_ENROL_VER_RECEIVED_IN_REVIEW){
                            exRegCase.Is_First_time_Exam_Case__c = true;
                            caseToUpdate.Is_First_time_Exam_Case__c = true;
                        }
                        examRegCasesToUpdate.add(caseToUpdate);
                    }
                    if(newStatus == CASE_STATUS_ENROL_VER_RECEIVED_IN_REVIEW){
                        allImpactedEpexCases(exRegCase, newStatus);
                    }
                }
            }
            if(!examRegCasesToUpdate.isEmpty()){
                updateCases(examRegCasesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //check and update impacted epex case(s) needs manual review 
    private void allImpactedEpexCases(Case exRegCase, String newStatus){
        try{
            List<Case> epexCasesToUpdate = new List<Case>();
            Case erCase = examRegCaseMap.containsKey(exRegCase.Id) ? (Case)examRegCaseMap.get(exRegCase.Id) : new Case();
            List<Case> epexCases = !(erCase.Cases.isEmpty()) ? erCase.Cases : new List<Case>();
            if(!epexCases.isEmpty()){
                for(Case epexCase : epexCases){
                    if(epexCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT){
                        epexCase.Internal_Status__c = newStatus;
                        epexCasesToUpdate.add(new Case(Id = epexCase.Id, Internal_Status__c = newStatus));
                    }
                }
            }
            if(!epexCasesToUpdate.isEmpty()){
                updateCases(epexCasesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private void updateCases(List<Case> casesToUpdate){
        try{
            if(!casesToUpdate.isEmpty() && GenericUtilities.checkIsUpdatable('Case')){
                CaseTriggerUtility.updateDMLMap(casesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to check and update impacted exam reg case(s) needs manual review from Enrollment Verification 
    private void manageEVFromEntityportal(Case newCase, Case oldCase){
        try{
            if(((newCase.Verification_Status__c != CASE_VERIFICATION_STATUS_DECEASED && newCase.Verification_Status__c != CASE_VERIFICATION_STATUS_ENROLLED && newCase.Verification_Status__c != null && newCase.Verification_Status__c != CASE_VERIFICATION_STATUS_GRADUATED)|| newCase.Passed_basic_sciences_course__c == STATUS_NO)){
                updateFollowUpExamCases(newCase, CASE_STATUS_MANUAL_REVIEW_REQUIRED, null); 
            }
            Decimal minYears = Decimal.valueOf(System.Label.Minimum_number_of_years_attended);
            if(newCase.Verification_Status__c == CASE_VERIFICATION_STATUS_ENROLLED && newCase.Passed_basic_sciences_course__c == STATUS_YES && 
               (oldCase.Attendance_Start_Month__c != newCase.Attendance_Start_Month__c||oldCase.Attendance_Start_Year__c != newCase.Attendance_Start_Year__c || 
                oldCase.Attendance_End_Month__c != newCase.Attendance_End_Month__c ||oldCase.Attendance_End_Year__c != newCase.Attendance_End_Year__c || 
                oldCase.Graduation_Month__c != newCase.Graduation_Month__c|| oldCase.Graduation_Year__c != newCase.Graduation_Year__c||
                oldCase.Degree_Month__c != newCase.Degree_Month__c|| oldCase.Degree_Year__c != newCase.Degree_Year__c|| 
                (oldCase.Number_of_Years_Attended__c != newCase.Number_of_Years_Attended__c && newCase.Number_of_Years_Attended__c < minYears))){           
                    String reviewReason = generateManualReviewReason(newCase, oldCase);
                    updateFollowUpExamCases(newCase, CASE_STATUS_MANUAL_REVIEW_REQUIRED, reviewReason);
                    updateFirstTimeExamCases(newCase, CASE_STATUS_MANUAL_REVIEW_REQUIRED, reviewReason); 
                } 
            if(newCase.Verification_Status__c == CASE_VERIFICATION_STATUS_DECEASED){
                allImpactedExamCases(newCase, CASE_STATUS_MANUAL_REVIEW_REQUIRED);
                List<Case> examRegCases = evExamRegCaseMap.containsKey(newCase.Id) ? (List<Case>)evExamRegCaseMap.get(newCase.Id) : new List<Case>();
                if(!examRegCases.isEmpty()){
                    for(Case exRegCase : examRegCases){
                        allImpactedEpexCases(exRegCase, CASE_STATUS_MANUAL_REVIEW_REQUIRED);
                    }
                }
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // check and update impacted follow-up exam reg case(s) needs manual review
    private void updateFollowUpExamCases(Case newCase, String newStatus, String reviewReason){
        try{
            List<Case> examRegCases = evExamRegCaseMap.containsKey(newCase.Id) ? (List<Case>)evExamRegCaseMap.get(newCase.Id) : new List<Case>();
            Map<String, Exam_Registration__c> examRegMap = New Map<String, Exam_Registration__c>();
            List<Case> casesToUpdate= new List<Case>();
            for(case eRCase : examRegCases){
                Case examRegCase = (Case)examRegChildRecords.get(eRCase.Id);
                if(eRCase.Internal_Status__c != CASE_STATUS_PENDING_ENROLLMENT){
                    for(Exam_Registration__c exam : examRegCase.Exam_Registrations__r){
                        examRegMap.put(exam.Case__c, exam);
                    }
                    if(String.isEmpty(examRegMap.get(eRCase.Id).Exam_Status__c)){
                        Case caseToUpdate = new Case();
                        eRCase.Internal_Status__c = newStatus;
                        caseToUpdate.Id = eRCase.Id;
                        caseToUpdate.Internal_Status__c = newStatus;
                        if(newStatus == CASE_STATUS_MANUAL_REVIEW_REQUIRED){
                            eRCase.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                            eRCase.Manual_Review_Reasons__c = reviewReason;
                            caseToUpdate.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                            caseToUpdate.Manual_Review_Reasons__c = reviewReason;
                        }
                        casesToUpdate.add(caseToUpdate);
                    }
                }
            }
            updateCases(casesToUpdate);
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private String generateManualReviewReason(Case newCase, Case oldCase){
        try{
            String reviewReason = '';
            if((oldCase.Attendance_Start_Month__c != newCase.Attendance_Start_Month__c)||(oldCase.Attendance_Start_Year__c != newCase.Attendance_Start_Year__c)){
                reviewReason = 'Attendance Start Date was updated.';
            }
            if((oldCase.Attendance_End_Month__c != newCase.Attendance_End_Month__c )||(oldCase.Attendance_End_Year__c != newCase.Attendance_End_Year__c )){
                if(reviewReason != ''){
                    reviewReason = reviewReason+'<br/>';
                }
                reviewReason = reviewReason+'Attendance End Date was updated.';
            }
            if(oldCase.Graduation_Month__c != newCase.Graduation_Month__c || oldCase.Graduation_Year__c != newCase.Graduation_Year__c){
                if(reviewReason != ''){
                    reviewReason = reviewReason+'<br/>';
                }
                reviewReason = reviewReason+'Graduation Date was updated.';
            }
            if((oldCase.Degree_Month__c != newCase.Degree_Month__c)|| (oldCase.Degree_Year__c != newCase.Degree_Year__c)){ 
                if(reviewReason != ''){
                    reviewReason = reviewReason+'<br/>';
                }
                reviewReason = reviewReason+'Degree Issue Date was updated.';
            }
            if(oldCase.Number_of_Years_Attended__c != newCase.Number_of_Years_Attended__c && newCase.Number_of_Years_Attended__c < 1.5){
                if(reviewReason != ''){
                    reviewReason = reviewReason+'<br/>';
                }
                reviewReason = reviewReason+'Number of Years Attended was updated and is now less than 18 months.';
            }
            return reviewReason;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Filter List of cases with Internal status
    private List<Case> getCasesWithStatus(List<Case> caseList, String status){
        try{
            List<Case> retCaseList = new List<Case>();
            for(Case cse : caseList){
                if(cse.Internal_Status__c == status){
                    retCaseList.add(cse);
                }
            }
            return retCaseList;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // check and update impacted follow-up exam reg case(s) needs manual review
    private void allImpactedExamCases(Case newCase, String newStatus){
        try{
            List<Case> examRegCases = evExamRegCaseMap.containsKey(newCase.Id) ? (List<Case>)evExamRegCaseMap.get(newCase.Id) : new List<Case>();
            Map<String, Exam_Registration__c> examRegMap = New Map<String, Exam_Registration__c>();
            List<Case> casesToUpdate= new List<Case>();
            for(case eRCase :examRegCases){
                Case examRegCase = (Case)examRegChildRecords.get(eRCase.Id);
                for(Exam_Registration__c exam : examRegCase.Exam_Registrations__r){
                    examRegMap.put(exam.Case__c, exam);
                }
                if(String.isEmpty(examRegMap.get(eRCase.Id).Exam_Status__c)){
                    eRCase.Internal_Status__c = newStatus;
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = eRCase.Id;
                    caseToUpdate.Internal_Status__c = newStatus;
                    if(newStatus == CASE_STATUS_MANUAL_REVIEW_REQUIRED){
                        eRCase.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                        eRCase.Manual_Review_Reasons__c = CASE_MANUAL_REVIEW_REASON_NOT_ENROLLED;
                        caseToUpdate.OwnerId = CASE_QUEUE_MANUAL_REVIEW_ID;
                        caseToUpdate.Manual_Review_Reasons__c = CASE_MANUAL_REVIEW_REASON_NOT_ENROLLED;
                    }
                    casesToUpdate.add(caseToUpdate);
                }
            }
            if(!casesToUpdate.isEmpty()){
                updateCases(casesToUpdate);
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }

    //US 3272 - System Check to see if impacted exam reg case(s) can be auto-verified -Scenario 1
    private void systemCheckEVCase(Case evNewCase, Case evOldCase){  
        try{
            // Verification_Status__c = Enrolled, Passed_basic_sciences_course__c = Yes, Entity Portal = true
            if(evNewCase.Verification_Status__c != evOldCase.Verification_Status__c && evNewCase.Verification_Status__c == CASE_VERIFICATION_STATUS_ENROLLED
              && evNewCase.Passed_basic_sciences_course__c == STATUS_YES && evNewCase.Enrolled_in_Entity_Portal__c == true){
                systemCheckEVEnrolledCase(evNewCase, evOldCase);
            }                
            if(evNewCase.Internal_Status__c != evOldCase.Internal_Status__c && evNewCase.Enrolled_in_Entity_Portal__c == false 
              && evNewCase.Internal_Status__c == CASE_STATUS_ENROLLMENT_VER_INCOMPLETE){
                systemActionsAfterAffirmations(evNewCase, evNewCase.Deficiency_Reason_RTF__c,evNewCase.Signature_Date__c);
            }
            systemCheckRejectedEVCase(evNewCase, evOldCase);
        }
        catch(Exception ex){
            throw ex;
        }  
    }
    //Method to avoid the Cognitive Complexity (Refactor Method)
    private void systemCheckEVEnrolledCase(Case evNewCase, Case evOldCase){
        try{
            Map<String,Set<Id>> cibisIdMap = new map <String,Set<Id>> {              
                       CIBIS_REGISTRATION_EVENT => new set<Id> (),               
                       CIBIS_ELIGIBILITY_EVALUATION_EVENT => new set<Id> ()};
           List<Case> casesToUpdate = new List<Case>();
           Set<ID> evCaseIdSet = new Set<ID>();      
           evCaseIdSet.add(evNewCase.Id);
           // e. Number of Years Attended  was NOT updated OR (Number of Years Attended  was updated AND Number of Years attended is less than 18 months) 
           Boolean numberOfYearsAttendedFlag = checkNumberOfYearsAttended(evNewCase, evOldCase);
           if(evNewCase.Attendance_Start_Date__c == evOldCase.Attendance_Start_Date__c 
           && evNewCase.Attendance_End_Date__c == evOldCase.Attendance_End_Date__c 
           && evNewCase.Graduation_Month__c == evOldCase.Graduation_Month__c 
           && evNewCase.Graduation_Year__c == evOldCase.Graduation_Year__c
           && evNewCase.Degree_Date__c == evOldCase.Degree_Date__c
           && (evNewCase.Number_of_Years_Attended__c == evOldCase.Number_of_Years_Attended__c
           || numberOfYearsAttendedFlag == true)){
               List<Case> examRegCases = evExamRegCaseMap.containsKey(evNewCase.Id) ? (List<Case>)evExamRegCaseMap.get(evNewCase.Id) : new List<Case>();
               // Exam Reg Cases (All First Time Exam Applications)
               for(Case examRegCase : examRegCases){
                   // Update Exam Reg Case with Status as Pending CIBIS
                   if(examRegCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT){
                        examRegCase.Verification_Status__c        =   evNewCase.Verification_Status__c;
                        examRegCase.Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c;
                        examRegCase.Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c;
                        examRegCase.Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c;
                        examRegCase.Internal_Status__c            =   CASE_STATUS_PENDING_CIBIS;
                        cibisIdMap.get(CIBIS_REGISTRATION_EVENT).add(examRegCase.Id);
                        casesToUpdate.add(new Case(Id = examRegCase.Id,
                                                   Verification_Status__c = evNewCase.Verification_Status__c,
                                                   Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c,
                                                   Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c,
                                                   Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c,
                                                   Internal_Status__c            =   CASE_STATUS_PENDING_CIBIS));
                   }
                   Case erCase = examRegCaseMap.containsKey(examRegCase.Id) ? (Case)examRegCaseMap.get(examRegCase.Id) : new Case();
                   List<Case> allEpexCases = !(erCase.Cases.isEmpty()) ? erCase.Cases : new List<Case>();
                   List<Case> epexCases = getCasesWithStatus(allEpexCases, CASE_STATUS_PENDING_ENROLLMENT);
                   // EPEx Cases (EPEx Applications)
                   for(Case epexCase : epexCases){
                        // Update Exam Reg Case with Status as Pending CIBIS
                        epexCase.Internal_Status__c = CASE_STATUS_PENDING_CIBIS;
                        epexCase.Is_Removed_From_EV__c = true;
                        casesToUpdate.add(new Case(Id = epexCase.Id,
                                                   Is_Removed_From_EV__c = true,
                                                   Internal_Status__c =  CASE_STATUS_PENDING_CIBIS));
                        cibisIdMap.get(CIBIS_ELIGIBILITY_EVALUATION_EVENT).add(epexCase.Id);
                    }
               }
            }
           // Update Exam Reg Case Status as Pending CIBIS
            if(!casesToUpdate.isEmpty()){
                updateCases(casesToUpdate);
                if(cibisIdMap.get(CIBIS_REGISTRATION_EVENT).size()>0 || cibisIdMap.get(CIBIS_ELIGIBILITY_EVALUATION_EVENT).size()>0){
                    CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);  
                }
            }
           // Updating EV Case Status as Enrollment Verification Complete
           CaseTriggerUtility.updateEVCaseStatus(evNewCase, null);
        }
        catch(Exception ex){
            throw ex;
        }
   }
   //Number of Years Attended  was NOT updated OR (Number of Years Attended  was updated AND Number of Years attended is less than 18 months) 
   private Boolean checkNumberOfYearsAttended(Case evEnrolledNewCase, Case evEnrolledOldCase){
        try{
            Boolean numberOfYearsAttendedFlag = true;
            if(evEnrolledNewCase.Number_of_Years_Attended__c != evEnrolledOldCase.Number_of_Years_Attended__c){
                numberOfYearsAttendedFlag = false;
                // Getting total of Number of Years Attended
                Decimal totalNumberOfYearsAttended   =   getTotalNumberOfYearsAttended(evEnrolledNewCase.contactId, evEnrolledNewCase.Number_of_Years_Attended__c);
                if((totalNumberOfYearsAttended * 12) > Decimal.valueof(System.Label.Number_of_Years_Attended)){
                    numberOfYearsAttendedFlag = true;
                }
            }
            return numberOfYearsAttendedFlag;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Number of Years Attended should be a total of all schools(degree medical school+other med schools+other institutions)
    private Decimal getTotalNumberOfYearsAttended(String contactId, Decimal evCaseNumberOfYearsAttended){  
        try{
            Decimal totalNumberOfYearsAttended = evCaseNumberOfYearsAttended + getOtherMedSclNumberOfYearsAttended(contactId) + getOtherInstiNumberOfYearsAttended(contactId);
            return totalNumberOfYearsAttended;
        }
        catch(Exception ex){
            throw ex;
        }      
    }
    //Method to getting the Other Medical School - Number of Years Attended
    private Decimal getOtherMedSclNumberOfYearsAttended(String contactId){
        try{
            Decimal otherMedSclNumberOfYearsAttended = 0;
            List <Contact_Association_Type__c> catsList = catsMap.containsKey(contactId) ? (List <Contact_Association_Type__c>)catsMap.get(contactId) : new List <Contact_Association_Type__c>();
            List <Contact_Association_Type__c> conAssocMedicalSchoolLists = new List <Contact_Association_Type__c>();
            for(Contact_Association_Type__c cat : catsList){
                if(cat.RecordType.DeveloperName == Constant_CAT__mdt.getInstance('REC_TYPE_DEGREE_MEDICAL_SCHOOL').Value__c && cat.Transfer_Credit_to_Degree_School__c == true){
                    conAssocMedicalSchoolLists.add(cat);
                }
            }
            if(!conAssocMedicalSchoolLists.isEmpty() && conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c != null){
                otherMedSclNumberOfYearsAttended = conAssocMedicalSchoolLists[0].Number_of_Years_Attended__c;
            }
            return otherMedSclNumberOfYearsAttended;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to getting the Other Institution - Number of Years Attended
    private Decimal getOtherInstiNumberOfYearsAttended(String contactId){
        try{
            Decimal otherInstiNumberOfYearsAttended = 0;
            List <Contact_Association_Type__c> catsList = catsMap.containsKey(contactId) ? (List <Contact_Association_Type__c>)catsMap.get(contactId) : new List <Contact_Association_Type__c>();
            List <Contact_Association_Type__c> conAssocOtherInstitutionLists = new List <Contact_Association_Type__c>();
            for(Contact_Association_Type__c cat : catsList){
                if(cat.RecordType.DeveloperName == Constant_CAT__mdt.getInstance('REC_TYPE_OTHER_INSTITUITION').Value__c){
                    conAssocOtherInstitutionLists.add(cat);
                }
            }
            if(!conAssocOtherInstitutionLists.isEmpty()){
                for(Contact_Association_Type__c tempInst: conAssocOtherInstitutionLists){
                    if(tempInst.Number_of_Years_Attended__c != null){
                        otherInstiNumberOfYearsAttended = otherInstiNumberOfYearsAttended + tempInst.Number_of_Years_Attended__c;
                    }
                }
            }
            return otherInstiNumberOfYearsAttended;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //US 1610 - System Actions after Affirmation process is completed
    private void systemActionsAfterAffirmations(Case evNewCase, String deficiencyReason, Date signatureDate){
        try{
            List<Case> examCaseList = new List<Case>();               
            List<Case> examRegCases = evExamRegCaseMap.containsKey(evNewCase.Id) ? (List<Case>)evExamRegCaseMap.get(evNewCase.Id) : new List<Case>();
            for(Case examCase : examRegCases){   
                if(examCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT || examCase.Is_First_time_Exam_Case__c == true){
                    Case exCaseUpdate   = new Case(Id = examCase.Id, Is_First_time_Exam_Case__c = False, Internal_Status__c = CASE_STATUS_ENROLLMENT_VER_INCOMPLETE);
                    examCase.Is_First_time_Exam_Case__c = false;
                    examCase.Internal_Status__c = CASE_STATUS_ENROLLMENT_VER_INCOMPLETE;
                    if(String.IsNotBlank(deficiencyReason)){
                        exCaseUpdate.Deficiency_Reason_RTF__c = deficiencyReason;
                        examCase.Deficiency_Reason_RTF__c = deficiencyReason;
                    }
                    examCaseList.add(exCaseUpdate);
                }
                Case erCase = (case)examRegChildRecords.get(examCase.Id);
                List<Exam_Registration__c> erList = erCase.Exam_Registrations__r;
                for(Exam_Registration__c examReg : erList){
                    if(String.isEmpty(examReg.Exam_Status__c)){
                        Case exSignatureDateCaseUpdate   = new Case (Id=examReg.Case__c, Signature_Date__c = signatureDate);
                        examCase.Signature_Date__c = signatureDate;
                        examCaseList.add(exSignatureDateCaseUpdate);
                    }
                }
            }
            if(!examCaseList.isEmpty()){
                updateCases(examCaseList);
            }
        }
        catch(Exception ex){
            throw ex;
        }     
    }
    private void systemCheckRejectedEVCase(Case evNewCase, Case evOldCase){    
        try{
            Boolean evRejected = false;
            String evManualRejectedReason;
            if(evnewCase.Verification_Status__c != evOldCase.Verification_Status__c){
                if((evNewCase.Verification_Status__c != CASE_VERIFICATION_STATUS_ENROLLED && evNewCase.Verification_Status__c != CASE_VERIFICATION_STATUS_DECEASED && evNewCase.Verification_Status__c != CASE_VERIFICATION_STATUS_NOT_REVIEWED) && evNewCase.Enrolled_in_Entity_Portal__c == true){                    
                    evRejected = true;
                    evManualRejectedReason = manualEnrolledRejectedReason(evNewCase);
                 }
                else if(evNewCase.Verification_Status__c == CASE_VERIFICATION_STATUS_ENROLLED && evNewCase.Passed_basic_sciences_course__c == Constants.STATUS_NO
                        && evNewCase.Enrolled_in_Entity_Portal__c == true){                    
                    evRejected = true;
                    evManualRejectedReason = manualBasicScienceRejectedReason(evNewCase);
                }else{
                    sytemCheckUpdateExamRegVerificationStatus(evNewCase);
                }
            }       
            if(evRejected){            
                sytemCheckEVRejectedFirstSenario(evNewCase, evManualRejectedReason);
            }
        }
        catch(Exception ex){
            throw ex;
        }  
    }
    //Helper method for systemCheckRejectedEVCase
    private String manualEnrolledRejectedReason(Case evNewCase){
        try{
            String evManualRejectedReason;
            if(evNewCase.Verification_Status__c != CASE_VERIFICATION_STATUS_ENROLLED){          
                evManualRejectedReason = CASE_MANUAL_REVIEW_REASON_NOT_ENROLLED;
            }
            return evManualRejectedReason;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Helper method for systemCheckRejectedEVCase
    private String manualBasicScienceRejectedReason(Case evNewCase){
        try{
            String evManualRejectedReason;
            if(evNewCase.Passed_basic_sciences_course__c == Constants.STATUS_NO){
                evManualRejectedReason = CASE_MANUAL_REVIEW_REASON_NOT_BASIC_SCIENCE;
            }
            return evManualRejectedReason;
        }
        catch(Exception ex){
            throw ex;
        }
    }
    //Method to Rejected EV Case
    private void sytemCheckEVRejectedFirstSenario(Case evNewCase, String evManualRejectedReason){  
        try{
            List<Case> casesToUpdate = new List<Case>();
            List<Case> examRegCases = evExamRegCaseMap.containsKey(evNewCase.Id) ? (List<Case>)evExamRegCaseMap.get(evNewCase.Id) : new List<Case>();
            Boolean updateEv = false;     
            for(Case examRegCase : examRegCases){
                updateEv = true;
                if(examRegCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT && evNewCase.Verification_Status__c != CASE_VERIFICATION_STATUS_DECEASED){
                    examRegCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL;
                    examRegCase.Verification_Status__c        =   evNewCase.Verification_Status__c;
                    examRegCase.Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c;
                    examRegCase.Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c;
                    examRegCase.Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c;
                    Case examRegCaseUpdate   = new Case(Id = examRegCase.Id,
                                                        Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL,
                                                        Verification_Status__c        =   evNewCase.Verification_Status__c,
                                                        Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c,
                                                        Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c,
                                                        Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c);
                    casesToUpdate.add(examRegCaseUpdate);
                }
                Case erCase = examRegCaseMap.containsKey(examRegCase.Id) ? (Case)examRegCaseMap.get(examRegCase.Id) : new Case();
                List<Case> epexCases = !(erCase.Cases.isEmpty()) ? erCase.Cases : new List<Case>();
                for(Case epexCase : epexCases){
                    // Update epex Case as Rejected 
                    if(epexCase.Internal_Status__c == CASE_STATUS_PENDING_ENROLLMENT){
                        epexCase.Internal_Status__c = CASE_STATUS_REJECTED;
                        epexCase.Is_Removed_From_EV__c = true;
                        Case epexCaseUpdate   = new Case(Id = epexCase.Id, Internal_Status__c = CASE_STATUS_REJECTED, Is_Removed_From_EV__c = True);
                        casesToUpdate.add(epexCaseUpdate);
                    }
                }
            }
            if(!casesToUpdate.isEmpty()){
                updateCases(casesToUpdate);
                
            }
            // Updating EV Case Status as Enrollment Verification Complete
            if(updateEv){
                CaseTriggerUtility.updateEVCaseStatus(evNewCase, evManualRejectedReason);
            } 
        }
        catch(Exception ex){
            throw ex;
        }      
    }
    //Updating Verification Status Enrolled, Deceased and Not Reviewed in Exam Reg Case
    private void sytemCheckUpdateExamRegVerificationStatus(Case evNewCase){
        try{
            List<Case> examRegCaseLists = new List<Case>();
            List<Case> examRegCases = evExamRegCaseMap.containsKey(evNewCase.Id) ? (List<Case>)evExamRegCaseMap.get(evNewCase.Id) : new List<Case>();
            for(Case examRegCase : examRegCases){
                examRegCase.Verification_Status__c        =   evNewCase.Verification_Status__c;
                examRegCase.Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c;
                examRegCase.Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c;
                examRegCase.Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c;
                Case examRegCaseUpdate   = new Case(Id = examRegCase.Id,
                                                    Verification_Status__c        =   evNewCase.Verification_Status__c,
                                                    Verification_Status_Month__c  =   evNewCase.Verification_Status_Month__c,
                                                    Verification_Status_Year__c   =   evNewCase.Verification_Status_Year__c,
                                                    Verification_Status_Date__c   =   evNewCase.Verification_Status_Date__c);
                examRegCaseLists.add(examRegCaseUpdate);                
            }
            if(!examRegCaseLists.isEmpty()){
                updateCases(examRegCaseLists);          
            }   
        }
        catch(Exception ex){
            throw ex;
        }   
    }
    private void handleEVCaseVerificationStatus(Case newCase){
        try{
            List <Contact_Association_Type__c> catsList = catsMap.containsKey(newCase.contactId) ? (List <Contact_Association_Type__c>)catsMap.get(newCase.contactId) : new List <Contact_Association_Type__c>();
            Contact_Association_Type__c catRecord = new Contact_Association_Type__c ();
            for(Contact_Association_Type__c cat : catsList){
                if(cat.RecordType.DeveloperName == Constant_CAT__mdt.getInstance('REC_TYPE_DEGREE_MEDICAL_SCHOOL').Value__c){
                    catRecord = cat;
                    break;
                }
            }
            if(newCase.Verification_Status__c == CASE_VERIFICATION_STATUS_ENROLLED || newCase.Verification_Status__c == CASE_VERIFICATION_STATUS_DECEASED){
                updateCATEnrolled(newCase, catRecord);       
            } 
            else if(newCase.Verification_Status__c == CASE_VERIFICATION_STATUS_GRADUATED){
                updateCATGraduated(newCase, catRecord);      
            } 
            else if(newCase.Verification_Status__c == CASE_VERIFICATION_WITHDRAWN || newCase.Verification_Status__c == CASE_VERIFICATION_DISMISSED || newCase.Verification_Status__c == CASE_VERIFICATION_TRANSFERRED){
                updateCATWithdrawn(newCase, catRecord);    
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // USER STORY 7604 - If "Enrolled" or "Deceased" is the Verification Status, then update the following fields on the CAT record
    private void updateCATEnrolled(Case newCase, Contact_Association_Type__c catRecord){
        try{
            List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();     
            if(catRecord != null){
                Contact_Association_Type__c catObj  =   new Contact_Association_Type__c();  
                catObj.Id                           =   catRecord.Id;       
                catObj.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catObj.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catObj.End_Month__c                 =   newCase.Attendance_End_Month__c;
                catObj.End_Year__c                  =   newCase.Attendance_End_Year__c;
                catObj.Graduation_Month__c          =   newCase.Graduation_Month__c;
                catObj.Graduation_Year__c           =   newCase.Graduation_Year__c;
                catObj.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catObj.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catObj.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                catList.add(catObj);   
                catRecord.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catRecord.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catRecord.End_Month__c                 =   newCase.Attendance_End_Month__c;
                catRecord.End_Year__c                  =   newCase.Attendance_End_Year__c;
                catRecord.Graduation_Month__c          =   newCase.Graduation_Month__c;
                catRecord.Graduation_Year__c           =   newCase.Graduation_Year__c;
                catRecord.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catRecord.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catRecord.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                if(Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
                    CaseTriggerUtility.updateDMLMap(catList);
                } 
            } 
        }
        catch(Exception ex){
            throw ex;
        }         
    }
    // USER STORY 7604 - If "Graduated" is the Verification Status, then update the following fields on the CAT record
    private void updateCATGraduated(Case newCase, Contact_Association_Type__c catRecord){
        try{
            List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
            if(catRecord != null){
                catRecord.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catRecord.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catRecord.End_Month__c                 =   newCase.Attendance_End_Month__c;
                catRecord.End_Year__c                  =   newCase.Attendance_End_Year__c;
                catRecord.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catRecord.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catRecord.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                catRecord.Graduation_Month__c          =   newCase.Verification_Status_Month__c;
                catRecord.Graduation_Year__c           =   newCase.Verification_Status_Year__c;
                Contact_Association_Type__c catObj  =   new Contact_Association_Type__c(); 
                catObj.Id                           =   catRecord.Id;
                catObj.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catObj.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catObj.End_Month__c                 =   newCase.Attendance_End_Month__c;
                catObj.End_Year__c                  =   newCase.Attendance_End_Year__c;
                catObj.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catObj.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catObj.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                catObj.Graduation_Month__c          =   newCase.Verification_Status_Month__c;
                catObj.Graduation_Year__c           =   newCase.Verification_Status_Year__c;
                catList.add(catObj);
                if(Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
                    CaseTriggerUtility.updateDMLMap(catList);
                } 
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    // USER STORY 7604 - If "Withdrawn" or "Dismissed" or "Transferred" is the Verification Status, then update the following fields on the CAT record
    private void updateCATWithdrawn(Case newCase, Contact_Association_Type__c catRecord){
        try{
            List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
            if(catRecord != null){
                Date verStDt = newCase.Verification_Status_Date__c;
                String verStMonth;
                String verStYear;
                if(verStDt != null){
                    verStMonth = getMonthAsText(verStDt.Month());
                    verStYear = String.valueOf(verStDt.Year());
                }
                catRecord.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catRecord.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catRecord.End_Month__c                 =   verStMonth;
                catRecord.End_Year__c                  =   verStYear;
                catRecord.Graduation_Month__c          =   newCase.Graduation_Month__c;
                catRecord.Graduation_Year__c           =   newCase.Graduation_Year__c;
                catRecord.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catRecord.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catRecord.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                Contact_Association_Type__c catObj  =   new Contact_Association_Type__c();       
                catObj.Id                           =   catRecord.Id;
                catObj.Start_Month__c               =   newCase.Attendance_Start_Month__c;
                catObj.Start_Year__c                =   newCase.Attendance_Start_Year__c;
                catObj.End_Month__c                 =   verStMonth;
                catObj.End_Year__c                  =   verStYear;
                catObj.Graduation_Month__c          =   newCase.Graduation_Month__c;
                catObj.Graduation_Year__c           =   newCase.Graduation_Year__c;
                catObj.Degree_Issue_Month__c        =   newCase.Degree_Month__c;
                catObj.Degree_Issue_Year__c         =   newCase.Degree_Year__c;
                catObj.Number_of_Years_Attended__c  =   newCase.Number_of_Years_Attended__c;
                catList.add(catObj);
                if(Contact_Association_Type__c.SObjectType.getDescribe().isUpdateable()){
                    CaseTriggerUtility.updateDMLMap(catList);
                } 
            }
        }
        catch(Exception ex){
            throw ex;
        }
    }
    private String getMonthAsText(Integer intMonth){
        try{
            Map<Integer,String> monthMap = new  Map<Integer,String>();
            monthMap.put(1,'January');
            monthMap.put(2,'February');
            monthMap.put(3,'March');
            monthMap.put(4,'April');
            monthMap.put(5,'May');
            monthMap.put(6,'June');
            monthMap.put(7,'July');
            monthMap.put(8,'August');
            monthMap.put(9,'September');
            monthMap.put(10,'October');
            monthMap.put(11,'November');
            monthMap.put(12,'December');
            return monthMap.get(intMonth);
        }
        catch(Exception ex){
            throw ex;
        }
    }
}