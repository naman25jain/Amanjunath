public with sharing class EnrollmentVerificationEntityController {    
    // Purpose : Method will get the Current User's Contact Id
	@AuraEnabled(Cacheable = false)
	public static Id getContact(String userId){
		User uId = [SELECT Id, ContactId FROM User WHERE Id = : userId WITH SECURITY_ENFORCED];
		Id getContactId = uId.contactId;
		return getContactId;
	}
    //For user Story 1602. To get EV active cases.     
    @AuraEnabled(cacheable = false)
    public static List<EnrollmentVerificationEntityHelper.EVCaseWrapper> getEVActiveCase(String currentEntityId) {
        List<Contact> currentUser = new List<Contact>();
        Id cID =  AppForCertHelper.retrieveCurrentContactId();
        currentUser = [Select Id,FirstName,LastName,AccountId,USMLE_ID__c,Birthdate from Contact where Id =: CID WITH SECURITY_ENFORCED];                
        List<EnrollmentVerificationEntityHelper.EVCaseWrapper> existingEVActiveCase = new List<EnrollmentVerificationEntityHelper.EVCaseWrapper>();
        Id evCaseRecordTypeId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        List<Case> existingEVCase = new List<Case>();
        List<CONTACT2ACCTSERVICE__c > activeEntityContactEnrolledInDataList = new List<CONTACT2ACCTSERVICE__c > ([SELECT Id,Service__c,Role__c
        FROM CONTACT2ACCTSERVICE__c
        WHERE Account_Service__r.Account__c =: currentEntityId AND
        Service_Contact__c =: CID AND
        Service__c =: Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION AND
        Active__c = true]);
        if(!activeEntityContactEnrolledInDataList.isEmpty()){
            existingEVCase = [Select Id,caseNumber,Case_Service__c,ContactId,Contact.FirstName,Contact.LastName,USMLE_ID__c,Contact.Id, Date_of_Birth__c,Verification_Status__c,Record_Available_Date__c,External_Status__c,Unique_Medical_School__c,
            Internal_Status__c from case where AccountId =:currentEntityId  And RecordtypeId =: evCaseRecordTypeId And Verification_Status__c =: Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED WITH SECURITY_ENFORCED];        
            Map<String,List<Exam_Registration__c>> examRegMap = new Map<String,List<Exam_Registration__c>>();
            Map<String,Boolean> examRegMapStatus = new Map<String,Boolean>();        
            Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            if(!existingEVCase.isEmpty()){
                for(Exam_Registration__c examReg : [Select Id,Case__c,Exam_Types__c,Exam_Status__c,
                                                        EP_start_Date__c,EP_end_Date__c,Case__r.Enrollment_Verification_Parent__c from Exam_Registration__c 
                                                        where Exam_Status__c = null And Case__r.Is_Removed_From_EV__c =: FALSE And Case__r.Id IN: 
                                                         [Select Id,Case_Service__c from Case where Enrollment_Verification_Parent__c IN: existingEVCase And RecordtypeId =: examregRecordTypeId]]) {
                                                            if(examRegMap.containsKey(examReg.Case__r.Enrollment_Verification_Parent__c)){
                        examRegMap.get(examReg.Case__r.Enrollment_Verification_Parent__c).add(examReg);
                    } else {                            
                        List<Exam_Registration__c> tempExamList = new List<Exam_Registration__c>();
                        tempExamList.add(examReg);
                        examRegMap.put(examReg.Case__r.Enrollment_Verification_Parent__c,tempExamList);
                    }                    
                    examRegMapStatus = getExamRegMap(examReg.Exam_Status__c,examRegMapStatus,examReg);
                }            
                existingEVActiveCase = getEVCaseWrp(existingEVCase,examRegMap,currentUser[0],examRegMapStatus);            
            }
        }
        return existingEVActiveCase;
    }

    // For user Story 1602. created to handle sonar issues.
     
    public static Map<String,Boolean> getExamRegMap(String examStatus,Map<String,Boolean> examRegMapStatus,Exam_Registration__c examReg){

        if(!(examStatus != null && examStatus != '')){                     
                              examRegMapStatus.put(examReg.Case__r.Enrollment_Verification_Parent__c,true);                       
      
        }
                          
        return examRegMapStatus;
    }

    
    // Purpose : For user Story 1602. created to handle sonar issues.     
    public static List<EnrollmentVerificationEntityHelper.EVCaseWrapper> getEVCaseWrp(List<case> extCase,Map<String,List<Exam_Registration__c>> examRegMap,contact currentUser,Map<String,Boolean> examRegMapStatus){
        Map<String,String> epexDeadlineMap  = new Map<String,String>(); 
        epexDeadlineMap = getActiveEpexCase(extCase);
        List<EnrollmentVerificationEntityHelper.EVCaseWrapper> returnValue = new List<EnrollmentVerificationEntityHelper.EVCaseWrapper>();        
        String EntityContactId = currentUser.Id;
        if(!extCase.isEmpty()){
            for(Case ca : extCase){
                String caseService = ca.Case_Service__c;
                String caseId = ca.Id;  
                String conId = ca.Contact.Id;                     
                String caseNumber = ca.caseNumber;
                String restOfName = ca.Contact.FirstName;
                String lastName = ca.Contact.LastName;
                String usmleID = ca.USMLE_ID__c;
                String uniqueMedicalSchoolID = ca.Unique_Medical_School__c;
                String dateOfBirth = null;
                if(ca.Date_of_Birth__c != null){                
                    dateOfBirth = dateFormatting(ca.Date_of_Birth__c);
                }	
                String examType = '';
                String eligibilityPeriod = '';
                String recordAvailableDate = null;
                if(ca.Record_Available_Date__c != null){
                    recordAvailableDate = dateFormatting(ca.Record_Available_Date__c);
                }
                String status = ca.External_Status__c;
                if(examRegMap.containsKey(ca.Id)){
                    examType = getExamType(examRegMap,ca);
                    eligibilityPeriod = getEligibilityPeriod(examRegMap,ca);
                }
                if(examRegMapStatus.containsKey(ca.Id)){
                    Map<String,String> cData = new Map<String,String>();
                    cData.put('caseIdVal',caseId);
                    cData.put('conIdVal',conId);
                    cData.put('caseNumberVal',caseNumber);
                    cData.put('caseServiceVal',caseService);
                    cData.put('restOfNameVal',restOfName);
                    cData.put('lastNameVal',lastName);
                    cData.put('usmleIDVal',usmleID);
                    cData.put('uniqueMedicalSchoolIDVal',uniqueMedicalSchoolID);
                    cData.putAll(checkdeadlineMap(epexDeadlineMap,cData,ca));
                    EnrollmentVerificationEntityHelper.EVCaseWrapper evWrap = new EnrollmentVerificationEntityHelper.EVCaseWrapper(cData,dateOfBirth,examType,eligibilityPeriod,recordAvailableDate,status,EntityContactId);
                    returnValue.add(evWrap);
                }            
            }
        }        
        return returnValue;
    }
    public static Map<String,String> checkdeadlineMap( Map<String,String> epexDeadlineMap, Map<String,String> cData, Case ca){
        Map<String,String> deadVals = new Map <String,String>();
        if(epexDeadlineMap.containsKey(ca.Id)){
            deadVals.put('DeadlineVal',epexDeadlineMap.get(ca.Id));
        }else{
            deadVals.put('DeadlineVal','false');
        }
        return deadVals;
    }
    // For user Story 1602. created to handle sonar issues.     
    public static string getExamType(Map<String,List<Exam_Registration__c>> examRegMap,case ca){
        string examType = '';
        if(examRegMap.containsKey(ca.Id)){
            for(Exam_Registration__c exam : examRegMap.get(ca.Id)) {                
                if(String.isBlank(examType)) {
                    examType = exam.Exam_Types__c;
                } else {
                    examType = examType+'\n'+exam.Exam_Types__c;
                }
            }
        }
        return examType;
    }
    
    // For user Story 1602. created to handle sonar issues.     
    public static string getEligibilityPeriod(Map<String,List<Exam_Registration__c>> examRegMap,case ca) {
        string eligibilityPeriod = '';
        if(examRegMap.containsKey(ca.Id)) {
            for(Exam_Registration__c exam : examRegMap.get(ca.Id)){                             
                if(String.isBlank(eligibilityPeriod)) {
                    eligibilityPeriod =  getEligibilityPeriodCheck(exam.EP_start_Date__c, exam.EP_end_Date__c);             
                } else {
                    eligibilityPeriod = eligibilityPeriod +'\n'+dateFormatting(exam.EP_start_Date__c)+' - '+dateFormatting(exam.EP_end_Date__c) ;
                }                
            }
        }
        return eligibilityPeriod;
    }

    // For Reduce cognitive complexity below 15 - getEligibilityPeriod
    public static string getEligibilityPeriodCheck(Date epStartDate, Date epEndDate) {
        string eligibilityPeriod = '';
        if(epStartDate != null && epEndDate != null) {
            eligibilityPeriod = dateFormatting(epStartDate)+' - '+dateFormatting(epEndDate);
        } else {
            eligibilityPeriod = '';
        }
        return eligibilityPeriod;
    }

    // For user Story 1602. To get EV completed cases.     
    @AuraEnabled(cacheable = false)
    public static List<EnrollmentVerificationEntityHelper.EVCaseWrapper> getEVCompletedCase(String currentEntityId) {
        List<Contact> currentUser = new List<Contact>();
        Id cID =  AppForCertHelper.retrieveCurrentContactId();        
        currentUser = [Select Id,FirstName,LastName,AccountId,USMLE_ID__c,Birthdate from Contact where Id =: CID WITH SECURITY_ENFORCED];                
        List<EnrollmentVerificationEntityHelper.EVCaseWrapper> existingEVActiveCase = new List<EnrollmentVerificationEntityHelper.EVCaseWrapper>();
        Id evCaseRecordTypeId   =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        List<Case> existingEVCase = new List<Case>();
        List<CONTACT2ACCTSERVICE__c > comEntityContactEnrolledInDataList = new List<CONTACT2ACCTSERVICE__c > ([SELECT Id,Service__c,Role__c
        FROM CONTACT2ACCTSERVICE__c
        WHERE Account_Service__r.Account__c =: currentEntityId AND
        Service_Contact__c =: CID AND
        Service__c =: Constants.SERVICE_NAME_ENROLLMENT_VERIFICATION AND
        Active__c = true]);
        if(!comEntityContactEnrolledInDataList.isEmpty()){
        existingEVCase = [Select Id,caseNumber,Case_Service__c,ContactId,Contact.FirstName,Contact.LastName,USMLE_ID__c,Contact.Id,
        Date_of_Birth__c,Verification_Status__c,Record_Available_Date__c,External_Status__c ,Unique_Medical_School__c,
        Internal_Status__c from case where AccountId =: currentEntityId And RecordtypeId =: evCaseRecordTypeId And 
        (Verification_Status__c !=: Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED  AND Verification_Status__c !='') WITH SECURITY_ENFORCED];   
        Map<String,List<Exam_Registration__c>> examRegMap = new Map<String,List<Exam_Registration__c>>();
        Map<String,Boolean> examRegMapStatus = new Map<String,Boolean>();        
        Id examregRecordTypeId  =   Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        if(!existingEVCase.isEmpty()){
            for(Exam_Registration__c examReg:[Select Id,Case__c,Exam_Types__c,Exam_Status__c,
                EP_start_Date__c,EP_end_Date__c,Case__r.Enrollment_Verification_Parent__c from Exam_Registration__c 
                where Exam_Status__c = null And Case__r.Is_Removed_From_EV__c =: FALSE And Case__r.Id IN: 
                [Select Id from Case where Enrollment_Verification_Parent__c IN: existingEVCase And RecordtypeId =: examregRecordTypeId]]) {                    
                    if(examRegMap.containsKey(examReg.Case__r.Enrollment_Verification_Parent__c)) {
                        examRegMap.get(examReg.Case__r.Enrollment_Verification_Parent__c).add(examReg);
                    } else {                        
                        List<Exam_Registration__c> tempExamList = new List<Exam_Registration__c>();
                        tempExamList.add(examReg);
                        examRegMap.put(examReg.Case__r.Enrollment_Verification_Parent__c,tempExamList);
                    }
                    examRegMapStatus = getExamRegMap(examReg.Exam_Status__c,examRegMapStatus,examReg);                    
                }            
                existingEVActiveCase = getEVCaseWrp(existingEVCase,examRegMap,currentUser[0],examRegMapStatus);
            }
        }        
        return existingEVActiveCase;
    }

    //For user Story 1602. created to handle sonar issues.   
    public static string dateFormatting(Date dateValue){
        String dateForm = '';
        if(dateValue != null){
            Date relatedMonthDate = dateValue;
            Integer day2 = relatedMonthDate.day();
            Integer mon2= relatedMonthDate.month();
            Integer yr2 = relatedMonthDate.year();
            DateTime dt2 = DateTime.newInstance(yr2, mon2, day2);       
            dateForm = dt2.format('MMMM d, yyyy');        
        }
        return dateForm;
    }
    // @description: US 9116 - check if any EPEx case exists for the active EV cases
    public static Map<String,String> getActiveEpexCase(List<Case> activeEVcases){
        Map<String,String> epexCaseMap = new Map<String,String>();
        for(Case epexC: [SELECT Id, Internal_Status__c, SLA_Date__c, Enrollment_Verification_Parent__c FROM Case 
                        WHERE Enrollment_Verification_Parent__c IN: activeEVcases AND 
                        RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND (Internal_Status__c !=: Constants.CASE_STATUS_ACCEPTED AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED) WITH SECURITY_ENFORCED]){
            if(!epexCaseMap.containsKey(epexC.Enrollment_Verification_Parent__c)){
                epexCaseMap.put(epexC.Enrollment_Verification_Parent__c, 'true');
            }
        }
        return epexCaseMap;
    }
}