@isTest
private class OFACAccountRequestBatchSchedulerTest {
    @isTest
    static void testSchedulerExecute(){
        Test.startTest();
        String chron = '0 0 22 * * ?';
        System.Schedule('Test OFACAccountRequestBatchScheduler', chron, new OFACAccountRequestBatchScheduler());
        Test.stopTest();
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
}