@isTest
public class EpicReportExpireSchedTest{
    @isTest 
    public static void testSchedulerExecute(){
        Test.startTest();
        String chron = '0 16 * * * ?';
        String jobId = System.Schedule('Test EpicReportExpirationScheduler', chron, new EpicReportExpirationScheduler());
        System.assert(jobId!=null,'Job no scheduled yet');
        Test.stopTest();
    }

}