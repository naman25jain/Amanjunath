/**
* Factory Class for EPEx functionality
*
* @author        Femi
* @version       1.0
* @createdDate   01-APR-2020
*/
@isTest
public class EPExTestFactory{
    public static testMethod void servicePageSetup(){
        //create a new contact;
        final String usmleStep1 = 'USMLE Step 1';
        final String usmleStep2CK = 'USMLE Step 2 CK';
        String examType = usmleStep1;
        Date birthdate1 = Date.valueOf('2000-01-01');
        String emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        Contact c1 = new Contact(Firstname=firstname, Lastname=lastname, Birthdate=birthdate1, Email=emailtest, MailingCountry='Mexico', School_Enrollment_Status__c=Constants.CONASCTYPESTG_STATUS_GRADUATE);
        INSERT c1;
        System.assert(c1.Id != null, 'Contact creation failed');
        Id p=[SELECT Id FROM Profile WHERE Name = '4-Customer Community Plus Login' LIMIT 1].id;
        //create a new User row
        User user1 = new User(Alias='second', Email=emailtest, Emailencodingkey='UTF-8', Lastname=lastname, Languagelocalekey='en_US', Localesidkey='en_US', Profileid=p, Country='United States', IsActive=true, ContactId=c1.Id, Timezonesidkey='America/Los_Angeles', Username=userName);
        INSERT user1;
        System.assert(user1.Id != null, 'user creation failed');
        //get the Household Account
        String accountname = lastname + ' Household';
        Account a = [SELECT Id FROM Account WHERE Name =: accountname LIMIT 1];
        Id epRecordTypeId = Schema.SObjectType.Eligibility_Period__c.getRecordTypeInfosByDeveloperName().get(Constants.ELIGIBILITY_PERIOD_RECORD_TYPE_EXAM_REG).getRecordTypeId();        
        Eligibility_Period__c ep1 = new Eligibility_Period__c();
        ep1.Active__c = 'Y';
        ep1.Extension_Flag__c = 'N';
        ep1.Exam_Type__c = usmleStep1;
        ep1.Period_Code__c = '1';
        ep1.EP_Start_Date__c = Date.newInstance(2022, 2, 1);
        ep1.EP_End_Date__c = Date.newInstance(2022, 5, 31);
        ep1.Deadline_Date__c = Date.newInstance(2022, 5, 31);
        ep1.RecordTypeId = epRecordTypeId;
        INSERT ep1;
        System.assert(ep1.Id != null, 'ep1 creation failed');
        Eligibility_Period__c ep2 = new Eligibility_Period__c();
        ep2.Active__c = 'Y';
        ep2.Extension_Flag__c = 'N';
        ep2.Exam_Type__c = usmleStep1;
        ep2.Period_Code__c = '1X';
        ep2.EP_Start_Date__c = Date.newInstance(2022, 2, 1);
        ep2.EP_End_Date__c = Date.newInstance(2022, 5, 31);
        ep2.Deadline_Date__c = Date.newInstance(2022, 5, 31);
        ep2.RecordTypeId = epRecordTypeId;
        INSERT ep2;
        System.assert(ep2.Id != null, 'ep2 creation failed');
        Eligibility_Period__c ep3 = new Eligibility_Period__c();
        ep3.Active__c = 'Y';
        ep3.Extension_Flag__c = 'N';
        ep3.Exam_Type__c = usmleStep2CK;
        ep3.Period_Code__c = '2';
        ep3.EP_Start_Date__c = Date.newInstance(2022, 2, 1);
        ep3.EP_End_Date__c = Date.newInstance(2022, 5, 31);
        ep3.Deadline_Date__c = Date.newInstance(2022, 5, 31);
        ep3.RecordTypeId = epRecordTypeId;
        INSERT ep3;
        System.assert(ep3.Id != null, 'ep3 creation failed');
        Eligibility_Period__c ep4 = new Eligibility_Period__c();
        ep4.Active__c = 'Y';
        ep4.Extension_Flag__c = 'N';
        ep4.Exam_Type__c = usmleStep2CK;
        ep4.Period_Code__c = '2X';
        ep4.EP_Start_Date__c = Date.newInstance(2022, 2, 1);
        ep4.EP_End_Date__c = Date.newInstance(2022, 5, 31);
        ep4.Deadline_Date__c = Date.newInstance(2022, 5, 31);
        ep4.RecordTypeId = epRecordTypeId;
        INSERT ep4;
        System.assert(ep4.Id != null, 'ep4 creation failed');
        //create new case
        Date epExtEndDate = Date.valueOf('2020-07-01');
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Id idEPExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Eligibility_Period_Extension').getRecordTypeId();
        Case cs = new Case(AccountId=a.Id, ContactId=c1.Id, Service__c='EPIC', RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered', Eligibility_Period__c=ep1.Id);
        INSERT cs;
        System.assert(cs.Id != null, 'cs creation failed');
        Case csEr = new Case(AccountId=a.Id, ContactId=c1.Id, Service__c='EPIC', RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered', Extended_Eligibility_End_Date__c =epExtEndDate, Eligibility_Period__c=ep3.Id);
        INSERT csEr;
        System.assert(csEr.Id != null, 'csEr creation failed');
        Case cs1 = new Case(AccountId=a.Id, ContactId=c1.Id, Service__c='EPIC', RecordTypeId=idEPExRecordTypeId, ParentId=cs.Id);
        INSERT cs1;
        System.assert(cs1.Id != null, 'cs1 creation failed');
        Case cs2 = new Case(AccountId=a.Id, ContactId=c1.Id, Service__c='EPIC', RecordTypeId=idEPExRecordTypeId, ParentId=csEr.Id, Internal_Status__c=Constants.CASE_STATUS_PENDING_SUBMISSION);
        INSERT cs2;
        System.assert(cs2.Id != null, 'cs2 creation failed');
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        INSERT region;
        System.assert(region.Id != null, 'region creation failed');
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        INSERT regionSurcharge;
        System.assert(regionSurcharge.Id != null, 'regionSurcharge creation failed');
        Date epStartDate = System.Today() + 1;
        Date epEndDate = System.Today() - 25;
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Applicant__c = c1.Id;
		INSERT updateExamRegistration;
        System.assert(updateExamRegistration.Id != null, 'updateExamRegistration creation failed');
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
		updateExamRegistration1.Exam_Types__c = usmleStep2CK;
		updateExamRegistration1.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration1.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration1.EP_start_Date__c = epStartDate;
		updateExamRegistration1.EP_end_Date__c = epEndDate;
		updateExamRegistration1.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration1.Visa_Letter_Needed__c = false;
        updateExamRegistration1.case__c = csEr.Id;
        updateExamRegistration1.Applicant__c = c1.Id;
		INSERT updateExamRegistration1;
        System.assert(updateExamRegistration1.Id != null, 'updateExamRegistration1 creation failed');
        Product2 prod = new Product2(Name = 'End User Legal Terms - EPeX', 
                                     Family = 'Hardware');
       	INSERT prod;
        System.assert(prod.Id != null, 'prod creation failed');
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c(
        	Name = 'Test',
        	Copy__c = 'Test',
        	Short_Copy__c = 'Test',
        	Status__c = 'Active',
        	Product__c = prod.Id,
        	ExpirationDate__c = System.today()+20
        );
        INSERT tc;
        System.assert(tc.Id != null, 'tc creation failed');
    }
}