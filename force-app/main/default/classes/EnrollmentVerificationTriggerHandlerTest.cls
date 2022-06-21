/**
* @description Test class for EnrollmentReVerCaseTriggerHandler
*/
@isTest
public with sharing class EnrollmentVerificationTriggerHandlerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id idMedicalSchoolRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id idOtherInstitutionRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_OTHER_INSTITUTION).getRecordTypeId();
        Id idDegreeMedicalRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idMedicalSchoolRecordType, Account__r=acc,Transfer_Credit_to_Degree_School__c=true,Number_of_Years_Attended__c=1));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idOtherInstitutionRecordType, Account__r=acc,Transfer_Credit_to_Degree_School__c=true,Number_of_Years_Attended__c=1));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idDegreeMedicalRecordType, Account__r=acc,Transfer_Credit_to_Degree_School__c=true,Number_of_Years_Attended__c=1));
        run();
    }
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c)); 
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EVR Customer Doc Config', cadmus_core__CustomerDocumentConfigId__c =Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c));
        run();
        system.assert(cas.id!=null,'case is not inserted');
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=cas.id,Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
        update cas;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c;
        update cas;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        update cas;
        cas.Internal_Status__c =Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c;
        cas.Enrolled_in_Entity_Portal__c = false;
        update cas;
    }
    
    @isTest
    static void testAfterUpdate(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=0
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
		system.assert(cas.id!=null,'case is not inserted');        
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=cas.id,Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
        cas.Enrolled_in_Entity_Portal__c =true;
        cas.Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
        cas.Passed_basic_sciences_course__c=Constant_Case__mdt.getInstance('STATUS_YES').Value__c;
        cas.Number_of_Years_Attended__c =1;
        Update cas;
    }
    
    @isTest
    static void testAfterUpdateEVCaseVerStatus(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=0
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=cas.id,Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
        cas.Enrolled_in_Entity_Portal__c =true;
        cas.Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
        cas.Passed_basic_sciences_course__c=Constant_Case__mdt.getInstance('STATUS_YES').Value__c;
        cas.Number_of_Years_Attended__c =1;
        cas.Attendance_Start_Month__c = 'January';
        cas.Attendance_End_Month__c ='January';
        cas.Graduation_Month__c ='January';
        cas.Degree_Month__c = 'January';
        Update cas;
        
    }
    
    @isTest
    static void testAfterUpdateManageEVFrom(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=0
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=cas.id,Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EVR Customer Doc Config', cadmus_core__CustomerDocumentConfigId__c =Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Enrolled_in_Entity_Portal__c =true;
        cas.Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_DECEASED').Value__c;
        Update cas;
        
    }
    
    @istest
    static void testAfterUpdatesystemCheckEVCase(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        cas.Enrolled_in_Entity_Portal__c =true;
        cas.Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
        cas.Passed_basic_sciences_course__c=Constants.STATUS_NO;
        Update cas;
    }
    
    @istest
    static void testAfterUpdatehandleEVCase(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        Case cas2 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId =cas1.id,Enrollment_Verification_Parent__c=cas1.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        cas.Enrolled_in_Entity_Portal__c =true;
        cas.Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_WITHDRAWN').Value__c;
        Update cas;
    }
    @istest
    static void testAfterUpdatesystemCheckRejectedEVCase3(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c)); 
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
        cas.Verification_Status__c = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
        Update cas;
    }
    
    @istest
    static void testAfterUpdateCATGraduated(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
        cas.Verification_Status__c = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_GRADUATED').Value__c;
        Update cas;
    }
    
    @istest
    static void testAfterUpdateHandleEVCase1(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO
                                                                                                    ,Verification_Status_Date__c = date.today()));
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId =cas1.id,Enrollment_Verification_Parent__c=cas1.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
        cas.Verification_Status__c = Constant_Case__mdt.getInstance('VERIFICATION_WITHDRAWN').Value__c;
        Update cas;
    }
    
    @istest
    static void testAfterUpdateHandleEVCase2(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c
                                                                                                    ,Contact=con, RecordTypeId=caseRecTypeId 
                                                                                                    ,Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c
                                                                                                    ,Number_of_Years_Attended__c=1
                                                                                                    ,Passed_basic_sciences_course__c = Constants.STATUS_NO));
        
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId =cas1.id,Enrollment_Verification_Parent__c=cas1.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        cas.Passed_basic_sciences_course__c =Constant_Case__mdt.getInstance('STATUS_YES').Value__c;
        cas.Enrolled_in_Entity_Portal__c = true;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_COMPLETE').Value__c;
        cas.Verification_Status__c = Constant_Case__mdt.getInstance('VERIFICATION_STATUS_ENROLLED').Value__c;
        Update cas;
    }
    
    
    @isTest
    static void testAfterUpdate1(){
        String examType = 'USMLE Step 1';
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_VERIFICATION').Value__c);
        Id caseRecTypeExamRegId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_EXAM_REGISTRATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Deficiency_Reason_RTF__c='test',Signature_Date__c=Date.Today().addDays(50), Verification_Status__c=Constant_Case__mdt.getInstance('VERIFICATION_STATUS_NOT_REVIEWED').Value__c,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        system.assert(cas.id!=null,'case is not inserted');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Enrollment_Verification_Parent__c=cas.id, Contact=con, RecordTypeId=caseRecTypeExamRegId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_ENROLLMENT').Value__c));
        run();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = '', Exam_Types__c = examType, Case__c = cas1.id));
        run();
        cas.Enrolled_in_Entity_Portal__c =false;
        cas.Internal_Status__c =Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c;
        Update cas;
    }
}