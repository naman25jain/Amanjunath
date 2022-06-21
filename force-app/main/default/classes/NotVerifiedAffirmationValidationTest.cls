// Test class for NotVerifiedAffirmationValidation
@isTest
public class NotVerifiedAffirmationValidationTest{
    @testSetup static void setup(){
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        BaseTestFactory.getCustomerCommunityPlusUser();
    }
    // US 11951- Tests the custom validation for 'Not_Verified_Screen_1'.
    @isTest
    static void testNotVerifiedAffNotPortal(){
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name='Account Name',RecordTypeId=idAccountTypeId,School__c=true, BillingCountry= 'India');
        Insert acct;
        System.assert(acct.Id != null,'Account Creation Failed');
        Case caseCV = new Case();
        caseCV.RecordTypeId = Constants.CVRECORDTYPEID;
        caseCV.Internal_Status__c = Constants.CASE_STATUS_SENT_FOR_VERIFICATION;
        caseCV.Entity__c = acct.Id;
        caseCV.Alternate_Entity__c = acct.Id;
        caseCV.ContactId = [SELECT Id FROM Contact Limit 1].Id;
        Insert caseCV;
        System.assert(caseCV.Id != null,'CV case creation failed');
        Affirmation__c affCV = new Affirmation__c();
        affCV.RecordTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        affCV.Case__c = caseCV.Id;
        Insert affCV;
        System.assert(affCV.Id != null,'CV affirmation creation failed');
        string errorMsg = '';
        string strScreenName = 'Not_Verified_Screen_1';
        Map<String, Object> mapValues = new Map<String, Object>();
        mapValues.put('Not_Verified_Next_Step__c',(Label.Not_Verified_Status_Portal).split(',')[0]);
        mapValues.put('Comments__c',ConstantsTest.TEST_STRING);
        mapValues.put('Case__c',caseCV.Id);
        Affirmation_Validation__mdt mdtValidation = Affirmation_Validation__mdt.getInstance(strScreenName);
        NotVerifiedAffirmationValidation notVerAff = new NotVerifiedAffirmationValidation();
        errorMsg = notVerAff.process(mdtValidation, mapValues);
        string expectederrMsg = Error_Message__mdt.getInstance('Not_Verified_Screen_1_Next_Action_Portal').Error_Message__c + '@';
        system.assertEquals(expectederrMsg, errorMsg,'Error not thrown');
        Service__c newSer = new Service__c();
        newSer.Name = Constants.SERVICE_NAME_CREDENTIAL_VERIFICATION;
        Insert newSer;
        system.assert(newSer.Id!=null,'Service not inserted');
        Account2Service__c acctServ = new Account2Service__c();
        acctServ.active__c = true;
        acctServ.Account__c = acct.Id;
        acctServ.Service__c = newSer.Id;
        Insert acctServ;
        System.assert(acctServ.Id != null, 'Account2Service creation failed');
        errorMsg = notVerAff.process(mdtValidation, mapValues);
        system.assert(String.isBlank(errorMsg),'Error thrown for Entity Portal');
        affCV.Verify_with_Alternate_Entity__c = true;
        Update affCV;
        system.assert(affCV.Verify_with_Alternate_Entity__c,'Affirmation updated');
        errorMsg = notVerAff.process(mdtValidation, mapValues);
        system.assert(String.isBlank(errorMsg),'Error thrown for alternalte Entity Portal');
    }
}