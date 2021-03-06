@isTest
public class Actionable_GenerateNameOnDocumentTest {
	@IsTest public static void setup(){
        CloudDataTestFactory.createCloudConfig();
        CurrentEntityIDSequence__c settings = CurrentEntityIDSequence__c.getOrgDefaults();
        settings.Entity_ID__c = '00000';
        upsert settings CurrentEntityIDSequence__c.Id;
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000';
        upsert curECFMGSetting CurrentECFMGIDSequence__c.Id;
        System.assert(curECFMGSetting!=null, 'Failed to upsert curECFMGSetting');
    }
    @isTest
    public static void testMedEduFormParam(){
        Id cvRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id accrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
        cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
        dataSource.Name = 'CATS Name on Document';
        dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
        dataSource.cadmus_core__Type__c = 'Single sObject';
        insert dataSource;
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'Universal Verification Form - English';
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        docConfig.cadmus_core__Delivery_option__c = 'BASE64';
        insert docConfig;
        System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');
        Account acc = new Account();
        acc.Name = 'TEST_ACCOUNT';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Arizona';
        acc.BillingCity = 'test';
        acc.BillingPostalCode = '123654';
        INSERT acc;
        System.assert(acc.Id != null, 'Failed to insert account Record!');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id != null, 'Failed to insert contact Record!');
        Account newAcct = new Account();
        newAcct.Name = 'Test AccountCred';
        newAcct.RecordTypeId = accrecTypeId;
        newAcct.BillingCity = 'test';
        newAcct.BillingCountry = 'India';
        newAcct.BillingPostalCode = '1234';
        newAcct.BillingState = 'West Bengal';
        newAcct.BillingStreet = 'test';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account not created'); 
        Case medCase = new Case();
        medCase.RecordTypeId = cvRTid;
        medCase.ContactId = con.Id;
        medCase.Service__c = 'ECFMG_Certification';
        medCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        medCase.Entity__c = newAcct.Id;
        INSERT medCase;
        System.assert(medCase.Id != null, 'med edu case null');
        Asset asst1 = new Asset();
        asst1.Name = Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM;
        asst1.Status = Constants.ASSET_STATUS_NEW;
        asst1.ContactId = con.Id;
        asst1.InstallDate = System.Today();
        asst1.key__c = Constants.ASSET_TYPE_TCT;
        asst1.Name_on_Document__c = 'Test 123';
        asst1.Case__c = medCase.Id;
        asst1.Type__c = 'Photo';
        asst1.Azure_Storage_URL__c = 'assetUrl';
        insert asst1;
        System.assert(asst1.Id != null, 'asset insertion failed');
        Contact_Association_Type_Staging__c catsRecordNew = new Contact_Association_Type_Staging__c();
        catsRecordNew.account__c = newAcct.Id;
        catsRecordNew.Title__c = 'TestTile';
        catsRecordNew.Contact__c = con.Id;
        catsRecordNew.Credential_Type__c = 'Final Medical Diploma'; 
        catsRecordNew.Alternate_Entity__c = newAcct.Id;
        catsRecordNew.Case__c = medCase.Id;
        INSERT catsRecordNew;
        Affirmation__c aff = new Affirmation__c();
        aff.Case__c = medCase.Id;
        aff.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        INSERT aff;
        System.assert(aff.Id != null, 'affirmation creation failed');
        Actionable_GenerateNameOnDocument action = new Actionable_GenerateNameOnDocument();
        action.execute(new cadmus_core__Actionable__c(), docConfig.Id, medCase.Id, new Map<String, Object> (), new cadmus_core.ConvertController.ConvertDataModel());
    }
    @isTest
    public static void testMedEduFormParam1(){
        Id cvRTid = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Id accrecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORD_TYPE_REGULATORY_ORG).getRecordTypeId();
        cadmus_core__Data_Source__c dataSource = new cadmus_core__Data_Source__c();
        dataSource.Name = 'CATS Name on Document';
        dataSource.RecordTypeId = Schema.SObjectType.cadmus_core__Data_Source__c.getRecordTypeInfosByDeveloperName().get('KEYVALUE').getRecordTypeId();
        dataSource.cadmus_core__Type__c = 'Single sObject';
        insert dataSource;
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'Universal Verification Form - English';
        docConfig.RecordTypeId = Schema.SObjectType.cadmus_core__Doc_Config__c.getRecordTypeInfosByDeveloperName().get('MAIN').getRecordTypeId();
        docConfig.cadmus_core__Delivery_option__c = 'BASE64';
        insert docConfig;
        System.assert(docConfig.Id != null, 'Failed to insert Doc Config Record!');
        Account acc = new Account();
        acc.Name = 'TEST_ACCOUNT';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Arizona';
        acc.BillingPostalCode = '123654';
        INSERT acc;
        System.assert(acc.Id != null, 'Failed to insert account Record!');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        System.assert(con.Id != null, 'Failed to insert contact Record!');
        Account newAcct = new Account();
        newAcct.Name = 'Test AccountCred';
        newAcct.RecordTypeId = accrecTypeId;
        newAcct.BillingCity = 'test';
        newAcct.BillingCountry = 'India';
        newAcct.BillingPostalCode = '1234';
        newAcct.BillingState = 'West Bengal';
        newAcct.BillingStreet = 'test';
        Insert newAcct;
        System.assert(newAcct.Id!= null,'Account not created'); 
        Case cvCase = new Case();
        cvCase.RecordTypeId = cvRTid;
        cvCase.ContactId = con.Id;
        cvCase.Service__c = 'EPIC';
        cvCase.Internal_Status__c = Constants.CASE_STATUS_NEW;
        cvCase.Entity__c = newAcct.Id;
        INSERT cvCase;
        System.assert(cvCase.Id != null, 'cv case null');
        Asset asst1 = new Asset();
        asst1.Name = Constants.ASSET_NAME_UNIVERSAL_VERIFICATION_FORM;
        asst1.Status = Constants.ASSET_STATUS_NEW;
        asst1.ContactId = con.Id;
        asst1.InstallDate = System.Today();
        asst1.key__c = Constants.ASSET_TYPE_TCT;
        asst1.Name_on_Document__c = 'Test 123';
        asst1.Case__c = cvCase.Id;
        asst1.Type__c = 'Photo';
        asst1.Azure_Storage_URL__c = 'assetUrl';
        insert asst1;
        System.assert(asst1.Id != null, 'asset insertion failed');
        Contact_Association_Type_Staging__c catsRecordNew1 = new Contact_Association_Type_Staging__c();
        catsRecordNew1.account__c = newAcct.Id;
        catsRecordNew1.Title__c = 'TestTile';
        catsRecordNew1.Contact__c = con.Id;
        catsRecordNew1.Credential_Type__c = 'Final Medical Diploma';
        catsRecordNew1.Name_on_Document__c = 'Testing123';
        catsRecordNew1.Alternate_Entity__c = newAcct.Id;
        catsRecordNew1.Case__c = cvCase.Id;
        INSERT catsRecordNew1;
        System.assert(cvCase.Id != null, 'cats creation failed');
        Affirmation__c aff = new Affirmation__c();
        aff.Case__c = cvCase.Id;
        aff.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_MED_EDU_FORM).getRecordTypeId();
        INSERT aff;
        System.assert(aff.Id != null, 'affirmation creation failed');
        Actionable_GenerateNameOnDocument action = new Actionable_GenerateNameOnDocument();
        action.execute(new cadmus_core__Actionable__c(), docConfig.Id, cvCase.Id, new Map<String, Object> (), new cadmus_core.ConvertController.ConvertDataModel());
    }
}