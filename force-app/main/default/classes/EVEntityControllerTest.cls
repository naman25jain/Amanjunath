//Test class for EnrollmentVerificationEntityController and its helper classes

@isTest
public class EVEntityControllerTest extends ECFMGTestFactory {
    public static final String UNITED_STATES  = 'United States';
    public static final String AMERICA_LA = 'America/Los_Angeles';
    public static testMethod void testEVActive() {
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp = new Group(Name=Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type='Queue');
            insert grp;
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp1 = new Group(Name=Constants.QUEUE_USMLE_TRANSCRIPTS, type='Queue');
            insert grp1;
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp2 = new Group(Name=Constants.QUEUE_APP_FOR_CERT, type='Queue');
            insert grp2;
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
        }     Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp3 = new Group(Name=Constants.QUEUE_EXAM_REG, type='Queue');
            insert grp3;
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
        }
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class,new Account(Name = 'Test Account'));
        run();
       
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        List<Service__c> myServiceList = new List<Service__c>();
Service__c serv = new Service__c(Name = 'Enrollment Verification', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
myServiceList.add(serv);

insert myServiceList;
List<Account2Service__c> myAccServList = new List<Account2Service__c>();
Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);

myAccServList.add(acc2Service);
insert myAccServList;
List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
myCon2AccService.add(conService);
insert myCon2AccService;

        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User user = new User(alias='flastt',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=con.Id, timezonesidkey=AMERICA_LA,username=userName);
        insert user;

        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.ContactId = con.Id;
        evcase.Verification_Status__c = Constants.CASE_VERIFICATION_STATUS_NOT_REVIEWED;
        INSERT evCase;
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
        examRegCase1.ContactId = con.Id;
        INSERT examRegCase1;
        String step1 = 'USMLE Step 1';
        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Case__c = examRegCase1.Id;
        examReg.Exam_Status__c = '';
        examReg.Exam_Types__c = step1;
        examReg.EP_end_Date__c = Date.today();
        INSERT examReg;
        Case examRegCase = new Case();
        examRegCase.RecordTypeId = examRegRTId;
        examRegCase.ContactId = con.Id;
        examRegCase.Enrollment_Verification_Parent__c = evCase.Id;
        INSERT examRegCase;
        Test.startTest();    
        Exam_Registration__c examReg1 = new Exam_Registration__c();
        examReg1.Case__c = examRegCase.Id;
        examReg1.Exam_Status__c = '';
        examReg1.Exam_Types__c = step1;
        examReg1.EP_end_Date__c = Date.today();
        INSERT examReg1;
        User testUser = [Select id,contactId from User where alias='flastt'];
        System.runAs(testUser){
        Contact currentUser = new contact();
        currentUser = [Select Id,FirstName,LastName,AccountId,USMLE_ID__c,Birthdate from Contact where Id =: testUser.contactId];
        List<EnrollmentVerificationEntityHelper.EVCaseWrapper> dt = EnrollmentVerificationEntityController.getEVActiveCase(String.Valueof(currentUser.AccountId));
        system.assertEquals(dt.size()>0,true,'Active Case');
        string dtval = EnrollmentVerificationEntityController.dateFormatting(System.today());
        system.assertEquals(dtval!=NULL,true,'Date Converted');
        }
        Test.stopTest();
       

    }
    public static testMethod void testEVCompleted() {
        Id examRegRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_EXAM_REGISTRATION).getRecordTypeId();
        Id evRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.CASE_RECORD_TYPE_ENROLLMENT_VERIFICATION).getRecordTypeId();
        Group grp = new Group();
        QueuesObject que = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp = new Group(Name=Constants.CASE_QUEUE_ENROLLMENT_VERIFICATION, type='Queue');
            insert grp;
            que = new QueueSObject(QueueID = grp.id, SobjectType = 'Case');
            insert que;
        }
        Group grp1 = new Group();
        QueuesObject que1 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp1 = new Group(Name=Constants.QUEUE_USMLE_TRANSCRIPTS, type='Queue');
            insert grp1;
            que1 = new QueueSObject(QueueID = grp1.id, SobjectType = 'Case');
            insert que1;
        }
        Group grp2 = new Group();
        QueuesObject que2 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp2 = new Group(Name=Constants.QUEUE_APP_FOR_CERT, type='Queue');
            insert grp2;
            que2 = new QueueSObject(QueueID = grp2.id, SobjectType = 'Case');
            insert que2;
        }     Group grp3 = new Group();
        QueuesObject que3 = new QueuesObject();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            grp3 = new Group(Name=Constants.QUEUE_EXAM_REG, type='Queue');
            insert grp3;
            que3 = new QueueSObject(QueueID = grp3.id, SobjectType = 'Case');
            insert que3;
        }
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class,new Account(Name = 'Test Account'));
        run();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;

        List<Service__c> myServiceList = new List<Service__c>();
        Service__c serv = new Service__c(Name = 'Enrollment Verification', Signature_Required__c = TRUE, Seal_Required__c = TRUE);
        myServiceList.add(serv);
        insert myServiceList;
        List<Account2Service__c> myAccServList = new List<Account2Service__c>();
        Account2Service__c acc2Service = new Account2Service__c(Account__c = acc.Id, Active__c = TRUE, Service__c = serv.Id);
       
        myAccServList.add(acc2Service);
        insert myAccServList;
        List<CONTACT2ACCTSERVICE__c> myCon2AccService = new List<CONTACT2ACCTSERVICE__c>();
        CONTACT2ACCTSERVICE__c conService = new CONTACT2ACCTSERVICE__c(Account_Service__c = acc2Service.Id, Role__c = 'Coordinator', Service_Contact__c=con.Id);
        myCon2AccService.add(conService);
        insert myCon2AccService;

        String step2 = 'USMLE Step 1';
        string emailtest = 'tester@unknownmail.com';
        String userName = 'tester@unknownmail.com_' + System.now();
        userName=userName.replace(' ','').replace(':','-');
        string lastname = 'Last';
        Id p=[Select id from profile where name='4-Customer Community Plus Login' LIMIT 1].id;
        User user = new User(alias='flastt',email=emailtest,emailencodingkey='UTF-8',lastname=lastname, languagelocalekey='en_US',localesidkey='en_US',profileid=p,country=UNITED_STATES,IsActive=true,ContactId=con.Id, timezonesidkey=AMERICA_LA,username=userName);
        insert user;
        Case evCase = new Case();
        evCase.RecordTypeId = evRTId;
        evCase.ContactId = con.Id;
        evCase.Verification_Status__c = constants.CASE_VERIFICATION_STATUS_ENROLLED;      
        INSERT evCase;
        Case examRegCase1 = new Case();
        examRegCase1.RecordTypeId = examRegRTId;
        examRegCase1.Enrollment_Verification_Parent__c = evCase.Id;
        examRegCase1.ContactId = con.Id;
        INSERT examRegCase1;

        Exam_Registration__c examReg = new Exam_Registration__c();
        examReg.Case__c = examRegCase1.Id;
        examReg.Exam_Status__c = '';
        examReg.Exam_Types__c = step2;
        examReg.EP_end_Date__c = Date.today();
        INSERT examReg;
        Case examRegCase = new Case();
        examRegCase.RecordTypeId = examRegRTId;
        examRegCase.ContactId = con.Id;
        examRegCase.Enrollment_Verification_Parent__c = evCase.Id;
        INSERT examRegCase;
        Test.startTest();
        Exam_Registration__c examReg1 = new Exam_Registration__c();
        examReg1.Case__c = examRegCase.Id;
        examReg1.Exam_Status__c = '';
        examReg1.Exam_Types__c = step2;
        examReg1.EP_end_Date__c = Date.today();
        INSERT examReg1;

        User testUser = [Select id,contactId from User where alias='flastt'];        
        System.runAs(testUser){
        Contact currentUser = new contact();
        currentUser = [Select Id,FirstName,LastName,AccountId,USMLE_ID__c,Birthdate from Contact where Id =: testUser.contactId];
        List<EnrollmentVerificationEntityHelper.EVCaseWrapper> dt = EnrollmentVerificationEntityController.getEVCompletedCase(String.Valueof(currentUser.AccountId));
        system.assertEquals(dt.size()>0,true,'Completed case');
    }
    Test.stopTest();
}
}