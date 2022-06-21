@isTest
public with sharing class CredVerAffirmationControllerTest{
    @isTest
    public static void checkTheFinalDocTest(){
        CloudDataTestFactory.createCloudConfig();
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        System.assert(curECFMGSetting.Id!=null,'ecfmg sequence id setting not found');
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        System.assert(curEntitySetting.Id!=null,'Entity sequence id setting not found');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Unique_Medical_School_ID__c = 'TA123';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id!=null,'Account not created');
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        System.assert(con.Id!=null, 'Contact not created');
        Id assetRecTypeCredential = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_CREDENTIAL).getRecordTypeId();
        Id credVerRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_CREDENTIAL_VERIFICATION ).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = credVerRecTypeId;
        newCase.ContactId = con.Id;
        newCase.AccountId = acc.Id;
        newCase.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not created');
        Asset asst = new Asset();
        asst.Name = Constants.ASSET_NAME_CREDENTIAL_REQUEST;
        asst.AccountId = acc.Id;
        asst.ContactId = con.Id;
        asst.Case__c = newCase.Id;
        asst.RecordTypeId = assetRecTypeCredential;
        asst.Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst.Status = Constants.ASSET_STATUS_VERIFIED;
        INSERT asst;
        System.assert(asst.Id != null, 'Asset not inserted');
        Case cvCase = new Case();
        cvCase.RecordTypeId = credVerRecTypeId;
        cvCase.ContactId = con.Id;
        cvCase.AccountId = acc.Id;
        cvCase.Service__c = Constants.CASE_SERVICE_EPIC;
         cvCase.Internal_Status__c = Constants.CASE_STATUS_INCOMPLETE;
        INSERT cvCase;
        System.assert(cvCase.Id!=null,'Case not created');
        List<ID> ids = new List<ID>();
        ids.add(cvCase.Id);
        List<Asset> asstList = CredVerAffirmationController.checkFMDExist(ids);
        System.assert(!asstList.isEmpty() , 'FMD Asset does not exist');
    }
    @isTest
    public static void checkTheFinalDocTestExcep(){
        try{
            List<Asset> asstList = CredVerAffirmationController.checkFMDExist(null);
            System.assert(!asstList.isEmpty() , 'FMD Asset does not exist');
        }catch(exception ex){
            system.debug('there is an exception');
        }
    }
}