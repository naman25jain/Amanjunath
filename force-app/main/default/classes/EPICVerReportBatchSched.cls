global with sharing class EPICVerReportBatchSched implements Schedulable{ 
    global void execute(SchedulableContext context){
        EPICVerReportBatch b = new EPICVerReportBatch();
        Database.executeBatch(b, EPICVerReportBatch.MAX_BATCH_SIZE);
    }
}