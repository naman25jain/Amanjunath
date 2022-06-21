@isTest
public class Actionable_AccountEstablishmentTest{
	public static final String TEST_ACCOUNT = 'Test Account';
	@testSetup static void setup(){
		CloudDataTestFactory.createCloudConfig();
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;		
		Account acc = new Account();
		acc.Name = TEST_ACCOUNT;
        acc.BillingCountry = 'India';
		INSERT acc;
		System.assert(acc.Id != null, 'Fail to insert account Record!');
		Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
		INSERT con;
		System.assert(con.Id != null, 'Fail to insert contact Record!');		
	}
    @isTest
    public static void testAccountEstablishmentSummary(){
		Id dcRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
		cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = Constants.ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY;
		docConfig.cadmus_core__CustomerDocumentConfigId__c = Constants.DOCCONFIG_ACCOUNT_ESTABLISHMENT_SUMMARY;
		insert docConfig;
        System.assert(docConfig.Id != NULL, 'DocConfig for Account Establishment Application Summary creation failed.');
		Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.com'];
		Case idCase = new Case();
		idCase.RecordTypeId = dcRTId;
		idCase.ContactId = con.Id;
		INSERT idCase;
        System.assert(idCase.Id != NULL, 'Identity Verification case creation failed.');
        Id assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_SUMMARY).getRecordTypeId();		
        Asset assetObj = new Asset();
		assetObj.RecordTypeId = assetRTId;
        assetObj.Name = Constants.ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY;
		assetObj.ContactId = con.Id;
        assetObj.Case__c = idCase.Id;
        assetObj.Type__c = Constants.ASSET_TYPE_APPLICATION_SUMMARY;
        assetObj.status = Constants.ASSET_STATUS_ACCEPTED;
		INSERT assetObj;
        System.assert(assetObj.Id != NULL, 'Asset creation failed.');
		cadmus_core.DocGenerationWrapper wrapper = new cadmus_core.DocGenerationWrapper();
		wrapper.response = new cadmus_core.CadmusHttpResponse();
		wrapper.response.base64 = Blob.valueOf('Test');
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_UploadDocument());
		Actionable_AccountEstablishmentSummary action = new Actionable_AccountEstablishmentSummary();
        action.execute(new cadmus_core__Actionable__c(), docConfig.Id, idCase.Id, new Map<String, Object>(), new cadmus_core.ConvertController.ConvertDataModel(), wrapper);
		Test.stopTest();
		System.assert([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Name =: Constants.ASSET_NAME_ACCOUNT_ESTABLISHMENT_APPLICATION_SUMMARY AND ContactId =: idCase.ContactId AND Case__c =: idCase.Id][0].Azure_Storage_URL__c != null, 'Failed to create Account Establishment Application Summary asset');
	}
}