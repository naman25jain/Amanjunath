@isTest
private class OFACAkaRequestBatchSchedulerTest {
    @isTest
    static void testSchedulerExecute(){
        Test.startTest();
        String chron = '0 0 23 * * ?';
        System.Schedule('Test OFACAkaRequestBatchScheduler', chron, new OFACAkaRequestBatchScheduler());
        Test.stopTest();
    }     
}