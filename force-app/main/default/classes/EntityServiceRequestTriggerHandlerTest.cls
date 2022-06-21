// Test class for EntityServiceRequestTriggerHandler
@isTest
public with sharing class EntityServiceRequestTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case esrCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,esrCase.Status,'Status is incorrect');
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id esrRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c);
        Id cvRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_ENTSERVREQ').Value__c);
        Contact con = [SELECT Id,AccountId FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=esrRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        Case cs = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=cvRecTypeId, AccountId=con.AccountId, Entity__c=con.AccountId));
        run();
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ENROLLMENT_COMPLETED').Value__c;
        cas.Type = Constant_Case__mdt.getInstance('TYPE_ENTITY_DETAILS_CHANGE').Value__c;
        Update cas;
        Case esrCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_CLOSED').Value__c,esrCase.Status,'Status is incorrect');
        System.assertEquals(((Constants.QUEUE_DEV_ID_MAP).get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_UPDATE_REQUEST').Value__c)),esrCase.OwnerId,'OwnerId is incorrect');
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        cas.OwnerId = UserInfo.getUserId();
        cas.Type = Constant_Case__mdt.getInstance('TYPE_NEW_ENTITY_REQUEST').Value__c;
        Update cas;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
        cas.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_ENTITY_UPDATE_REQUEST').Value__c);
        Update cas;
        esrCase = [SELECT Id,OwnerId FROM Case WHERE Id =:cas.Id];
        System.assertEquals(UserInfo.getUserId(),esrCase.OwnerId,'Case owner is incorrect');
        cas.Type = Constant_Case__mdt.getInstance('TYPE_ENTITY_DETAILS_CHANGE').Value__c;
        cas.OwnerId = UserInfo.getUserId();
        Update cas;
        cas.ParentId = cs.Id;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        Update cas;
        esrCase = [SELECT Id,Entity__c FROM Case WHERE Id =:cas.Id];
        System.assert(esrCase.Entity__c!=null,'Entity not filled');
    }
}