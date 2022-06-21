/**
 * Created by Matthew on 2019-07-15.
 */
@isTest
public class CaseServiceTest extends ECFMGTestFactory{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    @testSetup static void setup(){
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name = 'Test Acc'));
        run();
        Contact con = new Contact();
		con.AccountId = acc.Id;
		con.LastName = 'Test';
		con.Email = 'test@test.com';
		con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, con);
        run();
        Contact con1 = new Contact();
		con1.AccountId = acc.Id;
		con1.LastName = 'Test';
		con1.Email = 'test@test1.com';
		con1 = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, con1);
        run();
		Case caseVar = new Case();
		caseVar.ContactId = con.Id;
		INSERT caseVar;
    }
    @isTest static void testMethods(){
        Contact con = [SELECT Id FROM Contact WHERE Email ='test@test.com' LIMIT 1];
        Case testCase = [SELECT Id, ContactId FROM Case WHERE ContactId = :con.Id LIMIT 1];
        system.assertEquals(testCase.Id, CaseService.getCase(testCase.Id).Id, 'Case Ids are different.');
        Contact con2 = [SELECT Id FROM Contact WHERE Email ='test@test1.com' LIMIT 1];
        testCase.ContactId = con2.Id;
        CaseService.updateCase(testCase);
        system.assertEquals(testCase.ContactId, con2.Id, 'Case Service updateCase method failed');
        CaseService.setCaseAttribute(testCase.Id, 'testName', 'testValue');
        system.assertEquals('testValue', CaseService.getCaseAttribute(testCase.Id, 'testName'), 'Case attribute not set properly');
        CaseService.removeCaseAttribute(testCase.Id, 'testName');
        List<Case_Attribute__c> caseAttributes = [SELECT Id, Name, Case__c FROM Case_Attribute__c WHERE Case__c =: testCase.Id];
        system.assertEquals(0, caseAttributes.size(), 'Case attribute not removed');
        Case_Attribute__c ca = new Case_Attribute__c();
        ca.Name = 'testName2';
        ca.Value__c = 'testVal';
        ca.Case__c = testCase.Id;
        INSERT ca;
        CaseService.setCaseAttribute(testCase.Id, 'testName2', 'testValue2');
        Case_Attribute__c caToCompare = [SELECT Id, Name, Case__c, Value__c FROM Case_Attribute__c WHERE Id =: ca.Id];
        system.assertEquals('testValue2', caToCompare.Value__c, 'Case Attribute did not get updated');
        system.assertEquals(null, CaseService.getCaseByVerificationRequestId('test'), 'There exists a case with given verification request id');
        Asset testAsset = new Asset();
        testAsset.Name = 'TCT';
        testAsset.Status = Constants.ASSET_STATUS_IN_PROGRESS;
        testAsset.ContactId = con.Id;
        testAsset.Case__c = testCase.Id;
        INSERT testAsset;
        CaseService.massUpdateCaseAssetsAndAffirmations(testCase.Id, Constants.ASSET_STATUS_REJECTED, Constants.ASSET_STATUS_REJECTED);
        Asset assetToCompare = [SELECT Id, Status FROM Asset WHERE Id =:testAsset.Id LIMIT 1];
        system.assertEquals(Constants.ASSET_STATUS_REJECTED, assetToCompare.Status, 'Asset Status did not get updated');
        system.assertEquals(0, CaseService.getChildCases(testCase.Id).size(), 'There exist child cases for given case id');
    }
}