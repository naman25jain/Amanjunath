/**
* @description Factory Class for Region Change functionality
*
* @author        Nayana
* @version       1.0
* @createdDate   02-APR-2020
*/
@isTest
public class RegionChangeTestFactory {
    /**
     * Created by Nayana
     * Method Name: servicePageSetup
     * @description : test setup
     * @return: void
     */
    @testSetup public static void servicePageSetup(){
        
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

        Exam_Region__c examReg2 = new Exam_Region__c();
        examReg2.Name = 'RegionB';
        examReg2.Region_Name__c = 'RegionB';
        insert examReg2;
		
        List<Product_Detail__c> examRegSurList = new List<Product_Detail__c>();
        Product_Detail__c examRegSur1 = new Product_Detail__c();
        examRegSur1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examRegSur1.Exam_Region__c = examReg1.Id;
        examRegSur1.Processing_Fee__c = 50;
        examRegSur1.Service_Fee__c = 50;
        examRegSur1.Start_Date__c = System.today();
        examRegSur1.End_Date__c = System.today() + 5;
        examRegSurList.add(examRegSur1);

        Product_Detail__c examRegSur2 = new Product_Detail__c();
        examRegSur2.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examRegSur2.Exam_Region__c = examReg2.Id;
        examRegSur2.Processing_Fee__c = 50;
        examRegSur2.Service_Fee__c = 25;
        examRegSur2.Start_Date__c = System.today();
        examRegSur2.End_Date__c = System.today() + 5;
        examRegSurList.add(examRegSur2);

        Product_Detail__c examRegSur3 = new Product_Detail__c();
        examRegSur3.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
        examRegSur3.Exam_Region__c = examReg1.Id;
        examRegSur3.Processing_Fee__c = 150;
        examRegSur3.Service_Fee__c = 75;
        examRegSur3.Start_Date__c = System.today();
        examRegSur3.End_Date__c = System.today() + 5;
        examRegSurList.add(examRegSur3);

        insert examRegSurList;

        //create new case

        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Id idEPExRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Eligibility_Period_Extension').getRecordTypeId();
        Id idRegionChangeTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Region_Change').getRecordTypeId();

        Case cs = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
        insert cs;
        Case csEr = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId = idExamRegTypeId,Is_Requested_Region_Change__c=true, Internal_Status__c='Registered', Product_Detail__c =examRegSurList[0].Id);
        insert csEr;

        Case csRegionChange = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId = idRegionChangeTypeId,Is_Requested_Region_Change__c=true, Internal_Status__c='Pending CIBIS', Product_Detail__c =examRegSurList[0].Id);
        insert csRegionChange;

        Case csRegionChange2 = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',RecordTypeId = idRegionChangeTypeId,Is_Requested_Region_Change__c=true, Internal_Status__c='Pending Submission', ParentId=csEr.Id,Product_Detail__c =examRegSurList[0].Id);
        insert csRegionChange2;

        
        Case cs1 = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',Internal_Status__c='Pending Enrollment Verification',RecordTypeId=idEPExRecordTypeId,ParentId=cs.Id);
        insert cs1;
        Case cs2 = new Case(AccountId=a.Id,ContactId=c1.Id,Service__c='EPIC',Internal_Status__c='Pending Enrollment Verification',RecordTypeId=idEPExRecordTypeId,ParentId=csEr.Id);
        insert cs2;
        
        date epStartDate = date.valueOf('2020-01-01');
        
        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
		updateExamRegistration.Product_Detail__c = examRegSurList[0].Id;
        updateExamRegistration.Surcharge__c = examRegSurList[0].Surcharge__c;
        updateExamRegistration.EP_start_Date__c = epStartDate;
        updateExamRegistration.EP_end_Date__c = System.today() +20;
        updateExamRegistration.Exam_taken_date__c = NULL;
        updateExamRegistration.Test_Accommodations_needed__c = 'Yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Applicant__c = c1.Id;
		insert updateExamRegistration;
        
        Exam_Registration__c updateExamRegistration1 = new Exam_Registration__c();
		updateExamRegistration1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
		updateExamRegistration1.Product_Detail__c = examRegSurList[2].Id;
		updateExamRegistration1.Surcharge__c = examRegSurList[2].Surcharge__c;
		updateExamRegistration1.EP_start_Date__c = epStartDate;
		updateExamRegistration1.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration1.Visa_Letter_Needed__c = false;
        updateExamRegistration1.case__c = csEr.Id;
        updateExamRegistration1.Applicant__c = c1.Id;
		insert updateExamRegistration1;
        
        Product2 prod = new Product2(Name = Constants.PRODUCT_NAME_REGION_CHANGE_LEGAL_TERMS, 
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
        
    }    

}