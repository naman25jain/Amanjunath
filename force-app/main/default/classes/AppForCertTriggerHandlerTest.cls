// Test class for AppForCertTriggerHandler
@isTest
public with sharing class AppForCertTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c LIMIT 1];
        Case appforcertCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(serviceRec.Case_Service__c,appforcertCase.Case_Service__c,'Service is incorrect');
        System.assertEquals(serviceRec.Case_Service_Family__c,appforcertCase.Case_Service_Family__c,'Service Family is incorrect');
        System.assertEquals(serviceRec.Case_Service_Line__c,appforcertCase.Case_Service_Line__c,'Service Line is incorrect');
        System.assertEquals(Date.today(),appforcertCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,appforcertCase.Status,'Status is incorrect'); 
    }
    // test method for before insert
    @isTest
    static void testBeforeInsert1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c));
        run();
        Case appforcertCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect'); 
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c;
        Update cas;
        Case appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];        
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c),appforcertCase.OwnerId,'OwnerId is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_INCOMPLETE').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect');
        appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),appforcertCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');    
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate1(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_CRED_VER').Value__c;
        Update cas;
        Case appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];        
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c),appforcertCase.OwnerId,'OwnerId is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_PENDING_CRED_VER').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect');
        appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Date.today(),appforcertCase.Applicant_Last_Submission_Date__c,'Applicant Last submission date is incorrect');    
    }
    // Test method for after insert
    @isTest
    static void testAfterInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_CIBIS').Value__c));
        run();
    }
    // Test method for after update for Accepted
    @isTest
    static void testAfterUpdateAccepted(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c;
       	Update cas;        
        Case appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];        
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c),appforcertCase.OwnerId,'OwnerId is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_ACCEPTED').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect');
	}
    // Test method for after update for Rejected
    @isTest
    static void testAfterUpdateRejected(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPFORCERT').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Case appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];        
        Id assetRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Asset',Constant_Asset__mdt.getInstance('RECORD_TYPE_CREDENTIAL').Value__c);
        Asset ass1 = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssetData.class, new Asset(Name='Final Medical Diploma', RecordTypeId=assetRecTypeId, ContactId=con.Id, Case__c = appforcertCase.Id, Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Type__c = 'Final Medical Diploma'));
		insert ass1;
        appforcertCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c);
        appforcertCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c;
       	update appforcertCase;
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_APP_FOR_CERT').Value__c),appforcertCase.OwnerId,'OwnerId is incorrect');
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_REJECTED').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect');
        System.assertEquals(ass1.Case__c,appforcertCase.Id,'Asset is not created');
    }
}