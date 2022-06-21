// Test class for AppBioChangeCaseTriggerHandler
@isTest
public with sharing class AppBioChangeCaseTriggerHandlerTest extends ECFMGTestFactory{
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
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPLICANT_BIOGRAPHIC_CHANGE').Value__c);
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_IN_REVIEW').Value__c));
        run();
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPLICANT_BIOGRAPHIC_CHANGE').Value__c LIMIT 1];
        Case appBioChangeCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_NOT_APPLICABLE').Value__c,appBioChangeCase.Status,'Status is incorrect');
    }
    // test method for after update
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPLICANT_BIOGRAPHIC_CHANGE').Value__c);
        Case csException = new Case();
        try{
            Test.startTest();
            Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
            Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_ONLINE_NOTARY_SESSION_REINITIATED').Value__c));
            cadmus_core__Doc_Config__c docConfig = (cadmus_core__Doc_Config__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
            run();
            Map<String, cadmus_core__Doc_Config__c> docConfigMap = new Map<String, cadmus_core__Doc_Config__c>();
            docConfigMap.put(docConfig.cadmus_core__View_Customer_DocConfig_Id__c, docConfig);
            System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
            cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_APPLICANT_ACTION_NOTARIZE').Value__c;
            Update cas;
            Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_DEV_APPLICANT_BIOGRAPHIC_CHANGE').Value__c LIMIT 1];
            Case appBioChangeCase = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Applicant_Last_Submission_Date__c,Status,Internal_Status__c FROM Case WHERE Id =: cas.Id];
            appBioChangeCase.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_ONLINE_NOTARY_SESSION_REINITIATED').Value__c;
            Update appBioChangeCase;
            csException.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_APPLICANT_ACTION_NOTARIZE').Value__c;
            update csException;
            Test.stopTest();
        }catch(Exception ex){
            system.debug('Error'+ex);
        }
    }
}