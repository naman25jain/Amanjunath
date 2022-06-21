//Test Class for Enrollment Reverification case creation
@isTest
public with sharing class EnrollmentReVerificationBatchTest{
    public static TestMethod void enrollmentReVerBatchTest(){
        //create a new contact;
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailTest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_STUDENT);
        insert c1;
        system.assert(c1.Id != null,'Contact id is null');
        Id p = [Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        system.assert(user1.Id != null,'user1 id is null');
        //get the Household Account
        String accountname = lastname + ' Household';
        Account a = [Select Id from Account where name= :accountname LIMIT 1];
        String gradYear = String.valueOf((System.today() + 365).year());
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,
                                                    Contact__c = c1.Id, Account__c=a.id, School_Program__c = 'MBBS',
                                                    Start_Date__c = System.today() - 365, End_Date__c = System.today() + 365,
                                                    Graduation_Month__c = 'May', Graduation_Year__c = gradYear, Number_of_Years_Attended__c = 2);
        insert conAssocType;
        system.assert(conAssocType.Id != null,'conAssocType id is null');
        //Create and Insert Asset
        Asset asst1 = new Asset(
            Name = 'Test Asset',
            AccountId = a.id,
            ContactId = c1.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	'Photo'
        );
        insert asst1;
        system.assert(asst1.Id != null,'asst1 id is null');
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'EnrollReverification Case Template';
        docConfig.cadmus_core__CustomerDocumentConfigId__c ='46b34380-9e1a-4401-a102-07ec5d4d66ad';
        insert docConfig;
        system.assert(docConfig.Id != null,'docConfig id is null');
        Exam_Region__c examReg1 = new Exam_Region__c();
        examReg1.Name = 'RegionA';
        examReg1.Region_Name__c = 'RegionA';
        insert examReg1;
        system.assert(examReg1.Id != null,'examReg1 id is null');
        List<Exam_Region_Surcharge__c> examRegSurList = new List<Exam_Region_Surcharge__c>();
        Exam_Region_Surcharge__c examRegSur1 = new Exam_Region_Surcharge__c();
        examRegSur1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examRegSur1.Exam_Region__c = examReg1.Id;
        examRegSur1.Surcharge__c = 50;
        examRegSurList.add(examRegSur1);
        Exam_Region_Surcharge__c examRegSur2 = new Exam_Region_Surcharge__c();
        examRegSur2.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        examRegSur2.Exam_Region__c = examReg1.Id;
        examRegSur2.Surcharge__c = 50;
        examRegSurList.add(examRegSur2);
        insert examRegSurList;
        system.assert(examRegSurList[0].Id != null,'Insertion of examRegSur failed');
        //create new case
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id eVTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Id eRvTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_REVERIFICATION).getRecordTypeId();
        Case csEv = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=eVTypeId, Internal_Status__c ='New', Enrolled_in_Entity_Portal__c = false,Signature_Date__c = System.today() -200);
        insert csEv;
        system.assert(csEv.Id != null,'Insertion of csEv failed');
        Case csEr = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId = idExamRegTypeId,
                    Enrollment_Verification_Parent__c = csEv.Id, Internal_Status__c='Registered', Exam_Region_Surcharge__c =examRegSurList[0].Id,
                    Signature_Date__c = System.today() +200);
        insert csEr;
        system.assert(csEr.Id != null,'Insertion of csEr failed');
        date epStartDate = System.today();
        date epEndDate = System.today() + 240;
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
        updateExamRegistration1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        updateExamRegistration1.Exam_Region_Surcharge__c = examRegSurList[0].Id;
        updateExamRegistration1.Surcharge__c = examRegSurList[0].Surcharge__c;
        updateExamRegistration1.EP_start_Date__c = epStartDate;
        updateExamRegistration1.EP_end_Date__c = epEndDate;
        updateExamRegistration1.Test_Accommodations_needed__c = 'yes';
        updateExamRegistration1.Visa_Letter_Needed__c = false;
        updateExamRegistration1.case__c = csEr.Id;
        updateExamRegistration1.Applicant__c = c1.Id;
        updateExamRegistration1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration1.Posted_Date__c = System.today() - 1;
        updateExamRegistration1.Exam_taken_date__c = System.today() - 10;
        insert updateExamRegistration1;
        system.assert(updateExamRegistration1.Id != null,'Insertion of updateExamRegistration1 failed');
        Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
        updateExamRegistration2.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        updateExamRegistration2.Exam_Region_Surcharge__c = examRegSurList[1].Id;
        updateExamRegistration2.Surcharge__c = examRegSurList[1].Surcharge__c;
        updateExamRegistration2.EP_start_Date__c = epStartDate;
        updateExamRegistration2.EP_end_Date__c = epEndDate;
        updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
        updateExamRegistration2.Visa_Letter_Needed__c = false;
        updateExamRegistration2.case__c = csEr.Id;
        updateExamRegistration2.Applicant__c = c1.Id;
        updateExamRegistration2.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration2.Posted_Date__c = System.today() - 370;
        updateExamRegistration2.Exam_taken_date__c = System.today() - 380;
        Test.startTest();
        insert updateExamRegistration2;
        system.assert(updateExamRegistration2.Id != null,'Insertion of updateExamRegistration2 failed');
        System.schedule('Enrollment Reverification Case Creation Job'+System.now(), '0 30 1 * * ? *', new EnrollmentReVerificationScheduler());
        Database.executeBatch(new EnrollmentReVerificationBatch(),200);
        Test.stopTest();
        List<Case> enReverifCase = [SELECT Id FROM Case WHERE RecordTypeId =:eRvTypeId AND ContactId =: c1.Id];
        List<Case> examCase = [SELECT Id,Enrollment_Re_Verification_Parent__c FROM Case WHERE RecordTypeId =:idExamRegTypeId AND ContactId =: c1.Id];
        System.assertEquals(1,enReverifCase.size(),'Size is greater than 1 or 0');
        System.assertEquals(enReverifCase[0].Id,examCase[0].Enrollment_Re_Verification_Parent__c,'Expecting enrollment Reverification parent id');
    }
}