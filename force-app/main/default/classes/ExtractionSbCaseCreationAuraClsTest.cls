@isTest
Public with sharing Class ExtractionSbCaseCreationAuraClsTest extends ECFMGTestFactory{
    //testgetCaseDet
    @isTest public static void testgetCaseDet(){
        Account newApplAcct = new Account();
        newApplAcct.Name = 'abc tester';
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, newApplAcct);
        run();
        System.assert(newApplAcct.Id!=null,'Applicant account not created');
        Id applRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORD_TYPE_APPLICANT ).getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = newApplAcct.Id;
        con.LastName = 'Test';
        con.Email = 'test1@test.com';
        con.RecordTypeId = applRecTypeId;
        INSERT con;
        Id epicExtrRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Case parCas = new Case();
        parCas.RecordTypeId = epicExtrRecTypeId;
        parCas.ContactId = con.Id;
        parCas.Internal_Status__c = Constants.CASE_STATUS_NEW;
        parCas.AccountId = newApplAcct.Id;
        parCas.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT parCas;
        System.debug('parCas : '+parCas.OwnerId);
        System.assert(parCas.Id!=null,'Case not found!');
        Id subcsExtRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EPIC_EXTRACTION).getRecordTypeId();
        Case newCase = new Case();
        newCase.RecordTypeId = subcsExtRecTypeId;
        newCase.Ownerid = userinfo.getUserId();//parCas.Ownerid;
        newCase.ContactId = parCas.ContactId;
        newCase.Internal_Status__c = Constants.CASE_STATUS_IN_REVIEW; //Constants.CASE_STATUS_IN_PROGRESS;
        newCase.AccountId = newApplAcct.Id;
        newCase.Service__c = Constants.CASE_SERVICE_EPIC;
        INSERT newCase;
        System.assert(newCase.Id!=null,'Case not found!');
        Verification_Packet__c verPack = new Verification_Packet__c();
        verPack.Is_Active__c = true;
        verPack.Case__c = newCase.Id;
        verPack.Contact__c = newCase.ContactId;
        INSERT verPack;
        System.assert(verPack.Id!=null,'Case not found!');
        Test.startTest();
        ExtractionSbCaseCreationAuraCls.subcaseInsert(parCas.Id);
        Test.stopTest();
    }
}