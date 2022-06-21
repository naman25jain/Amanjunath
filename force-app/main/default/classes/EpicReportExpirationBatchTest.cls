@isTest
public class EpicReportExpirationBatchTest extends ECFMGTestFactory{
     Static final String AVAIL_DATE = '11/10/2020' ;  
     @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        UPSERT curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        UPSERT curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        WDOMS_ID_Sequence__c wdomsIdSeq = WDOMS_ID_Sequence__c.getOrgDefaults();
        wdomsIdSeq.AKA_ID__c = 1000;
        UPSERT wdomsIdSeq;
     }
    @isTest
    public static void testEpicReportExpireBatch(){
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Test Account',Unique_Medical_School_ID__c = 'TA123',BillingCountry = 'United States',BillingState = 'New Jersey',BillingPostalCode = 'x123'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(LastName='Test', RecordTypeId=applRecTypeId, Email = 'test1@test.com', Accountid = acc.id));
        run();
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case credVerCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = credVerRecTypeId,ContactId = con.Id, Internal_Status__c = Constants.CASE_STATUS_CV_ACCEPTED,Document_Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA));
        run();
        Id epicReportRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_VER_REPORT_REQUEST).getRecordTypeId();
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(RecordTypeId = epicReportRecTypeId,ContactId = con.Id,Payment_History__c = 'Free report',
                                                          Report_Type__c = 'Self', EPIC_Report_Status__c = 'Report Sent', Secondary_Parent_Case__c = credVerCase.Id, EPIC_Report_Entity__c = null, EPIC_Report_Received_Date__c = Date.parse(AVAIL_DATE),Internal_Status__c = 'Sent'));
        run();
        List<Case> epicReports = [SELECT Id FROM Case WHERE RecordTypeId =: epicReportRecTypeId AND ContactId =: con.Id LIMIT 1];
        Test.startTest(); 
        EpicReportExpirationBatchClass batch1 = new EpicReportExpirationBatchClass();
        Database.executeBatch(batch1);
        batch1.execute(null,epicReports);
        Test.stopTest();
    }
}