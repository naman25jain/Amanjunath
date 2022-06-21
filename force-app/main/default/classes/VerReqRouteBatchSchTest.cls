@isTest
public class VerReqRouteBatchSchTest {

	public static final String CRON_EXPRESSION = '0 0 0 1 1 ? 2050'; // 1/1/2050
	public static final String NEXT_FIRE_TIME = '2050-01-01 00:00:00';
	public static final String SCHEDULED_CLASS_NAME = 'ScheduleApexClassTest';

	static testmethod void test() {

		// schedule the test job
		String jobId = System.schedule(SCHEDULED_CLASS_NAME, CRON_EXPRESSION, new VerReqRouteBatchSch());

		// get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

		// verify the expressions are the same
		System.assertEquals(CRON_EXPRESSION, ct.CronExpression);

		// verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// verify the next time the job will run
		System.assertEquals(NEXT_FIRE_TIME, String.valueOf(ct.NextFireTime));
	}
}