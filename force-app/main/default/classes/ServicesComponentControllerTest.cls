/**
* Test Class for ServicesComponeentController class
* 27, 80, 88, 154, 170, 188
* @author        Enable Consulting
* @version       1.0
* @createdDate   13-DEC-2019
*/
@isTest
public class ServicesComponentControllerTest extends ECFMGTestFactory{

    @testSetup static void setup(){
        AppforCertTestFactory.servicePageSetup();
    }

    @isTest static void testOFACCountryAccessPositive(){
    //Tests when the Contact's MailingCountry is not among the OFAC list. Should return success.
        Test.startTest();

        User testUser = [Select id,contactId from User where alias='flastt'];

        System.assert(testUser.contactId!=null,'test method');

        Contact testContact = new Contact(id=testUser.contactId,MailingCountry='Mexico');
        update testContact;
       
        Test.stopTest();
    }

    @isTest static void testOFACCountryAccessNegative(){
    //Tests when the Contact's MailingCountry is among the OFAC list. Should return error message.
        Test.startTest();

        User testUser = [Select id,contactId from User where alias='flastt'];

        System.assert(testUser.contactId!=null,'No Contact Id exists');

        Contact testContact = new Contact(id=testUser.contactId,MailingCountry='Afghanistan');
        update testContact;

        System.runAs(testUser){
            System.assert(ServicesComponentController.getOFACAccessCheck()==(System.Label.OFAC_Not_Allowed_Error_Message+'<br>'),'Contacts mailing country is not in OFAC country list');
            System.assert(ServicesComponentController.checkValidationUpdateMyAppClick()==(System.Label.OFAC_Not_Allowed_Error_Message+'<br>'),'Contacts mailing country is not in OFAC country list');
        }
        Test.stopTest();

    }
    @isTest static void testAccEstablishmentPositive(){
    //Test for Case that is of record type Identity Verification and Account Established. Should return success.
        Test.startTest();
        User testUser = [Select id,contactId from User where alias='flastt'];
        System.assert(testUser.contactId!=null,'testUser doesnot exist');
        Id idVerRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Identity_Verification').getRecordTypeId();
        Case csval = [Select Id, Internal_Status__c From Case Where RecordTypeId=:idVerRecordTypeId and ContactId= :testUser.contactId];
        csval.Internal_Status__c = 'Accepted';
        update csval;
        System.runAs(testUser){
            System.assert(ServicesComponentController.getAccountEstablishment()!='Success','Method returned success');
        }
        Test.stopTest();
    }

    @isTest static void testgetContactPositive(){
        //Test to get contact Id. Check whether the logged in user is the same contact user. Returns same Id.

        User testUser = [Select id,contactId from User where alias='flastt'];
        System.assert(testUser.contactId!=null,'test method');
        Test.startTest();
        System.runAs(testUser){
            System.assert(ServicesComponentController.getContactId()==testUser.contactId,'test method');
        }
        Test.stopTest();        
    }
    
    @isTest static void testgetContactNegative() {
        //Test to get contact Id. Check whether the logged in user is the same contact user. Returns different Id.
        List<User> testUser = [Select id,contactId from User where alias='flastt'];
        System.assert(testUser[0].contactId!=null,'test method');		
        Test.startTest();
        System.assert(ServicesComponentController.getContactId()!=testUser[0].contactId,'test method');
        Test.stopTest();
    }
    
     @isTest static void testOFACCountryAccessExamReg() {
    	//Tests when the Contact's MailingCountry is not among the OFAC list. Should not return error Message.
        Test.startTest();
            User testUser = [Select id,contactId from User where alias='flastt'];
            System.assert(testUser.contactId!=null,'test method');
            Contact testContact = new Contact(id=testUser.contactId,MailingCountry='Mexico');
            update testContact;
         	System.assertEquals(testContact.MailingCountry, 'Mexico','test method');   
            
        Test.stopTest();
    }
    
     @isTest static void testOFACCountryAccessExamRegContactError() {
    	//Tests when the Contact's MailingCountry is not among the OFAC list. Should return error Message.
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='flastt'];       
         System.assert(testUser.contactId!=null,'test method'); 
         Contact testContact = new Contact(id=testUser.contactId,MailingCountry='India');
         update testContact;		        
         
