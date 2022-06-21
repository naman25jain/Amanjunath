@isTest(seeAllData=false)
public class ScheduleRestrictionBatchTest{
	@isTest
	public static void scheduleBatchtest(){
        String chron = '0 0 22 * * ?';
        String jobId = System.Schedule('ScheduleRestrictionBatchTest', chron, new ScheduleRestrictionBatch());
        System.assert(jobId!=null,'Scheduling failed');
        Test.StartTest();
        RestrictionProcessBatch e = new RestrictionProcessBatch();
        Database.executeBatch(e);
        Test.StopTest();
    }
}