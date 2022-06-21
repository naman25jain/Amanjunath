/**
 * Scheduler class for ScoreReleaseBatch
 *
 * @author        Nayana
 * @version       1.0
 * @createdDate   05-MAY-2020
 */
global with sharing class ScoreReleaseScheduler implements Schedulable {
    
    public static final Integer MAX_BATCH_SIZE = 200;
    
    global void execute(SchedulableContext context) {

		ScoreReleaseBatch b = new ScoreReleaseBatch();
		Database.executeBatch(b, MAX_BATCH_SIZE);

	}
}