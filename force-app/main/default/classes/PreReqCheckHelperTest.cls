@isTest
private class PreReqCheckHelperTest {
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
    @isTest
    static void checkIdVerfctnPreReqTest() {
        date birthDate = date.valueOf('2000-01-01');
        string emailTest = 'tester@unknownmail.com';
        string lastName = 'Last';
        string firstName = 'First';
        Contact c1 = new Contact(Firstname=firstName,Lastname=lastName,Birthdate=birthDate,email=emailTest,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_GRADUATE);
        insert c1;
        Asset asst1 = new Asset(
                Name = Constants.ASSET_NAME_ID_FORM_NOTARIZED,
                Status = Constants.ASSET_STATUS_VERIFIED,
                ContactId = c1.Id,
                InstallDate = System.Today(),
      			type__c = Constants.ASSET_TYPE_IDENTITY_VERIFICATION
            );
        insert asst1;
        List<Contact> applicants = new List<Contact>();
        applicants.add(c1);
        List<contact> eligibleApplicants = PreReqCheckHelper.checkIdVerificationPreReq(applicants);
        System.Assert(eligibleApplicants.contains(c1),'check failed'); 
    }
    @isTest
    static void checkExamPreReqTest() {
        date birthDate = date.valueOf('2000-01-01');
        string emailTest = 'tester@unknownmail.com';
        string lastName = 'Last';
        string firstName = 'First';
        Contact c1 = new Contact(Firstname = firstName, Lastname = lastName, Birthdate = birthDate, email = emailTest, MailingCountry = 'Mexico', School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE, English_Exam_Completed__c = true, Pathways_Completed__c = true);
        insert c1;
        List<Exam_Registration__c> examRegs = new List<Exam_Registration__c>();
        Exam_Registration__c examRegObject = new Exam_Registration__c();
        examRegObject.Applicant__c = c1.Id;
        examRegObject.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examRegObject.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examRegs.add(examRegObject);
        Exam_Registration__c examRegObject1 = new Exam_Registration__c();
        examRegObject1.Applicant__c = c1.Id;
        examRegObject1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examRegObject1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        examRegs.add(examRegObject1);
        insert examRegs;
        List<Contact> applicants = new List<Contact>();
        applicants.add(c1);
        List<contact> eligibleApplicants = PreReqCheckHelper.checkExamPreReq(applicants);
        System.Assert(eligibleApplicants.contains(c1),'check failed'); 
    }

