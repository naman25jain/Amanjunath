// Test class for NameReviewCaseTriggerHandler
@isTest
public with sharing class NameReviewCaseTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NAME_REVIEW').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case nameReviewCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),nameReviewCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,nameReviewCase.Status,'Status is incorrect');
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NAME_REVIEW').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
        cas.ParentId = parcas.Id;
        Update cas;
        Case nameReviewCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c,nameReviewCase.Status,'Status is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,nameReviewCase.Internal_Status__c,'Internal Status is incorrect');
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        Update cas;
        nameReviewCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),nameReviewCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
    }
}