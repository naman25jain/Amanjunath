// Test class for BiographicReviewCaseTriggerHandler
@isTest
public with sharing class BiographicReviewCaseTriggerHandlerTest extends ECFMGTestFactory{
    // Case Object
    public static final String CASE_OBJ = 'Case';
    public static final String STATUS_INCORRECT = 'Status is incorrect';
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'ECFMG Certificate', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ECFMG_CERT').Value__c));
        run();
    }
    // test method for before insert
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case bioRevCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),bioRevCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,bioRevCase.Status,STATUS_INCORRECT);
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        Update cas;
        Case bioRevCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,bioRevCase.Status,STATUS_INCORRECT);
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,bioRevCase.Internal_Status__c,'Internal Status is incorrect');
        System.assertEquals(Date.today(),bioRevCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
    }
    // Test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_DEV_BIOGRAPHIC_REVIEW').Value__c);
        Id ecfmgIdRecordId = GenericUtilities.getRecordTypeIdByDevName(CASE_OBJ,Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case casECFMG = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=ecfmgIdRecordId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c));
        run();
        system.debug(CaseTriggerUtility.populateDocConfig());
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c,ParentId = casECFMG.Id));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
        Update cas;
        Case ecfmgCaseRec= [SELECT Id,Internal_Status__c FROM Case WHERE Id =: casECFMG.Id];
        Case bioRevCaseRec= [SELECT Id,Applicant_Last_Submission_Date__c,Status FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c,bioRevCaseRec.Status,STATUS_INCORRECT);
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,ecfmgCaseRec.Internal_Status__c,'Internal Status is incorrect');
    }
}