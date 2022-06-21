@isTest
public class ERASTriggerHandlerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
        System.assert(acc.id!=null, 'Account failed');
    }
    @isTest  
    public static void insertERASTest() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id erasEPRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constant_Eligibility_Period__mdt.getInstance('REC_TYPE_ERAS').Value__c).getRecordTypeId();
        Eligibility_Period__c ep1 = new Eligibility_Period__c();
        ep1.Active__c = 'N';
        ep1.EP_Start_Date__c = Date.newInstance(2021, 4, 11);
        ep1.EP_End_Date__c = Date.newInstance(2021, 5, 31);
        ep1.Lockdown_Start_Date__c = Date.newInstance(2021, 5, 31);
        ep1.RecordTypeId = erasEPRecordTypeId;
        ep1.Earlier_Season_ID__c = '';
        Eligibility_Period__c ep2 = new Eligibility_Period__c();
        ep2.Active__c = 'Y';
        ep2.EP_Start_Date__c = Date.newInstance(2022, 4, 11);
        ep2.EP_End_Date__c = Date.newInstance(2022, 12, 31);
        ep2.Lockdown_Start_Date__c = Date.newInstance(2022, 12, 31);
        ep2.RecordTypeId = erasEPRecordTypeId;
        ep2.Earlier_Season_ID__c = '';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultEPTestData.class, ep1);
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultEPTestData.class, ep2);
        run();
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Id assetRecordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c,eligibility_period__c = ep1.Id,Repeat_Applicant__c = false));
        run();
        Asset asst = (Asset)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAssestTestData.class, new Asset(Name = 'ERAS Photo', Type__c = 'Photo', RecordTypeId = assetRecordtypeId, Status = Constant_Asset__mdt.getInstance('STATUS_IN_PROGRESS').Value__c, Contact = con, Case__c = cas.Id,Azure_Storage_URL__c = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf'));
        run();
        Case cas2 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c,eligibility_period__c = ep2.Id,Repeat_Applicant__c = true));
        run(); 
        Case previousErasCase = [SELECT id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Internal_Status__c FROM Case WHERE id=:cas.Id];
        System.assert(previousErasCase.Id!=null, 'Previous ERAS case not created');
        Case erasCase = [SELECT id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c,Repeat_Applicant__c,Internal_Status__c FROM Case WHERE Id=:cas2.Id];
        erasCase.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_DOCUMENT_UPLOAD').Value__c;
        update erasCase;
        System.assert(ErasCase.Id!=null, 'ERAS case not created');
        Case_Service_Mapping__mdt serviceRec = [SELECT Id,Case_Service__c,Case_Service_Family__c,Case_Service_Line__c FROM Case_Service_Mapping__mdt WHERE Service_RecordType__c =:Constant_Case__mdt.getInstance('REC_TYPE_ERAS').Value__c LIMIT 1];
        System.assertEquals(serviceRec.Case_Service__c,erasCase.Case_Service__c,'Service is incorrect');
        System.assertEquals(serviceRec.Case_Service_Family__c,erasCase.Case_Service_Family__c,'Service Family is incorrect');
        System.assertEquals(serviceRec.Case_Service_Line__c,erasCase.Case_Service_Line__c,'Service Line is incorrect');
        Test.stopTest();
    }
    // Test method for after update
    @isTest  
    public static void testAfterUpdate() {
        Test.startTest();
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id erasRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ERAS).getRecordTypeId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_TOKEN_REQUEST_SUBMITTED').Value__c));
        run(); 
        Case erasCase = [SELECT Id FROM Case WHERE Id=:cas.Id];
        System.assert(erasCase.Id!=null, 'ERAS case not created');
        erasCase.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_TOKEN_GENERATED').Value__c;
        Update erasCase;
        Case erasCaseUpdatd = [SELECT Id, Internal_Status__c FROM Case WHERE Id=:erasCase.Id];
        System.assertEquals(Constant_Case__mdt.getInstance('STATUS_TOKEN_GENERATED').Value__c, erasCaseUpdatd.Internal_Status__c, 'ERAS case updated');
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=erasRecordTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_SUBMISSION').Value__c));
        run();
        cas1.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_PENDING_TOKEN_CALL').Value__c;
        Update cas1;
        Test.stopTest();
    }
}