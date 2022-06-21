/**
* Test Class for Not Reviewed Enrollment Verification weekly notification
*
* @author        Nayana
* @version       1.0
* @createdDate   11-JUN-2020
*/
@isTest
public class EntityEnrollmentVerificationDailyTest {
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
    @testSetup static void setup() {
        EntityEnrollmentVerificationTestFactory.servicePageSetup();
    }
    public static testMethod void entityEVDailyTest() {
        Test.startTest();
		String cronExp = '0 0 22 * * ? *';
        String jobId = System.schedule('EntityEnrollmentVerificationDailySched',  cronExp, new EntityEnrollmentVerificationDailySched());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}