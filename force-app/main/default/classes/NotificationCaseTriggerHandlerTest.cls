// Test class for NotificationCaseTriggerHandler
@isTest
public with sharing class NotificationCaseTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NOTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id que = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOTIFICATIONS').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(OwnerId=que,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();        
        Case notCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(UserInfo.getUserId(),notCase.OwnerId,'OwnerId is incorrect');
    }
    @isTest
    static void testBeforeInsertOne(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NOTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id usr = UserInfo.getUserId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(OwnerId=usr,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();        
        Case notCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOTIFICATIONS').Value__c),notCase.OwnerId,'Owner is not matched');
    }
    // test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NOTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id que = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOTIFICATIONS').Value__c);
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(OwnerId=que,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
        Update cas;
        Case notCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(UserInfo.getUserId(),notCase.OwnerId,'Owner is incorrect');
    }
    @isTest
    static void testBeforeUpdateOne(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_NOTIFICATION').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id usr = UserInfo.getUserId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(OwnerId=usr,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();        
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        Update cas;
        Case notCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_NOTIFICATIONS').Value__c),notCase.OwnerId,'Owner is incorrect');
    }
}