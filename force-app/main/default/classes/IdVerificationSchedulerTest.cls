@isTest
public class IdVerificationSchedulerTest{
    /***************
     * name : unittest2
     * Description - Test method
     * ****************/
    public static testmethod void unittest2(){
        String chron = '0 0 22 * * ?';
        String jobId = System.Schedule('TestIdVerificationScheduler', chron, new IdVerificationScheduler());
        System.assert(jobId!=null,'Scheduling failed');
        Test.StartTest();
        IdVerificationExpiration e = new IdVerificationExpiration();
        Database.executeBatch(e);
        Test.StopTest();
    }
}