@isTest(seeAllData=false)
public class TranscriptAnnotationTriggerTest{
    @isTest
    public static void singleTranscriptTestMethod(){
        Account acc;
        Contact con;
        id conRecordTypeId;
        Id investCaseRecTypeId;
        conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT).getRecordTypeId();
        investCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_INVESTIGATION).getRecordTypeId();
        acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        insert acc;
        con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        insert con;
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Contact=con, RecordTypeId=investCaseRecTypeId, Internal_Status__c=Constants.CASE_STATUS_IN_REVIEW, Annotation__c='Standard',AccountId=acc.id));
        insert cas;
        Id profileId = [SELECT id FROM Profile WHERE name =: Constants.Applicant_360_USER_PROFILE LIMIT 1].id;
        String email1 = 'testUser@gmail.com';
        String country = 'America/Los_Angeles';
        String country2 = 'United States';
        User user = new User(alias='eUser',email=email1,emailencodingkey='UTF-8',lastname='User', languagelocalekey='en_US',localesidkey='en_US',profileid=profileId,country=country2,IsActive=true,ContactId=con.Id, timezonesidkey=country,username=email1);
        insert user;
        System.assert(true, true);
        Transcript_Anotation__c transcript = new Transcript_Anotation__c();
        transcript.ANNOTATION_CODE__c = '10';
        transcript.ANNOTATION_TEXT__c = 'Test Record';
        transcript.SHORT_TEXT__c = 'Testing';
        transcript.Cibis_Transcript_Status__c = 'APP IRREGULAR';
        transcript.SORT_ORDER__c = 2;
        transcript.ACTIVE__c = 'Y';
        transcript.Contact__c = con.id;
        transcript.Transcript_Case__c = cas.id;
        insert transcript; 
    }
}