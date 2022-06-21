@isTest
public class CasePBActionsHandlerTest{
    @isTest
    static void casePBActionsHandlerTestMethod(){
        CasePBActionsHandler casePB = new CasePBActionsHandler();
    }
    //Creating Test data
    /*@testSetup
    public static void createTestData(){
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id entityRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = entityRecTypeId;
        acc.BillingCity = 'test';
        acc.BillingCountry = 'India';
        acc.BillingPostalCode = '1234';
        acc.BillingState = 'West Bengal';
        acc.BillingStreet = 'test';
        insert acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        
        Id recordTypeIdCat = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.recordTypeId = recordTypeIdCat;
        cat.Account__c = con.AccountId;
        cat.Contact__c = con.Id;
        cat.Status__c = 'Student';
        cat.Type__c = Constants.CONASCTYPE_TYPE_DEGREE_SCHOOL;
        insert cat;
    }
    private static Case createTetaRecord(Id recortTypeId, String internalStatus, Id contactId){
        return createTetaRecord(RecortTypeId, internalStatus, contactId, null);
    }
    
    private static Case createTetaRecord(Id recortTypeId, String internalStatus, Id contactId, Id parentId){
        Case evCase = new Case();
        evCase.RecordTypeId = recortTypeId;
        evCase.ContactId = contactId;
        evCase.Internal_Status__c = internalStatus;
        evCase.ParentId = parentId;
        return evCase;
    }    
    //We have created lots of cases to cover the other scenarios but we have tested one particluar scenarion here
    //1. If ATTESTRECORDTYPEID record type case is created with any Internal status, Internal status should be change to "New"
    @isTest
    public static void verifyBeforeTriggerHandler(){
        Contact con = [SELECT Id, AccountId FROM Contact];
        Case objParentCase = createTetaRecord(Constants.CVRECORDTYPEID, Constants.CASE_STATUS_NEW, con.Id);
        insert objParentCase;        
        List<Case> lstCasesToInsert = new List<Case>();        
        lstCasesToInsert.add(createTetaRecord(Constants.CVRECORDTYPEID, Constants.CASE_STATUS_SUBMITTED_IN_REVIEW, con.Id, objParentCase.Id));
        Case objCaseToAccount = createTetaRecord(Constants.NEW_ENTITY_REQUEST_RDTYPEID, Constants.CASE_STATUS_ADDED, con.Id, objParentCase.Id);
        objCaseToAccount.AccountId = con.AccountId;
        lstCasesToInsert.add(objCaseToAccount);
        lstCasesToInsert.add(createTetaRecord(Constants.ENUSRREQRECORDTYPEID, Constants.CASE_STATUS_NEW, con.Id, objParentCase.Id));
        
        Case objNewCase = createTetaRecord(Constants.SCORERECHECKRDTYPEID, Constants.CASE_STATUS_RECEIVED, con.Id, objParentCase.Id);
        objNewCase.Case_Outcome__c = 'No Change in Score Result';
        lstCasesToInsert.add(objNewCase);
        
        lstCasesToInsert.add(createTetaRecord(Constants.ERVCASERECORDTYPEID, Constants.CASE_STATUS_SENT, con.Id));
        
        lstCasesToInsert.add(createTetaRecord(Constants.NOTIFICATION_RDTYPEID, Constants.CASE_STATUS_NEW, con.Id));
        
        Group entSerQueue = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ENTITY_SERVICE_REQUESTS);
        lstCasesToInsert.add(createTetaRecord(Constants.EXAMREGRTID, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, con.Id));
        Case objQueuCase = createTetaRecord(Constants.EXAMREGRTID, Constants.CASE_STATUS_APPROVED, con.Id);
        objQueuCase.OwnerId = entSerQueue.Id;
        lstCasesToInsert.add(objQueuCase);
        
        lstCasesToInsert.add(createTetaRecord(Constants.PAPERFILEREQRTID, Constants.CASE_STATUS_NEW, con.Id, objParentCase.Id));
        lstCasesToInsert.add(createTetaRecord(Constants.AUTHSIGNLISTRTID, Constants.CASE_STATUS_NEW, con.Id, objParentCase.Id));
        lstCasesToInsert.add(createTetaRecord(Constants.MEDEDURESRTID, Constants.CASE_STATUS_NEW, con.Id, objParentCase.Id));
        lstCasesToInsert.add(createTetaRecord(Constants.ENTITY_SERVICE_REQUEST_RDTYPEID, Constants.CASE_STATUS_NEW, con.Id, objParentCase.Id));
        
        Case attestedCase = createTetaRecord(Constants.ATTESTRECORDTYPEID, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, con.Id, objParentCase.Id);
        attestedCase.Case_Type__c = Constants.CASE_TYPE_ATTESTATION_CASE;
        lstCasesToInsert.add(AttestedCase);
        
        Case attestedCase1 = createTetaRecord(Constants.ATTESTRECORDTYPEID, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, con.Id, objParentCase.Id);
        attestedCase1.Case_Type__c = Constants.CASE_TYPE_ATTESTATION_SUB_CASE;
        lstCasesToInsert.add(attestedCase1);
        
        lstCasesToInsert.add(createTetaRecord(Constants.PETITIONFORRECONSRDTYPEID, Constants.CASE_STATUS_MANUAL_REVIEW_REQUIRED, con.Id, objParentCase.Id));
        
        insert lstCasesToInsert;
        
        Case objAttestedCase = [SELECT Id, Internal_Status__c FROM Case WHERE Id =: attestedCase.Id];
        System.assert(objAttestedCase.Internal_Status__c == Constants.CASE_STATUS_NEW);
    }

    //We have created a case and we passed a Map with Case Id and Status ('New')
    //Secnario: If Case is created with any Internal Status and in Map we provided New Internal status for same Case then
    //System should update the Internal status to "New"(i.e. whatever status we provided in the pramater Map)
    @isTest
    public static void verifyUpdateParentCase(){
        Contact con = [SELECT Id, AccountId FROM Contact];
        Case objParentCase = createTetaRecord(Constants.CVRECORDTYPEID, Constants.CASE_STATUS_SUBMITTED_IN_REVIEW, con.Id);
        insert objParentCase;
        //Map to set Internal Status for particluar Case id.
        Map<Id, String> idStatusMap = new  Map<Id, String>();
        idStatusMap.put(objParentCase.Id, Constants.CASE_STATUS_NEW);
        CasePBActionsHandler.updateParentCase(idStatusMap);
        
        Case resultantCase = [SELECT Id, Internal_Status__c FROM Case WHERE Id =: objParentCase.Id];
        System.assert(resultantCase.Internal_Status__c == Constants.CASE_STATUS_NEW);
    }    
    //We have created a case with active Verification_Packet__c record.
    //Secnario: If if call this method by providing case id which has active Verification_Packet__c then 
    //System should update the active Verification_Packet__c record to Incative i.e. Is_Active__c = FALSE.
    @isTest
    public static void verifyInvalidateVerificationPackets(){
        Contact con = [SELECT Id, AccountId FROM Contact];
        Case objParentCase = createTetaRecord(Constants.CVRECORDTYPEID, Constants.CASE_STATUS_SUBMITTED_IN_REVIEW, con.Id);
        insert objParentCase;
        //Setting verification packet to true 
        Verification_Packet__c vpObj2 = new Verification_Packet__c();
        vpObj2.Case__c = objParentCase.Id;
        vpObj2.Is_Active__c = true;
        insert vpObj2;
        Set<Id> caseIds = new Set<Id>();
        caseIds.add(objParentCase.Id);
        CasePBActionsHandler.invalidateVerificationPackets(caseIds);
        
        Verification_Packet__c resultantVerificationPacket = [SELECT Id, Is_Active__c FROM Verification_Packet__c WHERE Case__c IN :caseIds];
        System.assert(resultantVerificationPacket.Is_Active__c == false);
    }    
    //We created a test cases data to cover the Generate EPIC PDF Report data
    //As we cannot do callout for Test context we have added dummy mock response here.
    @isTest
    public static void verifyGenerateEpicReport(){        
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'PIA Template';
        docConfig.cadmus_core__CustomerDocumentConfigId__c = Constants.DOCCONFIG_EPIC_VERIFICATION_REPORT;
        insert docConfig;
        
        Contact con = [SELECT Id, AccountId FROM Contact];
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        
        Case objParentCase1 = createTetaRecord(Constants.EPICVERREPORTREQRTID, Constants.CASE_STATUS_CV_ACCEPTED, con.Id);
        objParentCase1.Service__c = Constants.CASE_SERVICE_EPIC;
        objParentCase1.RecordTypeId = credVerRecTypeId;
        insert objParentCase1;
        System.assert(objParentCase1.Id != null);
        Case objParentCase = createTetaRecord(Constants.EPICVERREPORTREQRTID, Constants.CASE_STATUS_NEW, con.Id);
        objParentCase.Secondary_Parent_Case__c = objParentCase1.Id;
        insert objParentCase;
        
        List<Case> caseList = new  List<Case>();
        caseList.add(objParentCase);
        Set<Id> epicCaseId = new Set<Id>();
        epicCaseId.add(objParentCase.Id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
        CasePBActionsHandler.generateEpicReport(caseList, epicCaseId);
        Test.stopTest();
    }*/
}