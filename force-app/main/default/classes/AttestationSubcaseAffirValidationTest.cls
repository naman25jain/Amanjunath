@isTest
public with sharing class AttestationSubcaseAffirValidationTest{
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        UPSERT curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        UPSERT curEntitySetting;
        BaseTestFactory.getCustomerCommunityPlusUser();
    }
    @isTest
    public static void testCheckOnlineVerAsset(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name='Account Name',RecordTypeId=idAccountTypeId,School__c=true, BillingCountry='India');
        INSERT acct;
        System.assert(acct.Id != null,'Account Creation Failed');
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ATTESTATION).getRecordTypeId();
        Case attCase = new Case();
        attCase.RecordTypeId = caseRecTypeId;
        attCase.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW_AT_ECFMG;
        attCase.Entity__c = acct.Id;
        attCase.Alternate_Entity__c = acct.Id;
        attCase.ContactId = [SELECT Id FROM Contact Limit 1].Id;
        INSERT attCase;
        System.assert(attCase.Id != null,'case creation failed');
        string strScreenName = 'Attestations_Subcase_Affirmations_Screen';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Case__c', attCase.Id);
        mapValues.put('Attestor_License_ver_state_medical_board__c', 'Yes');
        mapValues.put('Acknowledgment_complete_and_include_sign__c', 'No');
        mapValues.put('Notary_signature_is_missing__c', false);
        mapValues.put('Notary_seal_stamp_is_missing__c', false);
        mapValues.put('Acknowledgment_is_missing_information__c', false);
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        AttestationSubcaseAffirValidation attSubcaseAffValid = new AttestationSubcaseAffirValidation();
        String errorMsg = attSubcaseAffValid.process(mdtValidation, mapValues);
        System.assertEquals('Please select atleast one Reason for Incomplete Acknowledgment@', errorMsg, 'Wrong validation');
        Test.stopTest();
    }
}