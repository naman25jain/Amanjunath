//Test class for EPICVerReportBatch
@istest
public class EPICVerReportBatchSchedTest{
    @isTest 
    public static void epicRestCredentialsTestMethod(){
        Test.StartTest();
        EPICVerReportBatchSched reportBatch = new EPICVerReportBatchSched();      
        String t = '0 0 23 * * ?';
        String jobId = system.schedule('Test check', t, reportBatch);
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(t, ct.CronExpression, 'Job did not schedule');
    }    
}