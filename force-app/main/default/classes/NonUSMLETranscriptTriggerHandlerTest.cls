// Test class for NonUSMLETranscriptRequestTriggerHandler
@isTest
public with sharing class NonUSMLETranscriptTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c LIMIT 1];
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,nonUsmleCase.Status,'Status is incorrect');
    }
    // test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c));
        run();
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
        Update cas;
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c LIMIT 1];
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
    }
    // test method for after update
    @isTest
    static void testAfterUpdate1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_NON_USMLE_TRANSCRIPT').Value__c);
        Id parCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case parcas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=parCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c));
        run();
        Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
        Case nonUsmleCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        nonUsmleCase.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
        nonUsmleCase.ParentId = parcas.Id;
        Update nonUsmleCase;    
    }
}