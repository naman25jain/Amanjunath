// Test class for ScoreRecheckTriggerHandler
@isTest
public with sharing class ScoreRecheckTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_SCORE_RECHECK').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_SCORE_RECHECK').Value__c LIMIT 1];
        Case scoreRecheckCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c,External_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(serviceRec.Case_Service__c,scoreRecheckCase.Case_Service__c,'Service is incorrect');
        System.assertEquals(serviceRec.Case_Service_Family__c,scoreRecheckCase.Case_Service_Family__c,'Service Family is incorrect');
        System.assertEquals(serviceRec.Case_Service_Line__c,scoreRecheckCase.Case_Service_Line__c,'Service Line is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,scoreRecheckCase.Status,'Status is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_SUBMITTED_IN_REVIEW').Value__c,scoreRecheckCase.External_Status__c,'External Status is incorrect');
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_SCORE_RECHECK').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'Score Recheck Letter', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('Score_Recheck').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_RECEIVED').Value__c;
        cas.Case_Outcome__c = Constant_Case__mdt.getInstance('CASE_OUTCOME_NO_CHANGE_IN_SCORE_RESULT').Value__c;
        Update cas;
        Case scoreRecheckCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c,External_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c,scoreRecheckCase.Status,'Status is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c,scoreRecheckCase.Internal_Status__c,'Internal Status is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c,scoreRecheckCase.External_Status__c,'External Status is incorrect');
    }
    // Test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_SCORE_RECHECK').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'Score Recheck Letter', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('Score_Recheck').Value__c));
        run();
        System.assert(docConfig.Id != NULL, 'DocConfig creation failed.');
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
        cas.Case_Outcome__c = Constant_Case__mdt.getInstance('CASE_OUTCOME_NO_CHANGE_IN_SCORE_RESULT').Value__c;
        Update cas;
    }
}