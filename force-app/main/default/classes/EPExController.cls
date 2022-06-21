/**
 * Class for EPExController
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   24-MARCH-2020
 */
public with sharing class EPExController{
    public EPExController(){
        //Used for creating new instance
    }
    /**
	 * Created by Jofrin
	 * Method Name: enableEligPeriodExtRequest
	 * Purpose : Method to validate on eligibility period extension request link.
	 * Return Type : string
	 */
    @AuraEnabled(Cacheable = true)
    public static string enableEligPeriodExtRequest(){
        try{
            Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
            List<id> newCaseList = new List<id>();
            newCaseList = ExamRegistrationController.getEligibleRegionChangeCases();
            Map<String, Case> epexCaseMap = new Map <String, Case>();
            for (Case listCase: [SELECT id,Parent.Id, CaseNumber, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD AND Parent.Id= :newCaseList AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED]) {
                epexCaseMap.put(listCase.Parent.Id, listCase);
            }
            Map<String, OFAC__c> ofacCountriesMap = ServicesComponentController.getOFACCountryList();
            Contact thisContact = [SELECT id, MailingCountry, School_Enrollment_Status__c FROM Contact WHERE id =: currentContactId WITH SECURITY_ENFORCED Limit 1];
            if(!ofacCountriesMap.isEmpty() && ofacCountriesMap.containsKey(thisContact.MailingCountry) && ofacCountriesMap.get(thisContact.MailingCountry).type__c == System.Label.OFAC_NOT_ALLOWED1){
                return System.Label.OFAC_Not_Allowed_Error_Message + '<br>';
            }else{
                string methodVal = enableEligPeriodExtRequestContinue(newCaseList, epexCaseMap);
                if(string.isnotBlank(methodVal) && methodVal != 'true'){
                    return methodVal;
                }
            }
            return 'true';
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
	 * Created by Jofrin
	 * Method Name: enableEligPeriodExtRequestContinue
	 * Purpose : Method to validate on eligibility period extension request link.
	 * Return Type : string
	 */
    @AuraEnabled(Cacheable = true)
    public static string enableEligPeriodExtRequestContinue(List<Id> newCaseList, Map < String, Case > epexCaseMap ){

        List<Exam_Registration__c > erList = new List<Exam_Registration__c > ([Select id, case__c, EP_start_Date__c, EP_end_Date__c, Exam_taken_date__c, Exam_Status__c, Exam_Types__c from Exam_Registration__c where case__c =: newCaseList]);
       
       
        integer erListSize = erList.size();
        string valLabel = '';
        integer erCount = 0;
        boolean errorTrue ;
        
        for (Exam_Registration__c eachExmReg: erList) {
            errorTrue = false;
            

            string retVal =  enableEligPeriodExtRequestContinueSecond(eachExmReg);
            if (string.isnotblank(retVal) && retVal != 'true') {
                valLabel = valLabel + retVal;
                errorTrue = true;
            }

            if(!epexCaseMap.isEmpty() && epexCaseMap.containsKey(eachExmReg.case__c) && epexCaseMap.get(eachExmReg.case__c).Internal_Status__c != Constants.CASE_STATUS_REJECTED){
                valLabel = valLabel + System.label.Eligibility_Period_Extension_CaseAlreadyExist;
                errorTrue = true;
            }
            if(errorTrue){
                erCount++;
            }
        }
        if (erCount == erListSize) {

            return getFinalErrorMessage(valLabel);
        }
        return 'true';
    }
    /**
	 * Created by Femi
	 * Method Name: getFinalErrorMessage
	 * Purpose : Method to generate error msg for epex button.
	 * Return Type : string
	 */
    @AuraEnabled(Cacheable = true)
    public static string getFinalErrorMessage(String errorMsg){
        String returnValue = '';
        if(errorMsg.contains(System.label.Eligibility_Period_Extension_CaseAlreadyExist)){
            returnValue = returnValue+System.label.Eligibility_Period_Extension_CaseAlreadyExist;
        }
        if(errorMsg.contains(System.label.Eligibility_Period_Extension_StartDateValidation)){
            returnValue = returnValue+System.label.Eligibility_Period_Extension_StartDateValidation;
        }
        if(errorMsg.contains(System.label.Eligibility_Period_Extension_EndDateValidation)){
            returnValue = returnValue+System.label.Eligibility_Period_Extension_EndDateValidation;
        }
        return returnValue;
        
    }

    /**
	 * Created by Jofrin
	 * Method Name: enableEligPeriodExtRequestContinueSecond
	 * Purpose : Method to validate on eligibility period extension request link.
	 * Return Type : string
	 */
    @AuraEnabled(Cacheable = true)
    public static string enableEligPeriodExtRequestContinueSecond(Exam_Registration__c eachExmReg){
        
        Date curDate = System.Today();
        string valLab = '';
        boolean errorTrue = false;
        
        if(eachExmReg.EP_start_Date__c > curDate){
            valLab = valLab +  System.label.Eligibility_Period_Extension_StartDateValidation;
            errorTrue = true;
        }
        if(eachExmReg.EP_end_Date__c + 24 < curDate){
            valLab = valLab + System.label.Eligibility_Period_Extension_EndDateValidation;
            errorTrue = true;
        }
        if(errorTrue){
            return valLab;
        }
       return 'true';
    }
    /**
	 * Created by Femi
	 * Method Name: getEPExExams
	 * Purpose : Method to get the list of exam for which eligibility extension can be applied.
	 * Return Type : List<Exam_Registration__c>
	 */
    @AuraEnabled
    public static List<EpexWrapper>  getEPExExams(){
        try{
            Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
            List<case >newCaseList = new List<case >();
            List<EpexWrapper> epexList = new List<EpexWrapper>();
            Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            List<Exam_Registration__c > erList = new List<Exam_Registration__c>();
            newCaseList = [SELECT id, CaseNumber, Internal_Status__c, Eligibility_Period__r.Period_Code__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION
                    AND ContactId =: currentContactId AND Internal_Status__c =: Constants.CASE_STATUS_REGISTERED WITH SECURITY_ENFORCED
                ];
            erList = new List<Exam_Registration__c > ([Select id, case__c, EP_end_Date__c, EP_start_Date__c, Exam_taken_date__c, Exam_Status__c, Exam_Types__c, case__r.Eligibility_Period__c, case__r.Eligibility_Period__r.Period_Code__c, (SELECT Id FROM Cases__r WHERE RecordTypeId =: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION) 
                    from Exam_Registration__c where case__c =: newCaseList And(Exam_Types__c =: Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE or Exam_Types__c =: Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK)And Exam_Status__c = null WITH SECURITY_ENFORCED Order By Exam_Types__c 
                ]);
            List<String> periodCodeList = new List<String>();
            for(Exam_Registration__c exRec : erList){
                periodCodeList.add(exRec.case__r.Eligibility_Period__r.Period_Code__c + 'X');
            }
            Map<String, Eligibility_Period__c> periodCodeMap = getEpMap(periodCodeList);
            for(Exam_Registration__c examReg:erList){
                String periodCode = examReg.case__r.Eligibility_Period__r.Period_Code__c + 'X';
                Eligibility_Period__c extEligibilityPeriod = new Eligibility_Period__c();
                if(!periodCodeMap.isEmpty() && periodCodeMap.containskey(periodCode) && periodCodeMap.get(periodCode).Exam_Type__c == examReg.Exam_Types__c){
                    extEligibilityPeriod = periodCodeMap.get(periodCode);
                }
                if(extEligibilityPeriod != null){
                    EpexWrapper wrapper = new EpexWrapper(examReg.EP_start_Date__c , examReg.EP_end_Date__c, examReg.Exam_Types__c, examReg.case__c, extEligibilityPeriod.EP_Start_Date__c, extEligibilityPeriod.EP_End_Date__c, extEligibilityPeriod.Deadline_Date__c, examReg.Cases__r);
                    epexList.add(wrapper);
                }
            }    
            return epexList;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
	 * Created by Femi
	 * Method Name: validateEPExRequest
	 * Purpose : Method to validate exams for which eligibility extension can be applied.
	 * Return Type : Boolean
	 */
    @AuraEnabled
    public static Boolean validateEPExRequest(String examType,String caseId){
        try{
            Boolean returnValue = true;
            Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
            List<case >newCaseList = new List<case >();
            newCaseList = [SELECT id, CaseNumber, Internal_Status__c FROM Case WHERE recordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD
                    AND ContactId =: currentContactId AND Internal_Status__c !=: Constants.CASE_STATUS_REJECTED AND Exam_Registration__r.Exam_Types__c =:examType AND ParentId =:caseId AND Internal_Status__c !=: Constants.CASE_STATUS_PENDING_SUBMISSION WITH SECURITY_ENFORCED
                ];
            if(newCaseList.isEmpty()){
                returnValue = false;
            }      
            return returnValue;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
	 * Created by Nayana S
	 * Method Name: createEPExCase
	 * Purpose : Method to create new EPeX cases
	 * Return Type : Boolean
	 */
	@AuraEnabled
	public static String createEPExCase(String selectedList){
        try{
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            Id examRegRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
            Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            List<Case> newCaseList = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: examRegRecordTypeId AND ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_REGISTERED WITH SECURITY_ENFORCED];
            List<Id> examRegIds = new List<Id>();
            List<Id> epexToDeleteIds = new List<Id>();
            for(Case cse : newCaseList){
                if(selectedList.contains(cse.Id)){
                    examRegIds.add(cse.Id);
                }else{
                    epexToDeleteIds.add(cse.Id);
                }
            }
            List<Case> caseToInsert = new List<Case>();
            Group g = [SELECT Id, name, Group.DeveloperName FROM Group WHERE Type = 'Queue' AND Group.DeveloperName =: Constants.QUEUE_EXAM_REG WITH SECURITY_ENFORCED];
            List<Exam_Registration__c> exRegList = [SELECT Id, Name, case__r.Eligibility_Period__r.Period_Code__c, Exam_Types__c, EP_start_Date__c, EP_end_Date__c, Case__c, Applicant__r.School_Enrollment_Status__c, 
                                                    (SELECT Id FROM Cases__r WHERE RecordTypeId =: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION)
                                                    FROM Exam_Registration__c WHERE Case__c IN :examRegIds WITH SECURITY_ENFORCED];
            List<String> periodCodeList = new List<String>();
            for(Exam_Registration__c exRec : exRegList){
                periodCodeList.add(exRec.case__r.Eligibility_Period__r.Period_Code__c + 'X');
            }
            Map<String, Eligibility_Period__c> periodCodeMap = getEpMap(periodCodeList);
            for(Exam_Registration__c exRec : exRegList){
                if(exRec.Cases__r.isEmpty()){
                    Case c = new case();
                    c.Exam_Registration__c = exRec.Id;
                    c.ContactId = contactId;
                    c.OwnerId = g.Id;
                    c.parentId = exRec.Case__c;
                    c.Exam_Type__c = exRec.Exam_Types__c;
                    c.Internal_Status__c =  Constants.CASE_STATUS_PENDING_SUBMISSION;
                    c.RecordTypeId = ePExRecordTypeId;
                    String periodCode = exRec.case__r.Eligibility_Period__r.Period_Code__c + 'X';
                    if(!periodCodeMap.isEmpty() && periodCodeMap.containskey(periodCode) && periodCodeMap.get(periodCode).Exam_Type__c == exRec.Exam_Types__c){
                        c.Eligibility_Period__c = periodCodeMap.get(periodCode).Id;
                    }
                    caseToInsert.add(c);                    
                }
            }
            insertEpexCases(caseToInsert, epexToDeleteIds);
            String epexCaseIdString = '';
            List<String> epexCaseIdList = new List<String>();
            List<Case> epexCaseList = [SELECT Id, CaseNumber, Internal_Status__c FROM Case WHERE RecordTypeId =: ePExRecordTypeId AND ContactId =: contactId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND Exam_Registration__c != null WITH SECURITY_ENFORCED];
            for(Case epexCaseObj : epexCaseList){                
                epexCaseIdList.add(epexCaseObj.Id);
            }
            epexCaseIdString = String.join(epexCaseIdList,',');
            return epexCaseIdString;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Method to Insert new Epex cases and Mark Epex cases for deletion which are Unselected
    public static void insertEpexCases(List<Case> caseToInsert, List<Id> epexToDeleteIds){
        try{
            Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            List<Case> epexToDelete = [SELECT Id FROM Case WHERE RecordTypeId =: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId IN :epexToDeleteIds WITH SECURITY_ENFORCED];
            for(Case cse: epexToDelete){
                cse.Internal_Status__c = Constants.CASE_STATUS_MARKED_FOR_DELETION;
                cse.parentId = null;
                cse.Exam_Registration__c = null;
                cse.Eligibility_Period__c = null;
            }
            if(!epexToDelete.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                UPDATE epexToDelete; 
            }
            if(!caseToInsert.isEmpty() && Schema.sObjectType.Case.isCreateable()){
                INSERT caseToInsert; 
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Method to get Map of extended eligibility period
    public static Map<String, Eligibility_Period__c> getEpMap(List<String> periodCodeList){
        try{
            list<Eligibility_Period__c> epList = [SELECT Id, Period_Code__c, Exam_Type__c, EP_Start_Date__c, EP_End_Date__c, Deadline_Date__c FROM Eligibility_Period__c WHERE Period_Code__c IN :periodCodeList AND RecordType.DeveloperName =:Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG WITH SECURITY_ENFORCED];
            Map<String, Eligibility_Period__c> periodCodeMap = new Map<String, Eligibility_Period__c>();
            for(Eligibility_Period__c ep : epList){
                periodCodeMap.put(ep.Period_Code__c, ep);
            }
            return periodCodeMap;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
      /**
     * Method Name: getTermsandConditionsEPEx
     * Purpose : Method to fetch Terms and conditions for EPeX legalsignoff
     * Return Type : List of wrapper with terms content
     * @Params : None
     */
    @AuraEnabled(Cacheable = true)
    public static List <AppForCertHelper.TermsObjWrapper> getTermsandConditionsEPEx(){
        try{
            List<AppForCertHelper.TermsObjWrapper> fetchedValuesToReturn = new List <AppForCertHelper.TermsObjWrapper>();
            List<Terms_and_Conditions__c> termsList = new List <Terms_and_Conditions__c>();
            termsList = [SELECT Id, Copy__c, Name, Short_Copy__c FROM Terms_and_Conditions__c WHERE Product__r.Name =: Constants.PRODUCT_NAME_EPEX_LEGAL_TERMS
                AND Status__c =: Constants.TERMS_AND_COND_STATUS_ACTIVE  WITH SECURITY_ENFORCED
                Order By CreatedDate ASC
            ];
            if(!termsList.isEmpty()){
                For(Terms_and_Conditions__c terms: termsList){
                    string termsId = terms.Id;
                    string termsContent = terms.Copy__c;
                    string termsCheckBox = terms.Short_Copy__c;
                    AppForCertHelper.TermsObjWrapper tempTermsObj = new AppForCertHelper.TermsObjWrapper(termsId, termsContent, termsCheckBox);
                    fetchedValuesToReturn.add(tempTermsObj);
                }
            }
            return fetchedValuesToReturn;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    //Display epex cases in summary page
    @AuraEnabled(Cacheable = false)
    public static List<EpexWrapper> getEpexCaseDetails(){
        try{
            List<EpexWrapper> epexList = new List<EpexWrapper>();
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            List<Case> epexCases = [SELECT Exam_Registration__r.EP_start_Date__c, Exam_Registration__r.EP_end_Date__c, Exam_Registration__r.Exam_Types__c, Exam_Registration__r.Case__c,
                                    Eligibility_Period__r.EP_Start_Date__c, Eligibility_Period__r.EP_End_Date__c, Eligibility_Period__r.Deadline_Date__c
                                    FROM Case WHERE ContactId=: contactId AND RecordTypeId=: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
            for(Case cse : epexCases){
                EpexWrapper wrapper = new EpexWrapper(cse.Exam_Registration__r.EP_start_Date__c , cse.Exam_Registration__r.EP_end_Date__c, cse.Exam_Registration__r.Exam_Types__c, cse.Exam_Registration__r.case__c,
                                                cse.Eligibility_Period__r.EP_Start_Date__c, cse.Eligibility_Period__r.EP_End_Date__c, cse.Eligibility_Period__r.Deadline_Date__c, new List<Case>());
                epexList.add(wrapper);
            }
            return epexList;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
     * Created by Nayana S
     * Method Name: getEPExCaseNumber
     * Purpose : Method to get EPEx caseNumber
     * Return Type : String
     */
    @AuraEnabled(Cacheable = false)
    public static String getEPExCaseNumber(){
        try{
            String returnStr ='';
            Id contactId = AppForCertHelper.retrieveCurrentContactId();
            Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
            Map<Id, Id> examEVMap = new Map<Id, Id>();
            List<Case> epexCasesForEV = new List<Case>();
            List<Case> epexCases = [SELECT CaseNumber, Internal_Status__c, Contact.School_Enrollment_Status__c, ParentId, Parent.Enrollment_Verification_Parent__c, Enrollment_Verification_Parent__c FROM Case WHERE ContactId=: contactId AND RecordTypeId=: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION];
            for(case cse: epexCases){
                if(cse.Contact.School_Enrollment_Status__c == Constants.CONASCTYPESTG_STATUS_STUDENT){
                    cse.Internal_Status__c =  Constants.CASE_STATUS_PENDING_ENROLLMENT;
                    examEVMap.put(cse.ParentId, cse.Parent.Enrollment_Verification_Parent__c);
                    epexCasesForEV.add(cse);
                }else if(cse.Contact.School_Enrollment_Status__c == Constants.CONASCTYPESTG_STATUS_GRADUATE){
                    cse.Internal_Status__c =  Constants.CASE_STATUS_PENDING_CIBIS;
                }
            }
            if(!epexCases.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
                UPDATE epexCases; 
            }
            for(Case c : epexCases){
                if(returnStr == ''){
                    returnStr = String.valueof(c.caseNumber);
                }else{
                    returnStr = returnStr +',' +String.valueof(c.caseNumber);
                }
            }
            if(!epexCasesForEV.isEmpty()){
                updateEpexCasesForEV(contactId, examEVMap, epexCasesForEV);
            }
            return returnStr;
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }    
    public static void updateEpexCasesForEV(Id contactId, Map<Id, Id> examEVMap, List<Case> epexCasesForEV){
        try{
            Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            Group evQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION);
            Map<String, Contact_Association_Type__c> catMap = CaseTriggerUtility.catMap;
            Contact_Association_Type__c cat = catMap.get(contactId);
            Set<Id> accountIds = new Set<Id>();
            for(Account2Service__c a2s : [SELECT Id, Account__c FROM Account2Service__c WHERE Account__c =:cat.Account__c AND Active__c = True WITH SECURITY_ENFORCED]){
                accountIds.add(a2s.Account__c);
            }
            Map<Id, Case> evCases = new Map<Id, Case>([SELECT Id, Internal_Status__c, OwnerId, ContactId, AccountId, Enrolled_in_Entity_Portal__c, Account.IsCustomerPortal
                                                    FROM Case
                                                    WHERE RecordTypeId =:evRTId 
                                                            AND ContactId =:contactId
                                                            AND AccountId IN :accountIds 
                                                            AND Id IN :examEVMap.values()]);
            Map<Id, Case> caseMap = new Map<Id, Case>();
            for(Case newCase : epexCasesForEV){
                if(examEVMap.containsKey(newCase.ParentId) && evCases.containsKey(examEVMap.get(newCase.ParentId))){
                    Case evCase = evCases.get(examEVMap.get(newCase.ParentId));
                    if(newCase.ContactId == evCase.ContactId && cat.Account__c == evCase.AccountId && accountIds.contains(evCase.AccountId)){
                        newCase.Enrollment_Verification_Parent__c = evCase.Id;
                        caseMap.put(newCase.Id, newCase);                    
                        Case evCaseToUpdate = new Case();
                        evCaseToUpdate.Id = evCase.Id;
                        evCaseToUpdate.Internal_Status__c = Constants.CASE_STATUS_NEW;
                        evCaseToUpdate.Enrolled_in_Entity_Portal__c = accountIds.contains(evCase.AccountId);
                        caseMap.put(evCaseToUpdate.Id, evCaseToUpdate);
                    }
                    if(!accountIds.contains(evCase.AccountId)){
                        createEVCaseForEpex(newCase, evQueue.Id, cat, evRTId);
                    }
                }
                else{
                    if(cat != null){
                        createEVCaseForEpex(newCase, evQueue.Id, cat, evRTId);
                    }
                }
            }
            if(!caseMap.isEmpty() && Case.SObjectType.getDescribe().isUpdateable()){
                UPDATE caseMap.values();
                reUpdateEVCaseForEpex(caseMap.values());
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void createEVCaseForEpex(Case epexCase, String queueId, Contact_Association_Type__c catRecord, String evRTId){
        try{
            Case caseObj = new Case();
            caseObj.ContactId                    =   epexCase.ContactId;                
            caseObj.RecordTypeId                 =   evRTId;
            caseObj.Internal_Status__c           =   Constants.CASE_STATUS_NEW;
            caseObj.OwnerId                      =   queueId;
            caseObj.AccountId                    =   catRecord.Account__c;
            caseObj.Enrolled_in_Entity_Portal__c =   False;
            caseObj.School_Program__c            =   catRecord.School_Program__c;
            caseObj.Attendance_Start_Date__c     =   catRecord.Start_Date__c;
            caseObj.Attendance_End_Date__c       =   catRecord.End_Date__c;
            caseObj.Attendance_Start_Month__c    =   catRecord.Start_Month__c;
            caseObj.Attendance_Start_Year__c     =   catRecord.Start_Year__c;
            caseObj.Attendance_End_Month__c      =   catRecord.End_Month__c;
            caseObj.Attendance_End_Year__c       =   catRecord.End_Year__c;
            caseObj.Graduation_Month__c          =   catRecord.Graduation_Month__c;
            caseObj.Graduation_Year__c           =   catRecord.Graduation_Year__c;
            caseObj.Degree_Date__c               =   catRecord.Degree_Issue_Date__c;
            caseObj.Degree_Month__c              =   catRecord.Degree_Issue_Month__c;
            caseObj.Degree_Year__c               =   catRecord.Degree_Issue_Year__c;
            caseObj.Number_of_Years_Attended__c  =   catRecord.Number_of_Years_Attended__c;
            caseObj.Unique_Medical_School__c     =   catRecord.Student_ID__c;
            INSERT caseObj;
            if(Case.SObjectType.getDescribe().isUpdateable()){
                caseObj.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
                UPDATE caseObj;
                epexCase.Enrollment_Verification_Parent__c = caseObj.Id;
                UPDATE epexCase;
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    public static void reUpdateEVCaseForEpex(List<Case> evCases){
        try{
            Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            List<Case> evCaseToUpdate = new List<Case>();
            for(Case evCase : [SELECT Id, Internal_Status__c, External_Status__c, Verification_Status__c, Status_Not_Reviewed_Date__c FROM Case WHERE Id IN :evCases AND RecordTypeId =:evRTId]){
                evCase.External_Status__c = Constants.CASE_EXTERNAL_STATUS_NOT_REVIEWED;
                evCase.Status_Not_Reviewed_Date__c = System.today();
                evCase.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
                evCase.Internal_Status__c = Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL;
                evCaseToUpdate.add(evCase);
            }
            if(!evCaseToUpdate.isEmpty()){
                UPDATE evCaseToUpdate;
            }
        }catch(Exception e){
            throw new ControllerException(e.getMessage());
        }
    }
    /**
	 * Created by Femi
	 * Method Name: manageSchedulingPermit
	 * Purpose : Method to send email and create asset with scheduling permit for EPEx cases
	 */
	@AuraEnabled
	public static void manageSchedulingPermit(String caseId) {

		case newCase = [Select id, Internal_Status__c, ContactId, contact.Name, contact.Email, recordType.DeveloperName, ECFMG_Portal_Case_Url__c, parentId from Case where Id =: caseId];

		Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		message.setTargetObjectId(newCase.ContactId);
		EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.CASE_EMAIL_TEMPLATE_NAME];
        message.setTemplateID(emailTemplate.Id);
        List<OrgWideEmailAddress> addr  = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        message.setOrgWideEmailAddressId(addr[0].Id);

		String htmlBody = emailTemplate.HtmlValue;
		htmlBody = htmlBody.replace('{!Case.Internal_Status__c}', newCase.Internal_Status__c);
		htmlBody = htmlBody.replace('{!Case.Contact}', newCase.contact.Name);
		htmlBody = htmlBody.replace('[Link]', '<a href="' + newCase.ECFMG_Portal_Case_Url__c + '">Case Status</a>');

		htmlBody = htmlBody.replaceAll('<!\\[CDATA\\[', '');
		htmlBody = htmlBody.replaceAll('\\]\\]>', '');

		message.setHtmlBody(htmlBody);

		StaticResource sr = [Select Name, Id, Body From StaticResource where Name = 'ExamPermit'];
		Blob tempBlob = sr.Body;
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setBody(tempBlob);
		efa.setFileName(Constants.ASSET_TYPE_SCHEDULING_PERMIT + '.pdf');
		message.setFileAttachments(new Messaging.EmailFileAttachment[] {
			efa
		});
		message.toAddresses = new String[] {
			newCase.contact.email
		};
		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage > {
			message
		};
		try {
			Messaging.sendEmail(messages);
		} catch (Exception e) {
			system.debug(e);
		}

		Asset permit = new Asset();
		permit.Name = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
		permit.ContactId = newCase.contact.Id;
		permit.Case__c = newCase.parentId;
		permit.type__c = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
		permit.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
		insert permit;

		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.PathOnClient = Constants.ASSET_TYPE_SCHEDULING_PERMIT + '.pdf';
		conVer.Title = Constants.ASSET_TYPE_SCHEDULING_PERMIT;
		conVer.VersionData = sr.Body;
		insert conVer;

		Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: conVer.Id].ContentDocumentId;
		ContentDocumentLink conDocLink = New ContentDocumentLink();
		conDocLink.LinkedEntityId = permit.Id;
		conDocLink.ContentDocumentId = conDoc;
        conDocLink.shareType = 'V';
        conDocLink.Visibility = 'AllUsers';
		insert conDocLink;

    }
    /* Wrapper class to store epex record data in epex form page
     */
    public class EpexWrapper{
        @auraenabled public Date epStartDate{
            get;
            set;
        }
        @auraenabled public Date epEndDate{
            get;
            set;
        }
        @auraenabled public string type{
            get;
            set;
        }
        @auraenabled public string caseId{
            get;
            set;
        }
        @auraenabled public Date extendedStartDate{
            get;
            set;
        }
        @auraenabled public Date extendedEndDate{
            get;
            set;
        }
        @auraenabled public Date deadline{
            get;
            set;
        }
        @auraenabled public boolean check{
            get;
            set;
        }
        public EpexWrapper(Date tempEpStartDate, Date tempEpEndDate, String tempType, String tempCase, Date tempExtendedStartDate, Date tempExtendedEndDate, Date tempDeadline, List<Case> epexCases){
            epStartDate = tempEpStartDate;
            epEndDate = tempEpEndDate;
            type = tempType;
            caseId = tempCase;
            extendedStartDate = tempExtendedStartDate;
            extendedEndDate = tempExtendedEndDate;
            deadline = tempDeadline;
            if(!epexCases.isEmpty()){
                check = true;
            }
        }
    }
    /**
	 * Created by Varsha Hariharan
	 * Method Name: extRequestOnBiographic
	 * Purpose : Method to validate on eligibility period extension request link based on Biographic Change request.
	 * Return Type : string
	 */
    @AuraEnabled(Cacheable = true)
    public static string extRequestOnBiographic(){
        Id currentContactId = AppForCertHelper.retrieveCurrentContactId();
        String returnVal = '';
        List<Case> casesList = new List<Case>();
        if(Case.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.Case.fields.Id.isAccessible() && Schema.SObjectType.Case.fields.Internal_Status__c.isAccessible()){
        casesList = [Select Id, Internal_Status__c from Case where ContactId =: currentContactId and RecordType.DeveloperName = 'Applicant_Biographic_Change'];
        if(casesList.size() > 0){
            returnVal = checkInternalStatus(casesList);
        }
        else{
            returnVal = 'true'; 
        }
    }
        return returnVal;
    }

    public static String checkInternalStatus(List<Case> casesList){
        Set<String> caseStatusVal = new Set<String>{Constants.CASE_STATUS_ACCEPTED, Constants.CASE_STATUS_REJECTED, Constants.CASE_STATUS_CANCELLED_BY_APPLICANT, Constants.CASE_STATUS_CANCELLED_BY_ECFMG};
        String returnValues;
        for(integer i = 0; i < casesList.size(); i++){
            if(caseStatusVal.contains(casesList[i].Internal_Status__c)){
                returnValues = 'true';
            }
            else{
                returnValues = Label.Biographic_Change_To_Be_Completed + '<br>';
                break;
            }
        }
        return returnValues;
    }
}