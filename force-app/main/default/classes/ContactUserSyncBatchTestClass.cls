@isTest(seealldata=false)
public class ContactUserSyncBatchTestClass extends ECFMGTestFactory{
    private static CurrentEntityIDSequence__c settingsInstance;
    static{
        CurrentEntityIDSequence__c settingsInstance = CurrentEntityIDSequence__c.getOrgDefaults();
        settingsInstance.Entity_ID__c = '0000000';
        upsert settingsInstance;
    }
    private static CurrentECFMGIDSequence__c settingsECFMGInstance;
    static{
        CurrentECFMGIDSequence__c settingsECFMGInstance = CurrentECFMGIDSequence__c.getOrgDefaults();
        settingsECFMGInstance.ECFMG_ID__c = '00000001';
        upsert settingsECFMGInstance;
    }
    @isTest
    static void testContactUserSyncBatch(){
        Id conRecordTypeId = GenericUtilities.getRecordTypeIdByDevName('Contact',Constant_Contact__mdt.getInstance('REC_TYPE_APPLICANT').Value__c);
        Account acc = (Account)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultAccountData.class, new Account(Name='Account Test'));
        Contact con = (Contact)ECFMGTestFactory.make(ECFMGDefaultTestData.DefaultContactData.class, new Contact(FirstName='Test', LastName='Contacts', USMLE_ID__c='1234', RecordTypeId=conRecordTypeId, Account = acc, Gender__c = 'Male',MailingStreet = 'Test Street',
        Mailingcity = 'Test City', MailingState = 'New Jersey', MailingCountry = 'United States',
        MailingPostalCode = '123456', Name_Change__c = true));
        run();
        String userId = Userinfo.getUserId();
        User currentUser = [Select LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey from User where Id =: userId];
        Profile p = [Select Id from Profile where Profile.Name = '4-Customer Community Plus Login'];
        User userObj = (User)ECFMGTestFactory.make(ECFMGDefaultTestData.SystemAdminUser.class, new User(FirstName = 'Test', LastName = 'LastName', Alias = 'TLast', CommunityNickName = 'TestLastName',
                Email = 'TestLastName@Test.com',UserName = 'TestLastName@Test.com', ProfileId = p.Id, ContactId = con.Id, LocaleSidKey = currentUser.LocaleSidKey,
                LanguageLocaleKey = currentUser.LanguageLocaleKey,
                TimeZoneSidKey = currentUser.TimeZoneSidKey,
                EmailEncodingKey = currentUser.EmailEncodingKey));
        run();
        System.runAs(userObj){
            Test.StartTest();
            Database.ExecuteBatch(new ContactUserSyncBatch(), 200);
            Test.StopTest();
            User usr = [SELECT FirstName, LastName FROM User WHERE ContactId = :con.Id LIMIT 1];
            System.assertEquals(con.LastName,usr.LastName,'LastName of user and contact doesnot match');
            System.assertequals(con.FirstName,usr.FirstName,'FirstName of user and contact doesnot match');
        }
    }
    @isTest
    public static void testContUserSyncBatchSchd(){
        Test.startTest();
		String cronExp = '0 0 1 * * ? *';
        String jobId = System.schedule('ContactUserSyncBatchSchedule'+System.now(), cronExp, new ContactUserSyncBatchSchedule());
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression,'Cron expression doesnot match');
        Test.stopTest();
    }
}