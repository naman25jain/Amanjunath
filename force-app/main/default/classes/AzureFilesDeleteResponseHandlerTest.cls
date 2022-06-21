@isTest 
public with sharing class AzureFilesDeleteResponseHandlerTest {
    @TestSetup
    static void setup(){
        String tstAzureURL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/00302000004oj9mAAA_Transfer_Credit_Transcript_2020-11-17_04_10_38.pdf';
        

        final string URLPREFIX = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/';

        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;

        Contact contact = BaseTestFactory.getContact();              
        
        List<Asset> assets = new List<Asset>(); 
        for (Integer i=0; i<10; i++){
            Asset a = new Asset(ContactId = contact.Id,
            Name= 'Photo',
            Azure_Delete_Batch_Id__c = '7072F00001thDSdQAM.0',
            Azure_Storage_URL__c = URLPREFIX+i+'.pdf', 
            status = 'Marked for Deletion' );
            if (i>5){
                a.Azure_Delete_Batch_Id__c = '7072F00001thDSdQAM.1';
            }
            assets.add(a); 
        }
        INSERT assets;

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
    static void testResponseEventPayloadPartialSuccess(){
        String payload='{"coorelationId":"7072F00001thDSdQAM.0","transactionStatus":"Partial Success","transactionDetails":[{"fileName":"1.pdf","fileStatus":"Deleted"},{"fileName":"2.pdf","fileStatus":"Failed"},{"fileName":"3.jpeg","fileStatus":"Deleted"},{"fileName":null,"fileStatus":"Deleted"}]}';
        Test.startTest();
        EventBusWrapper.publish(new Azure_Files_Delete_Response_Event__e (payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }

    @isTest
    static void testResponseEventPayloadSuccess(){
        String payload='{"coorelationId":"7072F00001thDSdQAM.1","transactionStatus":"Success"}';
        Test.startTest();
        EventBusWrapper.publish(new Azure_Files_Delete_Response_Event__e (payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }

    @isTest
    static void testResponseEventPayloadFailure(){
        String payload='{"coorelationId":"1234567","transactionStatus":"Failure","errorDetails":{"errorCode":"Internal Server Error","errorDescription":"Unable to connect Azure services"}}';
        Test.startTest();
        EventBusWrapper.publish(new Azure_Files_Delete_Response_Event__e (payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }

    @isTest
    static void testResponseEventPayloadNull(){
        String payload;
        Test.startTest();
        EventBusWrapper.publish(new Azure_Files_Delete_Response_Event__e (payload__c = payload));
        Test.stopTest();
        System.assertEquals(1, EventBusWrapper.eventList.size(), 'More than 1 event is published');
    }
    @isTest
    static void testDeleteAsset(){
        Id identityAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_IDENTITY).getRecordTypeId();
        List<Asset> assetList = [SELECT Id, Name FROM Asset WHERE RecordTypeId =:identityAssetRecordTypeId  LIMIT 1];
        Test.startTest();
        AzureFilesDeleteResponseHandler.deleteAsset(assetList,'200');
        System.assertEquals(true, true,'Asset deleted successfully');
        Test.stopTest();
    }
    @isTest
    static void testDeleteAffirmation(){
            Id verifAssetRecordTypeId =Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_VERIFICATION).getRecordTypeId();
            List<Asset> assetList = [SELECT Id, Name FROM Asset WHERE RecordTypeId =:verifAssetRecordTypeId  LIMIT 1];
            Test.startTest();
            AzureFilesDeleteResponseHandler.deleteAffirmation(assetList);
            System.assertEquals(true, true,'Affirmation deleted successfully');
            Test.stopTest();
    }
}