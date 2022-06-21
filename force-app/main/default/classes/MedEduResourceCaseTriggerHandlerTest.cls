// Test class for MedEduResourceCaseTriggerHandler
@isTest
public with sharing class MedEduResourceCaseTriggerHandlerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));		
        Id caseParentRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c);
        Case parentCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con,RecordTypeId=caseParentRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));                              
        run();        
    }
    // test method for before insert
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        List<Case> pt = new List<Case>();
        pt = [SELECT Id,Internal_Status__c FROM Case WHERE RecordType.DeveloperName =: Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id parentId = null;
        if(!pt.isempty()){
            parentId = pt[0].Id;
        }
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentId,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));        
        run();        
        Case medCase = [SELECT Id,OwnerId,Case_Type__c,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MEDICAL_EDUCATION_RESOURCES').Value__c),medCase.OwnerId,'Owner is incorrect');
    }
    // test method for before update
    @isTest
    static void testBeforeUpdate(){
 		Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        List<Case> pt = new List<Case>();
        pt = [SELECT Id,Internal_Status__c FROM Case WHERE RecordType.DeveloperName =: Constant_Case__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_RESOURCES').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id parentId = null;
        if(!pt.isempty()){
            parentId = pt[0].Id;
        }
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentId,Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));        
        run(); 
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_NEW').Value__c;
        Update cas;
        Case medCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_MEDICAL_EDUCATION_RESOURCES').Value__c),medCase.OwnerId,'OwnerId is incorrect');
    }
}