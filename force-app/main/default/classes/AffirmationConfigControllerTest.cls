@isTest
public class AffirmationConfigControllerTest{
    @TestSetup
    static void testData(){
        List<RecordType> regUserRectTypeId = [select Id from RecordType where SobjectType = 'Contact' and Name = :Constants.CONTACT_RECORD_TYPE_REG_USR];
        List<Account> act = new List<Account>();
        act = [Select Id from Account where Id =: Label.Default_Portal_Account];
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.BillingCountry = 'India';
        INSERT acc;
        System.assert(acc.Id != null, 'acc not inserted');
        Contact con2;
        if(!act.isEmpty()){
            con2 = new Contact(
            FirstName = 'Test2',
            LastName = 'User2',
            Birthdate = System.today(),
            Gender__c = 'Male',
            AccountId = Label.Default_Portal_Account,
            RecordTypeId = regUserRectTypeId[0].Id
            );
            INSERT con2;  
        }
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        INSERT con;
        System.assert(con.Id != null, 'contact not inserted');
        Case objCase = new Case();
        objCase.AccountId = Label.Default_Portal_Account;
        objCase.subject = 'Test';
        objCase.ContactId = con.Id;
        INSERT objCase;
        System.assert(objCase.Id != null, 'case not inserted');
        Id affRecTypeId = Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get(Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION).getRecordTypeId();
        Affirmation__c objAf = new Affirmation__c();
        objAf.DOB_Evaluation_Status__c = 'Accepted';
        objAf.Credential_Evaluation_Status__c = 'Accepted';
        objAf.Case__c = objCase.Id;
        INSERT objAf;
        System.assert(objAf.Id != null, 'objAf not inserted');
        Asset asst = new Asset();
        asst.ContactId = con.Id;
        asst.Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        asst.Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA;
        INSERT asst;
        System.assert(asst.Id != null, 'Asst not inserted');
        Affirmation__c affr = new Affirmation__c();
        affr.Asset__c = asst.Id;
        affr.RecordTypeId = affRecTypeId;
        affr.Case__c = objCase.Id;
        affr.Reject_Translation__c = true;
        INSERT affr;
        System.assert(affr.Id != null,'affr not inserted');
    }
    @isTest
    static void testGetConfigs(){
        case objCase = [SELECT Id from Case limit 1];
        Asset asst = [SELECT Id from Asset limit 1];
        Affirmation__c objAf = [SELECT Id from Affirmation__c limit 1];
        map<String, Object> objMap = new Map<String, Object>{'DOB_Evaluation_Status__c' => 'Accepted', 'Credential_Evaluation_Status__c' => 'Accepted'};
        AffirmationConfigController.AffrimationConfigs objWrapper = AffirmationConfigController.getAffirmnationConfigs(Label.Screen_For_Test_Class, objCase.Id, objAf.Id, 'ID_Verification', new Map<String, object>{'Reject_Translation__c'=>true});
        System.assert(objWrapper.strAffirmationId != null, 'Data not returned');
        AffirmationConfigController.AffrimationConfigs objWrapper1 = AffirmationConfigController.getAffirmnationConfigs(Label.Screen_For_Test_Class, objCase.Id, '', Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION, null);
        System.assert(objWrapper1.strAffirmationId != null, 'Data not returned');
        AffirmationConfigController.AffrimationConfigs objWrapper2 = AffirmationConfigController.getAffirmnationConfigs(Label.Screen_For_Test_Class, asst.Id, '', Constants.AFFIRMATION_RECORD_TYPE_CREDENTIAL_VERIFICATION, new Map<String, object>{'Reject_Translation__c'=>true});
        System.assert(objWrapper2.strAffirmationId != null, 'Data not returned');
        AffirmationConfigController.AffirmationWrapper objWrapper3 = AffirmationConfigController.createAffirmationRecord(Label.Screen_For_Test_Class, objCase.Id, 'Affirmation__c', objMap, objAf.Id, 'ID_Verification');
        System.assert(objWrapper3.objAfRecord != null, 'Data not returned');   
    }
}