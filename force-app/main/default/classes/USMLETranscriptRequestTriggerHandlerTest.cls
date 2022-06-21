// Test class for USMLETranscriptRequestTriggerHandler
@isTest
public with sharing class USMLETranscriptRequestTriggerHandlerTest extends ECFMGTestFactory{
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
    }
    // test method for before insert
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c LIMIT 1];
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,nonUsmleCase.Status,'Status is incorrect');
    }
    // test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));
        run();
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
        Update cas;
    }
    // test method for after update
    @isTest
    static void testAfterUpdate1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));
        run();
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        nonUsmleCase.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
        nonUsmleCase.ParentId = parcas.Id;
        Update nonUsmleCase; 
        Case nonUsmleCase1 = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];   
        nonUsmleCase1.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
        Update nonUsmleCase1;
        System.assertEquals(nonUsmleCase.ParentId != NULL, TRUE);
    }
    @isTest
    static void testAfterUpdateTrans(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        Case relTransCas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        Transcript_Anotation__c transAnn = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        Transcript_Anotation__c transAnn1 = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        Exam_Registration__c exmReg = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = 'Pass', Exam_Types__c = 'USMLE Step 1', Applicant__c = con.Id));
        Exam_Registration__c exmReg1 = (Exam_Registration__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultExamRegistrationTestData.class, new Exam_Registration__c(Exam_Status__c = 'Pass', Exam_Types__c = 'USMLE Step 1', Applicant__c = con.Id));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));
        run();
        relTransCas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
        Update relTransCas;
        cas.Related_Transcript_Case__c = relTransCas.Id;
        Update cas;
        Transcript_Anotation__c transAnnRec = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec.Transcript_Case__c = cas.Id;
        transAnnRec.Cibis_Transcript_Status__c = 'EXAM IRREGULAR';
        Update transAnnRec;
        exmReg.Exam_taken_date__c = system.today();
        Update exmReg;
        exmReg1.Exam_taken_date__c = system.today();
        Update exmReg1;
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        nonUsmleCase.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
        Update nonUsmleCase; 
        Case nonUsmleCase1 = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        nonUsmleCase1.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
        nonUsmleCase1.Related_Transcript_Case__c = parcas.Id;
        Update nonUsmleCase1; 
        parcas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c;
        Update parcas;
        Case nonUsmleCase2 = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        nonUsmleCase2.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_APPROVED').Value__c;
        nonUsmleCase2.Related_Transcript_Case__c = parcas.Id;
        Update nonUsmleCase2; 
        System.assertEquals(nonUsmleCase2.Related_Transcript_Case__c != NULL, TRUE);
    }
}