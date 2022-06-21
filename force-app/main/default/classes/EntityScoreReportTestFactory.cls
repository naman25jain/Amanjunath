/**
* Factory Class for Entity Service Request functionality
*
* @author       Enable Consulting 
* @version       1.0
* @createdDate   17-JUN-2020
*/
@isTest
public class EntityScoreReportTestFactory {
    public static testMethod void servicePageSetup() {
         //create a new contact;
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailTest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName = userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
    
    	Id entityAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Entity').getRecordTypeId(); 

        Account acc1 = new Account(Name = 'Sample Entity',
                                   RecordTypeId = entityAccId,
                                   School__c = true,
                                   Sponsoring_Institution__c = true,Enrolled_for_Performance_Data__c = true,
                                   BillingCountry='United States',
                                   BillingStreet='1234 ECFMG Drive',
                                   BillingCity='Philadelphia',
                                   BillingPostalCode='19110',
                                   BillingState='Alaska');
        insert acc1;
        
        Id entityConId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();
        
        Contact con1 = new Contact(Firstname = firstname,
                                   Lastname = lastname,
                                   Birthdate = birthdate1,
                                   email = emailtest,
                                   MailingCountry = 'Mexico',
                                   RecordTypeId = entityConId,
                                   AccountId = acc1.Id);
        insert con1;
        
         Id p = [Select id from profile where name='4-Customer Community Entity 360' LIMIT 1].id;
        
        //create a new User row
        User user1 = new User(alias = 'second',
                              email = emailtest,
                              emailencodingkey = 'UTF-8',
                              lastname = lastname,
                              languagelocalekey = 'en_US',
                              localesidkey = 'en_US',
                              profileid = p,
                              country = 'United States',
                              IsActive = true,
                              ContactId = con1.Id,
                              timezonesidkey = 'America/Los_Angeles',
                              username = userName);
        insert user1;
        
        //create Contact Association type object        
		Id conAssocRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get('Degree_Medical_School').getRecordTypeId();
        Contact_Association_Type__c conAssocType = new Contact_Association_Type__c(RecordTypeId=conAssocRecordTypeId,Student_ID__c='123',contact__c = con1.Id,Account__c=acc1.id);
        insert conAssocType;
        
        Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
        Case cs = new Case(AccountId=acc1.Id,ContactId=con1.Id,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
        insert cs;
        
        //insert exam registration
        String examType = 'USMLE Step 1';
        
        Exam_Region__c region = new Exam_Region__c();
        region.name = 'test_Region';
        region.Region_Name__c = 'test_Region';
        insert region;
        
        Exam_Region_Surcharge__c regionSurcharge =new Exam_Region_Surcharge__c();
        regionSurcharge.Exam_Region__c = region.Id;
     	regionSurcharge.Exam_Types__c = examType;
        regionSurcharge.Surcharge__c = 100;
        insert regionSurcharge;
        
        Service__c newService = new Service__c();
        newService.Name = 'Performance Data';
        insert newService;
        
        Account2Service__c ac2ServiceRec = new Account2Service__c();
        ac2ServiceRec.Account__c = acc1.Id;
        ac2ServiceRec.Active__c = true;
        ac2ServiceRec.Start_Date__c = System.Today() - 4;
        ac2ServiceRec.Service__c = newService.Id;
        insert ac2ServiceRec;
        
        date epStartDate = System.Today() + 1;
        date epEndDate = System.Today() - 25;

        Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
		updateExamRegistration.Exam_Types__c = examType;
		updateExamRegistration.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration.EP_start_Date__c = epStartDate;
		updateExamRegistration.EP_end_Date__c = epEndDate;
		updateExamRegistration.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration.Visa_Letter_Needed__c = false;
        updateExamRegistration.case__c = cs.Id;
        updateExamRegistration.Posted_Date__c = System.Today() - 4;
        updateExamRegistration.Applicant__c = con1.Id;
        updateExamRegistration.Degree_Medical_School__c = acc1.Id;
        updateExamRegistration.Exam_status__c = 'Pass';
        insert updateExamRegistration;
        
        Exam_Registration__c updateExamRegistration2 = new Exam_Registration__c();
		updateExamRegistration2.Exam_Types__c = examType;
		updateExamRegistration2.Exam_Region_Surcharge__c = regionSurcharge.Id;
		updateExamRegistration2.Surcharge__c = regionSurcharge.Surcharge__c;
		updateExamRegistration2.EP_start_Date__c = epStartDate;
		updateExamRegistration2.EP_end_Date__c = epEndDate;
		updateExamRegistration2.Test_Accommodations_needed__c = 'yes';
		updateExamRegistration2.Visa_Letter_Needed__c = false;
        updateExamRegistration2.case__c = cs.Id;
        updateExamRegistration2.Posted_Date__c = System.Today() - 4;
        updateExamRegistration2.Applicant__c = con1.Id;
        updateExamRegistration2.Degree_Medical_School__c = acc1.Id;
        updateExamRegistration2.Exam_status__c = 'Pass';
        updateExamRegistration2.Pd_Optout_flag__c = true;
		insert updateExamRegistration2;
    }
}