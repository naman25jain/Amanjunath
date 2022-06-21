/**
 * Created by Matthew on 2019-07-19.
 */

global with sharing class VerReqFilesBatchSched implements Schedulable { 

    global void execute(SchedulableContext context) {

        VerReqFilesBatch b = new VerReqFilesBatch();

        Database.executeBatch(b, VerReqFilesBatch.MAX_BATCH_SIZE);

    }
}