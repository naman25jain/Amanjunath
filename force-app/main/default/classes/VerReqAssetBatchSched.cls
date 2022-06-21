public with sharing class VerReqAssetBatchSched implements Schedulable {
    public void execute(SchedulableContext context) {

        VerReqAssetBatch b = new VerReqAssetBatch();

        Database.executeBatch(b, VerReqAssetBatch.MAX_BATCH_SIZE);

    }

}