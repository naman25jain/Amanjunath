@isTest
private class ApplicantMyProfileUsernameChangeTest extends ECFMGTestFactory{
    @testSetup static void setup(){
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', Email = 'xyz@mail.com'));
        Contact con1 = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Frist', LastName='Last', USMLE_ID__c='4321', Email = 'abc@mail.com'));
    	Id pId = [Select Id from profile where name = '4-Customer Community Plus Login' LIMIT 1].id;
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias='flastt',email='tester@unknownmail.com',emailencodingkey='UTF-8',lastname='last', languagelocalekey='en_US',localesidkey='en_US',profileid=pId,country='United States',IsActive=true,timezonesidkey='America/Los_Angeles',username='tester@unknownmail.com',Username_Change_Needed__c=true,Contact=con));
        ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultUserTestData.class, new User(alias='flastt',email='tester@unknownmail.devint',emailencodingkey='UTF-8',lastname='last', languagelocalekey='en_US',localesidkey='en_US',profileid=pId,country='United States',IsActive=true,timezonesidkey='America/Los_Angeles',username='tester@unknownmail.com.devint',Username_Change_Needed__c=true,Contact=con1));
    	run();
    }
    @isTest
    public static void testJob(){
        Test.startTest();
        ApplicantMyProfileUsernameChange a = new ApplicantMyProfileUsernameChange();
        Database.executeBatch(a);
        String jobId = System.schedule('ApplicantMyProfileUsernameChangeSchedule',
                                       '0 0 0 3 9 ? 2022',
                                       new ApplicantMyProfileUsernameChangeSchedule());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression, 'Cron expressions are not the same');
        System.assertEquals(0, ct.TimesTriggered, 'the job has run before the test ended');
        Test.stopTest();
        User assertionUser = [SELECT Username_Change_Needed__c from User where UserName='tester@unknownmail.com' LIMIT 1];
        System.assertEquals(false, assertionUser.Username_Change_Needed__c, 'Applicant Username not changed'); 
    }
}