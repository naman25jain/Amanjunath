/**
 * Created by Matthew on 2019-06-21.
 */

global with sharing class VerReqAccountDupeCheckBatchSch implements Schedulable {

	global void execute(SchedulableContext context) {

		VerReqAccountDupeCheckBatch b = new VerReqAccountDupeCheckBatch();

		Database.executeBatch(b, VerReqAccountDupeCheckBatch.MAX_BATCH_SIZE);

	}
}