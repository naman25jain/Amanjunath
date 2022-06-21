// Test class for ECFMGCertificateTriggerHandler
@isTest
public with sharing class ECFMGCertificateTriggerHandlerTest extends ECFMGTestFactory{
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
    }
    // test method for insert
    @isTest
    static void testInsert(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
		Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case paperCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,paperCase.Status,'Status is incorrect');
    }
    // Test method for update
    @isTest
    static void testUpdate(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ECFMG_CERTIFICATION').Value__c);
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'ECFMG Certificate', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ECFMG_CERT').Value__c));
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_PRINT').Value__c;
        Update cas;
        try{
            cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT').Value__c;
            Update cas;
        }catch(Exception e){}
        Case ecfmgCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,ecfmgCase.Status,'Status is incorrect');
    }
}