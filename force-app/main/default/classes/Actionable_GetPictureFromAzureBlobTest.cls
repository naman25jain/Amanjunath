@isTest
public class Actionable_GetPictureFromAzureBlobTest {
    public static final string AZURE_URL = 'https://ecfmglocal001.blob.core.windows.net/sfdc-applicant-documents/0033F00000Sul33QAB_Passport_0.jpeg';
    @testSetup static void setup() {
        CloudDataTestFactory.createCloudConfig();
        
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
        
        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.ContactId = con.Id;
        INSERT evCase;
        
        Asset asst = new Asset();
        asst.Name = 'Photo';
        asst.ContactId = con.Id;
        asst.Status = Constants.ASSET_STATUS_VERIFIED;
        asst.Type__c = 'Photo';
        asst.Azure_Storage_URL__c = AZURE_URL;
        INSERT asst;
        
        cadmus_core__Data_Source__c source = new cadmus_core__Data_Source__c();
        source.Name = 'Applicant Photo Data Source';
        source.cadmus_core__Image_Name__c = 'Image';
        source.cadmus_core__Image_source__c = 'ATTACHMENTS';
        source.cadmus_core__Parent_Query_Field_Name__c = 'Id';
        source.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('PICTURE_LIST').getRecordTypeId();
        
        cadmus_core__Data_Source__c source1 = new cadmus_core__Data_Source__c();
        source1.Name = 'Applicant Passport Data Source';
        source1.cadmus_core__Image_Name__c = 'Image';
        source1.cadmus_core__Image_source__c = 'ATTACHMENTS';
        source1.cadmus_core__Parent_Query_Field_Name__c = 'Id';
        source1.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('PICTURE_LIST').getRecordTypeId();
        
        List<cadmus_core__Data_Source__c> sources = new List<cadmus_core__Data_Source__c>();
        sources.add(source);
        sources.add(source1);
        INSERT sources;
    }

    public static testMethod void testExecute1(){
        Case evCase = [SELECT Id, ContactId FROM Case WHERE Contact.Email = 'test@test.com' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
        Actionable_GetPictureFromAzureBlob action = new Actionable_GetPictureFromAzureBlob();
        action.execute(new cadmus_core__Actionable__c(), null, evCase.Id, new Map<String,Object>(), new Map<String,Object>(), new cadmus_core.ConvertController.ConvertDataModel());
        Test.stopTest();
        
        System.assert([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Type__c = 'Photo' AND ContactId = :evCase.ContactId][0].Azure_Storage_URL__c != null, 'Assert succeeded!');
    }
    
    public static testMethod void testExecute2(){
        Id idRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_IDENTITY_VERIFICATION).getRecordTypeId();
        
        Contact con = [SELECT Id, Email, AccountId FROM Contact WHERE Email = 'test@test.com'];
        
        Case idCase = new Case();
        idCase.RecordTypeId = idRTId;
        idCase.ContactId = con.Id;
        INSERT idCase;
        
        Asset asst = new Asset();
        asst.Name = 'Photo';
        asst.ContactId = con.Id;
        asst.Status = Constants.ASSET_STATUS_VERIFIED;
        asst.Type__c = 'Photo';
        asst.Azure_Storage_URL__c = AZURE_URL;
        asst.Case__c = idCase.Id;
        INSERT asst;
        
        Asset idasst = new Asset();
        idasst.Name = 'Passport';
        idasst.ContactId = con.Id;
        idasst.Status = Constants.ASSET_STATUS_VERIFIED;
        idasst.Type__c = 'Passport';
        idasst.Azure_Storage_URL__c = AZURE_URL;
        idasst.Case__c = idCase.Id;
        INSERT idasst;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
        Actionable_GetPictureFromAzureBlob action = new Actionable_GetPictureFromAzureBlob();
        action.execute(new cadmus_core__Actionable__c(), null, idCase.Id, new Map<String,Object>(), new Map<String,Object>(), new cadmus_core.ConvertController.ConvertDataModel());
        Test.stopTest();
        
        System.assert([SELECT Id, Azure_Storage_URL__c FROM Asset WHERE Type__c = 'Photo' AND ContactId = :idCase.ContactId][0].Azure_Storage_URL__c != null, 'Assert succeeded!');
    }
    //testing credVerECFMGFormGeneration method 
    @isTest
    public static void testExecute3(){
        Case evCase = [SELECT Id, ContactId, AccountId FROM Case WHERE Contact.Email = 'test@test.com' LIMIT 1];
        System.assert(evCase != null);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_GetPicture());
        //created a instance to call non-static methods of Actionable_GetPictureFromAzureBlob class
        Actionable_GetPictureFromAzureBlob action = new Actionable_GetPictureFromAzureBlob();
        
        //Prepatred requested data
        cadmus_core.ConvertController.ConvertDataModel objInput = new cadmus_core.ConvertController.ConvertDataModel();
        
        cadmus_core.CadmusKeyValue data = new cadmus_core.CadmusKeyValue();
        data.key = 'entityId';
        data.valueString = evCase.AccountId;
        
        cadmus_core.CadmusKeyValue data1 = new cadmus_core.CadmusKeyValue();
        data1.key = 'entityUserId';
        data1.valueString = evCase.ContactId;
        
        List<cadmus_core.CadmusKeyValue> lstData = new List<cadmus_core.CadmusKeyValue>();
        lstData.add(data);
        lstData.add(data1);
        
        cadmus_core.CadmusParameters objParams = new cadmus_core.CadmusParameters();
        objParams.values = lstData;
        
        objInput.parameters = objParams;
        
        action.credVerECFMGFormGeneration(objInput, new Map<String,Object>());
        Test.stopTest();
        
    }

}