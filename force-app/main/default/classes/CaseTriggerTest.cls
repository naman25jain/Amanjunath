//Test class for CaseTrigger and its handler classes
@isTest
public class CaseTriggerTest{
    /*public static final String TEMPLATE_NAME = 'EV Case Template';
    public static final String CONFIG_ID = '451ce5c1-31da-4d30-a6a8-62623c7194e4';
    public static final String ASSERT_ERROR_1 = 'Record creation failed'; 
    public static final String ASSERT_ERROR_2 = 'Record update failed';
    public static final String ACCOUNT_NAME='Test Account12';
    public static final String CONTACT_EMAIL='test12@test.com';
    public static final String BILLING_COUNTRY = 'India';
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
    }
    public static testMethod void testAfterInsert(){
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type = 'Queue');
            insert grp;
            System.assert(grp.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp1 = new Group(Name = Constants.QUEUE_USMLE_TRANSCRIPTS, type = 'Queue');
            insert grp1;
            System.assert(grp1.Id != null, ASSERT_ERROR_1);
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
            System.assert(que1.Id != null, ASSERT_ERROR_1);
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp2 = new Group(Name = Constants.QUEUE_APP_FOR_CERT, type = 'Queue');
            insert grp2;
            System.assert(grp2.Id != null, ASSERT_ERROR_1);
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
            System.assert(que2.Id != null, ASSERT_ERROR_1);
        }
        Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp3 = new Group(Name = Constants.QUEUE_EXAM_REG, type = 'Queue');
            insert grp3;
            System.assert(grp3.Id != null, ASSERT_ERROR_1);
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
            System.assert(que3.Id != null, ASSERT_ERROR_1);
        }
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Asset asst = new Asset();
        asst.Name = 'Photo';
        asst.ContactId = con.Id;
        asst.Type__c = 'Photo';
        INSERT asst;
        System.assert(asst.Id != null, ASSERT_ERROR_1);
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        Case evCase = new Case();
        evCase.Enrolled_in_Entity_Portal__c = True;
        evCase.RecordTypeId = evRTId;
        evCase.ContactId = con.Id;
        INSERT evCase;
        System.assert(evCase.Id != null, ASSERT_ERROR_1);
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
        examRegCase1.ContactId = con.Id;
        INSERT examRegCase1;
        System.assert(examRegCase1.Id != null, ASSERT_ERROR_1);
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Case__c = examRegCase1.Id;
        examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examReg.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg.EP_end_Date__c = Date.today();
        INSERT examReg;
        System.assert(examReg.Id != null, ASSERT_ERROR_1);
        Case epexCase = new Case();
        epexCase.RecordTypeId = epexRTId;
        epexCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        epexCase.ContactId = con.Id;
        INSERT epexCase;
        System.assert(epexCase.Id != null, ASSERT_ERROR_1);
        Case epexCasePC = new Case();
        epexCasePC.RecordTypeId = epexRTId;
        epexCasePC.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        epexCasePC.ContactId = con.Id;
        epexCasePC.Enrollment_Verification_Parent__c = evCase.Id;
        INSERT epexCasePC;
        System.assert(epexCasePC.Id != null, ASSERT_ERROR_1);
        Test.startTest();
        Case examRegCase = new Case();
        examRegCase.RecordTypeId = examRegRTId;
        examRegCase.ContactId = con.Id;
        INSERT examRegCase;
        System.assert(examRegCase.Id != null, ASSERT_ERROR_1);
        epexCase.ParentId = examRegCase.Id;
        UPDATE epexCase;
        System.assert(epexCase.ParentId == examRegCase.Id, ASSERT_ERROR_2);
        Exam_Registration__c examReg1 = new Exam_Registration__c();
        examReg1.Case__c = examRegCase.Id;
        examReg1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examReg1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg1.EP_end_Date__c = Date.today();
        INSERT examReg1;
        System.assert(examReg1.Id != null, ASSERT_ERROR_1);
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = TEMPLATE_NAME;
        docConfig.cadmus_core__CustomerDocumentConfigId__c = CONFIG_ID;
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        INSERT docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.afterInsertHelper(new List<Case> {
            epexCasePC
                });
        CaseTriggerHelper.afterInsertHelper(new List<Case> {
            epexCase
                });
        System.assert([SELECT ECFMG_Portal_Case_Url__c FROM Case WHERE Id =: epexCase.Id][0].ECFMG_Portal_Case_Url__c != '','record fetching failed');
        EnrollmentVerificationCaseHandler.updateSLADate(new Set<Id> {
            examRegCase1.Id
                });
        System.assert(EnrollmentVerificationCaseHandler.createEVCaseObject(con.Id, que.Id, true) != null,'Record fetching failed');
        Test.stopTest();
    }
    public static testMethod void testAfterInsertHelper(){
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id epicRepReqRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST);
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        Case examRegCase = new Case();
        examRegCase.RecordTypeId = epicRepReqRecTypeId;
        examRegCase.ContactId = con.Id;
        examRegCase.Internal_Status__c = Constants.CASE_STATUS_SENT;
        INSERT examRegCase;
        System.assert(examRegCase.Id != null, ASSERT_ERROR_1);
        Service__c serv = new Service__c(Name = Constants.SERVICE_NAME_PERFORMANCE_DATA);
        INSERT serv;
        System.assert(serv.Id != null, ASSERT_ERROR_1);
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);
        INSERT acc2Service;
        System.assert(acc2Service.Id != null, ASSERT_ERROR_1);
        EnrollmentVerificationCaseHandler.updateEVCase(new List<Case> {examRegCase});
    }
    public static testMethod void testAfterInsertHelperForEvCase(){
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();   
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = CONTACT_EMAIL;
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        Case examRegCase = new Case();
        examRegCase.RecordTypeId = examRegRTId;
        examRegCase.ContactId = con.Id;
        INSERT examRegCase;
        System.assert(examRegCase.Id != null, ASSERT_ERROR_1);
        Service__c serv = new Service__c(Name = Constants.SERVICE_NAME_PERFORMANCE_DATA);
        INSERT serv;
        System.assert(serv.Id != null, ASSERT_ERROR_1);
        Test.startTest();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);
        INSERT acc2Service;
        System.assert(acc2Service.Id != null, 'Account Service ID is not null');
        Asset ast = new Asset();
        ast.Name = 'PHOTO';
        ast.Type__c = 'Photo';
        ast.ContactId = con.Id;
        insert ast;
        System.assert(ast.Id != null, ASSERT_ERROR_1);
        EnrollmentVerificationCaseHandler.createEVCase(new List<Case> {examRegCase}, new Set<Id> {con.Id});
        Test.stopTest();
    }
    public static testMethod void testAfterUpdate(){
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id appForCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id cvRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id usmleTranscriptCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Id ifomRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IFOM_REQUEST).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type = 'Queue');
            insert grp;
            System.assert(grp.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp1 = new Group(Name = Constants.QUEUE_USMLE_TRANSCRIPTS, type = 'Queue');
            insert grp1;
            System.assert(grp1.Id != null, ASSERT_ERROR_1);
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
            System.assert(que1.Id != null, ASSERT_ERROR_1);
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp2 = new Group(Name = Constants.QUEUE_APP_FOR_CERT, type = 'Queue');
            insert grp2;
            System.assert(grp2.Id != null, ASSERT_ERROR_1);
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
            System.assert(que2.Id != null, ASSERT_ERROR_1);
        }
        Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp3 = new Group(Name = Constants.QUEUE_EXAM_REG, type = 'Queue');
            insert grp3;
            System.assert(grp3.Id != null, ASSERT_ERROR_1);
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
            System.assert(que3.Id != null, ASSERT_ERROR_1);
        }
        Account acc = new Account();
        acc.Name = 'Test Accounttwo1';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Testtwo';
        con.Email = 'test@testtwo1.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Case appforcertCase = new Case();
        appforcertCase.RecordTypeId = appForCertRTId;
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CV;
        appforcertCase.ContactId = con.Id;
        INSERT appforcertCase;
        System.assert(appforcertCase.Id != null, ASSERT_ERROR_1);
        Id recordTypeId = Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId = recordTypeId;
        cats.Account__c = con.AccountId;
        cats.Case__c = appforcertCase.Id;
        cats.Contact__c = con.Id;
        cats.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, ASSERT_ERROR_1);
        Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId = recordTypeIdCat;
        cat.Account__c = con.AccountId;
        cat.Case__c = appforcertCase.Id;
        cat.Contact__c = con.Id;
        cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        Case cvCase = new Case();
        cvCase.RecordTypeId = cvRTId;
        cvCase.Internal_Status__c = Constants.CASE_STATUS_CV_REJECTED;
        cvCase.ContactId = con.Id;
        INSERT cvCase;
        System.assert(cvCase.Id != null, ASSERT_ERROR_1);
        Case oldcvCase = cvCase;
        cvCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        oldcvCase.ParentId = appforcertCase.Id;
        UPDATE oldcvCase;
        System.assert(oldcvCase.ParentId == appforcertCase.Id, ASSERT_ERROR_2);
        CaseTriggerHelper.afterUpdateHelper(new List<Case> {
            cvCase
                }, new Map<Id, Case> {
                    cvCase.Id => oldcvCase
                        }); 
        Case epexCasePC = new Case();
        epexCasePC.RecordTypeId = epexRTId;
        epexCasePC.ContactId = con.Id;
        INSERT epexCasePC;
        System.assert(epexCasePC.Id != null, ASSERT_ERROR_1);
        Case epexCasePCNew = epexCasePC;
        epexCasePCNew.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        UPDATE epexCasePCNew;
        System.assert(epexCasePCNew.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS, ASSERT_ERROR_2);
        Test.startTest();
        CaseTriggerHelper.afterUpdateHelper(new List<Case> {
            epexCasePCNew
                }, new Map<Id, Case> {
                    epexCasePCNew.Id => epexCasePC
                        });
        Case ifomCase = new Case();
        ifomCase.RecordTypeId = ifomRTId;
        ifomCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE;
        ifomCase.ContactId = con.Id;
        INSERT ifomCase;
        System.assert(ifomCase.Id != null, ASSERT_ERROR_1);
        Case newifomCase = new Case();
        newifomCase.id = ifomCase.id;
        newifomCase.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
        UPDATE newifomCase;
        System.assert(newifomCase.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.afterUpdateHelper(new List<Case> {
            newifomCase
                }, new Map<Id, Case> {
                    newifomCase.Id => ifomCase
                        });
        System.assert([SELECT Updated_in_NBME_system__c FROM Case WHERE Id =: newifomCase.Id][0].Updated_in_NBME_system__c == False, 'Expected and actual field values are not same');
        Case usmleCase = new Case();
        usmleCase.RecordTypeId = usmleTranscriptCaseRecordtypeId;
        usmleCase.ContactId = con.Id;
        INSERT usmleCase;
        System.assert(usmleCase.Id != null, ASSERT_ERROR_1);
        Case odlusmleCase = usmleCase;
        usmleCase.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
        UPDATE usmleCase;
        System.assert(usmleCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED, ASSERT_ERROR_2);
        CaseTriggerHelper.updateDeficiencyReson(new List<Case> {
            usmleCase
                }, new Map<Id, Case> {
                    usmleCase.Id => odlusmleCase
                        });
        System.assert([SELECT Deficiency_Reason_RTF__c FROM Case WHERE Id =: usmleCase.Id][0].Deficiency_Reason_RTF__c != '', 'Field value is empty');
        CaseTriggerHelper.updateDeficiencyReson(new List<Case> { usmleCase }, new Map<Id, Case>());
        test.stopTest();
    }
    public static testMethod void testAfterUpdate1(){
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id usmleTranscriptCaseRecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.Passed_basic_sciences_course__c = Constants.STATUS_NO;
        evCase.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
        INSERT evCase;
        System.assert(evCase.Id != null, ASSERT_ERROR_1);
        Case examRegCase = new Case();
        examRegCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL;
        examRegCase.RecordTypeId = examRegRTId;
        examRegCase.Enrollment_Verification_Parent__c = evCase.Id;
        INSERT examRegCase;
        System.assert(examRegCase.Id != null, ASSERT_ERROR_1);
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Case__c = examRegCase.Id;
        examReg.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg.EP_end_Date__c = Date.today();
        INSERT examReg;
        System.assert(examReg.Id != null, ASSERT_ERROR_1);
        Case epexCase = new Case();
        epexCase.RecordTypeId = epexRTId;
        epexCase.ParentId = examRegCase.Id;
        epexCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        INSERT epexCase;
        System.assert(epexCase.Id != null, ASSERT_ERROR_1);
        Case usmleCase = new Case();
        usmleCase.RecordTypeId = usmleTranscriptCaseRecordtypeId;
        INSERT usmleCase;
        System.assert(usmleCase.Id != null, ASSERT_ERROR_1);
        Test.startTest();
        CaseTriggerHelper.allImpactedExamCases(evCase, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED);
        CaseTriggerHelper.manageEVFromEntityportal(evCase, usmleCase);
        CaseTriggerHelper.allImpactedEpexCases(evCase, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED);
        Test.stopTest();
    }
    public static testMethod void testAfterUpdate2(){
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId(); 
        Case evCase4 = new Case();
        evCase4.RecordTypeId = evRTId;
        evCase4.Verification_Status__c = Constants.CASE_VERIFICATION_ENROLLED;
        evCase4.Passed_basic_sciences_course__c = Constants.STATUS_YES;
        evCase4.Attendance_Start_Date__c = Date.today();
        evCase4.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        INSERT evCase4;
        System.assert(evCase4.Id != null, ASSERT_ERROR_1);
        Case examRegCase1 = new Case();
        examRegCase1.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.Enrollment_Verification_Parent__c = evCase4.Id;
        INSERT examRegCase1;
        System.assert(examRegCase1.Id != null, ASSERT_ERROR_1);
        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.Passed_basic_sciences_course__c = Constants.STATUS_NO;
        evCase.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
        evCase.Attendance_Start_Date__c = Date.Today().addDays(-50) ;
        evCase.Attendance_End_Date__c =  Date.Today().addDays(50);
        evCase.Graduation_Month__c = 'December' ;
        evCase.Graduation_Year__c = String.Valueof(Date.Today().year());
        evCase.Degree_Date__c = Date.Today().addDays(50);
        evCase.Number_of_Years_Attended__c = 2;
        INSERT evCase;
        System.assert(evCase.Id != null, ASSERT_ERROR_1);
        Case evCase1 = new Case();
        evCase1.RecordTypeId = evRTId;
        evCase1.Verification_Status__c = Constants.CASE_VERIFICATION_ENROLLED;
        evCase1.Passed_basic_sciences_course__c = Constants.STATUS_YES;
        evCase1.Attendance_Start_Date__c = Date.Today().addDays(-50) ;
        evCase1.Attendance_End_Date__c =  Date.Today().addDays(50);
        evCase1.Graduation_Month__c = 'December';
        evCase1.Graduation_Year__c = String.Valueof(Date.Today().year());
        evCase1.Degree_Date__c = Date.Today().addDays(50);
        evCase1.Number_of_Years_Attended__c = 2;
        evCase1.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        evCase1.Enrolled_in_Entity_Portal__c = true;
        INSERT evCase1;
        System.assert(evCase1.Id != null, ASSERT_ERROR_1);       
        Test.startTest();
        CaseTriggerHelper.manageEVFromEntityportal(evCase1, evCase);
        EnrollmentVerificationCaseHandler.systemCheckEVCase(new List<Case> {evCase1}, new Map<Id, Case> {evCase1.Id => evCase});
        System.assertNotEquals([SELECT Internal_Status__c FROM Case WHERE Id =: evCase1.Id][0].Internal_Status__c, Constants.CASE_STATUS_NEW,'Status is not New');
        Case evCase3 = new Case();
        evCase3.RecordTypeId = evRTId;
        evCase3.Verification_Status__c = Constants.CASE_VERIFICATION_DECEASED;
        INSERT evCase3;
        System.assert(evCase3.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.manageEVFromEntityportal(evCase3, evCase);
        Case evCase2 = new Case();
        evCase2.RecordTypeId = evRTId;
        evCase2.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
        evCase2.Enrolled_in_Entity_Portal__c = False;
        INSERT evCase2;
        System.assert(evCase2.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.manageExamRegManualReview(new List<Case> {evCase2}, new Map<Id, Case> {evCase2.Id => evCase1});
        CaseTriggerHelper.getSequence();
        CaseTriggerHelper.updateSequence('123');        
        Test.stopTest();
    }
    public static testMethod void testAfterUpdate3(){
        Id usmlTranscriptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'test acc';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'testone';
        con.Email = 'testone@testone.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Case evCase5 = new Case();
        evCase5.RecordTypeId = evRTId;
        evCase5.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
        evCase5.ContactId = con.Id;
        INSERT evCase5;
        System.assert(evCase5.Id != null, ASSERT_ERROR_1);
        evCase5.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE;
        update evCase5;
        System.assert(evCase5.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE, ASSERT_ERROR_2);
        Case transcriptCase = new Case();
        transcriptCase.RecordTypeId = usmlTranscriptRecordTypeId;
        transcriptCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CV;
        transcriptCase.ContactId = con.Id;
        INSERT transcriptCase;
        System.assert(transcriptCase.Id != null, ASSERT_ERROR_1);
        transcriptCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        update transcriptCase;
        System.assert(transcriptCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED, ASSERT_ERROR_2);
    }
    public static testMethod void testbeforeUpdate(){
        Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type = 'Queue');
            insert grp;
            System.assert(grp.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp1 = new Group(Name = Constants.QUEUE_USMLE_TRANSCRIPTS, type = 'Queue');
            insert grp1;
            System.assert(grp1.Id != null, ASSERT_ERROR_1);
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
            System.assert(que1.Id != null, ASSERT_ERROR_1);
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp2 = new Group(Name = Constants.QUEUE_APP_FOR_CERT, type = 'Queue');
            insert grp2;
            System.assert(grp2.Id != null, ASSERT_ERROR_1);
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
            System.assert(que2.Id != null, ASSERT_ERROR_1);
        }
        Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp3 = new Group(Name = Constants.QUEUE_EXAM_REG, type = 'Queue');
            insert grp3;
            System.assert(grp3.Id != null, ASSERT_ERROR_1);
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
            System.assert(que3.Id != null, ASSERT_ERROR_1);
        }
        Account acc = new Account();
        acc.Name = 'Test Accountthree';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Testthree';
        con.Email = 'test@testthree.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Test.startTest();
        Case appforcertCase = new Case();
        appforcertCase.RecordTypeId = appForCertRecordTypeId;
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CV;
        appforcertCase.ContactId = con.Id;
        INSERT appforcertCase;
        System.assert(appforcertCase.Id != null, ASSERT_ERROR_1);
        Id recordTypeId   =   Schema.SObjectType.Contact_Association_Type_Staging__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type_Staging__c cats = new Contact_Association_Type_Staging__c();
        cats.recordTypeId   =   recordTypeId;
        cats.Account__c   =   con.AccountId;
        cats.Case__c     =  appforcertCase.Id;
        cats.Contact__c    =  con.Id;
        cats.Type__c    =  Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cats;
        System.assert(cats.Id != null, ASSERT_ERROR_1);
        Id recordTypeIdCat   =   Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId   =   recordTypeIdCat;
        cat.Account__c     =   con.AccountId;
        cat.Case__c     =  appforcertCase.Id;
        cat.Contact__c    =  con.Id;
        cat.Type__c      =  Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        update appforcertCase;
        System.assert(appforcertCase.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED, ASSERT_ERROR_2);
        Case examCase = new Case();
        examCase.RecordTypeId = examRegRTId;
        examCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
        examCase.ContactId = con.Id;
        INSERT examCase;
        System.assert(examCase.Id != null, ASSERT_ERROR_1);
        examCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        update examCase;
        System.assert(examCase.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT, ASSERT_ERROR_2);
        Test.stopTest();
    }
    public static testMethod void testEntityUserRequest(){
        Id entityUserRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Account acc = new Account();
        acc.Name = ACCOUNT_NAME;
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test11@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Case entityUserServiceRequestCase1 = new Case();
        entityUserServiceRequestCase1.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase1.ContactId = con.Id;
        entityUserServiceRequestCase1.Source__c = Constants.CASE_SOURCE_COORDINATOR;
        entityUserServiceRequestCase1.Internal_Status__c = Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK;
        INSERT entityUserServiceRequestCase1;
        System.assert(entityUserServiceRequestCase1.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.afterInsertHelper(new List<Case> {
            entityUserServiceRequestCase1
                });
        System.assertEquals([SELECT Internal_Status__c FROM Case WHERE Id =: entityUserServiceRequestCase1.Id][0].Internal_Status__c, Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK,'Assetion Failed: Status is not Pending Signature Check');
        ID profileID = [Select id from Profile where name = '4-Customer Community Entity 360'].id;
        Account acc2 = new Account(Name = 'Test Account2',BillingCountry=BILLING_COUNTRY);
        insert acc2;
        System.assert(acc2.Id != null, ASSERT_ERROR_1);
        Contact con2 = new Contact(AccountID = acc2.id, FirstName = 'User', LastName = 'test', email = Constants.TEST_EMAIL_ID);
        insert con2;
        System.assert(con2.Id != null, ASSERT_ERROR_1);
        User u = new User(email = Constants.TEST_EMAIL_ID, contactid = Con2.id, profileid = profileid, UserName = Constants.TEST_EMAIL_ID, alias = 'tuser', CommunityNickName = 'tuser', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US', FirstName = 'User', LastName = 'Test');
        insert u;
        System.assert(u.Id != null, ASSERT_ERROR_1);
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_TYPE_PIA_TEMPLATE;
        insert docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1);
        Service__c s = new Service__c();
        s.Name = 'Test Service';
        insert s;
        System.assert(s.Id != null, ASSERT_ERROR_1);
        Case entityUserServiceRequestCase2 = new Case();
        entityUserServiceRequestCase2.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase2.ContactId = con2.Id;
        entityUserServiceRequestCase2.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase2.Service_Name__c = s.id;
        INSERT entityUserServiceRequestCase2;
        System.assert(entityUserServiceRequestCase2.Id != null, ASSERT_ERROR_1);
        Test.startTest();
        CaseTriggerHelper.afterInsertHelper(new List<Case> {
            entityUserServiceRequestCase2
                });
        System.assertEquals([SELECT Internal_Status__c FROM Case WHERE Id =: entityUserServiceRequestCase2.Id][0].Internal_Status__c, Constants.CASE_STATUS_NEW,'Assetion Failed: Status is not New');
        Case entityUserServiceRequestCase3 = new Case();
        entityUserServiceRequestCase3.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase3.AccountId = con2.AccountID;
        entityUserServiceRequestCase3.ContactId = con2.Id;
        entityUserServiceRequestCase3.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase3.Service_Name__c = s.id;
        INSERT entityUserServiceRequestCase3;
        System.assert(entityUserServiceRequestCase3.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.afterInsertHelper(new List<Case> {
            entityUserServiceRequestCase3
                });
        System.assertEquals([SELECT Internal_Status__c FROM Case WHERE Id =: entityUserServiceRequestCase3.Id][0].Internal_Status__c, Constants.CASE_STATUS_NEW,'Assetion Failed: Status is not New');        
        CaseTriggerHelper.entityContactCheckNewServiceForm(new List<Case>{entityUserServiceRequestCase1}, new Map<Id, Case> {entityUserServiceRequestCase1.Id => entityUserServiceRequestCase2});
        Test.stopTest();
    }
    public static testMethod void testSendEntitiUserReqDef(){
        Test.startTest();
        Id entityUserRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Id entityDocRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ENTITY_DOC).getRecordTypeId();
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_TYPE_PIA_TEMPLATE;
        insert docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1);
        Account acc2 = new Account(Name = 'Test Account2',BillingCountry=BILLING_COUNTRY);
        insert acc2;
        System.assert(acc2.Id != null, ASSERT_ERROR_1);
        Contact con2 = new Contact(AccountID = acc2.id, FirstName = 'User', LastName = 'test', email = Constants.TEST_EMAIL_ID);
        insert con2;
        System.assert(con2.Id != null, ASSERT_ERROR_1);
        Case entityUserServiceRequestCase4 = new Case();
        entityUserServiceRequestCase4.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase4.AccountId = con2.AccountID;
        entityUserServiceRequestCase4.ContactId = con2.Id;
        entityUserServiceRequestCase4.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE;
        entityUserServiceRequestCase4.Deficiency_Reason_RTF__c = 'Test';
        INSERT entityUserServiceRequestCase4;
        System.assert(entityUserServiceRequestCase4.Id != null, ASSERT_ERROR_1);
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset();
        asset1.Name = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE;
        asset1.Type__c = Constants.ASSET_TYPE_NEW_SERVICE_TEMPLATE;
        asset1.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset1.Case__c = entityUserServiceRequestCase4.Id;
        asset1.ContactId = entityUserServiceRequestCase4.ContactId;
        asset1.AccountId = entityUserServiceRequestCase4.AccountId;
        asset1.RecordTypeId = entityDocRTId;
        assets.add(asset1);
        Asset asset2 = new Asset();
        asset2.Name = Constants.ASSET_TYPE_PIA_TEMPLATE;
        asset2.Type__c = Constants.ASSET_TYPE_PIA_TEMPLATE;
        asset2.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset2.Case__c = entityUserServiceRequestCase4.Id;
        asset2.ContactId = entityUserServiceRequestCase4.ContactId;
        asset2.AccountId = entityUserServiceRequestCase4.AccountId;
        asset2.RecordTypeId = entityDocRTId;
        assets.add(asset2);
        Asset asset3 = new Asset();
        asset3.Name = Constants.ASSET_TYPE_SIGNED_PIA;
        asset3.Type__c = Constants.ASSET_TYPE_SIGNED_PIA;
        asset3.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset3.Case__c = entityUserServiceRequestCase4.Id;
        asset3.ContactId = entityUserServiceRequestCase4.ContactId;
        asset3.AccountId = entityUserServiceRequestCase4.AccountId;
        asset3.RecordTypeId = entityDocRTId;
        assets.add(asset3);
        Asset asset4 = new Asset();
        asset4.Name = Constants.ASSET_TYPE_SIGNED_SERVICE_FORM;
        asset4.Type__c = Constants.ASSET_TYPE_SIGNED_SERVICE_FORM;
        asset4.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset4.Case__c = entityUserServiceRequestCase4.Id;
        asset4.ContactId = entityUserServiceRequestCase4.ContactId;
        asset4.AccountId = entityUserServiceRequestCase4.AccountId;
        asset4.RecordTypeId = entityDocRTId;
        assets.add(asset4);
        INSERT assets;
        System.assert(asset1.Id != null, ASSERT_ERROR_1);
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        System.assert(cv.Id != null, ASSERT_ERROR_1);
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = asset1.Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id][0].ContentDocumentId;
        cdl.shareType = 'V';
        Insert cdl;
        System.assert(cdl.Id != null, ASSERT_ERROR_1);
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document1';
        cv1.PathOnClient = 'TestDocument1.pdf';
        cv1.VersionData = Blob.valueOf('Test Content1');
        cv1.IsMajorVersion = true;
        Insert cv1;
        System.assert(cv1.Id != null, ASSERT_ERROR_1);
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = asset2.Id;
        cdl1.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv1.Id][0].ContentDocumentId;
        cdl1.shareType = 'V';
        Insert cdl1;
        System.assert(cdl1.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.sendEntityUserRequestDeficiency(new List<Case> {entityUserServiceRequestCase4}, entityUserRequestRecordTypeId);
        Test.stopTest();
    }
    public static testMethod void testAfterUpdateHelp(){
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId(); 
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();       
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type = 'Queue');
            insert grp;
            System.assert(grp.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp1 = new Group(Name = Constants.QUEUE_USMLE_TRANSCRIPTS, type = 'Queue');
            insert grp1;
            System.assert(grp1.Id != null, ASSERT_ERROR_1);
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
            System.assert(que1.Id != null, ASSERT_ERROR_1);
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp2 = new Group(Name = Constants.QUEUE_APP_FOR_CERT, type = 'Queue');
            insert grp2;
            System.assert(grp2.Id != null, ASSERT_ERROR_1);
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
            System.assert(que2.Id != null, ASSERT_ERROR_1);
        }
        Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp3 = new Group(Name = Constants.QUEUE_EXAM_REG, type = 'Queue');
            insert grp3;
            System.assert(grp3.Id != null, ASSERT_ERROR_1);
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
            System.assert(que3.Id != null, ASSERT_ERROR_1);
        }
        Account acc = new Account();
        acc.Name = 'Test Accounttwo2';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Testtwo';
        con.Email = 'test@testtwo2.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Id recordTypeIdCat   =   Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId   =   recordTypeIdCat;
        cat.Account__c     =   con.AccountId;
        cat.Contact__c    =  con.Id;
        cat.Type__c      =  Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        System.assert(cat.Id != NULL, 'Contact association type creation failed.');
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = TEMPLATE_NAME;
        docConfig.cadmus_core__CustomerDocumentConfigId__c = CONFIG_ID;
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        INSERT docConfig;
        System.assert(docConfig.Id != NULL, 'Data config creation failed.');
        Case epexCasePC = new Case();
        epexCasePC.RecordTypeId = epexRTId;
        epexCasePC.ContactId = con.Id;
        INSERT epexCasePC; 
        System.assert(epexCasePC.Id != null, ASSERT_ERROR_1);       
        Test.startTest();
        Case examCasePC = new Case();
        examCasePC.RecordTypeId = examRegRTId;
        examCasePC.Enrollment_Verification_Parent__c = null;
        examCasePC.ContactId = con.Id;
        INSERT examCasePC;
        System.assert(examCasePC.Id != null, ASSERT_ERROR_1);
        RecursiveTriggerHandler.isFirstTime = true;
        examCasePC.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        update examCasePC;
        System.assert(examCasePC.Internal_Status__c == Constants.CASE_STATUS_PENDING_ENROLLMENT, ASSERT_ERROR_2);   
    }
    public static testMethod void testAfterUpdateEVCase(){
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id ervRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();       
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type = 'Queue');
            insert grp;
            System.assert(grp.Id != null, 'Group creation failed');
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, 'Queue creation failed');
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp1 = new Group(Name = Constants.QUEUE_USMLE_TRANSCRIPTS, type = 'Queue');
            insert grp1;
            System.assert(grp1.Id != null, 'group creation failed');
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
            System.assert(que1.Id != null, ASSERT_ERROR_1);
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp2 = new Group(Name = Constants.QUEUE_APP_FOR_CERT, type = 'Queue');
            insert grp2;
            System.assert(grp2.Id != null, ASSERT_ERROR_1);
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
            System.assert(que2.Id != null, ASSERT_ERROR_1);
        }
        Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp3 = new Group(Name = Constants.QUEUE_EXAM_REG, type = 'Queue');
            insert grp3;
            System.assert(grp3.Id != null, 'group creation failed');
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
            System.assert(que3.Id != null, 'Queue creation failed');
        }
        Account acc = new Account();
        acc.Name = 'Test Accounttwo3';
        acc.BillingCountry=BILLING_COUNTRY;  
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Testtwo';
        con.Email = 'test@testtwo3.com';
        INSERT con; 
        System.assert(con.Id != null, 'Contact creation failed');
        Case evCasePC = new Case();
        evCasePC.RecordTypeId = evRTId;
        evCasePC.ContactId = con.Id;
        INSERT evCasePC;
        System.assert(evCasePC.Id != null, 'Case creation failed');
        cadmus_core__Doc_Config__c docConfig1 = new cadmus_core__Doc_Config__c();
        docConfig1.Name = 'EnrollReverification Case Template';
        docConfig1.cadmus_core__CustomerDocumentConfigId__c ='46b34380-9e1a-4401-a102-07ec5d4d66ad';
        insert docConfig1;
        System.assert(docConfig1.Id != null, 'Doc config creation failed');
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = TEMPLATE_NAME;
        docConfig.cadmus_core__CustomerDocumentConfigId__c = CONFIG_ID;
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        INSERT docConfig;
        System.assert(docConfig.Id != null, 'Doc config creation failed');
        Case exam = new Case();
        exam.RecordTypeId = examRegRTId;
        exam.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        exam.Enrollment_Verification_Parent__c=evCasePC.Id;
        exam.Is_First_time_Exam_Case__c = true;
        exam.ContactId = con.Id;
        INSERT exam;
        System.assert(exam.Id != null, ASSERT_ERROR_1);
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg.Case__c = exam.Id;
        insert examReg;
        System.assert(examReg.Id != null, 'Exam registration creation failed');
        Case epexcas = new Case();
        epexcas.RecordTypeId = epexRTId;
        epexcas.Internal_Status__c = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        epexcas.ParentId=exam.Id;
        epexcas.ContactId = con.Id;
        INSERT epexcas;
        System.assert(epexcas.Id != null, 'Case registration creation failed');
        Test.startTest();
        RecursiveTriggerHandler.isFirstTime = true;
        Case evCasePCNew = evCasePC;
        evCasePCNew.RecordTypeId = Constants.examRegRTId;
        evCasePCNew.Verification_Status__c= Constants.CASE_VERIFICATION_STATUS_GRADUATED;
        evCasePCNew.Enrolled_in_Entity_Portal__c= true;
        evCasePCNew.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        UPDATE evCasePCNew;
        System.assert(evCasePCNew.Internal_Status__c == Constants.CASE_STATUS_PENDING_CIBIS, 'Case registration update failed');     
        RecursiveTriggerHandler.isFirstTime = true;
        Case evCasePCNewOne = evCasePC;
        evCasePCNewOne.Verification_Status__c= Constants.CASE_VERIFICATION_STATUS_GRADUATED;
        evCasePCNewOne.Enrolled_in_Entity_Portal__c= false;
        evCasePCNewOne.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE;
        UPDATE evCasePCNewOne;
        System.assert(evCasePCNewOne.Internal_Status__c == Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE, ASSERT_ERROR_2);     
        Case ervCasePC = new Case();
        ervCasePC.RecordTypeId = ervRTId;       
        ervCasePC.ContactId = con.Id;
        INSERT ervCasePC;
        System.assert(ervCasePC.Id != null, ASSERT_ERROR_1);     
        RecursiveTriggerHandler.isFirstTime = true;
        Test.stopTest();
        Case ervCasePCNew = ervCasePC;
        ervCasePCNew.Internal_Status__c = Constants.CASE_STATUS_RECEIVED_IN_REVIEW;
        UPDATE ervCasePCNew;
        System.assert(ervCasePCNew.Internal_Status__c == Constants.CASE_STATUS_RECEIVED_IN_REVIEW, 'Case registration update failed');     
        Id conAssocStagingOtherInst= Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Other_Institution').getRecordTypeId();      
        Contact_Association_Type__c conAssocType7 = new Contact_Association_Type__c(Number_of_Years_Attended__c=5.00,RecordTypeId=conAssocStagingOtherInst,contact__c = con.Id,Account__c=acc.Id);
        insert conAssocType7;
        System.assert(conAssocType7.Id != null, ASSERT_ERROR_1);     
        EnrollmentVerificationCaseHandler.getOtherInstiNumberOfYearsAttended(con.Id);
        Id conAssocTypeRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(Number_of_Years_Attended__c=5.00,RecordTypeId=conAssocTypeRecordTypeId,contact__c = con.Id,Account__c=acc.Id);
        insert conAssocType;
        System.assert(conAssocType.Id != null, ASSERT_ERROR_1);     
        EnrollmentVerificationCaseHandler.getOtherMedSclNumberOfYearsAttended(con.Id);
        Decimal dc = EnrollmentVerificationCaseHandler.getTotalNumberOfYearsAttended(con.id,4.00);
        system.assertequals(dc,9.00,'VAlue is not 9.00');
        Boolean checkEV = EnrollmentVerificationCaseHandler.checkNumberOfYearsAttended(evCasePC,evCasePC);
        system.assertequals(checkEV,true,'Boolean is not True');
        EnrollmentVerificationCaseHandler.reupdateEVCaseStatuses((new List<Case> {evCasePC}));
    }
    public static testMethod void testAfterUpdateHelper(){
        Id eurRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account acc = new Account();
        acc.Name = ACCOUNT_NAME;
        acc.ECFMG_Acceptable__c = true;
        acc.RecordTypeId = entityRTId;
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;  
        System.assert(acc.Id != null, ASSERT_ERROR_1);      
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = CONTACT_EMAIL;
        INSERT con;  
        System.assert(con.Id != null, ASSERT_ERROR_1);         
        List<Case> caseList = new List<Case>();
        Case examCase = new Case();
        examCase.RecordTypeId = examRegRTId;
        examCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        examCase.Attendance_Start_Date__c = Date.today();
        examCase.Attendance_End_Date__c = Date.today().addDays(5);
        examCase.Graduation_Month__c = 'May';
        examCase.Degree_Date__c = Date.today().addDays(5);
        examCase.Number_of_Years_Attended__c = 1.0;
        examCase.ContactId = con.Id;
        caseList.add(examCase);        
        Case examCase1 = new Case();
        examCase1.RecordTypeId = examRegRTId;
        examCase1.Attendance_Start_Date__c = Date.today().addDays(1);
        examCase1.Attendance_End_Date__c = Date.today().addDays(6);
        examCase1.Graduation_Month__c = 'June';
        examCase1.Degree_Date__c = Date.today().addDays(6);
        examCase1.Number_of_Years_Attended__c = 2.0;
        examCase1.ContactId = con.Id;
        caseList.add(examCase1);
        INSERT caseList;
        System.assert(examCase.Id != null, ASSERT_ERROR_1); 
        Map<Id, Case> examCaseMap = CaseTriggerHelper.getPendingCibisExamRegCases(new Map<Id, Case> {examCase.Id => examCase1}, new List<Case> {examCase});
        CaseTriggerHelper.generateManualReviewReason(examCase, examCase1);        
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Case__c = examCase.Id;
        examReg.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examReg.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg.EP_end_Date__c = Date.today();
        INSERT examReg;
        System.assert(examReg.Id != null, ASSERT_ERROR_1);
        MAP<ID, Exam_Registration__c> examRegMap = CaseTriggerHelper.getExamRegistrationRefactor(new List<Id> (examCaseMap.keySet()));        
        CaseTriggerHelper.managePendingCibisEP(new Map<Id, Case> {examCase.Id => examCase}, new Map<Id, Case> {examCase.Id => examCase1}, examRegMap);
        CaseTriggerHelper.updateExamRegistrationRefactor(new List<Exam_Registration__c>{examReg});
        CaseTriggerHelper.updateCaseEligibilityPeriodRefactor(new List<Case>{examCase});
        List<Service__c> servList = new List<Service__c>();
        Service__c s = new Service__c();
        s.Name = 'Test Service';
        s.Signature_Required__c = true;
        servList.add(s);        
        Service__c s1 = new Service__c();
        s1.Name = 'Test Service1';
        s1.Signature_Required__c = true;
        servList.add(s1);
        insert servList;
        System.assert(s1.Id != null, ASSERT_ERROR_1);        
        Case eurCase = new Case();
        eurCase.RecordTypeId = eurRTId;
        eurCase.ContactId = con.Id;
        eurCase.AccountId = acc.Id;
        eurCase.Entity__c = acc.Id;
        eurCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SIGNATURE_CHECK;
        INSERT eurCase; 
        System.assert(eurCase.Id != null, ASSERT_ERROR_1);       
        Case2Service__c c2s = new Case2Service__c();
        c2s.Service__c = s.Id;
        c2s.Case__c = eurCase.Id;
        Insert c2s;    
        System.assert(c2s.Id != null, ASSERT_ERROR_1);    
        Asset asset1 = new Asset();
        asset1.Name = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE;
        asset1.Type__c = Constants.ASSET_ENTITY_CONTACT_USER_SIGNATURE;
        asset1.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset1.Case__c = eurCase.Id;
        asset1.ContactId = con.Id;
        asset1.AccountId = acc.Id;
        Insert asset1; 
        System.assert(asset1.Id != null, ASSERT_ERROR_1);       
        Account2Service__c a2s = new Account2Service__c();
        a2s.Account__c = acc.Id;
        a2s.Service__c = s.Id;
        a2s.Active__c = true;
        Insert a2s;
        System.assert(a2s.Id != null, ASSERT_ERROR_1); 
        // For US 7604
        Id appCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Case caseobj = new Case();
        caseobj.ContactId = con.Id;
        caseobj.AccountId = acc.Id;
        caseobj.Internal_Status__c = 'Accepted';
        caseobj.RecordTypeId = appCertRecordTypeId;
        insert caseObj;
        System.assert(caseObj.Id != null, 'Fail to insert Case Record!');
        // Contact_Association_Type__c
        Id conAssocTypeRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId = conAssocTypeRecordTypeId;
        cat.Account__c = acc.Id;
        cat.Case__c = caseObj.Id;
        cat.Contact__c = con.Id;
        cat.Status__c = 'Student';
        cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1); 
        // EV Case  - INSERT
        Id evRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Case evCase = new Case();
        evCase.ContactId = con.Id;
        evCase.AccountId = acc.Id;
        evCase.Verification_Status_Date__c = Date.today();
        evCase.Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_COMPLETE;
        evCase.RecordTypeId = evRecordTypeId;
        Test.StartTest();
        insert evCase;
        System.assert(evCase.Id != null, ASSERT_ERROR_1); 
        SET<Id> enrolledVCaseIdSet  =   new SET<Id>();
        enrolledVCaseIdSet.add(evCase.Id);
        MAP<ID, ID> catMap          =   new  MAP<ID, ID>();
        catMap.put(con.Id, cat.Id);
        List<Case2Service__c> c2sList = new List<Case2Service__c>{c2s};
            CaseTriggerHelper.updateEntityUserRequestCaseStatus(new List<Case>{eurCase});
        CaseTriggerHelper.getStatusIfCoordinator(eurCase, new Map<Id, Service__c>{s.Id => s}, new Map<Id, List<Case2Service__c>>{eurCase.Id => c2sList}, new Map<Id, Asset>{con.Id => asset1});
        List<id> serviceList = new List<id>{s.Id};
            CaseTriggerHelper.getStatusAndRejectionReasonForNonExistingService(eurCase, new Map<Id, Service__c>{s.Id => s}, new Map<Id, List<id>>{acc.Id => serviceList}, new List<Account>{acc}, new Map<Id, List<Case2Service__c>>{eurCase.Id => c2sList});
        CaseTriggerHelper.getStatusAndRejectionReasonForPerformanceDataService(eurCase, new Map<Id, List<id>>{acc.Id => serviceList}, s.Id, s1.Id,  new List<Id>{acc.Id});
        CaseTriggerHelper.getStatusAndRejectionReasonForPerformanceDataService(eurCase, new Map<Id, List<id>>{acc.Id => serviceList}, null, null,  new List<Id>{acc.Id});
        CaseTriggerHelper.updateEntityUserRequestCaseStatusRefactor(new List<Case>{eurCase}, true, true, new List<Id> {con.Id});
        CaseTriggerHelper.existingService(eurCase);
        CaseTriggerHelper.checkIfExistingPortalUserForGivenEntity(eurCase, new List<String> {con.Id});        
        examCase1.Internal_Status__c = Constants.CASE_STATUS_REGISTERED;
        Update examCase1;
        System.assert(examCase1.Internal_Status__c == Constants.CASE_STATUS_REGISTERED, ASSERT_ERROR_2); 
        CaseTriggerHelper.getHistoryList(new List<Id> {examCase.Id});
        // For US 7604
        CaseTriggerHelper.updateCATEnrolled(enrolledVCaseIdSet, catMap);
        CaseTriggerHelper.updateCATGraduated(enrolledVCaseIdSet, catMap);
        CaseTriggerHelper.updateCATWithdrawn(enrolledVCaseIdSet, catMap);
        Test.StopTest();
    }
    public static testMethod void testEntityUserRequestPerfor(){
        Test.startTest();
        Id entityUserRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();        
        Account acc = new Account();
        acc.Name = 'Test Account7';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1); 
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test2@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1); 
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_TYPE_PIA_TEMPLATE;
        insert docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1); 
        List<Case> caseList = new List<Case>();
        Account acc2 = new Account(Name = 'Test Account6',BillingCountry=BILLING_COUNTRY);
        insert acc2;
        System.assert(acc2.Id != null, ASSERT_ERROR_1); 
        Contact con2 = new Contact(AccountID = acc2.id, FirstName = 'User', LastName = 'test', email = Constants.TEST_EMAIL_ID);
        insert con2;
        System.assert(con2.Id != null, ASSERT_ERROR_1); 
        Case entityUserServiceRequestCasePendingNewSer = new Case();
        entityUserServiceRequestCasePendingNewSer.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCasePendingNewSer.ContactId = con.Id;
        entityUserServiceRequestCasePendingNewSer.Source__c = Constants.CASE_SOURCE_COORDINATOR;
        entityUserServiceRequestCasePendingNewSer.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
        caseList.add(entityUserServiceRequestCasePendingNewSer);
        List<Service__c> serList = new List<Service__c>();
        Service__c s = new Service__c();
        s.Name = 'Test Service3';
        serList.add(s);
        Service__c s2 = new Service__c();
        s2.Name = 'Performance Data';
        serList.add(s2);
        insert serList;
        System.assert(s2.Id != null, ASSERT_ERROR_1); 
        Case entityUserServiceRequestCase2 = new Case();
        entityUserServiceRequestCase2.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase2.ContactId = con2.Id;
        entityUserServiceRequestCase2.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase2.Service_Name__c = s.id;
        caseList.add(entityUserServiceRequestCase2);
        INSERT caseList;
        System.assert(entityUserServiceRequestCase2.Id != null, ASSERT_ERROR_1); 
        Case2Service__c case2Ser = new Case2Service__c();
        case2Ser.Case__c = entityUserServiceRequestCasePendingNewSer.Id;
        case2Ser.Service__c = serList[1].Id;
        insert case2Ser;
        System.assertEquals([SELECT Internal_Status__c FROM Case WHERE Id =: entityUserServiceRequestCasePendingNewSer.Id][0].Internal_Status__c, Constants.CASE_STATUS_PENDING_NEW_SERVICE,'Assertion Failed:Status != Pending New Service');
        CaseTriggerHelper.entityContactCheckNewServiceForm(new List<Case>{entityUserServiceRequestCasePendingNewSer}, new Map<Id, Case> {entityUserServiceRequestCasePendingNewSer.Id => entityUserServiceRequestCase2});    
        Test.stopTest();
    } 
    public static testMethod void testEntityUserRequestPerforElsePart(){
        Id entityUserRequestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENTITY_USER_REQUEST).getRecordTypeId();        
        Account acc = new Account();
        acc.Name = 'Test Account8';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1); 
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1); 
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_TYPE_PIA_TEMPLATE;
        insert docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1); 
        List<Case> caseList = new List<Case>();
        Account acc2 = new Account(Name = 'Test Account5',BillingCountry=BILLING_COUNTRY);
        insert acc2;
        System.assert(acc2.Id != null, ASSERT_ERROR_1); 
        Contact con2 = new Contact(AccountID = acc2.id, FirstName = 'User', LastName = 'test', email = Constants.TEST_EMAIL_ID);
        insert con2;
        System.assert(con2.Id != null, ASSERT_ERROR_1); 
        Case entityUserServiceRequestCasePendingNewSer = new Case();
        entityUserServiceRequestCasePendingNewSer.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCasePendingNewSer.ContactId = con.Id;
        entityUserServiceRequestCasePendingNewSer.Source__c = Constants.CASE_SOURCE_COORDINATOR;
        entityUserServiceRequestCasePendingNewSer.Internal_Status__c = Constants.CASE_STATUS_PENDING_NEW_SERVICE;
        caseList.add(entityUserServiceRequestCasePendingNewSer);
        List<Service__c> serList = new List<Service__c>();
        Service__c s = new Service__c();
        s.Name = 'Test Service4';
        serList.add(s);
        insert serList;
        System.assert(s.Id != null, ASSERT_ERROR_1); 
        Case entityUserServiceRequestCase2 = new Case();
        entityUserServiceRequestCase2.RecordTypeId = entityUserRequestRecordTypeId;
        entityUserServiceRequestCase2.ContactId = con2.Id;
        entityUserServiceRequestCase2.Source__c = Constants.CASE_SOURCE_PORTAL_USER;
        entityUserServiceRequestCase2.Service_Name__c = s.id;
        caseList.add(entityUserServiceRequestCase2);
        INSERT caseList;
        System.assert(entityUserServiceRequestCase2.Id != null, ASSERT_ERROR_1); 
        Test.startTest();
        System.assertEquals([SELECT Internal_Status__c FROM Case WHERE Id =: entityUserServiceRequestCasePendingNewSer.Id][0].Internal_Status__c, Constants.CASE_STATUS_PENDING_NEW_SERVICE,'Assertion Failed:Status != Pending New Service');
        CaseTriggerHelper.entityContactCheckNewServiceForm(new List<Case>{entityUserServiceRequestCasePendingNewSer}, new Map<Id, Case> {entityUserServiceRequestCasePendingNewSer.Id => entityUserServiceRequestCase2});  
        Test.stopTest();
    }
    public static testMethod void testSharingRuleCoverage(){
        Id entityRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Account acc = new Account();
        acc.Name = ACCOUNT_NAME;
        acc.ECFMG_Acceptable__c = true;
        acc.RecordTypeId = entityRTId;
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;  
        System.assert(acc.Id != null, ASSERT_ERROR_1);      
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = CONTACT_EMAIL;
        INSERT con;  
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Group examRegQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_EXAM_REG);
        List<Case> caseList = new List<Case>();
        Case examCase = new Case();
        examCase.RecordTypeId = examRegRTId;
        examCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CIBIS;
        examCase.Attendance_Start_Date__c = Date.today();
        examCase.Attendance_End_Date__c = Date.today().addDays(5);
        examCase.Graduation_Month__c = 'May';
        examCase.Degree_Date__c = Date.today().addDays(5);
        examCase.Number_of_Years_Attended__c = 1.0;
        examCase.OwnerId = examRegQueue.id;
        examCase.ContactId = con.Id;
        caseList.add(examCase);
        Insert caseList;
        System.assert(examCase.Id != null, ASSERT_ERROR_1); 
        Group specialInvQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_SPECIAL_INVESTIGATIONS_QUEUE);
        Test.StartTest();
        examCase.OwnerId = specialInvQueue.Id;
        Update examCase;
        system.assertEquals(examCase.OwnerId, specialInvQueue.Id,'Owner Id is not updated');
        Test.StopTest();
    }
    public static testMethod void testAppForCertAssetUpdate(){
        Id appForCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Accounttwo1';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != NULL, 'Asset creation failed.');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Testtwo';
        con.Email = 'test@testtwo1.com';
        INSERT con;
        System.assert(con.Id != NULL, 'Contact creation failed.');
        Case appforcertCase = new Case();
        appforcertCase.RecordTypeId = appForCertRTId;
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        appforcertCase.ContactId = con.Id;
        INSERT appforcertCase;
        test.startTest();
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset();
        asset1.Name = Constants.ASSET_TYPE_TCT;
        asset1.Type__c = Constants.ASSET_TYPE_NAME_DOC;
        asset1.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        asset1.Case__c = appforcertCase.Id;
        asset1.ContactId = appforcertCase.ContactId;
        assets.add(asset1);
        Asset asset2 = new Asset();
        asset2.Name = Constants.ASSET_TYPE_DEAN_LETTER;
        asset2.Type__c = Constants.ASSET_TYPE_NAME_DOC;
        asset2.Status = Constants.ASSET_STATUS_INCOMPLETE;
        asset2.Case__c = appforcertCase.Id;
        asset2.ContactId = appforcertCase.ContactId;
        assets.add(asset2);
        Insert assets;
        System.assert(asset2.Id != NULL, 'Asset creation failed.');
        Id recordTypeIdCat   =   Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId   =   recordTypeIdCat;
        cat.Account__c     =   con.AccountId;
        cat.Contact__c    =  con.Id;
        cat.Type__c      =  Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        cat.case__c = appforcertCase.Id;
        insert cat;
        System.assert(cat.Id != NULL, 'Contact association type creation failed.');
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_REJECTED;
        update appforcertCase;
        System.assert(appforcertCase.Internal_Status__c == Constants.CASE_STATUS_REJECTED, 'Case update failed.');
        Test.stopTest();
    }   
    public static testMethod void getExamRegCaseTest(){
        Account acc = new Account();
        acc.Name = 'Test Account3';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = TEMPLATE_NAME;
        docConfig.cadmus_core__CustomerDocumentConfigId__c = CONFIG_ID;
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        INSERT docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test2@test.com';
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        List<Case> caseList = new List<Case>();
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.ContactId = con.Id;
        caseList.add(examRegCase1);
        Case examRegCase2 = new Case();
        examRegCase2.RecordTypeId = examRegRTId;
        examRegCase2.ContactId = con.Id;
        caseList.add(examRegCase2);
        Case examRegCase3 = new Case();
        examRegCase3.RecordTypeId = epexRTId;
        examRegCase3.ContactId = con.Id;
        examRegCase3.Internal_Status__c = constants.CASE_STATUS_PENDING_ENROLLMENT;
        caseList.add(examRegCase3);
        Case examRegCase4 = new Case();
        examRegCase4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        examRegCase4.ContactId = con.Id;
        examRegCase4.Internal_Status__c = constants.CASE_STATUS_SUBMITTED;
        caseList.add(examRegCase4);
        insert caseList;
        System.assert(examRegCase4.Id != null, ASSERT_ERROR_1);
        CaseTriggerHelper.generateUsmleId(examRegCase4, examRegCase3);
        System.assert(examRegCase2.Id != null, 'Case creation failed');
        Test.startTest();
        EnrollmentVerificationCaseHandler.getExamRegCaseMapRefactor(caseList);
        caseList[0].Internal_Status__c = Constants.CASE_STATUS_ENROLLMENT_VERIFICATION_INCOMPLETE;
        caseList[1].Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        caseList[0].parentId = examRegCase4.Id;
        caseList[1].parentId = examRegCase4.Id;
        caseList[2].parentId = examRegCase1.Id;
        update caseList;
        System.assert(examRegCase2.Internal_Status__c == Constants.CASE_STATUS_ACCEPTED, 'Case update failed');
        Map<Id,Id> childParentCaseMap = new Map<Id,Id>();
        childParentCaseMap.put(examRegCase1.Id, examRegCase4.Id);
        childParentCaseMap.put(examRegCase2.Id, examRegCase4.Id);
        CaseTriggerHelper.getEntityPortalUserContactIds();
        Test.stopTest();
    }
    public static testMethod void getExamRegCaseTest2(){
        Account acc = new Account();
        acc.Name = 'Test Account4';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation unsuccessful');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test4@test.com';
        INSERT con;
        System.assert(con.Id != null, 'Contact creation unsuccessful');
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = TEMPLATE_NAME;
        docConfig.cadmus_core__CustomerDocumentConfigId__c = CONFIG_ID;
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        INSERT docConfig;
        System.assert(docConfig.Id != null, ASSERT_ERROR_1);
        Id epexRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        List<Case> caseList = new List<Case>();
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Case examRegCase2 = new Case();
        examRegCase2.RecordTypeId = evRTId;
        examRegCase2.ContactId = con.Id;
        insert examRegCase2;
        System.assert(examRegCase2.Id != null, ASSERT_ERROR_1);
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.ContactId = con.Id;
        examRegCase1.Status = Constants.CASE_STATUS_PENDING_ENROLLMENT;
        examRegCase1.Enrollment_Verification_Parent__c = examRegCase2.Id;
        caseList.add(examRegCase1);
        Id ecfmgCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_Certification).getRecordTypeId();
        test.startTest();
        Case examRegCase5 = new Case();
        examRegCase5.RecordTypeId = ecfmgCertRecordTypeId;
        examRegCase5.ContactId = con.Id;
        examRegCase5.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
        examRegCase5.Enrollment_Verification_Parent__c = examRegCase2.Id;
        caseList.add(examRegCase5);
        Case examRegCase3 = new Case();
        examRegCase3.RecordTypeId = examRegRTId;
        examRegCase3.ContactId = con.Id;
        examRegCase3.Internal_Status__c = Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED;
        examRegCase3.Enrollment_Verification_Parent__c = examRegCase2.Id;
        caseList.add(examRegCase3);
        insert caseList;
        System.assert(examRegCase3.Id != null, ASSERT_ERROR_1);
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examReg.Case__c = examRegCase1.Id;
        insert examReg;
        System.assert(examReg.Id != null, ASSERT_ERROR_1);
        RecursiveTriggerHandler.isFirstTime = true;
        examRegCase2.Internal_Status__c = constants.CASE_STATUS_RECEIVED_IN_REVIEW;
        examRegCase2.Verification_Status__c = Constants.CASE_VERIFICATION_ENROLLED;
        examRegCase2.Passed_basic_sciences_course__c = Constants.STATUS_YES;
        examRegCase2.Number_of_Years_Attended__c = 1;
        update examRegCase2;
        System.assert(examRegCase2.Internal_Status__c == constants.CASE_STATUS_RECEIVED_IN_REVIEW, ASSERT_ERROR_1);
        examRegCase3.Internal_Status__c = constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL;
        Case examRegCase4 = new Case();
        examRegCase4.RecordTypeId = epexRTId;
        examRegCase4.ContactId = con.Id;
        examRegCase4.Internal_Status__c = constants.CASE_STATUS_PENDING_ENROLLMENT;
        examRegCase4.ParentId = examRegCase3.Id;
        insert examRegCase4;
        System.assert(examRegCase4.Id != null, ASSERT_ERROR_1);
        test.stopTest();
        RecursiveTriggerHandler.isFirstTime = true;
        update examRegCase3;
        System.assert(examRegCase3.Internal_Status__c == constants.CASE_STATUS_ENROLLMENT_NOT_VERIFIED_MEDSCL, ASSERT_ERROR_2);
        OrgWideEmailAddress addr = [select Id from OrgWideEmailAddress where displayname =: Constants.ORG_WIDE_ADDRESS];
        EmailTemplate emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body from EmailTemplate where DeveloperName =: Constants.EMAIL_TEMPLATE_ECFMG_DUP_CERTIFICATE];
        CaseTriggerHelper.prepareEmail(caseList[0],addr,emailTemplate);
        RecursiveTriggerHandler.isFirstTime = true;
        examRegCase5.Internal_Status__c = Constants.CASE_STATUS_SENT;
        update examRegCase5;
        System.assert(examRegCase5.Internal_Status__c == constants.CASE_STATUS_SENT, ASSERT_ERROR_2);
    } 
    public static testMethod void testUpdateParentCertCase(){
        Group grpECFMGCert = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grpECFMGCert = new Group(Name = Constants.CASE_QUEUE_ECFMG_CERTIFICATION, type = 'Queue');
            insert grpECFMGCert;
            System.assert(grpECFMGCert.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grpECFMGCert.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }       
        Account acc = new Account();
        acc.Name = 'Account Applicant';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, 'Account creation failed');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'TestCon';
        con.Email = 'test4@user.com';
        INSERT con;
        System.assert(con.Id != null, 'Contact creation failed');
        Id ecfmgCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = ecfmgCertRTId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Internal_Status__c = 'Incomplete';
        insert newCase;
        Case newCase2 = new Case();
        newCase2.RecordTypeId = credVerRTId;
        newCase2.ContactId = con.Id;
        newCase2.AccountId = acc.Id;
        newCase2.Internal_Status__c = 'New';
        newCase2.ParentId = newCase.Id;
        insert newCase2;
        newCase2.Internal_Status__c = 'Accepted';
        update newCase2;
    }
    public static testMethod void testUpdateParentCertCaseNeg(){
        Group grpECFMGCert = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs(new User(Id = UserInfo.getUserId())){
            grpECFMGCert = new Group(Name = Constants.CASE_QUEUE_ECFMG_CERTIFICATION, type = 'Queue');
            insert grpECFMGCert;
            System.assert(grpECFMGCert.Id != null, ASSERT_ERROR_1);
            que = new QueueSObject(QueueID = grpECFMGCert.id, SobjectType = 'Case');
            insert que;
            System.assert(que.Id != null, ASSERT_ERROR_1);
        }       
        Account acc = new Account();
        acc.Name = 'Account Applicant';
        acc.BillingCountry=BILLING_COUNTRY;
        INSERT acc;
        System.assert(acc.Id != null, 'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'TestCon';
        con.Email = 'test4@user.com';
        INSERT con;
        System.assert(con.Id != null, 'Contact not created');
        Id ecfmgCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = ecfmgCertRTId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Internal_Status__c = 'Incomplete';
        insert newCase;
        Case newCase2 = new Case();
        newCase2.RecordTypeId = credVerRTId;
        newCase2.ContactId = con.Id;
        newCase2.AccountId = acc.Id;
        newCase2.Internal_Status__c = 'New';
        newCase2.ParentId = newCase.Id;
        insert newCase2;
        Case newCase3 = new Case();
        newCase3.RecordTypeId = credVerRTId;
        newCase3.ContactId = con.Id;
        newCase3.AccountId = acc.Id;
        newCase3.Internal_Status__c = 'New';
        newCase3.ParentId = newCase.Id;
        insert newCase3;
        newCase2.Internal_Status__c = 'Accepted';
        update newCase2;
    }
    @isTest
    public static void testUpdateParentAppforCert(){
        Id appForCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id cvRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'test@test.test';
        INSERT con;
        System.assert(con.Id != null, 'Contact insert failed');
        Case appforcertCase = new Case();
        appforcertCase.RecordTypeId = appForCertRTId;
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_REVIEW;
        appforcertCase.ContactId = con.Id;
        INSERT appforcertCase;
        System.assert(appforcertCase.Id != null, 'AppforCert insert failed');
        Case cvCase = new Case();
        cvCase.RecordTypeId = cvRTId;
        cvCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        cvCase.ContactId = con.Id;
        cvCase.ParentId = appforcertCase.Id;
        INSERT cvCase;
        System.assert(cvCase.Id != null, 'CV case insert failed');
        Case cvCase1 = new Case();
        cvCase1.RecordTypeId = cvRTId;
        cvCase1.Internal_Status__c = Constants.CASE_STATUS_PENDING_EMAIL_CREATION;
        cvCase1.ContactId = con.Id;
        cvCase1.ParentId = appforcertCase.Id;
        Case cvCase2 = new Case();
        cvCase2.RecordTypeId = cvRTId;
        cvCase2.Internal_Status__c = Constants.CASE_STATUS_VERIFICATION_IN_REVIEW;
        cvCase2.ContactId = con.Id;
        cvCase2.ParentId = appforcertCase.Id;
        List<Case> cases = new List<Case>();
        cases.add(cvCase1);
        cases.add(cvCase2);
        INSERT cases;
        System.assert(cvCase1.Id != null, 'CV case insert failed');
        Case oldcvCase = new Case(Id=cvCase.Id, Internal_Status__c=Constants.CASE_STATUS_NEW);
        cvCase.Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED;
        UPDATE cvCase;
        System.assert(cvCase.Id != null, 'CV case update failed');
        RecursiveTriggerHandler.isFirstTimeCV = true;
        CaseTriggerHandler.updateParentAppforCert(new List<Case>{cvCase}, new Map<Id,Case>{cvCase.Id => oldcvCase});
        cvCase.Internal_Status__c = Constants.CASE_STATUS_CV_REJECTED;
        UPDATE cvCase;
        System.assert(cvCase.Id != null, 'CV case update failed');
        RecursiveTriggerHandler.isFirstTimeCV = true;
        CaseTriggerHandler.updateParentAppforCert(new List<Case>{cvCase}, new Map<Id,Case>{cvCase.Id => oldcvCase});
    }
    @isTest
    public static void testInsertForAttestationCase(){
        Id attestationRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_Attestation).getRecordTypeId();
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();   
        Id appForCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = CONTACT_EMAIL;
        con.Attestation_Prerequisite_met__c = false;
        INSERT con;
        System.assert(con.Id != null, ASSERT_ERROR_1);
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        System.assert(cat.Id != null, ASSERT_ERROR_1);
        Case appforcertCase = new Case();
        appforcertCase.RecordTypeId = appForCertRTId;
        appforcertCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_CV;
        appforcertCase.ContactId = con.Id;
        INSERT appforcertCase;
        System.assert(appforcertCase.Id != null, ASSERT_ERROR_1);
        Case attestationCase = new Case();
        attestationCase.RecordTypeId = attestationRTId;
        attestationCase.ContactId = con.Id;
        attestationCase.Case_Type__c = Constants.CASE_TYPE_ATTESTATION_CASE;
        attestationCase.Internal_status__c = Constants.CASE_STATUS_NEW;
        Test.startTest();
        INSERT attestationCase;
        System.assert(attestationCase.Id != null, ASSERT_ERROR_1);
        Case attestationSubCase = new Case();
        attestationSubCase.RecordTypeId = attestationRTId;
        attestationSubCase.Case_Type__c = Constants.CASE_TYPE_ATTESTATION_SUB_CASE;
        attestationSubCase.Internal_status__c = Constants.CASE_STATUS_IN_PROGRESS;
        attestationSubCase.parentId = attestationCase.Id;
        INSERT attestationSubCase;
        System.assert(attestationSubCase.Id != null, ASSERT_ERROR_1);
        RecursiveTriggerHandler.isFirstTime = true;
        attestationSubCase.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE_RESENT_TO_APPLICANT;
        UPDATE attestationSubCase;
        System.assert(attestationSubCase.Id != null, 'Attestation Subcase not updated');
        Case parentCase = [SELECT Internal_status__c FROM Case WHERE Id=: attestationCase.Id WITH SECURITY_ENFORCED];
        System.assertEquals(Constants.CASE_STATUS_INCOMPLETE_RESENT_TO_APPLICANT, parentCase.Internal_Status__c, 'Parent case status not updated');
        RecursiveTriggerHandler.isFirstTime = true;
        attestationCase.Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
        UPDATE attestationCase;
        System.assert(attestationCase.Id != null, 'Attestation Parent Case not updated');
        Contact updatedContact = [SELECT Attestation_Prerequisite_met__c FROM Contact WHERE Id=: con.Id WITH SECURITY_ENFORCED];
        System.assertEquals(true, updatedContact.Attestation_Prerequisite_met__c, 'Contact not updated');
        Test.stopTest();
    }
*/
    // ==================================================================================================
    // This secction was added by Raul Roque of Coastal Cloud
    // ==================================================================================================
    // This method is for testing some methods on the CaseTriggerHandler.cls. Those methods are 
    // createCaseLineItemsOnAfterInsert(), createCaseLineItemsOnAfterUpdate() and createCaseLineItems()
    // ==================================================================================================
    /*@isTest
    static void testCaseLineRecordCreation() {
        // Id caseExamRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id ecfmgCertRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Id credVerRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();

        Test.startTest();

        // =============================================================
        // Creating a Service__c for the test.
        // =============================================================
        Service__c service = new Service__c(Name = 'ECFMG_Certification');
        insert service;
        System.assert(service.Id != null, 'Service not created');

        // Second Service for when it has no product2services
        Service__c service2 = new Service__c(Name = 'EICS');
        insert service2;
        System.assert(service.Id != null, 'Service not created');

        // Creating start and end dates for the product detail records
        Date yesterday = Date.today().addDays(-1);
        Date tomorrow = Date.today().addDays(1);

        // =============================================================
        // Creating a Product (1) and it's related objects
        // =============================================================
        Product2 product1 = new Product2(Name = 'ECFMG_Certification');
        insert product1;
        System.assert(product1.Id != null, 'Product 1 not created');

        Product2Service__c p2s1 = new Product2Service__c(Service_list__c = 'ECFMG_Certification', Product__c = product1.Id, Default__c = true, Quantity__c = 1);
        insert p2s1;
        System.assert(p2s1.Id != null, 'Product2Service 1 not created');

        Product_Detail__c pd1 = new Product_Detail__c();
        pd1.Product__c = product1.Id;
        pd1.Start_Date__c = yesterday;
        pd1.End_Date__c = tomorrow;
        pd1.Service_Fee__c = 1.0;
        insert pd1;
        System.assert(pd1.Id != null, 'Product Detail 1 not created');

        // =============================================================
        // Creating a Product (2) and it's related objects
        // =============================================================
        Product2 product2 = new Product2(Name = 'ECFMG_Certification_Step_2');
        insert product2;
        System.assert(product2.Id != null, 'Product 2 not created');

        Product2Service__c p2s2 = new Product2Service__c(Service_list__c = 'ECFMG_Certification', Product__c = product2.Id, Default__c = false, Quantity__c = 1);
        insert p2s2;
        System.assert(p2s2.Id != null, 'Product2Service 2 not created');

        Product_Detail__c pd2 = new Product_Detail__c();
        pd2.Product__c = product2.Id;
        pd2.Start_Date__c = yesterday;
        pd2.End_Date__c = tomorrow;
        pd2.Service_Fee__c = 2.0;
        insert pd2;
        System.assert(pd2.Id != null, 'Product Detail 2 not created');

        // =============================================================
        // Creating a Product (3) and it's related objects
        // =============================================================
        Product2 product3 = new Product2(Name = 'ECFMG_Certification_Step_3');
        insert product3;
        System.assert(product3.Id != null, 'Product 3 not created');

        Product2Service__c p2s3 = new Product2Service__c(Service_list__c = 'ECFMG_Certification', Product__c = product3.Id, Default__c = true);
        insert p2s3;
        System.assert(p2s3.Id != null, 'Product2Service 3 not created');

        Product_Detail__c pd3 = new Product_Detail__c();
        pd3.Product__c = product3.Id;
        pd3.Start_Date__c = yesterday;
        pd3.End_Date__c = tomorrow;
        pd3.Service_Fee__c = 3.0;
        insert pd3;
        System.assert(pd3.Id != null, 'Product Detail 3 not created');

        // =============================================================
        // Creating a Product (4) and it's related objects
        // =============================================================
        Product2 product4 = new Product2(Name = 'ECFMG_Certification_Step_4');
        insert product4;
        System.assert(product4.Id != null, 'Product 4 not created');

        Product2Service__c p2s4 = new Product2Service__c(Service_list__c = 'ECFMG_Certification', Product__c = product4.Id, Default__c = true);
        insert p2s4;
        System.assert(p2s4.Id != null, 'Product2Service 3 not created');

        // This product detail is out of date but it's the latest.
        Product_Detail__c pd4 = new Product_Detail__c();
        pd4.Product__c = product4.Id;
        pd4.Start_Date__c = Date.today().addDays(-3);
        pd4.End_Date__c = yesterday;
        pd4.Service_Fee__c = 4.0;
        insert pd4;
        System.assert(pd4.Id != null, 'Product Detail 4 not created');

        // This product detail is out of date and it's NOT the latest.
        Product_Detail__c pd5 = new Product_Detail__c();
        pd5.Product__c = product4.Id;
        pd5.Start_Date__c = Date.today().addDays(-6);
        pd5.End_Date__c = Date.today().addDays(-4);
        pd5.Service_Fee__c = 5.0;
        insert pd5;
        System.assert(pd5.Id != null, 'Product Detail 5 not created');

        // =============================================================
        // Creating an account and a contact for the case lines.
        // =============================================================
        Account acc = new Account();
        acc.Name = 'Account Applicant';
        insert acc;
        System.assert(acc.Id != null, 'Account not created');

        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'TestCon';
        con.Email = 'test4@user.com';
        insert con;
        System.assert(con.Id != null, 'Contact not created');

        // =============================================================
        // Creating the new Case Lines
        // =============================================================
        List<Case> newCasesList = new List<Case>();

        // Testing when a case is created with a Service.
        Case newCase1 = new Case();
        newCase1.RecordTypeId = ecfmgCertRTId;
        newCase1.ContactId = con.Id;
        newCase1.AccountId = acc.Id;
        newCase1.Internal_Status__c = 'Incomplete';
        newCase1.Service__c = 'ECFMG_Certification';
        newCasesList.add(newCase1);

        // Testing when a case is created with a Service. 
        Case newCase2 = new Case();
        newCase2.RecordTypeId = credVerRTId;
        newCase2.ContactId = con.Id;
        newCase2.AccountId = acc.Id;
        newCase2.Internal_Status__c = 'New';
        newCase2.Service__c = 'ECFMG_Certification';
        newCasesList.add(newCase2);

        // Testing when a case is created without a Service.
        Case newCase3 = new Case();
        newCase3.RecordTypeId = ecfmgCertRTId;
        newCase3.ContactId = con.Id;
        newCase3.AccountId = acc.Id;
        newCase3.Internal_Status__c = 'Incomplete';
        newCasesList.add(newCase3);

        // Testing when a case is created without a Service.
        Case newCase4 = new Case();
        newCase4.RecordTypeId = credVerRTId;
        newCase4.ContactId = con.Id;
        newCase4.AccountId = acc.Id;
        newCase4.Internal_Status__c = 'New';
        newCasesList.add(newCase4);

        // Testing when a case is created with a Service that doesn't have any product2services. 
        Case newCase5 = new Case();
        newCase5.RecordTypeId = credVerRTId;
        newCase5.ContactId = con.Id;
        newCase5.AccountId = acc.Id;
        newCase5.Internal_Status__c = 'New';
        newCase5.Service__c = 'EICS';
        newCasesList.add(newCase5);

        // Testing when a case is created with a Service that doesn't have a matching Service__c record. 
        Case newCase6 = new Case();
        newCase6.RecordTypeId = credVerRTId;
        newCase6.ContactId = con.Id;
        newCase6.AccountId = acc.Id;
        newCase6.Internal_Status__c = 'New';
        newCase6.Service__c = 'J1';
        insert newCase6;

        insert newCasesList;

        // Making sure the cases where inserted.
        System.assert(newCase1.Id != null, 'newCase1 not created');
        System.assert(newCase2.Id != null, 'newCase2 not created');
        
        // The newCase1 should have 3 Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase1.Id].size(), 'New Case 1: The quantity of case lines does not match the expected.');
        // The newCase2 should have 3 Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase2.Id].size(), 'New Case 2: The quantity of case lines does not match the expected.');
        // The newCase3 should still have 0 Case Lines, since it doesn't have a service.
        System.assertEquals(0, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase3.Id].size(), 'New Case 3: The quantity of case lines does not match the expected.');
        // The newCase4 should still have 0 Case Lines, since it doesn't have a service.
        System.assertEquals(0, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase4.Id].size(), 'New Case 4: The quantity of case lines does not match the expected.');

        // adding a service to the newCase2 and leaving the newCase1 intact.
        newCase3.Service__c = 'ECFMG_Certification';
        newCase4.Service__c = 'ECFMG_Certification';
        // updating the same 4 cases.
        update newCasesList;

        // The newCase1 should still have 3 Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase1.Id].size(), 'New Case 1 updated: The quantity of case lines does not match the expected.');
        // The newCase2 should still have 3 Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase2.Id].size(), 'New Case 2 updated: The quantity of case lines does not match the expected.');
        // The newCase3 should have 3 new Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase3.Id].size(), 'New Case 3 updated: The quantity of case lines does not match the expected.');
        // The newCase4 should have 3 new Case Lines.
        System.assertEquals(3, [SELECT Id FROM Case_Line__c WHERE Case__c = :newCase4.Id].size(), 'New Case 4 updated: The quantity of case lines does not match the expected.');

        Test.stopTest();
    }
    /*@isTest
    public static void testPetitionForReconsrnCaseInsert(){
        Id petForReconRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_PETITION_FOR_RECONSN).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account1';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id != null, ASSERT_ERROR_1);
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = CONTACT_EMAIL;
        INSERT con;
        Case newCase = new Case(); 
        newCase.RecordTypeId = petForReconRTId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Internal_Status__c = 'New';
        insert newCase;
    }*/
}