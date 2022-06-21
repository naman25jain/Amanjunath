@isTest
public with sharing class DocNotAccForClientValidationTest{
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        BaseTestFactory.getCustomerCommunityPlusUser();
    }
    @isTest
    public static void testdocNotAccForClient(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name='Account Name', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'United States', BillingState = 'California', BillingCity = 'TEst', BillingPostalCode = '123456');
        Insert acct;
        System.assert(acct.Id != null,'Account Creation Failed');
        Case caseCV = new Case();
        caseCV.RecordTypeId = Constants.CVRECORDTYPEID;
        caseCV.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseCV.Entity__c = acct.Id;
        caseCV.Alternate_Entity__c = acct.Id;
        caseCV.ContactId = [SELECT Id FROM Contact Limit 1].Id;
        caseCV.Service__c = 'EICS';
        Insert caseCV;
        System.assert(caseCV.Id != null,'CV case creation failed');
        Affirmation__c affCV = new Affirmation__c();
        affCV.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_VERIFICATION_REVIEW).getRecordTypeId();
        affCV.Case__c = caseCV.Id;
        Insert affCV;
        System.assert(affCV.Id != null,'CV affirmation creation failed');
        string strScreenName = 'Returned_FMD_Evaluation_Screen_2';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Case__c', caseCV.Id);
        mapValues.put('Document_is_not_acceptable_for_the_Clien__c', true);
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        DocNotAccForClientValidation docNotAccForClientValid = new DocNotAccForClientValidation();
        String errorMsg = docNotAccForClientValid.process(mdtValidation, mapValues);
        System.assertEquals('This response for Document is not acceptable for Client refers to EPIC cases only@', errorMsg, 'Wrong validation');
        caseCV.Service__c = 'EPIC';
        Update caseCV;
        System.assert(caseCV.Id != null, 'CV case updation failed');
        affCV.Document_is_complete_and_legible__c = 'No';
        Update affCV;
        System.assert(affCV.Id != null,'CV affirmation updation failed');
        String errorMsg2 = docNotAccForClientValid.process(mdtValidation, mapValues);
        System.assertEquals('This response for Document is not acceptable for Client cannot be selected as the outcome of previous affirmations is Incomplete@', errorMsg2, 'Wrong validation');
        Test.stopTest();
    }
}