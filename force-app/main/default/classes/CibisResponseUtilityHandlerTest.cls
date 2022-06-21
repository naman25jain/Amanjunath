@isTest
public class CibisResponseUtilityHandlerTest extends ECFMGTestFactory {
	@TestSetup
    public static void setUp() {
    
        Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId();
        Id caseIdentityVerification = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Id eligibilityRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
     	Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts'));
        for(Integer i = 0; i < 2; i++) {
            Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        }
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        Case caseEligibility = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=eligibilityRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        Exam_Registration__c examRegistration = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Case__r = cas , Applicant__r=con));
        run();
    }

    @isTest
    static void testCibisDupCheckConResHandler() {
        Contact con = [select id from Contact limit 1];
        Case cas = [select id from Case limit 1];
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_OVER_ALL_MATCH_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        lstSerachEvents.add(returnEventInfo(strPayloadSuccess));
        publishEvent(lstSerachEvents);
    }
    

    @isTest
    static void testCibisExamHistoryConRespHandler() {
        Contact con = [select id from Contact limit 1];
        //String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_REG_HISTORY_EVENT-'+con.Id+'","payload":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}';
        String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_REG_HISTORY_EVENT-'+con.Id+'","payload":[{"Payload":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}]}';
        String strPayloadFail = '{"responseStatus":"FAILED","errorDescription":"","transactionId":"CIBIS_EXAM_REG_HISTORY_EVENT-'+con.Id+'","payload":[{"Payload":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(strPayloadSuccess));
        lstSerachEvents.add(returnEventInfo(strPayloadFail));
        publishEvent(lstSerachEvents);
    }
	//This test method testCibisCandidateConRespHandler is causing exception.. Check the record type commenting this for now.
    @isTest
    static void testCibisCandidateConRespHandler() {
        Contact con = [select id from Contact limit 1];
        Case cas = [select id from Case limit 1];
        String payload = '{ "responseStatus": "SUCCESS", "errorDescription":"","transactionId": "CIBIS_CANDIDATE_EVENT-'+cas.Id+'-'+con.Id+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." }}';
        String payloadError = '{ "responseStatus": "FAILED", "errorDescription":"","transactionId": "CIBIS_CANDIDATE_EVENT-'+cas.Id+'-'+con.Id+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." }}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }

    /*@isTest
    static void testCibisExamRegConRespHandler() {
        Case cas = [select id from Case limit 1];
        String payLoad = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_REGISTRATION_EVENT-'+cas.Id+'","payload":"{requestRecordId=1000000001101798, correlationId=null, applicationId=21}"}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }*/
    
    @isTest
    static void testCibisEpexConRespHandler() {
        Case cas = [select id from Case limit 1];
        String payload='{ "responseStatus": "SUCCESS", "errorDescription":"","transactionId": "CIBIS_ELIGIBILITY_EVENT-'+cas.Id+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." }}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisRegChangeConRespHandler() {
        List<Case> cases = [select id, ParentId, RecordTypeId from Case where RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_REGION_CHANGE and Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS];
        List<Case> parentCases = [select id, ParentId, RecordTypeId from Case where RecordType.DeveloperName!=:Constants.CASE_RECORD_TYPE_REGION_CHANGE];
        System.debug('cases size '+cases.size());
        System.debug('parentCases size '+parentCases.size());
        Case updateParentIdCase = new Case();
        for(Case eachCase: cases){
            /*if(eachCase.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId()){
                //updateParentIdCase.Id = eachCase.Id;
                updateParentIdCase.ParentId = eachCase.Id;
            } else if(eachCase.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_REGION_CHANGE).getRecordTypeId()){
                //updateParentIdCase.ParentId = eachCase.Id;
                updateParentIdCase.Id = eachCase.Id;
            }*/
            updateParentIdCase.Id = eachCase.Id;
        }
        for(Case eachParenCase: parentCases){
            updateParentIdCase.ParentId = eachParenCase.Id;
        }
        System.debug('updateParentIdCase '+updateParentIdCase);
        update updateParentIdCase;
        
        //List<Case> casesList = [Select Id,Internal_Status__c,parentId from Case where RecordType.DeveloperName=:Constants.CASE_RECORD_TYPE_REGION_CHANGE and Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS and Id IN:caseIds AND ParentID <> null];
        //System.debug('casesList '+casesList);
        String payload='{ "responseStatus": "SUCCESS", "errorDescription":"","transactionId": "CIBIS_EXAM_EVENT-'+updateParentIdCase.ParentId+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." },"regionPayload":{"CorrelationID":"re123","status":"Success"}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        
        String payloadError='{ "responseStatus": "ERROR", "errorDescription":"","transactionId": "CIBIS_EXAM_EVENT-'+updateParentIdCase.ParentId+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." },"regionPayload":{"CorrelationID":"re123","status":"Success"}}';
        lstSerachEvents.add(returnEventInfo(payloadError));
        
        publishEvent(lstSerachEvents);
    }

    public static Cibis_Entity_Search_Response_Event__e returnEventInfo(String strPayLoad) {
        Cibis_Entity_Search_Response_Event__e evtSuccess = new Cibis_Entity_Search_Response_Event__e();
        evtSuccess.Date_Time__c = Datetime.now();
        evtSuccess.Error_Description__c = 'Error occured';
        evtSuccess.Exception__c = 'Fatal Error';
        evtSuccess.Source__c = 'CIBIS';
        evtSuccess.Payload__c = strPayLoad;
        return evtSuccess;
    }

    public static void publishEvent(list<Cibis_Entity_Search_Response_Event__e> lstEvents) {
        if(lstEvents != null && !lstEvents.isEmpty()) {
            Test.startTest();
            Database.SaveResult[] sr = EventBus.publish(lstEvents);
            Test.stopTest();
        }
    }
    
    @isTest
    static void CibisFSMBConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payload= '{"responseStatus":"SUCCESS","errorDescription":{},"transactionId":"CIBIS_FSMB_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        String payload = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_FSMB_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"05596283","lastName":"Aladesawe","restOfName":"Akinwumi Gammal","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1964-09-02","deceasedFlag":"N","schoolId":"690007","SSN":"000000000","graduationYear":"1991","graduationMonth":"01","graduationVerifiedFlag":"N","internetAddress":"aaladesawe@yahoo.com","SSNLast4Digit":"0000"}],"FSMBInfo":[{"USMLEId":"05596283","fsmb_id":null,"FSMBBoardActionFlag":"Y","FSMBFlexHistoryFlag":"N","FSMBAlertNote":null,"lastUpdateDate":"2011-09-15T00:15:18","initialCreateDate":null}]}}';
        String payloadError = '{"responseStatus":"ERROR","errorDescription":"","transactionId":"CIBIS_NBME_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"05596283","lastName":"Aladesawe","restOfName":"Akinwumi Gammal","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1964-09-02","deceasedFlag":"N","schoolId":"690007","SSN":"000000000","graduationYear":"1991","graduationMonth":"01","graduationVerifiedFlag":"N","internetAddress":"aaladesawe@yahoo.com","SSNLast4Digit":"0000"}],"NBMEInfo":[{"USMLEId":"05596283","NBMEId":null,"NBMEPartHistoryFlag":"N","NBMEAlertNote":null,"NBMETranscriptType":"U","verifiedGraduationYear":null,"verifiedGraduationMonth":null,"lastUpdateDate":null,"initialCreateDate":null}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisNBMEConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payload= '{"responseStatus":"SUCCESS","errorDescription":{},"transactionId":"CIBIS_NBME_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        String payload = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_NBME_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"05596283","lastName":"Aladesawe","restOfName":"Akinwumi Gammal","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1964-09-02","deceasedFlag":"N","schoolId":"690007","SSN":"000000000","graduationYear":"1991","graduationMonth":"01","graduationVerifiedFlag":"N","internetAddress":"aaladesawe@yahoo.com","SSNLast4Digit":"0000"}],"NBMEInfo":[{"USMLEId":"05596283","NBMEId":null,"NBMEPartHistoryFlag":"N","NBMEAlertNote":null,"NBMETranscriptType":"U","verifiedGraduationYear":null,"verifiedGraduationMonth":null,"lastUpdateDate":null,"initialCreateDate":null}]}}';
        String payloadError = '{"responseStatus":"ERROR","errorDescription":"","transactionId":"CIBIS_NBME_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"05596283","lastName":"Aladesawe","restOfName":"Akinwumi Gammal","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1964-09-02","deceasedFlag":"N","schoolId":"690007","SSN":"000000000","graduationYear":"1991","graduationMonth":"01","graduationVerifiedFlag":"N","internetAddress":"aaladesawe@yahoo.com","SSNLast4Digit":"0000"}],"NBMEInfo":[{"USMLEId":"05596283","NBMEId":null,"NBMEPartHistoryFlag":"N","NBMEAlertNote":null,"NBMETranscriptType":"U","verifiedGraduationYear":null,"verifiedGraduationMonth":null,"lastUpdateDate":null,"initialCreateDate":null}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisECFMGConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payload= '{"responseStatus":"SUCCESS","errorDescription":{},"transactionId":"CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        String payload = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"50564780","lastName":"Hirt","restOfName":"Thomas Westendorf","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1976-02-01","deceasedFlag":"N","schoolId":"036020","SSN":"300823225","graduationYear":"2001","graduationMonth":"06","graduationVerifiedFlag":"Y","internetAddress":"hirttw@eudoramail.com","SSNLast4Digit":"3225"}],"ECFMGInfo":[{"USMLEId":"50564780","ecfmg_id":null,"Description":"N","Explanation":null,"ECFMGCertificationStatus":"?","ECFMGCertificationStatusDate":null,"lastUpdatedAt":"1998-12-10T16:30:16","initialCreatedAt":"1998-12-10T16:30:16","lastCSEResultCode":"N","lastCSAExamDate":null}]}}';
        String payloadError = '{"responseStatus":"ERROR","errorDescription":"","transactionId":"CIBIS_ECFMG_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"biographic":[{"USMLEId":"50564780","lastName":"Hirt","restOfName":"Thomas Westendorf","firstName":null,"middleName":null,"generationSuffix":null,"gender":"Male","deceasedDate":"","birthDate":"1976-02-01","deceasedFlag":"N","schoolId":"036020","SSN":"300823225","graduationYear":"2001","graduationMonth":"06","graduationVerifiedFlag":"Y","internetAddress":"hirttw@eudoramail.com","SSNLast4Digit":"3225"}],"ECFMGInfo":[{"USMLEId":"50564780","ecfmg_id":null,"Description":"N","Explanation":null,"ECFMGCertificationStatus":"?","ECFMGCertificationStatusDate":null,"lastUpdatedAt":"1998-12-10T16:30:16","initialCreatedAt":"1998-12-10T16:30:16","lastCSEResultCode":"N","lastCSAExamDate":null}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisUSMLEConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payload= '{"responseStatus":"SUCCESS","errorDescription":{},"transactionId":"CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        String payload = '{ "responseStatus": "SUCCESS", "errorDescription": "", "transactionId": "CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'", "payload": { "biographic": [ { "USMLEId": "50564780", "lastName": "Hirt", "restOfName": "Thomas Westendorf", "firstName": null, "middleName": null, "generationSuffix": null, "gender": "Male", "deceasedDate": "", "birthDate": "1976-02-01", "deceasedFlag": "N", "schoolId": "036020", "SSN": "300823225", "graduationYear": "2001", "graduationMonth": "06", "graduationVerifiedFlag": "Y", "internetAddress": "hirttw@eudoramail.com", "SSNLast4Digit": "3225" } ], "USMLEInfo": [ { "USMLEId": "50564780", "step1Attempts": 1, "step1PassDate": "1999-06-14T08:28:00", "step2Attempts": 1, "step2PassDate": "2000-10-07T08:33:00", "step3Attempts": 1, "step3PassDate": "2003-04-18T08:24:00", "registrationAttentionFlag": "N", "usmleStopFlag": "N", "usmleAlertNote": null, "withholdResearchFlag": "N", "lastUpdateDate": "2003-05-12T08:48:58", "initialCreateDate": "1998-12-10T16:30:16", "nonAdminIrregularity_status": "N", "step1EligibleDate": null, "step2EligibleDate": null, "step3EligibleDate": null, "secretariatDocument": "50564780.pdf", "step2csAttempts": 0, "step2csPassDate": null, "step2csEligibleDate": "2004-06-14T00:00:00", "AAMCId": 10714529 } ] }}'; 
        String payloadError = '{ "responseStatus": "ERROR", "errorDescription": "", "transactionId": "CIBIS_USMLE_TRANSCRIPT_NOTES_EVENT-'+con.Id+'-'+cas.Id+'", "payload": { "biographic": [ { "USMLEId": "50564780", "lastName": "Hirt", "restOfName": "Thomas Westendorf", "firstName": null, "middleName": null, "generationSuffix": null, "gender": "Male", "deceasedDate": "", "birthDate": "1976-02-01", "deceasedFlag": "N", "schoolId": "036020", "SSN": "300823225", "graduationYear": "2001", "graduationMonth": "06", "graduationVerifiedFlag": "Y", "internetAddress": "hirttw@eudoramail.com", "SSNLast4Digit": "3225" } ], "USMLEInfo": [ { "USMLEId": "50564780", "step1Attempts": 1, "step1PassDate": "1999-06-14T08:28:00", "step2Attempts": 1, "step2PassDate": "2000-10-07T08:33:00", "step3Attempts": 1, "step3PassDate": "2003-04-18T08:24:00", "registrationAttentionFlag": "N", "usmleStopFlag": "N", "usmleAlertNote": null, "withholdResearchFlag": "N", "lastUpdateDate": "2003-05-12T08:48:58", "initialCreateDate": "1998-12-10T16:30:16", "nonAdminIrregularity_status": "N", "step1EligibleDate": null, "step2EligibleDate": null, "step3EligibleDate": null, "secretariatDocument": "50564780.pdf", "step2csAttempts": 0, "step2csPassDate": null, "step2csEligibleDate": "2004-06-14T00:00:00", "AAMCId": 10714529 } ] }}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisExamRegConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payload= '{"responseStatus":"SUCCESS","errorDescription":{},"transactionId":"CIBIS_REGISTRATION_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"USMLEId":"07789985","sourceGenerationSuffix":null,"birthMonth":"06","gender":"M","lastName":"RAJ","overallMatch":65,"SSN":"000000000","birthYear":"1988","medicalSchoolCode":"014030","birthDay":"12","sourceLastName":"Bhanvadia","requestId":2769150,"firstName":"RAMNIK","sourceRestOfName":"Raj Ramnik"}]}';
        //String payload = '{ "responseStatus": "SUCCESS", "errorDescription": {  },requestRecordId": "123", "correlationId": "948", "applicationId": "123", "transactionId": "CIBIS_REGISTRATION_EVENT-'+con.Id+'-'+cas.Id+'", "payload": { "exams": [ { "USMLEId": "00166504", "exam": "STEP1", "applicationId": 2, "lastName": "Kwon", "restOfName": "Myung Sook", "firstName": null, "middleName": null, "generationSuffix": null, "reportName": "Kwon,Myung Sook", "gender": "Unknown", "birthDate": "03/04/1929", "SSN": "000000000", "address1": "P.O. Box 75855", "address2": "Oklahoma City, OK 73147", "address3": null, "address4": null, "city": null, "state": null, "zip": "73147", "countryId": null, "ethnics": "07", "citizenshipCountryId": "969", "englishNativeFlag": "N", "dominateHand": "?", "assignedCenterId": "900134", "assignedFacilityId": null, "regionId": null, "scoreReportDate": "1995-11-08", "initialCreateDate": null, "lastUpdateDate": "2021-01-11T16:21:37", "daytimePhone": null, "internetAddress": null, "requestedLocationId": null, "requestedExamMonth": null, "lastEligUpdateDate": null, "SSNLast4Digit": "0000", "testAccommodationFlag": "N", "scoreAnnotationFlag": "N", "specialAdministration": null, "irregularBehavior": [  ] }, { "USMLEId": "00166504", "exam": "STEP2", "applicationId": 2, "lastName": "Kwon", "restOfName": "Myung Sook", "firstName": null, "middleName": null, "generationSuffix": null, "reportName": "Kwon,Myung Sook", "gender": "Unknown", "birthDate": "03/04/1929", "SSN": "000000000", "address1": "P.O. Box 75855", "address2": "Oklahoma City, OK 73147", "address3": null, "address4": null, "city": null, "state": null, "zip": "73147", "countryId": null, "ethnics": "07", "citizenshipCountryId": "969", "englishNativeFlag": "N", "dominateHand": "?", "assignedCenterId": "900134", "assignedFacilityId": null, "regionId": null, "scoreReportDate": "1994-10-12", "initialCreateDate": null, "lastUpdateDate": "2021-01-11T16:22:38", "daytimePhone": null, "internetAddress": null, "requestedLocationId": null, "requestedExamMonth": null, "lastEligUpdateDate": null, "SSNLast4Digit": "0000", "testAccommodationFlag": "N", "scoreAnnotationFlag": "N", "specialAdministration": null, "irregularBehavior": [ { "USMLEID": "00166504", "applicationId": 2, "irregularBehavior": 2, "description": "Procedural Violation", "explanation": "Failing to adhere to any USMLE procedure or rule, including instructions of the test center staff. Making notes except on surfaces provided. Unauthorized items, equipment or material in the test area. Timing violation. Unscheduled breaks." } ] } ] }}';
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_REGISTRATION_EVENT-'+cas.Id+'-'+con.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        //String payloadError = '{"responseStatus": "ERROR","errorDescription": {},"transactionId":"CIBIS_REGISTRATION_EVENT-'+cas.Id+'-'+con.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        //lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisExamRegConRespHandlerError(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payloadError = '{"responseStatus": "ERROR","errorDescription": "","transactionId":"CIBIS_REGISTRATION_EVENT-'+cas.Id+'-'+con.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisCandIrregularConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        //String payloadError = '{"responseStatus": "SUCCESS","errorDescription": {},"transactionId":"CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","IrregularBehavior":[{"USMLEId":"123","IrregularBehavior":"9","Description":"Test","Explanation":"Explain Test"}],"examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        String payloadError = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"nonAdminIrregularityStatus":"P","FSMBBoardActionFlag":"Y","ECFMGPartHistory":"Y","FSMBFlexHistoryFlag":"Y","NBMEPartHistoryFlag":"Y","USMLEId":"123","IrregularBehavior":[{"FSMBBoardActionFlag":"Y","ECFMGPartHistory":"Y","FSMBFlexHistoryFlag":"Y","NBMEPartHistoryFlag":"Y","USMLEId":"123","IrregularBehavior":"9","Description":"Test","Explanation":"Explain Test"}],"examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisCandIrregularConRespHandlerError(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payloadError = '{"responseStatus": "ERROR","errorDescription": "","transactionId":"CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptEligibilityConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21},"payload":[{"agencyCode":"N","examType":"STEP 3"}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptEligibilityConRespHandlerDiffAgencyCode(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21},"payload":[{"agencyCode":"Y","examType":"STEP3"}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptEligibilityConRespHandlerBlankPayload(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21},"payload":[]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptEligibilityConRespHandlerDiffExamType(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","examPayload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21},"payload":[{"agencyCode":"Y","examType":"STEP1"}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptsNotesConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        Exam_Registration__c exam = [SELECT Id, Case__c FROM Exam_Registration__c LIMIT 1];
        exam.Case__c = cas.Id;
        update exam;
        System.debug('exam '+exam);
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_NOTES_REQUEST_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"USMLEId":"123", "NBMEPartHistoryFlag":"", "requestRecordId":1000000001101798, "correlationId":null, "applicationId":21}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
        Map<String, String> mapData = new Map<String, String>();
        mapData.put(cas.Id, '21');
        CibisUtility.constructExamRegExternalId(mapData);
    }
    
    @isTest
    static void CibisSecrDocURLConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_SECR_DOCURL_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21, "SecretariatDocumentInfoWithURL": [{"USMLEId":"123", "secretariatDocumentImageBLOB": "Blob", "updatedBy": "CIBIS User", "createdBy" : "CIBIS Test", "updatedAt": "2011-01-10T00:00:00.000Z"}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisExamIrregularConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21, "SecretariatDocumentInfoWithURL": [{"USMLEId":"123", "secretariatDocumentImageBLOB": "Blob", "updatedBy": "CIBIS User", "createdBy" : "CIBIS Test", "updatedAt": "2011-01-10T00:00:00.000Z"}]}}';
        //String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"exams":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}}';
        String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"exam":"USMLE Step 1","SFExamRegExternalId":"10459121-23-STEP2","actualStartDate":"'+Date.today()+'","irregularBehavior":[{"USMLEID":"1234","applicationId":123,"irregularBehavior":4}],"Payload":{"SFExamRegExternalId":"10459121-23-STEP2","USMLEId":"07789985","applicationId":21,"exam":"USMLE Step 1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":"7000000000036138"}}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(strPayloadSuccess));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisExamIrregularConRespHandlerError(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "ERROR","errorDescription": "","transactionId":"CIBIS_EXAM_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21, "SecretariatDocumentInfoWithURL": [{"USMLEId":"123", "secretariatDocumentImageBLOB": "Blob", "updatedBy": "CIBIS User", "createdBy" : "CIBIS Test", "updatedAt": "2011-01-10T00:00:00.000Z"}]}}';
        String strPayloadError = '{"responseStatus":"FAILED","errorDescription":"","transactionId":"CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT-'+cas.Id+'-'+con.Id+'","payload":{"exams":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(strPayloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisSecrDocInfoConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_SECR_DOCINFO_EVENT-'+cas.Id+'-'+con.Id+'","Payload":{"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21, "SecretariatDocumentInfo": [{"USMLEId":"123", "secretariatDocumentImageBLOB": "Blob", "updatedBy": "CIBIS User", "createdBy" : "CIBIS Test", "updatedAt": "2011-01-10T00:00:00.000Z"}]}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisEpexEvaluationConRespHandler(){
        Case cas = [select id from Case limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_EVALUATION_EVENT-'+cas.Id+'","Payload":{"candidateExistsinCibis":"N", "otherOpenRegistration":"N","candidateExistInCIBIS":"Y","covertValue":"Y","currentExamHasOpenRegistration":"Y", "pushToCovert":"Yes","outcomeRecievedValue":"Y"}}';
        String payloadCandidateDoesnotExist = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_EVALUATION_EVENT-'+cas.Id+'","Payload":{"candidateExistsinCibis":"Y", "otherOpenRegistration":"N", "covertValue":"Y","outcomeRecievedValue":"N","currentExamHasOpenRegistration":"Y"}}';
        String payloadPushToConvertN = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_EVALUATION_EVENT-'+cas.Id+'","Payload":{"candidateExistsinCibis":"Y", "otherOpenRegistration":"N", "covertValue":"N","currentExamHasOpenRegistration":"Y"}}';
        String payloadError = '{"responseStatus": "FAILED","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_EVALUATION_EVENT-'+cas.Id+'","Payload":{"candidateExistsinCibis":"Y", "otherOpenRegistration":"N", "covertValue":"Y","currentExamHasOpenRegistration":"Y"}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadCandidateDoesnotExist));
        lstSerachEvents.add(returnEventInfo(payloadPushToConvertN));
        lstSerachEvents.add(returnEventInfo(payloadError));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisEpexEligRevisionConRespHandler(){
        Case cas = [select id from Case WHERE RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_REVISION_EVENT-'+cas.Id+'","Payload":{"correlationId":"123", "message":"Success"}}';
        String payloadFail = '{"responseStatus": "FAILED","errorDescription": "","transactionId":"CIBIS_ELIGIBILITY_REVISION_EVENT-'+cas.Id+'","Payload":{"correlationId":"123", "message":"Success"}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadFail));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisEpexScheduleLimitConRespHandler(){
        Case cas = [select id from Case WHERE RecordType.DeveloperName =: Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_SCHEDULE_LIMIT_EVENT-'+cas.Id+'","Payload":{"correlationId":"123", "message":"Success"}}';
        String payloadFail = '{"responseStatus": "FAILED","errorDescription": "","transactionId":"CIBIS_SCHEDULE_LIMIT_EVENT-'+cas.Id+'","Payload":{"correlationId":"123", "message":"Success"}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadFail));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisScoreReportConRespHandler(){
        Case cas = [select id from Case limit 1];
        Contact con = [select id from Contact limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": {},"transactionId":"CIBIS_SCORE_EVENT-'+cas.Id+'-'+con.Id+'","CIBISScoringInfo":{},"Payload":{"CIBISScoringInfo":[{"actualStartDateExamDate":"'+Date.today()+'","indeterminateFlag":"Y","SFExamRegExternalId":"10459121-23-STEP2","exam":"USMLE Step 1"}],"requestRecordId":1000000001101798, "correlationId":null, "applicationId":21, "SecretariatDocumentInfoWithURL": [{"USMLEId":"123", "secretariatDocumentImageBLOB": "Blob", "updatedBy": "CIBIS User", "createdBy" : "CIBIS Test", "updatedAt": "2011-01-10T00:00:00.000Z"}]}}';
        //String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT-'+con.Id+'-'+cas.Id+'","payload":{"exams":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}}';
        //String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT-'+con.Id+'-'+cas.Id+'","payload":[{"exam":"USMLE Step 1","SFExamRegExternalId":"10459121-23-STEP2","actualStartDate":"'+Date.today()+'","Payload":{"SFExamRegExternalId":"10459121-23-STEP2","USMLEId":"07789985","applicationId":21,"exam":"USMLE Step 1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":"7000000000036138"}}]}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        //lstSerachEvents.add(returnEventInfo(strPayloadSuccess));
        publishEvent(lstSerachEvents);
    }
    
    @isTest
    static void CibisTranscriptEligConRespHandler(){
        Contact con = [select id from Contact limit 1];
        Case cas = [select id from Case limit 1];
        String payload = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","Payload":{"IsNBMEMostRecentlyRegistered":"N", "STEP3Exist":"N", "SecretariatDocumentUpdateDTime":"'+DateTime.now()+'"}}';
        String payloadPostCheck = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","Payload":{"IsNBMEMostRecentlyRegistered":"N", "STEP3Exist":"N", "SecretariatDocumentUpdateDTime":"'+DateTime.now()+'"}}';
        String payloadPostCheckWithNoDate = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","Payload":{"IsNBMEMostRecentlyRegistered":"N", "STEP3Exist":"N"}}';
        String payloadExistingUser = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","Payload":{"IsNBMEMostRecentlyRegistered":"Y", "STEP3Exist":"Y", "SecretariatDocumentUpdateDTime":"'+DateTime.now()+'"}}';
        String payloadExistingUserPostCheck = '{"responseStatus": "SUCCESS","errorDescription": "","transactionId":"CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT-'+con.Id+'-'+cas.Id+'","Payload":{"IsNBMEMostRecentlyRegistered":"Y", "STEP3Exist":"Y", "SecretariatDocumentUpdateDTime":"'+DateTime.now()+'"}}';
        list<Cibis_Entity_Search_Response_Event__e> lstSerachEvents = new list<Cibis_Entity_Search_Response_Event__e>();
        lstSerachEvents.add(returnEventInfo(payload));
        lstSerachEvents.add(returnEventInfo(payloadPostCheck));
        lstSerachEvents.add(returnEventInfo(payloadPostCheckWithNoDate));
        lstSerachEvents.add(returnEventInfo(payloadExistingUser));
        lstSerachEvents.add(returnEventInfo(payloadExistingUserPostCheck));
        publishEvent(lstSerachEvents);
        Map<Id,Date> conSecrMap=new Map<Id,Date>();
        Map<Id,Id> conCaseId=new Map<Id,Id>();
        conSecrMap.put(con.Id, Date.today());
        conCaseId.put(con.Id, cas.Id);
        CibisTranscriptEligConRespHandler.checkSecrDocumentUpdatedDate(conSecrMap,conCaseId);
    }
    
    @isTest
    static void invokeWrapperClasses(){
        Contact con = [select id from Contact limit 1];
        Case cas = [select id from Case limit 1];
        
        //CibisExamHistoryResponseEventWrap
        /*String strPayloadSuccess = '{"responseStatus":"SUCCESS","errorDescription":"","transactionId":"CIBIS_EXAM_REG_HISTORY_EVENT-'+con.Id+'","payload":[{"Payload":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}]}';
        String strPayloadFail = '{"responseStatus":"FAILED","errorDescription":"","transactionId":"CIBIS_EXAM_REG_HISTORY_EVENT-'+con.Id+'","payload":[{"Payload":[{"USMLEId":"07789985","applicationId":21,"examType":"STEP1","agencyCode":"N","schoolId":"036020","schoolStartDate":"1997-08-01","schoolEndDate":"2001-06-01","medicalSpecialtyId":null,"hospitalId":null,"residencyType":null,"residencyStartDate":"","residencyEndDate":"","originalUSMLEId":"07789985","initialCreateDate":"1999-03-29T18:16:29","lastUpdateDate":"2021-01-11","requestRecordId":7000000000036138}]}]}';
        CibisExamHistoryResponseEventWrap.parse(strPayloadSuccess);
        CibisExamHistoryResponseEventWrap.parse(strPayloadFail);*/
        
        //CibisCandidateResponseEventWrap
        /*String payload = '{ "responseStatus": "SUCCESS", "errorDescription":"","transactionId": "CIBIS_CANDIDATE_EVENT-'+cas.Id+'-'+con.Id+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." }}';
        String payloadError = '{ "responseStatus": "FAILED", "errorDescription":"Test","transactionId": "CIBIS_CANDIDATE_EVENT-'+cas.Id+'-'+con.Id+'", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." }}';
        CibisCandidateResponseEventWrap.parse(payload);
        CibisCandidateResponseEventWrap.parse(payloadError);*/
        
        CibisCandidateResponseEventWrap wrapper = new CibisCandidateResponseEventWrap();
        CibisCandidateResponseEventWrap.Payload wrapperp = new CibisCandidateResponseEventWrap.Payload();
        wrapper.errorDescription = 'Test';
       	wrapper.payload = wrapperp;
        wrapperp.correlationId = '234';
        wrapperp.message = 'TEst';
        
        //CibisRegChangeResponseEventWrap
        //String payloadReg='{ "responseStatus": "SUCCESS", "errorDescription":"","transactionId": "CIBIS_EXAM_EVENT-123", "payload": {"correlationId": "a54b85f0-fc77-11eb-bbda-06aae33fee84", "message": "Successfully updated new el application information." },"regionPayload":{"CorrelationID":"re123","status":"Success"}}';
        CibisRegChangeResponseEventWrap wrapper1 = new CibisRegChangeResponseEventWrap();
        wrapper1.errorDescription = 'Error';
        wrapper1.transactionId = '123';
        CibisRegChangeResponseEventWrap.regionPayload regPayLoad = new CibisRegChangeResponseEventWrap.regionPayload();
        regPayLoad.CorrelationID = '123';
        regPayLoad.status = 'Error';
        wrapper1.regionPayload = regPayLoad;
        //CibisRegChangeResponseEventWrap.parse(payloadReg);
        //
        
        //CibisExamRegResponseEventWrap
        CibisExamRegResponseEventWrap examWrapper = new CibisExamRegResponseEventWrap();
        examWrapper.errorDescription = 'Error';
        examWrapper.responseStatus = 'Success';
        examWrapper.transactionId = '123';
        CibisExamRegResponseEventWrap.Payload payloadExam = new CibisExamRegResponseEventWrap.Payload();
        payloadExam.applicationId = '123';
        payloadExam.correlationId = '345';
        payloadExam.requestRecordId = '123';
        examWrapper.Payload = payloadExam;
        
        //CibisEpexEvaluationResponseEventWrap
        CibisEpexEvaluationResponseEventWrap evalEventWrapper = new CibisEpexEvaluationResponseEventWrap();
        evalEventWrapper.errorDescription = 'Error';
        evalEventWrapper.responseStatus = 'Success';
        evalEventWrapper.transactionId = '123';
        CibisEpexEvaluationResponseEventWrap.Payload payloadWrapper = new CibisEpexEvaluationResponseEventWrap.Payload();
        payloadWrapper.candidateExistInCIBIS = '123';
        payloadWrapper.covertValue = '123';
        payloadWrapper.currentExamHasOpenRegistration = 'N';
        payloadWrapper.otherOpenRegistration = 'Y';
        payloadWrapper.outcomeRecievedValue = 'N';
        evalEventWrapper.Payload = payloadWrapper;
        
        //CibisEpexEligRevisionResponseEventWrap
        CibisEpexEligRevisionResponseEventWrap eligWrapper = new CibisEpexEligRevisionResponseEventWrap();
        eligWrapper.responseStatus = 'Success';
        eligWrapper.errorDescription = 'Error';
        eligWrapper.transactionId = '123';
        CibisEpexEligRevisionResponseEventWrap.epexResPayload payloadEval = new CibisEpexEligRevisionResponseEventWrap.epexResPayload();
        payloadEval.correlationId = '123';
        payloadEval.message = 'Success';
        eligWrapper.payload = payloadEval;
        
        //CibisEpexScheduleLimitResponseEventWrap
        CibisEpexScheduleLimitResponseEventWrap epexScheduleWrapper = new CibisEpexScheduleLimitResponseEventWrap();
        epexScheduleWrapper.responseStatus = 'Success';
        epexScheduleWrapper.errorDescription = 'Error';
        epexScheduleWrapper.transactionId = '123';
        CibisEpexScheduleLimitResponseEventWrap.epexResPayload epxResPayload = new CibisEpexScheduleLimitResponseEventWrap.epexResPayload();
        epxResPayload.correlationId = '123';
        epxResPayload.message = 'Success';
        epexScheduleWrapper.payload = epxResPayload;
        
        //CibisTranscriptEligResponseEventWrap
        CibisTranscriptEligResponseEventWrap transWrapper = new CibisTranscriptEligResponseEventWrap();
        transWrapper.errorDescription = 'Error';
        transWrapper.responseStatus = 'Success';
        transWrapper.transactionId = '123';
        CibisTranscriptEligResponseEventWrap.Payload transPayloadWrapper = new CibisTranscriptEligResponseEventWrap.Payload();
        transPayloadWrapper.IsNBMEMostRecentlyRegistered = 'N';
        transPayloadWrapper.SecretariatDocumentUpdateDTime = 'Y';
        transPayloadWrapper.STEP3Exist = 'N';
        transWrapper.payload = transPayloadWrapper;
    }
}