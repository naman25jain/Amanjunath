// Test class for MedEduFormCaseTriggerHandler
@isTest
public with sharing class MedEduFormCaseTriggerHandlerTest extends ECFMGTestFactory{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    // Setting up test data
    @TestSetup
    public static void setUp(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c);   
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Id idAccountTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Id caseParentRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_FCVS_REQUEST').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test', RecordTypeId = idAccountTypeId, School__c = true, BillingCountry = 'United States', BillingState = 'California', BillingCity = 'TEst', BillingPostalCode = '123456'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        Case parentCase = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Subject ='New1',Contact=con,RecordTypeId=caseParentRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c));
        run();
    }
    //Test before update
    @isTest
    static void testBeforeUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c);   
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id idAccountTypeIdFetch = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc =[SELECT Id FROM Account where RecordTypeId =: idAccountTypeIdFetch and name ='Account Test' limit 1];
        Case parentCase =[SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(ParentId=parentCase.id, Contact=con,Entity__c=acc.Id,Alternate_Entity__c=acc.id,Service__c =Constants.CASE_SERVICE_ECFMG_CERT,RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c));
        run();
        cas.Internal_Status__c =  Constant_Case__mdt.getInstance('STATUS_RESENT_FOR_VERIFICATION').Value__c;
        Update cas;
        cas.Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_CV_ACCEPTED').Value__c;
        Update cas;
    }
    @isTest
    static void testAfterInsert(){
        Id affRecTypeId=Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get( Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_FORM').Value__c).getRecordTypeId();
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c);   
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id idAccountTypeIdFetch = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
       	Account acc =[SELECT Id FROM Account where RecordTypeId =: idAccountTypeIdFetch and name ='Account Test' limit 1];
        acc.Entity_ID__c='test1234';
        update acc;
        Case parentCase =[SELECT Id,Internal_Status__c FROM Case LIMIT 1];
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Subject ='New2',ParentId=parentCase.id,Contact=con,Entity__c=acc.Id,Alternate_Entity__c=acc.id,Service__c =Constants.CASE_SERVICE_ECFMG_CERT,RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        Case cas1 = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Subject ='New3',ParentId=parentCase.id,Contact=con,Entity__c=acc.Id,Alternate_Entity__c=acc.id,Service__c =Constants.CASE_SERVICE_ECFMG_CERT,RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_PENDING_REVIEW').Value__c));
        run();
        Affirmation__c aff =(Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(Verify_with_Alternate_Entity__c=true,Case__c =cas.id,RecordTypeId=affRecTypeId));
        Affirmation__c aff1 =(Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(Verify_with_Alternate_Entity__c=false,Case__c =cas.id,RecordTypeId=affRecTypeId));
        run();
        Account acct = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Test Entity Account', RecordTypeId = idAccountTypeIdFetch, Medschool_Code__c = 'MED001', BillingCountry = 'Bhutan'));
        run();
        System.assert(cas.Id!=null,'Case record not inserted');
        System.assert(acct.Id!=null,'Account record not inserted');
        cas.Internal_Status__c = Constants.CASE_STATUS_PENDING_VER_REVIEW;
        cas.Alternate_Entity__c = acct.id;
        cas.Entity__c = acct.id;
        Update cas;
    }
    @isTest
    static void testAfterUpdate(){
        Id caseRecTypeId = GenericUtilities.getRecordTypeIdByDevName('Case',Constant_Case__mdt.getInstance('REC_TYPE_MED_EDU_FORM').Value__c);   
        Id idAccountTypeIdFetch = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
      	Account acc =[SELECT Id FROM Account where RecordTypeId =: idAccountTypeIdFetch limit 1];
        acc.Entity_ID__c='test123';
        update acc;
        Case parentCase =[SELECT Id,Internal_Status__c FROM Case LIMIT 1]; 
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c ORDER BY CreatedDate DESC LIMIT 1];
        Id affRecTypeId=Schema.SObjectType.Affirmation__c.getRecordTypeInfosByDeveloperName().get( Constant_Affirmation__mdt.getInstance('REC_TYPE_DEV_MEDICAL_EDUCATION_FORM').Value__c).getRecordTypeId();
        Case cas = (Case)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, new Case(Subject ='New4',ParentId=parentCase.id, Contact=con,Entity__c=acc.Id,Alternate_Entity__c=acc.id,Service__c =Constants.CASE_SERVICE_ECFMG_CERT,RecordTypeId=caseRecTypeId, Internal_Status__c = Constant_Case__mdt.getInstance('STATUS_SENT_FOR_VERIFICATION').Value__c));
        run();
        Affirmation__c aff2 =(Affirmation__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAffirmationTestData.class, new Affirmation__c(Verify_with_Alternate_Entity__c=false,Case__c =cas.Id,RecordTypeId=affRecTypeId));
        run();
        Account acct = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Test Entity Account', RecordTypeId = idAccountTypeIdFetch));
        run();
        cas.Entity__c = acct.id;
        Update cas;
    }
}