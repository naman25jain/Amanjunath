// Test class for InvestigationCaseTriggerHandler
@isTest
public with sharing class InvestigationCaseTriggerHandlerTest extends ECFMGTestFactory{
    public static final String EXAM_IRREGULAR = 'EXAM IRREGULAR';
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case relTransCas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Annotation__c = 'Standard', Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, Related_Transcript_Case__c = relTransCas.Id, Annotation_Text_for_Specialized__c = 'Testing'));
        Transcript_Anotation__c transAnn = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        run();
        Transcript_Anotation__c transAnnRec1 = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec1.Transcript_Case__c = cas.Id;
        transAnnRec1.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec1;
        Transcript_Anotation__c transAnnRec = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec.Transcript_Case__c = cas.Id;
        transAnnRec.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec;
        cas.Annotation__c = 'Specialized';
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        RecursiveTriggerHandler.isFirstTimeInvestigation = true;
        Update cas;
        cas.Annotation__c = NULL;
        RecursiveTriggerHandler.isFirstTimeInvestigation = true;
        Update cas;
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,cas.Internal_Status__c,'Status is incorrect');
    }
    @isTest
    static void testBeforeInsertOther(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case relTransCas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Annotation__c = 'Standard', Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, Related_Transcript_Case__c = relTransCas.Id, Annotation_Text_for_Specialized__c = 'Testing'));
        Case casNew = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Annotation__c = 'Standard', Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, Related_Transcript_Case__c = relTransCas.Id, Annotation_Text_for_Specialized__c = 'Testing'));
        Transcript_Anotation__c transAnn = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        run();
        Transcript_Anotation__c transAnnRec1 = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec1.Transcript_Case__c = cas.Id;
        transAnnRec1.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec1;
        Transcript_Anotation__c transAnnRec = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec.Transcript_Case__c = casNew.Id;
        transAnnRec.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec;
        cas.Annotation__c = 'Specialized';
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        RecursiveTriggerHandler.isFirstTimeInvestigation = true;
        Update cas;
        cas.Annotation__c = NULL;
        RecursiveTriggerHandler.isFirstTimeInvestigation = true;
        Update cas;
        casNew.Annotation__c = NULL;
        RecursiveTriggerHandler.isFirstTimeInvestigation = true;
        Update casNew;
        System.assertEquals(NULL,casNew.Annotation__c,'Annotation is incorrect');
    }
    // test method for after insert
    @isTest
    static void testAfterInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c);
        Id assRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('REC_TYPE_INVESTIGATION').Value__c);        
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate ASC LIMIT 1];
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst', RecordTypeId=assRecTypeId, ContactId=con1.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_ECFMG_CERTIFICATE').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst 1', RecordTypeId=assRecTypeId, ContactId=con.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_DUPLICATE_ECFMG_CERTIFICATE').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, 
                                                                                                    Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, 
                                                                                                    Annotation_Text_for_Specialized__c = 'Testing', 
                                                                                                    Committee_Action__c = Constant_Case__mdt.getInstance('COMMITTEE_ACTION_REV_ECFMG_CERT').Value__c, 
                                                                                                    Revocation_Date__c = System.today(),
                                                                                                    Timeline__c = Constant_Case__mdt.getInstance('TIMELINE_PERMANENT').Value__c,
                                                                                                    Annotation__c = 'Specialized'));
        run();
        System.assert(cas.Id != NULL, 'Case creation failed.');
    }
    // test method for after insert
    @isTest
    static void testAfterInsert1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c);
        Id assRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('REC_TYPE_INVESTIGATION').Value__c);        
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate ASC LIMIT 1];
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst', RecordTypeId=assRecTypeId, ContactId=con1.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_ECFMG_CERTIFICATE').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst 2', RecordTypeId=assRecTypeId, ContactId=con.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_DUPLICATE_ECFMG_CERTIFICATE').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, 
                                                                                                    Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, 
                                                                                                    Annotation_Text_for_Specialized__c = 'Testing', 
                                                                                                    Committee_Action__c = Constant_Case__mdt.getInstance('COMMITTEE_ACTION_REV_ECFMG_CERT').Value__c, 
                                                                                                    Timeline__c = '2 years',
                                                                                                    Revocation_Date__c = system.today(),
       																								Reinstatement_Date__c = system.today(),
                                                                                                    Annotation__c = 'Specialized'));
        run();
        System.assert(cas.Id != NULL, 'Case creation failed.');
    }
    @isTest
    static void testAfterUpdateTrans(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_INVESTIGATION_CASE').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c);
        Id assRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('REC_TYPE_INVESTIGATION').Value__c);        
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Contact con1 = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate ASC LIMIT 1];      
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, Irregular_Behavior_Annotated__c = false));
        Case relTransCas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Annotation__c = 'Standard', Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c, Related_Transcript_Case__c = relTransCas.Id));
        Transcript_Anotation__c transAnn = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        Transcript_Anotation__c transAnn1 = (Transcript_Anotation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultTranscriptAnnotationTestData.class, new Transcript_Anotation__c(Transcript_Case__c = cas.Id, USMLE_Transcripts_Notes__c = null));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst', RecordTypeId=assRecTypeId, ContactId=con1.Id, Case__c = cas.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_ECFMG_CERTIFICATE').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name='Asst 3', RecordTypeId=assRecTypeId, ContactId=con.Id, Case__c = cas.Id, Status = Constant_Asset__mdt.getInstance('STATUS_ACCEPTED').Value__c, Type__c = Constant_Asset__mdt.getInstance('TYPE_DUPLICATE_ECFMG_CERTIFICATE').Value__c));
        run();
        Transcript_Anotation__c transAnnRec1 = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn.Id];
        transAnnRec1.Transcript_Case__c = cas.Id;
        transAnnRec1.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec1;
        Transcript_Anotation__c transAnnRec = [SELECT Id,Transcript_Case__c, Cibis_Transcript_Status__c FROM Transcript_Anotation__c WHERE Id =: transAnn1.Id];
        transAnnRec.Transcript_Case__c = cas.Id;
        transAnnRec.Cibis_Transcript_Status__c = EXAM_IRREGULAR;
        Update transAnnRec;
        cas.Committee_Action__c = Constant_Case__mdt.getInstance('COMMITTEE_ACTION_REV_ECFMG_CERT').Value__c;
        cas.Revocation_Date__c = System.today();
        cas.Timeline__c = Constant_Case__mdt.getInstance('TIMELINE_PERMANENT').Value__c;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
        cas.Annotation__c = 'Specialized';
        cas.Related_Transcript_Case__c = relTransCas.Id;
        cas.Annotation_Text_for_Specialized__c = 'Testing';
        Update cas;
        cas.Annotation__c = 'Standard';
        cas.Timeline__c = 'Sponsorship Language';
        cas.Revocation_Date__c = system.today();
        cas.Reinstatement_Date__c = system.today();
        Update cas;
        System.assertEquals('Standard',cas.Annotation__c,'Annotation is incorrect');
    }
}