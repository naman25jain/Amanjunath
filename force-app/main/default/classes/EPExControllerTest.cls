/**
* Test Class for EPExController class
*
* @author        Femi
* @version       1.0
* @createdDate   01-APR-2020
*/
@isTest
public class EPExControllerTest extends ECFMGTestFactory{
    @testSetup static void setup() {
        CurrentECFMGIDSequence__c curECFMGSetting = CurrentECFMGIDSequence__c.getOrgDefaults();
        curECFMGSetting.ECFMG_ID__c = '00000001';
        upsert curECFMGSetting;
        CurrentEntityIDSequence__c curEntitySetting = CurrentEntityIDSequence__c.getOrgDefaults();
        curEntitySetting.Entity_ID__c = '0000000';
        upsert curEntitySetting;
        EPExTestFactory.servicePageSetup();
        // Doc Config
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EIF Doc Config', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'EV Case Template', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('EV_FORM').Value__c));
        // Account
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        run();
        // cat
        Contact cont = [SELECT id,School_Enrollment_Status__c,AccountId FROM Contact WHERE Name='First Last' LIMIT 1];
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Contact_Association_Type__c cat1 = new Contact_Association_Type__c();
        cat1.RecordTypeId = degMedSchRecordTypeId;
        cat1.contact__c = cont.Id;
        cat1.account__c = acc.Id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactAssociationTestData.class, cat1);
        run();
        // A2s
        Account2Service__c acc2ser = new Account2Service__c();
        acc2ser.Account__c = acc.Id;
        insert acc2ser;
    }
    @isTest static void testEPEx(){
        Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Case ePExcase = [SELECT id FROM case WHERE recordType.DeveloperName ='Eligibility_Period_Extension'][0];
        Case examRegcase = [SELECT id FROM case WHERE recordType.DeveloperName ='Exam_Registration'AND Eligibility_Period__r.Exam_Type__c = 'USMLE Step 1' LIMIT 1];
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        System.assert(String.valueOf(testUser.contactId)!= NULL, 'Validate ePEx case.');
        EPExController.manageSchedulingPermit(ePExcase.Id);
        Test.startTest();
        EPExController.getTermsandConditionsEPEx();
        System.runAs(testUser){
            List<EPExController.EpexWrapper> epexList = EPExController.getEPExExams();
            System.assertEquals(2, epexList.size(), 'All exams not found');
            String selectedList = examRegcase.Id;
            EPExController.createEPExCase(selectedList);
            List<Case> newEpexCases = [SELECT Id, CaseNumber FROM Case WHERE RecordTypeId =: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId =: examRegcase.Id];
            System.assertEquals(1, newEpexCases.size(), 'Epex case not created');
            List<EPExController.EpexWrapper> epexList2 = EPExController.getEpexCaseDetails();
            System.assertEquals(1, epexList2.size(), 'Epex case not found');
            String returnStr = EPExController.getEPExCaseNumber();
            System.assert(returnStr.contains(newEpexCases[0].CaseNumber), 'Epex case not returned');
        } 
        Test.stopTest();
    }
    @isTest static void testupdateEpexCasesForEV(){
        Id ePExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ELIGIBILITY_PERIOD).getRecordTypeId();
        Case examRegcase = [SELECT id,Enrollment_Verification_Parent__c FROM case WHERE recordType.DeveloperName ='Exam_Registration'AND Eligibility_Period__r.Exam_Type__c = 'USMLE Step 1' LIMIT 1];
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        System.assert(String.valueOf(testUser.contactId)!= NULL, 'Validate ePEx case.');
        // update Contact
        Contact cont = [SELECT id,School_Enrollment_Status__c FROM Contact WHERE id=:testUser.ContactId LIMIT 1];
        cont.School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_STUDENT;
        update cont;
        Test.startTest();
        System.runAs(testUser){
            String selectedList = examRegcase.Id;
            run();
            EPExController.createEPExCase(selectedList);
            List<Case> newEpexCases = [SELECT Id, CaseNumber,Internal_Status__c,ContactId,ParentId FROM Case WHERE RecordTypeId =: ePExRecordTypeId AND Internal_Status__c =: Constants.CASE_STATUS_PENDING_SUBMISSION AND ParentId =: examRegcase.Id];
            System.assertEquals(1, newEpexCases.size(), 'Epex case not created');
            String returnStr = EPExController.getEPExCaseNumber();
            System.assert(returnStr.contains(newEpexCases[0].CaseNumber), 'Epex case not returned');
        } 
        Test.stopTest();
    }
    @isTest static void testmanageEPExRequest(){
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        Case ePExcase = [SELECT id FROM case WHERE recordType.DeveloperName ='Exam_Registration' AND Eligibility_Period__r.Exam_Type__c = 'USMLE Step 1' LIMIT 1];
        String selected = ePExcase.Id;
        Test.startTest();
        System.runAs(testUser){
            Boolean returnValue = EPExController.validateEPExRequest('USMLE Step 1',selected);
            System.assert(!returnValue, 'Validation failed');
        } 
        Test.stopTest();  
    }
    @isTest static void testenableEligPeriodExtRequest(){
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        String valLabel = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE+' ' + System.label.Eligibility_Period_Extension_StartDateValidation;
        valLabel = valLabel+Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE+' ' + System.label.Eligibility_Period_Extension_EndDateValidation;
        valLabel = valLabel+ Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE+' ' + System.label.Eligibility_Period_Extension_CaseAlreadyExist;
        valLabel = valLabel+Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK+' ' + System.label.Eligibility_Period_Extension_StartDateValidation;
        valLabel = valLabel+Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK+' ' + System.label.Eligibility_Period_Extension_EndDateValidation;
        valLabel = valLabel+Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK+' ' + System.label.Eligibility_Period_Extension_CaseAlreadyExist;
        Test.startTest();
        System.runAs(testUser){
            String value = EPExController.enableEligPeriodExtRequest();
            System.assertNotEquals(null,value, 'Assert Not equal.');
        } 
        Test.stopTest();
    }
     @isTest static void testenableOFACValidation(){
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        OFAC__c ofacECFMG = new OFAC__c(Country__c = 'Mexico',Type__c = 'Restricted_by_NBME');
        INSERT ofacECFMG;
        System.assert(ofacECFMG.Id != null, 'ofacECFMG creation failed');
        String valLabel = 'Applicant is from restricted country' + '<br>';
        Test.startTest();
        System.runAs(testUser){
            String value = EPExController.enableEligPeriodExtRequest();
            System.assertEquals(valLabel,value, 'Values Not equal.');
        } 
        Test.stopTest();        
    }
    @isTest static void testOnBiographic(){
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        Test.startTest();
        System.runAs(testUser){
            String value = EPExController.extRequestOnBiographic();
            Id bioChangeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Applicant_Biographic_Change').getRecordTypeId();
            Case newCase = new Case();
            newCase.Internal_Status__c = 'Open';
            newCase.RecordTypeId = bioChangeRecordTypeId;
            newCase.ContactId = testUser.contactId;
            INSERT newCase;
            System.assert(newCase.Id != null, 'newCase creation failed');
            value = EPExController.extRequestOnBiographic();
            System.assertEquals('Your Biographic Change case must be accepted before you can proceed with this application.<br>', value, 'Values are equal.');
            newCase.Internal_Status__c = 'Rejected';
            UPDATE newCase;
            System.assert(newCase.Id != null, 'newCase updation failed');
            value = EPExController.extRequestOnBiographic();
            System.assertNotEquals('Your Biographic Change case must be accepted before you can proceed with this application.<br>', value, 'Values Not equal.');
        } 
        Test.stopTest();        
    }
    @isTest
    private static void testupdateEVcase(){
        User testUser = [SELECT id,contactId FROM User WHERE alias='second'];
        Test.startTest();
        System.runAs(testUser){
            Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
            List<Case> evCaseList = new List<Case>();
            Case evCase = new Case();
            evcase.ContactId = testUser.contactId;
            evCase.RecordTypeId = evRTId;
            ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultCaseData.class, evCase);
            run();
            evCaseList.add(evCase);
            EPExController.reUpdateEVCaseForEpex(evCaseList);
            Case retEvCase = [SELECT id,Internal_Status__c,External_Status__c FROM Case WHERE id=:evCase.Id];
            System.assert(retEvCase.Internal_Status__c == Constants.CASE_STATUS_POSTED_TO_ENTITY_PORTAL, 'EV Case not updated');
        }
        Test.stopTest();
    }
}