/**
 * Scheduler class for EntityEnrollmentVerificationDailyBatch
 *
 * @author        Nayana
 * @version       1.0
 * @createdDate   09-JUN-2020
 */
global with sharing class EntityEnrollmentVerificationDailySched implements Schedulable {
    public static final Integer MAX_BATCH_SIZE = 200;
    
    global void execute(SchedulableContext context) {

		EntityEnrollmentVerificationDailyBatch b = new EntityEnrollmentVerificationDailyBatch();
		Database.executeBatch(b, MAX_BATCH_SIZE);

	}
}