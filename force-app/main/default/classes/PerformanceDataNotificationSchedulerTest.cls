/**
* @name         : PerformanceDataNotificationSchedulerTest
* @description  : Test class for PerformanceDataNotificationScheduler and EntityPerformanceDataNotificationBatch
* @author       : Reshma Ravi
* @createdDate  : 15-May-2020
*/
@isTest
public class PerformanceDataNotificationSchedulerTest extends ECFMGTestFactory{
    @isTest public static void testExecute() {
        Id degMedSchRecordTypeId = Schema.SObjectType.Contact_Association_Type__c.getRecordTypeInfosByDeveloperName().get(Constants.CONASCTYPE_RECORD_TYPE_DEGREE_MEDICAL_SCHOOL).getRecordTypeId();
        Id entityRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Entity_Contact').getRecordTypeId();        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Enrolled_for_Performance_Data__c = true;
        acc.BillingCountry = 'India';
        acc.BillingCity = 'test';
        acc.BillingStreet = 'test';
        INSERT acc;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        INSERT con;
        
        Contact_Association_Type__c cat = new Contact_Association_Type__c();
        cat.Contact__c = con.Id;
        cat.RecordTypeId = degMedSchRecordTypeId;
        cat.Account__c = acc.Id;
        INSERT cat;
        
        Exam_Registration__c examReg1 = new Exam_Registration__c();
        examReg1.Applicant__c = con.Id;
        examReg1.Exam_Status__c = Constants.EXAM_REGISTRATION_EXAM_STATUS_PASSED;
        examReg1.Exam_Types__c = 'USMLE Step 1';
        examReg1.EP_end_Date__c = Date.today();
        examReg1.Posted_Date__c = Date.today();
        INSERT examReg1;
        
        Service__c Ser = (Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultServiceTestData.class, new Service__c(Name='Performance Data', Signature_Required__c = true));
        run();
        Account2Service__c acc2SerRec = (Account2Service__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new Account2Service__c(Service__c=Ser.Id, Account__c = acc.Id,Active__c = true));
        run();
        CONTACT2ACCTSERVICE__c con2accser = (CONTACT2ACCTSERVICE__c)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccount2ServiceTestData.class, new CONTACT2ACCTSERVICE__c(Active__c = true,Service_Contact__c =con.id,Account_Service__c = acc2SerRec.id));
        run();
        
        /*Service__c serv = new Service__c();
        serv.Name='Performance Data';
        serv.Signature_Required__c = true;
        insert serv;
        
        Account2Service__c acc2ser = new Account2Service__c();
        acc2ser.Account__c =acc.id;
        acc2ser.Active__c = true;
        acc2ser.Service__c = serv.id;
        insert acc2ser;

        CONTACT2ACCTSERVICE__c con2accser = new CONTACT2ACCTSERVICE__c();
        con2accser.Active__c = true;
        con2accser.Service_Contact__c =con.id;
        con2accser.Account_Service__c = acc2ser.id;
        Insert con2accser;*/
        
        Test.startTest();
		String cronExp = '0 0 0 15 3 ? *';
        String jobId = System.schedule('PerformanceDataNotificationScheduler',  cronExp, new PerformanceDataNotificationScheduler());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression,'TestMethod');
        System.assertEquals(0, ct.TimesTriggered,'TestMethod');
        Test.stopTest();
    }
}