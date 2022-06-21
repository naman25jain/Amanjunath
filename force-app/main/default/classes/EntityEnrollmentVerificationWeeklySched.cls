/**
 * Scheduler class for EntityEnrollmentVerificationWeeklyBatch
 *
 * @author        Nayana
 * @version       1.0
 * @createdDate   10-JUN-2020
 */
global with sharing class EntityEnrollmentVerificationWeeklySched implements Schedulable {
    public static final Integer MAX_BATCH_SIZE = 200;
    
    global void execute(SchedulableContext context) {

		EntityEnrollmentVerificationWeeklyBatch b = new EntityEnrollmentVerificationWeeklyBatch();
		Database.executeBatch(b, MAX_BATCH_SIZE);

	}
}