    @isTest static void credentialPreReqCheckTest(){
        date birthDate = date.valueOf('2000-01-05');
        string emailTest = 'testerTest@unknownmail.com';
        string lastName = 'LastTest';
        string firstName = 'FirstTest';
        Contact cont = new Contact(Firstname = firstName, Lastname = lastName, Birthdate = birthDate, email = emailTest, MailingCountry = 'Albania', School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE, Credential_Pre_req_exempted__c = true);
        Contact cont1 = new Contact(Firstname = 'firstName1', Lastname = 'lastName1', Birthdate = birthDate, email = emailTest, MailingCountry = 'Albania', School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE, Attestation_Prerequisite_met__c = false);
        Contact cont2 = new Contact(Firstname = 'firstName2', Lastname = 'lastName2', Birthdate = birthDate, email = emailTest, MailingCountry = 'Albania', School_Enrollment_Status__c = Constants.CONASCTYPESTG_STATUS_GRADUATE, Attestation_Prerequisite_met__c = true);
        List<Contact> applicantsList = new List<Contact>();
        applicantsList.add(cont);
        applicantsList.add(cont1);
        applicantsList.add(cont2);
        INSERT applicantsList;
        System.Assert(!applicantsList.isEmpty(),'List of applicants insertion Failed');
        List<Account> accounttList = new List<Account>();
        Id identityAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId();
        Account acc3 = new Account(Name='EntityAcctNameforNegative',RecordTypeId=identityAccountRecordTypeId,School__c=false, Is_Final_Transcript_Required__c = true,ECFMG_Acceptable__c = True, BillingCountry = 'India',BillingState='Goa',billingpostalcode = '123457');
        accounttList.add(acc3);
        INSERT accounttList;
        System.Assert(!accounttList.isEmpty(),'List of accounttList insertion Failed');
        List<Contact_Association_Type__c> catList = new List<Contact_Association_Type__c>();
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Id conAssocRecordTypeIdMedSchool = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Medical_School').getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,contact__c = cont1.Id,Account__c=acc3.id,Graduation_Year__c = '2020');
        Contact_Association_Type__c conAssocType2 = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeIdMedSchool,contact__c = cont2.Id,Account__c=acc3.id,Graduation_Year__c = '2020',Transfer_Credit_to_Degree_School__c = true);
        catList.add(conAssocType);
        catList.add(conAssocType2);
        insert catList;
        System.Assert(!catList.isEmpty(),'List of catList insertion Failed');
        Asset asst1 = new Asset(
            Name = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = cont1.Id,
            InstallDate = System.Today(),
            Type__c = Constants.ASSET_TYPE_FINAL_MED_DIPLOMA
        );
        Asset asst2 = new Asset(
            Name = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = cont1.Id,
            InstallDate = System.Today(),
            Type__c = Constants.ASSET_TYPE_FINAL_MED_SCHOOL_TRANSCRIPT
        );
        Id asset3RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Credential').getRecordTypeId();
        Asset asst3 = new Asset(
            Name = Constants.ASSET_TYPE_TCT,
            Status = Constants.ASSET_STATUS_ACCEPTED,
            ContactId = cont1.Id,
            InstallDate = System.Today(),
            Type__c = Constants.ASSET_TYPE_TCT,
            Contact_Association_Type__c = conAssocType2.Id,
            RecordTypeId = asset3RecordTypeId
        ); 
        List<Asset> assetList = new List<Asset>();
        assetList.add(asst1);
        assetList.add(asst2);
        assetList.add(asst3);
        INSERT assetList;
        System.Assert(!assetList.isEmpty(),'List of assetList insertion Failed');
        Degree__c deg = new Degree__c(Name = 'BBA');
        insert deg;
        System.Assert(deg.Id!= null,'degree insertion Failed');
        List<Object2Degree__c> ob2DegList = new List<Object2Degree__c>();
        Id schoolObject2DegreeRecordTypeId = Schema.SObjectType.Object2Degree__c.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        Object2Degree__c ob2Deg = new Object2Degree__c(Account__c = acc3.Id,Graduation_Year__c = '2020',Degree__c = deg.Id,RecordTypeId = schoolObject2DegreeRecordTypeId);
        Object2Degree__c ob2Deg1 = new Object2Degree__c(Account__c = acc3.Id,Graduation_Year__c = '2021',Degree__c = deg.Id,RecordTypeId = schoolObject2DegreeRecordTypeId);
        ob2DegList.add(ob2Deg);
        ob2DegList.add(ob2Deg1);
        INSERT ob2DegList;
        System.Assert(!ob2DegList.isEmpty(),'List of ob2DegList insertion Failed');
        Test.StartTest();
        List<Contact> returnList = PreReqCheckHelper.credentialPreReqCheck(applicantsList);
        System.AssertEquals(applicantsList[0].Id,returnList[0].Id,'Contact cont is not in the list');
        List<Contact> nonRestrApplicants = PreReqCheckHelper.checkRestrictions(applicantsList);
        System.AssertEquals(nonRestrApplicants.isEmpty(),false,'Non Restricted Applicants list is empty');
        Test.StopTest();
    }
    @isTest
    static void testCheckFinancePreReq() {
        date birthDate = date.valueOf('2000-04-07');
        string emailTest = 'testUser@unknownmail.com';
        string lastName = 'LastName';
        string firstName = 'FirstName';
        date birthDate2 = date.valueOf('2000-07-07');
        string emailTest2 = 'testCon@unknownmail.com';
        string lastName2 = 'LName';
        string firstName2 = 'FName';
        List<Contact> conList = new List<Contact>();
        Contact c1 = new Contact(Firstname=firstName,Lastname=lastName,Birthdate=birthDate,email=emailTest,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_GRADUATE, Fin_Email_Reminder_Sent__c = false);
        conList.add(c1);
        Contact c2 = new Contact(Firstname=firstName2,Lastname=lastName2,Birthdate=birthDate2,email=emailTest2,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_GRADUATE);
        conList.add(c2);
        insert conList;
        System.assertNotEquals(c1.Id, NULL, 'Contact Id Not Null');
        List<Contact> applicants = new List<Contact>();
        applicants.add(c1);
        applicants.add(c2);
        List<contact> retVal = PreReqCheckHelper.checkFinancePreReq(applicants);
        System.assertNotEquals(retVal, NULL, 'Not null');
        PreReqCheckHelper.notifyApplicantFinDebit(applicants);
    }
}