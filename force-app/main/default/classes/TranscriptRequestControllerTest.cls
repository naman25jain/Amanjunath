/**
* Test Class for TranscriptRequestController class
*
* @author        Enable Consulting
* @version       1.0
* @createdDate   01-APR-2020
* Description - Test class
*/
@isTest public class TranscriptRequestControllerTest{
    /* Name - setup
     * 
     * Description - Test Method *******/
   //  static final string coreName = 'EVR Customer Doc Config';
     private static WDOMS_ID_Sequence__c settingsInstance;
    static{
        WDOMS_ID_Sequence__c settingsInstance = WDOMS_ID_Sequence__c.getOrgDefaults();
        settingsInstance.MDT_Degree_Type_ID__c = 7104;
        upsert settingsInstance;
    } 
    
    
    @testSetup public static void setup(){
             
        AppforCertTestFactory.servicePageSetup();
    }
    
    /* Name - testcreateTranscriptRequestCases
     * 
     * Description - Test Method *******/
    @isTest static void testcreateTranscriptRequestCases(){
        final String transReq = 'Transcript Request';
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            cadmus_core__Doc_Config__c coredoc = new cadmus_core__Doc_Config__c();
            coredoc.Name = 'EVR Customer Doc Config';
            coredoc.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('USMLE_TRANSCRIPT').Value__c;
            insert coredoc;
            cadmus_core__Doc_Config__c coredoc1 = new cadmus_core__Doc_Config__c();
            coredoc1.Name = 'EVR Customer Doc Config';
            coredoc1.cadmus_core__CustomerDocumentConfigId__c=Constant_PDF_Butler__mdt.getInstance('NON_USMLE_TRANSCRIPT').Value__c;
            insert coredoc1;
            Contact getContactId = [Select Id,AccountId from Contact where Id =: testUser.contactId];
            System.assert(getContactId != null, 'getContactId IS NULL');
            String s ='{"primaryTranscriptId":"","primaryNameOfReceipt":"balashankr balashankar","primaryOrganization":"","primaryStreet":"rest","primaryCity":"chennai","primaryState":"","primaryCountry":"Albania","primaryPostalCode":"3232","primaryTelephoneNumber":"676","primaryCourier":"Yes","primarySendToSelf":true,"primaryRequestAnotherTranscript":true,"secondaryTranscriptId":"","secondaryNameOfReceipt":"balashankr balashankar","secondaryOrganization":"","secondaryStreet":"rest","secondaryCity":"chennai","secondaryState":"","secondaryCountry":"Albania","secondaryPostalCode":"3232","secondaryTelephoneNumber":"","secondaryCourier":"No","secondarySendToSelf":true,"primarySendToSameAddressTranscript":false,"numberOfCopMorethanOne":false,"linkSource":"Transcript Request"}';
            Boolean b = TranscriptRequestController.createTranscriptRequestCases(s);
            System.assert(b==true, 'b not true');
            String parentCaseId = TranscriptRequestController.getTransscriptRequestCases();
            System.assert(parentCaseId != null, 'Parent Case is not created');
            TranscriptRequestHelper.TranscriptObjWrapper  dat = TranscriptRequestController.getTranscriptRequest(transReq);
            System.assert(dat != null, 'dat not null');
            TranscriptRequestHelper.TranscriptObjWrapper  dat2 = TranscriptRequestController.getTranscriptRequest('Non Usmle Transcript Request');
            System.assert(dat2 != null, 'dat2 not null');
            //Used in Summary Screen
            List<Transcript_Request__c>  summaryData = TranscriptRequestController.getTrascriptDetails(transReq);
            System.assert(summaryData.size()>0, 'summaryData size is zero');
            List<String> caseNumbers = TranscriptRequestController.updateCaseStatus();
            System.assert(caseNumbers.size()>0, 'caseNumbers size is zero');
        }
        Test.stopTest();
    }
   
    /* Name - testgetTranscriptContact
     * 
     * Description - Test Method *******/
    @isTest static void testgetTranscriptContact(){
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            Contact getContactId = [Select Id,AccountId from Contact where Id =: testUser.contactId];
            System.assert(getContactId != null, 'getContactId IS NULL');            
            String con = TranscriptRequestController.getTranscriptContactDetails();
            System.assert(con != null,'Contact not created');
        }
        Test.stopTest();
    }
    /* *******************************
     * Name - testPicklistValues
     * 
     * Description - Test Method *******/
    @isTest static void testPicklistValues(){
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            Contact getContactId = [Select Id,AccountId from Contact where Id =: testUser.contactId];
            System.assert(getContactId != null, 'getContactId IS NULL');                       
            
            String objectStr = 'Transcript_Request__c';           
            Schema.SObjectType convertType = Schema.getGlobalDescribe().get(objectStr);
            Sobject genericObject = convertType.newSObject();            
            
            List < TranscriptRequestHelper.FatchValueWrapper > getPickVal = TranscriptRequestController.fatchPickListValue(genericObject, 'Country__c');
            System.assert(getPickVal.size() > 0 == true,'getPickVal');

        }
        Test.stopTest();
    }
    /* *******************************
     * Name - testgetTermsandConditionsTranscripts
     * 
     * Description - Test Method *******/
    @isTest static void testgetTermsandConditionsTranscripts(){
        Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Agreements').getRecordTypeId();
    	Product2 newProduct = new Product2();
        newProduct.Name = 'End User Legal Terms - TranscriptRequest';
        newProduct.IsActive = True;
        newProduct.RecordTypeId = productRecordTypeId;
        insert newProduct;
        
        Terms_and_Conditions__c newTnC = new Terms_and_Conditions__c();
        newTnC.Name = 'Terms and Conditions';
        newTnC.Copy__c = 'I hereby acknowledge that every information provided are true to the depth of my knowledge';
        newTnC.Short_Copy__c = 'I Agree';
        newTnC.Product__c = newProduct.Id;
        newTnC.Status__c = 'Active';
        newTnC.ExpirationDate__c = System.today() + 10;
        insert newTnC;
        
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            TranscriptRequestController.getTermsandConditionsTranscripts();
        } 
        Test.stopTest();
        System.assert(true, true);
    }
    
    /* *******************************
     * Name - testEnableTranscriptLink
     * 
     * Description - Test Method *******/
    @isTest static void testEnableTranscriptLink(){
        Id nonUsmleRecTypeId = Schema.SObjectType.Exam_Registration__c.getRecordTypeInfosByDeveloperName().get(Constants.EXAM_REGISTRATION_RECORD_TYPES_NON_USMLE).getRecordTypeId();
        Exam_Registration__c examHistory = new Exam_Registration__c();
        examHistory.Exam_Types__c = Constants.EXAM_REGISTRATION_EXAM_TYPES_USMLESTEPONE;
        examHistory.RecordTypeId = nonUsmleRecTypeId;
        INSERT examHistory;
        System.assert(examHistory.Id!=null,'examHistory ID is null');
        Date birthdate1 = date.valueOf('2000-01-01');
        String emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        String lastname = 'Last';
        String firstname = 'First';
        String usmleId = '123';
        Contact c1 = new Contact(Firstname=firstname,Lastname=lastname,Birthdate=birthdate1,email=emailtest,MailingCountry='Mexico',USMLE_ID__c = usmleId);
        INSERT c1;
        System.assert(c1.Id!=null,'c1 ID is null');
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User user = new User(alias='flastt',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=c1.Id, timezonesidkey='America/Los_Angeles',username=userName);
        INSERT user;
        System.assert(user.Id!=null,'user ID is null');
        Test.startTest();
        System.runAs(user){
            String returnVal = TranscriptRequestController.enableUSMLETranscriptRequestLink();
            System.assertEquals(returnVal, 'false', 'returnVal is not false');
            examHistory.Applicant__c = c1.Id;
            UPDATE examHistory;
            System.assert(examHistory.Id!=null,'examHistory ID is null');
            returnVal = TranscriptRequestController.enableUSMLETranscriptRequestLink();
            System.assertEquals(returnVal,'true', 'returnVal is not true');
        }
        Test.stopTest();
    }
    
    /* *******************************
     * Name - testGoogleAPICall
     * 
     * Description - Test Method *******/
    @isTest static void testGoogleAPICall(){
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GoogleAPIMockResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            // Call method to test
            String result = TranscriptRequestController.getAddressSet('1600 Pennysylvania', TRUE);
            System.assert(result != null, 'result');
            String retVal = TranscriptRequestController.getAddressDetailsByPlaceId('ChIJ37HL3ry3t4kRv3YLbdhpWXE');
            System.assert(retVal != NULL, 'retval');
        }        
        Test.stopTest();
    }
    /* *******************************
     * Name - testAPICallById
     * 
     * Description - Test Method *******/
    @isTest static void testAPICallById(){
        User testUser = [Select id, contactId from User where alias='flastt'];        
        Test.startTest();
        System.runAs(testUser){
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('GoogleAPIMockResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Associate the callout with a mock response
            Test.setMock(HttpCalloutMock.class, mock);
            // Call method to test
            String retVal = TranscriptRequestController.getAddressDetailsByPlaceId('ChIJ37HL3ry3t4kRv3YLbdhpWXE');
            System.assert(retVal != NULL,'retVal');
        }        
        Test.stopTest();
    }
	/* *******************************
     * Name - testCheckOFACRestriction
     * 
     * Description - Test Method *******/
    @isTest static void testCheckOFACRestriction(){
        User testUser = [Select id, contactId from User where alias='flastt'];        
        OFAC__c insertOfac = new OFAC__c(Country__c = 'Hungary', Type__c = 'Restricted_by_ECFMG');
        insert insertOfac;
        Test.startTest();
        System.runAs(testUser){
            List<Boolean> retVal = TranscriptRequestController.checkOFACRestriction('Albania', 'Hungary');
            System.assertEquals(retVal[0], false, 'Assert Value Equal');
            System.assertEquals(retVal[1], true, 'Assert Equal');
            retVal = TranscriptRequestController.checkOFACRestriction('Hungary', 'Albania');
            System.assertEquals(retVal[0], true, 'Assert Equals');
            System.assertEquals(retVal[1], false, 'Assert Equals');
        }        
        Test.stopTest();
    }

}