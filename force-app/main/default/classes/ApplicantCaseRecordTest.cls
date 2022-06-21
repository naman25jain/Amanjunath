@isTest
public class ApplicantCaseRecordTest{
    public static testMethod void testMethod1(){
        test.startTest();
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acct = new Account(Name = 'Entity Account', RecordTypeId = idAccountTypeId, School__c = true);
        acct.BillingCountry = 'United States';
        acct.BillingState = 'California';
        acct.BillingCity = 'Test City';
        acct.BillingPostalCode = '123456';
        acct.BillingStreet = 'Test';
        insert acct;
		Id idContactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName = 'Entity', LastName = 'User', RecordTypeId = idContactTypeId, Email = email1, AccountId = acct.Id);
        insert con;
        Id p=[Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        
		system.runAs(user){
            Case createCase = new Case();
            Id recTypeScoreRecheck = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Application_For_Certification').getRecordTypeId();
            createCase.RecordTypeId = recTypeScoreRecheck;
            createCase.Internal_Status__c = 'Incomplete';
            insert createCase;
            Case createCase2 = new Case();
            Id recTypeScoreRecheck2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
            createCase2.RecordTypeId = recTypeScoreRecheck2;
            createCase2.Internal_Status__c = 'Registered';
            insert createCase2;
            Case createCase3 = new Case();
            createCase3.RecordTypeId = recTypeScoreRecheck2;
            createCase3.Internal_Status__c = 'Submitted - In Review at ECFMG';
            insert createCase3;
            Case createCase4 = new Case();
            createCase4.RecordTypeId = recTypeScoreRecheck2;
            createCase4.Internal_Status__c ='Enrollment Verification Incomplete';
            insert createCase4;
            Case createCase5 = new Case();
            createCase5.RecordTypeId = recTypeScoreRecheck2;
            createCase5.Internal_Status__c = 'Online Notary Session Created';
            //insert createCase5;
            Map<String, Map<String, String>> returnVal = ApplicantCaseRecord.getApplicantRequestData();
            System.assertNotEquals(NULL, returnVal, 'Not NULL');
        }
        test.StopTest();
    }
}