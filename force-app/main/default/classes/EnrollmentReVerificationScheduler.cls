/**
 * Scheduler class for EnrollmentReVerificationBatch
 *
 * @author        Enable Consulting
 * @version       1.0
 * @createdDate   07-APR-2020
 */
global with sharing class EnrollmentReVerificationScheduler implements Schedulable {
    
    global void execute(SchedulableContext context) {

        Integer batchSize = Integer.valueOf(System.Label.EnrollmentReVerificationBatch_Size);
		EnrollmentReVerificationBatch b = new EnrollmentReVerificationBatch();

		Database.executeBatch(b, batchSize);

	}
}