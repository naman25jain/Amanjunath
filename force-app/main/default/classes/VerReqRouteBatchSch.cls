/**
 * Created by Matthew on 2019-06-21.
 */

global class VerReqRouteBatchSch implements Schedulable {

	global void execute(SchedulableContext context) {

		VerReqRouteBatch b = new VerReqRouteBatch();

		Database.executeBatch(b, VerReqRouteBatch.MAX_BATCH_SIZE);

	}
}