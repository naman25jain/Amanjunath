// Test class for AttestationTriggerHandler
 @isTest
public with sharing class AttestationTriggerHandlerTest extends ECFMGTestFactory{
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id idMedicalSchoolRecordType = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id caseRecTypeIdAppforCert = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, new Contact_Association_Type__c(Contact__r=con, RecordTypeId=idMedicalSchoolRecordType, Account__r=acc));
   		ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeIdAppforCert, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c));
        run();
    }
     // test method for before insert
    @isTest
    static void testBeforeInsert(){
        final String TYPE_ATTESTATION_CASE = Constant_Case__mdt.getInstance('TYPE_ATTESTATION_CASE').Value__c;
        final String TYPE_ATTESTATION_SUB_CASE = Constant_Case__mdt.getInstance('TYPE_ATTESTATION_SUB_CASE').Value__c;
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Case parentCase =[SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Test.startTest();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,Case_Type__c=TYPE_ATTESTATION_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_SUB_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas3 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas4 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas5 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_SUB_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas3.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_CANCELLED').Value__c;
        update cas3;
        cas4.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
        update cas4;
        cas5.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_INCOMPLETE_RESENT_TO_APPLICANT').Value__c;
        update cas5;
        system.assert(cas5.id!=null,'case is not updated');
        Test.StopTest();
        }
      @isTest
    static void testAfterInsert(){
        String message;
        final String TYPE_ATTESTATION_CASE = Constant_Case__mdt.getInstance('TYPE_ATTESTATION_CASE').Value__c;
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ATTESTATION').Value__c);
        Case parentCase =[SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        try{
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
            run();
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id,Contact=con,Case_Type__c=TYPE_ATTESTATION_CASE, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
            run();
        }catch(exception e){
            message = e.getMessage();
        }
        system.assert(message.contains('This Applicant does not have an open Application for Certification case'), 'message=' + message);
    }
}