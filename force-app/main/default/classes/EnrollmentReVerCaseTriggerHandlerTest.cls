/**
 * @description Test class for EnrollmentReVerCaseTriggerHandler
 */
@isTest
public with sharing class EnrollmentReVerCaseTriggerHandlerTest extends ECFMGTestFactory{
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        cadmus_core__Doc_Config__c defCovLetDocConfigId = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EnReverification Deficiency Cover Letter', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ERV_DEF_COV_LETTER').Value__c));
        cadmus_core__Doc_Config__c customerDocConfigId = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EVR Customer Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ERV_CUSTOMER').Value__c));
        run();
    }
    // test method for before insert
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        Case enrollReVerifCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c,enrollReVerifCase.Internal_Status__c,'Status is incorrect');
    }
    
    // Test method for after insert
    @isTest
    static void testAfterInsertStatusNew(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case enrollReverifcase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NEW').Value__c,enrollReverifcase.Internal_Status__c,'Status is incorrect');
    }
    
    // Test method for after insert
    @isTest
    static void testAfterInsertStatusIncomplete(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case enrollReverifcase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c));
        run();
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c,enrollReverifcase.Internal_Status__c,'Status is incorrect');
    }
    
    // test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
        Update cas;
        Case enrollReVerifCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c,enrollReVerifCase.Internal_Status__c,'Status is incorrect');
    }
    
    // test method for after update
    @isTest
    static void testAfterUpdateStatusNew(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        Update cas;
        Case enrollReVerifCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NEW').Value__c,enrollReVerifCase.Internal_Status__c,'Status is incorrect');
        
        enrollReVerifCase.Internal_Status__c= Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c;
        Update enrollReVerifCase;

        Case enrollReVerifCase2 = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: enrollReVerifCase.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c,enrollReVerifCase2.Internal_Status__c,'Status is incorrect');
    }

    //test method for updates resend SLA date
    @isTest
    static void testUpdateResendSLADate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_ENROLLMENT_REVERIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
        Update cas;
        Case enrollReVerifCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c,Resend_SLA_Date__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_SENT').Value__c,enrollReVerifCase.Internal_Status__c,'Status is incorrect');
        System.assertEquals(Date.today().addDays(90),enrollReVerifCase.Resend_SLA_Date__c,'Resend SLA Date is incorrect');
    }
}