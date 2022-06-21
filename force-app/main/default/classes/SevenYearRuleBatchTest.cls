/**
* Test Class for ScoreWithheldHelper
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   13-MAY-2020
*/
@isTest
public class SevenYearRuleBatchTest {
    public static testMethod void sevenYearRuleTest() {
        date birthdate1 = date.valueOf('2000-01-01');
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        string firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico');
        insert c1;
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        
        String examType = 'USMLE Step 1';
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Case cs = new Case(ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
        insert cs;
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        
        date epStartDate = date.valueOf('2020-01-01');
        date epEndDate = date.valueOf('2020-04-01');
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration.Voided__c = false;
        date takenDate = date.valueOf('2000-04-01');
        updateExamRegistration.Exam_taken_date__c = takenDate;
		insert updateExamRegistration;
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
		updateExamRegistration1.Exam_Types__c = examType;
		updateExamRegistration1.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration1.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration1.EP_start_Date__c = epStartDate;
		updateExamRegistration1.EP_end_Date__c = epEndDate;
        updateExamRegistration1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration1.Voided__c = false;
        takenDate = date.valueOf('2001-04-01');
        updateExamRegistration1.Exam_taken_date__c = takenDate;
        insert updateExamRegistration1;
        Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
		updateExamRegistration2.Exam_Types__c = examType;
		updateExamRegistration2.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration2.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration2.EP_start_Date__c = epStartDate;
		updateExamRegistration2.EP_end_Date__c = epEndDate;
        updateExamRegistration2.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration2.Voided__c = false;
        takenDate = date.valueOf('2003-04-01');
        updateExamRegistration2.Exam_taken_date__c = takenDate;
        insert updateExamRegistration2;
        Exam_Registration__c updateExamRegistration3 = new Exam_Registration__c();
		updateExamRegistration3.Exam_Types__c = 'USMLE Step 2 CK';
		updateExamRegistration3.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration3.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration3.EP_start_Date__c = epStartDate;
		updateExamRegistration3.EP_end_Date__c = epEndDate;
        updateExamRegistration3.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration3.Voided__c = false;
        takenDate = date.valueOf('2010-03-01');
        updateExamRegistration3.Exam_taken_date__c = takenDate;
        insert updateExamRegistration3;
        Exam_Registration__c updateExamRegistration4 = new Exam_Registration__c();
		updateExamRegistration4.Exam_Types__c = 'USMLE Step 2 CK';
		updateExamRegistration4.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration4.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration4.EP_start_Date__c = epStartDate;
		updateExamRegistration4.EP_end_Date__c = epEndDate;
        updateExamRegistration4.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        updateExamRegistration4.Voided__c = false;
        takenDate = date.valueOf('2008-03-01');
        updateExamRegistration4.Exam_taken_date__c = takenDate;
        insert updateExamRegistration4;
        Database.executeBatch(new SevenYearRuleBatch());
        Test.StartTest();
		SevenYearRuleScheduler testsche = new SevenYearRuleScheduler();
		String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
        SevenYearRuleBatch obj = new SevenYearRuleBatch();
            DataBase.executeBatch(obj); 
        Exam_Registration__c updateExamRegistration5 = [select Voided__c from Exam_Registration__c where id=:updateExamRegistration.Id][0];
        System.assertEquals(true, updateExamRegistration5.Voided__c);
    }
}