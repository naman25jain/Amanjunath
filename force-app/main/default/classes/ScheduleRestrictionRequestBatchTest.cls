@isTest(seeAllData=false)
public class ScheduleRestrictionRequestBatchTest{
    @isTest
	public static void scheduletest(){
        String chron = '0 0 22 * * ?';
        String jobId = System.Schedule('ScheduleRestrictionRequestBatchTest', chron, new ScheduleRestrictionRequestBatch());
        System.assert(jobId!=null,'Scheduling failed');
        Test.StartTest();
        RestrictionProcessBatch e = new RestrictionProcessBatch();
        Database.executeBatch(e);
        Test.StopTest();
    }
}