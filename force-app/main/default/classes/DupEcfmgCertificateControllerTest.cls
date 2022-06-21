@IsTest
public with sharing class DupEcfmgCertificateControllerTest extends ECFMGTestFactory{
    @TestSetup
    public static void setUp(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constants.CONTACT_RECORD_TYPE_APPLICANT);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc));
        run();
        System.assert(acc.id!=null, 'Account failed');
    }
    @IsTest
    public static void testCreateDupCert(){      
        System.runAs(new User(Id = UserInfo.getUserId())){
            Boolean retVal = DupEcfmgCertificateController.saveDupCertReason('other','None');
            System.assert(retVal, 'Return Value is set');
        }
    }
    @IsTest
    public static void testMarkForDelDupCert(){      
        System.runAs(new User(Id = UserInfo.getUserId())){
            Boolean retVal = DupEcfmgCertificateController.saveDupCertReason('other','None');
            System.assert(retVal, 'Return Value is set');
            retVal = DupEcfmgCertificateController.markforDelete();
            System.assert(retVal, 'Marked for deletion');
        }
    }
    @IsTest
    public static void testfetchDetailAndReason(){       
        System.runAs(new User(Id = UserInfo.getUserId())){
            Boolean retVal = DupEcfmgCertificateController.saveDupCertReason('other','None');
            System.assert(retVal, 'Return Value is set');
            List<String> resAndDetail = DupEcfmgCertificateController.fetchReasonAndDetails(); 
            System.assert(resAndDetail!= null, 'Reason and detail fetched');
        }
    }
    @IsTest
    public static void testEnableDuplicateRequest(){      
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Id ecfmgRecId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Constants.ASSET_RECORD_TYPE_ECFMG_CERTIFICATION).getRecordTypeId();
        Asset asst = new Asset();
        asst.Name = 'ECFMG Certificate';
        asst.ContactId = con.Id;
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        asst.RecordTypeId = ecfmgRecId;
        INSERT asst;
        System.assert(asst.Id != null, 'Asset creation failed');
        Boolean result = DupEcfmgCertificateController.enableDuplicateRequest(con.Id);
        System.assert(result == true, 'Asset check failed');
        //test for notification email for duplicate certificate 
        Id dCRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
        System.assert(dCRTId != null, 'Recordtype does not exist');
        Case dcCase = new Case();
		dcCase.RecordTypeId = dCRTId;
		dcCase.ContactId = con.Id;
        dcCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
		INSERT dcCase;
        System.assert(dcCase.Id != null, 'Case creation failed');
        dcCase.Internal_Status__c = Constants.CASE_STATUS_SENT;
        update dcCase;
        System.assert(dcCase.Internal_Status__c == Constants.CASE_STATUS_SENT, 'Case update failed');
    }
    @isTest
public static void testFetchCaseNumber(){   
    Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
    Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
    User userCon = new User(alias='userTest',email='testUser@gmail.com',emailencodingkey='UTF-8',lastname='UserTest', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=con.Id, timezonesidkey='America/Los_Angeles',username='testuser3@gmail.com');
    insert userCon;
    System.assert(con.Id != null, 'Contact creation failed');
    Id dCRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
    List<Group> queueDupCert = [select Id, Name from Group where Type = 'Queue' and Name =: Constants.CASE_QUEUE_ECFMG_CERTIFICATION WITH SECURITY_ENFORCED];
    Id queueId = queueDupCert[0].Id;
    System.assert(dCRTId != null, 'Recordtype does not exist');
    System.runAs(userCon){
        Case dcCase = new Case();
        dcCase.RecordTypeId = dCRTId;
        dcCase.ContactId = con.Id;
        dcCase.Internal_Status__c = Constants.CASE_STATUS_SUBMITTED_IN_REVIEW;
        dcCase.OwnerId = queueId;
        INSERT dcCase;
        System.assert(dcCase.Id != null, 'Case creation failed');
        String retVal = DupEcfmgCertificateController.fetchCaseNumber();   
        System.assert(retVal != null, 'Case Number is not Present');
    }
}
    @isTest
    public static void testPaymentCompletion(){     
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User userCon = new User(alias='userTest',email='testUser@gmail.com',emailencodingkey='UTF-8',lastname='UserTest', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country='United States',IsActive=true,ContactId=con.Id, timezonesidkey='America/Los_Angeles',username='testuser3@gmail.com');
        insert userCon;
        System.assert(con.Id != null, 'Contact not created');
        Id dCRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        Group queueVal = CaseTriggerUtility.groupMap.get(Constants.CASE_QUEUE_ECFMG_CERTIFICATION);
        Case dcCase = new Case();
		dcCase.RecordTypeId = dCRTId;
		dcCase.ContactId = con.Id;
        dcCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_SUBMISSION;
        dcCase.OwnerId = queueVal.Id;
        INSERT dcCase;
        System.runAs(new User(Id = UserInfo.getUserId())){
            grp = new Group(Name = 'ECFMG Certification', type = 'Queue');
            insert grp;
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
        }
        System.assert(dCRTId != null, 'Recordtype not available');
        System.runAs(userCon){
            Boolean retVal = DupEcfmgCertificateController.paymentCompletion();
            System.assert(retVal != NULL, 'Return Value is not set');
            String dupCertCaseId = DupEcfmgCertificateController.getDupCertCases();
            System.assert(dupCertCaseId != NULL, 'Duplicate Cerificate is not created');
        }
    }
    @IsTest
    public static void testCheckDupCertSubmission(){
        Contact con = [SELECT Id FROM Contact WHERE RecordType.DeveloperName =: Constants.CONTACT_RECORD_TYPE_APPLICANT ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(con.Id != null, 'Contact not created');
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User userCon = new User(alias='userTest',email='testcontact@gmail.com',emailencodingkey='UTF-8',lastname='UserTest', languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=ConstantsTest.TEST_COUNTRY,IsActive=true,ContactId=con.Id, timezonesidkey=ConstantsTest.TEST_TIMEZONE,username='testuser12@gmail.com');
        insert userCon;
        System.assert(userCon.Id != null, 'User not created');
        Asset asst = new Asset();
        asst.Name = 'ECFMG Certificate';
        asst.ContactId = con.Id;
        asst.Status = Constants.ASSET_STATUS_ACCEPTED;
        INSERT asst;
        System.assert(asst.Id != null, 'Asset not created');
        System.runAs(userCon){
            Boolean retVal = DupEcfmgCertificateController.checkDupCertSubmission();
            System.assert(retVal != null, 'Value returned is NULL');
            Id dCRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_DUPLICATE_CERTIFICATE).getRecordTypeId();
            Case dcCase = new Case();
            dcCase.RecordTypeId = dCRTId;
            dcCase.ContactId = con.Id;
            dcCase.Internal_Status__c = Constants.CASE_STATUS_PENDING_PRINT;
            INSERT dcCase;
        	System.assert(dcCase.Id != null, 'Case not created');
            retVal = DupEcfmgCertificateController.checkDupCertSubmission();
            System.assertNotEquals(retVal, NULL, 'retVal is NULL');
        }
    }
}