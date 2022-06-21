/**
* Factory Class for Score Report functionality
*
* @author        Nayana
* @version       1.0
* @createdDate   13-MAY-2020
*/
@isTest
public class ScoreReportTestFactory {
    public static testMethod void servicePageSetup() {
        
        //create a new contact;
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailTest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',School_Enrollment_Status__c =Constants.CONASCTYPESTG_STATUS_GRADUATE);
        insert c1;

        Id p = [Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(alias='second',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        insert user1;
        
        //get the Household Account
        String accountname = lastname + ' Household';
        Account a = [Select Id from Account where name= :accountname LIMIT 1];
        
        
        Exam_Region__c examReg1 = new Exam_Region__c();
        examReg1.Name = 'RegionA';
        examReg1.Region_Name__c = 'RegionA';
        insert examReg1;

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

        //create new case

        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();

        Case csEr = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId = idExamRegTypeId,Is_Requested_Region_Change__c=true, Internal_Status__c='Registered', Exam_Region_Surcharge__c =examRegSurList[0].Id);
        insert csEr;

        
        date epStartDate = date.valueOf('2020-01-01');
        date epEndDate = date.valueOf('2020-04-01');
        
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
		insert updateExamRegistration2;
        
        Product2 prod = new Product2(Name = Constants.PRODUCT_NAME_SCORE_RECHECK_LEGAL_TERMS, 
                                     Family = 'ECFMG_Certification');
       	insert prod;
            
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c(
        	Name = 'Test',
        	Copy__c = 'Test',
        	Short_Copy__c = 'Test',
        	Status__c = 'Active',
        	Product__c = prod.Id,
        	ExpirationDate__c = System.today() + 20
        );
        insert tc;
        
        date scheduledTestDate = system.Today() + 20;
        
        Exam_Registration__c updateExamRegistration3 = new Exam_Registration__c();
		updateExamRegistration3.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
		updateExamRegistration3.Exam_Region_Surcharge__c = examRegSurList[0].Id;
		updateExamRegistration3.Surcharge__c = examRegSurList[0].Surcharge__c;
		updateExamRegistration3.EP_start_Date__c = epStartDate;
		updateExamRegistration3.EP_end_Date__c = epEndDate;
		updateExamRegistration3.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration3.Visa_Letter_Needed__c = false;
        updateExamRegistration3.case__c = csEr.Id;
        updateExamRegistration3.Applicant__c = c1.Id;
        updateExamRegistration3.Posted_Date__c = System.today() - 1;
        updateExamRegistration3.Exam_taken_date__c = System.today() - 10;
        updateExamRegistration3.Scheduled_Test_Date__c = scheduledTestDate;
        updateExamRegistration3.Test_Accommodations__c = 'Y';
        updateExamRegistration3.Pd_Optout_flag__c = false;
        
        insert updateExamRegistration3;
        
    }    

}