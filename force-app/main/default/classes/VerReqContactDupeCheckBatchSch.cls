global with sharing class VerReqContactDupeCheckBatchSch implements Schedulable{
	global void execute(SchedulableContext context){
		VerReqContactDupeCheckBatch b = new VerReqContactDupeCheckBatch();
		Database.executeBatch(b, VerReqContactDupeCheckBatch.MAX_BATCH_SIZE);
	}
}