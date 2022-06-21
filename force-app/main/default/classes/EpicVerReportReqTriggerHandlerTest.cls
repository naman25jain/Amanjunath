// Test class for EpicVerReportReqTriggerHandlerTest
@isTest
public with sharing class EpicVerReportReqTriggerHandlerTest extends ECFMGTestFactory{
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id accRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Account','Entity');        
        Account entityAcc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Entity', RecordTypeId=accRecTypeId));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = entityAcc));
        run();
    }
    // Test method for before insert
    @isTest
    static void testBeforeInsert(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        Case appforcertCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,appforcertCase.Status,'Status is incorrect'); 
    }
    // Test method for before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c;
        Update cas;
        Case appforcertCase = [SELECT Id,OwnerId,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];        
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c,appforcertCase.Internal_Status__c,'Internal Status is incorrect');
	}
    // Test method for before insert
    @isTest
    static void testAfterInsert(){
        Account entityAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Entity' ORDER BY CreatedDate DESC LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);        
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c,Service__c = Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c, Entity__c=entityAcc.Id,Do_Not_Know_Orgs_to_send_EPIC_Reports__c=true));        
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EPIC Report Page', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('EPIC_VER_REPORT_REQUEST').Value__c));        
        run();
        Id cvCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c);
        Case evpCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, Secondary_Parent_Case__c=cas.Id, RecordTypeId=cvCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c, Entity__c=entityAcc.Id, Issuing_Entity__c = cas.Entity__c));
        run();
        System.assert(evpCase.Id != NULL, 'Epic Ver Report Request is not created');
        System.assertEquals(evpCase.Secondary_Parent_Case__c,cas.Id,'No Parent for Epic Ver Report Request');
        System.assertEquals(false, [SELECT Id,Do_Not_Know_Orgs_to_send_EPIC_Reports__c FROM Case WHERE Id =:cas.Id].Do_Not_Know_Orgs_to_send_EPIC_Reports__c,'Parent CV Case Do_Not_Know_Orgs_to_send_EPIC_Reports__c is not updated');
       	Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
        docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
        System.assert(docConfig.Id != NULL, 'EPIC Report Page failed.');
	}
    // Test method for before insert
    @isTest
    static void testAfterUpdate(){
        Account entityAcc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Entity' ORDER BY CreatedDate DESC LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_CREDENTIAL_VERIFICATION').Value__c);        
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c,Service__c = Constant_Case__mdt.getInstance('SERVICE_EPIC').Value__c, Entity__c=entityAcc.Id));        
        cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EPIC Report Page', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('EPIC_VER_REPORT_REQUEST').Value__c));        
        run();
        Id cvCaseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_EPIC_VER_REPORT_REQUEST').Value__c);
        Case evpCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, Secondary_Parent_Case__c=cas.Id, RecordTypeId=cvCaseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_NEW').Value__c, Entity__c=entityAcc.Id, OwnerId = userInfo.getUserId()));
        insert evpCase;
        System.assert(evpCase.Id != NULL, 'Epic Ver Report Request is not created');
        System.assertEquals(evpCase.Secondary_Parent_Case__c,cas.Id,'No Parent for Epic Ver Report Request');
        Id accountRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Account','Entity');        
        Account entityAccount = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Entity Military', RecordTypeId=accountRecTypeId));
        evpCase.Entity__c = entityAccount.Id;
        evpCase.OwnerId = Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VERIFICATION_PENDING').Value__c);
        update evpCase;
        System.assertEquals(entityAccount.Id,evpCase.Entity__c,'Entity is incorrect');
        System.assertEquals(Constants.QUEUE_DEV_ID_MAP.get(Constant_Case__mdt.getInstance('QUEUE_VERIFICATION_PENDING').Value__c), evpCase.OwnerId,'Owner update is failed');
	}
}