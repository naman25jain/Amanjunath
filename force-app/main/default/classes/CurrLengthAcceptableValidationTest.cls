@isTest
public with sharing class CurrLengthAcceptableValidationTest{
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
        Account acct = new Account(Name='Account Name',RecordTypeId=idAccountTypeId,School__c=true,BillingCountry='Bhutan');
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
        string strScreenName = 'Returned_FMST_Evaluation_Screen_3';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Case__c', caseCV.Id);
        mapValues.put('Curriculum_Length_Acceptable__c', 'Yes, due to acceptable transfer credits');
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        Test.startTest();
        CurrLengthAcceptableValidation currLenAccValid = new CurrLengthAcceptableValidation();
        String errorMsg = currLenAccValid.process(mdtValidation, mapValues);
        System.assertEquals('This response for Curriculum Length Acceptable refers to ECFMG Certification cases only@', errorMsg, 'Wrong validation');
        Test.stopTest();
    }
    
    @isTest
    public static void testdocNotAccForClientExcep(){
        try{
            Test.startTest();
            CurrLengthAcceptableValidation currLenAccValid = new CurrLengthAcceptableValidation();
            String errorMsg = currLenAccValid.process(null,null);
            system.assert(string.isNotBlank(errorMsg) , 'FMD Asset does not exist');
            Test.stopTest();
        }catch(Exception ex){
            system.debug('there is an exception');
        }
    }
}