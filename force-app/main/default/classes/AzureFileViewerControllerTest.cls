@isTest
public class AzureFileViewerControllerTest {
    public static final string AZURE_URL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0033F00000Sul33QAB_Passport_0.jpeg';
	@testSetup static void setup(){
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '0000000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;

        Id acctRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_ENTITY).getRecordTypeId();
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        acc.RecordTypeId = acctRecTypeId;
        INSERT acc;
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Id credVerifRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case credVerifCase = new Case(RecordTypeId = credVerifRecordTypeId, ContactId = con.Id, Service__c = Constants.CASE_SERVICE_ECFMG_CERTIFICATION, Internal_Status__c = Constants.CASE_STATUS_VERIFICATION_IN_REVIEW,Document_URL__c=AZURE_URL);
        INSERT credVerifCase;
        
        Id verifAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
        //Insert Asset
        Asset tstOnlineAsst = new Asset(
                Name = 'Online Verification',
                Status = Constants.ASSET_STATUS_IN_PROGRESS,
                ContactId = con.Id,
                InstallDate = System.Today(),
                Case__c = credVerifCase.Id,
                Type__c =   Constants.ASSET_TYPE_ONLINE_VERIFICATION,
                Azure_Storage_URL__c = AZURE_URL,
                RecordTypeId = verifAssetRecordTypeId);
        INSERT tstOnlineAsst;
        
    }
	@isTest    
    static void testGetAzureUrl() {
        CloudDataTestFactory.createCloudConfig();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Asset tstAsset = [SELECT Id, Name, Case__c FROM Asset WHERE ContactId=:tstContact.Id LIMIT 1];
        System.assert(AzureFileViewerController.getAzureUrl(tstAsset.Id) != null, 'Assert success');
    }
    @isTest
    static void testGetDocumentUrl(){
        CloudDataTestFactory.createCloudConfig();
        Contact tstContact = [SELECT ID, Name FROM Contact WHERE Name='Test' LIMIT 1];
        Id cvRecTypeID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Case cvCase = [SELECT Id, Internal_Status__c, ContactId FROM Case WHERE RecordTypeId =: cvRecTypeID AND ContactId=:tstContact.Id LIMIT 1];
        System.assert(AzureFileViewerController.getDocumentUrl(cvCase.Id) != null, 'Document URL is not generated');
    }
}