@isTest
public with sharing class DeliverEventsTest extends ECFMGTestFactory {
    
    @TestSetup
    static void makeData(){

        Id caseIdentityVerificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        Id usmleTranscriptRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_USMLE_TRANSCRIPT).getRecordTypeId();
        Id appForCertRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_APP_FOR_CERT).getRecordTypeId();
        Id idMedicalSchoolRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        cadmus_core__Doc_Config__c docConfig1 = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'USMLE_TRANSCRIPT', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c));
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts'));
        Case case1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseIdentityVerificationRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS));
        Case case2 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=usmleTranscriptRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS));
        Case case3 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=appForCertRecordTypeId, Internal_Status__c=Constants.CASE_STATUS_ERROR_CIBIS));
        Contact_Association_Type__c conAssociation = (Contact_Association_Type__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idMedicalSchoolRecordType, Account__r=acc, Case__r=case1));
        run();
    }

    @isTest
    public static void invokeDeliverEvents(){
        List<Case> caseRecords = [SELECT Id, Internal_Status__c, RecordTypeId, ContactId FROM Case];
        for(Case eachRecord: caseRecords){
            DeliverEvents.publishEvents(eachRecord.Id, eachRecord.RecordTypeId,eachRecord.Internal_Status__c);
        }
    }
}