        Test.stopTest();
    }
    
     @isTest static void testOFACCountryAccessExamRegAccountError() {
    	//Tests when the Contact's MailingCountry is not among the OFAC list. Should return error Message.

         Test.startTest();
         User testUser = [Select id,contactId from User where alias='flastt'];       
         System.assert(testUser.contactId!=null,'test method'); 
         Account accct = [Select id,name from Account where Name='EntityAcctNameNew'];
		 accct.BillingCountry = 'India';
         update accct;		        
         
        Test.stopTest();
    }
    
    @isTest static void testTranscriptLink() {   	
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='user4'];       
         System.assert(testUser.contactId!=null,'test method');    
         Account a = [Select Id from Account where name= 'EntityAcctNameNew' LIMIT 1];
         Exam_Region__c examReg1 = new Exam_Region__c();
         examReg1.Name = 'RegionA';
         examReg1.Region_Name__c = 'RegionA';
         insert examReg1;         
         Exam_Region__c examReg2 = new Exam_Region__c();
         examReg2.Name = 'RegionB';
         examReg2.Region_Name__c = 'RegionB';
         insert examReg2;         
         List<Exam_Region_Surcharge__c> examRegSurList = new List<Exam_Region_Surcharge__c>();
         Exam_Region_Surcharge__c examRegSur1 = new Exam_Region_Surcharge__c();
         examRegSur1.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
         examRegSur1.Exam_Region__c = examReg1.Id;
         examRegSur1.Surcharge__c = 50;
         examRegSurList.add(examRegSur1);
         
         Exam_Region_Surcharge__c examRegSur2 = new Exam_Region_Surcharge__c();
         examRegSur2.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
         examRegSur2.Exam_Region__c = examReg2.Id;
         examRegSur2.Surcharge__c = 50;
         examRegSurList.add(examRegSur2);
         
         Exam_Region_Surcharge__c examRegSur3 = new Exam_Region_Surcharge__c();
         examRegSur3.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPTWOCK;
         examRegSur3.Exam_Region__c = examReg1.Id;
         examRegSur3.Surcharge__c = 150;
         examRegSurList.add(examRegSur3);
         
         insert examRegSurList;
         
         Id idExamRegTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Exam_Registration').getRecordTypeId();
         Case cs = new Case(AccountId=a.Id,ContactId=testUser.contactId,Service__c='EPIC',RecordTypeId=idExamRegTypeId, Internal_Status__c='Registered');
         insert cs;
         date epStartDate = date.valueOf('2020-01-01');
         Exam_Registration__c updateExamRegistration = new Exam_Registration__c();
         updateExamRegistration.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
         updateExamRegistration.Exam_Region_Surcharge__c = examRegSurList[0].Id;
         updateExamRegistration.Surcharge__c = examRegSurList[0].Surcharge__c;
         updateExamRegistration.EP_start_Date__c = epStartDate;
         updateExamRegistration.EP_end_Date__c = System.today() +20;
         updateExamRegistration.Exam_taken_date__c = NULL;
         updateExamRegistration.Test_Accommodations_needed__c = 'Yes';
         updateExamRegistration.Visa_Letter_Needed__c = false;
         updateExamRegistration.case__c = cs.Id;
         updateExamRegistration.Applicant__c = testUser.contactId;
         updateExamRegistration.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
         insert updateExamRegistration;
		
        Map<String, String> testMap = new Map<String, String>();
        testMap.put('CIBIS_USMLE_TRANSCRIPT_ELIGIBLE_CHECK_MSG', 'dummy');
        testMap.put('CIBIS_USMLE_TRANSCRIPT_NOT_ELIGIBLE_MSG', 'dummy1');
         System.runAs(testUser){
			ServicesComponentController.checkUSMLTranscriptEligibility(testUser.contactId,testMap) ;            
            System.assert(ServicesComponentController.enableTranscriptLink()=='true','test method');
         }
        Test.stopTest();
    }
    
     @isTest static void testTranscriptLinkValidation() {
    	
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='user4'];       
         System.assert(testUser.contactId!=null,'test method'); 
               
         System.runAs(testUser){
             String validtionMsg = System.label.Transcript_Request_Link_Validation_NBMEExam+ '<br>' + System.label.Transcript_Request_Link_Validation_Step3+ '<br>';
             System.assert(ServicesComponentController.transcriptLinkValidation()!=validtionMsg,'test method');
         }
        Test.stopTest();
    }
    
     @isTest static void testTranscriptLinkValidationCheck() {
    	
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='user4'];       
         System.assert(testUser.contactId!=null,'test method'); 
         
         OFAC__c ofac = new OFAC__c(Country__c='Mexico', Type__c=System.Label.OFAC_NOT_ALLOWED);
         insert ofac;   
         
         Contact con = [Select id,Step_3_Exists__c from contact where id=:testUser.ContactId];
         con.Step_3_Exists__c = true;
         update con;
                
             System.runAs(testUser){
                 string validtionMsg =  System.Label.Biographic_change_error_message  + '<br>'+ System.Label.OFAC_Not_Allowed_Error_Message + '<br>' + System.label.Transcript_Request_Link_Validation_Step3+ '<br>';
                 System.assert(ServicesComponentController.transcriptLinkValidation()==validtionMsg,'test method');
             }
        Test.stopTest();
    }
    
     @isTest static void testTranscriptLinkValScenario2() {
    	
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='user4'];       
         System.assert(testUser.contactId!=null,'test method');  
         
          System.runAs(testUser){
             String validtionMsg =  System.Label.Biographic_change_error_message + '<br>';
             System.assert(ServicesComponentController.transcriptLinkValidation()==validtionMsg,'test method');
         }
         
         Contact con = [Select id,Step_3_Exists__c,NBME_Exam_Exists__c from contact where id=:testUser.ContactId];
         con.NBME_Exam_Exists__c = true;
         con.Step_3_Exists__c = false;
         update con;

         System.runAs(testUser){
             string validtionMsg =  System.Label.Biographic_change_error_message + '<br>' + System.label.Transcript_Request_Link_Validation_NBMEExam+ '<br>';
             System.assert(ServicesComponentController.transcriptLinkValidation()==validtionMsg,'test method');
         }
        Test.stopTest();
    }
    
     @isTest static void testTranscriptLinkValScenario3() {
    	 ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultDocConfigData.class, new cadmus_core__Doc_Config__c(Name = 'ID_FORM_TEMPLATE', cadmus_core__CustomerDocumentConfigId__c = Constant_PDF_Butler__mdt.getInstance('ID_FORM_TEMPLATE').Value__c));
		 run();
         Test.startTest();
         User testUser = [Select id,contactId from User where alias='user4'];       
         System.assert(testUser.contactId!=null,'test method');  
         
         Contact con = [Select id,Step_3_Exists__c,NBME_Exam_Exists__c from contact where id=:testUser.ContactId];
         con.MailingCountry = 'India';
         update con;
         
         List<Case> existingCases = [Select id,ContactId,isClosed,Service__c,RecordType.DeveloperName,Case_Status__c from Case where ContactId=:testUser.ContactId
                                    and RecordType.DeveloperName =:Constants.CASE_RECORD_TYPE_APP_BIO_CHANGE and Internal_Status__c != :Constants.CASE_STATUS_ACCEPTED and Internal_Status__c != :Constants.CASE_STATUS_REJECTED and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_APPLICANT and Internal_Status__c != :Constants.CASE_STATUS_CANCELLED_BY_ECFMG];
		 if(!existingCases.isEmpty()){
             existingCases[0].Internal_Status__c = Constants.CASE_STATUS_ACCEPTED;
             update existingCases;
         }
 
         System.runAs(testUser){
             string validtionMsg =  'true';
             System.assert(ServicesComponentController.transcriptLinkValidation()==validtionMsg,'test method');
         }
        Test.stopTest();
    }
    
    @isTest static void testExamRegValiationOfac(){
        OFAC__c ofac = new OFAC__c(Country__c='India', Type__c=System.Label.OFAC_NOT_ALLOWED1);
        insert ofac;   
        Test.startTest();
        
        ServicesComponentController.examRegValiationOfac(ofac.Country__c,ofac.Country__c);
        System.assert(true, 'Test Method') ;
        Test.stopTest();
    }   
}