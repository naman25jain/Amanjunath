/**
 * Scheduler class for SevenYearRuleBatch
 *
 * @author        Femi
 * @version       1.0
 * @createdDate   05-MAY-2020
 */
global with sharing class SevenYearRuleScheduler implements Schedulable {
	
    global void execute(SchedulableContext context) {

        Integer batchSize = Integer.valueOf(System.Label.SevenYearRuleBatch_Size);
		SevenYearRuleBatch b = new SevenYearRuleBatch();

		Database.executeBatch(b, batchSize);

	}
}