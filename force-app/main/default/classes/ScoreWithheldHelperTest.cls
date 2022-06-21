/**
* Test Class for ScoreWithheldHelper
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   12-MAY-2020
*/
@isTest
public class ScoreWithheldHelperTest {
    public static testMethod void scoreWithheldTest() {
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico');
        insert c1;
        System.assert(c1.Id!=null,'Contact not found');
        String accountName = lastname + ' Household';
        Account acct = [Select Id from Account where name= :accountName LIMIT 1];
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        System.assert(user1.Id!=null,'User doesnot exists');
        String examType = 'USMLE Step 1';
        cadmus_core__Doc_Config__c docConfig = new cadmus_core__Doc_Config__c();
        docConfig.Name = 'EnrollReverification Case Template';
        docConfig.cadmus_core__CustomerDocumentConfigId__c ='46b34380-9e1a-4401-a102-07ec5d4d66ad';
        insert docConfig;
        System.assert(docConfig.Id!=null,'Doc config doesnot exists');
        Id eVTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Enrollment_Reverification').getRecordTypeId();
        Case csEv = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=eVTypeId, Internal_Status__c='New');
        insert csEv;
        System.assert(csEv.Id!= null, 'Case record not found');
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Case cs = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered', Enrollment_Re_Verification_Parent__c =csEv.Id);
        insert cs;
        System.assert(cs.Id!=null,'Case not found');
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        System.assert(region.Id!=null,'Region not found');  
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        System.assert(regionSurcharge.Id!=null,'regionSurcharge record not found');
        date epStartDate = date.valueOf('2020-01-01');
        date epEndDate = date.valueOf('2020-04-01');
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
        updateExamRegistration.Application_Id__c = 2000;
        updateExamRegistration.USMLE_ID_CIBIS__c ='2000';
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Applicant__c = c1.Id;
		insert updateExamRegistration; 
        System.assert(updateExamRegistration.Id!=null,'Exam Registration record doesnot exists');
        String gradYear = String.valueOf((System.today() + 365).year());
        Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c degMedSchool = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,
                                                    Contact__c = c1.Id, Account__c=acct.id, School_Program__c = 'MBBS',
                                                    Start_Date__c = System.today() - 365, End_Date__c = System.today() + 365,
                                                    Graduation_Month__c = 'May', Graduation_Year__c = gradYear, Number_of_Years_Attended__c = 2);
        insert degMedSchool;
        System.assert(degMedSchool.Id!=null,'Not found');
        Service__c perfData = new Service__c();
        perfData.Name= Constants.SERVICE_NAME_PERFORMANCE_DATA;
        insert perfData;
        System.assert(perfData.Id!=null,'Service not found');
        Account2Service__c acc2ServiceRecord = new Account2Service__c ();
        acc2ServiceRecord.Account__c= acct.Id;
        acc2ServiceRecord.Active__c = True;
        acc2ServiceRecord.Service__c= perfData.Id;
      	insert acc2ServiceRecord;
        System.assert(acc2ServiceRecord.Id!=null,'Account2Service record not found ');
        updateExamRegistration.Pd_Optout_flag__c = false;
        updateExamRegistration.Test_Accommodations__c = 'Y';
        update updateExamRegistration;
        System.assert(updateExamRegistration.Pd_Optout_flag__c==false,'update failed');
        Test.startTest();
        NBME_Score_Update_Event__e testEvent = new NBME_Score_Update_Event__e(Application_id__c = 1000, USMLE_ID__c ='1000', Exam__c ='Step1',score_status__c = 'N',Test_Accommodations__c='Y',score_report_document_id__c=null);
        NBME_Score_Update_Event__e testEvent1 = new NBME_Score_Update_Event__e(Application_id__c = 2000, USMLE_ID__c ='2000', Exam__c ='Step1');
        Database.SaveResult sr = EventBus.publish(testEvent);
        Database.SaveResult sr1 = EventBus.publish(testEvent1);
        System.assertEquals(true, sr.isSuccess(),'Failed');
        System.assertEquals(true, sr1.isSuccess(),'Failed');
        Map<NBME_Score_Update_Event__e, Exam_Registration__c> eventExamRegMap = new Map<NBME_Score_Update_Event__e, Exam_Registration__c>();
        eventExamRegMap.put(testEvent,updateExamRegistration);
        Score_Report_Import_Error__c sRrecord = new Score_Report_Import_Error__c();
        sRrecord.USMLE_ID__c = '1000';
        sRrecord.Application_id__c = 1000;
        sRrecord.Exam__c ='Step1';
        insert sRrecord;
        System.assert(sRrecord.Id!=null,'Record not inserted');
        ScoreWithheldHelper.releaseScore(sRrecord.Id);
        Score_Report_Import_Error__c sRrecord1 = new Score_Report_Import_Error__c();
        sRrecord1.USMLE_ID__c = '2000';
        sRrecord1.Application_id__c = 2000;
        sRrecord1.Exam__c ='Step1';
        insert sRrecord1;
        System.assert(sRrecord1.Id!=null,'Record not inserted');
        ScoreWithheldHelper.releaseScore(sRrecord1.Id);
        sRrecord.Test_Accommodations__c = 'Y';
        sRrecord.score_report_document_id__c= null;
        sRrecord.score_status__c='N';
        update sRrecord;
        System.assert(sRrecord.score_status__c=='N','Update failed');
        ScoreWithheldHelper.exmRegRemarkCheckOnScoreRelease(updateExamRegistration, sRrecord);
        ScoreWithheldHelper.examOutcomeGenerator(sRrecord);
        ScoreWithheldHelper.updateExamOutcome(eventExamRegMap);
        ScoreWithheldHelper.exmRegRemarkCheck(testEvent, eventExamRegMap);
        ScoreWithheldHelper.withHeldCheckForNBME(eventExamRegMap);
        Test.stopTest();
    }
    public static testMethod void scoreWithheldTest1() {
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico');
        insert c1;
        System.assert(c1.Id!=null,'Contact not found');
        String accountName = lastname + ' Household';
        Account acct = [Select Id from Account where name= :accountName LIMIT 1];
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        System.assert(user1.Id!=null,'User doesnot exists');
        String examType = 'USMLE Step 1';
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Case cs = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
        insert cs;
        System.assert(cs.Id!=null,'Case cs not found');
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        System.assert(region.Id!=null,'Region not found');  
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        System.assert(regionSurcharge.Id!=null,'regionSurcharge record not found');
        date epStartDate = date.valueOf('2020-01-01');
        date epEndDate = date.valueOf('2020-04-01');
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
        updateExamRegistration.Application_Id__c = 2000;
        updateExamRegistration.USMLE_ID_CIBIS__c ='2000';
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Applicant__c = c1.Id;
        updateExamRegistration.Score_report_Document_id__c = 'abcde';
		insert updateExamRegistration;
        System.assert(updateExamRegistration.Id!=null,'Exam Reg doesnot exists');
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
		updateExamRegistration1.Exam_Types__c = examType;
        updateExamRegistration1.Application_Id__c = 2000;
        updateExamRegistration1.USMLE_ID_CIBIS__c ='2000';
		updateExamRegistration1.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration1.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration1.EP_start_Date__c = epStartDate;
		updateExamRegistration1.EP_end_Date__c = epEndDate;
        insert updateExamRegistration1;
        System.assert(updateExamRegistration1.Id!=null,'Exam Reg doesnot exists');
        List<Exam_Registration__c> examRegList = new List<Exam_Registration__c>();
        examRegList.add(updateExamRegistration);
        examRegList.add(updateExamRegistration1);
        Asset asst1 = new Asset(
            Name = Constants.ASSET_NAME_ID_FORM_NOTARIZED,
            Status = Constants.ASSET_STATUS_IN_PROGRESS,
            AccountId = acct.id,
            ContactId = c1.Id,
            InstallDate = System.Today(),
            UsageEndDate = System.Today(),
            Type__c	=	Constants.ASSET_TYPE_IDENTITY_VERIFICATION
        );
        insert asst1;
        System.assert(asst1.Id!=null,'Asset not found');
        List<String> appIdListUpdateAsset = new List<String>();
        appIdListUpdateAsset.add(c1.Id);
        List<String> appIdListUpdateCase = new List<String>();
        appIdListUpdateCase.add(c1.Id);
        Set<String> contactIdFormNotarized = new Set<String> ();
        Set<String> contactApplicantBioChange = new Set<String> ();
        Test.startTest();
        ScoreWithheldHelper.updateWithHeldScore(examRegList, appIdListUpdateAsset, appIdListUpdateCase, contactIdFormNotarized, contactApplicantBioChange);
        List<Exam_Registration__c> exmRegUnderIdVer= ScoreWithheldHelper.withHeldCheckForIdVerification(examRegList);
        System.assert(!exmRegUnderIdVer.isEmpty(),'No score withheld due to Id Verfication');
        Test.stopTest();   
    }
}