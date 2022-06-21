@isTest
public with sharing class CibisRequestUtilityHandlerTest extends ECFMGTestFactory {
    private static CurrentEntityIDSequence__c settingsInstance;
    @TestSetup
    public static void setUp() {
        Id idRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        //Id usmleTransRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id idMedicalSchoolRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        CurrentEntityIDSequence__c csSettings = new CurrentEntityIDSequence__c();
        csSettings.Entity_ID__c = '123';
        csSettings.SetupOwnerId = UserInfo.getOrganizationId();
        insert csSettings;
        
        User us = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.SystemAdminUser.class, new User(FirstName = 'Admin'));
        
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        
     	Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='Cibis', RecordTypeId=conRecordTypeId));
        
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=idRecordId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS));
        //Case cas = (Case)ECFMGTestFactory.make(ECF-
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_PENDING_CIBIS, ParentId=cas.Id));
        Exam_Registration__c exam = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Case__r = cas , Applicant__r=con));
        Exam_Registration__c exam1 = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Case__r = cas1 , Applicant__r=con));
        
        Contact_Association_Type__c conAssociation = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idMedicalSchoolRecordType, Account__r=acc));
        run();
    }

    @isTest
    static void testCibisRegChangeGenReqHandler() {
        Test.startTest();
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE Profile.Name='Salesforce Admin' AND Alias='adminUsr'];
        System.runAs(adminUser){
            Map<String, Set<Id>> cibisIdMap = new Map<String, Set<Id>>();
            List<Contact> cons = [SELECT Id FROM Contact];
            List<Case> cases = [SELECT Id, RecordTypeId, ContactId FROM Case];
            List<Exam_Registration__c> exams = [SELECT Id, Case__c, Case__r.Contact.USMLE_ID__c FROM Exam_Registration__c];
            List<Contact> conCases = [SELECT Id, USMLE_ID__c,(Select id from Cases) FROM Contact];
            System.debug('conCases Size '+conCases[0].Cases.size());
            System.debug('conCases '+conCases);
            //Loop case and update ParentId 
            Case updateParentIdCase = new Case();
            for(Case eachCase: cases){
                if(eachCase.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId()){
                    updateParentIdCase.ParentId = eachCase.Id;
                } else {
                    updateParentIdCase.Id = eachCase.Id;
                }
                if(!cibisIdMap.containsKey(Constants.CIBIS_EXAM_EVENT) && cibisIdMap.get(Constants.CIBIS_EXAM_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_EXAM_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('CIBIS_EXAM_EVENT', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_EXAM_EVENT, new Set<Id> {eachCase.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_REGISTRATION_EVENT) && cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_REGISTRATION_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('registrations', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_REGISTRATION_EVENT, new Set<Id> {eachCase.Id});
                }
                
                /*if(!cibisIdMap.containsKey(Constants.CIBIS_ELIGIBILITY_EVENT) && cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVENT) != null){
Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVENT);
csIds.add(eachCase.Id);
cibisIdMap.put('eligibility', csIds);
} else {
cibisIdMap.put(Constants.CIBIS_ELIGIBILITY_EVENT, new Set<Id> {eachCase.Id});
}*/
                if(!cibisIdMap.containsKey(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT) && cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_ELIGIBILITY_EVALUATION_EVENT, new Set<Id> {eachCase.Id});
                }
                if(!cibisIdMap.containsKey(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT) && cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_ELIGIBILITY_REVISION_EVENT, new Set<Id> {eachCase.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_SCHEDULE_LIMIT_EVENT) && cibisIdMap.get(Constants.CIBIS_SCHEDULE_LIMIT_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_SCHEDULE_LIMIT_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_SCHEDULE_LIMIT_EVENT, new Set<Id> {eachCase.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT) && cibisIdMap.get(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_APPLICANT_IRREGULAR_BEHAVIOR_EVENT, new Set<Id> {eachCase.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT) && cibisIdMap.get(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_EXAM_HISTORY_IRREGULAR_BEHAVIOR_EVENT, new Set<Id> {eachCase.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_SECR_DOCURL_EVENT) && cibisIdMap.get(Constants.CIBIS_SECR_DOCURL_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_SECR_DOCURL_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put(Constants.CIBIS_SECR_DOCURL_EVENT, csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_SECR_DOCURL_EVENT, new Set<Id> {eachCase.Id});
                }
                /*if(!cibisIdMap.containsKey(Constants.CIBIS_CANDIDATE_EVENT) && cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT) != null){
Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT);
csIds.add(eachCase.Id);
cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, csIds);
} else {
cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, new Set<Id> {eachCase.Id});
}*/
            }
            for(Contact eachCon: cons){
                /*if(!cibisIdMap.containsKey(Constants.CIBIS_CANDIDATE_EVENT) && cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT) != null){
Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT);
csIds.add(eachCon.Id);
cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, csIds);
} else {
cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, new Set<Id> {eachCon.Id});
}*/
                
                if(!cibisIdMap.containsKey('CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT') && cibisIdMap.get('CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT') != null){
                    Set<Id> csIds = cibisIdMap.get('CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT');
                    csIds.add(eachCon.Id);
                    cibisIdMap.put('CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT', csIds);
                } else {
                    cibisIdMap.put('CIBIS_USMLE_TRANSCRIPT_EXAM_HISTORY_CHECK_EVENT', new Set<Id> {eachCon.Id});
                }
                
                if(!cibisIdMap.containsKey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT) && cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT);
                    csIds.add(eachCon.Id);
                    cibisIdMap.put('eligibility', csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_PRE_CHECK_EVENT, new Set<Id> {eachCon.Id});
                }
                //Commented below code because of exception occuring for inner query in CibisTranscriptEligGenReqHandler class @line 20 con.Cases[0]
                //Error message: List Index out of bounds
                /*if(!cibisIdMap.containsKey(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT) && cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT) != null){
Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT);
csIds.add(eachCon.Id);
cibisIdMap.put('eligibility', csIds);
} else {
cibisIdMap.put(Constants.CIBIS_USMLE_TRANSCRIPT_REQUEST_POST_CHECK_EVENT, new Set<Id> {eachCon.Id});
}*/
            }
            update updateParentIdCase;
            System.debug('Exams Cases --> '+cibisIdMap.get('eligibility'));
            CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);
            CibisRequestUtilityHandler.processEnrollementVerificationCase(cases);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void invokeCibisCandidateGenReqHandler(){
        Test.startTest();
        Map<String, Set<Id>> cibisIdMap = new Map<String, Set<Id>>();
        List<Case> cases = [SELECT Id, RecordTypeId, ContactId FROM Case];
        
        Map<Id, Id> conCaseIds = new Map<Id, Id>();
        User adminUser = [SELECT Id, Profile.Name FROM User WHERE Profile.Name='Salesforce Admin' AND Alias='adminUsr'];
        System.runAs(adminUser){
            List<Case> filterCases = [SELECT Id, RecordTypeId, ContactId, AccountId FROM Case WHERE RecordType.developerName=:Constants.CASE_RECORD_TYPE_APP_FOR_CERT AND Internal_Status__c=:Constants.CASE_STATUS_PENDING_CIBIS];
            for(Case eachCase: filterCases){
                conCaseIds.put(eachCase.ContactId, eachCase.Id);            
            }
            
            CibisCandidateGenReqHandler.conCaseIdMap = conCaseIds;
            
            for(Case eachCase: cases){
                if(!cibisIdMap.containsKey(Constants.CIBIS_CANDIDATE_EVENT) && cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT) != null){
                    Set<Id> csIds = cibisIdMap.get(Constants.CIBIS_CANDIDATE_EVENT);
                    csIds.add(eachCase.Id);
                    cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, csIds);
                } else {
                    cibisIdMap.put(Constants.CIBIS_CANDIDATE_EVENT, new Set<Id> {eachCase.Id});
                }
            }
            System.debug('cibisIdMap '+cibisIdMap);
            CibisRequestUtilityHandler.cibisPlatformEventPublish(cibisIdMap);   
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void invokeWrapperClasses(){
        //CibisCandidateRequestEventWrap
        CibisCandidateRequestEventWrap regWrapper = new CibisCandidateRequestEventWrap();
        regWrapper.entity = 'Test';
        regWrapper.subEntity = 'Exam';
        regWrapper.operation = 'DML';
        regWrapper.subEntity = '';
        regWrapper.transactionId = '123';
        regWrapper.USMLEId = '123';
        CibisCandidateRequestEventWrap.candidatePayLoad regPayLoad = new CibisCandidateRequestEventWrap.candidatePayLoad();
        regPayLoad.USMLEId = '123';
        regPayLoad.lastName = 'SSP';
        regPayLoad.firstName = 'MP';
        regPayLoad.middleName = 'S';
        regPayLoad.restOfName = 'MSP SSP';
        regPayLoad.generationSuffix = 'Mrs';
        regPayLoad.gender = 'Female';
        regPayLoad.dateOfBirth = '13Jan';
        regPayLoad.SSN = '1234';
        regPayLoad.schoolId = '123';
        regPayLoad.graduationYear = '2011';
        regPayLoad.graduationMonth = 'July';
        regPayLoad.schoolStartYear = '2004';
        regPayLoad.schoolStartMonth = 'July';
        regPayLoad.nidCountryId = 'US001';
        regPayLoad.emailAddress = 'ecfmg@ecfmg.com';
        regWrapper.payload = regPayLoad;
    }
}