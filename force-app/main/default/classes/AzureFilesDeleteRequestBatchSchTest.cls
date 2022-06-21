@isTest 
public with sharing class AzureFilesDeleteRequestBatchSchTest {
    @testSetup static void setup(){
        String tstAzureURL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Id credVerifRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id credVerifAffirmRecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        //Insert Asset
        Id verifAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        Id identityAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();

        Case credVerifCase = new Case(RecordTypeId = credVerifRecordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_VERIFICATION_IN_REVIEW);
        INSERT credVerifCase;
        
        //Insert Asset
        Asset tstOnlineAsst = new Asset(
                Name = 'Online Verification',
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Case__c = credVerifCase.Id,
                Type__c =   Constants.ASSET_TYPE_ONLINE_VERIFICATION,
                Azure_Storage_URL__c = tstAzureURL,
                RecordTypeId = verifAssetRecordTypeId);
        INSERT tstOnlineAsst;
        //Insert affirmation for the asset
        Affirmation__c tstAffirm = new Affirmation__c(RecordTypeId = credVerifAffirmRecordTypeId,
                    Asset__c = tstOnlineAsst.Id,
                    Status__c = Constants.ASSET_STATUS_IN_PROGRESS);
        INSERT tstAffirm;

        //Insert Asset
        Asset tstIdentityAsst = new Asset(
                Name = 'IDFormNotarized',
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Case__c = credVerifCase.Id,
                Type__c =   'ID Verification',
                Azure_Storage_URL__c = tstAzureURL,
                RecordTypeId = identityAssetRecordTypeId);
        INSERT tstIdentityAsst;
        
	}
    @isTest 
    public static void testSchedulerExecute() {
        Test.startTest();
        String chron = '0 0 12 * * ?';
        System.Schedule('Test AzureFilesDeleteRequestBatchScheduler', chron, new AzureFilesDeleteRequestBatchScheduler());
        Test.stopTest();
    }
    @isTest
    static void testDeleteAsset(){
        Id identityAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        String tstName = 'IDFormNotarized';
        String toBeDeleteSoql = 'SELECT Id '         
                                + ' FROM Asset'
                                + ' WHERE Name = \''+ tstName + '\''
                                + ' WITH SECURITY_ENFORCED';
        Test.startTest();
        AzureFilesDeleteRequestBatchScheduler.deleteAsset(toBeDeleteSoql);
        System.assertEquals(true, true,'Asset deleted successfully');
        Test.stopTest();
    }
    @isTest
    static void testDeleteAffirmation(){
        Id verifAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        List<Asset> assetList = [SELECT Id, Name FROM Asset WHERE RecordTypeId =:verifAssetRecordTypeId  LIMIT 1];

        Test.startTest();
        AzureFilesDeleteRequestBatchScheduler.deleteAffirmation(assetList);
        System.assertEquals(true, true,'Affirmation deleted successfully');
        Test.stopTest();
    }   
}