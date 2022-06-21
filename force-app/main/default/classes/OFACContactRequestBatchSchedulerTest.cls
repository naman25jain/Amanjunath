@isTest
private class OFACContactRequestBatchSchedulerTest {
    @isTest
    static void testSchedulerExecute(){
        Test.startTest();
        String chron = '0 0 23 * * ?';
        System.Schedule('Test OFACContactRequestBatchScheduler', chron, new OFACContactRequestBatchScheduler());
        Test.stopTest();
    } 
    
}