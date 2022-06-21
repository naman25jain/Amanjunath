// Test class for IFOMRequestTriggerHandler
@isTest
public with sharing class IFOMRequestTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_IFOM_REQUEST').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_IFOM_REQUEST').Value__c LIMIT 1];
        Case ifomCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(serviceRec.Case_Service__c,ifomCase.Case_Service__c,'Service is incorrect');
        System.assertEquals(serviceRec.Case_Service_Family__c,ifomCase.Case_Service_Family__c,'Service Family is incorrect');
        System.assertEquals(serviceRec.Case_Service_Line__c,ifomCase.Case_Service_Line__c,'Service Line is incorrect');
        System.assertEquals(Date.today(),ifomCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,ifomCase.Status,'Status is incorrect');
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_IFOM_REQUEST').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_VERIFICATION_INCO').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_RECEIVED_IN_REVIEW').Value__c;
        Update cas;
        Case ifomCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,ifomCase.Status,'Status is incorrect');
        System.assertEquals(((Constants.QUEUE_DEV_ID_MAP).get(Constant_Case__mdt.getInstance('QUEUE_ENROLLMENT_VERIFICATION').Value__c)),ifomCase.OwnerId,'OwnerId is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c,ifomCase.Internal_Status__c,'Internal Status is incorrect');
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c;
        Update cas;
        ifomCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),ifomCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
    }
}